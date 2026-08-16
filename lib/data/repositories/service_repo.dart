import 'package:drift/drift.dart';

import '../../core/utils/clock.dart';
import '../db/database.dart';

/// Service item (recurring definition) and service log (completed event)
/// access.
///
/// The two are deliberately separate concepts and this repository keeps the
/// one rule that ties them together: logging a service against an item
/// updates that item's baseline, so the next due point moves forward.
class ServiceRepo {
  ServiceRepo(this._db);

  final AppDatabase _db;

  // -------------------------------------------------------------------
  // Service items
  // -------------------------------------------------------------------

  Stream<List<ServiceItemRow>> watchItems(
    int vehicleId, {
    bool includeInactive = false,
  }) {
    final q = _db.select(_db.serviceItems)
      ..where((s) => s.vehicleId.equals(vehicleId) & s.deletedAt.isNull())
      ..orderBy([
        (s) => OrderingTerm(expression: s.sortOrder),
        (s) => OrderingTerm(expression: s.name),
      ]);
    if (!includeInactive) q.where((s) => s.isActive.equals(true));
    return q.watch();
  }

  Future<List<ServiceItemRow>> getItems(
    int vehicleId, {
    bool includeInactive = false,
  }) => watchItems(vehicleId, includeInactive: includeInactive).first;

  Future<ServiceItemRow?> getItem(int id) {
    return (_db.select(
      _db.serviceItems,
    )..where((s) => s.id.equals(id) & s.deletedAt.isNull())).getSingleOrNull();
  }

  Future<int> createItem(ServiceItemsCompanion draft) {
    final now = Clock.nowMs;
    return _db
        .into(_db.serviceItems)
        .insert(draft.copyWith(createdAt: Value(now), updatedAt: Value(now)));
  }

  Future<void> updateItem(int id, ServiceItemsCompanion changes) async {
    await (_db.update(_db.serviceItems)..where((s) => s.id.equals(id))).write(
      changes.copyWith(updatedAt: Value(Clock.nowMs)),
    );
  }

  Future<void> softDeleteItem(int id) async {
    final now = Clock.nowMs;
    await (_db.update(_db.serviceItems)..where((s) => s.id.equals(id))).write(
      ServiceItemsCompanion(deletedAt: Value(now), updatedAt: Value(now)),
    );
  }

  // -------------------------------------------------------------------
  // Service logs
  // -------------------------------------------------------------------

  Stream<List<ServiceLogRow>> watchLogs(int vehicleId) {
    return (_db.select(_db.serviceLogs)
          ..where((s) => s.vehicleId.equals(vehicleId) & s.deletedAt.isNull())
          ..orderBy([
            (s) => OrderingTerm(expression: s.dateMs, mode: OrderingMode.desc),
            (s) => OrderingTerm(expression: s.id, mode: OrderingMode.desc),
          ]))
        .watch();
  }

  Future<List<ServiceLogRow>> getLogs(int vehicleId) =>
      watchLogs(vehicleId).first;

  Future<List<ServiceLogRow>> getLogsInRange(
    int vehicleId, {
    required int fromMs,
    required int toMs,
  }) {
    return (_db.select(_db.serviceLogs)
          ..where(
            (s) =>
                s.vehicleId.equals(vehicleId) &
                s.deletedAt.isNull() &
                s.dateMs.isBetweenValues(fromMs, toMs),
          )
          ..orderBy([
            (s) => OrderingTerm(expression: s.dateMs, mode: OrderingMode.desc),
          ]))
        .get();
  }

  Future<ServiceLogRow?> getLog(int id) {
    return (_db.select(
      _db.serviceLogs,
    )..where((s) => s.id.equals(id) & s.deletedAt.isNull())).getSingleOrNull();
  }

