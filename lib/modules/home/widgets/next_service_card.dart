import 'package:flutter/material.dart';
import 'package:get/get.dart' hide Value;

import '../../../app/routes/app_routes.dart';
import '../../../app/theme/app_dimens.dart';
import '../../../app/theme/app_text.dart';
import '../../../app/theme/app_theme.dart';
import '../../../core/calc/service_predictor.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/jatra_widgets.dart';
import '../../../data/models/enums.dart';
import '../../service/service_controller.dart';
import '../../service/widgets/service_item_tile.dart';
import '../../vehicles/vehicle_controller.dart';
import '../../../core/utils/enum_labels.dart';
import '../../../l10n/app_localizations.dart';

/// What needs doing next, on the home screen.
///
/// Shows the single most urgent item rather than a list — home answers "is
/// anything wrong?", and the service screen answers "what exactly?".
class NextServiceCard extends StatelessWidget {
  const NextServiceCard({super.key});

  @override
  Widget build(BuildContext context) {
    final c = context.jatra;
    final service = Get.find<ServiceController>();
    final vehicles = Get.find<VehicleController>();

    return Obx(() {
      final fmt = vehicles.fmt.value;
      final urgent = service.mostUrgent;
      final others = service.needingAttention - (urgent == null ? 0 : 1);

      if (urgent == null) {
        return JatraCard(
          onTap: () => Get.toNamed(Routes.service),
          child: Row(
            children: [
              Icon(Icons.check_circle_outline, size: 20, color: c.ok),
              const SizedBox(width: Gap.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Nothing due',
                      style: AppText.titleMd.copyWith(color: c.textPrimary),
                    ),
                    Text(
                      service.plan.isEmpty
                          ? 'No service items set up yet.'
                          : 'All ${service.plan.length} items are in the '
                                'clear.',
                      style: AppText.bodySm.copyWith(color: c.textMuted),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: c.textMuted),
            ],
          ),
        );
      }

      final colour = statusColour(context, urgent.status);

      return JatraCard(
        onTap: () => Get.toNamed(Routes.service),
        accent: urgent.isPastDue ? colour : null,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(serviceIcon(urgent.item.iconKey), size: 20, color: colour),
                const SizedBox(width: Gap.sm),
                Expanded(
                  child: Text(
                    urgent.item.name,
                    style: AppText.titleMd.copyWith(color: c.textPrimary),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                StatusPill(
                  text: urgent.status.labelOf(L.of(context)),
                  color: colour,
                ),
              ],
            ),
            const SizedBox(height: Gap.sm),
            if (urgent.status != ServiceStatus.unknown)
              ProgressRule(fraction: urgent.usedFraction, color: colour),
            const SizedBox(height: Gap.sm),
            Row(
              children: [
                Expanded(
                  child: Text(
                    _detail(L.of(context), urgent, fmt),
                    style: AppText.bodySm.copyWith(color: c.textMuted),
                  ),
                ),
                if (others > 0)
                  Text(
                    L.of(context).homeMoreCount(others),
                    style: AppText.caption.copyWith(color: c.textMuted),
                  ),
              ],
            ),
          ],
        ),
      );
    });
  }

  String _detail(L l, ServiceDue due, Fmt fmt) {
    final remainingM = due.remainingM;
    if (remainingM == null) {
      final dueDateMs = due.dueDateMs;
      return dueDateMs == null
          ? l.homeTapForDetails
          : l.serviceDueOn(relativeDayOf(l, dueDateMs));
    }
    final unit = fmt.distanceLabel.toLowerCase();
    return remainingM >= 0
        ? l.serviceToGo(fmt.distance(remainingM), unit)
        : l.serviceOver(fmt.distance(-remainingM), unit);
  }
}
