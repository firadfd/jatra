import 'package:flutter/material.dart';
import 'package:get/get.dart' hide Value;

import '../../../app/routes/app_routes.dart';
import '../../../app/theme/app_dimens.dart';
import '../../../app/theme/app_text.dart';
import '../../../app/theme/app_theme.dart';
import '../../../core/widgets/jatra_widgets.dart';
import '../../vehicles/vehicle_controller.dart';
import '../ride_tracker_controller.dart';
import '../../../l10n/app_localizations.dart';

/// The live recording panel, shown at the top of the rides screen while a
/// ride is in progress and hidden entirely otherwise.
class RecordingBar extends StatelessWidget {
  const RecordingBar({super.key});

  @override
  Widget build(BuildContext context) {
    final tracker = Get.find<RideTrackerController>();

    return Obx(() {
      // An interrupted ride takes priority: it needs an answer before a new
      // one can start.
      if (tracker.interrupted.value != null) {
        return const _InterruptedRidePrompt();
      }
      if (!tracker.isRecording.value) return const SizedBox.shrink();
      return const _LiveStats();
    });
  }
}

class _LiveStats extends StatelessWidget {
  const _LiveStats();

  @override
  Widget build(BuildContext context) {
    final c = context.jatra;
    final tracker = Get.find<RideTrackerController>();
    final vehicles = Get.find<VehicleController>();

    return Padding(
      padding: const EdgeInsets.fromLTRB(Gap.md, Gap.md, Gap.md, 0),
      child: JatraCard(
        accent: c.data,
        child: Obx(() {
          final fmt = vehicles.fmt.value;
          final paused = tracker.isPaused.value;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _PulseDot(active: !paused),
                  const SizedBox(width: Gap.sm),
                  Expanded(
                    child: Text(
                      paused
                          ? L.of(context).ridesPaused
                          : L.of(context).ridesRecording,
                      style: AppText.titleMd.copyWith(color: c.textPrimary),
                    ),
                  ),
                  Text(
                    L.of(context).ridesPoints(tracker.pointCount.value),
                    style: AppText.caption.copyWith(color: c.textMuted),
                  ),
                ],
              ),
              const SizedBox(height: Gap.md),
              Row(
                children: [
                  Expanded(
                    child: _Metric(
                      label: L.of(context).statsDistance,
                      value: fmt.distancePrecise(tracker.distanceM.value),
                      unit: fmt.distanceLabel,
                      colour: c.data,
                    ),
                  ),
                  Expanded(
                    child: _Metric(
                      label: L.of(context).ridesMovingTime,
                      value: fmt.duration(tracker.movingSeconds.value),
                      unit: null,
                    ),
                  ),
                  Expanded(
                    child: _Metric(
                      label: L.of(context).ridesTotalTime,
                      value: fmt.duration(tracker.totalSeconds.value),
                      unit: null,
                    ),
                  ),
                ],
              ),

              // The gap notice, stated plainly rather than hidden.
              if (tracker.gapNotice != null) ...[
                const SizedBox(height: Gap.md),
                Container(
                  padding: const EdgeInsets.all(Gap.sm),
                  decoration: BoxDecoration(
                    color: c.dueSoon.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(Radii.button),
                  ),
                  child: Text(
                    tracker.gapNotice!,
                    style: AppText.caption.copyWith(color: c.textSecondary),
                  ),
                ),
              ],

              const SizedBox(height: Gap.md),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: paused ? tracker.unpause : tracker.pause,
                      icon: Icon(paused ? Icons.play_arrow : Icons.pause),
                      label: Text(
                        paused
                            ? L.of(context).ridesResume
                            : L.of(context).ridesPause,
                      ),
                    ),
                  ),
                  const SizedBox(width: Gap.sm),
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: () => _stop(context, tracker),
                      icon: const Icon(Icons.stop),
                      label: Text(L.of(context).ridesFinish),
                    ),
                  ),
                ],
              ),
            ],
          );
        }),
      ),
    );
  }

  Future<void> _stop(
    BuildContext context,
    RideTrackerController tracker,
  ) async {
    final saved = await tracker.stop();
    if (!context.mounted) return;

    if (saved == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(L.of(context).ridesDiscardedEmpty)),
      );
      return;
    }

    Get.toNamed(Routes.rideDetail, arguments: {RouteArgs.rideId: saved.id});
  }
}

