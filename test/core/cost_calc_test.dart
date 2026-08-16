import 'package:flutter_test/flutter_test.dart';
import 'package:jatra/core/calc/cost_calc.dart';
import 'package:jatra/core/calc/date_range.dart';
import 'package:jatra/core/utils/clock.dart';
import 'package:jatra/core/utils/money.dart';
import 'package:jatra/data/db/database.dart';

final _now = DateTime.utc(2026, 8, 4, 12);
int get _nowMs => _now.millisecondsSinceEpoch;

VehicleRow vehicle({
  double? purchasePrice,
  double? currentValue,
  int? boughtDaysAgo,
}) {
  return VehicleRow(
    id: 1,
    name: 'Pulsar',
    createdAt: Dates.addDays(_nowMs, -(boughtDaysAgo ?? 365)),
    updatedAt: _nowMs,
    fuelType: FuelType.petrol,
    initialOdometerM: 0,
    distanceUnit: DistanceUnit.km,
    volumeUnit: VolumeUnit.l,
    currency: 'BDT',
    isDefault: true,
    colorTag: 0,
    isArchived: false,
    purchaseDateMs: boughtDaysAgo == null
        ? null
        : Dates.addDays(_nowMs, -boughtDaysAgo),
    purchasePriceMinor: purchasePrice == null
        ? null
        : Money.fromMajor(purchasePrice).minor,
    currentValueEstimateMinor: currentValue == null
        ? null
        : Money.fromMajor(currentValue).minor,
  );
}

FuelEntryRow fuel(double total, {int daysAgo = 0}) => FuelEntryRow(
  id: daysAgo,
  vehicleId: 1,
  dateMs: Dates.addDays(_nowMs, -daysAgo),
  odometerM: 0,
  volumeMl: 10000,
  pricePerUnitMinor: 12150,
  totalCostMinor: Money.fromMajor(total).minor,
  isFullTank: true,
  isMissedEntry: false,
  createdAt: 0,
  updatedAt: 0,
);

ServiceLogRow serviceLog(double total, {int daysAgo = 0}) => ServiceLogRow(
  id: daysAgo,
  vehicleId: 1,
  name: 'Engine oil',
  dateMs: Dates.addDays(_nowMs, -daysAgo),
  odometerM: 0,
  partsCostMinor: 0,
  laborCostMinor: 0,
  totalCostMinor: Money.fromMajor(total).minor,
  createdAt: 0,
  updatedAt: 0,
);

ExpenseRow expense(double amount, {int daysAgo = 0}) => ExpenseRow(
  id: daysAgo,
  vehicleId: 1,
  category: ExpenseCategory.insurance,
  dateMs: Dates.addDays(_nowMs, -daysAgo),
  amountMinor: Money.fromMajor(amount).minor,
  createdAt: 0,
  updatedAt: 0,
);

CostReport report({
  VehicleRow? bike,
  List<FuelEntryRow> fuelEntries = const [],
  List<ServiceLogRow> serviceLogs = const [],
  List<ExpenseRow> expenses = const [],
  int distanceKm = 1000,
  int observationCount = 2,
  DateRange? range,
}) {
  return CostCalculator.compute(
    vehicle: bike ?? vehicle(),
    range: range ?? DateRange.allTime(nowMs: _nowMs),
    fuelEntries: fuelEntries,
    serviceLogs: serviceLogs,
    expenses: expenses,
    distanceM: distanceKm * 1000,
    observationCount: observationCount,
    defaultAnnualDepreciationPercent: 12,
    nowMs: _nowMs,
  );
}

