import 'package:flutter/material.dart';

import '../../../app/theme/app_dimens.dart';
import '../../../app/theme/app_text.dart';
import '../../../app/theme/app_theme.dart';
import '../../../core/calc/mileage_calc.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/utils/money.dart';
import '../../../core/widgets/jatra_widgets.dart';
import '../../../l10n/app_localizations.dart';
import '../../../data/db/database.dart';

/// One fill in the history list.
///
/// The km/L cell is the point of the row, so it gets the right-hand anchor
/// and the numeral face. What it shows depends on what the entry actually
/// supports:
///
/// * a reliable window it closes → the figure;
/// * an unreliable window → the figure, flagged, greyed;
/// * a partial fill → `PARTIAL`, because it can never have a figure;
/// * the first full tank → `—`, because there is nothing to measure against.
class FuelRow extends StatelessWidget {
  const FuelRow({
    super.key,
    required this.entry,
    required this.window,
    required this.fmt,
    this.onTap,
  });

  final FuelEntryRow entry;
  final MileageWindow? window;
  final Fmt fmt;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.jatra;

    return JatraCard(
      onTap: onTap,
      padding: const EdgeInsets.symmetric(horizontal: Gap.md, vertical: Gap.sm),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      fmt.dateShort(entry.dateMs),
                      style: AppText.titleMd.copyWith(color: c.textPrimary),
                    ),
                    const SizedBox(width: Gap.sm),
                    if (!entry.isFullTank)
                      StatusPill(
                        text: L.of(context).fuelPartial,
                        color: c.textMuted,
                      ),
                    if (entry.isMissedEntry) ...[
                      const SizedBox(width: Gap.xs),
                      StatusPill(
                        text: L.of(context).fuelGap,
                        color: c.overdue,
                        icon: Icons.report_gmailerrorred_outlined,
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  [
                    '${fmt.volume(entry.volumeMl)} ${fmt.volumeLabel.toLowerCase()}',
                    fmt.amount(Money(entry.totalCostMinor)),
                    '${fmt.distance(entry.odometerM)} ${fmt.distanceLabel.toLowerCase()}',
                  ].join(' · '),
                  style: AppText.bodySm.copyWith(color: c.textMuted),
                  overflow: TextOverflow.ellipsis,
                ),
                if (entry.station != null)
                  Text(
                    entry.station!,
                    style: AppText.caption.copyWith(color: c.textMuted),
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),
          const SizedBox(width: Gap.sm),
          _EconomyCell(entry: entry, window: window, fmt: fmt),
        ],
      ),
    );
  }
}

class _EconomyCell extends StatelessWidget {
  const _EconomyCell({
    required this.entry,
    required this.window,
    required this.fmt,
  });

  final FuelEntryRow entry;
  final MileageWindow? window;
  final Fmt fmt;

  @override
  Widget build(BuildContext context) {
    final c = context.jatra;

    if (!entry.isFullTank) {
      return SizedBox(
        width: 84,
        child: Text(
          L.of(context).fuelCountsTowardNext,
          textAlign: TextAlign.right,
          style: AppText.caption.copyWith(color: c.textMuted),
        ),
      );
    }

    final w = window;
    if (w == null) {
      // The first full tank on record has nothing to measure against.
      return SizedBox(
        width: 84,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              Fmt.dash,
              style: AppText.numeralMd.copyWith(color: c.textMuted),
            ),
            Text(
              fmt.economyLabel,
              style: AppText.unit.copyWith(color: c.textMuted),
            ),
          ],
        ),
      );
    }

    final value = w.economy(fmt.distanceUnit, fmt.volumeUnit);
    final colour = w.isReliable ? c.signal : c.textMuted;

    return SizedBox(
      width: 84,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            fmt.economyOf(value),
            style: AppText.numeralMd.copyWith(color: colour),
          ),
          Text(
            fmt.economyLabel,
            style: AppText.unit.copyWith(color: c.textMuted),
          ),
          if (!w.isReliable)
            Text(
              L.of(context).fuelUnreliable,
              style: AppText.caption.copyWith(color: c.overdue),
            ),
        ],
      ),
    );
  }
}
