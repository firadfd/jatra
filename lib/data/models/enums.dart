/// Enumerations shared by the database schema, the calculators and the UI.
///
/// All of these are persisted **by name** (Drift `textEnum`), not by index, so
/// reordering a declaration can never silently reinterpret existing rows and
/// JSON backups stay human-readable.
library;

enum FuelType {
  petrol,
  octane,
  diesel,
  cng,
  electric;

  String get label => switch (this) {
    FuelType.petrol => 'Petrol',
    FuelType.octane => 'Octane',
    FuelType.diesel => 'Diesel',
    FuelType.cng => 'CNG',
    FuelType.electric => 'Electric',
  };

  /// Electric bikes are metered in kWh, not litres, which changes every unit
  /// label on the fuel form.
  bool get isLiquid => this != FuelType.electric;
}

enum DistanceUnit {
  km,
  mi;

  String get label => switch (this) {
    DistanceUnit.km => 'KM',
    DistanceUnit.mi => 'MI',
  };
}

enum VolumeUnit {
  l,
  gal;

  String get label => switch (this) {
    VolumeUnit.l => 'L',
    VolumeUnit.gal => 'GAL',
  };
}

/// Non-fuel, non-service costs.
enum ExpenseCategory {
  insurance,
  taxToken,
  fitness,
  registration,
  accessories,
  fine,
  parking,
  washing,
  other;

  String get label => switch (this) {
    ExpenseCategory.insurance => 'Insurance',
    ExpenseCategory.taxToken => 'Tax token',
    ExpenseCategory.fitness => 'Fitness',
    ExpenseCategory.registration => 'Registration',
    ExpenseCategory.accessories => 'Accessories',
    ExpenseCategory.fine => 'Fine',
    ExpenseCategory.parking => 'Parking',
    ExpenseCategory.washing => 'Washing',
    ExpenseCategory.other => 'Other',
  };

  /// Categories that normally cover a period and therefore expire. These are
  /// the ones worth prompting for `validUntil` and counting down on the
  /// expenses screen.
  bool get isDocument => switch (this) {
    ExpenseCategory.insurance ||
    ExpenseCategory.taxToken ||
    ExpenseCategory.fitness ||
    ExpenseCategory.registration => true,
    _ => false,
  };

  /// Recurring ownership costs, as opposed to one-off purchases. Both feed
  /// running cost/km; the split only matters for how they are summarised.
  bool get isFixedCost => isDocument;
}

enum ReminderType {
  service,
  documentExpiry,
  custom;

  String get label => switch (this) {
    ReminderType.service => 'Service',
    ReminderType.documentExpiry => 'Document expiry',
    ReminderType.custom => 'Reminder',
  };
}

/// How close a service item is to its next due point.
///
/// Ordered most-urgent-first so `sort` on `index` gives the urgency ordering
/// the service screen needs.
enum ServiceStatus {
  overdue,
  dueNow,
  dueSoon,
  ok,
  unknown;

  String get label => switch (this) {
    ServiceStatus.overdue => 'OVERDUE',
    ServiceStatus.dueNow => 'DUE NOW',
    ServiceStatus.dueSoon => 'DUE SOON',
    ServiceStatus.ok => 'OK',
    ServiceStatus.unknown => 'NOT SET',
  };
}

/// Ride tracking mode. Default is [off] — the app is fully usable by someone
/// who never grants location permission.
enum TrackingMode {
  off,
  appOpen,
  background;

  String get label => switch (this) {
    TrackingMode.off => 'Off',
    TrackingMode.appOpen => 'While app is open',
    TrackingMode.background => 'Background',
  };

  String get description => switch (this) {
    TrackingMode.off =>
      'No GPS. Enter ride distances by hand. Everything else works.',
    TrackingMode.appOpen =>
      'Records while Jatra is on screen. Pauses when you switch away.',
    TrackingMode.background =>
      'Keeps recording with the screen off, using a notification.',
  };
}
