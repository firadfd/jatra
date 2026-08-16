import 'package:flutter/material.dart';
import 'package:get/get.dart' hide Value;

import '../../../app/routes/app_routes.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_dimens.dart';
import '../../../app/theme/app_text.dart';
import '../../../app/theme/app_theme.dart';
import '../../vehicles/vehicle_controller.dart';
import '../../../l10n/app_localizations.dart';

/// App-bar vehicle switcher.
///
/// With one bike it is just the name — no affordance suggesting a choice
/// that does not exist. With several it opens a menu; the colour tag is what
/// people actually recognise at a glance, so it leads.
class VehicleSwitcher extends StatelessWidget {
  const VehicleSwitcher({super.key});

  @override
  Widget build(BuildContext context) {
    final c = context.jatra;
    final vehicles = Get.find<VehicleController>();

    return Obx(() {
      final active = vehicles.active.value;
      if (active == null) return const SizedBox.shrink();

      final tag = Palette.vehicleTag(active.colorTag);
      final multiple = vehicles.vehicles.length > 1;

      final label = Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(color: tag, shape: BoxShape.circle),
          ),
          const SizedBox(width: Gap.sm),
          Flexible(
            child: Text(
              active.name,
              style: AppText.titleLg.copyWith(color: c.textPrimary),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (multiple) ...[
            const SizedBox(width: Gap.xs),
            Icon(Icons.expand_more, size: 20, color: c.textMuted),
          ],
        ],
      );

      if (!multiple) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: Gap.sm),
          child: label,
        );
      }

      return PopupMenuButton<int>(
        tooltip: L.of(context).vehiclesSwitch,
        position: PopupMenuPosition.under,
        onSelected: (id) {
          if (id == -1) {
            Get.toNamed(Routes.vehicles);
          } else {
            vehicles.setActive(id);
          }
        },
        itemBuilder: (context) => [
          for (final v in vehicles.vehicles)
            PopupMenuItem(
              value: v.id,
              child: Row(
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: Palette.vehicleTag(v.colorTag),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: Gap.sm),
                  Expanded(child: Text(v.name)),
                  if (v.id == active.id)
                    Icon(Icons.check, size: 18, color: c.signal),
                ],
              ),
            ),
          const PopupMenuDivider(),
          PopupMenuItem(value: -1, child: Text(L.of(context).vehiclesManage)),
        ],
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: Gap.sm),
          child: label,
        ),
      );
    });
  }
}
