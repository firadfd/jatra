import 'package:flutter_test/flutter_test.dart';
import 'package:jatra/core/calc/bike_report.dart';
import 'package:jatra/data/db/database.dart';

final _bike = VehicleRow(
  id: 1,
  createdAt: 0,
  updatedAt: 0,
  name: 'Pulsar',
  fuelType: FuelType.petrol,
  initialOdometerM: 1000,
  distanceUnit: DistanceUnit.km,
  volumeUnit: VolumeUnit.l,
  currency: 'BDT',
  isDefault: true,
  colorTag: 0,
  isArchived: false,
);

int _ms(int y, int m, int d) => DateTime(y, m, d).millisecondsSinceEpoch;

FuelEntryRow _fuel(int ms, int odo, {int cost = 1000}) => FuelEntryRow(
  id: odo,
  createdAt: 0,
  updatedAt: 0,
  vehicleId: 1,
  dateMs: ms,
  odometerM: odo,
  volumeMl: 1000,
  pricePerUnitMinor: 1000,
  totalCostMinor: cost,
  isFullTank: true,
  isMissedEntry: false,
);

ServiceLogRow _log(int ms, int odo, {int parts = 0, String? brand}) =>
    ServiceLogRow(
      id: odo,
      createdAt: 0,
      updatedAt: 0,
      vehicleId: 1,
      name: 'Oil',
      dateMs: ms,
      odometerM: odo,
      partsCostMinor: parts,
      laborCostMinor: 0,
      totalCostMinor: 500,
      partBrand: brand,
    );

BikeReport _build(
  List<FuelEntryRow> fuel, [
  List<ServiceLogRow> logs = const [],
]) => BikeReport.build(
  vehicle: _bike,
  fuel: fuel,
  services: logs,
  expenses: const [],
);

void main() {
  test('adds up spend by kind', () {
    final report = BikeReport.build(
      vehicle: _bike,
      fuel: [_fuel(_ms(2026, 1, 1), 2000, cost: 700)],
      services: [_log(_ms(2026, 1, 2), 2100)],
      expenses: [
        ExpenseRow(
          id: 1,
          createdAt: 0,
          updatedAt: 0,
          vehicleId: 1,
          category: ExpenseCategory.other,
          dateMs: _ms(2026, 1, 3),
          amountMinor: 300,
        ),
      ],
    );

    expect(report.fuelTotal.minor, 700);
    expect(report.serviceTotal.minor, 500);
    expect(report.otherTotal.minor, 300);
    expect(report.total.minor, 1500);
  });

  test('timeline keeps the last reading of each month', () {
    final report = _build([
      _fuel(_ms(2026, 1, 5), 2000),
      _fuel(_ms(2026, 1, 20), 2500),
      _fuel(_ms(2026, 2, 3), 3000),
    ]);

    expect(report.odometer.map((o) => o.odometerM), [2500, 3000]);
    expect(report.latestOdometerM, 3000);
  });

  test('never hides a reading that went backwards', () {
    final report = _build([
      _fuel(_ms(2026, 1, 5), 5000),
      _fuel(_ms(2026, 1, 10), 3000),
      _fuel(_ms(2026, 1, 20), 5500),
    ]);

    expect(report.lowerReadingCount, 1);
    expect(
      report.odometer.where((o) => o.isLowerThanEarlier).single.odometerM,
      3000,
    );
    expect(report.odometer.last.odometerM, 5500);
  });

  test('two entries on one day are not a rollback', () {
    final day = _ms(2026, 1, 5);
    final report = _build([_fuel(day, 5000)], [_log(day, 4900)]);

    expect(report.lowerReadingCount, 0);
  });

  test('a reading below where logging began is flagged', () {
    expect(_build([_fuel(_ms(2026, 1, 5), 500)]).lowerReadingCount, 1);
  });

  test('parts are services with a part cost or brand, oldest first', () {
    final report = _build(const [], [
      _log(_ms(2026, 3, 1), 3000, brand: 'Motul'),
      _log(_ms(2026, 1, 1), 2000, parts: 900),
      _log(_ms(2026, 2, 1), 2500),
    ]);

    expect(report.services.map((s) => s.odometerM), [2000, 2500, 3000]);
    expect(report.parts.map((s) => s.odometerM), [2000, 3000]);
  });

  test('an empty log has no first record', () {
    final report = _build(const []);

    expect(report.firstRecordMs, isNull);
    expect(report.latestOdometerM, 1000);
    expect(report.total.minor, 0);
  });
}
