/// Layout constants. Everything sits on an 8pt grid.
abstract final class Gap {
  static const xs = 4.0;
  static const sm = 8.0;
  static const md = 16.0;
  static const lg = 24.0;
  static const xl = 32.0;
  static const xxl = 48.0;
}

abstract final class Radii {
  static const card = 16.0;
  static const button = 12.0;
  static const input = 12.0;

  /// Chips are full-round; any value past half the height achieves that.
  static const chip = 999.0;
}

abstract final class Dimens {
  /// Minimum interactive size. People use this one-handed at a fuel pump,
  /// sometimes wearing gloves — nothing tappable goes below this.
  static const minTouchTarget = 48.0;

  /// Hairline separator. In dark mode this replaces elevation entirely.
  static const border = 1.0;

  /// Content max width, so the layout does not sprawl on tablets.
  static const contentMaxWidth = 560.0;
}
