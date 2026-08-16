import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:get/get.dart' hide Value;

import '../../app/routes/app_routes.dart';
import '../../core/utils/clock.dart';
import '../../core/utils/formatters.dart';
import '../../core/utils/money.dart';
import '../../core/utils/units.dart';
import '../../data/db/database.dart';
import '../../data/repositories/fuel_repo.dart';
import '../../data/repositories/service_repo.dart';
import '../../services/reminder_service.dart';
import '../vehicles/vehicle_controller.dart';
import '../../core/utils/l10n.dart';

/// Log a completed service.
///
/// Logging against a recurring item advances that item's baseline, so the
/// next due point moves forward — the whole point of keeping items and logs
/// as separate concepts.
class ServiceLogFormController extends GetxController {
  ServiceLogFormController(
    this._service,
    this._fuel,
    this._vehicles,
    this._reminders,
  );

  final ServiceRepo _service;
  final FuelRepo _fuel;
  final VehicleController _vehicles;
  final ReminderService _reminders;

  final formKey = GlobalKey<FormState>();

  final nameCtrl = TextEditingController();
  final odometerCtrl = TextEditingController();
  final partsCtrl = TextEditingController();
  final laborCtrl = TextEditingController();
  final totalCtrl = TextEditingController();
  final workshopCtrl = TextEditingController();
  final partBrandCtrl = TextEditingController();
  final notesCtrl = TextEditingController();

  final dateMs = Clock.nowMs.obs;

  /// Null ⇒ a one-off repair with no recurring definition behind it.
  final serviceItemId = RxnInt();

  final items = <ServiceItemRow>[].obs;
  final isLoading = true.obs;
  final isSaving = false.obs;

  /// True once the user edits the total by hand, after which parts+labour
  /// stops overwriting it — a bundled workshop bill is one number, not two.
  bool _totalEditedByHand = false;
  bool _writingTotal = false;

  int? editId;
  bool get isEditing => editId != null;

  Fmt get fmt => _vehicles.fmt.value;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    editId = args is Map ? args[RouteArgs.editId] as int? : null;
    final presetItemId = args is Map
        ? args[RouteArgs.serviceItemId] as int?
        : null;

    partsCtrl.addListener(_recomputeTotal);
    laborCtrl.addListener(_recomputeTotal);
    totalCtrl.addListener(() {
      if (!_writingTotal) _totalEditedByHand = true;
    });

