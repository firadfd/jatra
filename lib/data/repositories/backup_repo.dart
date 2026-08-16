import 'dart:io';

import 'package:drift/drift.dart';

import '../db/database.dart';
import '../db/db_connection.dart';
import '../models/backup.dart';

/// Reads the whole database out and writes a whole database back in.
///
/// Every import runs inside a single transaction: either the entire file
/// lands or nothing changes. There is no state in which a user has half a
/// backup.
class BackupRepo {
  BackupRepo(this._db);

  final AppDatabase _db;

  // -------------------------------------------------------------------
  // Reading
  // -------------------------------------------------------------------

  /// Every row, tombstones included.
  ///
  /// Soft-deleted records are exported on purpose: they are how a later
  /// import tells "the user deleted this" apart from "this device never had
  /// it", which is the whole reason the tombstones exist.
  Future<BackupData> readAll({bool includeRidePoints = false}) async {
    return BackupData(
      vehicles: await _db.select(_db.vehicles).get(),
      fuelEntries: await _db.select(_db.fuelEntries).get(),
      serviceItems: await _db.select(_db.serviceItems).get(),
      serviceLogs: await _db.select(_db.serviceLogs).get(),
      expenses: await _db.select(_db.expenses).get(),
      rides: await _db.select(_db.rides).get(),
      ridePoints: includeRidePoints
          ? await _db.select(_db.ridePoints).get()
          : const [],
      includesRidePoints: includeRidePoints,
    );
  }

  // -------------------------------------------------------------------
  // Writing
  // -------------------------------------------------------------------

  /// Applies a validated backup.
  ///
  /// [companions] arrive already parsed and integrity-checked — this method
  /// assumes nothing needs rejecting and concerns itself only with getting
  /// the rows in atomically, parents before children.
  Future<void> restore({
    required MergeStrategy strategy,
    required List<VehiclesCompanion> vehicles,
    required List<FuelEntriesCompanion> fuelEntries,
    required List<ServiceItemsCompanion> serviceItems,
    required List<ServiceLogsCompanion> serviceLogs,
    required List<ExpensesCompanion> expenses,
    required List<RidesCompanion> rides,
    required List<RidePointsCompanion> ridePoints,
  }) async {
    await _db.transaction(() async {
      if (strategy == MergeStrategy.replaceAll) {
        await _db.wipeAll();
      }

      // Insertion order matters: a fuel entry cannot land before the vehicle
      // it points at, and foreign keys are enforced.
      await _insertAll(_db.vehicles, vehicles, strategy);
      await _insertAll(_db.serviceItems, serviceItems, strategy);
      await _insertAll(_db.fuelEntries, fuelEntries, strategy);
      await _insertAll(_db.serviceLogs, serviceLogs, strategy);
      await _insertAll(_db.expenses, expenses, strategy);
      await _insertAll(_db.rides, rides, strategy);
      await _insertAll(_db.ridePoints, ridePoints, strategy);

      // SQLite tracks the next autoincrement value per table in a side
      // table. Restoring rows with explicit IDs leaves it stale, so the very
      // next insert would collide with a just-imported ID.
      await _resyncAutoIncrement();
    });
  }

  Future<void> _insertAll<T extends Table, D>(
    TableInfo<T, D> table,
    List<Insertable<D>> rows,
    MergeStrategy strategy,
  ) async {
    if (rows.isEmpty) return;

    // After a wipe there is nothing to conflict with, so a plain insert is
    // both correct and faster.
    final mode = switch (strategy) {
      MergeStrategy.replaceAll => InsertMode.insert,
      MergeStrategy.keepMine => InsertMode.insertOrIgnore,
      MergeStrategy.preferImported => InsertMode.insertOrReplace,
    };

    await _db.batch((batch) => batch.insertAll(table, rows, mode: mode));
  }

  /// Pushes each table's autoincrement counter past the highest imported ID.
  Future<void> _resyncAutoIncrement() async {
    const tables = [
      'vehicles',
      'fuel_entries',
      'service_items',
      'service_logs',
      'expenses',
      'rides',
      'ride_points',
    ];

    for (final table in tables) {
      await _db.customStatement(
        'UPDATE sqlite_sequence SET seq = '
        '(SELECT IFNULL(MAX(id), 0) FROM $table) WHERE name = ?',
        [table],
      );
      // A table that has never had a row has no sqlite_sequence entry yet;
      // create one so the UPDATE above has something to hit next time.
      await _db.customStatement(
        'INSERT INTO sqlite_sequence (name, seq) '
        'SELECT ?, (SELECT IFNULL(MAX(id), 0) FROM $table) '
        'WHERE NOT EXISTS (SELECT 1 FROM sqlite_sequence WHERE name = ?)',
        [table, table],
      );
    }
  }

  // -------------------------------------------------------------------
  // Raw database file
  // -------------------------------------------------------------------

  /// Copies the SQLite file itself.
  ///
  /// Faster and higher fidelity than JSON for moving between devices on the
  /// same app version — it carries indexes and autoincrement state verbatim.
  /// JSON remains the portable format, because a `.sqlite` from a newer
  /// schema will not open on an older build.
  Future<File> copyDatabaseTo(String destinationPath) async {
    // Flush the write-ahead log into the main file first, or the copy will
    // be missing the most recent writes — the ones the user just made.
    await _db.customStatement('PRAGMA wal_checkpoint(TRUNCATE);');

    final source = await DbConnection.databaseFile();
    return source.copy(destinationPath);
  }

  /// Size of the live database file, for the backup screen.
  Future<int> databaseSizeBytes() async {
    final file = await DbConnection.databaseFile();
    return file.existsSync() ? file.length() : 0;
  }

  /// Overwrites the live database with [source].
  ///
  /// The connection must be closed first and the app restarted afterwards,
  /// so this is only ever called from a flow that does both.
  Future<void> replaceDatabaseWith(File source) async {
    final target = await DbConnection.databaseFile();

    await _db.close();

    // Drop the sidecar journals too. Leaving a stale -wal beside a swapped
    // -in database is a reliable way to corrupt it.
    for (final suffix in ['-wal', '-shm']) {
      final sidecar = File('${target.path}$suffix');
      if (sidecar.existsSync()) await sidecar.delete();
    }

    await source.copy(target.path);
  }
}
