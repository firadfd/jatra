import 'package:intl/intl.dart';

import '../../data/models/enums.dart';
import 'clock.dart';
import 'money.dart';
import 'units.dart';

/// Turns canonical integers into strings for display.
///
/// Constructed from the active vehicle's units and currency, so one instance
/// formats an entire screen consistently. Deliberately knows nothing about
/// the database — it takes plain values, which keeps `core/` independent of
/// `data/`.
///
/// Numeric methods return the **number only**. Unit labels come back from
/// separate getters, because the design pairs them at different sizes and in
/// different faces:  **44.2** `KM/L`.
class Fmt {
  Fmt({
    this.distanceUnit = DistanceUnit.km,
    this.volumeUnit = VolumeUnit.l,
    this.currency = 'BDT',
    String? locale,
  }) : locale = locale ?? Intl.getCurrentLocale(),
       money = MoneyFormatter(currencyCode: currency, locale: locale);

  final DistanceUnit distanceUnit;
  final VolumeUnit volumeUnit;
  final String currency;

  /// Drives month and day names. Bangla dates read as `৪ আগ ২০২৬`.
  final String locale;

  final MoneyFormatter money;

  /// Digits are always Latin, whatever the interface language.
  ///
  /// Under `bn`, `intl` renders 24,180 as ২৪,১৮০. Three things break:
  ///
  /// 1. The odometer barrel splits a number into digits by subtracting 0x30
  ///    from each code unit. Bengali digits live at U+09E6–U+09EF, so that
  ///    arithmetic produces nonsense.
  /// 2. Barlow Condensed — the tabular numeral face the whole design rests
  ///    on — has no Bengali digit glyphs, so every figure would fall back to
  ///    Hind Siliguri and lose both the condensed look and `tnum`.
  /// 3. Riders read instrument readings, pump prices and money in Latin
  ///    digits regardless; that is what is printed on the bike itself.
  ///
  /// So measurements stay Latin and prose localises. Month names still
  /// translate, because they are words rather than instrument readings.
  static const numberLocale = 'en';

  /// Shown wherever a figure cannot be computed. Never "0" — a zero is a
  /// measurement, an em dash is an absence, and confusing the two is how
  /// people end up believing their first tank did 0 km/L.
  static const dash = '—';

  // --- Unit labels (mono face, uppercase) ---
  String get distanceLabel => distanceUnit.label;
  String get volumeLabel => volumeUnit.label;
  String get economyLabel => Units.economyLabel(distanceUnit, volumeUnit);
  String get perDistanceLabel => Units.perDistanceLabel(distanceUnit);
  String get perVolumeLabel => Units.perVolumeLabel(volumeUnit);
  String get speedLabel => Units.speedLabel(distanceUnit);
  String get currencySymbol => money.symbol;

  // --- Numbers ---

  /// `24,180` — odometer readings and distances, whole units.
  String distance(int metres) => NumberFormat(
    '#,##0',
    numberLocale,
  ).format(Units.metresTo(metres, distanceUnit));

  /// `24,180.4` — trip distances, where the tenth matters.
  String distancePrecise(int metres) => NumberFormat(
    '#,##0.0',
    numberLocale,
  ).format(Units.metresTo(metres, distanceUnit));

  /// `8.42` — fuel volumes.
  String volume(int ml) =>
      NumberFormat('#,##0.00', numberLocale).format(Units.mlTo(ml, volumeUnit));

  /// `44.2`, or [dash] when the window cannot produce a figure.
  String economy(int metres, int ml) {
    final value = Units.economy(metres, ml, distanceUnit, volumeUnit);
    if (value == null) return dash;
    return NumberFormat('#,##0.0', numberLocale).format(value);
  }

  String economyOf(double? kmPerLitre) {
    if (kmPerLitre == null || !kmPerLitre.isFinite) return dash;
    return NumberFormat('#,##0.0', numberLocale).format(kmPerLitre);
  }

  /// `62` — speeds in the user's distance unit per hour.
  String speed(double metresPerSecond) => NumberFormat(
    '#,##0',
    numberLocale,
  ).format(Units.speedTo(metresPerSecond, distanceUnit));

  /// `৳1,250.75`
  String amount(Money value) => money.format(value);

  /// `৳1,251` — headline figures, where paisa is visual noise.
  String amountRounded(Money value) => money.formatRounded(value);

  /// `৳2.47` / `৳0.083` — cost-per-km and price-per-litre figures, which need
  /// more precision than a whole minor unit.
  String rate(double majorPerUnit) => money.formatRate(majorPerUnit);

