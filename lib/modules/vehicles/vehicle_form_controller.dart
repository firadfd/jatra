import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:get/get.dart' hide Value;

import '../../app/routes/app_routes.dart';
import '../../core/utils/money.dart';
import '../../core/utils/units.dart';
import '../../data/db/database.dart';
import '../../data/repositories/vehicle_repo.dart';

/// Add / edit a vehicle.
///
/// All text controllers live here rather than in the widget, so rotating the
/// device mid-form loses nothing.
class VehicleFormController extends GetxController {
  VehicleFormController(this._repo);

  final VehicleRepo _repo;

  final formKey = GlobalKey<FormState>();

  final nameCtrl = TextEditingController();
  final makeCtrl = TextEditingController();
  final modelCtrl = TextEditingController();
  final yearCtrl = TextEditingController();
  final engineCcCtrl = TextEditingController();
  final registrationCtrl = TextEditingController();
  final purchasePriceCtrl = TextEditingController();
  final currentValueCtrl = TextEditingController();
  final tankCapacityCtrl = TextEditingController();
  final initialOdometerCtrl = TextEditingController();

  final fuelType = FuelType.petrol.obs;
  final distanceUnit = DistanceUnit.km.obs;
  final volumeUnit = VolumeUnit.l.obs;
  final currency = 'BDT'.obs;
  final colorTag = 0.obs;
  final isDefault = false.obs;
  final purchaseDateMs = RxnInt();

  final isSaving = false.obs;
  final isLoading = true.obs;

  /// Null when creating.
  int? editId;

  bool get isEditing => editId != null;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    editId = args is Map ? args[RouteArgs.editId] as int? : null;
    _load();
  }

  @override
  void onClose() {
    for (final c in [
      nameCtrl,
      makeCtrl,
      modelCtrl,
      yearCtrl,
      engineCcCtrl,
      registrationCtrl,
      purchasePriceCtrl,
      currentValueCtrl,
      tankCapacityCtrl,
      initialOdometerCtrl,
    ]) {
      c.dispose();
    }
    super.onClose();
  }

  Future<void> _load() async {
    final id = editId;
    if (id == null) {
      isLoading.value = false;
      return;
    }

    final v = await _repo.getById(id);
    if (v == null) {
      isLoading.value = false;
      return;
    }

    nameCtrl.text = v.name;
    makeCtrl.text = v.make ?? '';
    modelCtrl.text = v.model ?? '';
    yearCtrl.text = v.year?.toString() ?? '';
    engineCcCtrl.text = v.engineCc?.toString() ?? '';
    registrationCtrl.text = v.registrationNo ?? '';
    purchasePriceCtrl.text = v.purchasePriceMinor == null
        ? ''
        : Money(v.purchasePriceMinor!).asMajor.toStringAsFixed(2);
    currentValueCtrl.text = v.currentValueEstimateMinor == null
        ? ''
        : Money(v.currentValueEstimateMinor!).asMajor.toStringAsFixed(2);
    tankCapacityCtrl.text = v.tankCapacityMl == null
        ? ''
        : Units.mlTo(v.tankCapacityMl!, v.volumeUnit).toStringAsFixed(1);
    initialOdometerCtrl.text = Units.metresTo(
      v.initialOdometerM,
      v.distanceUnit,
    ).toStringAsFixed(0);

    fuelType.value = v.fuelType;
    distanceUnit.value = v.distanceUnit;
    volumeUnit.value = v.volumeUnit;
    currency.value = v.currency;
    colorTag.value = v.colorTag;
    isDefault.value = v.isDefault;
    purchaseDateMs.value = v.purchaseDateMs;

    isLoading.value = false;
  }

  Future<void> save() async {
    if (!(formKey.currentState?.validate() ?? false)) return;
    if (isSaving.value) return;
    isSaving.value = true;

    try {
      final companion = VehiclesCompanion(
        name: Value(nameCtrl.text.trim()),
        make: Value(_text(makeCtrl)),
        model: Value(_text(modelCtrl)),
        year: Value(_int(yearCtrl)),
        engineCc: Value(_int(engineCcCtrl)),
        registrationNo: Value(_text(registrationCtrl)),
        fuelType: Value(fuelType.value),
        purchaseDateMs: Value(purchaseDateMs.value),
        purchasePriceMinor: Value(_money(purchasePriceCtrl)?.minor),
        currentValueEstimateMinor: Value(_money(currentValueCtrl)?.minor),
        tankCapacityMl: Value(
          _double(tankCapacityCtrl) == null
              ? null
              : Units.toMl(_double(tankCapacityCtrl)!, volumeUnit.value),
        ),
        initialOdometerM: Value(
          Units.toMetres(_double(initialOdometerCtrl) ?? 0, distanceUnit.value),
        ),
        distanceUnit: Value(distanceUnit.value),
        volumeUnit: Value(volumeUnit.value),
        currency: Value(currency.value),
        colorTag: Value(colorTag.value),
        isDefault: Value(isDefault.value),
      );

      final id = editId;
      if (id == null) {
        final newId = await _repo.create(
          // `insert` requires the non-nullable columns; the repository stamps
          // the timestamps, so the zeros here are placeholders it overwrites.
          companion.copyWith(
            createdAt: const Value(0),
            updatedAt: const Value(0),
          ),
        );
        Get.back<int>(result: newId);
      } else {
        await _repo.update(id, companion);
        if (isDefault.value) await _repo.setDefault(id);
        Get.back<int>(result: id);
      }
    } finally {
      isSaving.value = false;
    }
  }

  static String? _text(TextEditingController c) {
    final t = c.text.trim();
    return t.isEmpty ? null : t;
  }

  static int? _int(TextEditingController c) => int.tryParse(c.text.trim());

  static double? _double(TextEditingController c) =>
      double.tryParse(c.text.replaceAll(',', '').trim());

  static Money? _money(TextEditingController c) => Money.tryParse(c.text);
}
