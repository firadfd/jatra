import 'dart:convert';

import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jatra/core/utils/clock.dart';
import 'package:jatra/core/utils/money.dart';
import 'package:jatra/data/db/database.dart';
import 'package:jatra/data/db/demo_seed.dart';
import 'package:jatra/data/models/backup.dart';
import 'package:jatra/data/repositories/backup_repo.dart';
import 'package:jatra/data/repositories/expense_repo.dart';
import 'package:jatra/data/repositories/fuel_repo.dart';
import 'package:jatra/data/repositories/service_repo.dart';
import 'package:jatra/data/repositories/vehicle_repo.dart';
import 'package:jatra/services/export_service.dart';
import 'package:jatra/services/import_service.dart';

void main() {
  late AppDatabase db;
  late BackupRepo repo;
  late ImportService importer;

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    repo = BackupRepo(db);
    importer = ImportService(repo);
    Clock.freeze(DateTime.utc(2026, 8, 4, 12));
  });

  tearDown(() async {
    Clock.freeze(null);
    await db.close();
  });

  /// The full export → encode → decode → import cycle, without the
  /// filesystem.
  Future<ParsedBackup> roundTrip({bool includeRidePoints = false}) async {
    final data = await repo.readAll(includeRidePoints: includeRidePoints);
    final document = ExportService.buildDocument(data);
    // Through a real string, so anything that fails to encode is caught.
    final decoded = jsonDecode(jsonEncode(document)) as Map<String, dynamic>;
    return importer.parseDocument(decoded);
  }

  group('round trip', () {
    test('export → wipe → import reproduces the database exactly', () async {
      await DemoSeed.seed(db);

      final before = await repo.readAll(includeRidePoints: true);
      final parsed = await roundTrip();

      await db.wipeAll();
      expect(await VehicleRepo(db).getAll(), isEmpty);

      await importer.apply(
        parsed,
        strategy: MergeStrategy.replaceAll,
        createSafetyCopy: false,
      );

      final after = await repo.readAll(includeRidePoints: true);

      expect(after.vehicles.length, before.vehicles.length);
      expect(after.fuelEntries.length, before.fuelEntries.length);
      expect(after.serviceItems.length, before.serviceItems.length);
      expect(after.serviceLogs.length, before.serviceLogs.length);
      expect(after.expenses.length, before.expenses.length);

      // IDs preserved, so relationships survive.
      expect(
        after.fuelEntries.map((f) => f.id).toList(),
        before.fuelEntries.map((f) => f.id).toList(),
      );
      expect(
        after.serviceLogs.map((s) => s.serviceItemId).toList(),
        before.serviceLogs.map((s) => s.serviceItemId).toList(),
      );
    });

    test('money survives to the paisa', () async {
      await DemoSeed.seed(db);

      int fuelTotal(List<FuelEntryRow> rows) =>
          rows.fold(0, (sum, f) => sum + f.totalCostMinor);

      final before = fuelTotal((await repo.readAll()).fuelEntries);
      final parsed = await roundTrip();
      await db.wipeAll();
      await importer.apply(
        parsed,
        strategy: MergeStrategy.replaceAll,
        createSafetyCopy: false,
      );

      expect(fuelTotal((await repo.readAll()).fuelEntries), before);
    });

    test('dates survive the ISO 8601 conversion exactly', () async {
      await DemoSeed.seed(db);

      final before = (await repo.readAll()).fuelEntries.map((f) => f.dateMs);
      final parsed = await roundTrip();
      await db.wipeAll();
      await importer.apply(
        parsed,
        strategy: MergeStrategy.replaceAll,
        createSafetyCopy: false,
      );

      expect((await repo.readAll()).fuelEntries.map((f) => f.dateMs), before);
    });

    test('tombstones are carried across, not resurrected', () async {
      final vehicleId = await VehicleRepo(db).create(
        VehiclesCompanion.insert(name: 'Pulsar', createdAt: 0, updatedAt: 0),
      );
      final fuel = FuelRepo(db);
      final deleted = await fuel.create(
        FuelEntriesCompanion.insert(
          vehicleId: vehicleId,
          dateMs: Clock.nowMs,
          odometerM: 1000,
          volumeMl: 6000,
          pricePerUnitMinor: 12150,
          totalCostMinor: 72900,
          createdAt: 0,
          updatedAt: 0,
        ),
      );
      await fuel.softDelete(deleted);

      final parsed = await roundTrip();
      await db.wipeAll();
      await importer.apply(
        parsed,
        strategy: MergeStrategy.replaceAll,
        createSafetyCopy: false,
      );

      // The row is back, still tombstoned — so a merge on another device
      // knows the user deleted it rather than re-adding it.
      expect(await fuel.getForVehicle(vehicleId), isEmpty);
      final raw = await db.select(db.fuelEntries).get();
      expect(raw.single.deletedAt, isNotNull);
    });

    test('the next insert after an import does not collide', () async {
      await DemoSeed.seed(db);
      final parsed = await roundTrip();
      await db.wipeAll();
      await importer.apply(
        parsed,
        strategy: MergeStrategy.replaceAll,
        createSafetyCopy: false,
      );

      // SQLite's autoincrement counter is reset to 0 by the wipe; if the
      // import does not push it past the restored IDs, this insert fails on
      // a primary-key conflict.
      final vehicleId = (await VehicleRepo(db).getAll()).first.id;
      final newId = await FuelRepo(db).create(
        FuelEntriesCompanion.insert(
          vehicleId: vehicleId,
          dateMs: Clock.nowMs,
          odometerM: 99999000,
          volumeMl: 6000,
          pricePerUnitMinor: 12150,
          totalCostMinor: 72900,
          createdAt: 0,
          updatedAt: 0,
        ),
      );

      expect(newId, greaterThan(40));
    });

    test('ride points are omitted unless asked for', () async {
      await DemoSeed.seed(db);

      final without = ExportService.buildDocument(await repo.readAll());
      expect(without['ridePoints'], isEmpty);
      expect(without['includesRidePoints'], isFalse);

      final with_ = ExportService.buildDocument(
        await repo.readAll(includeRidePoints: true),
      );
      expect(with_['includesRidePoints'], isTrue);
    });
  });

  group('merge strategies', () {
    /// A device with one bike and one fill, and a backup describing the same
    /// ids with different content.
    Future<ParsedBackup> conflictingBackup() async {
      final vehicleId = await VehicleRepo(db).create(
        VehiclesCompanion.insert(
          name: 'From backup',
          createdAt: 0,
          updatedAt: 0,
        ),
      );
      await FuelRepo(db).create(
        FuelEntriesCompanion.insert(
          vehicleId: vehicleId,
          dateMs: Clock.nowMs,
          odometerM: 5000,
          volumeMl: 6000,
          pricePerUnitMinor: 12150,
          totalCostMinor: Money.fromMajor(999).minor,
          createdAt: 0,
          updatedAt: 0,
          station: const Value('Backup station'),
        ),
      );
      final parsed = await roundTrip();

      // Now make the device's own copy differ, keeping the same ids.
      await (db.update(db.vehicles)..where((v) => v.id.equals(vehicleId)))
          .write(const VehiclesCompanion(name: Value('On device')));
      await (db.update(db.fuelEntries)..where((f) => f.id.equals(1))).write(
        FuelEntriesCompanion(
          totalCostMinor: Value(Money.fromMajor(111).minor),
          station: const Value('Device station'),
        ),
      );

      return parsed;
    }

    test('keep mine leaves existing records untouched', () async {
      final parsed = await conflictingBackup();
      await importer.apply(parsed, strategy: MergeStrategy.keepMine);

      expect((await VehicleRepo(db).getAll()).single.name, 'On device');
      final fuel = (await repo.readAll()).fuelEntries.single;
      expect(fuel.station, 'Device station');
      expect(Money(fuel.totalCostMinor).asMajor, 111);
    });

    test('prefer imported overwrites the clashes', () async {
      final parsed = await conflictingBackup();
      await importer.apply(parsed, strategy: MergeStrategy.preferImported);

      expect((await VehicleRepo(db).getAll()).single.name, 'From backup');
      final fuel = (await repo.readAll()).fuelEntries.single;
      expect(fuel.station, 'Backup station');
      expect(Money(fuel.totalCostMinor).asMajor, 999);
    });

    test('keep mine still adds records the device does not have', () async {
      final vehicleId = await VehicleRepo(db).create(
        VehiclesCompanion.insert(name: 'Pulsar', createdAt: 0, updatedAt: 0),
      );
      await FuelRepo(db).create(
        FuelEntriesCompanion.insert(
          vehicleId: vehicleId,
          dateMs: Clock.nowMs,
          odometerM: 5000,
          volumeMl: 6000,
          pricePerUnitMinor: 12150,
          totalCostMinor: 72900,
          createdAt: 0,
          updatedAt: 0,
        ),
      );
      final parsed = await roundTrip();

      // Device loses the fill but keeps the bike.
      await db.delete(db.fuelEntries).go();
      expect(await FuelRepo(db).getForVehicle(vehicleId), isEmpty);

      await importer.apply(parsed, strategy: MergeStrategy.keepMine);
      expect(await FuelRepo(db).getForVehicle(vehicleId), hasLength(1));
    });

    test('replace all wipes first', () async {
      await DemoSeed.seed(db);
      final parsed = await roundTrip();

      // An extra bike that is not in the backup.
      await VehicleRepo(db).create(
        VehiclesCompanion.insert(
          name: 'Interloper',
          createdAt: 0,
          updatedAt: 0,
        ),
      );
      expect(await VehicleRepo(db).getAll(), hasLength(2));

      await importer.apply(
        parsed,
        strategy: MergeStrategy.replaceAll,
        createSafetyCopy: false,
      );

      final names = (await VehicleRepo(db).getAll()).map((v) => v.name);
      expect(names, ['Pulsar']);
    });
  });

  group('a bad file fails cleanly and changes nothing', () {
    Future<void> expectRejected(
      Map<String, dynamic> document,
      Matcher messageMatcher,
    ) async {
      await DemoSeed.seed(db);
      final before = (await repo.readAll()).counts;

      expect(
        () => importer.parseDocument(document),
        throwsA(
          isA<BackupValidationException>().having(
            (e) => e.message,
            'message',
            messageMatcher,
          ),
        ),
      );

      // Nothing touched.
      expect((await repo.readAll()).counts, before);
    }

    test('rejects a file that is not a Jatra backup', () async {
      await expectRejected({
        'some': 'other json',
      }, contains('not a Jatra backup'));
    });

    test('rejects a backup from a newer Jatra', () async {
      await expectRejected({
        'format': 'jatra-backup',
        'schemaVersion': 99,
      }, allOf(contains('newer version'), contains('99')));
    });

    test(
      'names the orphaned record rather than failing on a foreign key',
      () async {
        await expectRejected(
          {
            'format': 'jatra-backup',
            'schemaVersion': 1,
            'vehicles': const [],
            'fuelEntries': [
              {
                'id': 42,
                'vehicleId': 7,
                'date': '2026-08-04T12:00:00.000Z',
                'odometerM': 1000,
                'volumeMl': 6000,
                'totalCostMinor': 72900,
                'createdAt': '2026-08-04T12:00:00.000Z',
                'updatedAt': '2026-08-04T12:00:00.000Z',
              },
            ],
          },
          allOf(
            contains('fuel entry with id 42'),
            contains('bike 7'),
            contains('nothing has been imported'),
          ),
        );
      },
    );

    test('names the entry and field when one record is malformed', () async {
      await expectRejected(
        {
          'format': 'jatra-backup',
          'schemaVersion': 1,
          'vehicles': [
            {
              'id': 1,
              'name': 'Pulsar',
              'createdAt': '2026-08-04T12:00:00.000Z',
              'updatedAt': '2026-08-04T12:00:00.000Z',
            },
            {'id': 2, 'name': 'Broken'}, // no timestamps
          ],
        },
        allOf(contains('Entry 2'), contains('vehicles'), contains('createdAt')),
      );
    });

    test('rejects duplicate ids rather than silently dropping one', () async {
      await expectRejected(
        {
          'format': 'jatra-backup',
          'schemaVersion': 1,
          'vehicles': [
            for (var i = 0; i < 2; i++)
              {
                'id': 1,
                'name': 'Pulsar $i',
                'createdAt': '2026-08-04T12:00:00.000Z',
                'updatedAt': '2026-08-04T12:00:00.000Z',
              },
          ],
        },
        allOf(contains('two records with id 1'), contains('nothing has been')),
      );
    });

    test('rejects a section that is not a list', () async {
      await expectRejected({
        'format': 'jatra-backup',
        'schemaVersion': 1,
        'vehicles': {'not': 'a list'},
      }, contains('should be a list'));
    });

    test(
      'a truncated file is a JSON failure, caught before any write',
      () async {
        await DemoSeed.seed(db);
        final before = (await repo.readAll()).counts;

        final document = ExportService.buildDocument(await repo.readAll());
        final json = jsonEncode(document);
        final truncated = json.substring(0, json.length ~/ 2);

        expect(() => jsonDecode(truncated), throwsFormatException);
        expect((await repo.readAll()).counts, before);
      },
    );
  });

  group('the preview', () {
    test('describes the file before anything is applied', () async {
      await DemoSeed.seed(db);
      final parsed = await roundTrip();

      expect(parsed.preview.vehicleNames, ['Pulsar']);
      expect(parsed.preview.counts['fuelEntries'], 40);
      expect(parsed.preview.counts['serviceLogs'], 9);
      expect(parsed.preview.schemaVersion, 1);
      expect(parsed.preview.appVersion, '1.0.0');
      expect(parsed.preview.earliestMs, isNotNull);
      expect(parsed.preview.latestMs, greaterThan(parsed.preview.earliestMs!));
    });

    test('an empty but valid backup is accepted', () async {
      final parsed = importer.parseDocument({
        'format': 'jatra-backup',
        'schemaVersion': 1,
      });
      expect(parsed.preview.totalRecords, 0);
      expect(parsed.vehicles, isEmpty);
    });

    test(
      'a backup written before the Odo → Jatra rename still reads',
      () async {
        final parsed = importer.parseDocument({
          'format': 'odo-backup',
          'schemaVersion': 1,
          'vehicles': [
            {
              'id': 1,
              'name': 'Pulsar',
              'createdAt': '2026-08-04T12:00:00.000Z',
              'updatedAt': '2026-08-04T12:00:00.000Z',
            },
          ],
        });
        expect(parsed.preview.vehicleNames, ['Pulsar']);
      },
    );
  });

  group('the exported document', () {
    test('is self-describing', () async {
      await DemoSeed.seed(db);
      final document = ExportService.buildDocument(await repo.readAll());

      expect(document['format'], 'jatra-backup');
      expect(document['schemaVersion'], 1);
      expect(document['units'], isA<Map<String, String>>());
      expect((document['units'] as Map)['money'], contains('minor'));
      expect(document['counts'], isA<Map<String, int>>());
    });

    test('writes dates as ISO 8601, not epoch integers', () async {
      await DemoSeed.seed(db);
      final document = ExportService.buildDocument(await repo.readAll());
      final firstFill = (document['fuelEntries'] as List).first as Map;

      expect(firstFill['date'], isA<String>());
      expect(DateTime.tryParse(firstFill['date'] as String), isNotNull);
    });

    test('file names sort chronologically', () {
      final name = ExportService.backupFileName(DateTime(2026, 8, 4, 14, 32));
      expect(name, 'odo_backup_2026-08-04_1432.json');
    });
  });

  group('cross-checking the restored data', () {
    test('every repository sees the same records after a restore', () async {
      await DemoSeed.seed(db);
      final vehicleId = (await VehicleRepo(db).getAll()).single.id;

      final fuelBefore = (await FuelRepo(db).getForVehicle(vehicleId)).length;
      final logsBefore = (await ServiceRepo(db).getLogs(vehicleId)).length;
      final itemsBefore = (await ServiceRepo(db).getItems(vehicleId)).length;
      final expensesBefore = (await ExpenseRepo(
        db,
      ).getForVehicle(vehicleId)).length;

      final parsed = await roundTrip();
      await db.wipeAll();
      await importer.apply(
        parsed,
        strategy: MergeStrategy.replaceAll,
        createSafetyCopy: false,
      );

      expect((await FuelRepo(db).getForVehicle(vehicleId)).length, fuelBefore);
      expect((await ServiceRepo(db).getLogs(vehicleId)).length, logsBefore);
      expect((await ServiceRepo(db).getItems(vehicleId)).length, itemsBefore);
      expect(
        (await ExpenseRepo(db).getForVehicle(vehicleId)).length,
        expensesBefore,
      );
    });
  });
}
