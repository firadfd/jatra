import 'package:drift/drift.dart';

import '../../core/utils/clock.dart';
import '../../core/utils/units.dart';
import '../db/database.dart';
import '../models/default_service_items.dart';

/// Counts of everything that would go with a vehicle, so the delete
/// confirmation can name them:
/// "This deletes 142 fuel entries, 23 service logs and 56 rides."
class VehicleDeletionCounts {
  const VehicleDeletionCounts({
    required this.fuelEntries,
    required this.serviceLogs,
    required this.serviceItems,
    required this.expenses,
    required this.rides,
    required this.ridePoints,
  });

  final int fuelEntries;
  final int serviceLogs;
  final int serviceItems;
  final int expenses;
  final int rides;
  final int ridePoints;

  bool get isEmpty =>
      fuelEntries == 0 &&
      serviceLogs == 0 &&
      expenses == 0 &&
      rides == 0 &&
      serviceItems == 0;

  /// "142 fuel entries, 23 service logs and 56 rides", skipping empty
  /// categories and using a serial comma-free Oxford-less join.
  String describe() {
    final parts = <String>[
      if (fuelEntries > 0) _plural(fuelEntries, 'fuel entry', 'fuel entries'),
      if (serviceLogs > 0) _plural(serviceLogs, 'service log', 'service logs'),
      if (expenses > 0) _plural(expenses, 'expense', 'expenses'),
      if (rides > 0) _plural(rides, 'ride', 'rides'),
      if (serviceItems > 0)
        _plural(serviceItems, 'service reminder', 'service reminders'),
    ];
    if (parts.isEmpty) return 'no records';
    if (parts.length == 1) return parts.first;
    return '${parts.sublist(0, parts.length - 1).join(', ')} and ${parts.last}';
  }

  static String _plural(int n, String one, String many) =>
      '$n ${n == 1 ? one : many}';
}

/// All vehicle reads and writes. Plain class — no GetX, no Flutter imports —
/// so it can be unit-tested against an in-memory database.
class VehicleRepo {
  VehicleRepo(this._db);

  final AppDatabase _db;

  // -------------------------------------------------------------------
  // Reads
  // -------------------------------------------------------------------

  /// Live list of vehicles for the switcher, defaults first then by name.
  Stream<List<VehicleRow>> watchAll({bool includeArchived = false}) {
    final q = _db.select(_db.vehicles)
      ..where((v) => v.deletedAt.isNull())
      ..orderBy([
        (v) => OrderingTerm(expression: v.isDefault, mode: OrderingMode.desc),
        (v) => OrderingTerm(expression: v.name),
      ]);
    if (!includeArchived) {
      q.where((v) => v.isArchived.equals(false));
    }
    return q.watch();
  }

  Future<List<VehicleRow>> getAll({bool includeArchived = false}) =>
      watchAll(includeArchived: includeArchived).first;

  Future<VehicleRow?> getById(int id) {
    return (_db.select(
      _db.vehicles,
    )..where((v) => v.id.equals(id) & v.deletedAt.isNull())).getSingleOrNull();
  }

  Stream<VehicleRow?> watchById(int id) {
    return (_db.select(_db.vehicles)
          ..where((v) => v.id.equals(id) & v.deletedAt.isNull()))
        .watchSingleOrNull();
  }

  /// The vehicle the app should open on: the explicit default, else the
  /// first non-archived one, else null (⇒ onboarding).
  Future<VehicleRow?> getDefault() async {
    final explicit =
        await (_db.select(_db.vehicles)
              ..where(
                (v) =>
                    v.isDefault.equals(true) &
                    v.isArchived.equals(false) &
                    v.deletedAt.isNull(),
              )
              ..limit(1))
            .getSingleOrNull();
    if (explicit != null) return explicit;

    final all = await getAll();
    return all.isEmpty ? null : all.first;
  }

  Future<int> count() async {
    final rows = await getAll(includeArchived: true);
    return rows.length;
  }

  // -------------------------------------------------------------------
  // Writes
  // -------------------------------------------------------------------

  /// Creates a vehicle and seeds its default maintenance schedule.
  ///
  /// The first vehicle ever created becomes the default automatically —
  /// asking a first-time user to nominate a default among one option is
  /// pointless friction.
  Future<int> create(
    VehiclesCompanion draft, {
    bool seedServiceItems = true,
  }) async {
    return _db.transaction(() async {
      final now = Clock.nowMs;
      final isFirst = (await count()) == 0;

      final requestedDefault = draft.isDefault.present && draft.isDefault.value;
      final makeDefault = requestedDefault || isFirst;

      if (makeDefault) await _clearDefaultFlag();

      final id = await _db
          .into(_db.vehicles)
          .insert(
            draft.copyWith(
              isDefault: Value(makeDefault),
              createdAt: Value(now),
              updatedAt: Value(now),
            ),
          );

      if (seedServiceItems) {
        await _seedServiceItems(
          vehicleId: id,
          startOdometerM: draft.initialOdometerM.present
              ? draft.initialOdometerM.value
              : 0,
          startDateMs: draft.purchaseDateMs.present
              ? (draft.purchaseDateMs.value ?? now)
              : now,
        );
      }

      return id;
    });
  }

  Future<void> update(int id, VehiclesCompanion changes) async {
    await (_db.update(_db.vehicles)..where((v) => v.id.equals(id))).write(
      changes.copyWith(updatedAt: Value(Clock.nowMs)),
    );
  }

