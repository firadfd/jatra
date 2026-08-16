import 'package:flutter_test/flutter_test.dart';
import 'package:jatra/core/calc/mileage_calc.dart';
import 'package:jatra/data/db/database.dart';

/// Builds a fuel entry with only the fields the mileage engine reads.
///
/// [odometerKm] and [litres] are given in human units and converted here, so
/// the expectations below can be checked against a calculator without
/// mentally dividing by a thousand.
FuelEntryRow entry({
  required int id,
  required double odometerKm,
  required double litres,
  bool isFullTank = true,
  bool isMissedEntry = false,
  double pricePerLitre = 121.50,
  int dayOffset = 0,
}) {
  final volumeMl = (litres * 1000).round();
  final priceMinor = (pricePerLitre * 100).round();
  return FuelEntryRow(
    id: id,
    vehicleId: 1,
    dateMs:
        DateTime.utc(2026, 1, 1).millisecondsSinceEpoch + dayOffset * 86400000,
    odometerM: (odometerKm * 1000).round(),
    volumeMl: volumeMl,
    pricePerUnitMinor: priceMinor,
    totalCostMinor: (volumeMl * priceMinor / 1000).round(),
    isFullTank: isFullTank,
    isMissedEntry: isMissedEntry,
    createdAt: 0,
    updatedAt: 0,
  );
}

double? kmPerLitre(MileageWindow? w) => w?.economyKmPerLitre;

