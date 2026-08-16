import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:get/get.dart' hide Value;
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';

import '../data/db/database.dart';
import '../data/models/backup.dart';
import '../data/repositories/backup_repo.dart';

/// A parsed, validated backup ready to apply.
class ParsedBackup {
  const ParsedBackup({
    required this.preview,
    required this.vehicles,
    required this.fuelEntries,
    required this.serviceItems,
    required this.serviceLogs,
    required this.expenses,
    required this.rides,
    required this.ridePoints,
  });

  final BackupPreview preview;
  final List<VehiclesCompanion> vehicles;
  final List<FuelEntriesCompanion> fuelEntries;
  final List<ServiceItemsCompanion> serviceItems;
  final List<ServiceLogsCompanion> serviceLogs;
  final List<ExpensesCompanion> expenses;
  final List<RidesCompanion> rides;
  final List<RidePointsCompanion> ridePoints;
}

/// Reads a backup file, checks it completely, and only then applies it.
///
/// The contract: **validate before touching the database, and on any failure
/// abort entirely with a message naming what was wrong.** There is no partial
/// import. A truncated or hand-mangled file leaves the device exactly as it
/// was.
class ImportService extends GetxService {
  ImportService(this._repo);

  final BackupRepo _repo;

  // -------------------------------------------------------------------
  // Parsing and validation
  // -------------------------------------------------------------------

  /// Reads and fully validates a file. Throws [BackupValidationException]
  /// with a specific message on anything wrong.
  ///
  /// Nothing is written here — the result is handed back so the user can see
  /// a preview and pick a merge strategy before committing.
  Future<ParsedBackup> parseFile(File file) async {
    if (!file.existsSync()) {
      throw const BackupValidationException(
        'That file no longer exists. Pick it again.',
      );
    }

    final String contents;
    try {
      contents = await file.readAsString();
    } on FileSystemException catch (e) {
      throw BackupValidationException(
        'Jatra could not read that file: ${e.osError?.message ?? e.message}.',
      );
    }

    if (contents.trim().isEmpty) {
      throw const BackupValidationException('That file is empty.');
    }

    // Decoding a large backup blocks long enough to drop frames, so it goes
    // to a background isolate like the export does.
    final Map<String, dynamic> json;
    try {
      final decoded = await compute(_decodeJson, contents);
      if (decoded is! Map<String, dynamic>) {
        throw const BackupValidationException(
          'That file is not a Jatra backup — the contents are not a JSON '
          'object.',
        );
      }
      json = decoded;
    } on FormatException catch (e) {
      // The overwhelmingly common cause is a truncated download.
      throw BackupValidationException(
        'That file is not valid JSON — it may have been cut short while '
        'copying. (${e.message})',
      );
    }

    return parseDocument(json);
  }

