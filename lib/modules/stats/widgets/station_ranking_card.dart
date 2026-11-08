import 'package:flutter/material.dart';
import 'package:get/get.dart' hide Value;

import '../../../app/theme/app_dimens.dart';
import '../../../app/theme/app_text.dart';
import '../../../app/theme/app_theme.dart';
import '../../../core/widgets/jatra_widgets.dart';
import '../../../l10n/app_localizations.dart';
import '../../vehicles/vehicle_controller.dart';
import '../stats_controller.dart';

/// Which pump's fuel has gone furthest on this bike.
class StationRankingCard extends GetView<StatsController> {
  const StationRankingCard({super.key});

  @override
  Widget build(BuildContext context) {
    final c = context.jatra;
    final l = L.of(context);
    final vehicles = Get.find<VehicleController>();

    return JatraCard(
      child: Obx(() {
        final fmt = vehicles.fmt.value;
        final stations = controller.stationRanking.toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SectionLabel(l.statsStationsTitle),
            const SizedBox(height: Gap.sm),
            if (stations.isEmpty)
              Text(
                l.statsStationsEmpty,
                style: AppText.bodySm.copyWith(color: c.textMuted),
              )
            else ...[
              for (final s in stations)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: Gap.xs),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              s.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppText.bodySm.copyWith(
                                color: c.textPrimary,
                              ),
                            ),
                            Text(
                              l.statsStationsTanks(s.windowCount),
                              style: AppText.caption.copyWith(
                                color: c.textMuted,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: Gap.md),
                      Text(
                        '${fmt.economy(s.distanceM, s.volumeMl)} '
                        '${fmt.economyLabel}',
                        style: AppText.bodySm.copyWith(color: c.textPrimary),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: Gap.sm),
              Text(
                l.statsStationsCaveat,
                style: AppText.caption.copyWith(color: c.textMuted),
              ),
            ],
          ],
        );
      }),
    );
  }
}
