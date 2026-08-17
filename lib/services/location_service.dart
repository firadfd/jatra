import 'dart:async';
import 'dart:io';

import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart' hide Value;

import '../app/theme/app_colors.dart';
import '../core/utils/geo_utils.dart';
import '../core/utils/l10n.dart';

/// Where a permission request ended up.
enum LocationPermissionState {
  /// Never asked, or asked and dismissed without an answer.
  notRequested,

  /// Foreground only. Enough for "while app is open".
  whileInUse,

  /// Background granted. Required for recording with the screen off.
  always,

  /// Refused, but can be asked again.
  denied,

  /// Refused permanently, or blocked by policy. Only Settings can undo this.
  deniedForever,

  /// Location is switched off device-wide.
  servicesDisabled;

  bool get allowsForeground =>
      this == LocationPermissionState.whileInUse ||
      this == LocationPermissionState.always;

  bool get allowsBackground => this == LocationPermissionState.always;

  /// True when nothing the app can do will change the answer — the user has
  /// to go to Settings.
  bool get needsSettings => this == LocationPermissionState.deniedForever;
}

/// GPS access and the permission dance around it.
///
/// Nothing in this class runs at launch. It is constructed lazily, and the
/// first thing that touches the platform is a request the user explicitly
/// triggered by switching tracking on.
class LocationService extends GetxService {
  /// Current known permission state, kept for the settings screen to react
  /// to without re-querying on every rebuild.
  final permission = LocationPermissionState.notRequested.obs;

  /// The stream configuration for a tracking mode.
  ///
  /// The critical detail is [ForegroundNotificationConfig]: supplying it
  /// starts an Android foreground service, and passing `null` means no
  /// service and no notification at all. A recording ride always passes one —
  /// it is the only thing that keeps location flowing once the app is no
  /// longer on screen. The "you are here" dot on the map passes null, because
  /// looking at a map is not a reason to hold a service open.
  static LocationSettings buildSettings({required bool backgroundEnabled}) {
    if (!Platform.isAndroid) {
      return const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10,
      );
    }

