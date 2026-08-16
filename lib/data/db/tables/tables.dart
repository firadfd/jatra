import 'package:drift/drift.dart';

import '../../models/enums.dart';

/// Columns every table carries.
///
/// Deletes are **soft** (`deletedAt` set, row retained) so a JSON import can
/// reconcile against records the user removed on another device without
/// resurrecting them. Every read filters `deletedAt IS NULL`; only
/// "delete all data" and a Replace-all import hard-delete rows.
mixin TableMeta on Table {
  IntColumn get id => integer().autoIncrement()();

  /// UTC epoch milliseconds. Always. Displayed in local time, never stored
  /// in it — otherwise a user crossing a timezone rewrites their history.
  IntColumn get createdAt => integer()();
  IntColumn get updatedAt => integer()();
  IntColumn get deletedAt => integer().nullable()();
}

// ---------------------------------------------------------------------------
// Vehicles
// ---------------------------------------------------------------------------

@DataClassName('VehicleRow')
class Vehicles extends Table with TableMeta {
  TextColumn get name => text().withLength(min: 1, max: 60)();
  TextColumn get make => text().nullable()();
  TextColumn get model => text().nullable()();
  IntColumn get year => integer().nullable()();
  IntColumn get engineCc => integer().nullable()();
  TextColumn get registrationNo => text().nullable()();

  TextColumn get fuelType =>
      textEnum<FuelType>().withDefault(const Constant('petrol'))();

  IntColumn get purchaseDateMs => integer().nullable()();

  /// Minor units (paisa).
  IntColumn get purchasePriceMinor => integer().nullable()();

  /// Odometer reading when the bike entered the log, in metres. Distance
  /// owned is measured from here, not from zero — most people start logging
  /// on a bike that already has kilometres on it.
  IntColumn get initialOdometerM => integer().withDefault(const Constant(0))();

  /// What the bike is worth now, in minor units. Drives the depreciation
  /// half of true cost/km. Null ⇒ fall back to the default annual rate.
  IntColumn get currentValueEstimateMinor => integer().nullable()();

  IntColumn get tankCapacityMl => integer().nullable()();

  TextColumn get distanceUnit =>
      textEnum<DistanceUnit>().withDefault(const Constant('km'))();
  TextColumn get volumeUnit =>
      textEnum<VolumeUnit>().withDefault(const Constant('l'))();
  TextColumn get currency =>
      text().withLength(min: 3, max: 3).withDefault(const Constant('BDT'))();

  BoolColumn get isDefault => boolean().withDefault(const Constant(false))();

  /// Index into `Palette.vehicleTags`.
  IntColumn get colorTag => integer().withDefault(const Constant(0))();

  /// Archived bikes stay in the data (their history still counts in
  /// all-vehicle stats) but drop out of the switcher.
  BoolColumn get isArchived => boolean().withDefault(const Constant(false))();
}

// ---------------------------------------------------------------------------
// Fuel
// ---------------------------------------------------------------------------

