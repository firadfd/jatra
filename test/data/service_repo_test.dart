import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jatra/core/calc/service_predictor.dart';
import 'package:jatra/core/utils/clock.dart';
import 'package:jatra/data/db/database.dart';
import 'package:jatra/data/repositories/service_repo.dart';
import 'package:jatra/data/repositories/vehicle_repo.dart';

/// The rule tying items and logs together: logging a service advances the
/// item's baseline, so the next due point moves forward.
void main() {
  late AppDatabase db;
  late ServiceRepo service;
  late int vehicleId;
  late int oilItemId;

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    service = ServiceRepo(db);
    Clock.freeze(DateTime.utc(2026, 8, 4, 12));

    vehicleId = await VehicleRepo(db).create(
      VehiclesCompanion.insert(
        name: 'Pulsar',
        createdAt: 0,
        updatedAt: 0,
        initialOdometerM: const Value(20000000), // 20,000 km
      ),
    );

    final items = await service.getItems(vehicleId);
    oilItemId = items.firstWhere((i) => i.name == 'Engine oil').id;
  });

  tearDown(() async {
    Clock.freeze(null);
    await db.close();
  });

  Future<int> logService({
    required int odometerKm,
    int? itemId,
    int daysAgo = 0,
    String name = 'Engine oil',
  }) {
    return service.createLog(
      ServiceLogsCompanion.insert(
        vehicleId: vehicleId,
        name: name,
        dateMs: Dates.addDays(Clock.nowMs, -daysAgo),
        odometerM: odometerKm * 1000,
        createdAt: 0,
        updatedAt: 0,
        serviceItemId: Value(itemId),
        totalCostMinor: const Value(100000),
      ),
    );
  }

  test('logging against an item advances its baseline', () async {
    await logService(odometerKm: 22000, itemId: oilItemId);

    final item = await service.getItem(oilItemId);
    expect(item!.lastDoneOdometerM, 22000 * 1000);
    expect(item.lastDoneDateMs, Clock.nowMs);
  });

  test('the next due point moves with it', () async {
    // Engine oil is a 2,000 km interval seeded from 20,000 km, so at
    // 21,900 km it is nearly due.
    var item = await service.getItem(oilItemId);
    var due = ServicePredictor.evaluate(item!, currentOdometerM: 21900 * 1000);
    expect(due.status, ServiceStatus.dueSoon);
    expect(due.dueOdometerM, 22000 * 1000);

    await logService(odometerKm: 21900, itemId: oilItemId);

    item = await service.getItem(oilItemId);
    due = ServicePredictor.evaluate(item!, currentOdometerM: 21900 * 1000);
    expect(due.status, ServiceStatus.ok);
    expect(due.dueOdometerM, 23900 * 1000);
  });

  test('a back-dated log never drags the baseline backwards', () async {
    await logService(odometerKm: 24000, itemId: oilItemId);
    // Remembering a service from months ago, logged after the recent one.
    await logService(odometerKm: 21000, itemId: oilItemId, daysAgo: 90);

    final item = await service.getItem(oilItemId);
    expect(item!.lastDoneOdometerM, 24000 * 1000);
  });

  test('a one-off repair leaves every item alone', () async {
    final before = await service.getItem(oilItemId);
    await logService(odometerKm: 22500, name: 'Puncture repair');

    final after = await service.getItem(oilItemId);
    expect(after!.lastDoneOdometerM, before!.lastDoneOdometerM);
    expect((await service.getLogs(vehicleId)).single.serviceItemId, isNull);
  });

  test(
    'deleting the latest log rolls the baseline back to the one before',
    () async {
      await logService(odometerKm: 22000, itemId: oilItemId, daysAgo: 60);
      final second = await logService(odometerKm: 24000, itemId: oilItemId);

      expect(
        (await service.getItem(oilItemId))!.lastDoneOdometerM,
        24000 * 1000,
      );

      await service.softDeleteLog(second);
      expect(
        (await service.getItem(oilItemId))!.lastDoneOdometerM,
        22000 * 1000,
      );
    },
  );

  test(
    'deleting the only log falls back to the bike’s starting point',
    () async {
      final only = await logService(odometerKm: 22000, itemId: oilItemId);
      await service.softDeleteLog(only);

      final item = await service.getItem(oilItemId);
      // The vehicle's initial odometer, not null — a null baseline would make
      // the item read as overdue since the epoch.
      expect(item!.lastDoneOdometerM, 20000 * 1000);
    },
  );

  test('editing a log’s odometer moves the baseline with it', () async {
    final id = await logService(odometerKm: 22000, itemId: oilItemId);

    await service.updateLog(
      id,
      ServiceLogsCompanion(odometerM: Value(22500 * 1000)),
    );

    expect((await service.getItem(oilItemId))!.lastDoneOdometerM, 22500 * 1000);
  });

  test('the seeded schedule sorts sensibly for a bike just ridden', () async {
    // 900 km after the seed baseline: chain lube (500 km) is overdue,
    // chain adjust (1,500 km) is not yet due.
    final plan = ServicePredictor.plan(
      await service.getItems(vehicleId),
      currentOdometerM: 20900 * 1000,
    );

    expect(plan.first.item.name, 'Chain lube');
    expect(plan.first.status, ServiceStatus.overdue);
    expect(
      plan.firstWhere((d) => d.item.name == 'Tyre (front)').status,
      ServiceStatus.ok,
    );
  });
}
