import 'package:drift/drift.dart' show Value;

import '../db/database.dart';

/// The JSON backup format.
///
/// Design rules, all load-bearing:
///
/// * **IDs are preserved.** Export → wipe → import must reproduce the
///   database exactly, relationships intact.
/// * **Dates are ISO 8601 with a timezone offset**, not epoch integers, so a
///   human can read the file and a spreadsheet can parse it.
/// * **Quantities stay canonical** — metres, millilitres, currency minor
///   units — and the header says so, making the file self-describing rather
///   than requiring this source to interpret.
/// * **Ride points are optional.** They dominate file size; a backup without
///   them is a few hundred KB where one with them can be tens of MB.
abstract final class BackupFormat {
  static const magic = 'jatra-backup';

  /// What [magic] was before the app was renamed from Odo. Still accepted on
  /// import — a file exported from an older build has to restore into this
  /// one — but never written.
  static const legacyMagic = 'odo-backup';

  static bool isKnownMagic(Object? format) =>
      format == magic || format == legacyMagic;

  /// The newest schema this build can *write*.
  static const currentVersion = 1;

  /// The oldest schema this build can *read*. Anything older would need a
  /// migration path that does not exist yet.
  static const minimumSupportedVersion = 1;

  static const units = <String, String>{
    'distance': 'metres',
    'volume': 'millilitres',
    'money': 'currency minor units (e.g. paisa)',
    'time': 'ISO 8601 with offset',
  };
}

/// Everything in the database, ready to encode.
class BackupData {
  const BackupData({
    required this.vehicles,
    required this.fuelEntries,
    required this.serviceItems,
    required this.serviceLogs,
    required this.expenses,
    required this.rides,
    required this.ridePoints,
    this.includesRidePoints = true,
  });

  final List<VehicleRow> vehicles;
  final List<FuelEntryRow> fuelEntries;
  final List<ServiceItemRow> serviceItems;
  final List<ServiceLogRow> serviceLogs;
  final List<ExpenseRow> expenses;
  final List<RideRow> rides;
  final List<RidePointRow> ridePoints;

  /// False when the user chose to leave GPS data out. Recorded so an import
  /// can tell "this backup had no points" from "this bike had no rides".
  final bool includesRidePoints;

  Map<String, int> get counts => {
    'vehicles': vehicles.length,
    'fuelEntries': fuelEntries.length,
    'serviceItems': serviceItems.length,
    'serviceLogs': serviceLogs.length,
    'expenses': expenses.length,
    'rides': rides.length,
    'ridePoints': ridePoints.length,
  };

  int get totalRecords => counts.values.fold(0, (sum, count) => sum + count);
}

/// Reasons an import was refused. Each carries a message that names the
/// specific problem — never "Invalid file".
class BackupValidationException implements Exception {
  const BackupValidationException(this.message);

  final String message;

  @override
  String toString() => message;
}

/// How an import reconciles with what is already on the device.
enum MergeStrategy {
  /// Wipe everything, then restore. Requires typed confirmation.
  replaceAll,

  /// Add only records whose ID is not already present.
  keepMine,

  /// Overwrite conflicts with the imported version.
  preferImported;

  String get label => switch (this) {
    MergeStrategy.replaceAll => 'Replace everything',
    MergeStrategy.keepMine => 'Merge, keep mine',
    MergeStrategy.preferImported => 'Merge, prefer imported',
  };

  String get description => switch (this) {
    MergeStrategy.replaceAll =>
      'Delete everything on this phone first, then restore the backup '
          'exactly as it was.',
    MergeStrategy.keepMine =>
      'Add records this phone does not have. Anything already here is '
          'left untouched.',
    MergeStrategy.preferImported =>
      'Add missing records and overwrite the ones that clash with the '
          'backup’s version.',
  };

  bool get isDestructive => this == MergeStrategy.replaceAll;
}

/// What a file contains, shown to the user *before* they choose a strategy.
class BackupPreview {
  const BackupPreview({
    required this.exportedAt,
    required this.appVersion,
    required this.schemaVersion,
    required this.counts,
    required this.vehicleNames,
    required this.includesRidePoints,
    required this.earliestMs,
    required this.latestMs,
  });