void main() {
  group('full-tank windows', () {
    test('the first entry can never produce a figure', () {
      final report = MileageEngine.compute([
        entry(id: 1, odometerKm: 10000, litres: 8),
      ]);
      expect(report.windows, isEmpty);
      expect(report.latest, isNull);
      // Callers render this as an em dash, not as zero.
      expect(report.average(DistanceUnit.km, VolumeUnit.l), isNull);
    });

    test('two full tanks give distance ÷ the closing volume', () {
      // 10,000 → 10,440 km on 10 L = 44.0 km/L exactly.
      final report = MileageEngine.compute([
        entry(id: 1, odometerKm: 10000, litres: 8),
        entry(id: 2, odometerKm: 10440, litres: 10),
      ]);

      expect(report.windows, hasLength(1));
      final w = report.windows.single;
      expect(w.openingEntryId, 1);
      expect(w.closingEntryId, 2);
      expect(w.distanceM, 440000);
      // The opening fill's 8 L is excluded — that fuel was burned before the
      // window started.
      expect(w.volumeMl, 10000);
      expect(kmPerLitre(w), closeTo(44.0, 1e-9));
    });

    test('a third tank produces a second, independent window', () {
      // 10,440 → 10,860 = 420 km on 10 L = 42.0 km/L.
      final report = MileageEngine.compute([
        entry(id: 1, odometerKm: 10000, litres: 8),
        entry(id: 2, odometerKm: 10440, litres: 10),
        entry(id: 3, odometerKm: 10860, litres: 10),
      ]);

      expect(report.windows, hasLength(2));
      expect(kmPerLitre(report.windows[0]), closeTo(44.0, 1e-9));
      expect(kmPerLitre(report.windows[1]), closeTo(42.0, 1e-9));
      expect(kmPerLitre(report.latest), closeTo(42.0, 1e-9));
      expect(kmPerLitre(report.previous), closeTo(44.0, 1e-9));
    });
  });

  group('partial fills', () {
    test('accumulate into the next full tank instead of measuring alone', () {
      // 10,000 → 10,440 km = 440 km.
      // Fuel added after the opening tank: 4 L partial + 6 L full = 10 L.
      // 440 ÷ 10 = 44.0 km/L, and the partial gets no figure of its own.
      final report = MileageEngine.compute([
        entry(id: 1, odometerKm: 10000, litres: 8),
        entry(id: 2, odometerKm: 10180, litres: 4, isFullTank: false),
        entry(id: 3, odometerKm: 10440, litres: 6),
      ]);

      expect(report.windows, hasLength(1));
      final w = report.windows.single;
      expect(w.closingEntryId, 3);
      expect(w.volumeMl, 10000);
      expect(w.fillCount, 2);
      expect(kmPerLitre(w), closeTo(44.0, 1e-9));

      // The partial fill closes nothing, so the history row shows no km/L.
      expect(report.windowsByClosingEntry.containsKey(2), isFalse);
      expect(report.windowsByClosingEntry.containsKey(3), isTrue);
    });

    test('several partials in a row all roll into one window', () {
      // 440 km on 3 + 3 + 4 = 10 L.
      final report = MileageEngine.compute([
        entry(id: 1, odometerKm: 10000, litres: 8),
        entry(id: 2, odometerKm: 10100, litres: 3, isFullTank: false),
        entry(id: 3, odometerKm: 10250, litres: 3, isFullTank: false),
        entry(id: 4, odometerKm: 10440, litres: 4),
      ]);

      expect(report.windows, hasLength(1));
      expect(report.windows.single.volumeMl, 10000);
      expect(report.windows.single.fillCount, 3);
      expect(kmPerLitre(report.windows.single), closeTo(44.0, 1e-9));
    });

    test('partial fills before the first full tank are discarded', () {
      // That fuel was burned before logging began; counting it would make
      // the first real window look terrible.
      final report = MileageEngine.compute([
        entry(id: 1, odometerKm: 9800, litres: 5, isFullTank: false),
        entry(id: 2, odometerKm: 10000, litres: 8),
        entry(id: 3, odometerKm: 10440, litres: 10),
      ]);

      expect(report.windows, hasLength(1));
      expect(report.windows.single.openingEntryId, 2);
      expect(report.windows.single.volumeMl, 10000);
      expect(kmPerLitre(report.windows.single), closeTo(44.0, 1e-9));
    });
  });

  group('missed entries', () {
    test('poison their window but leave it visible', () {
      final report = MileageEngine.compute([
        entry(id: 1, odometerKm: 10000, litres: 8),
        entry(id: 2, odometerKm: 10440, litres: 10),
        entry(id: 3, odometerKm: 11400, litres: 10, isMissedEntry: true),
        entry(id: 4, odometerKm: 11840, litres: 10),
      ]);

      expect(report.windows, hasLength(3));
      expect(report.windows[1].isReliable, isFalse);
      expect(report.windows[0].isReliable, isTrue);
      expect(report.windows[2].isReliable, isTrue);

      // Still listed, so the row can be shown with a flag…
      expect(report.windowsByClosingEntry[3], isNotNull);
      // …but never counted.
      expect(report.reliableWindows, hasLength(2));
      expect(kmPerLitre(report.latest), closeTo(44.0, 1e-9));
    });

    test('a missed partial poisons the whole window it lands in', () {
      final report = MileageEngine.compute([
        entry(id: 1, odometerKm: 10000, litres: 8),
        entry(
          id: 2,
          odometerKm: 10180,
          litres: 4,
          isFullTank: false,
          isMissedEntry: true,
        ),
        entry(id: 3, odometerKm: 10440, litres: 6),
      ]);

      expect(report.windows.single.isReliable, isFalse);
      expect(report.reliableWindows, isEmpty);
    });

    test('unreliable fuel is excluded from the lifetime average', () {
      // Reliable: 440 km / 10 L and 440 km / 10 L → 880 / 20 = 44.0 km/L.
      // The poisoned 960 km / 10 L (96 km/L) must not drag it upward.
      final report = MileageEngine.compute([
        entry(id: 1, odometerKm: 10000, litres: 8),
        entry(id: 2, odometerKm: 10440, litres: 10),
        entry(id: 3, odometerKm: 11400, litres: 10, isMissedEntry: true),
        entry(id: 4, odometerKm: 11840, litres: 10),
      ]);

      expect(report.totalDistanceM, 880000);
      expect(report.totalVolumeMl, 20000);
      expect(
        report.average(DistanceUnit.km, VolumeUnit.l),
        closeTo(44.0, 1e-9),
      );
    });
  });

  group('guards', () {
    test('a non-positive distance produces no window', () {
      // Two fills at the same reading — a duplicate, not a measurement.
      final report = MileageEngine.compute([
        entry(id: 1, odometerKm: 10000, litres: 8),
        entry(id: 2, odometerKm: 10000, litres: 5, dayOffset: 1),
      ]);
      expect(report.windows, isEmpty);
      expect(report.average(DistanceUnit.km, VolumeUnit.l), isNull);
    });

    test('entries in the wrong order are sorted before computing', () {
      final ordered = MileageEngine.compute([
        entry(id: 1, odometerKm: 10000, litres: 8),
        entry(id: 2, odometerKm: 10440, litres: 10),
        entry(id: 3, odometerKm: 10860, litres: 10),
      ]);
      final shuffled = MileageEngine.compute([
        entry(id: 3, odometerKm: 10860, litres: 10),
        entry(id: 1, odometerKm: 10000, litres: 8),
        entry(id: 2, odometerKm: 10440, litres: 10),
      ]);

      expect(shuffled.windows.map(kmPerLitre), ordered.windows.map(kmPerLitre));
    });

    test('an empty log reports nothing rather than zero', () {
      final report = MileageEngine.compute([]);
      expect(report.windows, isEmpty);
      expect(report.latest, isNull);
      expect(report.best, isNull);
      expect(report.trendFraction, isNull);
    });
  });

  group('aggregates', () {
    // Six windows of exactly 440 km, on volumes chosen to give clean figures.
    List<FuelEntryRow> series(List<double> economies) {
      final rows = <FuelEntryRow>[entry(id: 1, odometerKm: 10000, litres: 8)];
      var odometer = 10000.0;
      for (var i = 0; i < economies.length; i++) {
        odometer += 440;
        rows.add(
          entry(
            id: i + 2,
            odometerKm: odometer,
            litres: 440 / economies[i],
            dayOffset: (i + 1) * 6,
          ),
        );
      }
      return rows;
    }

    test('best and worst pick the right tanks', () {
      final report = MileageEngine.compute(series([44, 48, 41, 45]));
      expect(kmPerLitre(report.best), closeTo(48, 0.01));
      expect(kmPerLitre(report.worst), closeTo(41, 0.01));
    });

    test('the average is volume-weighted, not a mean of ratios', () {
      // Two windows, same distance, very different economies. Weighted by
      // volume the answer is 880 km ÷ (440/60 + 440/20) L = 30 km/L, whereas
      // the naive mean of 60 and 20 would say 40.
      final report = MileageEngine.compute(series([60, 20]));
      expect(
        report.average(DistanceUnit.km, VolumeUnit.l),
        closeTo(30.0, 0.01),
      );
    });

    test('trend is the signed change from the previous reliable window', () {
      final report = MileageEngine.compute(series([44, 40]));
      // 40 vs 44 → down about 9.1%.
      expect(report.trendFraction, closeTo(-0.0909, 0.001));
    });

    test('the cost of a window sums only its own fills', () {
      // 10 L at 121.50 = 1215.00 → 121500 paisa.
      final report = MileageEngine.compute([
        entry(id: 1, odometerKm: 10000, litres: 8),
        entry(id: 2, odometerKm: 10440, litres: 10),
      ]);
      expect(report.windows.single.cost.minor, 121500);
      expect(report.totalFuelCost.minor, 121500);
    });
  });

  group('drop detection', () {
    List<MileageWindow> windowsFor(List<double> economies) =>
        MileageEngine.compute([
          entry(id: 1, odometerKm: 10000, litres: 8),
          for (var i = 0; i < economies.length; i++)
            entry(
              id: i + 2,
              odometerKm: 10000 + 440.0 * (i + 1),
              litres: 440 / economies[i],
              dayOffset: (i + 1) * 6,
            ),
        ]).windows;

    test('fires when the latest tank falls past the threshold', () {
      // Median of 44, 45, 43, 44, 46 is 44. 38 is 13.6% below it.
      final drop = MileageEngine.detectDrop(
        windowsFor([44, 45, 43, 44, 46, 38]),
        thresholdPercent: 12,
      );

      expect(drop, isNotNull);
      expect(drop!.latest, closeTo(38, 0.01));
      expect(drop.baseline, closeTo(44, 0.01));
      expect(drop.dropFraction, closeTo(0.1364, 0.001));
      expect(drop.sampleCount, 5);
    });

    test('stays quiet for a drop inside the threshold', () {
      // 41 against a median of 44 is 6.8% — normal tank-to-tank variation.
      expect(
        MileageEngine.detectDrop(
          windowsFor([44, 45, 43, 44, 46, 41]),
          thresholdPercent: 12,
        ),
        isNull,
      );
    });

    test('the threshold is configurable and 0 turns it off', () {
      final windows = windowsFor([44, 45, 43, 44, 46, 41]);
      expect(MileageEngine.detectDrop(windows, thresholdPercent: 20), isNull);
      // Same data, a stricter threshold: now it fires.
      expect(MileageEngine.detectDrop(windows, thresholdPercent: 5), isNotNull);
      expect(MileageEngine.detectDrop(windows, thresholdPercent: 0), isNull);
    });

    test('only looks back five readings', () {
      // The five most recent priors are 30, 30, 30, 30, 30 → median 30.
      // The ancient 60s must not hold the baseline up.
      final drop = MileageEngine.detectDrop(
        windowsFor([60, 60, 60, 30, 30, 30, 30, 30, 29]),
        thresholdPercent: 2,
      );
      expect(drop!.baseline, closeTo(30, 0.01));
    });

    test('a median ignores one freak tank', () {
      // A single 70 km/L highway run among 44s should not raise the
      // baseline enough to fire a false alarm on a normal 43.
      expect(
        MileageEngine.detectDrop(
          windowsFor([44, 70, 44, 45, 44, 43]),
          thresholdPercent: 12,
        ),
        isNull,
      );
    });

    test('needs a history before it will call anything unusual', () {
      // Three readings total: not enough of a "usual" to judge against, even
      // though the fall is enormous.
      expect(
        MileageEngine.detectDrop(
          windowsFor([44, 44, 20]),
          thresholdPercent: 12,
        ),
        isNull,
      );
    });

    test('unreliable windows are not eligible as latest or as baseline', () {
      final report = MileageEngine.compute([
        entry(id: 1, odometerKm: 10000, litres: 8),
        entry(id: 2, odometerKm: 10440, litres: 10, dayOffset: 6),
        entry(id: 3, odometerKm: 10880, litres: 10, dayOffset: 12),
        entry(id: 4, odometerKm: 11320, litres: 10, dayOffset: 18),
        entry(id: 5, odometerKm: 11760, litres: 10, dayOffset: 24),
        // A window with fuel missing looks like a huge economy gain; it must
        // not become the latest reading and trigger nothing, nor inflate the
        // baseline for the next one.
        entry(
          id: 6,
          odometerKm: 13000,
          litres: 10,
          dayOffset: 30,
          isMissedEntry: true,
        ),
      ], dropThresholdPercent: 12);

      expect(report.latest!.closingEntryId, 5);
      expect(report.drop, isNull);
    });
  });
}
