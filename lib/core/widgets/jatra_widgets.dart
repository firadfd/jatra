import 'package:flutter/material.dart';

import '../../app/theme/app_dimens.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_text.dart';
import '../../app/theme/app_theme.dart';

/// Shared UI components.
///
/// Two rules run through all of them:
/// * no drop shadows — surfaces separate with a 1px border;
/// * nothing tappable is smaller than 48dp, because people use this
///   one-handed at a fuel pump, sometimes wearing gloves.

/// A bordered surface. Replaces `Card`'s elevation with a hairline.
class JatraCard extends StatelessWidget {
  const JatraCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(Gap.md),
    this.onTap,
    this.accent,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;

  /// Tints the border and adds a left rule — used to flag a card as a
  /// warning or a status without shouting.
  final Color? accent;

  @override
  Widget build(BuildContext context) {
    final c = context.jatra;
    final radius = BorderRadius.circular(Radii.card);
    final padded = Padding(padding: padding, child: child);

    // The surface is a Material rather than a decorated Container, and it is
    // the *outermost* widget here on purpose.
    //
    // ListTile and SwitchListTile paint their background and ink on the
    // nearest Material ancestor. With a DecoratedBox in between, Flutter
    // asserts ("ListTile background color or ink splashes may be invisible")
    // and renders an error box in debug — which is what happened when this
    // card only supplied a Material in the tappable branch. Every card now
    // provides one, so a list tile can sit in any of them.
    //
    // `shape` carries the 1px border; elevation stays 0, so the no-shadow
    // rule is unchanged.
    return Material(
      color: c.surface,
      // Clips ink to the rounded corners, which the old outer InkWell got
      // from its borderRadius.
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: radius,
        side: BorderSide(color: accent ?? c.border, width: Dimens.border),
      ),
      child: onTap == null ? padded : InkWell(onTap: onTap, child: padded),
    );
  }
}

/// A number with its unit, set the way the design system requires: the
/// figure in the condensed tabular face, the unit in mono, smaller, muted.
///
/// ```
/// 44.2 KM/L
/// ```
class StatValue extends StatelessWidget {
  const StatValue({
    super.key,
    required this.value,
    this.unit,
    this.style,
    this.color,
    this.prefix,
    this.semanticsLabel,
  });

  final String value;
  final String? unit;
  final TextStyle? style;
  final Color? color;

  /// Leading widget on the same baseline — a trend arrow, usually.
  final Widget? prefix;

  /// Overrides what a screen reader announces. Without it the reader would
  /// read the number and the unit as two unrelated fragments — "44.2",
  /// pause, "K M slash L" — so they are merged into one label.
  final String? semanticsLabel;

  @override
  Widget build(BuildContext context) {
    final c = context.jatra;
    final base = (style ?? AppText.numeralLg).copyWith(
      color: color ?? c.textPrimary,
    );

    return Semantics(
      label: semanticsLabel ?? (unit == null ? value : '$value $unit'),
      excludeSemantics: true,
      child: _row(context, base, c),
    );
  }

  Widget _row(BuildContext context, TextStyle base, JatraColors c) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        if (prefix != null) ...[prefix!, const SizedBox(width: Gap.xs)],
        Flexible(child: Text(value, style: base, maxLines: 1, softWrap: false)),
        if (unit != null) ...[
          const SizedBox(width: Gap.xs),
          Text(unit!, style: AppText.unit.copyWith(color: c.textMuted)),
        ],
      ],
    );
  }
}

/// Uppercase mono section label, e.g. `THIS MONTH`.
class SectionLabel extends StatelessWidget {
  const SectionLabel(this.text, {super.key, this.trailing, this.color});

  final String text;
  final Widget? trailing;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final c = context.jatra;
    final label = Text(
      text.toUpperCase(),
      style: AppText.label.copyWith(color: color ?? c.textMuted),
    );
    if (trailing == null) return label;
    return Row(children: [label, const Spacer(), trailing!]);
  }
}

/// Small status chip — service urgency, "unreliable window", "partial fill".
class StatusPill extends StatelessWidget {
  const StatusPill({
    super.key,
    required this.text,
    required this.color,
    this.filled = false,
    this.icon,
  });

  final String text;
  final Color color;
  final bool filled;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      // The visible label is uppercased for the design; screen readers get
      // the natural-case text, because some spell out all-caps words.
      label: text,
      excludeSemantics: true,
      child: _pill(context),
    );
  }

  Widget _pill(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: Gap.sm, vertical: 3),
      decoration: BoxDecoration(
        color: filled ? color : color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(Radii.chip),
        border: Border.all(color: color, width: Dimens.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              size: 12,
              color: filled ? context.jatra.onSignal : color,
            ),
            const SizedBox(width: Gap.xs),
          ],
          Text(
            text.toUpperCase(),
            style: AppText.unit.copyWith(
              color: filled ? context.jatra.onSignal : color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

/// Empty states are invitations, not apologies — so the action that fills the
/// screen sits right inside it.
class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  final IconData icon;
  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final c = context.jatra;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(Gap.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 40, color: c.textMuted),
            const SizedBox(height: Gap.md),
            Text(
              title,
              style: AppText.titleMd.copyWith(color: c.textPrimary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: Gap.sm),
            Text(
              message,
              style: AppText.bodySm.copyWith(color: c.textMuted),
              textAlign: TextAlign.center,
            ),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: Gap.lg),
              FilledButton(onPressed: onAction, child: Text(actionLabel!)),
            ],
          ],
        ),
      ),
    );
  }
}

/// Progress toward a service item's next due point.
///
/// Clamped to [0,1] for the bar but the caller still gets to say "112%" in
/// text — an overdue item should read as overdue, not as a full bar.
class ProgressRule extends StatelessWidget {
  const ProgressRule({
    super.key,
    required this.fraction,
    required this.color,
    this.height = 4,
    this.semanticsLabel,
  });

  final double fraction;
  final Color color;
  final double height;
  final String? semanticsLabel;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label:
          semanticsLabel ?? '${(fraction * 100).round()}% of the interval used',
      excludeSemantics: true,
      child: _bar(context),
    );
  }

  Widget _bar(BuildContext context) {
    final c = context.jatra;
    return ClipRRect(
      borderRadius: BorderRadius.circular(height),
      child: LinearProgressIndicator(
        value: fraction.clamp(0.0, 1.0),
        minHeight: height,
        backgroundColor: c.surfaceElevated,
        valueColor: AlwaysStoppedAnimation(color),
      ),
    );
  }
}

/// Constrains content width so the layout does not sprawl on a tablet, and
/// centres it.
class ContentColumn extends StatelessWidget {
  const ContentColumn({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: Dimens.contentMaxWidth),
        child: child,
      ),
    );
  }
}

/// A labelled row inside a detail sheet: label left in mono, value right.
class DetailRow extends StatelessWidget {
  const DetailRow({super.key, required this.label, required this.value});

  final String label;
  final Widget value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: Gap.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: SectionLabel(label)),
          const SizedBox(width: Gap.md),
          value,
        ],
      ),
    );
  }
}
