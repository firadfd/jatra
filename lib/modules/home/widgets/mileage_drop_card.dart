import 'package:flutter/material.dart';

import '../../../app/theme/app_dimens.dart';
import '../../../app/theme/app_text.dart';
import '../../../app/theme/app_theme.dart';
import '../../../core/calc/mileage_calc.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/utils/units.dart';
import '../../../core/widgets/jatra_widgets.dart';
import '../../../l10n/app_localizations.dart';

/// Surfaced when the latest tank falls meaningfully below the usual.
///
/// Deliberately not alarming: it states the numbers, names the three cheapest
/// things to check, and stops. A rider who sees a red siren every time they
/// sit in traffic for a week will turn the feature off.
class MileageDropCard extends StatelessWidget {
  const MileageDropCard({super.key, required this.drop, required this.fmt});

  final MileageDrop drop;
  final Fmt fmt;

  @override
  Widget build(BuildContext context) {
    final c = context.jatra;

    // The engine works in km/L so the threshold means the same thing for
    // every rider; only the display converts.
    final latest = Units.economyFromKmPerLitre(
      drop.latest,
      fmt.distanceUnit,
      fmt.volumeUnit,
    );
    final baseline = Units.economyFromKmPerLitre(
      drop.baseline,
      fmt.distanceUnit,
      fmt.volumeUnit,
    );

    return JatraCard(
      accent: c.overdue,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.trending_down, size: 18, color: c.overdue),
              const SizedBox(width: Gap.sm),
              Expanded(
                child: Text(
                  L
                      .of(context)
                      .mileageDropTitle((drop.dropFraction * 100).round()),
                  style: AppText.titleMd.copyWith(color: c.textPrimary),
                ),
              ),
            ],
          ),
          const SizedBox(height: Gap.sm),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              StatValue(
                value: fmt.economyOf(latest),
                unit: fmt.economyLabel,
                style: AppText.numeralLg,
                color: c.overdue,
              ),
              const SizedBox(width: Gap.sm),
              Flexible(
                child: Text(
                  L.of(context).mileageDropVsUsual(fmt.economyOf(baseline)),
                  style: AppText.bodySm.copyWith(color: c.textMuted),
                ),
              ),
            ],
          ),
          const SizedBox(height: Gap.md),
          Text(
            L.of(context).mileageDropCauses2(MileageDrop.commonCauses),
            style: AppText.bodySm.copyWith(color: c.textSecondary),
          ),
        ],
      ),
    );
  }
}
