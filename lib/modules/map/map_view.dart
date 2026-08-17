import 'package:flutter/material.dart';
import 'package:get/get.dart' hide Value;
import 'package:latlong2/latlong.dart';

import '../../app/routes/app_routes.dart';
import '../../app/theme/app_dimens.dart';
import '../../app/theme/app_text.dart';
import '../../app/theme/app_theme.dart';
import '../../core/widgets/jatra_widgets.dart';
import '../../data/models/enums.dart';
import '../../services/location_service.dart';
import '../../services/settings_service.dart';
import '../rides/ride_tracker_controller.dart';
import '../rides/widgets/recording_bar.dart';
import '../rides/widgets/ride_map.dart';
import '../vehicles/vehicle_controller.dart';
import 'map_controller.dart';
import '../../l10n/app_localizations.dart';

/// The Map tab.
///
/// Shows one path: the ride being recorded if there is one, otherwise the most
/// recent finished ride. The map fills whatever height is left after the
/// recording panel, so this reads as a map screen rather than as a card with a
/// map in it.
///
/// The base map is drawn in every state, including with tracking Off and no
/// rides recorded — a browsable map and a "you are here" dot are both useful
/// on their own, and neither needs a ride to exist first. What is missing in
/// those states is said in one line above the map, not in place of it.
///
/// Location is requested only when the rider taps the locate button. Opening
/// this tab touches no GPS.
///
/// The one exception is a ride in progress: that already holds a granted
/// permission and a running position stream, so the dot switches itself on
/// and the camera follows the rider without a second ask. The map reads that
/// ride's fixes rather than opening a stream of its own.
class MapView extends GetView<MapController> {
  const MapView({super.key});

  @override
  Widget build(BuildContext context) {
    final tracker = Get.find<RideTrackerController>();
    final settings = Get.find<SettingsService>();

    return Scaffold(
      appBar: AppBar(
        title: Text(L.of(context).mapTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.route_outlined),
            tooltip: L.of(context).mapAllRides,
            onPressed: () => Get.toNamed(Routes.rides),
          ),
        ],
      ),
      body: Column(
        children: [
          // Carries the interrupted-ride prompt and the live pause/finish
          // controls. Hidden entirely when neither applies.
          const RecordingBar(),
          Expanded(
            child: Obx(() {
              if (!controller.isReady.value) {
                return const Center(child: CircularProgressIndicator());
              }
              // The map is drawn in every state, including "no rides yet".
              // A Map tab that shows no map until you switch on GPS and
              // finish a ride is a door with nothing behind it; the base
              // tiles are worth something on their own, and the explainer
              // rides along underneath rather than replacing them.
              return _MapPanel(
                trackingOff: settings.trackingMode.value == TrackingMode.off,
              );
            }),
          ),
        ],
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          const _MyLocationButton(),
          const SizedBox(height: Gap.sm),
          Obx(() {
            if (!tracker.trackingEnabled || tracker.isRecording.value) {
              return const SizedBox.shrink();
            }
            return FloatingActionButton.extended(
              heroTag: 'fab-map',
              onPressed: () => _startRide(context, tracker),
              icon: const Icon(Icons.play_arrow),
              label: Text(L.of(context).ridesStart),
            );
          }),
        ],
      ),
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

/// Turns the "you are here" dot on, and follows it once it is on.
///
/// The first tap is what triggers the permission request — Jatra asks for
/// location when the rider asks to be located, and at no other time. Tapping
/// it again while the dot is showing recentres and resumes following;
/// long-pressing turns the dot off altogether.
///
/// The icon carries the follow state, the way it does in every map app:
/// filled crosshair while the camera is chasing the rider, outline once they
/// have dragged the map somewhere else.
class _MyLocationButton extends GetView<MapController> {
  const _MyLocationButton();

  @override
  Widget build(BuildContext context) {
    final c = context.jatra;

    return Obx(() {
      final on = controller.showMyLocation.value;
      final following = controller.followMe.value;
      final busy = controller.locating.value;

      // FloatingActionButton has no long-press of its own, so the gesture is
      // added around it. Long-press is the way back out — it drops the dot and
      // the GPS subscription with it.
      return GestureDetector(
        onLongPress: on ? controller.disableMyLocation : null,
        child: FloatingActionButton.small(
          heroTag: 'fab-map-locate',
          backgroundColor: c.surfaceElevated,
          foregroundColor: on ? c.signal : c.textSecondary,
          tooltip: switch ((on, following)) {
            (true, true) => L.of(context).mapFollowing,
            (true, false) => L.of(context).mapRecentre,
            _ => L.of(context).mapShowMyLocation,
          },
          onPressed: busy ? null : () => _tap(context),
          child: busy
              ? SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: c.textSecondary,
                  ),
                )
              : Icon(switch ((on, following)) {
                  (true, true) => Icons.my_location,
                  (true, false) => Icons.location_searching,
                  _ => Icons.location_disabled_outlined,
                }),
        ),
      );
    });
  }

  Future<void> _tap(BuildContext context) async {
    if (controller.showMyLocation.value) {
      controller.recentreOnMe();
      return;
    }

    final state = await controller.enableMyLocation();
    if (!context.mounted) return;

    if (state.allowsForeground) {
      controller.recentreOnMe();
      return;
    }

    // A refusal is answered with the one action that can actually undo it,
    // which is a different place depending on why it failed.
    final location = Get.find<LocationService>();
    final l = L.of(context);
    final (message, label, action) = switch (state) {
      LocationPermissionState.servicesDisabled => (
        l.mapLocationServicesOff,
        l.mapTurnOn,
        location.openLocationSettings,
      ),
      LocationPermissionState.deniedForever => (
        l.mapLocationBlocked,
        l.mapOpenSettings,
        location.openAppSettings,
      ),
      _ => (l.mapLocationNeeded, null, null),
    };

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          action: label == null || action == null
              ? null
              : SnackBarAction(label: label, onPressed: () => action()),
        ),
      );
  }
}

