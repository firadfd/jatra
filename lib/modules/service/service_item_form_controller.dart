import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:get/get.dart' hide Value;

import '../../app/routes/app_routes.dart';
import '../../core/utils/formatters.dart';
import '../../core/utils/units.dart';
import '../../data/db/database.dart';
import '../../data/repositories/service_repo.dart';
import '../../services/reminder_service.dart';
import '../vehicles/vehicle_controller.dart';
import '../../core/utils/l10n.dart';

/// Add / edit a recurring maintenance definition.
class ServiceItemFormController extends GetxController {
  ServiceItemFormController(this._service, this._vehicles, this._reminders);

  final ServiceRepo _service;
  final VehicleController _vehicles;
  final ReminderService _reminders;

  final formKey = GlobalKey<FormState>();

  final nameCtrl = TextEditingController();
  final intervalDistanceCtrl = TextEditingController();
  final intervalDaysCtrl = TextEditingController();
  final lastDoneOdometerCtrl = TextEditingController();

  final lastDoneDateMs = RxnInt();
  final iconKey = 'wrench'.obs;
  final isActive = true.obs;

  final isLoading = true.obs;
  final isSaving = false.obs;

  int? editId;
  bool get isEditing => editId != null;

  Fmt get fmt => _vehicles.fmt.value;

  /// The icons offered in the picker, in the order they appear.
  static const iconKeys = [
    'wrench',
    'oil',
    'filter',
    'air',
    'chain',
    'spark',
    'brake',
    'fluid',
    'coolant',
    'tyre',
    'battery',
    'valve',
  ];

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    editId = args is Map ? args[RouteArgs.editId] as int? : null;
    _load();
  }

  @override
  void onClose() {
    nameCtrl.dispose();
    intervalDistanceCtrl.dispose();
    intervalDaysCtrl.dispose();
    lastDoneOdometerCtrl.dispose();
    super.onClose();
  }

  Future<void> _load() async {
    final id = editId;
    if (id != null) {
      final item = await _service.getItem(id);
      if (item != null) {
        nameCtrl.text = item.name;
        intervalDistanceCtrl.text = item.intervalM == null
            ? ''
            : _trim(Units.metresTo(item.intervalM!, fmt.distanceUnit));
        intervalDaysCtrl.text = item.intervalDays?.toString() ?? '';
        lastDoneOdometerCtrl.text = item.lastDoneOdometerM == null
            ? ''
            : _trim(Units.metresTo(item.lastDoneOdometerM!, fmt.distanceUnit));
        lastDoneDateMs.value = item.lastDoneDateMs;
        iconKey.value = item.iconKey;
        isActive.value = item.isActive;
      }
    }
    isLoading.value = false;
  }

  String? validateName(String? v) =>
      (v == null || v.trim().isEmpty) ? l10n.serviceItemNameError : null;

  /// At least one interval is required, otherwise the item can never come
  /// due and the screen would show it as `NOT SET` forever.
  String? validateIntervals() {
    final distance = _parse(intervalDistanceCtrl);
    final days = int.tryParse(intervalDaysCtrl.text.trim());
    if ((distance == null || distance <= 0) && (days == null || days <= 0)) {
      return l10n.serviceItemIntervalError;
    }
    return null;
  }

  final intervalError = RxnString();

  Future<void> save() async {
    intervalError.value = validateIntervals();
    if (!(formKey.currentState?.validate() ?? false)) return;
    if (intervalError.value != null) return;
    if (isSaving.value) return;
    isSaving.value = true;

    try {
      final distance = _parse(intervalDistanceCtrl);
      final days = int.tryParse(intervalDaysCtrl.text.trim());
      final lastOdometer = _parse(lastDoneOdometerCtrl);

      final companion = ServiceItemsCompanion(
        vehicleId: Value(_vehicles.activeId),
        name: Value(nameCtrl.text.trim()),
        intervalM: Value(
          distance == null || distance <= 0
              ? null
              : Units.toMetres(distance, fmt.distanceUnit),
        ),
        intervalDays: Value(days == null || days <= 0 ? null : days),
        lastDoneOdometerM: Value(
          lastOdometer == null
              ? null
              : Units.toMetres(lastOdometer, fmt.distanceUnit),
        ),
        lastDoneDateMs: Value(lastDoneDateMs.value),
        iconKey: Value(iconKey.value),
        isActive: Value(isActive.value),
      );

      final id = editId;
      if (id == null) {
        await _service.createItem(
          companion.copyWith(
            createdAt: const Value(0),
            updatedAt: const Value(0),
          ),
        );
      } else {
        await _service.updateItem(id, companion);
      }

      await _reminders.recompute(_vehicles.activeId);
      Get.back<bool>(result: true);
    } finally {
      isSaving.value = false;
    }
  }

  Future<void> delete() async {
    final id = editId;
    if (id == null) return;
    await _service.softDeleteItem(id);
    await _reminders.recompute(_vehicles.activeId);
    Get.back<bool>(result: true);
  }

  static double? _parse(TextEditingController c) =>
      double.tryParse(c.text.replaceAll(',', '').trim());

  static String _trim(double value) => value == value.roundToDouble()
      ? value.round().toString()
      : value.toStringAsFixed(1);
}
