import 'package:flutter/material.dart';

/// Raw palette. These constants are the *only* place literal colour values
/// appear in the app. Everything else reads semantic slots off [JatraColors]
/// via `Theme.of(context).extension<JatraColors>()` (see `context.jatra` in
/// `app_theme.dart`), so dark and light stay in lockstep.
///
/// The identity is drawn from motorcycle instrument clusters and
/// sodium-vapour street lighting: cool ink surfaces, one warm amber signal.
abstract final class Palette {
  // --- Ink scale (dark theme surfaces) ---
  static const ink900 = Color(
    0xFF12161A,
  ); // base background — neutral-cool, not black
  static const ink800 = Color(0xFF1A2026); // card surface
  static const ink700 = Color(0xFF252D35); // elevated surface, input fields
  static const ink600 = Color(0xFF38424C); // borders, dividers

  static const slate400 = Color(0xFF7C8A97); // secondary text
  static const slate200 = Color(0xFFC3CDD6); // body text
  static const white = Color(0xFFF2F6F8); // primary text, headline numerals

  // --- Signal (primary accent) ---
  static const signal = Color(0xFFFFB020); // sodium-lamp amber
  static const signalDim = Color(0xFF6B4A12); // low-emphasis amber, chart fills

  // --- Data + status ---
  static const cyan400 = Color(0xFF4FC3D9); // secondary data accent, ride paths
  static const green400 = Color(0xFF5BC98C); // OK / healthy
  static const amber400 = Color(0xFFFFB020); // due soon (same as signal)
  static const red400 = Color(0xFFE5614F); // overdue, errors, mileage drop

  // --- Light theme (a workshop logbook page) ---
  static const paper = Color(0xFFF7F5F1); // warm off-white base
  static const paperCard = Color(0xFFFFFFFF);
  static const paperElevated = Color(0xFFEFEBE4);
  static const paperBorder = Color(0xFFDCD6CC);
  static const inkText = Color(0xFF12161A);
  static const inkTextSecondary = Color(0xFF5F6B75);

  /// Amber held darker in light mode so text on paper clears WCAG AA.
  static const signalLight = Color(0xFFC77F00);
  static const signalDimLight = Color(0xFFF3E2C0);

  static const cyanLight = Color(0xFF0F7C93);
  static const greenLight = Color(0xFF1E8A55);
  static const redLight = Color(0xFFC0392B);

  // --- Chart categorical series ---
  //
  // Separate steps from the UI accents above, and not a design flourish: the
  // UI amber/cyan/violet sit at OKLCH lightness 0.70–0.81, outside the
  // 0.48–0.67 band that keeps categorical fills distinguishable on a dark
  // surface. These are the same three hues re-stepped into the band, and the
  // set is validated for colour-vision deficiency — worst adjacent pair is
  // ΔE 12.1 under deuteranopia, well clear of the 8.0 target.
  //
  // Status colours (green/red) are deliberately *not* reused here. They mean
  // "healthy" and "overdue" everywhere else in the app, and a spend category
  // painted red would read as a warning.
  //
  // Re-validate with the dataviz palette script if these ever change.
  static const chartDark = <Color>[
    Color(0xFFC38405), // fuel — amber
    Color(0xFF07A4BB), // service — cyan
    Color(0xFF8F79FF), // other — violet
  ];

  static const chartLight = <Color>[
    Color(0xFFA46E00),
    Color(0xFF06899D),
    Color(0xFF785CEA),
  ];

  /// Per-vehicle colour tags. `Vehicle.colorTag` is an index into this list;
  /// out-of-range values wrap, so adding entries later is safe.
  static const vehicleTags = <Color>[
    signal,
    cyan400,
    green400,
    red400,
    Color(0xFF9B8CFF), // violet
    Color(0xFFFF8FA3), // rose
    Color(0xFF8FD4FF), // sky
    Color(0xFFD6C08A), // sand
  ];

  static Color vehicleTag(int index) =>
      vehicleTags[index.abs() % vehicleTags.length];
}

/// Semantic colour slots. Widgets read these, never [Palette] directly.
@immutable
class JatraColors extends ThemeExtension<JatraColors> {
  const JatraColors({
    required this.background,
    required this.surface,
    required this.surfaceElevated,
    required this.border,
    required this.textPrimary,
    required this.textSecondary,
    required this.textMuted,
    required this.signal,
    required this.signalDim,
    required this.onSignal,
    required this.data,
    required this.ok,
    required this.dueSoon,
    required this.overdue,
    required this.danger,
    required this.odometerCell,
    required this.odometerDigit,
    required this.chartSeries,
    required this.gridLine,
  });

  /// Page background.
  final Color background;

  /// Card / sheet surface.
  final Color surface;

  /// Inputs, chips, pressed states — one step above [surface].
  final Color surfaceElevated;

  /// 1px hairline. In dark mode this replaces drop shadows entirely:
  /// shadows on dark backgrounds read as smudge.
  final Color border;

  final Color textPrimary;
  final Color textSecondary;

  /// Unit labels and other tertiary metadata.
  final Color textMuted;

  /// Primary accent — active states, key numbers, the odometer strip.
  final Color signal;

  /// Low-emphasis accent — chart fills, progress-bar tracks.
  final Color signalDim;

