import 'package:flutter/material.dart';

import '../../../app/theme/app_dimens.dart';
import '../../../app/theme/app_text.dart';
import '../../../app/theme/app_theme.dart';
import '../../../core/calc/service_predictor.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/utils/enum_labels.dart';
import '../../../core/widgets/jatra_widgets.dart';
import '../../../l10n/app_localizations.dart';
import '../../../data/models/enums.dart';

/// Maps a stable [ServiceItemRow.iconKey] to a glyph. Keyed rather than
/// stored as an icon code point so a rename never loses the icon and the
/// mapping can change without a migration.
IconData serviceIcon(String key) => switch (key) {
  'oil' => Icons.oil_barrel_outlined,
  'filter' => Icons.filter_alt_outlined,
  'air' => Icons.air,
  'chain' => Icons.link,
  'spark' => Icons.bolt_outlined,
  'brake' => Icons.disc_full_outlined,
  'fluid' => Icons.water_drop_outlined,
  'coolant' => Icons.ac_unit,
  'tyre' => Icons.trip_origin,
  'battery' => Icons.battery_charging_full_outlined,
  'valve' => Icons.settings_input_component_outlined,
  _ => Icons.build_outlined,
};

Color statusColour(BuildContext context, ServiceStatus status) {
  final c = context.jatra;
  return switch (status) {
    ServiceStatus.overdue => c.overdue,
    ServiceStatus.dueNow => c.overdue,
    ServiceStatus.dueSoon => c.dueSoon,
    ServiceStatus.ok => c.ok,
    ServiceStatus.unknown => c.textMuted,
  };
}

/// One service item, with a progress rule toward its next due point.
class ServiceItemTile extends StatelessWidget {
  const ServiceItemTile({
    super.key,
    required this.due,
    required this.fmt,
    this.onLog,
    this.onEdit,
  });

  final ServiceDue due;
  final Fmt fmt;
  final VoidCallback? onLog;
  final VoidCallback? onEdit;

  @override
  Widget build(BuildContext context) {
    final c = context.jatra;
    final colour = statusColour(context, due.status);
    final item = due.item;

    return JatraCard(
      onTap: onEdit,
      accent: due.isPastDue ? colour : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(serviceIcon(item.iconKey), size: 20, color: colour),
              const SizedBox(width: Gap.sm),
              Expanded(
                child: Text(
                  item.name,
                  style: AppText.titleMd.copyWith(color: c.textPrimary),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: Gap.sm),
              StatusPill(
                text: due.status.labelOf(L.of(context)),
                color: colour,
              ),
            ],
          ),
          const SizedBox(height: Gap.sm),

          if (due.status != ServiceStatus.unknown) ...[
            ProgressRule(fraction: due.usedFraction, color: colour),
            const SizedBox(height: Gap.sm),
          ],

          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Text(
                  _detail(L.of(context)),
                  style: AppText.bodySm.copyWith(color: c.textMuted),
                ),
              ),
              if (onLog != null)
                TextButton(
                  onPressed: onLog,
                  child: Text(L.of(context).serviceLogAction),
                ),
            ],
          ),
        ],
      ),
    );
  }

  /// The one line that tells the rider what they need to know. Distance
  /// first — it is the axis most motorcycle maintenance actually runs on —
  /// then the date, labelled as an estimate when it is projected.
  String _detail(L l) {
    if (due.status == ServiceStatus.unknown) {
      return l.serviceNoInterval;
    }

    final parts = <String>[];

    final remainingM = due.remainingM;
    if (remainingM != null) {
      final unit = fmt.distanceLabel.toLowerCase();
      parts.add(
        remainingM >= 0
            ? l.serviceToGo(fmt.distance(remainingM), unit)
            : l.serviceOver(fmt.distance(-remainingM), unit),
      );
    }

    final dueDateMs = due.dueDateMs;
    if (dueDateMs != null) {
      final when = relativeDayOf(l, dueDateMs);
      parts.add(due.dueDateIsEstimate ? l.dateRoughly(when) : when);
    }

    if (parts.isEmpty) {
      final pct = (due.usedFraction * 100).round();
      return l.serviceIntervalUsed(pct);
    }
    return parts.join(' · ');
  }
}
