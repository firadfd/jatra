import 'dart:async';
import 'dart:io';

import 'package:drift/drift.dart' show TableUpdateQuery;
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart' hide Value;
import 'package:intl/intl.dart';

import '../core/utils/clock.dart';
import '../data/db/database.dart';
import '../data/repositories/backup_repo.dart';
import 'export_service.dart';
import 'settings_service.dart';

/// When a backup is worth writing. Pure, so the rules can be tested alone.
abstract final class AutoBackupPolicy {
  static const changeThreshold = 5;
  static const maxAge = Duration(days: 7);

  /// How many backups stay in the folder.
  static const keep = 5;

  static bool isDue({
    required int? lastBackupMs,
    required int nowMs,
    required int changedRecords,
  }) {
    // Nothing new: another copy would only push a useful older one out.
    if (changedRecords <= 0) return false;
    if (lastBackupMs == null) return true;
    if (changedRecords >= changeThreshold) return true;
    return nowMs - lastBackupMs >= maxAge.inMilliseconds;
  }

  /// Oldest surplus backups among [names]. Timestamped names sort by age.
  /// Anything that is not one of Jatra's automatic backups is never touched.
  static List<String> surplus(List<String> names) {
    final ours = names.where(isAutoBackupName).toList()..sort();
    return ours.length <= keep ? const [] : ours.sublist(0, ours.length - keep);
  }

  static bool isAutoBackupName(String name) =>
      name.startsWith(_prefix) && name.endsWith('.json');

  static const _prefix = 'jatra_auto_';

  static String fileName(DateTime at) =>
      '$_prefix${DateFormat('yyyy-MM-dd_HHmmss').format(at)}.json';
}

/// The chosen backup folder. An interface so the service runs in tests.
abstract interface class BackupFolder {
  /// Null when the user backed out of the system picker.
  Future<({String uri, String label})?> pick();
  Future<bool> hasAccess(String uri);
  Future<void> write(String uri, String name, String sourcePath);
  Future<List<String>> list(String uri);
  Future<void> delete(String uri, String name);
}

/// Android's Storage Access Framework, via `BackupFolder.kt`.
///
/// A plain path will not do: since Android 11 an app cannot write to shared
/// folders by path without a broad storage permission. A folder picked here
/// needs no manifest permission and stays reachable across restarts.
class AndroidBackupFolder implements BackupFolder {
  static const _channel = MethodChannel('com.firad.jatra/backup_folder');

  @override
  Future<({String uri, String label})?> pick() async {
    final picked = await _channel.invokeMapMethod<String, String>('pick');
    if (picked == null) return null;
    return (uri: picked['uri']!, label: picked['label']!);
  }

  @override
  Future<bool> hasAccess(String uri) async =>
      await _channel.invokeMethod<bool>('hasAccess', {'uri': uri}) ?? false;

  @override
  Future<void> write(String uri, String name, String sourcePath) =>
      _channel.invokeMethod('write', {
        'uri': uri,
        'name': name,
        'sourcePath': sourcePath,
      });

  @override
  Future<List<String>> list(String uri) async =>
      await _channel.invokeListMethod<String>('list', {'uri': uri}) ?? const [];

  @override
  Future<void> delete(String uri, String name) =>
      _channel.invokeMethod('delete', {'uri': uri, 'name': name});
}

/// Why the most recent automatic backup failed, if it did.
enum AutoBackupFailure { folderAccess, write }

/// Writes rolling JSON backups to a folder the rider chose.
///
/// Off until a folder is picked. Runs only while the app is alive, the same
/// as the home widget: records can only change while it is running, so a
/// background job would have nothing extra to save. The one gap is a weekly
/// backup falling due while the app stays closed, which then runs on next
/// launch, with nothing lost in between.
class AutoBackupService extends GetxService with WidgetsBindingObserver {
  AutoBackupService(
    this._db,
    this._repo,
    this._export,
    this._settings,
    this._folder,
  );

