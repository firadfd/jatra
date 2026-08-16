import 'dart:math';

import 'package:drift/drift.dart';

import '../../core/utils/clock.dart';
import '../../core/utils/money.dart';
import '../../services/settings_service.dart';
import '../repositories/vehicle_repo.dart';
import 'database.dart';

/// A realistic demo dataset, behind `--dart-define=SEED_DEMO=true`.
///
/// One bike, 40 fuel entries across eight months, a handful of services and
/// the fixed costs a rider in Dhaka actually pays. Deliberately *not* clean
/// data — it includes partial fills, a missed entry and a tank where mileage
/// falls off a cliff, because those are the cases the app has to handle
/// correctly and the ones a screenshot of tidy data would hide.
///
/// Everything is generated from a fixed random seed, so every run produces
/// byte-identical data and a figure you hand-check once stays checkable.
abstract final class DemoSeed {
  /// Litres per 100 entries of jitter, roughly. Fixed seed ⇒ reproducible.
  static const _seed = 20260804;

  /// Bajaj Pulsar NS160 — a common commuter in this market.
  static const _startOdometerKm = 18420;
  static const _tankCapacityL = 12.0;

  /// Runs only when the database is empty, so a seeded install can be used
  /// normally afterwards without data multiplying on every launch.
  static Future<void> ensureSeeded(
    AppDatabase db,
    SettingsService settings,
  ) async {
    final existing = await db.managers.vehicles.count();
    if (existing > 0) return;

    final vehicleId = await seed(db);

    settings.setActiveVehicle(vehicleId);
    settings.onboardingComplete.value = true;

    // Home hides the Rides section entirely while tracking is Off, and Rides
    // is the only route to the map. Seeding paths without this leaves them
    // unreachable. Nothing is requested by flipping this — the permission
    // prompt only ever fires from the tracking control in Settings — so the
    // demo build can show the map while a real install still starts Off.
    settings.trackingMode.value = TrackingMode.appOpen;
  }

  /// Writes the dataset and returns the vehicle id.
  ///
  /// Kept free of [SettingsService] so tests can assert on what this data
  /// actually produces — the mileage figures, the drop alert, the service
  /// statuses — without needing Flutter bindings or `get_storage`.
  static Future<int> seed(AppDatabase db) async {
    final vehicleId = await _seedVehicle(db);
    await _seedFuel(db, vehicleId);
    await _seedServices(db, vehicleId);
    await _seedExpenses(db, vehicleId);
    await _seedRides(db, vehicleId);
    return vehicleId;
  }

  static Future<int> _seedVehicle(AppDatabase db) async {
    final repo = VehicleRepo(db);
    final now = Clock.nowMs;

    return repo.create(
      VehiclesCompanion.insert(
        name: 'Pulsar',
        createdAt: now,
        updatedAt: now,
        make: const Value('Bajaj'),
        model: const Value('NS160'),
        year: const Value(2022),
        engineCc: const Value(160),
        registrationNo: const Value('DHAKA METRO-L 12-3456'),
        fuelType: const Value(FuelType.octane),
        purchaseDateMs: Value(Dates.addDays(now, -3 * 365)),
        purchasePriceMinor: Value(Money.fromMajor(185000).minor),
        currentValueEstimateMinor: Value(Money.fromMajor(122000).minor),
        initialOdometerM: const Value(_startOdometerKm * 1000),
        tankCapacityMl: Value((_tankCapacityL * 1000).round()),
        currency: const Value('BDT'),
        isDefault: const Value(true),
        colorTag: const Value(1),
      ),
    );
  }