  final DateTime? exportedAt;
  final String appVersion;
  final int schemaVersion;
  final Map<String, int> counts;
  final List<String> vehicleNames;
  final bool includesRidePoints;

  /// Span of the records inside, so "this is my old phone's backup" is
  /// obvious at a glance.
  final int? earliestMs;
  final int? latestMs;

  int get totalRecords => counts.values.fold(0, (sum, c) => sum + c);
}

// ---------------------------------------------------------------------------
// Encoding
// ---------------------------------------------------------------------------

/// Epoch millis → ISO 8601 with the device's current offset.
String? _isoOrNull(int? ms) => ms == null
    ? null
    : DateTime.fromMillisecondsSinceEpoch(ms).toIso8601String();

String _iso(int ms) =>
    DateTime.fromMillisecondsSinceEpoch(ms).toIso8601String();

/// ISO 8601 → epoch millis. Accepts a bare integer too, so a file
/// hand-edited by someone who prefers epochs still imports.
int? _msOrNull(Object? value) {
  if (value == null) return null;
  if (value is int) return value;
  if (value is String) {
    final parsed = DateTime.tryParse(value);
    if (parsed != null) return parsed.millisecondsSinceEpoch;
    return int.tryParse(value);
  }
  return null;
}

int _msRequired(Object? value, String field) {
  final ms = _msOrNull(value);
  if (ms == null) {
    throw BackupValidationException(
      'The field "$field" is missing or is not a date Jatra can read.',
    );
  }
  return ms;
}

T _require<T>(Map<String, dynamic> json, String field) {
  final value = json[field];
  if (value is! T) {
    throw BackupValidationException(
      'The field "$field" is missing or has the wrong type.',
    );
  }
  return value;
}

/// Serialisers, one per table.
///
/// Written out by hand rather than generated: the JSON is a published format
/// that people and other tools will read, so its field names must not move
/// when a Dart class is refactored.
abstract final class BackupCodec {
  // --- Vehicles ---

  static Map<String, dynamic> vehicleToJson(VehicleRow v) => {
    'id': v.id,
    'name': v.name,
    'make': v.make,
    'model': v.model,
    'year': v.year,
    'engineCc': v.engineCc,
    'registrationNo': v.registrationNo,
    'fuelType': v.fuelType.name,
    'purchaseDate': _isoOrNull(v.purchaseDateMs),
    'purchasePriceMinor': v.purchasePriceMinor,
    'initialOdometerM': v.initialOdometerM,
    'currentValueEstimateMinor': v.currentValueEstimateMinor,
    'tankCapacityMl': v.tankCapacityMl,
    'distanceUnit': v.distanceUnit.name,
    'volumeUnit': v.volumeUnit.name,
    'currency': v.currency,
    'isDefault': v.isDefault,
    'colorTag': v.colorTag,
    'isArchived': v.isArchived,
    'createdAt': _iso(v.createdAt),
    'updatedAt': _iso(v.updatedAt),
    'deletedAt': _isoOrNull(v.deletedAt),
  };