    _load(presetItemId);
  }

  @override
  void onClose() {
    for (final c in [
      nameCtrl,
      odometerCtrl,
      partsCtrl,
      laborCtrl,
      totalCtrl,
      workshopCtrl,
      partBrandCtrl,
      notesCtrl,
    ]) {
      c.dispose();
    }
    super.onClose();
  }

  Future<void> _load(int? presetItemId) async {
    items.assignAll(await _service.getItems(_vehicles.activeId));

    final id = editId;
    if (id != null) {
      final log = await _service.getLog(id);
      if (log != null) {
        nameCtrl.text = log.name;
        odometerCtrl.text = _trim(
          Units.metresTo(log.odometerM, fmt.distanceUnit),
        );
        partsCtrl.text = _major(log.partsCostMinor);
        laborCtrl.text = _major(log.laborCostMinor);
        _writingTotal = true;
        totalCtrl.text = _major(log.totalCostMinor);
        _writingTotal = false;
        workshopCtrl.text = log.workshop ?? '';
        partBrandCtrl.text = log.partBrand ?? '';
        notesCtrl.text = log.notes ?? '';
        dateMs.value = log.dateMs;
        serviceItemId.value = log.serviceItemId;
        // An existing total may have been entered as a bundle; do not let
        // parts+labour clobber it on first edit.
        _totalEditedByHand = true;
      }
    } else {
      // Pre-fill the odometer with the current reading — the overwhelmingly
      // common case is logging a service that just happened.
      odometerCtrl.text = _trim(
        Units.metresTo(
          await _fuel.latestOdometerM(_vehicles.activeId),
          fmt.distanceUnit,
        ),
      );
      if (presetItemId != null) selectItem(presetItemId);
    }

    isLoading.value = false;
  }

  /// Picking a recurring item fills the name in, but the name stays editable
  /// — "Engine oil (synthetic)" is a useful thing to be able to write.
  void selectItem(int? id) {
    serviceItemId.value = id;
    if (id == null) return;
    final item = items.firstWhereOrNull((i) => i.id == id);
    if (item != null && nameCtrl.text.trim().isEmpty) {
      nameCtrl.text = item.name;
    }
  }

  void _recomputeTotal() {
    if (_totalEditedByHand) return;
    final parts = Money.tryParse(partsCtrl.text) ?? Money.zero;
    final labor = Money.tryParse(laborCtrl.text) ?? Money.zero;
    final sum = parts + labor;

    final text = sum.isZero ? '' : sum.asMajor.toStringAsFixed(2);
    if (totalCtrl.text == text) return;

    _writingTotal = true;
    totalCtrl.text = text;
    _writingTotal = false;
  }

  String? validateName(String? v) =>
      (v == null || v.trim().isEmpty) ? l10n.serviceLogWhatError : null;

  String? validateOdometer(String? v) {
    final raw = v?.replaceAll(',', '').trim() ?? '';
    if (raw.isEmpty) return l10n.serviceLogOdometerError;
    final parsed = double.tryParse(raw);
    if (parsed == null) return l10n.serviceLogOdometerNumberError;
    if (parsed < 0) return l10n.serviceLogOdometerNegativeError;
    return null;
  }

  Future<void> save() async {
    if (!(formKey.currentState?.validate() ?? false)) return;
    if (isSaving.value) return;
    isSaving.value = true;

    try {
      final parts = Money.tryParse(partsCtrl.text) ?? Money.zero;
      final labor = Money.tryParse(laborCtrl.text) ?? Money.zero;
      final total = Money.tryParse(totalCtrl.text) ?? (parts + labor);

      final companion = ServiceLogsCompanion(
        vehicleId: Value(_vehicles.activeId),
        serviceItemId: Value(serviceItemId.value),
        name: Value(nameCtrl.text.trim()),
        dateMs: Value(dateMs.value),
        odometerM: Value(
          Units.toMetres(
            double.tryParse(odometerCtrl.text.replaceAll(',', '').trim()) ?? 0,
            fmt.distanceUnit,
          ),
        ),
        partsCostMinor: Value(parts.minor),
        laborCostMinor: Value(labor.minor),
        totalCostMinor: Value(total.minor),
        workshop: Value(_text(workshopCtrl)),
        partBrand: Value(_text(partBrandCtrl)),
        notes: Value(_text(notesCtrl)),
      );

      final id = editId;
      if (id == null) {
        await _service.createLog(
          companion.copyWith(
            createdAt: const Value(0),
            updatedAt: const Value(0),
          ),
        );
      } else {
        await _service.updateLog(id, companion);
      }

      // The odometer moved and a baseline advanced, so due points and their
      // reminders both need recomputing.
      await _reminders.recompute(_vehicles.activeId);

      Get.back<bool>(result: true);
      Get.snackbar(
        isEditing ? l10n.serviceUpdated : l10n.serviceLogged,
        serviceItemId.value == null
            ? nameCtrl.text.trim()
            : l10n.serviceNextDueMoved,
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isSaving.value = false;
    }
  }

  static String _major(int minor) => Money(minor).asMajor.toStringAsFixed(2);

  static String? _text(TextEditingController c) {
    final t = c.text.trim();
    return t.isEmpty ? null : t;
  }

  static String _trim(double value) => value == value.roundToDouble()
      ? value.round().toString()
      : value.toStringAsFixed(1);
}
