import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_dimens.dart';
import 'app_text.dart';

/// Convenience accessors so widgets never reach for literal colours.
///
/// ```dart
/// Container(color: context.jatra.surface)
/// ```
extension JatraThemeContext on BuildContext {
  JatraColors get jatra => Theme.of(this).extension<JatraColors>()!;

  /// True when the platform or user has asked for reduced motion. The
  /// odometer barrel falls back to a cross-fade when this is set.
  bool get reduceMotion => MediaQuery.disableAnimationsOf(this);
}

abstract final class AppTheme {
  static ThemeData get dark => _build(JatraColors.dark, Brightness.dark);
  static ThemeData get light => _build(JatraColors.light, Brightness.light);

  static ThemeData _build(JatraColors c, Brightness brightness) {
    final scheme = ColorScheme(
      brightness: brightness,
      primary: c.signal,
      onPrimary: c.onSignal,
      secondary: c.data,
      onSecondary: c.onSignal,
      error: c.danger,
      onError: c.onSignal,
      surface: c.surface,
      onSurface: c.textPrimary,
      surfaceContainerHighest: c.surfaceElevated,
      outline: c.border,
    );

    final textTheme = TextTheme(
      displayLarge: AppText.numeralXl.copyWith(color: c.textPrimary),
      displayMedium: AppText.numeralLg.copyWith(color: c.textPrimary),
      displaySmall: AppText.numeralMd.copyWith(color: c.textPrimary),
      titleLarge: AppText.titleLg.copyWith(color: c.textPrimary),
      titleMedium: AppText.titleMd.copyWith(color: c.textPrimary),
      bodyLarge: AppText.body.copyWith(color: c.textSecondary),
      bodyMedium: AppText.bodySm.copyWith(color: c.textSecondary),
      bodySmall: AppText.caption.copyWith(color: c.textMuted),
      labelLarge: AppText.button,
      labelMedium: AppText.label.copyWith(color: c.textMuted),
      labelSmall: AppText.unit.copyWith(color: c.textMuted),
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor: c.background,
      canvasColor: c.background,
      textTheme: textTheme,
      fontFamily: AppFonts.body,
      fontFamilyFallback: AppFonts.fallback,
      extensions: <ThemeExtension<dynamic>>[c],

      // No drop shadows anywhere — surfaces are separated by a 1px border.
      // On dark backgrounds a shadow reads as a smudge, not as depth.
      shadowColor: Colors.transparent,
      cardTheme: CardThemeData(
        color: c.surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Radii.card),
          side: BorderSide(color: c.border, width: Dimens.border),
        ),
      ),

      appBarTheme: AppBarTheme(
        backgroundColor: c.background,
        surfaceTintColor: Colors.transparent,
        foregroundColor: c.textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: AppText.titleLg.copyWith(color: c.textPrimary),
      ),

      dividerTheme: DividerThemeData(
        color: c.border,
        thickness: Dimens.border,
        space: Dimens.border,
      ),