/// The map itself, plus a caption saying which ride is on screen.
class _MapPanel extends GetView<MapController> {
  const _MapPanel({required this.trackingOff});

  final bool trackingOff;

  /// Where the map opens before any ride has been recorded.
  ///
  /// Jatra is built for Bangladesh — prices are in ৳, Bangla is a shipped
  /// locale — so Dhaka is the least surprising place to land. It is only a
  /// starting view: the map is draggable, and the moment a ride exists the
  /// camera fits that instead. Deriving this from the device's location would
  /// mean asking for a location permission the user has explicitly not
  /// granted, which is not a trade worth making for a default camera.
  static const _defaultCentre = LatLng(23.8103, 90.4125);

  @override
  Widget build(BuildContext context) {
    final c = context.jatra;
    final vehicles = Get.find<VehicleController>();

    return Padding(
      // The buttons float over the bottom-right of the map, as they do in
      // every map app. That corner is deliberately empty in `RideMap` — the
      // attribution sits bottom-left precisely so this can happen.
      padding: const EdgeInsets.all(Gap.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Obx(() {
            final ride = controller.ride.value;
            // No ride to caption yet — say what would put one here, above the
            // map rather than in place of it.
            if (ride == null) return _MapHint(trackingOff: trackingOff);

            final fmt = vehicles.fmt.value;
            final live = controller.isLive;

            return Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          if (live) ...[
                            StatusPill(text: 'LIVE', color: c.overdue),
                            const SizedBox(width: Gap.sm),
                          ],
                          Flexible(
                            child: Text(
                              ride.title ?? fmt.dateTime(ride.startTimeMs),
                              style: AppText.titleMd.copyWith(
                                color: c.textPrimary,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${fmt.distancePrecise(ride.distanceMeters)} '
                        '${fmt.distanceLabel.toLowerCase()} · '
                        '${controller.points.length} points',
                        style: AppText.bodySm.copyWith(color: c.textMuted),
                      ),
                    ],
                  ),
                ),
                // A live ride is finished from the recording panel above, so
                // sending the user to its detail screen mid-ride would only
                // get in the way.
                if (!live)
                  TextButton(
                    onPressed: () => Get.toNamed(
                      Routes.rideDetail,
                      arguments: {RouteArgs.rideId: ride.id},
                    ),
                    child: Text(L.of(context).mapDetails),
                  ),
              ],
            );
          }),
          const SizedBox(height: Gap.md),
          Expanded(
            // RideMap sizes itself from an explicit height, so the remaining
            // space is measured and handed to it rather than guessed.
            //
            // The Obx sits *outside* the LayoutBuilder deliberately. A
            // LayoutBuilder runs its builder during layout, so an Obx inside
            // one calls setState mid-layout the first time a point lands —
            // which is the `!_debugDoingThisLayout` assertion. Reading the
            // observables here keeps the rebuild in the build phase where it
            // belongs, and hands the builder plain values.
            child: Obx(() {
              final points = controller.points.toList();
              final fmt = vehicles.fmt.value;
              final me = controller.myLocation.value;

              return LayoutBuilder(
                builder: (context, constraints) => RideMap(
                  points: points,
                  fmt: fmt,
                  height: constraints.maxHeight,
                  fallbackCentre: _defaultCentre,
                  myLocation: me,
                  mapController: controller.camera,
                  onUserMovedMap: controller.breakFollow,
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

/// The one-line caption under the map when there is no ride to describe.
///
/// Replaces the two full-screen empty states this tab used to have. Those
/// answered "why is there no path?" by removing the map, which also removed
/// the only part of the screen that worked without GPS.
class _MapHint extends StatelessWidget {
  const _MapHint({required this.trackingOff});

  final bool trackingOff;

  @override
  Widget build(BuildContext context) {
    final c = context.jatra;

    return Row(
      children: [
        Icon(
          trackingOff ? Icons.location_off_outlined : Icons.route_outlined,
          size: 18,
          color: c.textMuted,
        ),
        const SizedBox(width: Gap.sm),
        Expanded(
          child: Text(
            trackingOff
                ? 'Ride tracking is off. Nothing is recorded until you turn '
                      'it on.'
                : 'No rides yet — start one and the path is drawn here as you '
                      'go.',
            style: AppText.bodySm.copyWith(color: c.textMuted),
          ),
        ),
        if (trackingOff)
          TextButton(
            onPressed: () => Get.toNamed(Routes.settings),
            child: Text(L.of(context).mapSetUp),
          ),
      ],
    );
  }
}
