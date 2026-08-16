import 'dart:async';

import 'package:get/get.dart' hide Value;

import '../../core/utils/clock.dart';
import '../../core/utils/money.dart';
import '../../data/db/database.dart';
import '../../data/repositories/expense_repo.dart';
import '../../services/reminder_service.dart';
import '../vehicles/vehicle_controller.dart';

/// One month of expenses, for the grouped list.
class ExpenseMonthGroup {
  const ExpenseMonthGroup({
    required this.monthStartMs,
    required this.entries,
    required this.total,
  });

  final int monthStartMs;
  final List<ExpenseRow> entries;
  final Money total;
}

/// A document with a countdown attached.
class DocumentStatus {
  const DocumentStatus({required this.expense, required this.daysRemaining});

  final ExpenseRow expense;

  /// Negative once it has lapsed.
  final int daysRemaining;

  bool get hasExpired => daysRemaining < 0;
  bool get isUrgent => daysRemaining <= 14;
}

class ExpensesController extends GetxController {
  ExpensesController(this._repo, this._vehicles, this._reminders);

  final ExpenseRepo _repo;
  final VehicleController _vehicles;
  final ReminderService _reminders;

  StreamSubscription<List<ExpenseRow>>? _sub;

  final entries = <ExpenseRow>[].obs;
  final isReady = false.obs;

  /// "All vehicles" is offered on this screen and on stats, and nowhere else
  /// — everywhere else, a figure that mixed two bikes would be meaningless.
  final allVehicles = false.obs;

  @override
  void onInit() {
    super.onInit();
    ever(_vehicles.active, (_) => _bind());
    ever(allVehicles, (_) => _bind());
    _bind();
  }

  @override
  void onClose() {
    _sub?.cancel();
    super.onClose();
  }

  void _bind() {
    _sub?.cancel();
    isReady.value = false;

    if (allVehicles.value) {
      _sub = _repo.watchAll().listen(_onRows);
      return;
    }

    final id = _vehicles.activeId;
    if (id == 0) {
      entries.clear();
      isReady.value = true;
      return;
    }
    _sub = _repo.watchForVehicle(id).listen(_onRows);
  }

  void _onRows(List<ExpenseRow> rows) {
    entries.assignAll(rows);
    isReady.value = true;
  }

  /// Newest month first.
  List<ExpenseMonthGroup> get monthGroups {
    final buckets = <int, List<ExpenseRow>>{};
    for (final e in entries) {
      buckets.putIfAbsent(Dates.startOfLocalMonth(e.dateMs), () => []).add(e);
    }

    final keys = buckets.keys.toList()..sort((a, b) => b.compareTo(a));
    return [
      for (final key in keys)
        ExpenseMonthGroup(
          monthStartMs: key,
          entries: buckets[key]!,
          total: buckets[key]!.fold(
            Money.zero,
            (sum, e) => sum + Money(e.amountMinor),
          ),
        ),
    ];
  }

  /// Documents with a `validUntil`, soonest first.
  ///
  /// Already-lapsed ones lead: an expired insurance policy is more urgent
  /// than one expiring next week, not less.
  List<DocumentStatus> get documents {
    final now = Clock.nowMs;
    final withExpiry = entries.where((e) => e.validUntilMs != null).toList();

    // One row per category — only the newest policy of each kind matters,
    // otherwise last year's expired insurance would nag forever.
    final newestPerCategory = <ExpenseCategory, ExpenseRow>{};
    for (final e in withExpiry) {
      final existing = newestPerCategory[e.category];
      if (existing == null || e.validUntilMs! > existing.validUntilMs!) {
        newestPerCategory[e.category] = e;
      }
    }

    final statuses = [
      for (final e in newestPerCategory.values)
        DocumentStatus(
          expense: e,
          daysRemaining: Dates.daysBetween(
            Dates.startOfLocalDay(now),
            Dates.startOfLocalDay(e.validUntilMs!),
          ),
        ),
    ]..sort((a, b) => a.daysRemaining.compareTo(b.daysRemaining));

    return statuses;
  }

  Money get total =>
      entries.fold(Money.zero, (sum, e) => sum + Money(e.amountMinor));

  /// Totals per category, largest first — the breakdown on the summary card.
  List<({ExpenseCategory category, Money total})> get byCategory {
    final buckets = <ExpenseCategory, Money>{};
    for (final e in entries) {
      buckets[e.category] =
          (buckets[e.category] ?? Money.zero) + Money(e.amountMinor);
    }
    final list = [
      for (final entry in buckets.entries)
        (category: entry.key, total: entry.value),
    ]..sort((a, b) => b.total.minor.compareTo(a.total.minor));
    return list;
  }

  Future<void> delete(int id) async {
    await _repo.softDelete(id);
    await _reminders.recompute(_vehicles.activeId);
  }

  Future<void> undoDelete(int id) async {
    await _repo.restore(id);
    await _reminders.recompute(_vehicles.activeId);
  }
}
