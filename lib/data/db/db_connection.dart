import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';

/// Where the SQLite file lives and how it is opened.
///
/// The path is computed here rather than handed to `driftDatabase(name:)`
/// because Phase 5's raw database backup/restore needs the exact [File] to
/// copy — a perfect-fidelity backup for same-version transfers.
abstract final class DbConnection {
  static const fileName = 'jatra.sqlite';

  /// Resolved once and cached; `getApplicationDocumentsDirectory` hits a
  /// platform channel and the backup screen asks for this repeatedly.
  static File? _cachedFile;

  static Future<File> databaseFile() async {
    final cached = _cachedFile;
    if (cached != null) return cached;
    final dir = await getApplicationDocumentsDirectory();
    return _cachedFile = File('${dir.path}/$fileName');
  }

  /// Opens the database on a background isolate, so a large import or a
  /// 50,000-point ride query never blocks the UI isolate.
  static QueryExecutor open() {
    return LazyDatabase(() async {
      final file = await databaseFile();
      return NativeDatabase.createInBackground(
        file,
        // Surface constraint violations loudly in debug rather than letting
        // an orphaned row reach a backup file.
        setup: (db) => db.execute('PRAGMA foreign_keys = ON;'),
      );
    });
  }
}
