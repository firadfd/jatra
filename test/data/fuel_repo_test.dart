import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jatra/core/calc/mileage_calc.dart';
import 'package:jatra/core/utils/clock.dart';
import 'package:jatra/core/utils/money.dart';
import 'package:jatra/data/db/database.dart';
import 'package:jatra/data/repositories/fuel_repo.dart';
import 'package:jatra/data/repositories/vehicle_repo.dart';

void main() {
  late AppDatabase db;
  late FuelRepo fuel;
  late int vehicleId;

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    fuel = FuelRepo(db);
    Clock.freeze(DateTime.utc(2026, 8, 4, 12));
    vehicleId = await VehicleRepo(db).create(
      VehiclesCompanion.insert(
        name: 'Pulsar',
        createdAt: 0,
        updatedAt: 0,
        initialOdometerM: const Value(10000000), // 10,000 km
      ),
    );
  });

  tearDown(() async {
    Clock.freeze(null);
    await db.close();
  });

  Future<int> addFill({
    required double odometerKm,
    required double litres,
    bool isFullTank = true,
    double pricePerLitre = 121.50,
    int dayOffset = 0,
  }) {
    final volumeMl = (litres * 1000).round();
    final price = Money.fromMajor(pricePerLitre);
    return fuel.create(
      FuelEntriesCompanion.insert(
        vehicleId: vehicleId,
        dateMs: Dates.addDays(Clock.nowMs, dayOffset),
        odometerM: (odometerKm * 1000).round(),
        volumeMl: volumeMl,
        pricePerUnitMinor: price.minor,
        totalCostMinor: Money.fromVolume(
          ml: volumeMl,
          pricePerLitre: price,
        ).minor,
        createdAt: 0,
        updatedAt: 0,
        isFullTank: Value(isFullTank),
      ),
    );
  }

  test(
    'entries come back in odometer order, whatever order they went in',
    () async {
      await addFill(odometerKm: 10860, litres: 10, dayOffset: -6);
      await addFill(odometerKm: 10000, litres: 8, dayOffset: -18);
      await addFill(odometerKm: 10440, litres: 10, dayOffset: -12);

      final rows = await fuel.getForVehicle(vehicleId);
      expect(rows.map((e) => e.odometerM), [10000000, 10440000, 10860000]);
    },
  );

  test('the engine reads the repository output without resorting', () async {
    await addFill(odometerKm: 10000, litres: 8, dayOffset: -18);
    await addFill(
      odometerKm: 10180,
      litres: 4,
      isFullTank: false,
      dayOffset: -14,
    );
    await addFill(odometerKm: 10440, litres: 6, dayOffset: -12);
    await addFill(odometerKm: 10860, litres: 10, dayOffset: -6);

    final report = MileageEngine.compute(await fuel.getForVehicle(vehicleId));

    expect(report.windows, hasLength(2));
    // 440 km on 4 + 6 L.
    expect(report.windows[0].economyKmPerLitre, closeTo(44.0, 1e-9));
    // 420 km on 10 L.
    expect(report.windows[1].economyKmPerLitre, closeTo(42.0, 1e-9));
  });

  test(
    'a soft-deleted fill leaves the mileage window it was part of',
    () async {
      await addFill(odometerKm: 10000, litres: 8, dayOffset: -18);
      final partial = await addFill(
        odometerKm: 10180,
        litres: 4,
        isFullTank: false,
        dayOffset: -14,
      );
      await addFill(odometerKm: 10440, litres: 6, dayOffset: -12);

      var report = MileageEngine.compute(await fuel.getForVehicle(vehicleId));
      expect(report.windows.single.volumeMl, 10000);

      // Removing the partial top-up leaves 440 km on 6 L — the figure has to
      // move, because the fuel genuinely is not accounted for any more.
      await fuel.softDelete(partial);
      report = MileageEngine.compute(await fuel.getForVehicle(vehicleId));
      expect(report.windows.single.volumeMl, 6000);
      expect(report.windows.single.economyKmPerLitre, closeTo(73.33, 0.01));

      // Undo puts it back exactly.
      await fuel.restore(partial);
      report = MileageEngine.compute(await fuel.getForVehicle(vehicleId));
      expect(report.windows.single.volumeMl, 10000);
      expect(report.windows.single.economyKmPerLitre, closeTo(44.0, 1e-9));
    },
  );

  test('latest entry by date drives the price pre-fill', () async {
    await addFill(
      odometerKm: 10000,
      litres: 8,
      pricePerLitre: 118,
      dayOffset: -18,
    );
    await addFill(
      odometerKm: 10440,
      litres: 10,
      pricePerLitre: 124.75,
      dayOffset: -6,
    );

    final last = await fuel.latestEntry(vehicleId);
    expect(last!.pricePerUnitMinor, 12475);
  });

  test('money totals stay exact across 200 fills', () async {
    // The acceptance criterion, exercised end to end through SQLite rather
    // than only in the value type.
    var odometer = 10000.0;
    for (var i = 0; i < 200; i++) {
      odometer += 300;
      await addFill(
        odometerKm: odometer,
        litres: 6.83,
        pricePerLitre: 121.50,
        dayOffset: -600 + i * 3,
      );
    }

    final rows = await fuel.getForVehicle(vehicleId);
    final total = rows.fold(
      Money.zero,
      (sum, e) => sum + Money(e.totalCostMinor),
    );

    // 6830 ml at 121.50/L = 829.845 → rounds to 829.85 per fill, ×200.
    expect(total.minor, 200 * 82985);
    expect(total.asMajor, 165970.0);
  });

  test('odometer observations span fuel entries and service logs', () async {
    await addFill(odometerKm: 10440, litres: 10, dayOffset: -12);

    await db
        .into(db.serviceLogs)
        .insert(
          ServiceLogsCompanion.insert(
            vehicleId: vehicleId,
            name: 'Engine oil',
            dateMs: Dates.addDays(Clock.nowMs, -3),
            odometerM: 10900000,
            createdAt: 0,
            updatedAt: 0,
          ),
        );

    expect(await fuel.latestOdometerM(vehicleId), 10900000);

    final observations = await fuel.odometerObservations(vehicleId);
    expect(observations.map((o) => o.odometerM), [10440000, 10900000]);
  });
}
