import 'package:drift/drift.dart';

import '../../core/utils/clock.dart';
import '../db/database.dart';

/// Fuel entry reads and writes.
///
/// Ordering matters here more than anywhere else in the app: the mileage
/// engine walks entries in odometer order to build full-tank windows, so
/// every list read is sorted by odometer with `dateMs` only as a tiebreaker
/// for two fills at the same reading.
class FuelRepo {
  FuelRepo(this._db);

  final AppDatabase _db;

  // -------------------------------------------------------------------
  // Reads
  // -------------------------------------------------------------------

  /// Ascending by odometer — the order the mileage calculator expects.
  Stream<List<FuelEntryRow>> watchForVehicle(int vehicleId) {
    return (_db.select(_db.fuelEntries)
          ..where((f) => f.vehicleId.equals(vehicleId) & f.deletedAt.isNull())
          ..orderBy([
            (f) => OrderingTerm(expression: f.odometerM),
            (f) => OrderingTerm(expression: f.dateMs),
          ]))
        .watch();
  }

  Future<List<FuelEntryRow>> getForVehicle(int vehicleId) =>
      watchForVehicle(vehicleId).first;

  /// Entries inside a date range, still in odometer order.
  Future<List<FuelEntryRow>> getInRange(
    int vehicleId, {
    required int fromMs,
    required int toMs,
  }) {
    return (_db.select(_db.fuelEntries)
          ..where(
            (f) =>
                f.vehicleId.equals(vehicleId) &
                f.deletedAt.isNull() &
                f.dateMs.isBetweenValues(fromMs, toMs),
          )
          ..orderBy([
            (f) => OrderingTerm(expression: f.odometerM),
            (f) => OrderingTerm(expression: f.dateMs),
          ]))
        .get();
  }

  Future<FuelEntryRow?> getById(int id) {
    return (_db.select(
      _db.fuelEntries,
    )..where((f) => f.id.equals(id) & f.deletedAt.isNull())).getSingleOrNull();
  }

  /// The highest odometer reading recorded for this vehicle in *any* table
  /// that carries one — fuel entries, service logs and completed rides all
  /// count as odometer observations.
  ///
  /// This is what the add-fuel form pre-fills and validates against, and what
  /// service due prediction measures from. Returns the vehicle's initial
  /// odometer when nothing has been logged yet.
  Future<int> latestOdometerM(int vehicleId) async {
    final row = await _db
        .customSelect(
          '''
      SELECT MAX(o) AS max_o FROM (
        SELECT MAX(odometer_m) AS o FROM fuel_entries
          WHERE vehicle_id = ? AND deleted_at IS NULL
        UNION ALL
        SELECT MAX(odometer_m) FROM service_logs
          WHERE vehicle_id = ? AND deleted_at IS NULL
        UNION ALL
        SELECT MAX(end_odometer_m) FROM rides
          WHERE vehicle_id = ? AND deleted_at IS NULL
        UNION ALL
        SELECT initial_odometer_m FROM vehicles WHERE id = ?
      )
      ''',
          variables: List.filled(4, Variable.withInt(vehicleId)),
          readsFrom: {
            _db.fuelEntries,
            _db.serviceLogs,
            _db.rides,
            _db.vehicles,
          },
        )
        .getSingle();
    return row.read<int?>('max_o') ?? 0;
  }

  Stream<int> watchLatestOdometerM(int vehicleId) {
    // Any write to a table feeding the query above invalidates the reading,
    // so the home screen's odometer strip re-rolls on its own.
    return _db
        .customSelect(
          'SELECT 1',
          readsFrom: {
            _db.fuelEntries,
            _db.serviceLogs,
            _db.rides,
            _db.vehicles,
          },
        )
        .watch()
        .asyncMap((_) => latestOdometerM(vehicleId));
  }

  /// The most recent fill by date, used to pre-fill price per unit.
  Future<FuelEntryRow?> latestEntry(int vehicleId) {
    return (_db.select(_db.fuelEntries)
          ..where((f) => f.vehicleId.equals(vehicleId) & f.deletedAt.isNull())
          ..orderBy([
            (f) => OrderingTerm(expression: f.dateMs, mode: OrderingMode.desc),
            (f) => OrderingTerm(expression: f.id, mode: OrderingMode.desc),
          ])
          ..limit(1))
        .getSingleOrNull();
  }

  /// Odometer observations from every source, ascending by date. Feeds the
  /// daily-km estimate behind service due dates.
  Future<List<({int dateMs, int odometerM})>> odometerObservations(
    int vehicleId, {
    int? sinceMs,
  }) async {
    final since = sinceMs ?? 0;
    final rows = await _db
        .customSelect(
          '''
      SELECT date_ms AS d, odometer_m AS o FROM fuel_entries
        WHERE vehicle_id = ? AND deleted_at IS NULL AND date_ms >= ?
      UNION ALL
      SELECT date_ms, odometer_m FROM service_logs
        WHERE vehicle_id = ? AND deleted_at IS NULL AND date_ms >= ?
      UNION ALL
      SELECT end_time_ms, end_odometer_m FROM rides
        WHERE vehicle_id = ? AND deleted_at IS NULL
          AND end_time_ms IS NOT NULL AND end_odometer_m IS NOT NULL
          AND end_time_ms >= ?
      ORDER BY d ASC
      ''',
          variables: [
            for (var i = 0; i < 3; i++) ...[
              Variable.withInt(vehicleId),
              Variable.withInt(since),
            ],
          ],
          readsFrom: {_db.fuelEntries, _db.serviceLogs, _db.rides},
        )
        .get();

    return [
      for (final r in rows)
        (dateMs: r.read<int>('d'), odometerM: r.read<int>('o')),
    ];
  }

  // -------------------------------------------------------------------
  // Writes
  // -------------------------------------------------------------------

  Future<int> create(FuelEntriesCompanion draft) {
    final now = Clock.nowMs;
    return _db
        .into(_db.fuelEntries)
        .insert(draft.copyWith(createdAt: Value(now), updatedAt: Value(now)));
  }

  Future<void> update(int id, FuelEntriesCompanion changes) async {
    await (_db.update(_db.fuelEntries)..where((f) => f.id.equals(id))).write(
      changes.copyWith(updatedAt: Value(Clock.nowMs)),
    );
  }

  Future<void> softDelete(int id) async {
    final now = Clock.nowMs;
    await (_db.update(_db.fuelEntries)..where((f) => f.id.equals(id))).write(
      FuelEntriesCompanion(deletedAt: Value(now), updatedAt: Value(now)),
    );
  }

  /// Undo support for the swipe-to-delete gesture.
  Future<void> restore(int id) async {
    await (_db.update(_db.fuelEntries)..where((f) => f.id.equals(id))).write(
      FuelEntriesCompanion(
        deletedAt: const Value(null),
        updatedAt: Value(Clock.nowMs),
      ),
    );
  }
}