  /// Validates an already-decoded document. Split out so tests can feed maps
  /// directly.
  ParsedBackup parseDocument(Map<String, dynamic> json) {
    // --- Header ---
    final format = json['format'];
    if (!BackupFormat.isKnownMagic(format)) {
      throw BackupValidationException(
        format == null
            ? 'That file is not a Jatra backup — it has no "format" field.'
            : 'That file says it is "$format", not a Jatra backup.',
      );
    }

    final schemaVersion = json['schemaVersion'];
    if (schemaVersion is! int) {
      throw const BackupValidationException(
        'That backup has no readable schema version.',
      );
    }
    if (schemaVersion > BackupFormat.currentVersion) {
      throw BackupValidationException(
        'That backup was written by a newer version of Jatra '
        '(format $schemaVersion, this build reads up to '
        '${BackupFormat.currentVersion}). Update Jatra and try again.',
      );
    }
    if (schemaVersion < BackupFormat.minimumSupportedVersion) {
      throw BackupValidationException(
        'That backup uses format $schemaVersion, which this version of Jatra '
        'can no longer read.',
      );
    }

    // --- Rows ---
    final vehicles = _parseList(json, 'vehicles', BackupCodec.vehicleFromJson);
    final serviceItems = _parseList(
      json,
      'serviceItems',
      BackupCodec.serviceItemFromJson,
    );
    final fuelEntries = _parseList(
      json,
      'fuelEntries',
      BackupCodec.fuelFromJson,
    );
    final serviceLogs = _parseList(
      json,
      'serviceLogs',
      BackupCodec.serviceLogFromJson,
    );
    final expenses = _parseList(json, 'expenses', BackupCodec.expenseFromJson);
    final rides = _parseList(json, 'rides', BackupCodec.rideFromJson);
    final ridePoints = _parseList(
      json,
      'ridePoints',
      BackupCodec.ridePointFromJson,
    );

    // --- Referential integrity ---
    //
    // Checked before anything is written, because SQLite would otherwise
    // reject an orphan mid-transaction and the message the user sees would
    // be a foreign-key error rather than "fuel entry 42 belongs to a bike
    // that is not in this file".
    final vehicleIds = {for (final v in vehicles) v.id.value};
    final serviceItemIds = {for (final s in serviceItems) s.id.value};
    final rideIds = {for (final r in rides) r.id.value};

    _requireParent(
      fuelEntries,
      'fuel entry',
      vehicleIds,
      (r) => (id: r.id.value, parent: r.vehicleId.value),
      'bike',
    );
    _requireParent(
      serviceItems,
      'service item',
      vehicleIds,
      (r) => (id: r.id.value, parent: r.vehicleId.value),
      'bike',
    );
    _requireParent(
      serviceLogs,
      'service log',
      vehicleIds,
      (r) => (id: r.id.value, parent: r.vehicleId.value),
      'bike',
    );
    _requireParent(
      expenses,
      'expense',
      vehicleIds,
      (r) => (id: r.id.value, parent: r.vehicleId.value),
      'bike',
    );
    _requireParent(
      rides,
      'ride',
      vehicleIds,
      (r) => (id: r.id.value, parent: r.vehicleId.value),
      'bike',
    );
    _requireParent(
      ridePoints,
      'ride point',
      rideIds,
      (r) => (id: r.id.value, parent: r.rideId.value),
      'ride',
    );

    // A service log may legitimately have no item behind it — that is a
    // one-off repair — but if it names one, that one must exist.
    for (final log in serviceLogs) {
      final itemId = log.serviceItemId.value;
      if (itemId != null && !serviceItemIds.contains(itemId)) {
        throw BackupValidationException(
          'Service log ${log.id.value} refers to service item $itemId, which '
          'is not in this file.',
        );
      }
    }

    _requireUniqueIds(vehicles.map((v) => v.id.value), 'bikes');
    _requireUniqueIds(fuelEntries.map((f) => f.id.value), 'fuel entries');
    _requireUniqueIds(rides.map((r) => r.id.value), 'rides');

    // --- Preview ---
    final dates = <int>[
      for (final f in fuelEntries) f.dateMs.value,
      for (final s in serviceLogs) s.dateMs.value,
      for (final e in expenses) e.dateMs.value,
      for (final r in rides) r.startTimeMs.value,
    ]..sort();

    final counts = {
      'vehicles': vehicles.length,
      'fuelEntries': fuelEntries.length,
      'serviceItems': serviceItems.length,
      'serviceLogs': serviceLogs.length,
      'expenses': expenses.length,
      'rides': rides.length,
      'ridePoints': ridePoints.length,
    };

    return ParsedBackup(
      preview: BackupPreview(
        exportedAt: DateTime.tryParse(json['exportedAt'] as String? ?? ''),
        appVersion: json['appVersion'] as String? ?? 'unknown',
        schemaVersion: schemaVersion,
        counts: counts,
        vehicleNames: [for (final v in vehicles) v.name.value],
        includesRidePoints:
            json['includesRidePoints'] as bool? ?? ridePoints.isNotEmpty,
        earliestMs: dates.isEmpty ? null : dates.first,
        latestMs: dates.isEmpty ? null : dates.last,
      ),
      vehicles: vehicles,
      fuelEntries: fuelEntries,
      serviceItems: serviceItems,
      serviceLogs: serviceLogs,
      expenses: expenses,
      rides: rides,
      ridePoints: ridePoints,
    );
  }

  static List<T> _parseList<T>(
    Map<String, dynamic> json,
    String key,
    T Function(Map<String, dynamic>) parse,
  ) {
    final raw = json[key];
    // A missing section is treated as empty: a backup exported without ride
    // points has no "ridePoints" key, and that is not an error.
    if (raw == null) return const [];
    if (raw is! List) {
      throw BackupValidationException(
        'The "$key" section should be a list, but it is a '
        '${raw.runtimeType}.',
      );
    }

    final result = <T>[];
    for (var i = 0; i < raw.length; i++) {
      final item = raw[i];
      if (item is! Map<String, dynamic>) {
        throw BackupValidationException(
          'Entry ${i + 1} in "$key" is not an object.',
        );
      }
      try {
        result.add(parse(item));
      } on BackupValidationException catch (e) {
        // Re-thrown with the location, so the user knows *where* it broke.
        throw BackupValidationException(
          'Entry ${i + 1} in "$key" is unusable: ${e.message}',
        );
      } on TypeError {
        throw BackupValidationException(
          'Entry ${i + 1} in "$key" has a field of the wrong type.',
        );
      }
    }
    return result;
  }

