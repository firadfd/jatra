// Does a saved fill actually appear on screen?
//
// FuelController is already proven to receive it (see
// test/modules/fuel_controller_test.dart), so this covers the last hop: the
// widgets that render that list.
//
// Two harness rules learned the hard way:
//  * SettingsService is never init()ed — init() opens get_storage, which
//    needs path_provider.
//  * All async setup happens in setUp (real async). Inside testWidgets,
//    `Future.delayed` runs under fake async and deadlocks.
import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart' hide Value;
import 'package:intl/date_symbol_data_local.dart';

import 'package:jatra/app/theme/app_theme.dart';
import 'package:jatra/core/utils/clock.dart';
import 'package:jatra/core/utils/money.dart';
import 'package:jatra/data/db/database.dart';
import 'package:jatra/data/repositories/fuel_repo.dart';
import 'package:jatra/data/repositories/vehicle_repo.dart';
import 'package:jatra/modules/fuel/fuel_controller.dart';
import 'package:jatra/modules/fuel/fuel_history_view.dart';
import 'package:jatra/modules/vehicles/vehicle_controller.dart';
import 'package:jatra/services/settings_service.dart';
import 'package:jatra/l10n/app_localizations.dart';

void main() {
  // The month headers run dates through DateFormat, which throws
  // LocaleDataException without this. main() does the same thing at launch.
  setUpAll(initializeDateFormatting);

  late AppDatabase db;
  late FuelRepo fuel;
  late int vehicleId;

  Future<void> settle() =>
      Future<void>.delayed(const Duration(milliseconds: 60));

  setUp(() async {
    Clock.freeze(DateTime.utc(2026, 8, 4, 12));
    db = AppDatabase.forTesting(NativeDatabase.memory());
    fuel = FuelRepo(db);
    final settings = SettingsService();

    vehicleId = await VehicleRepo(db).create(
      VehiclesCompanion.insert(
        name: 'Pulsar',
        createdAt: 0,
        updatedAt: 0,
        initialOdometerM: const Value(10000000),
      ),
    );

    final vehicles = Get.put(VehicleController(VehicleRepo(db), settings));
    await settle();
    Get.put(FuelController(fuel, vehicles, settings));
    await settle();
  });

  tearDown(() async {
    Get.reset();
    Clock.freeze(null);
    await db.close();
  });

  Future<int> addFill({required double odometerKm}) => fuel.create(
    FuelEntriesCompanion.insert(
      vehicleId: vehicleId,
      dateMs: Clock.nowMs,
      odometerM: (odometerKm * 1000).round(),
      volumeMl: 10000,
      pricePerUnitMinor: Money.fromMajor(121.5).minor,
      totalCostMinor: Money.fromMajor(1215).minor,
      createdAt: 0,
      updatedAt: 0,
    ),
  );

  Widget wrap() => GetMaterialApp(
    theme: AppTheme.dark,
    localizationsDelegates: L.localizationsDelegates,
    supportedLocales: L.supportedLocales,
    home: const FuelHistoryView(),
  );

  testWidgets('an empty log shows the empty state, not a stuck spinner', (
    tester,
  ) async {
    await tester.pumpWidget(wrap());
    await tester.pump(const Duration(milliseconds: 50));

    expect(tester.takeException(), isNull);
    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(find.text('No fills logged yet'), findsOneWidget);
  });

  testWidgets('a saved fill is rendered in the history list', (tester) async {
    // runAsync, not a bare await: the testWidgets body runs under fake async,
    // where Future.delayed never fires and the drift stream never delivers.
    await tester.runAsync(() async {
      await addFill(odometerKm: 10250);
      await settle();
    });

    await tester.pumpWidget(wrap());
    await tester.pump(const Duration(milliseconds: 50));

    expect(tester.takeException(), isNull);
    expect(
      find.text('No fills logged yet'),
      findsNothing,
      reason: 'the list still thinks it is empty',
    );
    expect(
      find.textContaining('10,250'),
      findsWidgets,
      reason: 'the odometer reading of the saved fill should be on screen',
    );
  });

  testWidgets('a fill saved while the list is on screen appears without '
      'reopening it', (tester) async {
    await tester.pumpWidget(wrap());
    await tester.pump(const Duration(milliseconds: 50));
    expect(find.text('No fills logged yet'), findsOneWidget);

    // This is the real-world sequence: the list is mounted, the user saves a
    // fill on the form, and the list must update itself.
    await tester.runAsync(() async {
      await addFill(odometerKm: 10250);
      await settle();
    });
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    expect(tester.takeException(), isNull);
    expect(find.text('No fills logged yet'), findsNothing);
    expect(find.textContaining('10,250'), findsWidgets);
  });
}
