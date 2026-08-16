// Does a saved fill actually reach the lists?
//
// Home's "Recent fills" and the fuel history screen both read FuelController,
// never the repository. The repository is well covered already, so this walks
// the layer above it: insert a fill and assert the controller's observable
// list picks it up, in the order the UI shows.
//
// Plain `test()` on purpose — `testWidgets` runs under fake async, where the
// drift stream's timers never fire.
import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart' hide Value;

import 'package:jatra/core/utils/clock.dart';
import 'package:jatra/core/utils/money.dart';
import 'package:jatra/data/db/database.dart';
import 'package:jatra/data/repositories/fuel_repo.dart';
import 'package:jatra/data/repositories/vehicle_repo.dart';
import 'package:jatra/modules/fuel/fuel_controller.dart';
import 'package:jatra/modules/vehicles/vehicle_controller.dart';
import 'package:jatra/services/settings_service.dart';

void main() {
  late AppDatabase db;
  late FuelRepo fuel;
  late VehicleController vehicles;
  late FuelController controller;
  late int vehicleId;

  /// Lets the drift streams and the GetX workers settle.
  Future<void> settle() =>
      Future<void>.delayed(const Duration(milliseconds: 60));

  setUp(() async {
    Clock.freeze(DateTime.utc(2026, 8, 4, 12));
    db = AppDatabase.forTesting(NativeDatabase.memory());
    fuel = FuelRepo(db);

    // SettingsService is deliberately NOT init()ed: init() is what opens
    // get_storage and registers the `ever` writers, and none of the fields
    // used here need either. This keeps the test free of path_provider.
    final settings = SettingsService();

    vehicleId = await VehicleRepo(db).create(
      VehiclesCompanion.insert(
        name: 'Pulsar',
        createdAt: 0,
        updatedAt: 0,
        initialOdometerM: const Value(10000000), // 10,000 km
      ),
    );

    vehicles = Get.put(VehicleController(VehicleRepo(db), settings));
    await settle();
    controller = Get.put(FuelController(fuel, vehicles, settings));
    await settle();
  });

  tearDown(() async {
    Get.reset();
    Clock.freeze(null);
    await db.close();
  });

  Future<int> addFill({required double odometerKm, double litres = 10}) {
    final volumeMl = (litres * 1000).round();
    final total = Money.fromMajor(litres * 121.5);
    return fuel.create(
      FuelEntriesCompanion.insert(
        vehicleId: vehicleId,
        dateMs: Clock.nowMs,
        odometerM: (odometerKm * 1000).round(),
        volumeMl: volumeMl,
        pricePerUnitMinor: Money.fromMajor(121.5).minor,
        totalCostMinor: total.minor,
        createdAt: 0,
        updatedAt: 0,
      ),
    );
  }

  test('the controller binds to the active vehicle', () async {
    expect(vehicles.activeId, vehicleId);
    expect(controller.isReady.value, isTrue);
    expect(controller.entries, isEmpty);
  });

  test('a saved fill reaches the observable list', () async {
    await addFill(odometerKm: 10250);
    await settle();

    expect(
      controller.entries,
      hasLength(1),
      reason: 'the drift stream should push the new row into the controller',
    );
    expect(controller.entries.first.odometerM, 10250000);
  });

  test('the newest fill is first in the list the UI renders', () async {
    await addFill(odometerKm: 10250);
    await settle();
    await addFill(odometerKm: 10600);
    await settle();
    await addFill(odometerKm: 10950);
    await settle();

    expect(controller.entries, hasLength(3));
    // Home takes `newestFirst.take(4)`; the fill just added must lead it.
    expect(controller.newestFirst.first.odometerM, 10950000);
    expect(controller.monthGroups, isNotEmpty);
    expect(controller.monthGroups.first.entries.first.odometerM, 10950000);
  });

  // Documents a real trap rather than asserting an ideal: the list is
  // ordered by ODOMETER, not by date. `newestFirst` means "highest reading",
  // so a fill logged with a reading below one already recorded sinks to the
  // bottom — and Home only renders `newestFirst.take(4)`. To a user who
  // overrode the odometer warning, that reads as "I added fuel and it did
  // not show up".
  test(
    'a fill with a lower odometer sinks to the bottom of the list',
    () async {
      await addFill(odometerKm: 10250);
      await settle();
      await addFill(odometerKm: 90000); // a typo, or a replaced cluster
      await settle();
      await addFill(odometerKm: 10600); // the next real fill
      await settle();

      expect(controller.entries, hasLength(3));

      // The genuinely newest fill is NOT first.
      expect(controller.newestFirst.first.odometerM, 90000000);
      expect(controller.newestFirst.last.odometerM, 10250000);
      expect(controller.newestFirst[1].odometerM, 10600000);
    },
  );

  test('successive fills each appear without a rebind', () async {
    for (var i = 1; i <= 5; i++) {
      await addFill(odometerKm: 10000 + i * 300.0);
      await settle();
      expect(
        controller.entries,
        hasLength(i),
        reason: 'fill $i did not reach the list',
      );
    }
  });
}
