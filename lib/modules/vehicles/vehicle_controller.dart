import 'dart:async';

import 'package:get/get.dart';

import '../../core/utils/formatters.dart';
import '../../data/db/database.dart';
import '../../data/repositories/vehicle_repo.dart';
import '../../services/settings_service.dart';

/// Global vehicle state: the list for the switcher and which one is active.
///
/// Registered permanently in `InitialBinding` because every screen scopes to
/// the active vehicle. Screens read `active` and `fmt` from here rather than
/// each fetching a vehicle of their own.
class VehicleController extends GetxController {
  VehicleController(this._repo, this._settings);

  final VehicleRepo _repo;
  final SettingsService _settings;

  StreamSubscription<List<VehicleRow>>? _sub;

  final vehicles = <VehicleRow>[].obs;
  final active = Rx<VehicleRow?>(null);
  final isReady = false.obs;

  /// Formatter bound to the active vehicle's units and currency. Recomputed
  /// whenever the active vehicle changes, so switching a bike from km to
  /// miles reformats every screen at once.
  final fmt = Fmt().obs;

  bool get hasVehicles => vehicles.isNotEmpty;
  int get activeId => active.value?.id ?? 0;

  @override
  void onInit() {
    super.onInit();
    _sub = _repo.watchAll().listen(_onVehicles);
    ever(active, (v) => fmt.value = _formatterFor(v));
  }

  @override
  void onClose() {
    _sub?.cancel();
    super.onClose();
  }

  void _onVehicles(List<VehicleRow> rows) {
    vehicles.assignAll(rows);

    // Resolve the active vehicle against the fresh list every time, so an
    // archived or deleted bike cannot stay selected.
    final storedId = _settings.activeVehicleId.value;
    final resolved =
        rows.firstWhereOrNull((v) => v.id == storedId) ??
        rows.firstWhereOrNull((v) => v.isDefault) ??
        (rows.isEmpty ? null : rows.first);

    active.value = resolved;
    if (resolved != null && resolved.id != storedId) {
      _settings.setActiveVehicle(resolved.id);
    }
    if (rows.isEmpty && storedId != 0) {
      _settings.setActiveVehicle(0);
    }

    isReady.value = true;
  }

  void setActive(int id) {
    final match = vehicles.firstWhereOrNull((v) => v.id == id);
    if (match == null) return;
    _settings.setActiveVehicle(id);
    active.value = match;
  }

  Fmt _formatterFor(VehicleRow? v) {
    if (v == null) return Fmt(locale: _settings.localeCode.value);
    return Fmt(
      distanceUnit: v.distanceUnit,
      volumeUnit: v.volumeUnit,
      currency: v.currency,
      locale: _settings.localeCode.value,
    );
  }

  /// Cycles to the next vehicle. Backs the app-bar switcher's tap gesture
  /// when only two bikes exist, where a menu would be overkill.
  void cycleNext() {
    if (vehicles.length < 2) return;
    final i = vehicles.indexWhere((v) => v.id == activeId);
    setActive(vehicles[(i + 1) % vehicles.length].id);
  }
}
