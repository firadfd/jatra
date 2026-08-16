import 'package:flutter_test/flutter_test.dart';
import 'package:jatra/core/utils/units.dart';
import 'package:jatra/data/models/enums.dart';

void main() {
  group('Units', () {
    test('metres round-trip through km and miles', () {
      expect(Units.metresToKm(24180000), 24180.0);
      expect(Units.toMetres(24180, DistanceUnit.km), 24180000);
      expect(Units.toMetres(100, DistanceUnit.mi), 160934);
      expect(Units.metresToMiles(160934), closeTo(100, 0.001));
    });

    test('millilitres round-trip through litres and gallons', () {
      expect(Units.mlToLitres(8420), 8.42);
      expect(Units.toMl(8.42, VolumeUnit.l), 8420);
      expect(Units.toMl(1, VolumeUnit.gal), 3785);
    });

    test('km/L is metres per millilitre', () {
      // 280 km on 6.4 L → 43.75 km/L.
      final value = Units.economy(280000, 6400, DistanceUnit.km, VolumeUnit.l);
      expect(value, closeTo(43.75, 0.0001));
    });

    test('economy returns null rather than zero or infinity', () {
      // Guard every division — correctness rule 3.
      expect(Units.economy(0, 6400, DistanceUnit.km, VolumeUnit.l), isNull);
      expect(Units.economy(280000, 0, DistanceUnit.km, VolumeUnit.l), isNull);
      expect(Units.economy(-100, 6400, DistanceUnit.km, VolumeUnit.l), isNull);
      expect(Units.economy(280000, -1, DistanceUnit.km, VolumeUnit.l), isNull);
    });

    test('mi/gal is materially different from km/L for the same ride', () {
      final kmL = Units.economy(280000, 6400, DistanceUnit.km, VolumeUnit.l)!;
      final mpg = Units.economy(280000, 6400, DistanceUnit.mi, VolumeUnit.gal)!;
      // 1 km/L ≈ 2.352 mi/gal (US).
      expect(mpg / kmL, closeTo(2.352, 0.01));
    });

    test('unit labels compose the way the UI shows them', () {
      expect(Units.economyLabel(DistanceUnit.km, VolumeUnit.l), 'KM/L');
      expect(Units.economyLabel(DistanceUnit.mi, VolumeUnit.gal), 'MI/GAL');
      expect(Units.perDistanceLabel(DistanceUnit.km), '/KM');
      expect(Units.speedLabel(DistanceUnit.mi), 'MPH');
    });

    test('speed converts from metres per second', () {
      expect(Units.speedTo(10, DistanceUnit.km), closeTo(36, 0.001));
      expect(Units.speedTo(10, DistanceUnit.mi), closeTo(22.369, 0.001));
    });
  });
}