  /// Long enough that a run of edits becomes one check.
  static const _debounce = Duration(seconds: 5);

  final AppDatabase _db;
  final BackupRepo _repo;
  final ExportService _export;
  final SettingsService _settings;
  final BackupFolder _folder;

  StreamSubscription<void>? _changes;
  Timer? _pending;
  bool _running = false;

  final isRunning = false.obs;

  static bool get isSupported => !kIsWeb && Platform.isAndroid;

  AutoBackupService init() {
    if (!isSupported) return this;
    WidgetsBinding.instance.addObserver(this);

    // Rides are absent on purpose: a recording updates its row constantly.
    // A finished ride is still counted, and caught by the next check.
    _changes = _db
        .tableUpdates(
          TableUpdateQuery.onAllTables([
            _db.vehicles,
            _db.fuelEntries,
            _db.serviceLogs,
            _db.expenses,
          ]),
        )
        .listen((_) => _schedule());

    unawaited(runIfDue());
    return this;
  }

  @override
  void onClose() {
    if (isSupported) WidgetsBinding.instance.removeObserver(this);
    _changes?.cancel();
    _pending?.cancel();
    super.onClose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed ||
        state == AppLifecycleState.paused) {
      unawaited(runIfDue());
    }
  }

  void _schedule() {
    _pending?.cancel();
    _pending = Timer(_debounce, () => unawaited(runIfDue()));
  }

  /// Lets the rider choose a folder, then backs up straight away so a bad
  /// folder shows up now rather than a week from now.
  Future<bool> chooseFolder() async {
    final picked = await _folder.pick();
    if (picked == null) return false;
    _settings.autoBackupFolderUri.value = picked.uri;
    _settings.autoBackupFolderLabel.value = picked.label;
    return backUpNow();
  }

  /// Stops future backups. Files already in the folder stay.
  void turnOff() {
    _settings.autoBackupFolderUri.value = null;
    _settings.autoBackupFolderLabel.value = null;
    _settings.autoBackupFailure.value = null;
  }

  Future<bool> backUpNow() => _run(force: true);

  Future<bool> runIfDue() => _run(force: false);

  /// True when a backup was written.
  Future<bool> _run({required bool force}) async {
    final uri = _settings.autoBackupFolderUri.value;
    if (uri == null || _running) return false;

    _running = true;
    isRunning.value = true;
    File? temp;
    try {
      // Taken before reading, so an edit landing mid-backup counts as
      // unsaved rather than being marked as covered.
      final startedMs = Clock.nowMs;
      final last = _settings.autoBackupLastMs.value;

      if (!force) {
        final changed = await _repo.changedRecordsSince(last ?? 0);
        final due = AutoBackupPolicy.isDue(
          lastBackupMs: last,
          nowMs: startedMs,
          changedRecords: changed,
        );
        if (!due) return false;
      }

      if (!await _folder.hasAccess(uri)) {
        _settings.autoBackupFailure.value = AutoBackupFailure.folderAccess.name;
        return false;
      }

      final result = await _export.exportJson(
        includeRidePoints: _settings.includeRidePointsInExport.value,
        pretty: _settings.prettyPrintExport.value,
      );
      temp = result.file;

      await _folder.write(
        uri,
        AutoBackupPolicy.fileName(DateTime.now()),
        temp.path,
      );

      // Only after the new file exists, so a failed write removes nothing.
      for (final name in AutoBackupPolicy.surplus(await _folder.list(uri))) {
        await _folder.delete(uri, name);
      }

      _settings.autoBackupLastMs.value = startedMs;
      _settings.autoBackupFailure.value = null;
      return true;
    } on Object catch (e, stack) {
      debugPrint('Automatic backup failed: $e\n$stack');
      _settings.autoBackupFailure.value = AutoBackupFailure.write.name;
      return false;
    } finally {
      if (temp != null && temp.existsSync()) await temp.delete();
      _running = false;
      isRunning.value = false;
    }
  }
}
