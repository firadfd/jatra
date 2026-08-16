import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:get/get.dart' hide Value;

import 'app/bindings/initial_binding.dart';
import 'app/routes/app_pages.dart';
import 'app/routes/app_routes.dart';
import 'app/theme/app_theme.dart';
import 'l10n/app_localizations.dart';
import 'data/db/database.dart';
import 'data/db/demo_seed.dart';
import 'services/notification_service.dart';
import 'services/settings_service.dart';

/// Loads a realistic demo dataset on first run so screens can be evaluated
/// with real-looking data:
///
///     flutter run --dart-define=SEED_DEMO=true
///
/// Guarded by [kDebugMode] as well, so it can never reach a release build
/// even if the define is left on.
const kSeedDemo = bool.fromEnvironment('SEED_DEMO');

/// Prints every framework error in full instead of collapsing repeats:
///
///     flutter run --dart-define=VERBOSE_ERRORS=true
///
/// By default Flutter dumps the *first* error verbosely — message, offending
/// widget, stack — and reduces every later one to a single
/// "Another exception was thrown: ..." line (see `_errorCount` in
/// `FlutterError.dumpErrorToConsole`). That is the right default for a noisy
/// app, but it is useless when the first error scrolls past and all you are
/// left with is a wall of identical one-liners. This forces the full report
/// every time, which is how you find out *which widget* is failing.
///
/// Debug-only, and off unless the define is passed.
const kVerboseErrors = bool.fromEnvironment('VERBOSE_ERRORS');

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (kDebugMode && kVerboseErrors) {
    FlutterError.onError = (details) =>
        FlutterError.dumpErrorToConsole(details, forceReport: true);
  }

  // Month and day names for every locale Jatra ships. Without this, a Bangla
  // DateFormat throws rather than falling back.
  await initializeDateFormatting();

  // Settings first — the theme and the initial route both depend on them.
  final settings = await Get.putAsync(
    () => SettingsService().init(),
    permanent: true,
  );

  final db = AppDatabase();
  Get.put<AppDatabase>(db, permanent: true);

  // Sets up the notification channel and reads back whether the user has
  // already allowed notifications. Asks for nothing.
  await Get.putAsync(() => NotificationService().init(), permanent: true);

  if (kDebugMode && kSeedDemo) {
    await DemoSeed.ensureSeeded(db, settings);
  }

  // Someone who already has a bike should never see onboarding again, even
  // if the completion flag was lost — the data is the source of truth.
  final hasVehicle = await db.managers.vehicles
      .filter((f) => f.deletedAt.isNull())
      .exists();

  runApp(JatraApp(initialRoute: hasVehicle ? Routes.home : Routes.onboarding));
}

class JatraApp extends StatelessWidget {
  const JatraApp({super.key, required this.initialRoute});

  final String initialRoute;

  @override
  Widget build(BuildContext context) {
    final settings = Get.find<SettingsService>();

    return GetMaterialApp(
      title: 'Jatra',
      debugShowCheckedModeBanner: false,
      initialBinding: InitialBinding(),
      initialRoute: initialRoute,
      getPages: AppPages.pages,

      // Dark is primary: this app is used at dusk, in a garage, at a pump.
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: settings.themeMode.value,

      // Charts and formatted numbers both read the locale, so it is set here
      // once rather than per screen.
      locale: settings.locale,
      fallbackLocale: const Locale('en'),
      localizationsDelegates: const [
        L.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: L.supportedLocales,
    );
  }
}
