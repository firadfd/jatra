import 'package:flutter/material.dart';
import 'package:get/get.dart' hide Value;

import '../../app/routes/app_routes.dart';
import '../../app/theme/app_dimens.dart';
import '../../app/theme/app_text.dart';
import '../../app/theme/app_theme.dart';
import '../../core/utils/formatters.dart';
import '../../core/utils/money.dart';
import '../../core/widgets/jatra_widgets.dart';
import '../../l10n/app_localizations.dart';
import '../../data/db/database.dart';
import '../../services/notification_service.dart';
import '../../services/settings_service.dart';
import '../vehicles/vehicle_controller.dart';
import 'service_controller.dart';
import 'widgets/service_item_tile.dart';

/// The service screen: what needs doing, sorted by urgency, with the history
/// underneath.
class ServiceView extends GetView<ServiceController> {
  const ServiceView({super.key});

  @override
  Widget build(BuildContext context) {
    final vehicles = Get.find<VehicleController>();

    return Scaffold(
      appBar: AppBar(
        title: Text(L.of(context).serviceTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: L.of(context).serviceAddItem,
            onPressed: () => Get.toNamed(Routes.serviceItemForm),
          ),
        ],
      ),
      body: Obx(() {
        if (!controller.isReady.value) {
          return const Center(child: CircularProgressIndicator());
        }
        if (controller.plan.isEmpty) {
          return EmptyState(
            icon: Icons.build_outlined,
            title: L.of(context).serviceNoItemsTitle,
            message: L.of(context).serviceNoItemsBody,
            actionLabel: L.of(context).serviceAddItem,
            onAction: () => Get.toNamed(Routes.serviceItemForm),
          );
        }

        final fmt = vehicles.fmt.value;

        return RefreshIndicator(
          onRefresh: controller.refreshPlan,
          child: ContentColumn(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(Gap.md, Gap.md, Gap.md, 96),
              children: [
                const _ReminderPrompt(),
                SectionLabel(
                  L.of(context).serviceDue,
                  trailing: Text(
                    controller.needingAttention == 0
                        ? L.of(context).serviceNothingPending
                        : L
                              .of(context)
                              .serviceNeedAttention(
                                controller.needingAttention,
                              ),
                    style: AppText.caption.copyWith(
                      color: context.jatra.textMuted,
                    ),
                  ),
                ),
                const SizedBox(height: Gap.sm),
                for (final due in controller.plan) ...[
                  ServiceItemTile(
                    due: due,
                    fmt: fmt,
                    onLog: () => Get.toNamed(
                      Routes.serviceLogForm,
                      arguments: {RouteArgs.serviceItemId: due.item.id},
                    ),
                    onEdit: () => Get.toNamed(
                      Routes.serviceItemForm,
                      arguments: {RouteArgs.editId: due.item.id},
                    ),
                  ),
                  const SizedBox(height: Gap.sm),
                ],
                const SizedBox(height: Gap.lg),
                const _ServiceHistory(),
              ],
            ),
          ),
        );
      }),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'fab-service',
        onPressed: () => Get.toNamed(Routes.serviceLogForm),
        icon: const Icon(Icons.build),
        label: Text(L.of(context).serviceLogAction),
      ),
    );
  }
}

/// Offered here rather than requested at launch: the permission is asked for
/// at the moment the rider says they want the feature, with the reason in
/// front of them.
class _ReminderPrompt extends StatelessWidget {
  const _ReminderPrompt();

  @override
  Widget build(BuildContext context) {
    final c = context.jatra;
    final notifications = Get.find<NotificationService>();
    final settings = Get.find<SettingsService>();

    return Obx(() {
      final on =
          settings.notificationsEnabled.value &&
          notifications.isAuthorised.value;
      if (on) return const SizedBox.shrink();

      return Padding(
        padding: const EdgeInsets.only(bottom: Gap.md),
        child: JatraCard(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.notifications_none, size: 20, color: c.signal),
              const SizedBox(width: Gap.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Get told when a service is due',
                      style: AppText.titleMd.copyWith(color: c.textPrimary),
                    ),
                    const SizedBox(height: Gap.xs),
                    Text(
                      'Jatra will post a reminder on this phone. Nothing is '
                      'sent anywhere — the reminder is worked out here, from '
                      'your own log.',
                      style: AppText.bodySm.copyWith(color: c.textMuted),
                    ),
                    const SizedBox(height: Gap.sm),
                    FilledButton(
                      onPressed: () async {
                        final granted = await notifications.requestPermission();
                        settings.notificationsEnabled.value = granted;
                        if (granted) {
                          await Get.find<ServiceController>().refreshPlan();
                        }
                      },
                      child: Text(L.of(context).serviceRemindersEnable),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}

class _ServiceHistory extends GetView<ServiceController> {
  const _ServiceHistory();

  @override
  Widget build(BuildContext context) {
    final c = context.jatra;
    final vehicles = Get.find<VehicleController>();

    return Obx(() {
      final logs = controller.logs;
      final fmt = vehicles.fmt.value;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionLabel(
            L.of(context).serviceHistory,
            trailing: logs.isEmpty
                ? null
                : Text(
                    L.of(context).serviceLoggedCount(logs.length),
                    style: AppText.caption.copyWith(color: c.textMuted),
                  ),
          ),
          const SizedBox(height: Gap.sm),
          if (logs.isEmpty)
            JatraCard(
              child: Text(
                L.of(context).serviceNothingLogged,
                style: AppText.bodySm.copyWith(color: c.textMuted),
              ),
            )
          else
            for (final log in logs) ...[
              _ServiceLogTile(log: log, fmt: fmt),
              const SizedBox(height: Gap.sm),
            ],
        ],
      );
    });
  }
}

class _ServiceLogTile extends GetView<ServiceController> {
  const _ServiceLogTile({required this.log, required this.fmt});

  final ServiceLogRow log;
  final Fmt fmt;

  @override
  Widget build(BuildContext context) {
    final c = context.jatra;

    return Dismissible(
      key: ValueKey('service-log-${log.id}'),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: Gap.lg),
        decoration: BoxDecoration(
          color: c.danger.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(Radii.card),
          border: Border.all(color: c.danger, width: Dimens.border),
        ),
        child: Icon(Icons.delete_outline, color: c.danger),
      ),
      onDismissed: (_) => controller.deleteLog(log.id),
      child: JatraCard(
        onTap: () => Get.toNamed(
          Routes.serviceLogForm,
          arguments: {RouteArgs.editId: log.id},
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: Gap.md,
          vertical: Gap.sm,
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    log.name,
                    style: AppText.titleMd.copyWith(color: c.textPrimary),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    [
                      fmt.date(log.dateMs),
                      '${fmt.distance(log.odometerM)} '
                          '${fmt.distanceLabel.toLowerCase()}',
                      if (log.workshop != null) log.workshop!,
                    ].join(' · '),
                    style: AppText.bodySm.copyWith(color: c.textMuted),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: Gap.sm),
            Text(
              fmt.amount(Money(log.totalCostMinor)),
              style: AppText.numeralMd.copyWith(color: c.textPrimary),
            ),
          ],
        ),
      ),
    );
  }
}
