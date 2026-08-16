import 'package:flutter/material.dart';

import '../../app/theme/app_dimens.dart';
import '../../app/theme/app_text.dart';
import '../../app/theme/app_theme.dart';

/// A mechanical odometer barrel.
///
/// Each digit sits in its own dark cell separated by a hairline. When the
/// value changes, digits roll vertically into place, staggered right to left
/// and eased out — the way a real barrel drags its neighbours along.
///
/// This is the one memorable moment in the app; everything else stays calm.
/// The animation budget is spent here on purpose.
///
/// Honours reduced motion: when `MediaQuery.disableAnimations` is set the roll
/// is replaced by a straight cross-fade.
class OdometerStrip extends StatelessWidget {
  const OdometerStrip({
    super.key,
    required this.value,
    this.unitLabel,
    this.minDigits = 5,
    this.digitHeight = 56,
    this.digitWidth = 34,
    this.fontSize = 44,
    this.groupSeparatorEvery = 3,
  });

  /// The reading, already converted to the user's distance unit and rounded.
  /// Negative values are clamped to zero — an odometer cannot run backwards.
  final int value;

  /// Rendered to the right of the barrel in the mono face, e.g. `KM`.
  final String? unitLabel;

  /// Pads with leading zeros so a bike at 4,180 km still reads as an
  /// instrument rather than a number that shrank.
  final int minDigits;

  final double digitHeight;
  final double digitWidth;
  final double fontSize;

  /// Insert a slim spacer every N digits from the right. 0 disables grouping.
  final int groupSeparatorEvery;

  @override
  Widget build(BuildContext context) {
    final c = context.jatra;
    final digits = _digitsOf(value < 0 ? 0 : value, minDigits);

    // Built right-to-left so the stagger index and the grouping both count
    // from the least-significant digit, then reversed for display.
    final cells = <Widget>[];
    for (var i = 0; i < digits.length; i++) {
      final fromRight = i;
      final digit = digits[digits.length - 1 - i];

      cells.add(
        _DigitCell(
          digit: digit,
          height: digitHeight,
          width: digitWidth,
          fontSize: fontSize,
          // Right-most digit leads; each step left lags by 45 ms. Capped so a
          // seven-figure odometer does not take a full second to settle.
          delay: Duration(milliseconds: (fromRight * 45).clamp(0, 360)),
        ),
      );

      final isLast = i == digits.length - 1;
      if (!isLast) {
        final isGroupBoundary =
            groupSeparatorEvery > 0 &&
            (fromRight + 1) % groupSeparatorEvery == 0;
        cells.add(SizedBox(width: isGroupBoundary ? Gap.xs : 1.5));
      }
    }

    return Semantics(
      label: unitLabel == null ? '$value' : '$value $unitLabel',
      excludeSemantics: true,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          DecoratedBox(
            decoration: BoxDecoration(
              color: c.odometerCell,
              borderRadius: BorderRadius.circular(Radii.button),
              border: Border.all(color: c.border, width: Dimens.border),
            ),
            child: Padding(
              padding: const EdgeInsets.all(Gap.xs),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: cells.reversed.toList(),
              ),
            ),
          ),
          if (unitLabel != null) ...[
            const SizedBox(width: Gap.sm),
            Padding(
              padding: const EdgeInsets.only(bottom: Gap.sm),
              child: Text(
                unitLabel!,
                style: AppText.unit.copyWith(color: c.textMuted),
              ),
            ),
          ],
        ],
      ),
    );
  }

  static List<int> _digitsOf(int value, int minDigits) {
    final text = value.toString().padLeft(minDigits, '0');
    return [for (final ch in text.codeUnits) ch - 0x30];
  }
}

/// One barrel cell. Owns its own animation so digits that did not change do
/// not rebuild or re-roll.
class _DigitCell extends StatefulWidget {
  const _DigitCell({
    required this.digit,
    required this.height,
    required this.width,
    required this.fontSize,
    required this.delay,
  });

