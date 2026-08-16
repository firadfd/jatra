// Drift and matcher both export `isNull`/`isNotNull`. In a test file the
// matcher versions are the ones we want; Drift is only here for `Value`.
import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jatra/core/utils/clock.dart';
import 'package:jatra/data/db/database.dart';
import 'package:jatra/data/models/default_service_items.dart';
import 'package:jatra/data/repositories/fuel_repo.dart';
import 'package:jatra/data/repositories/vehicle_repo.dart';

void main() {
  late AppDatabase db;
  late VehicleRepo repo;

  setUp(() {
    // In-memory database — the repositories are plain classes, so they can be
    // constructed directly with no GetX and no Flutter bindings.
    db = AppDatabase.forTesting(NativeDatabase.memory());
    repo = VehicleRepo(db);
    Clock.freeze(DateTime.utc(2026, 8, 4, 12));
  });

  tearDown(() async {
    Clock.freeze(null);
    await db.close();
  });

  VehiclesCompanion draft(String name, {int initialOdometerM = 0}) =>
      VehiclesCompanion.insert(
        name: name,
        createdAt: 0,
        updatedAt: 0,
        initialOdometerM: Value(initialOdometerM),
      );

  test('first vehicle becomes the default without being asked', () async {
    final id = await repo.create(draft('Pulsar'));
    final v = await repo.getById(id);
    expect(v!.isDefault, isTrue);
  });

  test('a new vehicle is seeded with the maintenance schedule', () async {
    final id = await repo.create(draft('Pulsar', initialOdometerM: 18420000));

    final items = await (db.select(
      db.serviceItems,
    )..where((s) => s.vehicleId.equals(id))).get();

    expect(items, hasLength(kDefaultServiceItems.length));

    final oil = items.firstWhere((i) => i.name == 'Engine oil');
    expect(oil.intervalM, 2000 * 1000);
    // Baseline is the bike's starting odometer, not null — otherwise every
    // item would read OVERDUE on day one.
    expect(oil.lastDoneOdometerM, 18420000);

    final brakeFluid = items.firstWhere((i) => i.name == 'Brake fluid');
    expect(brakeFluid.intervalM, isNull);
    expect(brakeFluid.intervalDays, 730);
  });

  test('setting a default clears the previous one', () async {
    final a = await repo.create(draft('Pulsar'));
    final b = await repo.create(draft('Discover'));

    expect((await repo.getById(a))!.isDefault, isTrue);
    expect((await repo.getById(b))!.isDefault, isFalse);

    await repo.setDefault(b);
    expect((await repo.getById(a))!.isDefault, isFalse);
    expect((await repo.getById(b))!.isDefault, isTrue);
  });

  test('deletion counts name what will go', () async {
    final id = await repo.create(draft('Pulsar'));
    final fuel = FuelRepo(db);

    for (var i = 1; i <= 3; i++) {
      await fuel.create(
        FuelEntriesCompanion.insert(
          vehicleId: id,
          dateMs: Clock.nowMs,
          odometerM: 1000 * i,
          volumeMl: 6000,
          pricePerUnitMinor: 12150,
          totalCostMinor: 72900,
          createdAt: 0,
          updatedAt: 0,
        ),
      );
    }

    final counts = await repo.deletionCounts(id);
    expect(counts.fuelEntries, 3);
    expect(counts.serviceItems, kDefaultServiceItems.length);
    expect(counts.describe(), contains('3 fuel entries'));
  });

  test('deleting a vehicle cascades to its records', () async {
    final id = await repo.create(draft('Pulsar'));
    final fuel = FuelRepo(db);
    await fuel.create(
      FuelEntriesCompanion.insert(
        vehicleId: id,
        dateMs: Clock.nowMs,
        odometerM: 5000,
        volumeMl: 6000,
        pricePerUnitMinor: 12150,
        totalCostMinor: 72900,
        createdAt: 0,
        updatedAt: 0,
      ),
    );

    await repo.softDelete(id);

    expect(await repo.getById(id), isNull);
    expect(await fuel.getForVehicle(id), isEmpty);

    // Soft, not hard: the tombstone survives so an import can tell "deleted"
    // apart from "never existed".
    final raw = await (db.select(
      db.vehicles,
    )..where((v) => v.id.equals(id))).getSingle();
    expect(raw.deletedAt, isNotNull);
  });

  test('deleting the default promotes another vehicle', () async {
    final a = await repo.create(draft('Pulsar'));
    final b = await repo.create(draft('Discover'));

    await repo.softDelete(a);
    expect((await repo.getById(b))!.isDefault, isTrue);
  });

  test('archiving hides a bike from the switcher but keeps it', () async {
    final a = await repo.create(draft('Pulsar'));
    await repo.create(draft('Discover'));

    await repo.setArchived(a, true);

    final active = await repo.getAll();
    expect(active.map((v) => v.name), ['Discover']);
    expect(await repo.getAll(includeArchived: true), hasLength(2));
  });

  test('latest odometer falls back to the vehicle starting reading', () async {
    final id = await repo.create(draft('Pulsar', initialOdometerM: 18420000));
    final fuel = FuelRepo(db);

    expect(await fuel.latestOdometerM(id), 18420000);

    await fuel.create(
      FuelEntriesCompanion.insert(
        vehicleId: id,
        dateMs: Clock.nowMs,
        odometerM: 18700000,
        volumeMl: 6000,
        pricePerUnitMinor: 12150,
        totalCostMinor: 72900,
        createdAt: 0,
        updatedAt: 0,
      ),
    );

    expect(await fuel.latestOdometerM(id), 18700000);
  });
}