  /// Records a completed service and, when it belongs to a recurring item,
  /// advances that item's baseline in the same transaction.
  ///
  /// Doing both atomically matters: a crash between the two writes would
  /// leave an item claiming it is still overdue for work already logged.
  Future<int> createLog(ServiceLogsCompanion draft) async {
    return _db.transaction(() async {
      final now = Clock.nowMs;
      final id = await _db
          .into(_db.serviceLogs)
          .insert(draft.copyWith(createdAt: Value(now), updatedAt: Value(now)));

      final itemId = draft.serviceItemId.present
          ? draft.serviceItemId.value
          : null;
      if (itemId != null) {
        await _advanceItemBaseline(
          itemId,
          odometerM: draft.odometerM.value,
          dateMs: draft.dateMs.value,
        );
      }
      return id;
    });
  }

  Future<void> updateLog(int id, ServiceLogsCompanion changes) async {
    await _db.transaction(() async {
      await (_db.update(_db.serviceLogs)..where((s) => s.id.equals(id))).write(
        changes.copyWith(updatedAt: Value(Clock.nowMs)),
      );

      // Editing the odometer or date of the most recent log for an item has
      // to move that item's baseline too, so recompute from the logs rather
      // than trusting the edit in isolation.
      final log = await getLog(id);
      if (log?.serviceItemId != null) {
        await _recomputeItemBaseline(log!.serviceItemId!);
      }
    });
  }

  Future<void> softDeleteLog(int id) async {
    await _db.transaction(() async {
      final log = await getLog(id);
      final now = Clock.nowMs;
      await (_db.update(_db.serviceLogs)..where((s) => s.id.equals(id))).write(
        ServiceLogsCompanion(deletedAt: Value(now), updatedAt: Value(now)),
      );
      if (log?.serviceItemId != null) {
        await _recomputeItemBaseline(log!.serviceItemId!);
      }
    });
  }

  // -------------------------------------------------------------------
  // Internals
  // -------------------------------------------------------------------

  /// Moves an item's baseline forward, but never backward — logging an
  /// *older* service you forgot to record must not undo a newer one.
  Future<void> _advanceItemBaseline(
    int itemId, {
    required int odometerM,
    required int dateMs,
  }) async {
    final item = await getItem(itemId);
    if (item == null) return;

    final newerOdo = (item.lastDoneOdometerM ?? -1) < odometerM;
    final newerDate = (item.lastDoneDateMs ?? -1) < dateMs;
    if (!newerOdo && !newerDate) return;

    await updateItem(
      itemId,
      ServiceItemsCompanion(
        lastDoneOdometerM: newerOdo ? Value(odometerM) : const Value.absent(),
        lastDoneDateMs: newerDate ? Value(dateMs) : const Value.absent(),
      ),
    );
  }

  /// Rebuilds an item's baseline from its surviving logs. Used after an edit
  /// or delete, where the baseline may need to move *back*.
  Future<void> _recomputeItemBaseline(int itemId) async {
    final latest =
        await (_db.select(_db.serviceLogs)
              ..where(
                (s) => s.serviceItemId.equals(itemId) & s.deletedAt.isNull(),
              )
              ..orderBy([
                (s) =>
                    OrderingTerm(expression: s.dateMs, mode: OrderingMode.desc),
                (s) => OrderingTerm(
                  expression: s.odometerM,
                  mode: OrderingMode.desc,
                ),
              ])
              ..limit(1))
            .getSingleOrNull();

    // No logs left — fall back to the vehicle's starting point rather than
    // null, so the item reads "not due yet" instead of "overdue since epoch".
    if (latest == null) {
      final item = await getItem(itemId);
      if (item == null) return;
      final vehicle = await (_db.select(
        _db.vehicles,
      )..where((v) => v.id.equals(item.vehicleId))).getSingleOrNull();
      if (vehicle == null) return;
      await updateItem(
        itemId,
        ServiceItemsCompanion(
          lastDoneOdometerM: Value(vehicle.initialOdometerM),
          lastDoneDateMs: Value(vehicle.purchaseDateMs ?? vehicle.createdAt),
        ),
      );
      return;
    }

    await updateItem(
      itemId,
      ServiceItemsCompanion(
        lastDoneOdometerM: Value(latest.odometerM),
        lastDoneDateMs: Value(latest.dateMs),
      ),
    );
  }
}