      // The bottom nav sits on the same background as the body and is
      // separated by the same 1px border as every other surface — no
      // elevation, no tint, consistent with the rest of the app.
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: c.background,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        height: 64,
        indicatorColor: c.signal.withValues(alpha: 0.16),
        indicatorShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Radii.chip),
        ),
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        iconTheme: WidgetStateProperty.resolveWith(
          (s) => IconThemeData(
            size: 22,
            color: s.contains(WidgetState.selected) ? c.signal : c.textMuted,
          ),
        ),
        labelTextStyle: WidgetStateProperty.resolveWith(
          (s) => AppText.caption.copyWith(
            color: s.contains(WidgetState.selected) ? c.signal : c.textMuted,
          ),
        ),
      ),

      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: c.signal,
        foregroundColor: c.onSignal,
        elevation: 0,
        focusElevation: 0,
        hoverElevation: 0,
        highlightElevation: 0,
        extendedTextStyle: AppText.button.copyWith(color: c.onSignal),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Radii.button),
        ),
      ),

      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: c.signal,
          foregroundColor: c.onSignal,
          disabledBackgroundColor: c.surfaceElevated,
          disabledForegroundColor: c.textMuted,
          minimumSize: const Size(0, Dimens.minTouchTarget),
          padding: const EdgeInsets.symmetric(horizontal: Gap.lg),
          textStyle: AppText.button,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(Radii.button),
          ),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: c.textPrimary,
          minimumSize: const Size(0, Dimens.minTouchTarget),
          padding: const EdgeInsets.symmetric(horizontal: Gap.lg),
          textStyle: AppText.button,
          side: BorderSide(color: c.border, width: Dimens.border),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(Radii.button),
          ),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: c.signal,
          minimumSize: const Size(0, Dimens.minTouchTarget),
          textStyle: AppText.button,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(Radii.button),
          ),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: c.surfaceElevated,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: Gap.md,
          vertical: Gap.md,
        ),
        labelStyle: AppText.bodySm.copyWith(color: c.textMuted),
        floatingLabelStyle: AppText.caption.copyWith(color: c.signal),
        hintStyle: AppText.body.copyWith(color: c.textMuted),
        helperStyle: AppText.caption.copyWith(color: c.textMuted),
        errorStyle: AppText.caption.copyWith(color: c.danger),
        // Suffix units render in the mono face, per the type rules.
        suffixStyle: AppText.unit.copyWith(color: c.textMuted),
        border: _inputBorder(c.border),
        enabledBorder: _inputBorder(c.border),
        focusedBorder: _inputBorder(c.signal, width: 2),
        errorBorder: _inputBorder(c.danger),
        focusedErrorBorder: _inputBorder(c.danger, width: 2),
        disabledBorder: _inputBorder(c.border),
      ),

      chipTheme: ChipThemeData(
        backgroundColor: c.surfaceElevated,
        selectedColor: c.signal,
        checkmarkColor: c.onSignal,
        labelStyle: AppText.bodySm.copyWith(color: c.textSecondary),
        secondaryLabelStyle: AppText.bodySm.copyWith(color: c.onSignal),
        side: BorderSide(color: c.border, width: Dimens.border),
        shape: const StadiumBorder(),
        padding: const EdgeInsets.symmetric(
          horizontal: Gap.sm,
          vertical: Gap.xs,
        ),
      ),

      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected) ? c.onSignal : c.textMuted,
        ),
        trackColor: WidgetStateProperty.resolveWith(
          (s) =>
              s.contains(WidgetState.selected) ? c.signal : c.surfaceElevated,
        ),
        trackOutlineColor: WidgetStateProperty.all(c.border),
      ),

      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: c.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        showDragHandle: true,
        dragHandleColor: c.border,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(Radii.card)),
        ),
      ),

      dialogTheme: DialogThemeData(
        backgroundColor: c.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        titleTextStyle: AppText.titleLg.copyWith(color: c.textPrimary),
        contentTextStyle: AppText.body.copyWith(color: c.textSecondary),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Radii.card),
          side: BorderSide(color: c.border, width: Dimens.border),
        ),
      ),

      snackBarTheme: SnackBarThemeData(
        backgroundColor: c.surfaceElevated,
        contentTextStyle: AppText.bodySm.copyWith(color: c.textPrimary),
        actionTextColor: c.signal,
        behavior: SnackBarBehavior.floating,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Radii.button),
          side: BorderSide(color: c.border, width: Dimens.border),
        ),
      ),

      listTileTheme: ListTileThemeData(
        iconColor: c.textMuted,
        textColor: c.textPrimary,
        titleTextStyle: AppText.titleMd.copyWith(color: c.textPrimary),
        subtitleTextStyle: AppText.bodySm.copyWith(color: c.textMuted),
        minVerticalPadding: Gap.sm,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Radii.button),
        ),
      ),

      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: c.signal,
        linearTrackColor: c.surfaceElevated,
        circularTrackColor: c.surfaceElevated,
      ),

      iconTheme: IconThemeData(color: c.textSecondary, size: 22),

      splashFactory: InkSparkle.splashFactory,
    );
  }

  static OutlineInputBorder _inputBorder(Color color, {double width = 1}) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(Radii.input),
      borderSide: BorderSide(color: color, width: width),
    );
  }
}