  final int digit;
  final double height;
  final double width;
  final double fontSize;
  final Duration delay;

  @override
  State<_DigitCell> createState() => _DigitCellState();
}

class _DigitCellState extends State<_DigitCell>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 420),
  );

  /// The digit currently shown at rest; [_incoming] rolls in over it.
  late int _settled = widget.digit;
  int? _incoming;

  @override
  void initState() {
    super.initState();
    _controller.addStatusListener(_onDone);
  }

  @override
  void didUpdateWidget(covariant _DigitCell old) {
    super.didUpdateWidget(old);
    if (widget.digit == old.digit) return;

    // A change arriving mid-roll: land the in-flight digit first so the
    // barrel never appears to skip a value.
    if (_incoming != null) _settled = _incoming!;

    setState(() => _incoming = widget.digit);
    _controller.reset();

    // The stagger delays the *start*, not the curve, so every digit travels
    // at the same speed — the way a real barrel drags its neighbours along.
    Future<void>.delayed(widget.delay, () {
      if (mounted && _incoming != null) _controller.forward(from: 0);
    });
  }

  void _onDone(AnimationStatus status) {
    if (status != AnimationStatus.completed || !mounted) return;
    setState(() {
      _settled = _incoming ?? _settled;
      _incoming = null;
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.jatra;
    final style = AppText.numeralXl.copyWith(
      fontSize: widget.fontSize,
      color: c.odometerDigit,
      height: 1.0,
    );

    final incoming = _incoming;
    final reduceMotion = context.reduceMotion;

    Widget content;
    if (incoming == null) {
      content = _glyph(_settled, style);
    } else if (reduceMotion) {
      content = AnimatedBuilder(
        animation: _controller,
        builder: (_, _) => Stack(
          alignment: Alignment.center,
          children: [
            Opacity(
              opacity: 1 - _controller.value,
              child: _glyph(_settled, style),
            ),
            Opacity(opacity: _controller.value, child: _glyph(incoming, style)),
          ],
        ),
      );
    } else {
      content = AnimatedBuilder(
        animation: _controller,
        builder: (_, _) {
          // Ease-out: fast off the mark, settling gently into the detent.
          final t = Curves.easeOutCubic.transform(_controller.value);
          return Stack(
            clipBehavior: Clip.none,
            children: [
              // Outgoing digit rises out of the window…
              Transform.translate(
                offset: Offset(0, -widget.height * t),
                child: _glyph(_settled, style),
              ),
              // …while the incoming one climbs in from below.
              Transform.translate(
                offset: Offset(0, widget.height * (1 - t)),
                child: _glyph(incoming, style),
              ),
            ],
          );
        },
      );
    }

    return ClipRect(
      child: SizedBox(
        height: widget.height,
        width: widget.width,
        child: content,
      ),
    );
  }

  Widget _glyph(int digit, TextStyle style) => SizedBox(
    height: widget.height,
    width: widget.width,
    child: Center(
      child: Text('$digit', style: style, textAlign: TextAlign.center),
    ),
  );
}

/// Compact, non-animating variant for list rows and cards, where a rolling
/// barrel would be noise rather than delight.
class OdometerChip extends StatelessWidget {
  const OdometerChip({super.key, required this.text, this.unitLabel});

  final String text;
  final String? unitLabel;

  @override
  Widget build(BuildContext context) {
    final c = context.jatra;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: Gap.sm, vertical: 3),
      decoration: BoxDecoration(
        color: c.odometerCell,
        borderRadius: BorderRadius.circular(Radii.button),
        border: Border.all(color: c.border, width: Dimens.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.baseline,
        textBaseline: TextBaseline.alphabetic,
        children: [
          Text(text, style: AppText.numeralSm.copyWith(color: c.odometerDigit)),
          if (unitLabel != null) ...[
            const SizedBox(width: 3),
            Text(unitLabel!, style: AppText.unit.copyWith(color: c.textMuted)),
          ],
        ],
      ),
    );
  }
}
