import 'dart:async';

import 'package:get/get.dart' hide Value;

import '../../core/calc/mileage_calc.dart';
import '../../core/utils/clock.dart';
import '../../core/utils/money.dart';
import '../../data/db/database.dart';
import '../../data/repositories/fuel_repo.dart';
import '../../services/settings_service.dart';
import '../vehicles/vehicle_controller.dart';

/// One month of fills, for the grouped history list.
class FuelMonthGroup {
  const FuelMonthGroup({
    required this.monthStartMs,
    required this.entries,
    required this.totalCost,
    required this.totalVolumeMl,
  });

  final int monthStartMs;

  /// Newest first, the way the list reads.
  final List<FuelEntryRow> entries;

  final Money totalCost;
  final int totalVolumeMl;
}

/// The active vehicle's fuel log and everything derived from it.
///
/// Registered permanently: the home screen, the history screen and (from
/// Phase 4) the stats screen all need the same [MileageReport], and computing
/// it three times over a few hundred entries would be wasteful and, worse,
/// could show three different answers mid-write.
class FuelController extends GetxController {
  FuelController(this._repo, this._vehicles, this._settings);

  final FuelRepo _repo;
  final VehicleController _vehicles;
  final SettingsService _settings;

  StreamSubscription<List<FuelEntryRow>>? _sub;

  /// Ascending by odometer — the order the mileage engine expects.
  final entries = <FuelEntryRow>[].obs;

  final report = MileageReport.empty.obs;
  final isReady = false.obs;

  @override
  void onInit() {
    super.onInit();
    ever(_vehicles.active, (_) => _bind());
    // Re-run the engine when the alert threshold changes, so the setting
    // takes effect without a restart.
    ever(_settings.mileageDropThreshold, (_) => _recompute());
    _bind();
  }

  @override
  void onClose() {
    _sub?.cancel();
    super.onClose();
  }

  void _bind() {
    _sub?.cancel();
    final id = _vehicles.activeId;
    if (id == 0) {
      entries.clear();
      report.value = MileageReport.empty;
      isReady.value = true;
      return;
    }
    isReady.value = false;
    _sub = _repo.watchForVehicle(id).listen((rows) {
      entries.assignAll(rows);
      _recompute();
      isReady.value = true;
    });
  }

  void _recompute() {
    report.value = MileageEngine.compute(
      entries,
      dropThresholdPercent: _settings.mileageDropThreshold.value,
    );
  }

  /// Newest first — the order every list in the app shows fills in.
  List<FuelEntryRow> get newestFirst =>
      [...entries].reversed.toList(growable: false);

  /// Fills grouped into calendar months in the user's local time, newest
  /// month first. Grouping in UTC would push a 9pm fill in Dhaka into
  /// tomorrow's bucket.
  List<FuelMonthGroup> get monthGroups {
    final buckets = <int, List<FuelEntryRow>>{};
    for (final e in newestFirst) {
      buckets.putIfAbsent(Dates.startOfLocalMonth(e.dateMs), () => []).add(e);
    }

    final keys = buckets.keys.toList()..sort((a, b) => b.compareTo(a));
    return [
      for (final key in keys)
        FuelMonthGroup(
          monthStartMs: key,
          entries: buckets[key]!,
          totalCost: buckets[key]!.fold(
            Money.zero,
            (sum, e) => sum + Money(e.totalCostMinor),
          ),
          totalVolumeMl: buckets[key]!.fold(0, (sum, e) => sum + e.volumeMl),
        ),
    ];
  }

  /// The window a given entry closes, if any. Drives the km/L cell on a row.
  MileageWindow? windowFor(int entryId) =>
      report.value.windowsByClosingEntry[entryId];

  Future<void> delete(int id) => _repo.softDelete(id);

  Future<void> undoDelete(int id) => _repo.restore(id);
}
