import 'package:flutter/material.dart';
import 'package:get/get.dart' hide Value;

import '../../app/routes/app_routes.dart';
import '../../app/theme/app_dimens.dart';
import '../../app/theme/app_text.dart';
import '../../app/theme/app_theme.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/jatra_widgets.dart';
import '../../l10n/app_localizations.dart';
import '../../data/db/database.dart';
import '../../services/settings_service.dart';
import '../vehicles/vehicle_controller.dart';
import 'ride_tracker_controller.dart';
import 'rides_controller.dart';
import 'widgets/recording_bar.dart';

/// Recorded rides.
///
/// With tracking Off, the "Start ride" control is hidden entirely rather
/// than shown disabled — a button that cannot be pressed is worse than no
/// button, and the screen still has a job explaining what the feature is.
class RidesView extends GetView<RidesController> {
  const RidesView({super.key});

  @override
  Widget build(BuildContext context) {
    final tracker = Get.find<RideTrackerController>();
    final settings = Get.find<SettingsService>();

    return Scaffold(
      appBar: AppBar(title: Text(L.of(context).ridesTitle)),
      body: Column(
        children: [
          const RecordingBar(),
          Expanded(
            child: Obx(() {
              if (!controller.isReady.value) {
                return const Center(child: CircularProgressIndicator());
              }

              if (controller.rides.isEmpty) {
                return settings.trackingMode.value == TrackingMode.off
                    ? const _TrackingOffState()
                    : EmptyState(
                        icon: Icons.route_outlined,
                        title: L.of(context).ridesNoneTitle,
                        message: L.of(context).ridesNoneBody,
                      );
              }

              return const _RideList();
            }),
          ),
        ],
      ),
      floatingActionButton: Obx(() {
        if (!tracker.trackingEnabled || tracker.isRecording.value) {
          return const SizedBox.shrink();
        }
        return FloatingActionButton.extended(
          heroTag: 'fab-rides',
          onPressed: () => _startRide(context, tracker),
          icon: const Icon(Icons.play_arrow),
          label: Text(L.of(context).ridesStart),
        );
      }),
    );
  }

  Future<void> _startRide(
    BuildContext context,
    RideTrackerController tracker,
  ) async {
    final started = await tracker.start();
    if (started || !context.mounted) return;

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(L.of(context).rideCouldNotStart)));
  }
}

/// What the screen says when tracking is switched off — which is the
/// default, and a perfectly reasonable place to stay.
class _TrackingOffState extends StatelessWidget {
  const _TrackingOffState();

  @override
  Widget build(BuildContext context) {
    final c = context.jatra;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(Gap.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.location_off_outlined, size: 40, color: c.textMuted),
            const SizedBox(height: Gap.md),
            Text(
              L.of(context).ridesTrackingOffTitle,
              style: AppText.titleMd.copyWith(color: c.textPrimary),
            ),
            const SizedBox(height: Gap.sm),
            Text(
              L.of(context).ridesTrackingOffBody,
              style: AppText.bodySm.copyWith(color: c.textMuted),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: Gap.lg),
            FilledButton(
              onPressed: () => Get.toNamed(Routes.settings),
              child: Text(L.of(context).ridesSetUp),
            ),
          ],
        ),
      ),
    );
  }
}

class _RideList extends GetView<RidesController> {
  const _RideList();

  @override
  Widget build(BuildContext context) {
    final vehicles = Get.find<VehicleController>();

    return Obx(() {
      final fmt = vehicles.fmt.value;
      final groups = controller.monthGroups;

      return ContentColumn(
        child: ListView.builder(
          padding: const EdgeInsets.fromLTRB(Gap.md, Gap.md, Gap.md, 96),
          itemCount: groups.length,
          itemBuilder: (context, i) {
            final group = groups[i];
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (i > 0) const SizedBox(height: Gap.lg),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: Gap.xs),
                  child: Row(
                    children: [
                      Expanded(
                        child: SectionLabel(fmt.month(group.monthStartMs)),
                      ),
                      StatValue(
                        value: fmt.distance(group.distanceM),
                        unit: fmt.distanceLabel,
                        style: AppText.numeralMd,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: Gap.sm),
                for (final ride in group.rides) ...[
                  _RideTile(ride: ride, fmt: fmt),
                  const SizedBox(height: Gap.sm),
                ],
              ],
            );
          },
        ),
      );
    });
  }
}

class _RideTile extends GetView<RidesController> {
  const _RideTile({required this.ride, required this.fmt});

  final RideRow ride;
  final Fmt fmt;

  @override
  Widget build(BuildContext context) {
    final c = context.jatra;

    return Dismissible(
      key: ValueKey('ride-${ride.id}'),
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
      onDismissed: (_) => _deleteWithUndo(context),
      child: JatraCard(
        onTap: () => Get.toNamed(
          Routes.rideDetail,
          arguments: {RouteArgs.rideId: ride.id},
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
                    ride.title ?? fmt.dateTime(ride.startTimeMs),
                    style: AppText.titleMd.copyWith(color: c.textPrimary),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    [
                      fmt.duration(ride.totalSeconds),
                      '${fmt.speed(ride.avgSpeed)} '
                          '${fmt.speedLabel.toLowerCase()} avg',
                    ].join(' · '),
                    style: AppText.bodySm.copyWith(color: c.textMuted),
                  ),
                ],
              ),
            ),
            const SizedBox(width: Gap.sm),
            StatValue(
              value: fmt.distancePrecise(ride.distanceMeters),
              unit: fmt.distanceLabel,
              style: AppText.numeralMd,
              color: c.data,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _deleteWithUndo(BuildContext context) async {
    await controller.delete(ride.id);
    if (!context.mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            L.of(context).ridesDeletedSnack(fmt.dateShort(ride.startTimeMs)),
          ),
          action: SnackBarAction(
            label: L.of(context).actionUndo,
            onPressed: () => controller.undoDelete(ride.id),
          ),
          duration: const Duration(seconds: 6),
        ),
      );
  }
}
