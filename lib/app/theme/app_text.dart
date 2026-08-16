import 'package:flutter/material.dart';

/// Font families bundled in `assets/fonts`. No runtime font fetching —
/// `google_fonts` would require network access, which this app does not have.
abstract final class AppFonts {
  /// Condensed grotesque with `tnum`. Numerals only.
  static const display = 'BarlowCondensed';

  /// Body and UI.
  static const body = 'Inter';

  /// Units, codes, data labels. Monospace ⇒ tabular by construction.
  static const mono = 'JetBrainsMono';

  /// Bangla. Appended to every style's fallback chain so Bangla text renders
  /// correctly everywhere — including inside chart labels, which do not
  /// inherit from the widget tree.
  static const bangla = 'HindSiliguri';

  static const fallback = <String>[bangla];
}

/// Digits must not shift width as values change — a rolling odometer or a
/// live-updating cost figure that jitters horizontally looks broken.
const _tabular = <FontFeature>[FontFeature.tabularFigures()];

/// The type scale: 40 / 28 / 20 / 16 / 14 / 12 / 11.
///
/// Sizes are in logical pixels and scale with the user's text-size setting.
abstract final class AppText {
  // ---------------------------------------------------------------------
  // Numerals — the content of this app.
  // ---------------------------------------------------------------------

  /// 40 — the home-screen headline figure (odometer, headline km/L).
  static const numeralXl = TextStyle(
    fontFamily: AppFonts.display,
    fontFamilyFallback: AppFonts.fallback,
    fontSize: 40,
    height: 1.0,
    fontWeight: FontWeight.w600,
    fontFeatures: _tabular,
    letterSpacing: 0.5,
  );

  /// 28 — card headline figures (cost/km, this month's spend).
  static const numeralLg = TextStyle(
    fontFamily: AppFonts.display,
    fontFamilyFallback: AppFonts.fallback,
    fontSize: 28,
    height: 1.05,
    fontWeight: FontWeight.w600,
    fontFeatures: _tabular,
  );

  /// 20 — list-row figures (a fill's km/L, a month subtotal).
  static const numeralMd = TextStyle(
    fontFamily: AppFonts.display,
    fontFamilyFallback: AppFonts.fallback,
    fontSize: 20,
    height: 1.1,
    fontWeight: FontWeight.w600,
    fontFeatures: _tabular,
  );

  /// 16 — inline figures inside body text.
  static const numeralSm = TextStyle(
    fontFamily: AppFonts.display,
    fontFamilyFallback: AppFonts.fallback,
    fontSize: 16,
    height: 1.15,
    fontWeight: FontWeight.w500,
    fontFeatures: _tabular,
  );

  // ---------------------------------------------------------------------
  // Body / UI — Inter, regular and medium only.
  // ---------------------------------------------------------------------

  /// 28 — onboarding and empty-screen headlines. Body face, not the numeral
  /// face: the condensed grotesque is reserved for figures.
  static const headline = TextStyle(
    fontFamily: AppFonts.body,
    fontFamilyFallback: AppFonts.fallback,
    fontSize: 28,
    height: 1.25,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.4,
  );

  /// 20 — screen and sheet titles.
  static const titleLg = TextStyle(
    fontFamily: AppFonts.body,
    fontFamilyFallback: AppFonts.fallback,
    fontSize: 20,
    height: 1.3,
    fontWeight: FontWeight.w600,
  );

  /// 16 — card titles, list row primary text.
  static const titleMd = TextStyle(
    fontFamily: AppFonts.body,
    fontFamilyFallback: AppFonts.fallback,
    fontSize: 16,
    height: 1.35,
    fontWeight: FontWeight.w500,
  );

  /// 16 — body copy.
  static const body = TextStyle(
    fontFamily: AppFonts.body,
    fontFamilyFallback: AppFonts.fallback,
    fontSize: 16,
    height: 1.45,
    fontWeight: FontWeight.w400,
  );

  /// 14 — secondary body, list row supporting text.
  static const bodySm = TextStyle(
    fontFamily: AppFonts.body,
    fontFamilyFallback: AppFonts.fallback,
    fontSize: 14,
    height: 1.45,
    fontWeight: FontWeight.w400,
  );

  /// 14 — button labels.
  static const button = TextStyle(
    fontFamily: AppFonts.body,
    fontFamilyFallback: AppFonts.fallback,
    fontSize: 15,
    height: 1.2,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.1,
  );

  /// 12 — captions, helper text under inputs.
  static const caption = TextStyle(
    fontFamily: AppFonts.body,
    fontFamilyFallback: AppFonts.fallback,
    fontSize: 12,
    height: 1.35,
    fontWeight: FontWeight.w400,
  );

  // ---------------------------------------------------------------------
  // Data labels / units — mono, letter-spaced, uppercase.
  // Always smaller than the number they follow:  44.2 KM/L
  // ---------------------------------------------------------------------

  /// 12 — section labels above data ("THIS MONTH", "NEXT SERVICE").
  static const label = TextStyle(
    fontFamily: AppFonts.mono,
    fontFamilyFallback: AppFonts.fallback,
    fontSize: 12,
    height: 1.2,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.8,
  );

  /// 11 — the unit suffix on a figure.
  static const unit = TextStyle(
    fontFamily: AppFonts.mono,
    fontFamilyFallback: AppFonts.fallback,
    fontSize: 11,
    height: 1.2,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.6,
  );
}
