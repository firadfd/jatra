import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart' hide Value;
import 'package:intl/date_symbol_data_local.dart';
import 'package:jatra/app/theme/app_theme.dart';
import 'package:jatra/core/utils/enum_labels.dart';
import 'package:jatra/data/db/database.dart';
import 'package:jatra/data/repositories/fuel_repo.dart';
import 'package:jatra/data/repositories/vehicle_repo.dart';
import 'package:jatra/l10n/app_localizations.dart';
import 'package:jatra/l10n/app_localizations_bn.dart';
import 'package:jatra/l10n/app_localizations_en.dart';
import 'package:jatra/modules/fuel/fuel_controller.dart';
import 'package:jatra/modules/fuel/fuel_history_view.dart';
import 'package:jatra/modules/vehicles/vehicle_controller.dart';
import 'package:jatra/services/settings_service.dart';

/// The interface itself must translate, not just the strings file.
///
/// Every screen used to be built from string literals, so `app_bn.arb` could
/// be complete and the app still read as English everywhere but Settings.
/// These tests pump a real screen under `bn` and assert on what it renders, so
/// a view that goes back to a hardcoded literal fails here rather than in
/// someone's hands.
void main() {
  setUpAll(() async {
    await initializeDateFormatting();
  });

  late AppDatabase db;

  // SettingsService is deliberately never init()ed — init() opens
  // get_storage, which needs path_provider. Same rule as
  // fuel_list_view_test.dart.
  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    final settings = SettingsService();
    final vehicles = Get.put(VehicleController(VehicleRepo(db), settings));
    await Future<void>.delayed(const Duration(milliseconds: 60));
    Get.put(FuelController(FuelRepo(db), vehicles, settings));
    await Future<void>.delayed(const Duration(milliseconds: 60));
  });

  tearDown(() async {
    Get.reset();
    await db.close();
  });

  Widget wrap(Locale locale) => GetMaterialApp(
    // JatraColors is a theme extension, and `context.jatra` asserts on it.
    theme: AppTheme.dark,
    locale: locale,
    localizationsDelegates: L.localizationsDelegates,
    supportedLocales: L.supportedLocales,
    home: const FuelHistoryView(),
  );

  testWidgets('the fuel screen renders in Bangla, not English', (tester) async {
    await tester.pumpWidget(wrap(const Locale('bn')));
    await tester.pump(const Duration(milliseconds: 50));

    expect(tester.takeException(), isNull);
    // Title and empty state both come from the .arb file.
    expect(find.text('জ্বালানির হিসাব'), findsOneWidget);
    expect(find.text('No fills logged yet'), findsNothing);
  });

  testWidgets('the same screen still renders in English', (tester) async {
    await tester.pumpWidget(wrap(const Locale('en')));
    await tester.pump(const Duration(milliseconds: 50));

    expect(tester.takeException(), isNull);
    expect(find.text('Fuel history'), findsOneWidget);
  });

  group('enums translate without changing their stored value', () {
    test('expense categories', () {
      final bn = LBn();
      final en = LEn();

      expect(ExpenseCategory.insurance.labelOf(bn), 'বিমা');
      expect(ExpenseCategory.insurance.labelOf(en), 'Insurance');
      // The persisted identity is untouched — a category stored on one
      // language must mean the same thing read back on another.
      expect(ExpenseCategory.insurance.name, 'insurance');
    });

    test('service status', () {
      expect(ServiceStatus.overdue.labelOf(LBn()), isNot('OVERDUE'));
      expect(ServiceStatus.overdue.labelOf(LEn()), 'OVERDUE');
    });
  });
}
