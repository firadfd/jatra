import 'package:flutter_test/flutter_test.dart';
import 'package:jatra/core/calc/mileage_calc.dart';
import 'package:jatra/core/calc/station_ranking.dart';
import 'package:jatra/data/db/database.dart';

var _id = 0;

FuelEntryRow _fill(
  int km,
  String? station, {
  bool full = true,
  bool missed = false,
  int litres = 10,
}) {
  _id++;
  return FuelEntryRow(
    id: _id,
    createdAt: 0,
    updatedAt: 0,
    vehicleId: 1,
    dateMs: km * 1000,
    odometerM: km * 1000,
    volumeMl: litres * 1000,
    pricePerUnitMinor: 12500,
    totalCostMinor: litres * 12500,
    isFullTank: full,
    isMissedEntry: missed,
    station: station,
  );
}

List<StationStat> _rank(List<FuelEntryRow> fills) =>
    StationRanking.compute(fills, MileageEngine.compute(fills).windows);

void main() {
  test('credits a window to the fuel it burned, not the closing fill', () {
    // A's fuel burned over both windows; B only closes the last one.
    final stats = _rank([_fill(100, 'A'), _fill(500, 'A'), _fill(900, 'B')]);

    expect(stats.single.name, 'A');
    expect(stats.single.windowCount, 2);
    expect(stats.single.economyKmPerLitre, closeTo(40, 0.001));
  });

  test('ranks best mileage first', () {
    final stats = _rank([
      _fill(100, 'Low'),
      _fill(300, 'Low'),
      _fill(500, 'High'),
      _fill(1000, 'High'),
      _fill(1500, 'End'),
    ]);

    expect(stats.map((s) => s.name), ['High', 'Low']);
  });

  test('excludes a window whose burned fuel mixes stations', () {
    final stats = _rank([
      _fill(100, 'A'),
      _fill(200, 'B', full: false),
      _fill(500, 'A'),
      _fill(900, 'A'),
      _fill(1300, 'A'),
    ]);

    // The first window mixes A and B; the two after it are clean.
    expect(stats.single.windowCount, 2);
  });

  test('excludes a window with an unnamed fill', () {
    final stats = _rank([_fill(100, null), _fill(500, 'A'), _fill(900, 'Z')]);

    expect(stats, isEmpty);
  });

  test('needs more than one tank', () {
    expect(_rank([_fill(100, 'A'), _fill(500, 'B')]), isEmpty);
  });

  test('ignores unreliable windows', () {
    final stats = _rank([
      _fill(100, 'A'),
      _fill(500, 'A', missed: true),
      _fill(900, 'A'),
      _fill(1300, 'A'),
    ]);

    expect(stats.single.windowCount, 2);
  });

  test('treats case and spacing as the same station, newest spelling', () {
    final stats = _rank([
      _fill(100, 'meghna  pump'),
      _fill(500, ' Meghna Pump '),
      _fill(900, 'Meghna Pump'),
    ]);

    expect(stats.single.name, 'Meghna Pump');
    expect(stats.single.windowCount, 2);
  });

  test('range filter applies to the closing date', () {
    final fills = [_fill(100, 'A'), _fill(500, 'A'), _fill(900, 'A')];
    final stats = StationRanking.compute(
      fills,
      MileageEngine.compute(fills).windows,
      closedWithin: (ms) => ms < 900 * 1000,
    );

    expect(stats, isEmpty);
  });
}
