import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart' hide Value;

import '../../../app/theme/app_dimens.dart';
import '../../../app/theme/app_text.dart';
import '../../../app/theme/app_theme.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/utils/units.dart';
import '../../../core/widgets/jatra_widgets.dart';
import '../../../l10n/app_localizations.dart';
import '../../vehicles/vehicle_controller.dart';
import '../stats_controller.dart';

/// Enter a distance, get what the trip costs.
///
/// Built for delivery riders deciding whether a job pays: the fuel figure is
/// what leaves your pocket today, the true figure is what the trip actually
/// takes off the bike once servicing and depreciation are counted.
class TripCalculator extends StatefulWidget {
  const TripCalculator({super.key});

  @override
  State<TripCalculator> createState() => _TripCalculatorState();
}

class _TripCalculatorState extends State<TripCalculator> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.jatra;
    final stats = Get.find<StatsController>();
    final vehicles = Get.find<VehicleController>();

    return JatraCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionLabel(L.of(context).statsTripTitle),
          const SizedBox(height: Gap.md),
          Obx(
            () => TextField(
              controller: _controller,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
              ],
              style: AppText.numeralMd.copyWith(color: c.textPrimary),
              decoration: InputDecoration(
                labelText: L.of(context).statsTripDistance,
                hintText: L.of(context).statsTripHint,
                suffixText: vehicles.fmt.value.distanceLabel,
              ),
              onChanged: (_) => setState(() {}),
            ),
          ),
          const SizedBox(height: Gap.md),
          Obx(() {
            final fmt = vehicles.fmt.value;
            final entered = double.tryParse(
              _controller.text.replaceAll(',', '').trim(),
            );

            if (entered == null || entered <= 0) {
              return Text(
                L.of(context).statsTripUsesRates,
                style: AppText.caption.copyWith(color: c.textMuted),
              );
            }

            final estimate = stats.estimateTrip(
              Units.toMetres(entered, fmt.distanceUnit),
            );

            if (estimate == null) {
              return Text(
                L.of(context).statsTripNotEnough,
                style: AppText.bodySm.copyWith(color: c.textMuted),
              );
            }

            return Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SectionLabel(L.of(context).statsFuel),
                      const SizedBox(height: Gap.xs),
                      StatValue(
                        value: fmt.amount(estimate.fuelCost),
                        style: AppText.numeralLg,
                        color: c.chartSeries[0],
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SectionLabel(L.of(context).statsTrueCost),
                      const SizedBox(height: Gap.xs),
                      StatValue(
                        value: estimate.trueCost == null
                            ? Fmt.dash
                            : fmt.amount(estimate.trueCost!),
                        style: AppText.numeralLg,
                        color: estimate.trueCost == null
                            ? c.textMuted
                            : c.chartSeries[2],
                      ),
                    ],
                  ),
                ),
              ],
            );
          }),
        ],
      ),
    );
  }
}
