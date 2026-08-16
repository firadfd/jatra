import '../../data/db/database.dart';
import '../utils/clock.dart';
import '../utils/money.dart';
import '../utils/units.dart';
import 'date_range.dart';

/// What a kilometre costs — three different answers to three different
/// questions, kept apart because conflating them is how people end up
/// believing a motorcycle is nearly free to run.
class CostReport {
  const CostReport({
    required this.range,
    required this.distanceM,
    required this.fuelCost,
    required this.serviceCost,
    required this.otherCost,
    required this.depreciation,
    required this.hasDepreciation,
    required this.observationCount,
  });

  final DateRange range;

  /// Odometer span across the range. Zero when there are fewer than two
  /// readings to measure between.
  final int distanceM;

  final Money fuelCost;

  /// Parts and labour from service logs.
  final Money serviceCost;

  /// Insurance, tax token, fitness, accessories, fines — everything that is
  /// neither fuel nor a service.
  final Money otherCost;

  /// Straight-line value lost over this range. Always an estimate.
  final Money depreciation;

  /// False when the bike has no purchase price, in which case depreciation
  /// is genuinely unknown rather than zero, and true cost/km is not shown.
  final bool hasDepreciation;

  /// How many odometer readings the distance was measured across. One or
  /// zero means no distance could be established.
  final int observationCount;

  static const empty = CostReport(
    range: DateRange(fromMs: 0, toMs: 0, preset: RangePreset.allTime),
    distanceM: 0,
    fuelCost: Money.zero,
    serviceCost: Money.zero,
    otherCost: Money.zero,
    depreciation: Money.zero,
    hasDepreciation: false,
    observationCount: 0,
  );

  /// Fuel + service + fixed costs. What it takes to keep the bike running.
  Money get runningCost => fuelCost + serviceCost + otherCost;

  /// Running cost plus the value the bike quietly lost.
  Money get trueCost => runningCost + depreciation;

  bool get hasDistance => distanceM > 0;

  /// **Fuel cost per distance** — fuel spend ÷ distance. Fluctuates weekly
  /// with pump prices and traffic. In minor units per user distance unit.
  double? fuelPerDistance(DistanceUnit unit) => _perDistance(fuelCost, unit);

  /// **Running cost per distance** — fuel, servicing, parts and fixed costs.
  /// What it actually costs to keep riding.
  double? runningPerDistance(DistanceUnit unit) =>
      _perDistance(runningCost, unit);

  /// **True cost per distance** — running cost plus depreciation. The number
  /// that answers "what did this bike cost me?" honestly.
  ///
  /// Null when the bike has no purchase price, because an unknown is not a
  /// zero and quietly pretending otherwise would understate the answer.
  double? truePerDistance(DistanceUnit unit) =>
      hasDepreciation ? _perDistance(trueCost, unit) : null;

  /// Guards every division: no distance ⇒ no rate, never zero, never
  /// infinity.
  double? _perDistance(Money amount, DistanceUnit unit) {
    if (distanceM <= 0) return null;
    final distance = Units.metresTo(distanceM, unit);
    if (distance <= 0) return null;
    return amount.minor / 100 / distance;
  }

  /// Share of running cost that went on fuel — drives the stacked bar and
  /// reads well as "72% of what you spend is petrol".
  double get fuelShare =>
      runningCost.minor == 0 ? 0 : fuelCost.minor / runningCost.minor;
}

/// What one trip would cost, at the rates from the selected period.
class TripEstimate {
  const TripEstimate({
    required this.distanceM,
    required this.fuelCost,
    required this.trueCost,
  });

  final int distanceM;
  final Money fuelCost;

  /// Null when depreciation is unknown, matching [CostReport.truePerDistance].
  final Money? trueCost;
}

/// The money engine.
abstract final class CostCalculator {
  /// Distance covered inside a range, measured between the first and last
  /// odometer readings that fall in it.
  ///
  /// Readings come from fuel entries, service logs and completed rides. Two
  /// are needed to measure anything at all: a month with a single fill logged
  /// tells you what was spent but not how far it went, and reporting 0 km
  /// would turn every rate into nonsense.
  static ({int distanceM, int count}) distanceIn(
    List<({int dateMs, int odometerM})> observations, {
    required DateRange range,
  }) {
    final inRange = observations
        .where((o) => range.contains(o.dateMs))
        .toList();
    if (inRange.length < 2) {
      return (distanceM: 0, count: inRange.length);
    }

    var min = inRange.first.odometerM;
    var max = inRange.first.odometerM;
    for (final o in inRange) {
      if (o.odometerM < min) min = o.odometerM;
      if (o.odometerM > max) max = o.odometerM;
    }
    return (distanceM: max - min, count: inRange.length);
  }

