import 'dart:async';

import 'package:drift/drift.dart' show Value;
import 'package:flutter/widgets.dart';
import 'package:get/get.dart' hide Value;
import 'package:wakelock_plus/wakelock_plus.dart';

import '../../core/utils/clock.dart';
import '../../core/utils/geo_utils.dart';
import '../../data/db/database.dart';
import '../../data/repositories/fuel_repo.dart';
import '../../data/repositories/ride_repo.dart';
import '../../services/location_service.dart';
import '../../services/settings_service.dart';
import '../vehicles/vehicle_controller.dart';

/// What to do about a ride that was still recording when the app died.
enum InterruptedRideChoice { resume, save, discard }

/// Records a ride.
///
/// Two rules shape everything here:
///
/// 1. **Every accepted point is written to the database immediately.** The
///    path is never held in memory alone, so killing the app mid-ride costs
///    at most the last sample.
/// 2. **Gaps are shown, not smoothed over.** When recording stops and
///    resumes, the next point is flagged so the polyline breaks rather than
///    drawing a straight line across a stretch that was never ridden.
class RideTrackerController extends GetxController with WidgetsBindingObserver {
  RideTrackerController(
    this._rides,
    this._fuel,
    this._location,
    this._vehicles,
    this._settings,
  );

  final RideRepo _rides;
  final FuelRepo _fuel;
  final LocationService _location;
  final VehicleController _vehicles;
  final SettingsService _settings;

  StreamSubscription<GeoPoint>? _positionSub;

  /// The ride being recorded, or null when idle.
  final activeRide = Rxn<RideRow>();

  final isRecording = false.obs;
  final isPaused = false.obs;

  /// Live totals, mirrored from the database write so the UI can update
  /// without re-querying on every sample.
  final distanceM = 0.obs;
  final movingSeconds = 0.obs;
  final totalSeconds = 0.obs;
  final maxSpeedMps = 0.0.obs;
  final pointCount = 0.obs;

  /// Set when the app was backgrounded mid-ride in "app open" mode, so the
  /// UI can say so honestly rather than pretending nothing happened.
  final pausedGapSeconds = 0.obs;

  /// A ride found unfinished at launch, awaiting the user's choice.
  final interrupted = Rxn<RideRow>();

  /// The last point actually written, which the filter measures against.
  GeoPoint? _lastAccepted;

  /// True when the next accepted point should start a new polyline segment.
  bool _startNewSegment = false;

  /// Wall-clock start, and the moment recording last resumed. Total time
  /// counts the whole ride; moving time excludes stops and gaps.
  int _startedAtMs = 0;
  int? _pausedAtMs;

  Timer? _ticker;

