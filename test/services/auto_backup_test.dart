import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jatra/core/utils/clock.dart';
import 'package:jatra/data/db/database.dart';
import 'package:jatra/data/db/demo_seed.dart';
import 'package:jatra/data/repositories/backup_repo.dart';
import 'package:jatra/services/auto_backup_service.dart';
import 'package:jatra/services/export_service.dart';
import 'package:jatra/services/settings_service.dart';

class _FakeFolder implements BackupFolder {
  final files = <String>[];
  bool access = true;
  bool failWrite = false;

  @override
  Future<void> delete(String uri, String name) async => files.remove(name);

  @override
  Future<bool> hasAccess(String uri) async => access;

  @override
  Future<List<String>> list(String uri) async => [...files];

  @override
  Future<({String label, String uri})?> pick() async =>
      (uri: 'content://tree', label: 'Drive');

  @override
  Future<void> write(String uri, String name, String sourcePath) async {
    if (failWrite) throw const FileSystemException('full');
    files.add(name);
  }
}

class _FakeExport extends ExportService {
  _FakeExport(super.repo, this.dir);

  final Directory dir;
  File? last;

  @override
  Future<ExportResult> exportJson({
    bool includeRidePoints = false,
    bool pretty = true,
  }) async {
    final file = File('${dir.path}/out.json')..writeAsStringSync('{}');
    last = file;
    return ExportResult(file: file, recordCount: 0, sizeBytes: 2);
  }
}

void main() {
  const day = Duration.millisecondsPerDay;

  group('policy', () {
    test('nothing changed is never due, however old', () {
      expect(
        AutoBackupPolicy.isDue(
          lastBackupMs: 0,
          nowMs: 100 * day,
          changedRecords: 0,
        ),
        isFalse,
      );
    });

    test('first change after enabling is due', () {
      expect(
        AutoBackupPolicy.isDue(lastBackupMs: null, nowMs: 1, changedRecords: 1),
        isTrue,
      );
    });

    test('a few changes wait until the week is up', () {
      bool due(int nowMs) => AutoBackupPolicy.isDue(
        lastBackupMs: 0,
        nowMs: nowMs,
        changedRecords: 4,
      );

      expect(due(6 * day), isFalse);
      expect(due(7 * day), isTrue);
    });

    test('the change threshold does not wait', () {
      expect(
        AutoBackupPolicy.isDue(lastBackupMs: 0, nowMs: 1, changedRecords: 5),
        isTrue,
      );
    });

    test('prunes only the oldest of our own files', () {
      final names = [
        for (var i = 1; i <= 7; i++) 'jatra_auto_2026-01-0${i}_120000.json',
        'my_notes.json',
        'odo_backup_2026-01-01_1200.json',
      ];

      expect(AutoBackupPolicy.surplus(names), [
        'jatra_auto_2026-01-01_120000.json',
        'jatra_auto_2026-01-02_120000.json',
      ]);
    });
  });

  group('service', () {
    late AppDatabase db;
    late _FakeFolder folder;
    late _FakeExport export;
    late SettingsService settings;
    late AutoBackupService service;
    late Directory dir;

    setUp(() async {
      db = AppDatabase.forTesting(NativeDatabase.memory());
      dir = Directory.systemTemp.createTempSync('jatra_auto');
      Clock.freeze(DateTime.utc(2026, 8, 4, 12));
      final repo = BackupRepo(db);
      folder = _FakeFolder();
      export = _FakeExport(repo, dir);
      settings = SettingsService();
      service = AutoBackupService(db, repo, export, settings, folder);
    });

    tearDown(() async {
      Clock.freeze(null);
      await db.close();
      dir.deleteSync(recursive: true);
    });

    test('does nothing until a folder is chosen', () async {
      await DemoSeed.seed(db);

      expect(await service.runIfDue(), isFalse);
      expect(folder.files, isEmpty);
    });

    test('choosing a folder backs up and records it', () async {
      await DemoSeed.seed(db);

      expect(await service.chooseFolder(), isTrue);
      expect(folder.files, hasLength(1));
      expect(settings.autoBackupFolderLabel.value, 'Drive');
      expect(settings.autoBackupLastMs.value, Clock.nowMs);
      expect(export.last!.existsSync(), isFalse, reason: 'temp file removed');
    });

    test('an empty log has nothing due', () async {
      settings.autoBackupFolderUri.value = 'content://tree';

      expect(await service.runIfDue(), isFalse);
    });

    test('a failed write keeps old backups and reports it', () async {
      await DemoSeed.seed(db);
      settings.autoBackupFolderUri.value = 'content://tree';
      folder.files.addAll([
        for (var i = 1; i <= 5; i++) 'jatra_auto_2026-01-0${i}_120000.json',
      ]);
      folder.failWrite = true;

      expect(await service.backUpNow(), isFalse);
      expect(folder.files, hasLength(5));
      expect(settings.autoBackupFailure.value, AutoBackupFailure.write.name);
      expect(settings.autoBackupLastMs.value, isNull);
    });

    test('lost folder access is reported as that', () async {
      settings.autoBackupFolderUri.value = 'content://tree';
      folder.access = false;

      expect(await service.backUpNow(), isFalse);
      expect(
        settings.autoBackupFailure.value,
        AutoBackupFailure.folderAccess.name,
      );
    });

    test('rolls the folder to the newest five', () async {
      await DemoSeed.seed(db);
      settings.autoBackupFolderUri.value = 'content://tree';
      folder.files.addAll([
        for (var i = 1; i <= 5; i++) 'jatra_auto_2020-01-0${i}_120000.json',
      ]);

      await service.backUpNow();

      expect(folder.files, hasLength(5));
      expect(
        folder.files,
        isNot(contains('jatra_auto_2020-01-01_120000.json')),
      );
    });
  });
}