@DataClassName('FuelEntryRow')
@TableIndex(name: 'idx_fuel_vehicle_odo', columns: {#vehicleId, #odometerM})
@TableIndex(name: 'idx_fuel_vehicle_date', columns: {#vehicleId, #dateMs})
class FuelEntries extends Table with TableMeta {
  IntColumn get vehicleId =>
      integer().references(Vehicles, #id, onDelete: KeyAction.cascade)();

  IntColumn get dateMs => integer()();
  IntColumn get odometerM => integer()();

  IntColumn get volumeMl => integer()();

  /// Price per litre in minor units. Kept alongside [totalCostMinor] rather
  /// than derived, because the user may have typed either one.
  IntColumn get pricePerUnitMinor => integer()();
  IntColumn get totalCostMinor => integer()();

  /// Only full-tank-to-full-tank spans produce a mileage figure. A partial
  /// fill contributes its volume to the *next* full tank's window.
  BoolColumn get isFullTank => boolean().withDefault(const Constant(true))();

  /// The user knows they skipped logging a fill somewhere before this one.
  /// Poisons the whole window it lands in — that window is shown but never
  /// averaged.
  BoolColumn get isMissedEntry =>
      boolean().withDefault(const Constant(false))();

  TextColumn get station => text().nullable()();
  TextColumn get notes => text().nullable()();
}

// ---------------------------------------------------------------------------
// Service
// ---------------------------------------------------------------------------

/// Recurring maintenance *definitions* — "engine oil every 2,000 km".
/// Distinct from [ServiceLogs], which are things that actually happened.
@DataClassName('ServiceItemRow')
@TableIndex(name: 'idx_service_item_vehicle', columns: {#vehicleId})
class ServiceItems extends Table with TableMeta {
  IntColumn get vehicleId =>
      integer().references(Vehicles, #id, onDelete: KeyAction.cascade)();

  TextColumn get name => text().withLength(min: 1, max: 80)();

  /// Interval in metres. Either or both intervals may be set; whichever
  /// comes first wins. Both null ⇒ the item is informational only.
  IntColumn get intervalM => integer().nullable()();
  IntColumn get intervalDays => integer().nullable()();

  IntColumn get lastDoneOdometerM => integer().nullable()();
  IntColumn get lastDoneDateMs => integer().nullable()();

  BoolColumn get isActive => boolean().withDefault(const Constant(true))();

  /// Stable key into the icon map, so icons survive a rename.
  TextColumn get iconKey => text().withDefault(const Constant('wrench'))();

  IntColumn get sortOrder => integer().withDefault(const Constant(0))();
}

/// A completed service. `serviceItemId` null ⇒ a one-off repair with no
/// recurring definition behind it.
@DataClassName('ServiceLogRow')
@TableIndex(
  name: 'idx_service_log_vehicle_date',
  columns: {#vehicleId, #dateMs},
)
@TableIndex(name: 'idx_service_log_item', columns: {#serviceItemId})
class ServiceLogs extends Table with TableMeta {
  IntColumn get vehicleId =>
      integer().references(Vehicles, #id, onDelete: KeyAction.cascade)();

  IntColumn get serviceItemId => integer().nullable().references(
    ServiceItems,
    #id,
    onDelete: KeyAction.setNull,
  )();

  /// Denormalised from the item at log time so history stays readable after
  /// the item is renamed or deleted.
  TextColumn get name => text()();

  IntColumn get dateMs => integer()();
  IntColumn get odometerM => integer()();

  IntColumn get partsCostMinor => integer().withDefault(const Constant(0))();
  IntColumn get laborCostMinor => integer().withDefault(const Constant(0))();

  /// Authoritative total. Usually parts+labour, but kept separate so a
  /// bundled workshop bill can be entered as one number.
  IntColumn get totalCostMinor => integer().withDefault(const Constant(0))();

  TextColumn get workshop => text().nullable()();
  TextColumn get partBrand => text().nullable()();
  TextColumn get notes => text().nullable()();

  /// Snapshot of the next due point at the time of logging, so history shows
  /// what was expected then even if the interval changes later.
  IntColumn get nextDueOdometerM => integer().nullable()();
  IntColumn get nextDueDateMs => integer().nullable()();
}

// ---------------------------------------------------------------------------
// Expenses
// ---------------------------------------------------------------------------

@DataClassName('ExpenseRow')
@TableIndex(name: 'idx_expense_vehicle_date', columns: {#vehicleId, #dateMs})
class Expenses extends Table with TableMeta {
  IntColumn get vehicleId =>
      integer().references(Vehicles, #id, onDelete: KeyAction.cascade)();

  TextColumn get category => textEnum<ExpenseCategory>()();
  IntColumn get dateMs => integer()();
  IntColumn get amountMinor => integer()();
  TextColumn get notes => text().nullable()();

  /// Coverage period for documents. [validUntilMs] drives expiry countdowns
  /// and reminders.
  IntColumn get validFromMs => integer().nullable()();
  IntColumn get validUntilMs => integer().nullable()();
}

// ---------------------------------------------------------------------------
// Rides
// ---------------------------------------------------------------------------

@DataClassName('RideRow')
@TableIndex(name: 'idx_ride_vehicle_start', columns: {#vehicleId, #startTimeMs})
class Rides extends Table with TableMeta {
  IntColumn get vehicleId =>
      integer().references(Vehicles, #id, onDelete: KeyAction.cascade)();

  IntColumn get startTimeMs => integer()();

  /// Null while a ride is in progress. On launch, a ride with no end time is
  /// an interrupted recording and the user is offered resume/save/discard.
  IntColumn get endTimeMs => integer().nullable()();

  IntColumn get distanceMeters => integer().withDefault(const Constant(0))();

  /// Kept apart from [totalSeconds] so average speed excludes time spent
  /// stopped at signals.
  IntColumn get movingSeconds => integer().withDefault(const Constant(0))();
  IntColumn get totalSeconds => integer().withDefault(const Constant(0))();

  /// Metres per second.
  RealColumn get avgSpeed => real().withDefault(const Constant(0))();
  RealColumn get maxSpeed => real().withDefault(const Constant(0))();

  IntColumn get startOdometerM => integer().nullable()();
  IntColumn get endOdometerM => integer().nullable()();

  TextColumn get title => text().nullable()();
  TextColumn get notes => text().nullable()();

  BoolColumn get isComplete => boolean().withDefault(const Constant(false))();
}

/// One GPS sample. Written the instant it arrives — the full path is never
/// held in memory alone, so killing the app mid-ride loses at most the last
/// few seconds.
@DataClassName('RidePointRow')
@TableIndex(name: 'idx_ride_point_ride_ts', columns: {#rideId, #timestampMs})
class RidePoints extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get rideId =>
      integer().references(Rides, #id, onDelete: KeyAction.cascade)();

  RealColumn get lat => real()();
  RealColumn get lng => real()();
  IntColumn get timestampMs => integer()();

  /// Metres per second, as reported by the platform.
  RealColumn get speed => real().nullable()();

  /// Horizontal accuracy in metres. Samples worse than 30 m are discarded
  /// before they ever reach this table.
  RealColumn get accuracy => real().nullable()();
  RealColumn get altitude => real().nullable()();

  /// Marks the first point after a break in recording. The polyline breaks
  /// here instead of drawing a false straight line across the gap.
  BoolColumn get isGapStart => boolean().withDefault(const Constant(false))();
}

// ---------------------------------------------------------------------------
// Reminders
// ---------------------------------------------------------------------------

@DataClassName('ReminderRow')
@TableIndex(name: 'idx_reminder_vehicle', columns: {#vehicleId})
class Reminders extends Table with TableMeta {
  IntColumn get vehicleId =>
      integer().references(Vehicles, #id, onDelete: KeyAction.cascade)();

  TextColumn get type => textEnum<ReminderType>()();
  TextColumn get title => text()();

  IntColumn get dueDateMs => integer().nullable()();
  IntColumn get dueOdometerM => integer().nullable()();

  BoolColumn get isDismissed => boolean().withDefault(const Constant(false))();

  /// When the local notification was last posted, so it is not re-posted on
  /// every recompute.
  IntColumn get notifiedAtMs => integer().nullable()();

  /// The service item or expense this reminder was generated from, so it can
  /// be regenerated idempotently rather than duplicated.
  IntColumn get sourceId => integer().nullable()();
}