  static VehiclesCompanion vehicleFromJson(Map<String, dynamic> j) {
    return VehiclesCompanion(
      id: Value(_require<int>(j, 'id')),
      name: Value(_require<String>(j, 'name')),
      make: Value(j['make'] as String?),
      model: Value(j['model'] as String?),
      year: Value(j['year'] as int?),
      engineCc: Value(j['engineCc'] as int?),
      registrationNo: Value(j['registrationNo'] as String?),
      fuelType: Value(_enumOr(FuelType.values, j['fuelType'], FuelType.petrol)),
      purchaseDateMs: Value(_msOrNull(j['purchaseDate'])),
      purchasePriceMinor: Value(j['purchasePriceMinor'] as int?),
      initialOdometerM: Value(j['initialOdometerM'] as int? ?? 0),
      currentValueEstimateMinor: Value(j['currentValueEstimateMinor'] as int?),
      tankCapacityMl: Value(j['tankCapacityMl'] as int?),
      distanceUnit: Value(
        _enumOr(DistanceUnit.values, j['distanceUnit'], DistanceUnit.km),
      ),
      volumeUnit: Value(
        _enumOr(VolumeUnit.values, j['volumeUnit'], VolumeUnit.l),
      ),
      currency: Value(j['currency'] as String? ?? 'BDT'),
      isDefault: Value(j['isDefault'] as bool? ?? false),
      colorTag: Value(j['colorTag'] as int? ?? 0),
      isArchived: Value(j['isArchived'] as bool? ?? false),
      createdAt: Value(_msRequired(j['createdAt'], 'createdAt')),
      updatedAt: Value(_msRequired(j['updatedAt'], 'updatedAt')),
      deletedAt: Value(_msOrNull(j['deletedAt'])),
    );
  }

  // --- Fuel entries ---

  static Map<String, dynamic> fuelToJson(FuelEntryRow f) => {
    'id': f.id,
    'vehicleId': f.vehicleId,
    'date': _iso(f.dateMs),
    'odometerM': f.odometerM,
    'volumeMl': f.volumeMl,
    'pricePerLitreMinor': f.pricePerUnitMinor,
    'totalCostMinor': f.totalCostMinor,
    'isFullTank': f.isFullTank,
    'isMissedEntry': f.isMissedEntry,
    'station': f.station,
    'notes': f.notes,
    'createdAt': _iso(f.createdAt),
    'updatedAt': _iso(f.updatedAt),
    'deletedAt': _isoOrNull(f.deletedAt),
  };

  static FuelEntriesCompanion fuelFromJson(Map<String, dynamic> j) {
    return FuelEntriesCompanion(
      id: Value(_require<int>(j, 'id')),
      vehicleId: Value(_require<int>(j, 'vehicleId')),
      dateMs: Value(_msRequired(j['date'], 'date')),
      odometerM: Value(_require<int>(j, 'odometerM')),
      volumeMl: Value(_require<int>(j, 'volumeMl')),
      pricePerUnitMinor: Value(j['pricePerLitreMinor'] as int? ?? 0),
      totalCostMinor: Value(_require<int>(j, 'totalCostMinor')),
      isFullTank: Value(j['isFullTank'] as bool? ?? true),
      isMissedEntry: Value(j['isMissedEntry'] as bool? ?? false),
      station: Value(j['station'] as String?),
      notes: Value(j['notes'] as String?),
      createdAt: Value(_msRequired(j['createdAt'], 'createdAt')),
      updatedAt: Value(_msRequired(j['updatedAt'], 'updatedAt')),
      deletedAt: Value(_msOrNull(j['deletedAt'])),
    );
  }

  // --- Service items ---

  static Map<String, dynamic> serviceItemToJson(ServiceItemRow s) => {
    'id': s.id,
    'vehicleId': s.vehicleId,
    'name': s.name,
    'intervalM': s.intervalM,
    'intervalDays': s.intervalDays,
    'lastDoneOdometerM': s.lastDoneOdometerM,
    'lastDoneDate': _isoOrNull(s.lastDoneDateMs),
    'isActive': s.isActive,
    'iconKey': s.iconKey,
    'sortOrder': s.sortOrder,
    'createdAt': _iso(s.createdAt),
    'updatedAt': _iso(s.updatedAt),
    'deletedAt': _isoOrNull(s.deletedAt),
  };

  static ServiceItemsCompanion serviceItemFromJson(Map<String, dynamic> j) {
    return ServiceItemsCompanion(
      id: Value(_require<int>(j, 'id')),
      vehicleId: Value(_require<int>(j, 'vehicleId')),
      name: Value(_require<String>(j, 'name')),
      intervalM: Value(j['intervalM'] as int?),
      intervalDays: Value(j['intervalDays'] as int?),
      lastDoneOdometerM: Value(j['lastDoneOdometerM'] as int?),
      lastDoneDateMs: Value(_msOrNull(j['lastDoneDate'])),
      isActive: Value(j['isActive'] as bool? ?? true),
      iconKey: Value(j['iconKey'] as String? ?? 'wrench'),
      sortOrder: Value(j['sortOrder'] as int? ?? 0),
      createdAt: Value(_msRequired(j['createdAt'], 'createdAt')),
      updatedAt: Value(_msRequired(j['updatedAt'], 'updatedAt')),
      deletedAt: Value(_msOrNull(j['deletedAt'])),
    );
  }

