import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
// GetX exports a `Value` typedef of its own (for ValueBuilder), which collides
// with Drift's companion wrapper. Drift's is the one we want everywhere a
// companion is built, so GetX's is hidden — the convention throughout the app.
import 'package:get/get.dart' hide Value;

import '../../app/routes/app_routes.dart';
import '../../core/utils/units.dart';
import '../../data/db/database.dart';
import '../../data/repositories/vehicle_repo.dart';
import '../../services/settings_service.dart';
import '../../core/utils/l10n.dart';
import '../../core/utils/enum_labels.dart';

/// Three screens, maximum: add your bike, set your current odometer, done.
///
/// Not a single permission is requested here — not location, not
/// notifications. The app is fully usable without either, and asking on
/// first launch trains people to tap "deny" before they know what for.
class OnboardingController extends GetxController {
  OnboardingController(this._repo, this._settings);

  final VehicleRepo _repo;
  final SettingsService _settings;

  /// Text controllers live on the controller, not in the widget, so rotating
  /// the device or backgrounding the app mid-form loses nothing.
  final nameCtrl = TextEditingController();
  final makeCtrl = TextEditingController();
  final modelCtrl = TextEditingController();
  final odometerCtrl = TextEditingController();

  final pageController = PageController();

  final page = 0.obs;
  final distanceUnit = DistanceUnit.km.obs;
  final volumeUnit = VolumeUnit.l.obs;
  final currency = 'BDT'.obs;
  final fuelType = FuelType.petrol.obs;
  final isSaving = false.obs;

  final nameError = RxnString();
  final odometerError = RxnString();

  static const lastPage = 2;

  @override
  void onClose() {
    nameCtrl.dispose();
    makeCtrl.dispose();
    modelCtrl.dispose();
    odometerCtrl.dispose();
    pageController.dispose();
    super.onClose();
  }

  double? _parseOdometer() {
    final raw = odometerCtrl.text.replaceAll(',', '').trim();
    if (raw.isEmpty) return null;
    final parsed = double.tryParse(raw);
    if (parsed == null || parsed < 0 || !parsed.isFinite) return null;
    return parsed;
  }

  void next() {
    if (!_validateCurrentPage()) return;
    if (page.value >= lastPage) {
      finish();
      return;
    }
    pageController.nextPage(
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeOutCubic,
    );
  }

  void back() {
    if (page.value == 0) return;
    pageController.previousPage(
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeOutCubic,
    );
  }

  bool _validateCurrentPage() {
    nameError.value = null;
    odometerError.value = null;

    switch (page.value) {
      case 0:
        if (nameCtrl.text.trim().isEmpty) {
          nameError.value = l10n.onboardingBikeNameError;
          return false;
        }
      case 1:
        if (_parseOdometer() == null) {
          odometerError.value = l10n.onboardingOdometerError(
            distanceUnit.value.wordOf(l10n).toLowerCase(),
          );
          return false;
        }
    }
    return true;
  }

  /// Creates the bike, seeds its maintenance schedule and hands over to home.
  Future<void> finish() async {
    if (isSaving.value) return;
    if (!_validateCurrentPage()) return;
    isSaving.value = true;

    try {
      final odometerM = Units.toMetres(
        _parseOdometer() ?? 0,
        distanceUnit.value,
      );

      final id = await _repo.create(
        VehiclesCompanion.insert(
          name: nameCtrl.text.trim(),
          // createdAt/updatedAt are stamped by the repository.
          createdAt: 0,
          updatedAt: 0,
          make: Value(_nullIfBlank(makeCtrl.text)),
          model: Value(_nullIfBlank(modelCtrl.text)),
          fuelType: Value(fuelType.value),
          initialOdometerM: Value(odometerM),
          distanceUnit: Value(distanceUnit.value),
          volumeUnit: Value(volumeUnit.value),
          currency: Value(currency.value),
          isDefault: const Value(true),
        ),
      );

      _settings.setActiveVehicle(id);
      _settings.onboardingComplete.value = true;
      Get.offAllNamed(Routes.home);
    } finally {
      isSaving.value = false;
    }
  }

  static String? _nullIfBlank(String value) {
    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }
}
