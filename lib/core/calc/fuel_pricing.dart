import '../../data/models/enums.dart';
import '../utils/money.dart';
import '../utils/numeric_input.dart';
import '../utils/units.dart';

/// Keeps a fill's unit price stable between the form and the database.
///
/// Dividing the total by the stored volume does not give back the pump price:
/// volume is rounded to a whole millilitre, and on a small fill that alone
/// moves the result by several paisa.
abstract final class FuelPricing {
  /// The per-litre price to store. The price the rider entered wins when it
  /// agrees with the volume and total; otherwise it is derived from them.
  static Money perLitreToStore({
    required int ml,
    required Money total,
    required double? enteredPerUnit,
    required VolumeUnit unit,
  }) {
    final derived = Money.unitPrice(ml: ml, total: total) ?? Money.zero;
    if (enteredPerUnit == null || enteredPerUnit <= 0) return derived;

    final perLitreMinor = enteredPerUnit * 100 / Units.mlTo(1000, unit);
    return _agrees(ml: ml, total: total, perLitreMinor: perLitreMinor)
        ? Money(perLitreMinor.round())
        : derived;
  }

  /// The per-unit price to show for a saved fill, or `null` without a volume.
  ///
  /// The stored price is only used for litres, and only when it explains the
  /// total. It is whole paisa per litre, so a gallon price or a three-decimal
  /// pump price is recovered from the total instead.
  static String? priceText({
    required int ml,
    required Money total,
    required Money storedPerLitre,
    required VolumeUnit unit,
  }) {
    if (ml <= 0) return null;
    if (unit == VolumeUnit.l &&
        storedPerLitre.isPositive &&
        _agrees(
          ml: ml,
          total: total,
          perLitreMinor: storedPerLitre.minor.toDouble(),
        )) {
      return storedPerLitre.asMajor.toStringAsFixed(2);
    }
    return trimmedDecimal(
      total.asMajor / Units.mlTo(ml, unit),
      minDecimals: 2,
      maxDecimals: 3,
    );
  }

  /// Whether [perLitreMinor] × [ml] lands on [total], allowing for the volume
  /// being up to half a millilitre out and the total up to a minor unit out.
  static bool _agrees({
    required int ml,
    required Money total,
    required double perLitreMinor,
  }) {
    final expected = ml * perLitreMinor / 1000;
    final tolerance = perLitreMinor / 2000 + 1;
    return (expected - total.minor).abs() <= tolerance;
  }
}