  /// 40 fills over eight months.
  ///
  /// Fills are grouped into full-tank windows. Within a window the economy is
  /// held constant, so `window distance ÷ window volume` reproduces it
  /// exactly — which is what makes this dataset usable for verifying the
  /// mileage engine by hand.
  static Future<void> _seedFuel(AppDatabase db, int vehicleId) async {
    final rng = Random(_seed);
    final now = Clock.nowMs;

    var odometerM = _startOdometerKm * 1000;
    var dateMs = Dates.addDays(now, -243); // ~8 months
    var pricePerLitre = Money.fromMajor(121.50);

    final rows = <FuelEntriesCompanion>[];
    var window = 0;

    while (rows.length < 40) {
      window++;

      // Typical 42–47 km/L for this bike, drifting slowly…
      var economy = 44.0 + rng.nextDouble() * 3 - 1.5;

      // …except right at the end, where something goes wrong. A clogged air
      // filter and soft tyres, in the story this data tells.
      //
      // Only the final couple of tanks degrade, and sharply. A gradual slide
      // would drag the rolling median down with it and the alert would never
      // fire — which is correct behaviour from the engine, but useless as a
      // fixture for looking at the alert card.
      final isLate = rows.length >= 37;
      if (isLate) economy = 36.5 + rng.nextDouble();

      // Every third window includes a partial top-up before the full tank,
      // which must be accumulated into the window rather than measured
      // on its own.
      final legs = window % 3 == 0 ? 2 : 1;

      for (var leg = 0; leg < legs && rows.length < 40; leg++) {
        final isFullTank = leg == legs - 1;

        // A full leg covers most of a tank; a partial top-up covers less.
        final legKm = isFullTank
            ? 230 + rng.nextInt(90).toDouble()
            : 90 + rng.nextInt(50).toDouble();

        final litres = legKm / economy;
        final volumeMl = (litres * 1000).round();

        odometerM += (legKm * 1000).round();
        dateMs = Dates.addDays(dateMs, 4 + rng.nextInt(5));

        // Octane crept up over the period, with a little pump-to-pump noise.
        pricePerLitre = Money(
          (pricePerLitre.minor + 12 + rng.nextInt(25) - 8).clamp(11000, 14500),
        );

        // One deliberately flagged gap: the rider knows they forgot to log a
        // fill somewhere before this one, which poisons the whole window.
        final isMissed = rows.length == 17;

        rows.add(
          FuelEntriesCompanion.insert(
            vehicleId: vehicleId,
            dateMs: dateMs,
            odometerM: odometerM,
            volumeMl: volumeMl,
            pricePerUnitMinor: pricePerLitre.minor,
            totalCostMinor: Money.fromVolume(
              ml: volumeMl,
              pricePerLitre: pricePerLitre,
            ).minor,
            createdAt: dateMs,
            updatedAt: dateMs,
            isFullTank: Value(isFullTank),
            isMissedEntry: Value(isMissed),
            station: Value(_stations[rng.nextInt(_stations.length)]),
          ),
        );
      }
    }

    await db.batch((b) => b.insertAll(db.fuelEntries, rows));
  }

  static const _stations = [
    'Meghna Petrol Pump',
    'Padma Filling Station',
    'Jamuna Fuel',
    'City Filling Station',
  ];

