/// Every route name in the app, in one place.
///
/// Referenced as `Get.toNamed(Routes.addFuel)` — never as a string literal at
/// the call site, so renaming a route is a compile-time change rather than a
/// runtime surprise.
abstract final class Routes {
  static const onboarding = '/onboarding';
  static const home = '/home';

  static const fuelHistory = '/fuel';
  static const fuelForm = '/fuel/form';

  static const service = '/service';
  static const serviceLogForm = '/service/log-form';
  static const serviceItemForm = '/service/item-form';

  static const expenses = '/expenses';
  static const expenseForm = '/expenses/form';

  static const rides = '/rides';
  static const rideDetail = '/rides/detail';

  static const stats = '/stats';

  static const vehicles = '/vehicles';
  static const vehicleForm = '/vehicles/form';

  static const settings = '/settings';
  static const backup = '/settings/backup';
  static const about = '/settings/about';
}

/// Argument keys for `Get.toNamed(..., arguments: {...})`.
abstract final class RouteArgs {
  /// `int` — the record being edited. Absent ⇒ the form is creating.
  static const editId = 'editId';

  /// `int` — the vehicle a new record belongs to.
  static const vehicleId = 'vehicleId';

  /// `int` — pre-selected service item when logging a service from its row.
  static const serviceItemId = 'serviceItemId';

  /// `int` — ride to open on the detail screen.
  static const rideId = 'rideId';

  /// `bool` — onboarding shows no back button and lands on home when done.
  static const fromOnboarding = 'fromOnboarding';
}
