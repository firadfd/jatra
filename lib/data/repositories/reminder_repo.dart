import 'package:drift/drift.dart';

import '../../core/utils/clock.dart';
import '../db/database.dart';

/// Reminder rows backing the local notifications.
///
/// Reminders are *derived* state — they are regenerated from service items
/// and document expiries after every odometer-bearing entry and on launch.
/// [sourceId] plus [type] identifies the thing a reminder came from, so
/// regeneration updates in place instead of piling up duplicates.
class ReminderRepo {
  ReminderRepo(this._db);

  final AppDatabase _db;

  Stream<List<ReminderRow>> watchActive(int vehicleId) {
    return (_db.select(_db.reminders)
          ..where(
            (r) =>
                r.vehicleId.equals(vehicleId) &
                r.deletedAt.isNull() &
                r.isDismissed.equals(false),
          )
          ..orderBy([(r) => OrderingTerm(expression: r.dueDateMs)]))
        .watch();
  }

  Future<List<ReminderRow>> getForVehicle(int vehicleId) {
    return (_db.select(_db.reminders)
          ..where((r) => r.vehicleId.equals(vehicleId) & r.deletedAt.isNull()))
        .get();
  }

  Future<ReminderRow?> byId(int id) {
    return (_db.select(
      _db.reminders,
    )..where((r) => r.id.equals(id) & r.deletedAt.isNull())).getSingleOrNull();
  }

  Future<ReminderRow?> findBySource({
    required int vehicleId,
    required ReminderType type,
    required int sourceId,
  }) {
    return (_db.select(_db.reminders)
          ..where(
            (r) =>
                r.vehicleId.equals(vehicleId) &
                r.type.equalsValue(type) &
                r.sourceId.equals(sourceId) &
                r.deletedAt.isNull(),
          )
          ..limit(1))
        .getSingleOrNull();
  }

  /// Inserts or updates the reminder for a given source. Returns its id.
  ///
  /// [notifiedAtMs] is deliberately *not* reset when the due point merely
  /// shifts — otherwise recalculating on every app launch would re-post the
  /// same notification daily.
  Future<int> upsertForSource({
    required int vehicleId,
    required ReminderType type,
    required int sourceId,
    required String title,
    int? dueDateMs,
    int? dueOdometerM,
  }) async {
    final now = Clock.nowMs;
    final existing = await findBySource(
      vehicleId: vehicleId,
      type: type,
      sourceId: sourceId,
    );

    if (existing == null) {
      return _db
          .into(_db.reminders)
          .insert(
            RemindersCompanion.insert(
              vehicleId: vehicleId,
              type: type,
              title: title,
              createdAt: now,
              updatedAt: now,
              dueDateMs: Value(dueDateMs),
              dueOdometerM: Value(dueOdometerM),
              sourceId: Value(sourceId),
            ),
          );
    }

    await (_db.update(
      _db.reminders,
    )..where((r) => r.id.equals(existing.id))).write(
      RemindersCompanion(
        title: Value(title),
        dueDateMs: Value(dueDateMs),
        dueOdometerM: Value(dueOdometerM),
        updatedAt: Value(now),
      ),
    );
    return existing.id;
  }

  Future<void> markNotified(int id) async {
    final now = Clock.nowMs;
    await (_db.update(_db.reminders)..where((r) => r.id.equals(id))).write(
      RemindersCompanion(notifiedAtMs: Value(now), updatedAt: Value(now)),
    );
  }

  Future<void> dismiss(int id) async {
    final now = Clock.nowMs;
    await (_db.update(_db.reminders)..where((r) => r.id.equals(id))).write(
      RemindersCompanion(isDismissed: const Value(true), updatedAt: Value(now)),
    );
  }

  /// Clears the dismissed flag when a reminder's due point moves forward
  /// after a service is logged — the next cycle deserves a fresh warning.
  Future<void> reactivate(int id) async {
    final now = Clock.nowMs;
    await (_db.update(_db.reminders)..where((r) => r.id.equals(id))).write(
      RemindersCompanion(
        isDismissed: const Value(false),
        notifiedAtMs: const Value(null),
        updatedAt: Value(now),
      ),
    );
  }

  Future<void> softDeleteForSource({
    required ReminderType type,
    required int sourceId,
  }) async {
    final now = Clock.nowMs;
    await (_db.update(
          _db.reminders,
        )..where((r) => r.type.equalsValue(type) & r.sourceId.equals(sourceId)))
        .write(
          RemindersCompanion(deletedAt: Value(now), updatedAt: Value(now)),
        );
  }
}
