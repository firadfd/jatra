import 'package:get/get.dart' hide Value;

import '../../core/calc/cost_calc.dart';
import '../../core/calc/date_range.dart';
import '../../core/calc/mileage_calc.dart';
import '../../core/calc/monthly_rollup.dart';
import '../../core/utils/clock.dart';
import '../../core/utils/money.dart';
import '../../data/db/database.dart';
import '../../data/repositories/expense_repo.dart';
import '../../data/repositories/fuel_repo.dart';
import '../../data/repositories/service_repo.dart';
import '../../services/settings_service.dart';
import '../vehicles/vehicle_controller.dart';

/// A single point on the mileage or price line.
class SeriesPoint {
  const SeriesPoint({required this.dateMs, required this.value});

  final int dateMs;
  final double value;
}

/// Statistics screen state.
///
/// Every figure and every chart respects the selected range and the active
/// vehicle. Data is loaded once per range change rather than per chart, so
/// the six charts on this screen cannot disagree with each other.
class StatsController extends GetxController {
  StatsController(
    this._fuel,
    this._service,
    this._expenses,
    this._vehicles,
    this._settings,
  );

  final FuelRepo _fuel;
  final ServiceRepo _service;
  final ExpenseRepo _expenses;
  final VehicleController _vehicles;
  final SettingsService _settings;

  final range = DateRange.allTime().obs;
  final isLoading = true.obs;

  final report = CostReport.empty.obs;
  final mileageReport = MileageReport.empty.obs;
  final monthly = <MonthlySpend>[].obs;

  /// One point per valid full-tank window, in the user's economy units.
  final mileageSeries = <SeriesPoint>[].obs;

  /// Price actually paid per volume unit, per fill. People love watching this.
  final priceSeries = <SeriesPoint>[].obs;

  final totalFills = 0.obs;
  final daysOwned = 0.obs;

  @override
  void onInit() {
    super.onInit();
    ever(_vehicles.active, (_) => load());
    ever(range, (_) => load());
    load();
  }

  void setPreset(RangePreset preset) {
    if (preset == RangePreset.custom) return;
    range.value = DateRange.of(preset);
  }

  void setCustomRange(int fromMs, int toMs) {
    range.value = DateRange.custom(fromMs, toMs);
  }

  Future<void> load() async {
    final vehicle = _vehicles.active.value;
    if (vehicle == null) {
      isLoading.value = false;
      return;
    }

    isLoading.value = true;
    final r = range.value;

    final fuelEntries = await _fuel.getInRange(
      vehicle.id,
      fromMs: r.fromMs,
      toMs: r.toMs,
    );
    final serviceLogs = await _service.getLogsInRange(
      vehicle.id,
      fromMs: r.fromMs,
      toMs: r.toMs,
    );
    final expenses = await _expenses.getInRange(
      vehicle.id,
      fromMs: r.fromMs,
      toMs: r.toMs,
    );
    final observations = await _fuel.odometerObservations(vehicle.id);

    final distance = CostCalculator.distanceIn(observations, range: r);

    report.value = CostCalculator.compute(
      vehicle: vehicle,
      range: r,
      fuelEntries: fuelEntries,
      serviceLogs: serviceLogs,
      expenses: expenses,
      distanceM: distance.distanceM,
      observationCount: distance.count,
      defaultAnnualDepreciationPercent:
          _settings.defaultDepreciationPercent.value,
    );

    // The mileage engine runs over the *whole* log, not the range, because a
    // window needs the full tank before the range started to measure
    // against. Points outside the range are filtered afterwards.
    mileageReport.value = MileageEngine.compute(
      await _fuel.getForVehicle(vehicle.id),
      dropThresholdPercent: _settings.mileageDropThreshold.value,
    );

    _buildSeries(fuelEntries, r);
    _buildMonthly(fuelEntries, serviceLogs, expenses, observations);

    totalFills.value = fuelEntries.length;
    daysOwned.value = Dates.daysBetween(
      vehicle.purchaseDateMs ?? vehicle.createdAt,
      Clock.nowMs,
    );

    isLoading.value = false;
  }

  void _buildSeries(List<FuelEntryRow> fuelEntries, DateRange r) {
    final fmt = _vehicles.fmt.value;

    mileageSeries.assignAll([
      for (final w in mileageReport.value.reliableWindows)
        if (r.contains(w.closingDateMs))
          SeriesPoint(
            dateMs: w.closingDateMs,
            value: w.economy(fmt.distanceUnit, fmt.volumeUnit) ?? 0,
          ),
    ]);

    priceSeries.assignAll(
      [
        for (final e in fuelEntries)
          if (e.volumeMl > 0)
            SeriesPoint(
              dateMs: e.dateMs,
              // Derived from the exact volume/total pair the rider entered,
              // not from the canonicalised per-litre column.
              value:
                  Money(e.totalCostMinor).asMajor /
                  _volumeInUserUnits(e.volumeMl),
            ),
      ]..sort((a, b) => a.dateMs.compareTo(b.dateMs)),
    );
  }

  double _volumeInUserUnits(int ml) {
    final fmt = _vehicles.fmt.value;
    return fmt.volumeUnit == VolumeUnit.l ? ml / 1000 : ml / 3785.411784;
  }

  void _buildMonthly(
    List<FuelEntryRow> fuelEntries,
    List<ServiceLogRow> serviceLogs,
    List<ExpenseRow> expenses,
    List<({int dateMs, int odometerM})> observations,
  ) {
    monthly.assignAll(
      MonthlyRollup.build(
        fuelEntries: fuelEntries,
        serviceLogs: serviceLogs,
        expenses: expenses,
        observations: observations,
      ),
    );
  }

  /// Trip calculator, exposed for the stats screen's inline estimator.
  TripEstimate? estimateTrip(int distanceM) => CostCalculator.estimateTrip(
    report: report.value,
    distanceM: distanceM,
    unit: _vehicles.fmt.value.distanceUnit,
  );
}
