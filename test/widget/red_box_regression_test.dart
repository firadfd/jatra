// Regression cover for two red-box bugs that shipped, both invisible to
// `flutter analyze` because they are runtime contracts:
//
//  1. Every form's AppBar title was an `Obx` reading only `isEditing` — a
//     plain getter over a plain `int? editId`. An Obx that touches no
//     observable throws.
//  2. `JatraCard` painted its surface with a DecoratedBox and only supplied a
//     Material when tappable, so any ListTile/SwitchListTile inside a plain
//     card tripped "ListTile background color or ink splashes may be
//     invisible".
//
// Both render an ErrorWidget in debug. Only pumping the widget catches them.
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart' hide Value;

import 'package:jatra/app/theme/app_theme.dart';
import 'package:jatra/core/widgets/jatra_widgets.dart';
import 'package:jatra/data/db/database.dart';
import 'package:jatra/data/repositories/vehicle_repo.dart';
import 'package:jatra/modules/vehicles/vehicle_form_controller.dart';
import 'package:jatra/modules/vehicles/vehicle_form_view.dart';
import 'package:jatra/l10n/app_localizations.dart';

void main() {
  testWidgets('the vehicle form renders without an error box', (tester) async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    Get.put<VehicleRepo>(VehicleRepo(db));
    Get.put(VehicleFormController(Get.find<VehicleRepo>()));

    await tester.pumpWidget(
      GetMaterialApp(
        theme: AppTheme.dark,
        localizationsDelegates: L.localizationsDelegates,
        supportedLocales: L.supportedLocales,
        home: const VehicleFormView(),
      ),
    );
    // The controller loads asynchronously; the body is a spinner until it
    // finishes, and the SwitchListTile below only exists after that.
    await tester.pumpAndSettle();

    // The title is the widget that used to be an Obx over `isEditing`.
    // (The form's own SwitchListTile is further down a lazy ListView and so
    // is not built at this viewport size — the JatraCard group below covers
    // that shape directly instead.)
    expect(tester.takeException(), isNull);
    expect(find.text('Add a bike'), findsOneWidget);

    Get.reset();
    await db.close();
  });

  group('JatraCard hosts list tiles', () {
    Widget host(Widget child) => MaterialApp(
      theme: AppTheme.dark,
      localizationsDelegates: L.localizationsDelegates,
      supportedLocales: L.supportedLocales,
      home: Scaffold(body: Center(child: child)),
    );

    testWidgets('a plain card can hold a ListTile', (tester) async {
      await tester.pumpWidget(
        host(
          const JatraCard(
            padding: EdgeInsets.zero,
            child: ListTile(title: Text('Backup')),
          ),
        ),
      );
      expect(tester.takeException(), isNull);
      expect(find.text('Backup'), findsOneWidget);
    });

    testWidgets('a plain card can hold a SwitchListTile', (tester) async {
      await tester.pumpWidget(
        host(
          JatraCard(
            child: SwitchListTile.adaptive(
              value: true,
              onChanged: (_) {},
              title: const Text('Reminders'),
            ),
          ),
        ),
      );
      expect(tester.takeException(), isNull);
      expect(find.text('Reminders'), findsOneWidget);
    });

    testWidgets('a tappable card still reports taps', (tester) async {
      var taps = 0;
      await tester.pumpWidget(
        host(JatraCard(onTap: () => taps++, child: const Text('Tap me'))),
      );
      await tester.tap(find.text('Tap me'));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(taps, 1);
    });
  });
}
