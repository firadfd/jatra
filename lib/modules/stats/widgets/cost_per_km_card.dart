import 'package:flutter/material.dart';
import 'package:get/get.dart' hide Value;

import '../../../app/theme/app_dimens.dart';
import '../../../app/theme/app_text.dart';
import '../../../app/theme/app_theme.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/jatra_widgets.dart';
import '../../../l10n/app_localizations.dart';
import '../../vehicles/vehicle_controller.dart';
import '../stats_controller.dart';

/// The three cost-per-distance figures, labelled clearly, because they answer
/// three different questions and conflating them is how people convince
/// themselves a motorcycle is nearly free to run.
class CostPerKmCard extends GetView<StatsController> {
  const CostPerKmCard({super.key});

  @override
  Widget build(BuildContext context) {
    final c = context.jatra;
    final vehicles = Get.find<VehicleController>();

    return Obx(() {
      final fmt = vehicles.fmt.value;
      final report = controller.report.value;
      final unit = fmt.distanceUnit;

      if (!report.hasDistance) {
        return JatraCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SectionLabel(L.of(context).statsCostPerDistance),
              const SizedBox(height: Gap.sm),
              Text(
                report.observationCount < 2
                    ? L
                          .of(context)
                          .statsNeedTwoReadings(fmt.distanceLabel.toLowerCase())
                    : L.of(context).statsNoDistanceMeasured,
                style: AppText.bodySm.copyWith(color: c.textMuted),
              ),
            ],
          ),
        );
      }

      return JatraCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SectionLabel(
              L.of(context).statsCostPer(fmt.distanceLabel.toLowerCase()),
              trailing: Text(
                '${fmt.distance(report.distanceM)} '
                '${fmt.distanceLabel.toLowerCase()}',
                style: AppText.caption.copyWith(color: c.textMuted),
              ),
            ),
            const SizedBox(height: Gap.md),
            _Figure(
              label: L.of(context).statsFuel,
              explanation: L.of(context).statsFuelExplain,
              value: report.fuelPerDistance(unit),
              total: fmt.amount(report.fuelCost),
              colour: c.chartSeries[0],
              fmt: fmt,
            ),
            Divider(color: c.border, height: Gap.lg),
            _Figure(
              label: L.of(context).statsRunning,
              explanation: L.of(context).statsRunningExplain,
              value: report.runningPerDistance(unit),
              total: fmt.amount(report.runningCost),
              colour: c.chartSeries[1],
              fmt: fmt,
            ),
            Divider(color: c.border, height: Gap.lg),
            _Figure(
              label: L.of(context).statsTrue,
              explanation: L.of(context).statsTrueExplain,
              value: report.truePerDistance(unit),
              total: fmt.amount(report.trueCost),
              colour: c.chartSeries[2],
              fmt: fmt,
              // Depreciation is a straight-line model over a user-supplied
              // estimate. It is never presented as a measurement.
              isEstimate: true,
              unavailableMessage: report.hasDepreciation
                  ? null
                  : L.of(context).statsAddPurchasePrice,
            ),
          ],
        ),
      );
    });
  }
}

class _Figure extends StatelessWidget {
  const _Figure({
    required this.label,
    required this.explanation,
    required this.value,
    required this.total,
    required this.colour,
    required this.fmt,
    this.isEstimate = false,
    this.unavailableMessage,
  });

  final String label;
  final String explanation;
  final double? value;
  final String total;
  final Color colour;
  final Fmt fmt;
  final bool isEstimate;
  final String? unavailableMessage;

  @override
  Widget build(BuildContext context) {
    final c = context.jatra;
    final missing = unavailableMessage;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // A colour swatch that matches the stacked-spend chart, so the two
        // read as the same three categories.
        Container(
          width: 4,
          height: 36,
          margin: const EdgeInsets.only(top: 2, right: Gap.md),
          decoration: BoxDecoration(
            color: colour,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    label,
                    style: AppText.titleMd.copyWith(color: c.textPrimary),
                  ),
                  if (isEstimate) ...[
                    const SizedBox(width: Gap.sm),
                    StatusPill(
                      text: L.of(context).statsEstimate,
                      color: c.textMuted,
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 2),
              Text(
                missing ?? explanation,
                style: AppText.caption.copyWith(color: c.textMuted),
              ),
            ],
          ),
        ),
        const SizedBox(width: Gap.sm),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            StatValue(
              value: value == null ? Fmt.dash : fmt.rate(value!),
              unit: fmt.perDistanceLabel,
              style: AppText.numeralMd,
              color: value == null ? c.textMuted : c.textPrimary,
            ),
            if (value != null)
              Text(total, style: AppText.caption.copyWith(color: c.textMuted)),
          ],
        ),
      ],
    );
  }
}
