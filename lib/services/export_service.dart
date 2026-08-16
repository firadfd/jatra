import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:get/get.dart' hide Value;
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../core/utils/money.dart';
import '../data/models/backup.dart';
import '../data/repositories/backup_repo.dart';

/// A file produced for the user, ready to share.
class ExportResult {
  const ExportResult({
    required this.file,
    required this.recordCount,
    required this.sizeBytes,
  });

  final File file;
  final int recordCount;
  final int sizeBytes;
}

/// Writes JSON backups, CSV tables and raw database copies.
///
/// Nothing here touches the network. `share_plus` hands the file to the
/// Android share sheet and the user decides where it goes — Jatra itself never
/// transmits anything.
class ExportService extends GetxService {
  ExportService(this._repo);

  final BackupRepo _repo;

  /// `odo_backup_2026-08-04_1432.json`
  static String backupFileName([DateTime? at]) {
    final now = at ?? DateTime.now();
    return 'odo_backup_${DateFormat('yyyy-MM-dd_HHmm').format(now)}.json';
  }

  /// Builds the full JSON backup.
  ///
  /// The encode runs on a background isolate via [compute]: a log with GPS
  /// data can reach tens of megabytes, and encoding that on the UI isolate
  /// would freeze the app mid-tap.
  Future<ExportResult> exportJson({
    bool includeRidePoints = false,
    bool pretty = true,
  }) async {
    final data = await _repo.readAll(includeRidePoints: includeRidePoints);
    final document = buildDocument(data);

    final json = await compute(_encodeJson, (
      document: document,
      pretty: pretty,
    ));

    final file = File(
      '${(await getTemporaryDirectory()).path}/'
      '${backupFileName()}',
    );
    await file.writeAsString(json);

    return ExportResult(
      file: file,
      recordCount: data.totalRecords,
      sizeBytes: await file.length(),
    );
  }

  /// The document structure, separated from encoding so it can be asserted
  /// on in tests without going near the filesystem.
  static Map<String, dynamic> buildDocument(BackupData data) {
    return {
      'format': BackupFormat.magic,
      'schemaVersion': BackupFormat.currentVersion,
      'exportedAt': DateTime.now().toIso8601String(),
      'appVersion': appVersion,
      'units': BackupFormat.units,
      'includesRidePoints': data.includesRidePoints,
      'counts': data.counts,
      'vehicles': data.vehicles.map(BackupCodec.vehicleToJson).toList(),
      'fuelEntries': data.fuelEntries.map(BackupCodec.fuelToJson).toList(),
      'serviceItems': data.serviceItems
          .map(BackupCodec.serviceItemToJson)
          .toList(),
      'serviceLogs': data.serviceLogs
          .map(BackupCodec.serviceLogToJson)
          .toList(),
      'expenses': data.expenses.map(BackupCodec.expenseToJson).toList(),
      'rides': data.rides.map(BackupCodec.rideToJson).toList(),
      'ridePoints': data.ridePoints.map(BackupCodec.ridePointToJson).toList(),
    };
  }

  /// Kept in step with `pubspec.yaml`. Written into every backup so a file
  /// can be traced to the build that produced it.
  static const appVersion = '1.0.0';

  /// Hands the file to the system share sheet. Where it goes from there is
  /// the user's call — Jatra never uploads anything itself.
  Future<void> share(List<File> files, {required String subject}) async {
    if (files.isEmpty) return;
    await Share.shareXFiles([
      for (final f in files) XFile(f.path),
    ], subject: subject);
  }

  // -------------------------------------------------------------------
  // CSV
  // -------------------------------------------------------------------