  static void _requireParent<T>(
    List<T> rows,
    String rowLabel,
    Set<int> parentIds,
    ({int id, int parent}) Function(T) extract,
    String parentLabel,
  ) {
    for (final row in rows) {
      final ids = extract(row);
      if (!parentIds.contains(ids.parent)) {
        throw BackupValidationException(
          'The $rowLabel with id ${ids.id} belongs to $parentLabel '
          '${ids.parent}, which is not in this file. The backup is '
          'incomplete, so nothing has been imported.',
        );
      }
    }
  }

  static void _requireUniqueIds(Iterable<int> ids, String label) {
    final seen = <int>{};
    for (final id in ids) {
      if (!seen.add(id)) {
        throw BackupValidationException(
          'The $label section contains two records with id $id. Jatra cannot '
          'tell which one is right, so nothing has been imported.',
        );
      }
    }
  }

  // -------------------------------------------------------------------
  // Applying
  // -------------------------------------------------------------------

  /// Writes a parsed backup, in one transaction.
  ///
  /// A safety copy of the current database is taken first for any strategy
  /// that can destroy data, and its path is returned so the UI can tell the
  /// user where it went.
  ///
  /// If that copy cannot be made, the import is **refused**. Proceeding to
  /// wipe someone's data without the fallback in place would be exactly the
  /// wrong tradeoff.
  ///
  /// [createSafetyCopy] exists for tests, which run against an in-memory
  /// database that has no file to copy. Production callers leave it alone.
  Future<File?> apply(
    ParsedBackup backup, {
    required MergeStrategy strategy,
    bool createSafetyCopy = true,
  }) async {
    File? safetyCopy;
    if (strategy.isDestructive && createSafetyCopy) {
      try {
        safetyCopy = await createSafetyBackup();
      } on Object catch (e) {
        throw BackupValidationException(
          'Jatra could not save a safety copy of your current data, so it has '
          'not replaced anything. ($e)',
        );
      }
    }

    await _repo.restore(
      strategy: strategy,
      vehicles: backup.vehicles,
      fuelEntries: backup.fuelEntries,
      serviceItems: backup.serviceItems,
      serviceLogs: backup.serviceLogs,
      expenses: backup.expenses,
      rides: backup.rides,
      ridePoints: backup.ridePoints,
    );

    return safetyCopy;
  }

  /// Snapshots the live database into app storage before a destructive
  /// import. Kept inside the app's own directory so it survives the import
  /// and needs no permission to write.
  Future<File> createSafetyBackup() async {
    final dir = Directory(
      '${(await getApplicationDocumentsDirectory()).path}/safety_backups',
    );
    if (!dir.existsSync()) dir.createSync(recursive: true);

    final stamp = DateFormat('yyyy-MM-dd_HHmmss').format(DateTime.now());
    return _repo.copyDatabaseTo('${dir.path}/before_import_$stamp.sqlite');
  }

  /// Restores the raw database file. The caller must restart the app
  /// afterwards — every open Drift stream is pointing at the old file.
  Future<void> restoreDatabaseFile(File source) async {
    if (!source.existsSync()) {
      throw const BackupValidationException(
        'That file no longer exists. Pick it again.',
      );
    }

    // A SQLite file starts with a fixed 16-byte header. Checking it turns
    // "picked the wrong file" into a clear message instead of a crash on the
    // next query.
    final header = await source.openRead(0, 16).first;
    const magic = 'SQLite format 3';
    if (header.length < 16 || String.fromCharCodes(header.take(15)) != magic) {
      throw const BackupValidationException(
        'That is not a Jatra database file. Pick a .sqlite backup, or use a '
        '.json backup instead.',
      );
    }

    await _repo.replaceDatabaseWith(source);
  }
}

/// Top-level so it can cross an isolate boundary.
Object? _decodeJson(String contents) => jsonDecode(contents);
