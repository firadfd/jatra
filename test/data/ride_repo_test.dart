import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jatra/core/utils/clock.dart';
import 'package:jatra/core/utils/geo_utils.dart';
import 'package:jatra/data/db/database.dart';
import 'package:jatra/data/repositories/fuel_repo.dart';
import 'package:jatra/data/repositories/ride_repo.dart';
import 'package:jatra/data/repositories/vehicle_repo.dart';

/// Exercises the storage side of ride recording: points landing immediately,
/// interrupted rides being findable, and gaps surviving a round trip.
void main() {
  late AppDatabase db;
  late RideRepo rides;
  late int vehicleId;

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    rides = RideRepo(db);
    Clock.freeze(DateTime.utc(2026, 8, 4, 12));
    vehicleId = await VehicleRepo(db).create(
      VehiclesCompanion.insert(
        name: 'Pulsar',
        createdAt: 0,
        updatedAt: 0,
        initialOdometerM: const Value(20000000),
      ),
    );
  });

  tearDown(() async {
    Clock.freeze(null);
    await db.close();
  });

  Future<int> startRide() => rides.create(
    RidesCompanion.insert(
      vehicleId: vehicleId,
      startTimeMs: Clock.nowMs,
      createdAt: 0,
      updatedAt: 0,
      startOdometerM: const Value(20000000),
    ),
  );

  Future<void> addPoint(
    int rideId, {
    required double lat,
    required double lng,
    required int seconds,
    bool gap = false,
  }) {
    return rides.addPoint(
      RidePointsCompanion.insert(
        rideId: rideId,
        lat: lat,
        lng: lng,
        timestampMs: Clock.nowMs + seconds * 1000,
        isGapStart: Value(gap),
      ),
    );
  }

  test('an unfinished ride is findable after a restart', () async {
    final id = await startRide();
    await addPoint(id, lat: 23.81, lng: 90.41, seconds: 0);

    // Nothing set an end time — the process died mid-ride.
    final interrupted = await rides.findInterrupted();
    expect(interrupted, isNotNull);
    expect(interrupted!.id, id);
    expect(interrupted.endTimeMs, isNull);
  });

  test('a finished ride is not offered for recovery', () async {
    final id = await startRide();
    await rides.update(
      id,
      RidesCompanion(
        endTimeMs: Value(Clock.nowMs + 600000),
        isComplete: const Value(true),
      ),
    );
    expect(await rides.findInterrupted(), isNull);
  });

  test(
    'points come back in time order regardless of insertion order',
    () async {
      final id = await startRide();
      await addPoint(id, lat: 23.83, lng: 90.41, seconds: 20);
      await addPoint(id, lat: 23.81, lng: 90.41, seconds: 0);
      await addPoint(id, lat: 23.82, lng: 90.41, seconds: 10);

      final points = await rides.getPoints(id);
      expect(points.map((p) => p.timestampMs), [
        Clock.nowMs,
        Clock.nowMs + 10000,
        Clock.nowMs + 20000,
      ]);
    },
  );

  test('gap markers survive the round trip', () async {
    final id = await startRide();
    await addPoint(id, lat: 23.81, lng: 90.41, seconds: 0);
    await addPoint(id, lat: 23.82, lng: 90.41, seconds: 10);
    // The app was backgrounded here.
    await addPoint(id, lat: 23.90, lng: 90.45, seconds: 800, gap: true);

    final points = await rides.getPoints(id);
    expect(points.where((p) => p.isGapStart), hasLength(1));
    expect(points.last.isGapStart, isTrue);
  });

  test('the last point is what a resume measures from', () async {
    final id = await startRide();
    await addPoint(id, lat: 23.81, lng: 90.41, seconds: 0);
    await addPoint(id, lat: 23.82, lng: 90.41, seconds: 30);

    final last = await rides.lastPoint(id);
    expect(last!.lat, 23.82);
    expect(await rides.pointCount(id), 2);
  });

  test('discarding a ride takes its points with it', () async {
    final id = await startRide();
    for (var i = 0; i < 5; i++) {
      await addPoint(id, lat: 23.81 + i * 0.001, lng: 90.41, seconds: i * 10);
    }
    expect(await rides.pointCount(id), 5);

    await rides.hardDelete(id);
    expect(await rides.getById(id), isNull);
    expect(await rides.pointCount(id), 0);
  });

  test('deleting location history keeps the ride summaries', () async {
    final id = await startRide();
    for (var i = 0; i < 10; i++) {
      await addPoint(id, lat: 23.81 + i * 0.001, lng: 90.41, seconds: i * 10);
    }
    await rides.update(
      id,
      RidesCompanion(
        endTimeMs: Value(Clock.nowMs + 600000),
        distanceMeters: const Value(12400),
        isComplete: const Value(true),
      ),
    );

    final removed = await rides.deleteAllLocationHistory();
    expect(removed, 10);

    // The path is gone; the numbers statistics depend on are not.
    expect(await rides.pointCount(id), 0);
    final ride = await rides.getById(id);
    expect(ride!.distanceMeters, 12400);
  });

  test('a completed ride advances the odometer history', () async {
    // Rides are odometer observations too, so service prediction sees them.
    final id = await startRide();
    await rides.update(
      id,
      RidesCompanion(
        endTimeMs: Value(Clock.nowMs + 600000),
        distanceMeters: const Value(15000),
        endOdometerM: const Value(20015000),
        isComplete: const Value(true),
      ),
    );

    final fuel = FuelRepo(db);
    expect(await fuel.latestOdometerM(vehicleId), 20015000);

    final observations = await fuel.odometerObservations(vehicleId);
    expect(observations.map((o) => o.odometerM), contains(20015000));
  });

  test(
    'a soft-deleted ride leaves the history list but keeps its points',
    () async {
      final id = await startRide();
      await addPoint(id, lat: 23.81, lng: 90.41, seconds: 0);
      await rides.update(
        id,
        RidesCompanion(endTimeMs: Value(Clock.nowMs + 1000)),
      );

      await rides.softDelete(id);
      expect(await rides.getForVehicle(vehicleId), isEmpty);
      // Points are not tombstoned — the ride above them is, which is enough.
      expect(await rides.pointCount(id), 1);
    },
  );

  group('distance accumulation', () {
    test('matches the filtered sum of the path', () async {
      // A straight 500 m run sampled every 50 m, plus jitter that the filter
      // must throw away.
      const startLat = 23.81;
      var previous = GeoPoint(
        lat: startLat,
        lng: 90.41,
        timestampMs: Clock.nowMs,
        accuracy: 5,
      );

      var total = 0.0;
      for (var i = 1; i <= 10; i++) {
        // Real movement.
        final moved = GeoPoint(
          lat: startLat + (i * 50) / 111320.0,
          lng: 90.41,
          timestampMs: Clock.nowMs + i * 5000,
          accuracy: 5,
        );
        final result = GpsFilter.test(moved, previous);
        expect(result.isAccepted, isTrue);
        total += result.distanceFromPreviousM;
        previous = moved;

        // Jitter one second later, which must not count.
        final jitter = GeoPoint(
          lat: moved.lat + 2 / 111320.0,
          lng: moved.lng,
          timestampMs: moved.timestampMs + 1000,
          accuracy: 5,
        );
        expect(GpsFilter.test(jitter, previous).isAccepted, isFalse);
      }

      expect(total, closeTo(500, 5));
    });
  });
}
