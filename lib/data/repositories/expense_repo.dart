import 'package:drift/drift.dart';

import '../../core/utils/clock.dart';
import '../db/database.dart';

/// Non-fuel, non-service costs: insurance, tax token, fitness, registration,
/// accessories, fines, parking, washing.
class ExpenseRepo {
  ExpenseRepo(this._db);

  final AppDatabase _db;

  Stream<List<ExpenseRow>> watchForVehicle(int vehicleId) {
    return (_db.select(_db.expenses)
          ..where((e) => e.vehicleId.equals(vehicleId) & e.deletedAt.isNull())
          ..orderBy([
            (e) => OrderingTerm(expression: e.dateMs, mode: OrderingMode.desc),
            (e) => OrderingTerm(expression: e.id, mode: OrderingMode.desc),
          ]))
        .watch();
  }

  /// The expenses screen and the stats screen both offer "All vehicles".
  Stream<List<ExpenseRow>> watchAll() {
    return (_db.select(_db.expenses)
          ..where((e) => e.deletedAt.isNull())
          ..orderBy([
            (e) => OrderingTerm(expression: e.dateMs, mode: OrderingMode.desc),
          ]))
        .watch();
  }

  Future<List<ExpenseRow>> getForVehicle(int vehicleId) =>
      watchForVehicle(vehicleId).first;

  Future<List<ExpenseRow>> getInRange(
    int vehicleId, {
    required int fromMs,
    required int toMs,
  }) {
    return (_db.select(_db.expenses)
          ..where(
            (e) =>
                e.vehicleId.equals(vehicleId) &
                e.deletedAt.isNull() &
                e.dateMs.isBetweenValues(fromMs, toMs),
          )
          ..orderBy([
            (e) => OrderingTerm(expression: e.dateMs, mode: OrderingMode.desc),
          ]))
        .get();
  }

  Future<ExpenseRow?> getById(int id) {
    return (_db.select(
      _db.expenses,
    )..where((e) => e.id.equals(id) & e.deletedAt.isNull())).getSingleOrNull();
  }

  /// Documents that expire within [withinDays], soonest first. Drives the
  /// expiry countdowns and the document-expiry reminders.
  ///
  /// Already-expired documents are included — a lapsed insurance policy is
  /// more urgent than one expiring next week, not less.
  Future<List<ExpenseRow>> expiringDocuments(
    int vehicleId, {
    int withinDays = 45,
  }) {
    final cutoff = Dates.addDays(Clock.nowMs, withinDays);
    return (_db.select(_db.expenses)
          ..where(
            (e) =>
                e.vehicleId.equals(vehicleId) &
                e.deletedAt.isNull() &
                e.validUntilMs.isNotNull() &
                e.validUntilMs.isSmallerOrEqualValue(cutoff),
          )
          ..orderBy([(e) => OrderingTerm(expression: e.validUntilMs)]))
        .get();
  }

  Future<int> create(ExpensesCompanion draft) {
    final now = Clock.nowMs;
    return _db
        .into(_db.expenses)
        .insert(draft.copyWith(createdAt: Value(now), updatedAt: Value(now)));
  }

  Future<void> update(int id, ExpensesCompanion changes) async {
    await (_db.update(_db.expenses)..where((e) => e.id.equals(id))).write(
      changes.copyWith(updatedAt: Value(Clock.nowMs)),
    );
  }

  Future<void> softDelete(int id) async {
    final now = Clock.nowMs;
    await (_db.update(_db.expenses)..where((e) => e.id.equals(id))).write(
      ExpensesCompanion(deletedAt: Value(now), updatedAt: Value(now)),
    );
  }

  Future<void> restore(int id) async {
    await (_db.update(_db.expenses)..where((e) => e.id.equals(id))).write(
      ExpensesCompanion(
        deletedAt: const Value(null),
        updatedAt: Value(Clock.nowMs),
      ),
    );
  }
}