  // --- Service logs ---

  static Map<String, dynamic> serviceLogToJson(ServiceLogRow s) => {
    'id': s.id,
    'vehicleId': s.vehicleId,
    'serviceItemId': s.serviceItemId,
    'name': s.name,
    'date': _iso(s.dateMs),
    'odometerM': s.odometerM,
    'partsCostMinor': s.partsCostMinor,
    'laborCostMinor': s.laborCostMinor,
    'totalCostMinor': s.totalCostMinor,
    'workshop': s.workshop,
    'partBrand': s.partBrand,
    'notes': s.notes,
    'nextDueOdometerM': s.nextDueOdometerM,
    'nextDueDate': _isoOrNull(s.nextDueDateMs),
    'createdAt': _iso(s.createdAt),
    'updatedAt': _iso(s.updatedAt),
    'deletedAt': _isoOrNull(s.deletedAt),
  };

  static ServiceLogsCompanion serviceLogFromJson(Map<String, dynamic> j) {
    return ServiceLogsCompanion(
      id: Value(_require<int>(j, 'id')),
      vehicleId: Value(_require<int>(j, 'vehicleId')),
      serviceItemId: Value(j['serviceItemId'] as int?),
      name: Value(_require<String>(j, 'name')),
      dateMs: Value(_msRequired(j['date'], 'date')),
      odometerM: Value(_require<int>(j, 'odometerM')),
      partsCostMinor: Value(j['partsCostMinor'] as int? ?? 0),
      laborCostMinor: Value(j['laborCostMinor'] as int? ?? 0),
      totalCostMinor: Value(j['totalCostMinor'] as int? ?? 0),
      workshop: Value(j['workshop'] as String?),
      partBrand: Value(j['partBrand'] as String?),
      notes: Value(j['notes'] as String?),
      nextDueOdometerM: Value(j['nextDueOdometerM'] as int?),
      nextDueDateMs: Value(_msOrNull(j['nextDueDate'])),
      createdAt: Value(_msRequired(j['createdAt'], 'createdAt')),
      updatedAt: Value(_msRequired(j['updatedAt'], 'updatedAt')),
      deletedAt: Value(_msOrNull(j['deletedAt'])),
    );
  }

  // --- Expenses ---

  static Map<String, dynamic> expenseToJson(ExpenseRow e) => {
    'id': e.id,
    'vehicleId': e.vehicleId,
    'category': e.category.name,
    'date': _iso(e.dateMs),
    'amountMinor': e.amountMinor,
    'notes': e.notes,
    'validFrom': _isoOrNull(e.validFromMs),
    'validUntil': _isoOrNull(e.validUntilMs),
    'createdAt': _iso(e.createdAt),
    'updatedAt': _iso(e.updatedAt),
    'deletedAt': _isoOrNull(e.deletedAt),
  };

  static ExpensesCompanion expenseFromJson(Map<String, dynamic> j) {
    return ExpensesCompanion(
      id: Value(_require<int>(j, 'id')),
      vehicleId: Value(_require<int>(j, 'vehicleId')),
      category: Value(
        _enumOr(ExpenseCategory.values, j['category'], ExpenseCategory.other),
      ),
      dateMs: Value(_msRequired(j['date'], 'date')),
      amountMinor: Value(_require<int>(j, 'amountMinor')),
      notes: Value(j['notes'] as String?),
      validFromMs: Value(_msOrNull(j['validFrom'])),
      validUntilMs: Value(_msOrNull(j['validUntil'])),
      createdAt: Value(_msRequired(j['createdAt'], 'createdAt')),
      updatedAt: Value(_msRequired(j['updatedAt'], 'updatedAt')),
      deletedAt: Value(_msOrNull(j['deletedAt'])),
    );
  }

