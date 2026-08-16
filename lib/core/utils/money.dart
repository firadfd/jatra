import 'package:intl/intl.dart';

/// Money is an **integer count of minor units** (paisa for BDT, cents for USD).
/// Never a `double`.
///
/// Correctness rule 4 exists because `0.1 + 0.2 != 0.3` in binary floating
/// point. Summing a few hundred fuel entries as doubles drifts by a paisa or
/// two, which is exactly the kind of error a cost-tracking app cannot make.
///
/// [Money] is a thin, allocation-free wrapper over that integer: it is an
/// extension type, so at runtime it *is* the `int` stored in the database,
/// with no boxing cost and no risk of a `double` sneaking in through a
/// constructor.
extension type const Money(int minor) implements Object {
  static const zero = Money(0);

  /// Parses user input in major units ("1250.75") into minor units.
  ///
  /// Returns `null` on anything unparseable. Accepts an optional minus sign
  /// (refunds), commas as thousands separators, and both `.` and `٫`-free
  /// plain decimal points.
  static Money? tryParse(String input, {int decimals = 2}) {
    final cleaned = input.replaceAll(',', '').replaceAll(' ', '').trim();
    if (cleaned.isEmpty) return null;
    final value = double.tryParse(cleaned);
    if (value == null || !value.isFinite) return null;
    return Money.fromMajor(value, decimals: decimals);
  }

  /// Converts a major-unit `double` (only ever straight from user input or a
  /// legacy import) into exact minor units, rounding half away from zero.
  Money.fromMajor(double major, {int decimals = 2})
    : minor = (major * _pow10(decimals)).roundToDouble().toInt();

  double get asMajor => minor / _pow10(2);

  bool get isZero => minor == 0;
  bool get isPositive => minor > 0;

  Money operator +(Money other) => Money(minor + other.minor);
  Money operator -(Money other) => Money(minor - other.minor);

  /// Scales by a plain factor (a share of a period, a depreciation fraction).
  /// Rounds to the nearest minor unit so no fractional paisa ever escapes.
  Money scaled(num factor) => Money((minor * factor).round());

  /// Total cost from a volume and a unit price, both exact.
  ///
  /// `millilitres × (minor units per litre) ÷ 1000`, rounded once at the end —
  /// so 12.34 L at ৳121.50/L is a single rounding, not two.
  static Money fromVolume({required int ml, required Money pricePerLitre}) {
    return Money((ml * pricePerLitre.minor / 1000).round());
  }

  /// Unit price implied by a volume and a total. Inverse of [fromVolume].
  /// Returns `null` for a non-positive volume — guard every division.
  static Money? unitPrice({required int ml, required Money total}) {
    if (ml <= 0) return null;
    return Money((total.minor * 1000 / ml).round());
  }

  static int _pow10(int n) {
    var result = 1;
    for (var i = 0; i < n; i++) {
      result *= 10;
    }
    return result;
  }
}

/// Formats money for display. Held separately from [Money] so the value type
/// stays free of locale state.
class MoneyFormatter {
  /// [locale] is accepted for symmetry with the rest of the formatting layer
  /// but deliberately does not affect digits — see [Fmt.numberLocale]. Money
  /// renders in Latin digits in every language, because the numeral face has
  /// no others and neither does a pump receipt.
  MoneyFormatter({required this.currencyCode, String? locale});

  final String currencyCode;

  static const _digitLocale = 'en';

  /// Symbols for the currencies this app's users actually hold. Anything not
  /// listed falls back to the ISO code, which is never wrong — only terser.
  static const _symbols = <String, String>{
    'BDT': '৳',
    'INR': '₹',
    'PKR': '₨',
    'NPR': '₨',
    'LKR': 'Rs',
    'USD': r'$',
    'EUR': '€',
    'GBP': '£',
    'MYR': 'RM',
    'IDR': 'Rp',
    'PHP': '₱',
    'THB': '฿',
    'VND': '₫',
    'AED': 'AED',
    'SAR': 'SAR',
  };

  /// Currency codes offered in the picker, in the order they appear.
  static List<String> get supportedCurrencies => _symbols.keys.toList();

  static String symbolFor(String code) => _symbols[code] ?? code;

  String get symbol => symbolFor(currencyCode);

  /// `৳1,250.75`
  String format(Money money) => NumberFormat.currency(
    locale: _digitLocale,
    symbol: symbol,
    decimalDigits: 2,
  ).format(money.asMajor);

  /// `৳1,251` — for headline figures where paisa is visual noise. Only ever
  /// used for display; the underlying total stays exact.
  String formatRounded(Money money) => NumberFormat.currency(
    locale: _digitLocale,
    symbol: symbol,
    decimalDigits: 0,
  ).format(money.asMajor);

  /// `1,250.75` with no symbol, for tables and CSV-ish contexts where the
  /// currency is stated once in a header.
  String formatBare(Money money) =>
      NumberFormat('#,##0.00', _digitLocale).format(money.asMajor);

  /// Cost-per-distance figures are small and need more precision than a
  /// whole minor unit: `৳2.47`, `৳0.083`.
  String formatRate(double majorPerUnit) {
    final digits = majorPerUnit.abs() >= 1 ? 2 : 3;
    return '$symbol${NumberFormat('#,##0.${'0' * digits}', _digitLocale).format(majorPerUnit)}';
  }
}
