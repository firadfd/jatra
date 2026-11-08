import 'package:flutter/services.dart';

/// Restricts a field to one plain decimal number.
///
/// A decimal comma, which some keyboards offer instead of a point, becomes a
/// point rather than being dropped — dropping it turns `12,50` into `1250`.
/// When a paste holds both, as in `1,250.50`, the commas are thousands
/// separators and go. An edit that would add a second point is refused.
class DecimalInputFormatter extends TextInputFormatter {
  const DecimalInputFormatter();

  static final _allowed = FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'));

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text;
    final normalised = text.contains('.')
        ? _allowed.formatEditUpdate(oldValue, newValue)
        : _allowed.formatEditUpdate(
            oldValue,
            newValue.copyWith(text: text.replaceAll(',', '.')),
          );
    return '.'.allMatches(normalised.text).length > 1 ? oldValue : normalised;
  }
}

/// A stored quantity and the rounded text a form showed for it.
///
/// Text fields display fewer digits than the database holds, so parsing the
/// text back would quietly change a value the rider never touched.
class LoadedQuantity {
  const LoadedQuantity(this.text, this.value);

  final String text;
  final int value;
}

extension LoadedQuantityResolve on LoadedQuantity? {
  /// The stored value while [currentText] is untouched, otherwise [parse]d.
  int resolve(String currentText, int Function() parse) {
    final loaded = this;
    if (loaded == null || currentText.trim() != loaded.text.trim()) {
      return parse();
    }
    return loaded.value;
  }
}

/// Formats [value] to [maxDecimals], then drops trailing zeros down to
/// [minDecimals]: `4.070` → `4.07`, `4.066` → `4.066`.
String trimmedDecimal(
  double value, {
  required int minDecimals,
  required int maxDecimals,
}) {
  var text = value.toStringAsFixed(maxDecimals);
  final shortest = text.length - (maxDecimals - minDecimals);
  while (text.length > shortest && text.endsWith('0')) {
    text = text.substring(0, text.length - 1);
  }
  return text;
}
