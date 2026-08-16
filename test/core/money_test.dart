import 'package:flutter_test/flutter_test.dart';
import 'package:jatra/core/utils/money.dart';

void main() {
  group('Money', () {
    test('parses major units into exact minor units', () {
      expect(Money.tryParse('1250.75')?.minor, 125075);
      expect(Money.tryParse('1,250.75')?.minor, 125075);
      expect(Money.tryParse('0.01')?.minor, 1);
      expect(Money.tryParse('121.5')?.minor, 12150);
    });

    test('rejects junk', () {
      expect(Money.tryParse(''), isNull);
      expect(Money.tryParse('abc'), isNull);
      expect(Money.tryParse('12.3.4'), isNull);
    });

    test('rounds half away from zero rather than truncating', () {
      // 0.005 in binary floating point is slightly above or below; what
      // matters is that the result is a whole minor unit either way.
      expect(Money.fromMajor(10.005).minor, anyOf(1000, 1001));
      expect(Money.fromMajor(10.006).minor, 1001);
      expect(Money.fromMajor(10.004).minor, 1000);
    });

    test('addition over 200 entries stays exact to the paisa', () {
      // This is the case correctness rule 4 exists for: doing the same sum
      // in doubles drifts, and this must not.
      var total = Money.zero;
      for (var i = 0; i < 200; i++) {
        total += Money.tryParse('12.13')!;
      }
      expect(total.minor, 200 * 1213);
      expect(total.asMajor, 2426.0);
    });

    test('fromVolume rounds once, not twice', () {
      // 12.34 L at 121.50/L = 1499.31 exactly.
      final total = Money.fromVolume(
        ml: 12340,
        pricePerLitre: Money.fromMajor(121.50),
      );
      expect(total.minor, 149931);
    });

    test('unitPrice inverts fromVolume', () {
      final price = Money.fromMajor(121.50);
      const ml = 8420;
      final total = Money.fromVolume(ml: ml, pricePerLitre: price);
      final back = Money.unitPrice(ml: ml, total: total);
      // Allow one paisa of rounding slack in the round trip.
      expect((back!.minor - price.minor).abs(), lessThanOrEqualTo(1));
    });

    test('unitPrice guards against a zero volume', () {
      expect(Money.unitPrice(ml: 0, total: Money.fromMajor(500)), isNull);
      expect(Money.unitPrice(ml: -5, total: Money.fromMajor(500)), isNull);
    });

    test('scaled rounds to whole minor units', () {
      expect(Money.fromMajor(100).scaled(0.333).minor, 3330);
      expect(Money.fromMajor(1).scaled(0.5).minor, 50);
    });
  });

  group('MoneyFormatter', () {
    test('uses the taka symbol for BDT', () {
      final f = MoneyFormatter(currencyCode: 'BDT', locale: 'en_US');
      expect(f.format(Money.fromMajor(1250.75)), '৳1,250.75');
      expect(f.formatRounded(Money.fromMajor(1250.75)), '৳1,251');
    });

    test('falls back to the ISO code for unknown currencies', () {
      final f = MoneyFormatter(currencyCode: 'XYZ', locale: 'en_US');
      expect(f.symbol, 'XYZ');
    });

    test('rate figures gain a digit below one unit', () {
      final f = MoneyFormatter(currencyCode: 'BDT', locale: 'en_US');
      expect(f.formatRate(2.4712), '৳2.47');
      expect(f.formatRate(0.0834), '৳0.083');
    });
  });
}