  TrackingMode get mode => _settings.trackingMode.value;
  bool get trackingEnabled => mode != TrackingMode.off;

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addObserver(this);
    unawaited(checkForInterruptedRide());
  }

  @override
  void onClose() {
    WidgetsBinding.instance.removeObserver(this);
    _positionSub?.cancel();
    _ticker?.cancel();
    unawaited(_releaseWakelock());
    super.onClose();
  }

  // -------------------------------------------------------------------
  // Crash recovery
  // -------------------------------------------------------------------

  /// A ride with no end time was interrupted. Offer resume / save / discard
  /// rather than silently deciding for the user.
  Future<void> checkForInterruptedRide() async {
    if (isRecording.value) return;
    interrupted.value = await _rides.findInterrupted();
  }

  Future<void> resolveInterrupted(InterruptedRideChoice choice) async {
    final ride = interrupted.value;
    if (ride == null) return;

    switch (choice) {
      case InterruptedRideChoice.resume:
        await _resume(ride);
      case InterruptedRideChoice.save:
        await _finalise(ride, endMs: await _lastPointTimeOr(ride));
      case InterruptedRideChoice.discard:
        await _rides.hardDelete(ride.id);
    }
    interrupted.value = null;
  }

  Future<int> _lastPointTimeOr(RideRow ride) async {
    final last = await _rides.lastPoint(ride.id);
    return last?.timestampMs ?? ride.startTimeMs;
  }

  // -------------------------------------------------------------------
  // Recording
  // -------------------------------------------------------------------

  Future<bool> start() async {
    if (isRecording.value || !trackingEnabled) return false;

    final vehicleId = _vehicles.activeId;
    if (vehicleId == 0) return false;

    final state = await _location.check();
    if (!state.allowsForeground) return false;

    final now = Clock.nowMs;
    final id = await _rides.create(
      RidesCompanion.insert(
        vehicleId: vehicleId,
        startTimeMs: now,
        createdAt: now,
        updatedAt: now,
        startOdometerM: Value(await _fuel.latestOdometerM(vehicleId)),
      ),
    );

    activeRide.value = await _rides.getById(id);
    _startedAtMs = now;
    _pausedAtMs = null;
    _lastAccepted = null;
    _startNewSegment = false;
    distanceM.value = 0;
    movingSeconds.value = 0;
    totalSeconds.value = 0;
    maxSpeedMps.value = 0;
    pointCount.value = 0;
    pausedGapSeconds.value = 0;

    isRecording.value = true;
    isPaused.value = false;

    await _listen();
    _startTicker();
    await _applyWakelock();
    return true;
  }

  Future<void> _resume(RideRow ride) async {
    activeRide.value = ride;
    _startedAtMs = ride.startTimeMs;
    _pausedAtMs = null;

    final last = await _rides.lastPoint(ride.id);
    _lastAccepted = last == null
        ? null
        : GeoPoint(
            lat: last.lat,
            lng: last.lng,
            timestampMs: last.timestampMs,
            accuracy: last.accuracy,
            speed: last.speed,
          );

    // Whatever happened between then and now was not recorded, so the path
    // must break here.
    _startNewSegment = true;

    distanceM.value = ride.distanceMeters;
    movingSeconds.value = ride.movingSeconds;
    totalSeconds.value = ride.totalSeconds;
    maxSpeedMps.value = ride.maxSpeed;
    pointCount.value = await _rides.pointCount(ride.id);

    isRecording.value = true;
    isPaused.value = false;

    await _listen();
    _startTicker();
    await _applyWakelock();
  }

  Future<void> _listen() async {
    await _positionSub?.cancel();
    _positionSub = _location
        .watch(mode: mode)
        .listen(
          _onPoint,
          onError: (_) {
            // A revoked permission or a disabled GPS mid-ride. Pause rather
            // than tear down: the ride so far is worth keeping, and the
            // user may re-enable it.
            pause();
          },
        );
  }

  void _startTicker() {
    _ticker?.cancel();
    // One second is enough for a duration readout, and cheap.
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!isRecording.value || isPaused.value) return;
      totalSeconds.value = ((Clock.nowMs - _startedAtMs) / 1000).round();
    });
  }

  /// Handles one GPS sample: filter, then write.
  Future<void> _onPoint(GeoPoint point) async {
    final ride = activeRide.value;
    if (ride == null || !isRecording.value || isPaused.value) return;

    final previous = _lastAccepted;
    final result = GpsFilter.test(point, previous);
    if (!result.isAccepted) return;

    // A long silence means recording was interrupted, whatever the cause.
    final isGap =
        _startNewSegment ||
        (previous != null && GpsFilter.isGapAfter(previous, point));

    // Distance across a gap is not distance ridden — the stretch was never
    // recorded, and counting the straight line would invent kilometres.
    final segmentM = isGap ? 0.0 : result.distanceFromPreviousM;

    // Written before any state is updated: if the process dies on the next
    // line, the point is already safe.
    await _rides.addPoint(
      RidePointsCompanion.insert(
        rideId: ride.id,
        lat: point.lat,
        lng: point.lng,
        timestampMs: point.timestampMs,
        speed: Value(point.speed),
        accuracy: Value(point.accuracy),
        altitude: Value(point.altitude),
        isGapStart: Value(isGap),
      ),
    );

    distanceM.value += segmentM.round();
    pointCount.value += 1;

    final speed = point.speed ?? 0;
    if (speed > maxSpeedMps.value) maxSpeedMps.value = speed;

    // Moving time excludes stops, so average speed means "how fast when
    // actually riding" rather than "including twenty minutes at a signal".
    if (previous != null && !isGap && speed >= GpsFilter.movingThresholdMps) {
      final elapsed = (point.timestampMs - previous.timestampMs) / 1000;
      movingSeconds.value += elapsed.round();
    }

    _lastAccepted = point;
    _startNewSegment = false;

    // The ride summary is refreshed on a point rather than on the ticker, so
    // a crash loses at most the last sample's worth of totals.
    await _persistProgress(ride.id);
  }

  Future<void> _persistProgress(int rideId) async {
    await _rides.update(
      rideId,
      RidesCompanion(
        distanceMeters: Value(distanceM.value),
        movingSeconds: Value(movingSeconds.value),
        totalSeconds: Value(totalSeconds.value),
        maxSpeed: Value(maxSpeedMps.value),
        avgSpeed: Value(_averageSpeed),
      ),
    );
  }

  double get _averageSpeed {
    // Guard every division.
    if (movingSeconds.value <= 0) return 0;
    return distanceM.value / movingSeconds.value;
  }

  // -------------------------------------------------------------------
  // Pause, resume, stop
  // -------------------------------------------------------------------

  void pause() {
    if (!isRecording.value || isPaused.value) return;
    isPaused.value = true;
    _pausedAtMs = Clock.nowMs;
    // The next point after a pause starts a new segment.
    _startNewSegment = true;
  }

  void unpause() {
    if (!isRecording.value || !isPaused.value) return;
    final pausedAt = _pausedAtMs;
    if (pausedAt != null) {
      pausedGapSeconds.value += ((Clock.nowMs - pausedAt) / 1000).round();
    }
    isPaused.value = false;
    _pausedAtMs = null;
  }

  Future<RideRow?> stop() async {
    final ride = activeRide.value;
    if (ride == null) return null;

    await _positionSub?.cancel();
    _positionSub = null;
    _ticker?.cancel();
    await _releaseWakelock();

    isRecording.value = false;
    isPaused.value = false;

    final finished = await _finalise(ride, endMs: Clock.nowMs);
    activeRide.value = null;
    return finished;
  }

  Future<RideRow?> _finalise(RideRow ride, {required int endMs}) async {
    final startOdometer = ride.startOdometerM;

    await _rides.update(
      ride.id,
      RidesCompanion(
        endTimeMs: Value(endMs),
        isComplete: const Value(true),
        distanceMeters: Value(distanceM.value),
        movingSeconds: Value(movingSeconds.value),
        totalSeconds: Value(((endMs - ride.startTimeMs) / 1000).round()),
        maxSpeed: Value(maxSpeedMps.value),
        avgSpeed: Value(_averageSpeed),
        // Advancing the odometer by the ride's distance keeps rides feeding
        // the same odometer history as fills and services — which is what
        // service prediction reads.
        endOdometerM: Value(
          startOdometer == null ? null : startOdometer + distanceM.value,
        ),
      ),
    );

    final saved = await _rides.getById(ride.id);

    // A ride that recorded nothing is noise in the list and moves the
    // odometer nowhere — usually a mis-tap on Start. Drop it rather than
    // leave an empty row behind.
    if (saved != null && saved.distanceMeters == 0) {
      await _rides.hardDelete(ride.id);
      return null;
    }

    return saved;
  }

  // -------------------------------------------------------------------
  // App lifecycle — "app open" mode
  // -------------------------------------------------------------------

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (!isRecording.value) return;

    // Background mode keeps its foreground service running, so it ignores
    // the lifecycle entirely. App-open mode must stop and say so.
    if (mode != TrackingMode.appOpen) return;

    switch (state) {
      case AppLifecycleState.paused:
      case AppLifecycleState.detached:
      case AppLifecycleState.hidden:
        pause();
      case AppLifecycleState.resumed:
        unpause();
      case AppLifecycleState.inactive:
        break;
    }
  }

  /// The honest message for a ride that was paused while the app was away.
  /// Null when nothing was missed.
  String? get gapNotice {
    final seconds = pausedGapSeconds.value;
    if (seconds < 60) return null;

    final minutes = (seconds / 60).round();
    return 'Ride paused while the app was closed — $minutes min gap. '
        'Turn on background tracking to keep recording with the screen off.';
  }

  // -------------------------------------------------------------------
  // Screen wakelock
  // -------------------------------------------------------------------

  Future<void> _applyWakelock() async {
    if (!_settings.keepScreenOnDuringRides.value) return;
    try {
      await WakelockPlus.enable();
    } on Object {
      // Not worth failing a ride over.
    }
  }

  Future<void> _releaseWakelock() async {
    try {
      await WakelockPlus.disable();
    } on Object {
      // Ditto.
    }
  }
}