  /// Price per volume unit, derived from the authoritative total and volume
  /// rather than from the stored per-litre figure.
  ///
  /// `pricePerUnitMinor` is canonicalised to minor-units-per-litre on the way
  /// into the database, which quantises it for anyone buying by the gallon.
  /// Deriving the displayed price from the exact pair the user actually
  /// entered keeps that quantisation out of the UI entirely.
  String pricePerVolume(int totalMinor, int volumeMl) {
    if (volumeMl <= 0) return dash;
    final perUnit = totalMinor / 100 / Units.mlTo(volumeMl, volumeUnit);
    return rate(perUnit);
  }

  /// Fuel cost per distance unit, e.g. `৳2.76`.
  String costPerDistance(int totalMinor, int distanceM) {
    if (distanceM <= 0) return dash;
    return rate(totalMinor / 100 / Units.metresTo(distanceM, distanceUnit));
  }

  /// `+14%` / `−9%`, with a true minus sign rather than a hyphen.
  String signedPercent(double fraction) {
    final pct = (fraction * 100).round();
    if (pct == 0) return '0%';
    return pct > 0 ? '+$pct%' : '−${pct.abs()}%';
  }

  String percent(double fraction) => '${(fraction * 100).round()}%';

  // --- Dates ---

  /// `4 Aug 2026` — month name in the user's language, digits in Latin.
  String date(int ms) => _formatDate('d MMM yyyy', ms);

  /// `4 Aug` — inside a list already grouped by year.
  String dateShort(int ms) => _formatDate('d MMM', ms);

  /// `August 2026` — month group headers.
  String month(int ms) => _formatDate('MMMM yyyy', ms);

  /// `Aug` — chart axis ticks, where a full month name never fits.
  ///
  /// Upper-casing is left to the caller: Bangla has no letter case, and
  /// `toUpperCase()` on a Bangla string is a no-op rather than an error, so
  /// the axis style applies it only where it means something.
  String monthAbbrev(int ms) => _formatDate('MMM', ms);

  /// `4 Aug 2026, 6:42 pm`
  String dateTime(int ms) => _formatDate('d MMM yyyy, h:mm a', ms);

  String time(int ms) => _formatDate('h:mm a', ms);

  /// Formats with localised month and day names, then forces the digits back
  /// to Latin.
  ///
  /// `intl` has no way to ask for "Bangla words, Latin numerals" — the locale
  /// decides both together. Without this, a fuel history row would read
  /// `৪ আগ ২০২৬` immediately beside `24,180 KM`, mixing two numeral systems
  /// on one line. Words translate; digits do not. See [numberLocale].
  String _formatDate(String pattern, int ms) {
    final formatted = DateFormat(
      pattern,
      locale,
    ).format(DateTime.fromMillisecondsSinceEpoch(ms));
    return toLatinDigits(formatted);
  }

  /// Rewrites Bengali digits (U+09E6–U+09EF) as ASCII, leaving everything
  /// else alone.
  static String toLatinDigits(String input) {
    const bengaliZero = 0x09E6;
    return String.fromCharCodes([
      for (final unit in input.codeUnits)
        if (unit >= bengaliZero && unit <= bengaliZero + 9)
          0x30 + (unit - bengaliZero)
        else
          unit,
    ]);
  }

  /// `1h 24m`, `24m`, `48s` — ride durations.
  String duration(int seconds) {
    if (seconds < 60) return '${seconds}s';
    final h = seconds ~/ 3600;
    final m = (seconds % 3600) ~/ 60;
    if (h == 0) return '${m}m';
    return '${h}h ${m}m';
  }

  /// Human relative day, for "next service" and document expiry:
  /// `today`, `tomorrow`, `in 12 days`, `18 days ago`.
  String relativeDay(int ms) {
    final days = Dates.daysBetween(
      Dates.startOfLocalDay(Clock.nowMs),
      Dates.startOfLocalDay(ms),
    );
    return switch (days) {
      0 => 'today',
      1 => 'tomorrow',
      -1 => 'yesterday',
      > 1 => 'in $days days',
      _ => '${-days} days ago',
    };
  }

  /// File-size label for the map-tiles and backup screens.
  static String fileSize(int bytes) {
    const units = ['B', 'KB', 'MB', 'GB'];
    var value = bytes.toDouble();
    var unit = 0;
    while (value >= 1024 && unit < units.length - 1) {
      value /= 1024;
      unit++;
    }
    final digits = value >= 100 || unit == 0 ? 0 : 1;
    return '${value.toStringAsFixed(digits)} ${units[unit]}';
  }
}