  /// A handful of services across the same period, logged against the seeded
  /// recurring items so their baselines and next-due points are realistic.
  static Future<void> _seedServices(AppDatabase db, int vehicleId) async {
    final now = Clock.nowMs;
    final items = await (db.select(
      db.serviceItems,
    )..where((s) => s.vehicleId.equals(vehicleId))).get();

    int? itemFor(String name) =>
        items.where((i) => i.name == name).firstOrNull?.id;

    final logs =
        <
          ({
            String name,
            int daysAgo,
            int odometerKm,
            double parts,
            double labor,
          })
        >[
          (
            name: 'Engine oil',
            daysAgo: 232,
            odometerKm: 18600,
            parts: 850,
            labor: 150,
          ),
          (
            name: 'Chain lube',
            daysAgo: 210,
            odometerKm: 19100,
            parts: 220,
            labor: 0,
          ),
          (
            name: 'Engine oil',
            daysAgo: 168,
            odometerKm: 20650,
            parts: 880,
            labor: 150,
          ),
          (
            name: 'Air filter clean',
            daysAgo: 160,
            odometerKm: 20900,
            parts: 0,
            labor: 200,
          ),
          (
            name: 'Full service',
            daysAgo: 120,
            odometerKm: 22150,
            parts: 1400,
            labor: 900,
          ),
          (
            name: 'Engine oil',
            daysAgo: 96,
            odometerKm: 22700,
            parts: 880,
            labor: 150,
          ),
          (
            name: 'Chain adjust',
            daysAgo: 74,
            odometerKm: 23400,
            parts: 0,
            labor: 250,
          ),
          (
            name: 'Brake pads (front)',
            daysAgo: 52,
            odometerKm: 24050,
            parts: 1100,
            labor: 300,
          ),
          (
            name: 'Engine oil',
            daysAgo: 30,
            odometerKm: 24800,
            parts: 900,
            labor: 150,
          ),
        ];

    final repoRows = <ServiceLogsCompanion>[];
    for (final log in logs) {
      final dateMs = Dates.addDays(now, -log.daysAgo);
      final parts = Money.fromMajor(log.parts);
      final labor = Money.fromMajor(log.labor);
      repoRows.add(
        ServiceLogsCompanion.insert(
          vehicleId: vehicleId,
          name: log.name,
          dateMs: dateMs,
          odometerM: log.odometerKm * 1000,
          createdAt: dateMs,
          updatedAt: dateMs,
          serviceItemId: Value(itemFor(log.name)),
          partsCostMinor: Value(parts.minor),
          laborCostMinor: Value(labor.minor),
          totalCostMinor: Value((parts + labor).minor),
          workshop: const Value('Rahman Motors, Mirpur'),
        ),
      );
    }
    await db.batch((b) => b.insertAll(db.serviceLogs, repoRows));

    // Bring each item's baseline in line with its most recent log, the same
    // way `ServiceRepo.createLog` would have.
    for (final item in items) {
      final latest = logs.where((l) => l.name == item.name).lastOrNull;
      if (latest == null) continue;
      await (db.update(
        db.serviceItems,
      )..where((s) => s.id.equals(item.id))).write(
        ServiceItemsCompanion(
          lastDoneOdometerM: Value(latest.odometerKm * 1000),
          lastDoneDateMs: Value(Dates.addDays(now, -latest.daysAgo)),
          updatedAt: Value(now),
        ),
      );
    }
  }

  static Future<void> _seedExpenses(AppDatabase db, int vehicleId) async {
    final now = Clock.nowMs;

    final rows = <ExpensesCompanion>[
      // Insurance, expiring soon enough to show a countdown.
      ExpensesCompanion.insert(
        vehicleId: vehicleId,
        category: ExpenseCategory.insurance,
        dateMs: Dates.addDays(now, -335),
        amountMinor: Money.fromMajor(1450).minor,
        createdAt: Dates.addDays(now, -335),
        updatedAt: Dates.addDays(now, -335),
        validFromMs: Value(Dates.addDays(now, -335)),
        validUntilMs: Value(Dates.addDays(now, 30)),
      ),
      ExpensesCompanion.insert(
        vehicleId: vehicleId,
        category: ExpenseCategory.taxToken,
        dateMs: Dates.addDays(now, -300),
        amountMinor: Money.fromMajor(2800).minor,
        createdAt: Dates.addDays(now, -300),
        updatedAt: Dates.addDays(now, -300),
        validFromMs: Value(Dates.addDays(now, -300)),
        validUntilMs: Value(Dates.addDays(now, 65)),
      ),
      ExpensesCompanion.insert(
        vehicleId: vehicleId,
        category: ExpenseCategory.accessories,
        dateMs: Dates.addDays(now, -190),
        amountMinor: Money.fromMajor(3200).minor,
        createdAt: Dates.addDays(now, -190),
        updatedAt: Dates.addDays(now, -190),
        notes: const Value('Phone mount and USB charger'),
      ),
      ExpensesCompanion.insert(
        vehicleId: vehicleId,
        category: ExpenseCategory.fine,
        dateMs: Dates.addDays(now, -88),
        amountMinor: Money.fromMajor(500).minor,
        createdAt: Dates.addDays(now, -88),
        updatedAt: Dates.addDays(now, -88),
        notes: const Value('Wrong lane, Gulshan 1'),
      ),
      ExpensesCompanion.insert(
        vehicleId: vehicleId,
        category: ExpenseCategory.washing,
        dateMs: Dates.addDays(now, -21),
        amountMinor: Money.fromMajor(120).minor,
        createdAt: Dates.addDays(now, -21),
        updatedAt: Dates.addDays(now, -21),
      ),
    ];

    await db.batch((b) => b.insertAll(db.expenses, rows));
  }

