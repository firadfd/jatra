// Drives the real Route tab: pick a start and end, then correct the route.
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart' hide Value;

import 'package:jatra/app/theme/app_theme.dart';
import 'package:jatra/data/db/database.dart';
import 'package:jatra/data/repositories/vehicle_repo.dart';
import 'package:jatra/l10n/app_localizations.dart';
import 'package:jatra/modules/route_planner/route_planner_controller.dart';
import 'package:jatra/modules/route_planner/route_planner_view.dart';
import 'package:jatra/modules/vehicles/vehicle_controller.dart';
import 'package:jatra/services/district_map.dart';
import 'package:jatra/services/export_service.dart';
import 'package:jatra/services/place_network.dart';
import 'package:jatra/data/repositories/backup_repo.dart';
import 'package:jatra/services/settings_service.dart';

void main() {
  late AppDatabase db;
  late RoutePlannerController controller;
  late VehicleController vehicles;
  late SettingsService settings;

  // Loaded on real time and cached: the isolate behind it never finishes
  // under the fake clock `testWidgets` runs on.
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    await DistrictMap.load();
    await PlaceNetwork.load();
  });

  Future<void> open(WidgetTester tester) async {
    tester.view.physicalSize = const Size(600, 2600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    db = AppDatabase.forTesting(NativeDatabase.memory());
    settings = SettingsService();
    vehicles = VehicleController(VehicleRepo(db), settings);
    controller = Get.put(
      RoutePlannerController(vehicles, settings, ExportService(BackupRepo(db))),
    );

    await tester.pumpWidget(
      GetMaterialApp(
        theme: AppTheme.dark,
        localizationsDelegates: L.localizationsDelegates,
        supportedLocales: L.supportedLocales,
        home: const RoutePlannerView(),
      ),
    );
    await tester.pump();
    await tester.pump();
  }

  tearDown(() async {
    Get.reset();
    await db.close();
  });

  List<String> stops() => [
    for (final p in controller.route.value!.waypoints) p.id,
  ];

  testWidgets('the suggested route can be corrected by hand', (tester) async {
    await open(tester);

    controller
      ..setStart('kurigram.kurigram-sadar')
      ..setEnd('dhaka.dhaka-city');
    await tester.pump();
    expect(tester.takeException(), isNull);
    expect(find.byType(ReorderableListView), findsOneWidget);

    final suggested = controller.route.value!.estimatedM;
    controller.addStop('bandarban.bandarban-sadar');
    await tester.pump();
    expect(tester.takeException(), isNull);
    expect(stops(), contains('bandarban.bandarban-sadar'));
    expect(controller.isCustomRoute.value, isTrue);
    expect(controller.distanceM, greaterThan(suggested));

    controller.removeStop('bandarban.bandarban-sadar');
    await tester.pump();
    expect(stops(), isNot(contains('bandarban.bandarban-sadar')));

    controller.addStop('bandarban.bandarban-sadar');
    controller.resetRoute();
    await tester.pump();
    expect(stops(), isNot(contains('bandarban.bandarban-sadar')));
    expect(controller.isCustomRoute.value, isFalse);
  });

  testWidgets('a start district can be found by searching', (tester) async {
    await open(tester);

    await tester.tap(find.text('Start district or upazila'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).last, 'kuri');
    await tester.pumpAndSettle();
    expect(find.widgetWithText(ListTile, 'Kurigram Sadar'), findsOneWidget);
    expect(find.widgetWithText(ListTile, 'Dhaka City'), findsNothing);

    await tester.tap(find.widgetWithText(ListTile, 'Kurigram Sadar'));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(controller.start.value, 'kurigram.kurigram-sadar');
  });

  testWidgets('a trip within one district gets a distance', (tester) async {
    await open(tester);

    controller
      ..setStart('rangpur.rangpur-sadar')
      ..setEnd('rangpur.pirganj');
    await tester.pump();

    expect(tester.takeException(), isNull);
    expect(controller.distanceM, greaterThan(20000));
    expect(controller.route.value!.districts, ['Rangpur']);
  });

  VehicleRow bike(String name) => VehicleRow(
    id: 1,
    createdAt: 0,
    updatedAt: 0,
    name: name,
    fuelType: FuelType.petrol,
    initialOdometerM: 0,
    distanceUnit: DistanceUnit.km,
    volumeUnit: VolumeUnit.l,
    currency: 'BDT',
    isDefault: true,
    colorTag: 0,
    isArchived: false,
  );

  testWidgets('bike name starts as the active bike', (tester) async {
    await open(tester);

    vehicles.active.value = bike('Honda XBlade');
    await tester.pump();

    expect(controller.bike.value, 'Honda XBlade');
  });

  testWidgets('a typed bike name is not overwritten', (tester) async {
    await open(tester);

    controller.bikeCtrl.text = 'My Beast';
    vehicles.active.value = bike('Honda XBlade');
    await tester.pump();

    expect(controller.bike.value, 'My Beast');
  });

  testWidgets('a saved bike name beats the active bike', (tester) async {
    await open(tester);
    settings.routeCardBike.value = 'Saved';

    vehicles.active.value = bike('Honda XBlade');
    await tester.pump();

    expect(controller.bike.value, 'Saved');
  });

  testWidgets('a typed distance survives editing the stops', (tester) async {
    await open(tester);
    controller
      ..setStart('kurigram.kurigram-sadar')
      ..setEnd('dhaka.dhaka-city');
    await tester.pump();

    controller.distanceCtrl.text = '360';
    await tester.pump();
    controller.addStop('bogura.bogura-sadar');
    await tester.pump();

    expect(controller.distanceM, 360000);
    expect(controller.isManual, isTrue);
  });
}