  Future<void> setDefault(int id) async {
    await _db.transaction(() async {
      await _clearDefaultFlag();
      await (_db.update(_db.vehicles)..where((v) => v.id.equals(id))).write(
        VehiclesCompanion(
          isDefault: const Value(true),
          updatedAt: Value(Clock.nowMs),
        ),
      );
    });
  }

  /// Archiving hides a bike from the switcher but keeps its history in
  /// all-vehicle statistics — the right move for a bike you sold.
  Future<void> setArchived(int id, bool archived) async {
    await _db.transaction(() async {
      await (_db.update(_db.vehicles)..where((v) => v.id.equals(id))).write(
        VehiclesCompanion(
          isArchived: Value(archived),
          isDefault: archived ? const Value(false) : const Value.absent(),
          updatedAt: Value(Clock.nowMs),
        ),
      );

      // Archiving the default would leave the app with no active vehicle.
      if (archived) await _promoteAnyDefault();
    });
  }

  /// What [softDelete] would remove. Read before showing the confirmation.
  Future<VehicleDeletionCounts> deletionCounts(int vehicleId) async {
    Future<int> countOf(String table) async {
      final row = await _db
          .customSelect(
            'SELECT COUNT(*) AS c FROM $table '
            'WHERE vehicle_id = ? AND deleted_at IS NULL',
            variables: [Variable.withInt(vehicleId)],
          )
          .getSingle();
      return row.read<int>('c');
    }

    final ridePointRow = await _db
        .customSelect(
          'SELECT COUNT(*) AS c FROM ride_points p '
          'JOIN rides r ON r.id = p.ride_id '
          'WHERE r.vehicle_id = ? AND r.deleted_at IS NULL',
          variables: [Variable.withInt(vehicleId)],
        )
        .getSingle();

    return VehicleDeletionCounts(
      fuelEntries: await countOf('fuel_entries'),
      serviceLogs: await countOf('service_logs'),
      serviceItems: await countOf('service_items'),
      expenses: await countOf('expenses'),
      rides: await countOf('rides'),
      ridePoints: ridePointRow.read<int>('c'),
    );
  }

  /// Soft-deletes the vehicle and cascades to every record that belongs to
  /// it, in one transaction.
  ///
  /// Soft rather than hard so a later JSON import can tell "the user deleted
  /// this" apart from "this device never had it" and not resurrect the row.
  /// `ride_points` are left alone — they hang off `rides`, which is itself
  /// tombstoned, and tombstoning 41,000 points would be pure write cost.
  Future<void> softDelete(int vehicleId) async {
    final now = Clock.nowMs;
    await _db.transaction(() async {
      Future<void> tombstone(String table) => _db.customStatement(
        'UPDATE $table SET deleted_at = ?, updated_at = ? '
        'WHERE vehicle_id = ? AND deleted_at IS NULL',
        [now, now, vehicleId],
      );

      await tombstone('fuel_entries');
      await tombstone('service_logs');
      await tombstone('service_items');
      await tombstone('expenses');
      await tombstone('rides');
      await tombstone('reminders');

      await (_db.update(
        _db.vehicles,
      )..where((v) => v.id.equals(vehicleId))).write(
        VehiclesCompanion(
          deletedAt: Value(now),
          isDefault: const Value(false),
          updatedAt: Value(now),
        ),
      );

      await _promoteAnyDefault();
    });
  }

  // -------------------------------------------------------------------
  // Internals
  // -------------------------------------------------------------------

  Future<void> _clearDefaultFlag() async {
    await (_db.update(
      _db.vehicles,
    )..where((v) => v.isDefault.equals(true))).write(
      VehiclesCompanion(
        isDefault: const Value(false),
        updatedAt: Value(Clock.nowMs),
      ),
    );
  }

  /// Ensures exactly one vehicle carries the default flag after the current
  /// default is archived or deleted.
  Future<void> _promoteAnyDefault() async {
    final remaining = await getAll();
    if (remaining.isEmpty || remaining.any((v) => v.isDefault)) return;
    await (_db.update(
      _db.vehicles,
    )..where((v) => v.id.equals(remaining.first.id))).write(
      VehiclesCompanion(
        isDefault: const Value(true),
        updatedAt: Value(Clock.nowMs),
      ),
    );
  }

  /// Seeds the maintenance schedule.
  ///
  /// `lastDone` is set to the bike's starting odometer and purchase date, not
  /// left null: a brand-new item with no baseline would immediately read
  /// "OVERDUE", which is both wrong and alarming on day one.
  Future<void> _seedServiceItems({
    required int vehicleId,
    required int startOdometerM,
    required int startDateMs,
  }) async {
    final now = Clock.nowMs;
    await _db.batch((batch) {
      batch.insertAll(_db.serviceItems, [
        for (var i = 0; i < kDefaultServiceItems.length; i++)
          ServiceItemsCompanion.insert(
            vehicleId: vehicleId,
            name: kDefaultServiceItems[i].name,
            createdAt: now,
            updatedAt: now,
            intervalM: Value(
              kDefaultServiceItems[i].intervalKm == null
                  ? null
                  : Units.toMetres(
                      kDefaultServiceItems[i].intervalKm!.toDouble(),
                      DistanceUnit.km,
                    ),
            ),
            intervalDays: Value(kDefaultServiceItems[i].intervalDays),
            lastDoneOdometerM: Value(startOdometerM),
            lastDoneDateMs: Value(startDateMs),
            iconKey: Value(kDefaultServiceItems[i].iconKey),
            sortOrder: Value(i),
          ),
      ]);
    });
  }
}