  /// Builds the report. Every list is expected to be pre-filtered to
  /// [range]; this is a pure function over what it is handed.
  static CostReport compute({
    required VehicleRow vehicle,
    required DateRange range,
    required List<FuelEntryRow> fuelEntries,
    required List<ServiceLogRow> serviceLogs,
    required List<ExpenseRow> expenses,
    required int distanceM,
    required int observationCount,
    required double defaultAnnualDepreciationPercent,
    int? nowMs,
  }) {
    final fuel = fuelEntries.fold(
      Money.zero,
      (sum, e) => sum + Money(e.totalCostMinor),
    );
    final service = serviceLogs.fold(
      Money.zero,
      (sum, e) => sum + Money(e.totalCostMinor),
    );
    final other = expenses.fold(
      Money.zero,
      (sum, e) => sum + Money(e.amountMinor),
    );

    final depreciation = depreciationOver(
      vehicle,
      range: range,
      defaultAnnualPercent: defaultAnnualDepreciationPercent,
      nowMs: nowMs,
    );

    return CostReport(
      range: range,
      distanceM: distanceM,
      fuelCost: fuel,
      serviceCost: service,
      otherCost: other,
      depreciation: depreciation ?? Money.zero,
      hasDepreciation: depreciation != null,
      observationCount: observationCount,
    );
  }

  /// Straight-line depreciation across a range, or `null` when the bike has
  /// no purchase price to depreciate from.
  ///
  /// With a `currentValueEstimate`, the loss is spread evenly from the
  /// purchase date to today. Without one, the fallback is
  /// [defaultAnnualPercent] of the purchase price per year — 12% by default,
  /// overridable in settings.
  ///
  /// Always an estimate, and labelled as one everywhere it is shown.
  static Money? depreciationOver(
    VehicleRow vehicle, {
    required DateRange range,
    required double defaultAnnualPercent,
    int? nowMs,
  }) {
    final purchasePrice = vehicle.purchasePriceMinor;
    if (purchasePrice == null || purchasePrice <= 0) return null;

    final now = nowMs ?? Clock.nowMs;
    final ownedFromMs = vehicle.purchaseDateMs ?? vehicle.createdAt;
    if (ownedFromMs >= now) return Money.zero;

    final ownedMs = now - ownedFromMs;
    if (ownedMs <= 0) return Money.zero;

    // Rated per millisecond rather than per day. Day counts come in two
    // flavours — inclusive for a calendar range, exclusive for a span — and
    // mixing them here silently over-charged the depreciation by a day.
    // Milliseconds have no such ambiguity, and the all-time range then
    // recovers exactly the full loss.
    final double perMsMinor;
    final estimate = vehicle.currentValueEstimateMinor;
    if (estimate != null) {
      // A value higher than the purchase price means the bike appreciated,
      // or — far more likely — a typo. Either way, clamping at zero keeps
      // "true cost" from dipping below "running cost", which would read as
      // a bug rather than as a classic motorcycle.
      final lost = purchasePrice - estimate;
      perMsMinor = lost <= 0 ? 0 : lost / ownedMs;
    } else {
      const msPerYear = 365 * Dates.msPerDay;
      perMsMinor = purchasePrice * (defaultAnnualPercent / 100) / msPerYear;
    }

    // Only the part of the range the bike was actually owned for counts.
    final owned = range.intersect(ownedFromMs, now);
    if (owned == null) return Money.zero;

    return Money((perMsMinor * (owned.toMs - owned.fromMs)).round());
  }

  /// What a given trip costs, at the rates the report established.
  ///
  /// Built for delivery riders deciding whether a job pays: the fuel figure
  /// is the out-of-pocket cost today, the true figure is what the trip
  /// really takes off the bike.
  static TripEstimate? estimateTrip({
    required CostReport report,
    required int distanceM,
    required DistanceUnit unit,
  }) {
    if (distanceM <= 0) return null;

    final fuelRate = report.fuelPerDistance(unit);
    if (fuelRate == null) return null;

    final distance = Units.metresTo(distanceM, unit);
    final trueRate = report.truePerDistance(unit);

    return TripEstimate(
      distanceM: distanceM,
      fuelCost: Money.fromMajor(fuelRate * distance),
      trueCost: trueRate == null ? null : Money.fromMajor(trueRate * distance),
    );
  }
}
