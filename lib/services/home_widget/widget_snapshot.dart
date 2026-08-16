import '../../core/calc/cost_calc.dart';
import '../../core/calc/date_range.dart';
import '../../core/calc/mileage_calc.dart';
import '../../core/calc/monthly_rollup.dart';
import '../../core/utils/formatters.dart';
import '../../core/utils/money.dart';
import '../../core/utils/units.dart';
import '../../data/db/database.dart';
import '../../data/repositories/expense_repo.dart';
import '../../data/repositories/fuel_repo.dart';
import '../../data/repositories/service_repo.dart';

/// One month's bar on the widget's three charts, already converted into the
/// vehicle's own units.
///
/// The face draws from these and never touches a repository, so it can be
/// pumped in a test with a handful of literals.
class WidgetMonth {
  const WidgetMonth({
    required this.monthStartMs,
    required this.fuel,
    required this.service,
    required this.other,
    required this.distanceM,
    required this.distance,
    required this.fuelCostPerDistance,
  });

  /// Major currency units — the bars are drawn, not summed, so the exactness
  /// [Money] guarantees has already done its job by the time we get here.
  final double fuel;
  final double service;
  final double other;

  final int monthStartMs;

  /// Canonical metres, so the readout beside the chart can be formatted
  /// exactly by [Fmt] rather than rounded twice.
  final int distanceM;

  /// The same distance in the vehicle's unit, which is what the painter and
  /// the axis ticks scale against.
  final double distance;

  /// Fuel cost per distance unit, or null for a month with no measured
  /// distance. Those months break the line rather than plotting a zero.
  final double? fuelCostPerDistance;

  double get spend => fuel + service + other;
}

/// Everything the home-screen widget draws, resolved once.
///
/// Deliberately a plain value type holding **all-time** figures for one
/// vehicle: the widget has no controls, so there is no range to vary and
/// nothing to recompute between renders. [Fmt] rides along so the face
/// formats in the vehicle's own units and currency without reaching for
/// GetX.
class WidgetSnapshot {
  const WidgetSnapshot({
    required this.vehicleName,
    required this.fmt,
    required this.distanceM,
    required this.spend,
    required this.economy,
    required this.fuelCostPerDistance,
    required this.months,
  });

  /// The "no bike yet" face. Distinct from [hasData]: there is nothing to
  /// set up against, so the widget says so rather than showing four dashes.
  static WidgetSnapshot empty(Fmt fmt) => WidgetSnapshot(
    vehicleName: '',
    fmt: fmt,
    distanceM: 0,
    spend: Money.zero,
    economy: null,
    fuelCostPerDistance: null,
    months: const [],
  );

  final String vehicleName;
  final Fmt fmt;

  /// All-time distance, from the first logged odometer reading to the last.
  final int distanceM;

  /// Fuel + service + everything else. Running cost, not true cost —
  /// depreciation is an estimate and does not belong on a glanceable tile.
  final Money spend;

  /// Average economy over every reliable full-tank window, in the vehicle's
  /// units. Null until two full tanks exist.
  final double? economy;

  /// **Fuel** cost per distance unit — petrol only, not servicing, parts or
  /// fixed costs. Null with no measured distance.
  ///
  /// The statistics screen shows all three of fuel, running and true cost
  /// side by side with an explanation of each. A widget has room for one
  /// figure and no room to explain it, so it shows the one a rider can check
  /// against a pump receipt. [spend] beside it is still the full total, and
  /// is labelled as such.
  final double? fuelCostPerDistance;

  /// Every calendar month that carries a record, oldest first. Not padded:
  /// a rider who logged nothing in March gets no March bar rather than a
  /// misleading zero one.
  final List<WidgetMonth> months;

  bool get hasVehicle => vehicleName.isNotEmpty;
  bool get hasData => months.isNotEmpty;

  /// True once at least one month has a measured distance — the two
  /// distance-derived charts are hidden below this, since a chart of nothing
  /// reads as a chart of zero.
  bool get hasDistance => months.any((m) => m.distance > 0);
}

/// Builds a [WidgetSnapshot] straight from the repositories.
///
/// Runs the same calculators as the statistics screen over an all-time
/// range, so the widget and the app cannot disagree about what a kilometre
/// costs.
class WidgetSnapshotBuilder {
  const WidgetSnapshotBuilder(this._fuel, this._service, this._expenses);

  final FuelRepo _fuel;
  final ServiceRepo _service;
  final ExpenseRepo _expenses;

  Future<WidgetSnapshot> build({
    required VehicleRow? vehicle,
    required Fmt fmt,
    required int mileageDropThreshold,
    required double defaultDepreciationPercent,
  }) async {
    if (vehicle == null) return WidgetSnapshot.empty(fmt);

    final range = DateRange.allTime();

    final fuelEntries = await _fuel.getForVehicle(vehicle.id);
    final serviceLogs = await _service.getLogs(vehicle.id);
    final expenses = await _expenses.getForVehicle(vehicle.id);
    final observations = await _fuel.odometerObservations(vehicle.id);

    final distance = CostCalculator.distanceIn(observations, range: range);

    final report = CostCalculator.compute(
      vehicle: vehicle,
      range: range,
      fuelEntries: fuelEntries,
      serviceLogs: serviceLogs,
      expenses: expenses,
      distanceM: distance.distanceM,
      observationCount: distance.count,
      defaultAnnualDepreciationPercent: defaultDepreciationPercent,
    );

    final mileage = MileageEngine.compute(
      fuelEntries,
      dropThresholdPercent: mileageDropThreshold,
    );

    final months = MonthlyRollup.build(
      fuelEntries: fuelEntries,
      serviceLogs: serviceLogs,
      expenses: expenses,
      observations: observations,
    );

    return WidgetSnapshot(
      vehicleName: vehicle.name,
      fmt: fmt,
      distanceM: report.distanceM,
      spend: report.runningCost,
      economy: mileage.average(fmt.distanceUnit, fmt.volumeUnit),
      fuelCostPerDistance: report.fuelPerDistance(fmt.distanceUnit),
      months: [for (final m in months) _month(m, fmt.distanceUnit)],
    );
  }

  static WidgetMonth _month(MonthlySpend month, DistanceUnit unit) {
    final distance = Units.metresTo(month.distanceM, unit);

    return WidgetMonth(
      monthStartMs: month.monthStartMs,
      fuel: month.fuel.asMajor,
      service: month.service.asMajor,
      other: month.other.asMajor,
      distanceM: month.distanceM,
      distance: distance,
      // Fuel only, to match the tile above the chart, and guarded: a month
      // with one odometer reading has spend but no measurable distance, and
      // dividing by it would report an infinite cost per kilometre.
      fuelCostPerDistance: distance <= 0 ? null : month.fuel.asMajor / distance,
    );
  }
}
