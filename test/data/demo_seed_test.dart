import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jatra/core/calc/mileage_calc.dart';
import 'package:jatra/core/utils/clock.dart';
import 'package:jatra/data/db/database.dart';
import 'package:jatra/data/db/demo_seed.dart';
import 'package:jatra/data/repositories/expense_repo.dart';
import 'package:jatra/data/repositories/fuel_repo.dart';
import 'package:jatra/data/repositories/ride_repo.dart';
import 'package:jatra/data/repositories/service_repo.dart';

/// The demo dataset is a fixture, so it is worth asserting on: if a change to
/// the mileage engine quietly alters what these 40 fills produce, this is
/// where it shows up.
void main() {
  late AppDatabase db;
  late int vehicleId;

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    Clock.freeze(DateTime.utc(2026, 8, 4, 12));
    vehicleId = await DemoSeed.seed(db);
  });

  tearDown(() async {
    Clock.freeze(null);
    await db.close();
  });

  test('produces the advertised shape of dataset', () async {
    final fuel = await FuelRepo(db).getForVehicle(vehicleId);
    final logs = await ServiceRepo(db).getLogs(vehicleId);
    final expenses = await ExpenseRepo(db).getForVehicle(vehicleId);

    expect(fuel, hasLength(40));
    expect(logs, hasLength(9));
    expect(expenses, hasLength(5));

    // Eight months of history, give or take a fill interval.
    final span = fuel.last.dateMs - fuel.first.dateMs;
    expect(Dates.daysBetween(0, span), inInclusiveRange(200, 260));
  });

  test('is deliberately messy, so the awkward cases are exercised', () async {
    final fuel = await FuelRepo(db).getForVehicle(vehicleId);

    expect(
      fuel.where((e) => !e.isFullTank),
      isNotEmpty,
      reason: 'partial fills must be present',
    );
    expect(
      fuel.where((e) => e.isMissedEntry),
      hasLength(1),
      reason: 'exactly one flagged gap',
    );
  });

  test('the odometer only ever moves forward', () async {
    final fuel = await FuelRepo(db).getForVehicle(vehicleId);
    for (var i = 1; i < fuel.length; i++) {
      expect(fuel[i].odometerM, greaterThan(fuel[i - 1].odometerM));
    }
  });

  test('mileage lands in a believable range for a 160cc commuter', () async {
    final report = MileageEngine.compute(
      await FuelRepo(db).getForVehicle(vehicleId),
    );

    expect(report.reliableWindows, isNotEmpty);
    expect(
      report.average(DistanceUnit.km, VolumeUnit.l),
      inInclusiveRange(35, 50),
    );

    for (final w in report.reliableWindows) {
      expect(w.economyKmPerLitre, inInclusiveRange(30, 55));
    }
  });

  test('one window is unreliable and stays out of the average', () async {
    final report = MileageEngine.compute(
      await FuelRepo(db).getForVehicle(vehicleId),
    );

    final unreliable = report.windows.where((w) => !w.isReliable);
    expect(unreliable, hasLength(1));
    expect(report.reliableWindows.length, report.windows.length - 1);
  });

  test('the tail of the data triggers the mileage drop alert', () async {
    // The seed deliberately drops the last few windows to ~37 km/L from a
    // baseline in the mid-forties, so the alert card has something real to
    // render at the default 12% threshold.
    final report = MileageEngine.compute(
      await FuelRepo(db).getForVehicle(vehicleId),
      dropThresholdPercent: 12,
    );

    expect(report.drop, isNotNull);
    expect(report.drop!.dropFraction, greaterThan(0.12));
    expect(report.drop!.latest, lessThan(report.drop!.baseline));
  });

  test('service items carry baselines from the logged services', () async {
    final items = await ServiceRepo(db).getItems(vehicleId);
    final oil = items.firstWhere((i) => i.name == 'Engine oil');

    // The most recent engine-oil log in the fixture.
    expect(oil.lastDoneOdometerM, 24800 * 1000);
    expect(oil.lastDoneDateMs, Dates.addDays(Clock.nowMs, -30));
  });

  test(
    'a document is left expiring soon, so countdowns have something to show',
    () async {
      final expiring = await ExpenseRepo(db).expiringDocuments(vehicleId);
      expect(expiring, isNotEmpty);
      expect(expiring.first.category, ExpenseCategory.insurance);
    },
  );

  // Rides exist so the map is reachable without going out and riding: it is
  // the only screen that shows a map, and tracking is Off by default.
  test('seeds rides with GPS paths so the map has something to draw', () async {
    final rides = await RideRepo(db).getForVehicle(vehicleId);
    expect(rides, hasLength(3));
    expect(
      rides.every((r) => r.isComplete && r.endTimeMs != null),
      isTrue,
      reason: 'an unfinished ride would trigger the crash-recovery prompt',
    );
    expect(rides.every((r) => r.distanceMeters > 0), isTrue);

    for (final ride in rides) {
      final points = await RideRepo(db).getPoints(ride.id);
      expect(points.length, 180, reason: 'RideMap needs a real path');
      expect(points.every((p) => p.lat > 23 && p.lat < 24), isTrue);
      expect(points.every((p) => p.lng > 90 && p.lng < 91), isTrue);
    }

    // One ride carries a deliberate recording gap, so the broken-polyline
    // path and the "1 GAP" badge are exercised by the fixture.
    final gapCounts = <int>[];
    for (final ride in rides) {
      final points = await RideRepo(db).getPoints(ride.id);
      gapCounts.add(points.where((p) => p.isGapStart).length);
    }
    expect(gapCounts.where((c) => c > 0), hasLength(1));
  });
}
