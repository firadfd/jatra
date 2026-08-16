import 'package:drift/drift.dart';

import '../../core/utils/clock.dart';
import '../db/database.dart';

/// Ride and ride-point access.
///
/// Points are written the instant they arrive — never buffered in memory —
/// so killing the app mid-ride costs at most the last sample.
class RideRepo {
  RideRepo(this._db);

  final AppDatabase _db;

  // -------------------------------------------------------------------
  // Rides
  // -------------------------------------------------------------------

  Stream<List<RideRow>> watchForVehicle(int vehicleId) {
    return (_db.select(_db.rides)
          ..where((r) => r.vehicleId.equals(vehicleId) & r.deletedAt.isNull())
          ..orderBy([
            (r) => OrderingTerm(
              expression: r.startTimeMs,
              mode: OrderingMode.desc,
            ),
          ]))
        .watch();
  }

  Future<List<RideRow>> getForVehicle(int vehicleId) =>
      watchForVehicle(vehicleId).first;

  Future<List<RideRow>> getInRange(
    int vehicleId, {
    required int fromMs,
    required int toMs,
  }) {
    return (_db.select(_db.rides)
          ..where(
            (r) =>
                r.vehicleId.equals(vehicleId) &
                r.deletedAt.isNull() &
                r.startTimeMs.isBetweenValues(fromMs, toMs),
          )
          ..orderBy([
            (r) => OrderingTerm(
              expression: r.startTimeMs,
              mode: OrderingMode.desc,
            ),
          ]))
        .get();
  }

  Future<RideRow?> getById(int id) {
    return (_db.select(
      _db.rides,
    )..where((r) => r.id.equals(id) & r.deletedAt.isNull())).getSingleOrNull();
  }

  /// A ride with no `endTimeMs` is an interrupted recording — the app was
  /// killed while tracking. Checked on every launch so the user can resume,
  /// save what was captured, or discard it.
  Future<RideRow?> findInterrupted() {
    return (_db.select(_db.rides)
          ..where((r) => r.endTimeMs.isNull() & r.deletedAt.isNull())
          ..orderBy([
            (r) => OrderingTerm(
              expression: r.startTimeMs,
              mode: OrderingMode.desc,
            ),
          ])
          ..limit(1))
        .getSingleOrNull();
  }

  Future<int> create(RidesCompanion draft) {
    final now = Clock.nowMs;
    return _db
        .into(_db.rides)
        .insert(draft.copyWith(createdAt: Value(now), updatedAt: Value(now)));
  }

  Future<void> update(int id, RidesCompanion changes) async {
    await (_db.update(_db.rides)..where((r) => r.id.equals(id))).write(
      changes.copyWith(updatedAt: Value(Clock.nowMs)),
    );
  }

  Future<void> softDelete(int id) async {
    final now = Clock.nowMs;
    await (_db.update(_db.rides)..where((r) => r.id.equals(id))).write(
      RidesCompanion(deletedAt: Value(now), updatedAt: Value(now)),
    );
  }

  /// Hard-deletes a ride and its points. Used for "discard" on an
  /// interrupted recording and for "delete location history" in settings,
  /// where the user's intent is that the GPS data is actually gone.
  Future<void> hardDelete(int id) async {
    await _db.transaction(() async {
      await (_db.delete(
        _db.ridePoints,
      )..where((p) => p.rideId.equals(id))).go();
      await (_db.delete(_db.rides)..where((r) => r.id.equals(id))).go();
    });
  }

  /// Removes every recorded GPS path while keeping the ride summaries
  /// (distance, duration, speeds) that statistics depend on.
  Future<int> deleteAllLocationHistory() async {
    return _db.transaction(() async {
      final deleted = await _db.delete(_db.ridePoints).go();
      return deleted;
    });
  }

  // -------------------------------------------------------------------
  // Ride points
  // -------------------------------------------------------------------

  /// Appends one sample. Called from the location stream, so it must stay
  /// cheap — a single INSERT with no surrounding transaction.
  Future<int> addPoint(RidePointsCompanion point) =>
      _db.into(_db.ridePoints).insert(point);

  /// Full-resolution path, ascending by time. Callers simplify for display;
  /// the database always keeps every point.
  Future<List<RidePointRow>> getPoints(int rideId) {
    return (_db.select(_db.ridePoints)
          ..where((p) => p.rideId.equals(rideId))
          ..orderBy([(p) => OrderingTerm(expression: p.timestampMs)]))
        .get();
  }

  /// Live path for one ride, ascending by time.
  ///
  /// Drift re-emits on every insert into `ride_points`, which is what lets
  /// the map tab draw a ride as it is being recorded without polling.
  Stream<List<RidePointRow>> watchPoints(int rideId) {
    return (_db.select(_db.ridePoints)
          ..where((p) => p.rideId.equals(rideId))
          ..orderBy([(p) => OrderingTerm(expression: p.timestampMs)]))
        .watch();
  }

  Future<RidePointRow?> lastPoint(int rideId) {
    return (_db.select(_db.ridePoints)
          ..where((p) => p.rideId.equals(rideId))
          ..orderBy([
            (p) => OrderingTerm(
              expression: p.timestampMs,
              mode: OrderingMode.desc,
            ),
          ])
          ..limit(1))
        .getSingleOrNull();
  }

  Future<int> pointCount(int rideId) async {
    final row = await _db
        .customSelect(
          'SELECT COUNT(*) AS c FROM ride_points WHERE ride_id = ?',
          variables: [Variable.withInt(rideId)],
          readsFrom: {_db.ridePoints},
        )
        .getSingle();
    return row.read<int>('c');
  }
}
