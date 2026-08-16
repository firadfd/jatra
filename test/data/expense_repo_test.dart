import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jatra/core/calc/cost_calc.dart';
import 'package:jatra/core/calc/date_range.dart';
import 'package:jatra/core/utils/clock.dart';
import 'package:jatra/core/utils/money.dart';
import 'package:jatra/data/db/database.dart';
import 'package:jatra/data/repositories/expense_repo.dart';
import 'package:jatra/data/repositories/vehicle_repo.dart';

void main() {
  late AppDatabase db;
  late ExpenseRepo expenses;
  late int vehicleId;

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    expenses = ExpenseRepo(db);
    Clock.freeze(DateTime.utc(2026, 8, 4, 12));
    vehicleId = await VehicleRepo(db).create(
      VehiclesCompanion.insert(name: 'Pulsar', createdAt: 0, updatedAt: 0),
    );
  });

  tearDown(() async {
    Clock.freeze(null);
    await db.close();
  });

  Future<int> add(
    ExpenseCategory category,
    double amount, {
    int daysAgo = 0,
    int? expiresInDays,
  }) {
    return expenses.create(
      ExpensesCompanion.insert(
        vehicleId: vehicleId,
        category: category,
        dateMs: Dates.addDays(Clock.nowMs, -daysAgo),
        amountMinor: Money.fromMajor(amount).minor,
        createdAt: 0,
        updatedAt: 0,
        validUntilMs: Value(
          expiresInDays == null
              ? null
              : Dates.addDays(Clock.nowMs, expiresInDays),
        ),
      ),
    );
  }

  test('expiring documents include lapsed ones, soonest first', () async {
    await add(ExpenseCategory.insurance, 1450, expiresInDays: 30);
    await add(ExpenseCategory.fitness, 900, expiresInDays: -10); // lapsed
    await add(ExpenseCategory.taxToken, 2800, expiresInDays: 200); // far off
    await add(ExpenseCategory.washing, 120); // never expires

    final expiring = await expenses.expiringDocuments(vehicleId);

    // A lapsed policy is more urgent than one expiring next month, not less.
    expect(expiring.map((e) => e.category), [
      ExpenseCategory.fitness,
      ExpenseCategory.insurance,
    ]);
  });

  test('a range query only counts what falls inside it', () async {
    await add(ExpenseCategory.insurance, 1450, daysAgo: 300);
    await add(ExpenseCategory.fine, 500, daysAgo: 10);
    await add(ExpenseCategory.washing, 120, daysAgo: 2);

    final month = DateRange.thisMonth();
    final inMonth = await expenses.getInRange(
      vehicleId,
      fromMs: month.fromMs,
      toMs: month.toMs,
    );

    expect(inMonth, hasLength(1));
    expect(inMonth.single.category, ExpenseCategory.washing);
  });

  test('deleting is reversible and the totals follow', () async {
    final fine = await add(ExpenseCategory.fine, 500);
    await add(ExpenseCategory.washing, 120);

    Future<int> totalMinor() async {
      final rows = await expenses.getForVehicle(vehicleId);
      return rows.fold<int>(0, (sum, e) => sum + e.amountMinor);
    }

    expect(await totalMinor(), Money.fromMajor(620).minor);

    await expenses.softDelete(fine);
    expect(await totalMinor(), Money.fromMajor(120).minor);

    await expenses.restore(fine);
    expect(await totalMinor(), Money.fromMajor(620).minor);
  });

  test('expenses feed running cost but not fuel cost', () async {
    await add(ExpenseCategory.insurance, 1450);

    final report = CostCalculator.compute(
      vehicle: (await VehicleRepo(db).getById(vehicleId))!,
      range: DateRange.allTime(),
      fuelEntries: const [],
      serviceLogs: const [],
      expenses: await expenses.getForVehicle(vehicleId),
      distanceM: 1000 * 1000,
      observationCount: 2,
      defaultAnnualDepreciationPercent: 12,
    );

    expect(report.fuelCost.isZero, isTrue);
    expect(report.otherCost.minor, Money.fromMajor(1450).minor);
    expect(report.runningPerDistance(DistanceUnit.km), closeTo(1.45, 1e-9));
    // No purchase price on this bike, so true cost stays unavailable.
    expect(report.truePerDistance(DistanceUnit.km), isNull);
  });
}
