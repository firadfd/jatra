import '../../data/db/database.dart';
import '../utils/clock.dart';
import '../utils/money.dart';
import 'cost_calc.dart';
import 'date_range.dart';

/// One calendar month of spending, split by where it went.
class MonthlySpend {
  const MonthlySpend({
    required this.monthStartMs,
    required this.fuel,
    required this.service,
    required this.other,
    required this.distanceM,
  });

  final int monthStartMs;
  final Money fuel;
  final Money service;
  final Money other;
  final int distanceM;

  Money get total => fuel + service + other;

  /// Cost per metre in minor units, or null for a month with no measured
  /// distance — guard every division.
  double? get costPerMetreMinor =>
      distanceM <= 0 ? null : total.minor / distanceM;
}

/// Groups records into calendar months.
///
/// Shared by the statistics screen and the home-screen widget so the two can
/// never draw different bars from the same data. Pure over what it is
/// handed: every list is expected to be pre-filtered to the range the caller
/// cares about, and [observations] is the full odometer history (distance is
/// clipped per month inside).
abstract final class MonthlyRollup {
  static List<MonthlySpend> build({
    required List<FuelEntryRow> fuelEntries,
    required List<ServiceLogRow> serviceLogs,
    required List<ExpenseRow> expenses,
    required List<({int dateMs, int odometerM})> observations,
  }) {
    final months = <int, ({Money fuel, Money service, Money other})>{};

    void add(int dateMs, {Money? fuel, Money? service, Money? other}) {
      final key = Dates.startOfLocalMonth(dateMs);
      final current =
          months[key] ??
          (fuel: Money.zero, service: Money.zero, other: Money.zero);
      months[key] = (
        fuel: current.fuel + (fuel ?? Money.zero),
        service: current.service + (service ?? Money.zero),
        other: current.other + (other ?? Money.zero),
      );
    }

    for (final e in fuelEntries) {
      add(e.dateMs, fuel: Money(e.totalCostMinor));
    }
    for (final s in serviceLogs) {
      add(s.dateMs, service: Money(s.totalCostMinor));
    }
    for (final x in expenses) {
      add(x.dateMs, other: Money(x.amountMinor));
    }

    final keys = months.keys.toList()..sort();
    return [
      for (final key in keys)
        MonthlySpend(
          monthStartMs: key,
          fuel: months[key]!.fuel,
          service: months[key]!.service,
          other: months[key]!.other,
          distanceM: distanceInMonth(observations, key),
        ),
    ];
  }

  /// Odometer span within one calendar month. Zero when fewer than two
  /// readings landed in it.
  static int distanceInMonth(
    List<({int dateMs, int odometerM})> observations,
    int monthStartMs,
  ) {
    final d = DateTime.fromMillisecondsSinceEpoch(monthStartMs);
    final monthEnd = DateTime(d.year, d.month + 1).millisecondsSinceEpoch - 1;
    return CostCalculator.distanceIn(
      observations,
      range: DateRange(
        fromMs: monthStartMs,
        toMs: monthEnd,
        preset: RangePreset.custom,
      ),
    ).distanceM;
  }
}