  /// One CSV per table, for people who want a spreadsheet.
  ///
  /// Values are converted to human units here — kilometres, litres, major
  /// currency units — because a spreadsheet is for reading, not for
  /// round-tripping. JSON is the format that preserves everything exactly.
  Future<List<File>> exportCsv() async {
    final data = await _repo.readAll(includeRidePoints: false);
    final dir = await getTemporaryDirectory();
    final stamp = DateFormat('yyyy-MM-dd_HHmm').format(DateTime.now());
    final files = <File>[];

    Future<void> write(String name, String contents) async {
      final file = File('${dir.path}/odo_${name}_$stamp.csv');
      await file.writeAsString(contents);
      files.add(file);
    }

    final vehiclesById = {for (final v in data.vehicles) v.id: v};
    String vehicleName(int id) => vehiclesById[id]?.name ?? 'Unknown';

    // Fuel and service logs matter most, so they lead.
    await write(
      'fuel',
      csvTable(
        const [
          'Date',
          'Bike',
          'Odometer (km)',
          'Volume (L)',
          'Price/L',
          'Total',
          'Currency',
          'Full tank',
          'Missed entry',
          'Station',
          'Notes',
        ],
        [
          for (final f in data.fuelEntries.where((f) => f.deletedAt == null))
            [
              _date(f.dateMs),
              vehicleName(f.vehicleId),
              (f.odometerM / 1000).toStringAsFixed(1),
              (f.volumeMl / 1000).toStringAsFixed(2),
              Money(f.pricePerUnitMinor).asMajor.toStringAsFixed(2),
              Money(f.totalCostMinor).asMajor.toStringAsFixed(2),
              vehiclesById[f.vehicleId]?.currency ?? '',
              f.isFullTank ? 'yes' : 'no',
              f.isMissedEntry ? 'yes' : 'no',
              f.station ?? '',
              f.notes ?? '',
            ],
        ],
      ),
    );

    await write(
      'services',
      csvTable(
        const [
          'Date',
          'Bike',
          'Service',
          'Odometer (km)',
          'Parts',
          'Labour',
          'Total',
          'Currency',
          'Workshop',
          'Part brand',
          'Notes',
        ],
        [
          for (final s in data.serviceLogs.where((s) => s.deletedAt == null))
            [
              _date(s.dateMs),
              vehicleName(s.vehicleId),
              s.name,
              (s.odometerM / 1000).toStringAsFixed(1),
              Money(s.partsCostMinor).asMajor.toStringAsFixed(2),
              Money(s.laborCostMinor).asMajor.toStringAsFixed(2),
              Money(s.totalCostMinor).asMajor.toStringAsFixed(2),
              vehiclesById[s.vehicleId]?.currency ?? '',
              s.workshop ?? '',
              s.partBrand ?? '',
              s.notes ?? '',
            ],
        ],
      ),
    );

    await write(
      'expenses',
      csvTable(
        const [
          'Date',
          'Bike',
          'Category',
          'Amount',
          'Currency',
          'Valid from',
          'Valid until',
          'Notes',
        ],
        [
          for (final e in data.expenses.where((e) => e.deletedAt == null))
            [
              _date(e.dateMs),
              vehicleName(e.vehicleId),
              e.category.label,
              Money(e.amountMinor).asMajor.toStringAsFixed(2),
              vehiclesById[e.vehicleId]?.currency ?? '',
              e.validFromMs == null ? '' : _date(e.validFromMs!),
              e.validUntilMs == null ? '' : _date(e.validUntilMs!),
              e.notes ?? '',
            ],
        ],
      ),
    );

    await write(
      'rides',
      csvTable(
        const [
          'Start',
          'End',
          'Bike',
          'Title',
          'Distance (km)',
          'Moving time (min)',
          'Total time (min)',
          'Average speed (km/h)',
          'Max speed (km/h)',
        ],
        [
          for (final r in data.rides.where((r) => r.deletedAt == null))
            [
              _dateTime(r.startTimeMs),
              r.endTimeMs == null ? '' : _dateTime(r.endTimeMs!),
              vehicleName(r.vehicleId),
              r.title ?? '',
              (r.distanceMeters / 1000).toStringAsFixed(2),
              (r.movingSeconds / 60).toStringAsFixed(1),
              (r.totalSeconds / 60).toStringAsFixed(1),
              (r.avgSpeed * 3.6).toStringAsFixed(1),
              (r.maxSpeed * 3.6).toStringAsFixed(1),
            ],
        ],
      ),
    );

    return files;
  }

  /// RFC 4180: quote any field containing a comma, quote or newline, and
  /// double the quotes inside it.
  @visibleForTesting
  static String csvTable(List<String> header, List<List<String>> rows) {
    final buffer = StringBuffer()..writeln(header.map(csvEscape).join(','));
    for (final row in rows) {
      buffer.writeln(row.map(csvEscape).join(','));
    }
    return buffer.toString();
  }

  @visibleForTesting
  static String csvEscape(String value) {
    if (!value.contains(RegExp('[,"\n\r]'))) return value;
    return '"${value.replaceAll('"', '""')}"';
  }

  static String _date(int ms) =>
      DateFormat('yyyy-MM-dd').format(DateTime.fromMillisecondsSinceEpoch(ms));

  static String _dateTime(int ms) => DateFormat(
    'yyyy-MM-dd HH:mm',
  ).format(DateTime.fromMillisecondsSinceEpoch(ms));

  // -------------------------------------------------------------------
  // Raw database
  // -------------------------------------------------------------------

  Future<ExportResult> exportDatabase() async {
    final stamp = DateFormat('yyyy-MM-dd_HHmm').format(DateTime.now());
    final path = '${(await getTemporaryDirectory()).path}/odo_$stamp.sqlite';
    final file = await _repo.copyDatabaseTo(path);

    return ExportResult(
      file: file,
      recordCount: 0,
      sizeBytes: await file.length(),
    );
  }
}

/// Top-level so it can cross an isolate boundary.
String _encodeJson(({Map<String, dynamic> document, bool pretty}) args) {
  return args.pretty
      ? const JsonEncoder.withIndent('  ').convert(args.document)
      : jsonEncode(args.document);
}
