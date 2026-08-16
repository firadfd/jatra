import 'package:drift/drift.dart';

import '../models/enums.dart';
import 'db_connection.dart';
import 'tables/tables.dart';

// The generated `part` below is compiled *into* this library, so every type it
// names — including the enums behind `textEnum` columns — must be imported
// here, not merely reachable through `tables.dart`.
export '../models/enums.dart';
export 'tables/tables.dart';

part 'database.g.dart';

/// The application database.
///
/// A migration strategy is in place from day one — correctness rule 8. Adding
/// a column means: bump [schemaVersion], add a case to [_upgrade], and add a
/// row to the table in `doc/schema_history.md`. Never edit an existing case.
@DriftDatabase(
  tables: [
    Vehicles,
    FuelEntries,
    ServiceItems,
    ServiceLogs,
    Expenses,
    Rides,
    RidePoints,
    Reminders,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(DbConnection.open());

  /// Injectable constructor for tests, which pass an in-memory executor.
  AppDatabase.forTesting(super.executor);

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) async {
      await m.createAll();
    },
    onUpgrade: _upgrade,
    beforeOpen: (details) async {
      // Foreign keys are off by default in SQLite and must be re-enabled
      // on every connection. Without this, the ON DELETE CASCADE that
      // makes "delete a vehicle" clean up its 142 fuel entries silently
      // does nothing.
      await customStatement('PRAGMA foreign_keys = ON;');
    },
  );

  Future<void> _upgrade(Migrator m, int from, int to) async {
    // v1 is the initial schema, so there is nothing to migrate yet. Future
    // versions append here:
    //
    //   if (from < 2) await m.addColumn(vehicles, vehicles.someNewColumn);
    //
    // Each `if` is cumulative and independent, so a device jumping v1 → v4
    // runs every intervening step in order.
  }

  /// Hard-deletes every row, in foreign-key-safe order.
  ///
  /// Used by "Delete all data" in settings and by a Replace-all import. This
  /// is the one place that bypasses soft deletes — the user explicitly asked
  /// for the data to be gone.
  Future<void> wipeAll() async {
    await transaction(() async {
      await delete(ridePoints).go();
      await delete(rides).go();
      await delete(reminders).go();
      await delete(serviceLogs).go();
      await delete(serviceItems).go();
      await delete(expenses).go();
      await delete(fuelEntries).go();
      await delete(vehicles).go();
    });
  }
}