  /// Three recorded rides with real GPS paths.
  ///
  /// Without these the map is unreachable: rides are the only screen that
  /// shows one, tracking is Off by default, and recording a real ride means
  /// physically moving far enough to clear [GpsFilter.minMoveMetres]. Seeding
  /// paths makes the map inspectable in a simulator in one command.
  ///
  /// Routes are plausible Dhaka commutes. The middle ride carries a
  /// deliberate recording gap so the broken-polyline rendering and the "1
  /// GAP" badge are exercised rather than assumed.
  static Future<void> _seedRides(AppDatabase db, int vehicleId) async {
    final now = Clock.nowMs;
    final random = Random(_seed);

    // (start lat, start lng, bearing-ish step per sample, label)
    const routes =
        <({double lat, double lng, double dLat, double dLng, String title})>[
          (
            lat: 23.7806,
            lng: 90.4193,
            dLat: 0.00042,
            dLng: 0.00031,
            title: 'Morning commute',
          ),
          (
            lat: 23.8103,
            lng: 90.4125,
            dLat: -0.00036,
            dLng: 0.00044,
            title: 'Ride home',
          ),
          (
            lat: 23.7461,
            lng: 90.3742,
            dLat: 0.00051,
            dLng: -0.00022,
            title: 'Weekend run',
          ),
        ];

    for (var r = 0; r < routes.length; r++) {
      final route = routes[r];
      final startMs = Dates.addDays(now, -(3 + r * 6));
      // ~180 samples at 5 s apart: a 15-minute ride, which is what the
      // simplifier and the elevation profile are tuned for.
      const sampleCount = 180;
      const stepMs = 5000;

      // A gap in the middle ride only.
      final gapAt = r == 1 ? sampleCount ~/ 2 : -1;

      final points = <RidePointsCompanion>[];
      var distanceM = 0.0;
      var maxSpeed = 0.0;
      var lat = route.lat;
      var lng = route.lng;

      for (var i = 0; i < sampleCount; i++) {
        // Wander the heading a little so the path reads as a road rather
        // than a ruled line.
        final wobble = (random.nextDouble() - 0.5) * 0.00018;
        lat += route.dLat + wobble;
        lng += route.dLng + wobble;

        final speed = 6 + random.nextDouble() * 9; // 21–54 km/h
        if (speed > maxSpeed) maxSpeed = speed;
        if (i > 0) distanceM += speed * (stepMs / 1000);

        points.add(
          RidePointsCompanion.insert(
            rideId: 0, // replaced below, once the ride id exists
            lat: lat,
            lng: lng,
            timestampMs: startMs + i * stepMs,
            speed: Value(speed),
            accuracy: Value(6 + random.nextDouble() * 8),
            altitude: Value(4 + random.nextDouble() * 9),
            isGapStart: Value(i == gapAt),
          ),
        );
      }

      final totalSeconds = (sampleCount - 1) * stepMs ~/ 1000;
      final movingSeconds = (totalSeconds * 0.86).round();

      final rideId = await db
          .into(db.rides)
          .insert(
            RidesCompanion.insert(
              vehicleId: vehicleId,
              startTimeMs: startMs,
              createdAt: startMs,
              updatedAt: startMs,
              endTimeMs: Value(startMs + totalSeconds * 1000),
              distanceMeters: Value(distanceM.round()),
              movingSeconds: Value(movingSeconds),
              totalSeconds: Value(totalSeconds),
              avgSpeed: Value(distanceM / movingSeconds),
              maxSpeed: Value(maxSpeed),
              title: Value(route.title),
              isComplete: const Value(true),
            ),
          );

      await db.batch(
        (b) => b.insertAll(db.ridePoints, [
          for (final p in points) p.copyWith(rideId: Value(rideId)),
        ]),
      );
    }
  }
}