    return AndroidSettings(
      accuracy: LocationAccuracy.high,
      // A 10 m filter at the platform level, on top of the app's own 5 m
      // jitter rule. The platform one saves battery; the app's one is what
      // keeps distances honest.
      distanceFilter: 10,
      // Without an interval the platform is free to batch samples up and
      // deliver them in a clump once the device wakes, which makes the live
      // readout and the map dot lurch. Paired with the distance filter above
      // this is "at most every 2 s, and only if you have actually moved".
      intervalDuration: const Duration(seconds: 2),
      foregroundNotificationConfig: backgroundEnabled
          ? ForegroundNotificationConfig(
              // This is the plumbing notification, not the ride one.
              //
              // geolocator hardcodes IMPORTANCE_NONE on its channel and
              // recreates it on every service start, so it cannot be given a
              // sound or a status-bar icon from here — Android only lets an
              // app lower an existing channel's importance. Android still
              // forces it into the shade, collapsed under "Silent", which is
              // why `NotificationService.showRideProgress` posts the visible
              // one. The copy here is about *why the service is running*, so
              // the two entries never read as the same notification twice.
              notificationTitle: l10n.ridesLocationServiceTitle,
              notificationText: l10n.ridesForegroundNotification,
              // Named, so the system notification settings show "Ride
              // recording" rather than geolocator's generic "Background
              // Location" default. That row is where a user goes to silence
              // it, and it should be obvious which app feature it belongs to.
              notificationChannelName: l10n.ridesNotificationChannel,
              // The one warm accent the app answers to. A notification with no
              // colour reads as the system's, not as Jatra's.
              color: Palette.signal,
              // Holds the CPU awake between fixes. Without it the system
              // sleeps and the samples arrive in a batch at the next wake,
              // which is exactly the "it only worked in the foreground"
              // symptom.
              enableWakeLock: true,
              // Not dismissible. A swiped-away notification is a killed
              // service, and a killed service mid-ride loses the rest of the
              // ride — the user ends a ride with Finish, not with a swipe.
              setOngoing: true,
            )
          : null,
    );
  }

  /// Reads the current state without prompting.
  Future<LocationPermissionState> check() async {
    if (!await Geolocator.isLocationServiceEnabled()) {
      return permission.value = LocationPermissionState.servicesDisabled;
    }
    return permission.value = _map(await Geolocator.checkPermission());
  }

  /// Requests foreground location.
  ///
  /// Called at the moment the user flips the tracking toggle, never before,
  /// and never at launch.
  Future<LocationPermissionState> requestForeground() async {
    if (!await Geolocator.isLocationServiceEnabled()) {
      return permission.value = LocationPermissionState.servicesDisabled;
    }

    var current = await Geolocator.checkPermission();
    if (current == LocationPermission.denied) {
      current = await Geolocator.requestPermission();
    }
    return permission.value = _map(current);
  }

  /// Requests background ("Allow all the time") location.
  ///
  /// On Android 11+ this **cannot** be granted from the standard dialog —
  /// the system only offers "While using the app". The second request
  /// returns `whileInUse` rather than `always`, and the only route to
  /// `always` is the app's settings page.
  ///
  /// So: ask once, and if the answer is not `always`, hand back the state
  /// and let the UI show an explainer with a button to [openAppSettings].
  /// Never loop the dialog — repeated prompts are how an app gets its
  /// permission permanently denied.
  Future<LocationPermissionState> requestBackground() async {
    final foreground = await requestForeground();
    if (!foreground.allowsForeground) return foreground;

    final result = await Geolocator.requestPermission();
    return permission.value = _map(result);
  }

  /// Opens the app's settings page, for the Android 11+ background case and
  /// for a permanent denial. The caller re-checks on resume.
  Future<bool> openAppSettings() => Geolocator.openAppSettings();

  /// Opens the device location settings, for when GPS is off entirely.
  Future<bool> openLocationSettings() => Geolocator.openLocationSettings();

  /// The position stream for a ride being recorded, already mapped to the
  /// app's own [GeoPoint].
  ///
  /// Always starts the Android foreground service, so the stream survives the
  /// app being backgrounded, the screen locking and another app coming to the
  /// front. It stops when the subscription is cancelled, which the tracker
  /// does on Finish and nowhere else.
  ///
  /// Unfiltered — quality rules live in [GpsFilter] and are applied by the
  /// tracker, so they stay testable without a GPS.
  Stream<GeoPoint> watchRide() {
    return Geolocator.getPositionStream(
      locationSettings: buildSettings(backgroundEnabled: true),
    ).map(toGeoPoint);
  }

  /// A foreground position stream that does not depend on the tracking mode.
  ///
  /// [watch] returns an empty stream when tracking is Off, which is correct
  /// for ride recording — that switch governs whether rides are *recorded*.
  /// Showing a "you are here" dot is a different question, asked and answered
  /// per tap, and never writes a thing to the database.
  ///
  /// Always foreground-only: no [ForegroundNotificationConfig], so no service
  /// and no persistent notification. The caller is responsible for cancelling
  /// this the moment the map stops being looked at.
  Stream<GeoPoint> watchForeground() {
    return Geolocator.getPositionStream(
      locationSettings: buildSettings(backgroundEnabled: false),
    ).map(toGeoPoint);
  }

  /// A single fix, for stamping the start of a ride.
  Future<GeoPoint?> currentPosition() async {
    try {
      final position = await Geolocator.getCurrentPosition(
        locationSettings: buildSettings(backgroundEnabled: false),
      );
      return toGeoPoint(position);
    } on Object {
      // A timeout or a revoked permission mid-call. A ride can start
      // without an initial fix; the first stream sample will do.
      return null;
    }
  }

  static GeoPoint toGeoPoint(Position p) => GeoPoint(
    lat: p.latitude,
    lng: p.longitude,
    timestampMs: p.timestamp.millisecondsSinceEpoch,
    accuracy: p.accuracy,
    speed: p.speed,
    altitude: p.altitude,
  );

  static LocationPermissionState _map(LocationPermission p) => switch (p) {
    LocationPermission.always => LocationPermissionState.always,
    LocationPermission.whileInUse => LocationPermissionState.whileInUse,
    LocationPermission.denied => LocationPermissionState.denied,
    LocationPermission.deniedForever => LocationPermissionState.deniedForever,
    LocationPermission.unableToDetermine =>
      LocationPermissionState.notRequested,
  };
}