class _Metric extends StatelessWidget {
  const _Metric({
    required this.label,
    required this.value,
    required this.unit,
    this.colour,
  });

  final String label;
  final String value;
  final String? unit;
  final Color? colour;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionLabel(label),
        const SizedBox(height: Gap.xs),
        StatValue(
          value: value,
          unit: unit,
          style: AppText.numeralMd,
          color: colour,
        ),
      ],
    );
  }
}

/// A slow pulse while recording, still while paused. Respects reduced
/// motion — a permanently animating dot is exactly the sort of thing that
/// setting exists to stop.
class _PulseDot extends StatefulWidget {
  const _PulseDot({required this.active});

  final bool active;

  @override
  State<_PulseDot> createState() => _PulseDotState();
}

class _PulseDotState extends State<_PulseDot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1200),
  );

  @override
  void initState() {
    super.initState();
    if (widget.active) _controller.repeat(reverse: true);
  }

  @override
  void didUpdateWidget(covariant _PulseDot old) {
    super.didUpdateWidget(old);
    if (widget.active == old.active) return;
    if (widget.active) {
      _controller.repeat(reverse: true);
    } else {
      _controller
        ..stop()
        ..value = 1;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.jatra;
    final colour = widget.active ? c.overdue : c.textMuted;

    final dot = Container(
      width: 10,
      height: 10,
      decoration: BoxDecoration(color: colour, shape: BoxShape.circle),
    );

    if (!widget.active || context.reduceMotion) return dot;

    return FadeTransition(
      opacity: Tween<double>(begin: 0.35, end: 1).animate(_controller),
      child: dot,
    );
  }
}

/// Resume / save / discard, offered when a ride was still recording the last
/// time the app closed.
class _InterruptedRidePrompt extends StatelessWidget {
  const _InterruptedRidePrompt();

  @override
  Widget build(BuildContext context) {
    final c = context.jatra;
    final tracker = Get.find<RideTrackerController>();
    final fmt = Get.find<VehicleController>().fmt.value;

    return Obx(() {
      final ride = tracker.interrupted.value;
      if (ride == null) return const SizedBox.shrink();

      return Padding(
        padding: const EdgeInsets.fromLTRB(Gap.md, Gap.md, Gap.md, 0),
        child: JatraCard(
          accent: c.dueSoon,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                L.of(context).ridesInterruptedTitle,
                style: AppText.titleMd.copyWith(color: c.textPrimary),
              ),
              const SizedBox(height: Gap.xs),
              Text(
                'Started ${fmt.dateTime(ride.startTimeMs)} · '
                '${fmt.distancePrecise(ride.distanceMeters)} '
                '${fmt.distanceLabel.toLowerCase()} recorded so far.',
                style: AppText.bodySm.copyWith(color: c.textMuted),
              ),
              const SizedBox(height: Gap.md),
              Wrap(
                spacing: Gap.sm,
                runSpacing: Gap.sm,
                children: [
                  FilledButton(
                    onPressed: () => tracker.resolveInterrupted(
                      InterruptedRideChoice.resume,
                    ),
                    child: Text(L.of(context).ridesResumeAction),
                  ),
                  OutlinedButton(
                    onPressed: () =>
                        tracker.resolveInterrupted(InterruptedRideChoice.save),
                    child: Text(L.of(context).ridesSaveWhatWeHave),
                  ),
                  TextButton(
                    onPressed: () => _confirmDiscard(context, tracker),
                    child: Text(L.of(context).ridesDiscard),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    });
  }

  Future<void> _confirmDiscard(
    BuildContext context,
    RideTrackerController tracker,
  ) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(L.of(context).ridesDiscardTitle),
        content: Text(L.of(context).ridesDiscardBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(L.of(context).serviceItemKeep),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: context.jatra.danger),
            child: Text(L.of(context).ridesDiscard),
          ),
        ],
      ),
    );
    if (ok ?? false) {
      await tracker.resolveInterrupted(InterruptedRideChoice.discard);
    }
  }
}