void main() {
  setUp(() => Clock.freeze(_now));
  tearDown(() => Clock.freeze(null));

  group('the three figures answer different questions', () {
    test('and are computed independently', () {
      // 1,000 km. Fuel ৳3,000, service ৳1,000, insurance ৳1,000.
      final r = report(
        bike: vehicle(
          purchasePrice: 180000,
          currentValue: 144000,
          boughtDaysAgo: 365,
        ),
        fuelEntries: [fuel(3000)],
        serviceLogs: [serviceLog(1000)],
        expenses: [expense(1000)],
      );

      expect(r.fuelCost.minor, Money.fromMajor(3000).minor);
      expect(r.runningCost.minor, Money.fromMajor(5000).minor);

      // ৳3.00/km fuel, ৳5.00/km running.
      expect(r.fuelPerDistance(DistanceUnit.km), closeTo(3.0, 1e-9));
      expect(r.runningPerDistance(DistanceUnit.km), closeTo(5.0, 1e-9));

      // ৳36,000 lost over 365 days owned, and the range covers all of it,
      // so true cost is (5,000 + 36,000) ÷ 1,000 = ৳41.00/km.
      expect(r.truePerDistance(DistanceUnit.km), closeTo(41.0, 0.01));
    });

    test('true cost is withheld, not faked, when the price is unknown', () {
      final r = report(bike: vehicle(), fuelEntries: [fuel(3000)]);
      expect(r.hasDepreciation, isFalse);
      expect(r.truePerDistance(DistanceUnit.km), isNull);
      // The other two still work.
      expect(r.fuelPerDistance(DistanceUnit.km), closeTo(3.0, 1e-9));
    });

    test('rates convert with the rider’s distance unit', () {
      final r = report(fuelEntries: [fuel(3000)], distanceKm: 1000);
      final perKm = r.fuelPerDistance(DistanceUnit.km)!;
      final perMile = r.fuelPerDistance(DistanceUnit.mi)!;
      // A mile is longer, so it costs more.
      expect(perMile / perKm, closeTo(1.609344, 1e-6));
    });
  });

  group('guards', () {
    test('no distance means no rate, not a division by zero', () {
      final r = report(fuelEntries: [fuel(3000)], distanceKm: 0);
      expect(r.hasDistance, isFalse);
      expect(r.fuelPerDistance(DistanceUnit.km), isNull);
      expect(r.runningPerDistance(DistanceUnit.km), isNull);
      expect(r.truePerDistance(DistanceUnit.km), isNull);
      // Totals are still perfectly reportable.
      expect(r.fuelCost.minor, Money.fromMajor(3000).minor);
    });

    test('an empty period reports zeroes, not nulls', () {
      final r = report(distanceKm: 0, observationCount: 0);
      expect(r.runningCost.isZero, isTrue);
      expect(r.fuelShare, 0);
    });
  });

  group('distance measurement', () {
    List<({int dateMs, int odometerM})> obs(List<(int, int)> pairs) => [
      for (final (daysAgo, km) in pairs)
        (dateMs: Dates.addDays(_nowMs, -daysAgo), odometerM: km * 1000),
    ];

    test('spans the first and last readings inside the range', () {
      final result = CostCalculator.distanceIn(
        obs([(60, 20000), (30, 20800), (5, 21500)]),
        range: DateRange.allTime(nowMs: _nowMs),
      );
      expect(result.distanceM, 1500 * 1000);
      expect(result.count, 3);
    });

    test('ignores readings outside the range', () {
      // Only the last two fall inside this month.
      final result = CostCalculator.distanceIn(
        obs([(200, 10000), (3, 21000), (1, 21400)]),
        range: DateRange.thisMonth(nowMs: _nowMs),
      );
      expect(result.distanceM, 400 * 1000);
      expect(result.count, 2);
    });

    test('a single reading measures nothing', () {
      // Spend is known, distance is not — and 0 km would make every rate
      // meaningless rather than merely unavailable.
      final result = CostCalculator.distanceIn(
        obs([(3, 21000)]),
        range: DateRange.thisMonth(nowMs: _nowMs),
      );
      expect(result.distanceM, 0);
      expect(result.count, 1);
    });
  });

  group('depreciation', () {
    test('is straight-line between purchase price and current value', () {
      // ৳180,000 → ৳144,000 over 365 days = ৳36,000, all inside all-time.
      final d = CostCalculator.depreciationOver(
        vehicle(
          purchasePrice: 180000,
          currentValue: 144000,
          boughtDaysAgo: 365,
        ),
        range: DateRange.allTime(nowMs: _nowMs),
        defaultAnnualPercent: 12,
        nowMs: _nowMs,
      );
      expect(d!.asMajor, closeTo(36000, 100));
    });

    test('falls back to the default annual percentage', () {
      // 12% of ৳180,000 per year = ৳21,600 across a year of ownership.
      final d = CostCalculator.depreciationOver(
        vehicle(purchasePrice: 180000, boughtDaysAgo: 365),
        range: DateRange.allTime(nowMs: _nowMs),
        defaultAnnualPercent: 12,
        nowMs: _nowMs,
      );
      expect(d!.asMajor, closeTo(21600, 100));
    });

    test('the default rate is overridable', () {
      final d = CostCalculator.depreciationOver(
        vehicle(purchasePrice: 180000, boughtDaysAgo: 365),
        range: DateRange.allTime(nowMs: _nowMs),
        defaultAnnualPercent: 20,
        nowMs: _nowMs,
      );
      expect(d!.asMajor, closeTo(36000, 100));
    });

    test('is prorated to the part of the range the bike was owned', () {
      // Two years of ownership, ৳36,000 lost in total ⇒ ~৳49.3/day.
      // A 31-day month should carry roughly ৳1,529 of it, not the lot.
      final august = DateRange.custom(
        DateTime.utc(2026, 8, 1).millisecondsSinceEpoch,
        DateTime.utc(2026, 8, 31).millisecondsSinceEpoch,
      );
      final d = CostCalculator.depreciationOver(
        vehicle(
          purchasePrice: 180000,
          currentValue: 144000,
          boughtDaysAgo: 730,
        ),
        range: august,
        defaultAnnualPercent: 12,
        nowMs: _nowMs,
      );
      // Only the days up to "now" (4 Aug) count — the bike cannot depreciate
      // in the future.
      expect(d!.asMajor, closeTo(36000 / 730 * 4, 60));
    });

    test('is null when there is no purchase price to depreciate from', () {
      expect(
        CostCalculator.depreciationOver(
          vehicle(),
          range: DateRange.allTime(nowMs: _nowMs),
          defaultAnnualPercent: 12,
          nowMs: _nowMs,
        ),
        isNull,
      );
    });

    test('clamps at zero when the estimate exceeds the purchase price', () {
      // Almost always a typo, and a negative here would put true cost below
      // running cost, which reads as a bug.
      final d = CostCalculator.depreciationOver(
        vehicle(
          purchasePrice: 100000,
          currentValue: 150000,
          boughtDaysAgo: 365,
        ),
        range: DateRange.allTime(nowMs: _nowMs),
        defaultAnnualPercent: 12,
        nowMs: _nowMs,
      );
      expect(d!.isZero, isTrue);
    });

    test('a range entirely before ownership carries none of it', () {
      final beforePurchase = DateRange.custom(
        DateTime.utc(2020, 1, 1).millisecondsSinceEpoch,
        DateTime.utc(2020, 12, 31).millisecondsSinceEpoch,
      );
      final d = CostCalculator.depreciationOver(
        vehicle(purchasePrice: 180000, boughtDaysAgo: 365),
        range: beforePurchase,
        defaultAnnualPercent: 12,
        nowMs: _nowMs,
      );
      expect(d!.isZero, isTrue);
    });
  });

  group('the trip calculator', () {
    test('scales the period’s rates to a distance', () {
      // ৳3.00/km fuel, ৳41.00/km true. A 40 km delivery run:
      final r = report(
        bike: vehicle(
          purchasePrice: 180000,
          currentValue: 144000,
          boughtDaysAgo: 365,
        ),
        fuelEntries: [fuel(3000)],
        serviceLogs: [serviceLog(1000)],
        expenses: [expense(1000)],
      );

      final trip = CostCalculator.estimateTrip(
        report: r,
        distanceM: 40 * 1000,
        unit: DistanceUnit.km,
      )!;

      expect(trip.fuelCost.asMajor, closeTo(120, 0.01));
      expect(trip.trueCost!.asMajor, closeTo(1640, 1));
    });

    test('omits true cost when depreciation is unknown', () {
      final trip = CostCalculator.estimateTrip(
        report: report(fuelEntries: [fuel(3000)]),
        distanceM: 40 * 1000,
        unit: DistanceUnit.km,
      )!;
      expect(trip.fuelCost.asMajor, closeTo(120, 0.01));
      expect(trip.trueCost, isNull);
    });

    test('refuses a zero or negative distance', () {
      final r = report(fuelEntries: [fuel(3000)]);
      expect(
        CostCalculator.estimateTrip(
          report: r,
          distanceM: 0,
          unit: DistanceUnit.km,
        ),
        isNull,
      );
      expect(
        CostCalculator.estimateTrip(
          report: r,
          distanceM: -5,
          unit: DistanceUnit.km,
        ),
        isNull,
      );
    });

    test('cannot estimate without a rate to work from', () {
      final r = report(fuelEntries: [fuel(3000)], distanceKm: 0);
      expect(
        CostCalculator.estimateTrip(
          report: r,
          distanceM: 40000,
          unit: DistanceUnit.km,
        ),
        isNull,
      );
    });
  });

  group('date ranges', () {
    test('snap to local day boundaries', () {
      final month = DateRange.thisMonth(nowMs: _nowMs);
      expect(month.contains(_nowMs), isTrue);
      expect(month.contains(Dates.addDays(_nowMs, -40)), isFalse);
    });

    test('last three months covers this month and the two before', () {
      final r = DateRange.last3Months(nowMs: _nowMs);
      final june = DateTime.utc(2026, 6, 15).millisecondsSinceEpoch;
      final may = DateTime.utc(2026, 5, 15).millisecondsSinceEpoch;
      expect(r.contains(june), isTrue);
      expect(r.contains(may), isFalse);
    });

    test('all time reaches back past any plausible purchase', () {
      final r = DateRange.allTime(nowMs: _nowMs);
      expect(r.contains(DateTime.utc(1990).millisecondsSinceEpoch), isTrue);
    });

    test('intersect trims to the overlap', () {
      final year = DateRange.thisYear(nowMs: _nowMs);
      final overlap = year.intersect(
        DateTime.utc(2026, 6, 1).millisecondsSinceEpoch,
        _nowMs,
      );
      expect(overlap, isNotNull);
      expect(overlap!.fromMs, DateTime.utc(2026, 6, 1).millisecondsSinceEpoch);
      expect(
        year.intersect(
          DateTime.utc(2020).millisecondsSinceEpoch,
          DateTime.utc(2021).millisecondsSinceEpoch,
        ),
        isNull,
      );
    });
  });
}
