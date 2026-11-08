import 'package:flutter_test/flutter_test.dart';
import 'package:jatra/core/calc/fuel_pricing.dart';
import 'package:jatra/core/utils/money.dart';
import 'package:jatra/core/utils/numeric_input.dart';
import 'package:jatra/core/utils/units.dart';
import 'package:jatra/data/models/enums.dart';

void main() {
  group('FuelPricing', () {
    String roundTrip(double paid, double price) {
      final total = Money.fromMajor(paid);
      final volume = trimmedDecimal(
        paid / price,
        minDecimals: 2,
        maxDecimals: 3,
      );
      final ml = Units.toMl(double.parse(volume), VolumeUnit.l);
      final stored = FuelPricing.perLitreToStore(
        ml: ml,
        total: total,
        enteredPerUnit: price,
        unit: VolumeUnit.l,
      );
      return FuelPricing.priceText(
        ml: ml,
        total: total,
        storedPerLitre: stored,
        unit: VolumeUnit.l,
      )!;
    }

    test('the price typed comes back unchanged, even on small fills', () {
      for (final paid in [50.0, 100.0, 500.0, 1000.0]) {
        expect(roundTrip(paid, 122.97), '122.97', reason: 'paid $paid');
      }
    });

    test('a three-decimal pump price survives', () {
      final total = Money.tryParse((30 * 1.459).toStringAsFixed(2))!;
      expect(
        FuelPricing.priceText(
          ml: 30000,
          total: total,
          storedPerLitre: Money(146),
          unit: VolumeUnit.l,
        ),
        '1.459',
      );
    });

    test('a price that contradicts the total is not stored', () {
      expect(
        FuelPricing.perLitreToStore(
          ml: 4000,
          total: Money(50000),
          enteredPerUnit: 99,
          unit: VolumeUnit.l,
        ),
        Money(12500),
      );
    });

    test('a gallon price is converted to per litre', () {
      final ml = Units.toMl(10, VolumeUnit.gal);
      expect(
        FuelPricing.perLitreToStore(
          ml: ml,
          total: Money(3450),
          enteredPerUnit: 3.45,
          unit: VolumeUnit.gal,
        ),
        Money(91),
      );
      expect(
        FuelPricing.priceText(
          ml: ml,
          total: Money(3450),
          storedPerLitre: Money(91),
          unit: VolumeUnit.gal,
        ),
        '3.45',
      );
    });

    test('no volume means no price rather than Infinity', () {
      expect(
        FuelPricing.priceText(
          ml: 0,
          total: Money(100),
          storedPerLitre: Money.zero,
          unit: VolumeUnit.l,
        ),
        isNull,
      );
    });
  });

  group('Units.odometerPrefill', () {
    test('never rises above the real reading', () {
      expect(Units.odometerPrefill(24180460, DistanceUnit.km), 24180.4);
      expect(Units.odometerPrefill(24180440, DistanceUnit.km), 24180.4);
    });

    test('keeps a whole mile reading whole', () {
      expect(Units.odometerPrefill(1985930, DistanceUnit.mi), 1234.0);
    });
  });

  group('LoadedQuantity', () {
    const loaded = LoadedQuantity('4.56', 4555);

    test('an untouched field keeps its stored value', () {
      expect(loaded.resolve(' 4.56 ', () => 4560), 4555);
    });

    test('a changed field is parsed', () {
      expect(loaded.resolve('4.57', () => 4570), 4570);
    });

    test('a new entry is parsed', () {
      const LoadedQuantity? none = null;
      expect(none.resolve('4.56', () => 4560), 4560);
    });
  });

  group('DecimalInputFormatter', () {
    const formatter = DecimalInputFormatter();

    String type(String before, String after) => formatter
        .formatEditUpdate(
          TextEditingValue(text: before),
          TextEditingValue(text: after),
        )
        .text;

    test('a decimal comma becomes a point', () {
      expect(type('12', '12,'), '12.');
    });

    test('a second point is refused', () {
      expect(type('12.3', '12.3.'), '12.3');
    });

    test('a pasted thousands comma is dropped', () {
      expect(type('', '1,250.50'), '1250.50');
    });

    test('other characters are dropped', () {
      expect(type('1', '1a'), '1');
    });
  });

  group('Money.tryParse separators', () {
    test('decimal comma', () => expect(Money.tryParse('12,50'), Money(1250)));
    test(
      'thousands comma',
      () => expect(Money.tryParse('1,250'), Money(125000)),
    );
    test(
      'both separators',
      () => expect(Money.tryParse('1,250.75'), Money(125075)),
    );
  });

  test('trimmedDecimal keeps the minimum and drops only trailing zeros', () {
    String t(double v) => trimmedDecimal(v, minDecimals: 2, maxDecimals: 3);
    expect(t(4.07), '4.07');
    expect(t(4.066), '4.066');
    expect(t(125), '125.00');
    expect(t(100.5), '100.50');
  });
}
