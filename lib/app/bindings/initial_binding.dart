import 'package:get/get.dart' hide Value;

import '../../data/db/database.dart';
import '../../data/repositories/backup_repo.dart';
import '../../data/repositories/expense_repo.dart';
import '../../data/repositories/fuel_repo.dart';
import '../../data/repositories/reminder_repo.dart';
import '../../data/repositories/ride_repo.dart';
import '../../data/repositories/service_repo.dart';
import '../../data/repositories/vehicle_repo.dart';
import '../../modules/fuel/fuel_controller.dart';
import '../../modules/rides/ride_tracker_controller.dart';
import '../../modules/service/service_controller.dart';
import '../../modules/vehicles/vehicle_controller.dart';
import '../../services/export_service.dart';
import '../../services/home_widget/home_widget_service.dart';
import '../../services/import_service.dart';
import '../../services/location_service.dart';
import '../../services/notification_service.dart';
import '../../services/reminder_service.dart';
import '../../services/settings_service.dart';

/// Wires up everything that lives for the whole app run.
///
/// GetX handles state and routing, but the data layer is deliberately *not*
/// GetX-aware: repositories are plain classes that take an [AppDatabase] in
/// their constructor. `Get.put` is only the delivery mechanism, so any of
/// them can be constructed directly in a unit test with an in-memory
/// database and no GetX at all.
///
/// Registration order matters — each block may `Get.find` the ones above it.
class InitialBinding extends Bindings {
  @override
  void dependencies() {
    final db = Get.find<AppDatabase>();

    // --- Data access ---
    Get.put<VehicleRepo>(VehicleRepo(db), permanent: true);
    Get.put<FuelRepo>(FuelRepo(db), permanent: true);
    Get.put<ServiceRepo>(ServiceRepo(db), permanent: true);
    Get.put<ExpenseRepo>(ExpenseRepo(db), permanent: true);
    Get.put<RideRepo>(RideRepo(db), permanent: true);
    Get.put<ReminderRepo>(ReminderRepo(db), permanent: true);
    Get.put<BackupRepo>(BackupRepo(db), permanent: true);

    // --- File in, file out ---
    Get.put<ExportService>(
      ExportService(Get.find<BackupRepo>()),
      permanent: true,
    );
    Get.put<ImportService>(
      ImportService(Get.find<BackupRepo>()),
      permanent: true,
    );

    // --- Cross-screen state ---
    //
    // These three are permanent rather than per-route because several
    // screens read the same derived answer. Recomputing the mileage report
    // or the service plan per screen would be wasteful and, worse, could
    // show two different answers for the same data mid-write.

    // Every screen scopes to the active vehicle.
    Get.put<VehicleController>(
      VehicleController(Get.find<VehicleRepo>(), Get.find<SettingsService>()),
      permanent: true,
    );

    // Home, fuel history and (from Phase 4) stats share one mileage report.
    Get.put<FuelController>(
      FuelController(
        Get.find<FuelRepo>(),
        Get.find<VehicleController>(),
        Get.find<SettingsService>(),
      ),
      permanent: true,
    );

    // Reminders are derived state, recomputed on launch and after any entry
    // that carries an odometer reading. Nothing here posts a notification
    // until the user has opted in.
    Get.put<ReminderService>(
      ReminderService(
        vehicles: Get.find<VehicleRepo>(),
        service: Get.find<ServiceRepo>(),
        fuel: Get.find<FuelRepo>(),
        expenses: Get.find<ExpenseRepo>(),
        reminders: Get.find<ReminderRepo>(),
        notifications: Get.find<NotificationService>(),
        settings: Get.find<SettingsService>(),
      ),
      permanent: true,
    );

    // Location is constructed here but touches nothing until the user picks
    // a tracking mode. The tracker is app-wide because a ride must survive
    // navigating away from the rides screen.
    Get.put<LocationService>(LocationService(), permanent: true);
    Get.put<RideTrackerController>(
      RideTrackerController(
        Get.find<RideRepo>(),
        Get.find<FuelRepo>(),
        Get.find<LocationService>(),
        Get.find<VehicleController>(),
        Get.find<SettingsService>(),
      ),
      permanent: true,
    );

    // Home's next-service card and the service screen read the same plan.
    Get.put<ServiceController>(
      ServiceController(
        Get.find<ServiceRepo>(),
        Get.find<FuelRepo>(),
        Get.find<VehicleController>(),
        Get.find<ReminderService>(),
      ),
      permanent: true,
    );

    // Last, because it reads the active vehicle and every repository above
    // it. Registered unconditionally and inert everywhere but Android, and
    // inert on Android too until the user places a widget.
    Get.putAsync<HomeWidgetService>(
      () => HomeWidgetService(
        db,
        Get.find<VehicleController>(),
        Get.find<SettingsService>(),
        Get.find<FuelRepo>(),
        Get.find<ServiceRepo>(),
        Get.find<ExpenseRepo>(),
      ).init(),
      permanent: true,
    );
  }
}
