import 'package:get/get.dart' hide Value;

import '../../data/db/database.dart';
import '../../data/repositories/fuel_repo.dart';
import '../../data/repositories/backup_repo.dart';
import '../../data/repositories/expense_repo.dart';
import '../../data/repositories/ride_repo.dart';
import '../../data/repositories/service_repo.dart';
import '../../data/repositories/vehicle_repo.dart';
import '../../modules/fuel/fuel_controller.dart';
import '../../modules/fuel/fuel_form_controller.dart';
import '../../modules/fuel/fuel_form_view.dart';
import '../../modules/fuel/fuel_history_view.dart';
import '../../modules/expenses/expense_form_controller.dart';
import '../../modules/expenses/expense_form_view.dart';
import '../../modules/expenses/expenses_controller.dart';
import '../../modules/expenses/expenses_view.dart';
import '../../modules/home/home_controller.dart';
import '../../modules/map/map_controller.dart';
import '../../modules/onboarding/onboarding_controller.dart';
import '../../modules/onboarding/onboarding_view.dart';
import '../../modules/rides/ride_detail_view.dart';
import '../../modules/rides/ride_tracker_controller.dart';
import '../../modules/rides/rides_controller.dart';
import '../../modules/rides/rides_view.dart';
import '../../modules/shell/shell_controller.dart';
import '../../modules/shell/shell_view.dart';
import '../../modules/service/service_item_form_controller.dart';
import '../../modules/service/service_item_form_view.dart';
import '../../modules/service/service_log_form_controller.dart';
import '../../modules/service/service_log_form_view.dart';
import '../../modules/service/service_view.dart';
import '../../modules/settings/backup_controller.dart';
import '../../modules/settings/backup_view.dart';
import '../../modules/settings/settings_controller.dart';
import '../../modules/settings/settings_view.dart';
import '../../modules/stats/stats_controller.dart';
import '../../modules/stats/stats_view.dart';
import '../../modules/vehicles/vehicle_controller.dart';
import '../../modules/vehicles/vehicle_form_controller.dart';
import '../../modules/vehicles/vehicle_form_view.dart';
import '../../modules/vehicles/vehicles_view.dart';
import '../../services/export_service.dart';
import '../../services/import_service.dart';
import '../../services/location_service.dart';
import '../../services/notification_service.dart';
import '../../services/reminder_service.dart';
import '../../services/settings_service.dart';
import 'app_routes.dart';