  // --- Rides ---

  static Map<String, dynamic> rideToJson(RideRow r) => {
    'id': r.id,
    'vehicleId': r.vehicleId,
    'startTime': _iso(r.startTimeMs),
    'endTime': _isoOrNull(r.endTimeMs),
    'distanceMeters': r.distanceMeters,
    'movingSeconds': r.movingSeconds,
    'totalSeconds': r.totalSeconds,
    'avgSpeedMps': r.avgSpeed,
    'maxSpeedMps': r.maxSpeed,
    'startOdometerM': r.startOdometerM,
    'endOdometerM': r.endOdometerM,
    'title': r.title,
    'notes': r.notes,
    'isComplete': r.isComplete,
    'createdAt': _iso(r.createdAt),
    'updatedAt': _iso(r.updatedAt),
    'deletedAt': _isoOrNull(r.deletedAt),
  };

  static RidesCompanion rideFromJson(Map<String, dynamic> j) {
    return RidesCompanion(
      id: Value(_require<int>(j, 'id')),
      vehicleId: Value(_require<int>(j, 'vehicleId')),
      startTimeMs: Value(_msRequired(j['startTime'], 'startTime')),
      endTimeMs: Value(_msOrNull(j['endTime'])),
      distanceMeters: Value(j['distanceMeters'] as int? ?? 0),
      movingSeconds: Value(j['movingSeconds'] as int? ?? 0),
      totalSeconds: Value(j['totalSeconds'] as int? ?? 0),
      avgSpeed: Value((j['avgSpeedMps'] as num?)?.toDouble() ?? 0),
      maxSpeed: Value((j['maxSpeedMps'] as num?)?.toDouble() ?? 0),
      startOdometerM: Value(j['startOdometerM'] as int?),
      endOdometerM: Value(j['endOdometerM'] as int?),
      title: Value(j['title'] as String?),
      notes: Value(j['notes'] as String?),
      isComplete: Value(j['isComplete'] as bool? ?? false),
      createdAt: Value(_msRequired(j['createdAt'], 'createdAt')),
      updatedAt: Value(_msRequired(j['updatedAt'], 'updatedAt')),
      deletedAt: Value(_msOrNull(j['deletedAt'])),
    );
  }

  // --- Ride points ---
  //
  // Deliberately terse keys. A 41,000-point ride is the single biggest thing
  // in a backup, and full field names would roughly double the file.

  static Map<String, dynamic> ridePointToJson(RidePointRow p) => {
    'id': p.id,
    'rideId': p.rideId,
    'lat': p.lat,
    'lng': p.lng,
    't': p.timestampMs,
    'speed': p.speed,
    'accuracy': p.accuracy,
    'altitude': p.altitude,
    'gap': p.isGapStart,
  };

  static RidePointsCompanion ridePointFromJson(Map<String, dynamic> j) {
    return RidePointsCompanion(
      id: Value(_require<int>(j, 'id')),
      rideId: Value(_require<int>(j, 'rideId')),
      lat: Value((j['lat'] as num).toDouble()),
      lng: Value((j['lng'] as num).toDouble()),
      timestampMs: Value(_msRequired(j['t'], 't')),
      speed: Value((j['speed'] as num?)?.toDouble()),
      accuracy: Value((j['accuracy'] as num?)?.toDouble()),
      altitude: Value((j['altitude'] as num?)?.toDouble()),
      isGapStart: Value(j['gap'] as bool? ?? false),
    );
  }

  /// Reads an enum by name, falling back rather than throwing.
  ///
  /// A file written by a newer Jatra may carry a category this build has never
  /// heard of. Losing one label is a far better outcome than refusing the
  /// whole import.
  static T _enumOr<T extends Enum>(List<T> values, Object? name, T fallback) {
    if (name is! String) return fallback;
    for (final value in values) {
      if (value.name == name) return value;
    }
    return fallback;
  }
}
