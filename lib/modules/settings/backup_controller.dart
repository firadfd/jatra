import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:get/get.dart' hide Value;

import '../../data/models/backup.dart';
import '../../data/repositories/backup_repo.dart';
import '../../services/export_service.dart';
import '../../services/import_service.dart';
import '../../services/settings_service.dart';

/// Backup, export and import.
class BackupController extends GetxController {
  BackupController(this._export, this._import, this._repo, this.settings);

  final ExportService _export;
  final ImportService _import;
  final BackupRepo _repo;
  final SettingsService settings;

  final isBusy = false.obs;
  final busyLabel = ''.obs;

  /// Size of the live database, so the raw-backup option can state what it
  /// is about to copy.
  final databaseSizeBytes = 0.obs;

  /// A file the user picked and Jatra has validated, waiting on a merge
  /// strategy. Null when no import is in flight.
  final pending = Rxn<ParsedBackup>();
  final pendingFileName = ''.obs;

  final error = RxnString();

  @override
  void onInit() {
    super.onInit();
    _refreshSize();
  }

  Future<void> _refreshSize() async {
    databaseSizeBytes.value = await _repo.databaseSizeBytes();
  }

  Future<T?> _guarded<T>(String label, Future<T> Function() action) async {
    if (isBusy.value) return null;
    isBusy.value = true;
    busyLabel.value = label;
    error.value = null;
    try {
      return await action();
    } on BackupValidationException catch (e) {
      error.value = e.message;
      return null;
    } on Object catch (e) {
      error.value = 'Something went wrong: $e';
      return null;
    } finally {
      isBusy.value = false;
      busyLabel.value = '';
    }
  }

  // -------------------------------------------------------------------
  // Export
  // -------------------------------------------------------------------

  Future<void> exportJson() async {
    final result = await _guarded('Building backup…', () {
      return _export.exportJson(
        includeRidePoints: settings.includeRidePointsInExport.value,
        pretty: settings.prettyPrintExport.value,
      );
    });
    if (result == null) return;

    await _export.share([result.file], subject: 'Jatra backup');
    Get.snackbar(
      'Backup ready',
      '${result.recordCount} records · '
          '${_formatSize(result.sizeBytes)}',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  Future<void> exportCsv() async {
    final files = await _guarded('Building spreadsheets…', _export.exportCsv);
    if (files == null || files.isEmpty) return;

    await _export.share(files, subject: 'Jatra data (CSV)');
  }

  Future<void> exportDatabase() async {
    final result = await _guarded('Copying database…', _export.exportDatabase);
    if (result == null) return;

    await _export.share([result.file], subject: 'Jatra database');
  }

  // -------------------------------------------------------------------
  // Import
  // -------------------------------------------------------------------

  /// Picks a `.json` backup and validates it. Nothing is written yet — the
  /// user sees a preview and chooses a strategy first.
  Future<void> pickBackupFile() async {
    final picked = await _guarded('Reading file…', () async {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.any,
        withData: false,
      );
      final path = result?.files.single.path;
      if (path == null) return null;

      final parsed = await _import.parseFile(File(path));
      pendingFileName.value = result!.files.single.name;
      return parsed;
    });

    if (picked != null) pending.value = picked;
  }

  void cancelImport() {
    pending.value = null;
    pendingFileName.value = '';
    error.value = null;
  }

  /// Applies the pending import. Returns the safety-copy path, if one was
  /// made, so the UI can say where it went.
  Future<File?> applyPending(MergeStrategy strategy) async {
    final backup = pending.value;
    if (backup == null) return null;

    final safety = await _guarded('Importing…', () {
      return _import.apply(backup, strategy: strategy);
    });

    // `_guarded` returns null both on failure and on a non-destructive
    // import that made no safety copy, so success is judged on `error`.
    if (error.value != null) return null;

    cancelImport();
    Get.snackbar(
      'Import finished',
      '${backup.preview.totalRecords} records · ${strategy.label}',
      snackPosition: SnackPosition.BOTTOM,
    );
    return safety;
  }

  // -------------------------------------------------------------------
  // Raw database restore
  // -------------------------------------------------------------------

  /// Replaces the live database wholesale. The app must be restarted
  /// afterwards, which the UI makes clear before this is called.
  Future<bool> restoreDatabaseFile() async {
    final done = await _guarded('Restoring database…', () async {
      final result = await FilePicker.platform.pickFiles(withData: false);
      final path = result?.files.single.path;
      if (path == null) return false;

      await _import.restoreDatabaseFile(File(path));
      return true;
    });
    return done ?? false;
  }

  static String _formatSize(int bytes) {
    const units = ['B', 'KB', 'MB', 'GB'];
    var value = bytes.toDouble();
    var unit = 0;
    while (value >= 1024 && unit < units.length - 1) {
      value /= 1024;
      unit++;
    }
    final digits = value >= 100 || unit == 0 ? 0 : 1;
    return '${value.toStringAsFixed(digits)} ${units[unit]}';
  }
}
