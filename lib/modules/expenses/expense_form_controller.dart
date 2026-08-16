import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:get/get.dart' hide Value;

import '../../app/routes/app_routes.dart';
import '../../core/utils/clock.dart';
import '../../core/utils/formatters.dart';
import '../../core/utils/money.dart';
import '../../data/db/database.dart';
import '../../data/repositories/expense_repo.dart';
import '../../services/reminder_service.dart';
import '../vehicles/vehicle_controller.dart';
import '../../core/utils/l10n.dart';

/// Add / edit a non-fuel, non-service cost.
class ExpenseFormController extends GetxController {
  ExpenseFormController(this._repo, this._vehicles, this._reminders);

  final ExpenseRepo _repo;
  final VehicleController _vehicles;
  final ReminderService _reminders;

  final formKey = GlobalKey<FormState>();

  final amountCtrl = TextEditingController();
  final notesCtrl = TextEditingController();

  final category = ExpenseCategory.insurance.obs;
  final dateMs = Clock.nowMs.obs;
  final validFromMs = RxnInt();
  final validUntilMs = RxnInt();

  final isLoading = true.obs;
  final isSaving = false.obs;

  int? editId;
  bool get isEditing => editId != null;

  Fmt get fmt => _vehicles.fmt.value;

  /// Whether to show the coverage-period fields. Driven by the category, so
  /// a car wash never asks when it expires.
  bool get showsValidity => category.value.isDocument;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    editId = args is Map ? args[RouteArgs.editId] as int? : null;

    // Picking a document category pre-fills a one-year cover starting today,
    // which is what almost every policy and token in this market is.
    ever(category, (ExpenseCategory c) {
      if (!c.isDocument) {
        validFromMs.value = null;
        validUntilMs.value = null;
        return;
      }
      validFromMs.value ??= dateMs.value;
      validUntilMs.value ??= Dates.addDays(dateMs.value, 365);
    });

    _load();
  }

  @override
  void onClose() {
    amountCtrl.dispose();
    notesCtrl.dispose();
    super.onClose();
  }

  Future<void> _load() async {
    final id = editId;
    if (id != null) {
      final row = await _repo.getById(id);
      if (row != null) {
        category.value = row.category;
        dateMs.value = row.dateMs;
        amountCtrl.text = Money(row.amountMinor).asMajor.toStringAsFixed(2);
        notesCtrl.text = row.notes ?? '';
        validFromMs.value = row.validFromMs;
        validUntilMs.value = row.validUntilMs;
      }
    }
    isLoading.value = false;
  }

  String? validateAmount(String? v) {
    if (v == null || v.trim().isEmpty) return l10n.expensesAmountError;
    final parsed = Money.tryParse(v);
    if (parsed == null) return l10n.expensesAmountNumberError;
    if (parsed.minor < 0) return l10n.expensesAmountNegativeError;
    return null;
  }

  final validityError = RxnString();

  bool _validateValidity() {
    validityError.value = null;
    final from = validFromMs.value;
    final until = validUntilMs.value;
    if (from != null && until != null && until < from) {
      validityError.value = l10n.expensesCoverOrderError;
      return false;
    }
    return true;
  }

  Future<void> save() async {
    if (!(formKey.currentState?.validate() ?? false)) return;
    if (!_validateValidity()) return;
    if (isSaving.value) return;
    isSaving.value = true;

    try {
      final companion = ExpensesCompanion(
        vehicleId: Value(_vehicles.activeId),
        category: Value(category.value),
        dateMs: Value(dateMs.value),
        amountMinor: Value(
          (Money.tryParse(amountCtrl.text) ?? Money.zero).minor,
        ),
        notes: Value(_text(notesCtrl)),
        validFromMs: Value(showsValidity ? validFromMs.value : null),
        validUntilMs: Value(showsValidity ? validUntilMs.value : null),
      );

      final id = editId;
      if (id == null) {
        await _repo.create(
          companion.copyWith(
            createdAt: const Value(0),
            updatedAt: const Value(0),
          ),
        );
      } else {
        await _repo.update(id, companion);
      }

      // A changed expiry date changes what needs reminding about.
      await _reminders.recompute(_vehicles.activeId);

      Get.back<bool>(result: true);
      Get.snackbar(
        isEditing ? l10n.expensesUpdated : l10n.expensesSaved,
        category.value.label,
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isSaving.value = false;
    }
  }

  static String? _text(TextEditingController c) {
    final t = c.text.trim();
    return t.isEmpty ? null : t;
  }
}
