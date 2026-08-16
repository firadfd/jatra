import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:jatra/core/utils/formatters.dart';
import 'package:jatra/core/utils/money.dart';
import 'package:jatra/data/models/enums.dart';

/// Bangla must translate the prose without touching the digits.
///
/// This is not cosmetic. `intl` under `bn` renders 24,180 as ২৪,১৮০, and
/// three things then break: the odometer barrel splits digits by subtracting
/// 0x30 from each code unit and Bengali digits sit at U+09E6; Barlow
/// Condensed has no Bengali digit glyphs at all, so every figure would lose
/// the tabular numeral face; and riders read instrument readings in Latin
/// digits anyway.
void main() {
  setUpAll(() async {
    await initializeDateFormatting();
  });

  final bn = Fmt(currency: 'BDT', locale: 'bn');
  final en = Fmt(currency: 'BDT', locale: 'en');

  group('digits stay Latin in Bangla', () {
    test('distances', () {
      expect(bn.distance(24180000), '24,180');
      expect(bn.distance(24180000), en.distance(24180000));
    });

    test('volumes', () {
      expect(bn.volume(8420), '8.42');
    });

    test('fuel economy', () {
      expect(bn.economyOf(44.2), '44.2');
    });

    test('money', () {
      expect(bn.amount(Money.fromMajor(1250.75)), '৳1,250.75');
      expect(bn.rate(2.47), '৳2.47');
    });

    test('speed', () {
      expect(bn.speed(10), '36');
    });

    test('every digit is ASCII', () {
      final samples = [
        bn.distance(24180000),
        bn.volume(8420),
        bn.economyOf(44.2),
        bn.amount(Money.fromMajor(1250.75)),
        bn.speed(17.5),
        bn.percent(0.72),
      ];

      for (final sample in samples) {
        for (final unit in sample.codeUnits) {
          // Bengali digits occupy U+09E6–U+09EF. None may appear.
          expect(
            unit >= 0x09E6 && unit <= 0x09EF,
            isFalse,
            reason: 'Bengali digit found in "$sample"',
          );
        }
      }
    });

    test('the odometer barrel can still split the string', () {
      // The strip does `codeUnit - 0x30`. Anything outside 0–9 would render
      // a nonsense glyph index.
      final reading = bn.distance(24180000).replaceAll(',', '');
      for (final unit in reading.codeUnits) {
        final digit = unit - 0x30;
        expect(digit, inInclusiveRange(0, 9));
      }
    });
  });

  group('prose localises', () {
    test('month names translate', () {
      final ms = DateTime.utc(2026, 8, 4).millisecondsSinceEpoch;
      expect(en.month(ms), 'August 2026');
      // Bangla month name, Latin year — words translate, figures do not.
      expect(bn.month(ms), isNot(equals(en.month(ms))));
      expect(bn.month(ms), contains('2026'));
    });

    test('dates keep Latin numerals', () {
      final ms = DateTime.utc(2026, 8, 4).millisecondsSinceEpoch;
      expect(bn.date(ms), contains('4'));
      expect(bn.date(ms), contains('2026'));
    });
  });

  group('unit labels are unit symbols, not words', () {
    test('and so do not translate', () {
      // KM/L is read the same in both languages, and it is set in the mono
      // face which has no Bengali glyphs.
      expect(bn.economyLabel, 'KM/L');
      expect(bn.distanceLabel, 'KM');
      expect(
        Fmt(
          distanceUnit: DistanceUnit.mi,
          volumeUnit: VolumeUnit.gal,
          locale: 'bn',
        ).economyLabel,
        'MI/GAL',
      );
    });
  });
}