/// Route table.
///
/// Each page brings its own binding, so a controller is constructed when its
/// screen is opened and disposed when it leaves — `lazyPut` rather than the
/// permanent registrations in `InitialBinding`, which are reserved for
/// genuinely app-wide state.
abstract final class AppPages {
  static final pages = <GetPage<dynamic>>[
    GetPage(
      name: Routes.onboarding,
      page: () => const OnboardingView(),
      binding: BindingsBuilder(() {
        Get.lazyPut(
          () => OnboardingController(
            Get.find<VehicleRepo>(),
            Get.find<SettingsService>(),
          ),
        );
      }),
    ),
    GetPage(
      name: Routes.home,
      page: () => const ShellView(),
      binding: BindingsBuilder(() {
        // The shell's `IndexedStack` builds all four tabs at once and keeps
        // them alive across switches, so every tab's controller is registered
        // here and marked permanent.
        //
        // Permanent matters for more than lifetime: `/fuel` and `/stats` are
        // still reachable as pushed routes, and their bindings would otherwise
        // hand GetX ownership of the same controllers — which it would then
        // dispose on pop, emptying the tab still mounted behind.
        //
        // Each is guarded, because this binding runs again when onboarding
        // finishes with `offAllNamed(Routes.home)`. A bare `Get.put` would
        // swap in a second instance without closing the first one's database
        // subscriptions, leaking a stream per re-entry.
        _putOnce(() => ShellController());

        _putOnce(
          () => HomeController(
            Get.find<FuelRepo>(),
            Get.find<ServiceRepo>(),
            Get.find<ExpenseRepo>(),
            Get.find<VehicleController>(),
            Get.find<SettingsService>(),
            Get.find<FuelController>(),
          ),
        );

        _putOnce(
          () => MapController(
            Get.find<RideRepo>(),
            Get.find<RideTrackerController>(),
            Get.find<VehicleController>(),
            Get.find<LocationService>(),
            Get.find<ShellController>(),
          ),
        );

        _putOnce(
          () => StatsController(
            Get.find<FuelRepo>(),
            Get.find<ServiceRepo>(),
            Get.find<ExpenseRepo>(),
            Get.find<VehicleController>(),
            Get.find<SettingsService>(),
          ),
        );
      }),
    ),
    GetPage(name: Routes.fuelHistory, page: () => const FuelHistoryView()),
    GetPage(
      name: Routes.fuelForm,
      page: () => const FuelFormView(),
      binding: BindingsBuilder(() {
        // `fenix` so returning to the form after it was disposed rebuilds it
        // rather than throwing.
        Get.lazyPut(
          () => FuelFormController(
            Get.find<FuelRepo>(),
            Get.find<VehicleController>(),
            Get.find<ReminderService>(),
          ),
          fenix: true,
        );
      }),
    ),
    GetPage(name: Routes.service, page: () => const ServiceView()),
    GetPage(
      name: Routes.serviceLogForm,
      page: () => const ServiceLogFormView(),
      binding: BindingsBuilder(() {
        Get.lazyPut(
          () => ServiceLogFormController(
            Get.find<ServiceRepo>(),
            Get.find<FuelRepo>(),
            Get.find<VehicleController>(),
            Get.find<ReminderService>(),
          ),
          fenix: true,
        );
      }),
    ),
    GetPage(
      name: Routes.serviceItemForm,
      page: () => const ServiceItemFormView(),
      binding: BindingsBuilder(() {
        Get.lazyPut(
          () => ServiceItemFormController(
            Get.find<ServiceRepo>(),
            Get.find<VehicleController>(),
            Get.find<ReminderService>(),
          ),
          fenix: true,
        );
      }),
    ),
    GetPage(
      name: Routes.expenses,
      page: () => const ExpensesView(),
      binding: BindingsBuilder(() {
        Get.lazyPut(
          () => ExpensesController(
            Get.find<ExpenseRepo>(),
            Get.find<VehicleController>(),
            Get.find<ReminderService>(),
          ),
          fenix: true,
        );
      }),
    ),
    GetPage(
      name: Routes.expenseForm,
      page: () => const ExpenseFormView(),
      binding: BindingsBuilder(() {
        Get.lazyPut(
          () => ExpenseFormController(
            Get.find<ExpenseRepo>(),
            Get.find<VehicleController>(),
            Get.find<ReminderService>(),
          ),
          fenix: true,
        );
      }),
    ),
    GetPage(
      name: Routes.rides,
      page: () => const RidesView(),
      binding: BindingsBuilder(() {
        Get.lazyPut(
          () => RidesController(
            Get.find<RideRepo>(),
            Get.find<VehicleController>(),
          ),
          fenix: true,
        );
      }),
    ),
    GetPage(name: Routes.rideDetail, page: () => const RideDetailView()),
    // `/fuel` and `/stats` are the shell's tabs. They stay in the table so
    // existing `Get.toNamed` calls keep working, but they need no binding —
    // both controllers are registered permanently by the shell above.
    GetPage(name: Routes.stats, page: () => const StatsView()),
    GetPage(name: Routes.vehicles, page: () => const VehiclesView()),
    GetPage(
      name: Routes.vehicleForm,
      page: () => const VehicleFormView(),
      binding: BindingsBuilder(() {
        // `fenix` so returning to a form after it was disposed rebuilds it
        // rather than throwing.
        Get.lazyPut(
          () => VehicleFormController(Get.find<VehicleRepo>()),
          fenix: true,
        );
      }),
    ),
    GetPage(
      name: Routes.backup,
      page: () => const BackupView(),
      binding: BindingsBuilder(() {
        Get.lazyPut(
          () => BackupController(
            Get.find<ExportService>(),
            Get.find<ImportService>(),
            Get.find<BackupRepo>(),
            Get.find<SettingsService>(),
          ),
          fenix: true,
        );
      }),
    ),
    GetPage(
      name: Routes.settings,
      page: () => const SettingsView(),
      binding: BindingsBuilder(() {
        Get.lazyPut(
          () => SettingsController(
            Get.find<SettingsService>(),
            Get.find<AppDatabase>(),
            Get.find<ReminderService>(),
            Get.find<NotificationService>(),
          ),
        );
      }),
    ),
  ];

  /// Registers a permanent controller, but only the first time.
  ///
  /// `Get.put` would otherwise construct and install a replacement on every
  /// re-entry, orphaning the previous instance — which is still holding open
  /// database subscriptions, since nothing calls `onClose` on it.
  static void _putOnce<T>(T Function() create) {
    if (Get.isRegistered<T>()) return;
    Get.put<T>(create(), permanent: true);
  }
}