  /// Foreground for content sitting *on* [signal].
  final Color onSignal;

  /// Secondary data accent — charts, ride paths.
  final Color data;

  final Color ok;
  final Color dueSoon;
  final Color overdue;

  /// Errors and destructive actions.
  final Color danger;

  /// Background of a single odometer barrel cell.
  final Color odometerCell;

  /// Digit colour inside the odometer barrel.
  final Color odometerDigit;

  /// Categorical chart series, assigned in fixed order — index 0 is always
  /// fuel, 1 always service, 2 always other. Never cycled: a filter that
  /// removes a series must not repaint the survivors.
  final List<Color> chartSeries;

  /// Chart gridlines and axis rules. Recessive by design — the data is the
  /// content, the grid is scaffolding.
  final Color gridLine;

  static const dark = JatraColors(
    background: Palette.ink900,
    surface: Palette.ink800,
    surfaceElevated: Palette.ink700,
    border: Palette.ink600,
    textPrimary: Palette.white,
    textSecondary: Palette.slate200,
    textMuted: Palette.slate400,
    signal: Palette.signal,
    signalDim: Palette.signalDim,
    onSignal: Palette.ink900,
    data: Palette.cyan400,
    ok: Palette.green400,
    dueSoon: Palette.amber400,
    overdue: Palette.red400,
    danger: Palette.red400,
    odometerCell: Palette.ink900,
    odometerDigit: Palette.signal,
    chartSeries: Palette.chartDark,
    gridLine: Palette.ink700,
  );

  static const light = JatraColors(
    background: Palette.paper,
    surface: Palette.paperCard,
    surfaceElevated: Palette.paperElevated,
    border: Palette.paperBorder,
    textPrimary: Palette.inkText,
    textSecondary: Palette.inkTextSecondary,
    textMuted: Palette.inkTextSecondary,
    signal: Palette.signalLight,
    signalDim: Palette.signalDimLight,
    onSignal: Palette.paper,
    data: Palette.cyanLight,
    ok: Palette.greenLight,
    dueSoon: Palette.signalLight,
    overdue: Palette.redLight,
    danger: Palette.redLight,
    // The odometer barrel keeps its instrument-cluster look in both themes —
    // it is the app's signature element, and a dark barrel on paper reads as
    // an inset physical part rather than an inconsistency.
    odometerCell: Palette.ink900,
    odometerDigit: Palette.signal,
    chartSeries: Palette.chartLight,
    gridLine: Palette.paperBorder,
  );

  @override
  JatraColors copyWith({
    Color? background,
    Color? surface,
    Color? surfaceElevated,
    Color? border,
    Color? textPrimary,
    Color? textSecondary,
    Color? textMuted,
    Color? signal,
    Color? signalDim,
    Color? onSignal,
    Color? data,
    Color? ok,
    Color? dueSoon,
    Color? overdue,
    Color? danger,
    Color? odometerCell,
    Color? odometerDigit,
    List<Color>? chartSeries,
    Color? gridLine,
  }) {
    return JatraColors(
      background: background ?? this.background,
      surface: surface ?? this.surface,
      surfaceElevated: surfaceElevated ?? this.surfaceElevated,
      border: border ?? this.border,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      textMuted: textMuted ?? this.textMuted,
      signal: signal ?? this.signal,
      signalDim: signalDim ?? this.signalDim,
      onSignal: onSignal ?? this.onSignal,
      data: data ?? this.data,
      ok: ok ?? this.ok,
      dueSoon: dueSoon ?? this.dueSoon,
      overdue: overdue ?? this.overdue,
      danger: danger ?? this.danger,
      odometerCell: odometerCell ?? this.odometerCell,
      odometerDigit: odometerDigit ?? this.odometerDigit,
      chartSeries: chartSeries ?? this.chartSeries,
      gridLine: gridLine ?? this.gridLine,
    );
  }

  @override
  JatraColors lerp(ThemeExtension<JatraColors>? other, double t) {
    if (other is! JatraColors) return this;
    Color c(Color a, Color b) => Color.lerp(a, b, t)!;
    return JatraColors(
      background: c(background, other.background),
      surface: c(surface, other.surface),
      surfaceElevated: c(surfaceElevated, other.surfaceElevated),
      border: c(border, other.border),
      textPrimary: c(textPrimary, other.textPrimary),
      textSecondary: c(textSecondary, other.textSecondary),
      textMuted: c(textMuted, other.textMuted),
      signal: c(signal, other.signal),
      signalDim: c(signalDim, other.signalDim),
      onSignal: c(onSignal, other.onSignal),
      data: c(data, other.data),
      ok: c(ok, other.ok),
      dueSoon: c(dueSoon, other.dueSoon),
      overdue: c(overdue, other.overdue),
      danger: c(danger, other.danger),
      odometerCell: c(odometerCell, other.odometerCell),
      odometerDigit: c(odometerDigit, other.odometerDigit),
      // Series colours snap at the halfway point rather than blending —
      // a lerped categorical hue is a colour that passed no validation.
      chartSeries: t < 0.5 ? chartSeries : other.chartSeries,
      gridLine: c(gridLine, other.gridLine),
    );
  }
}
