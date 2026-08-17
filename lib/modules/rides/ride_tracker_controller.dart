import 'dart:async';

import 'package:drift/drift.dart' show Value;
import 'package:flutter/widgets.dart';
import 'package:get/get.dart' hide Value;
import 'package:wakelock_plus/wakelock_plus.dart';

import '../../core/utils/clock.dart';
import '../../core/utils/geo_utils.dart';
import '../../core/utils/l10n.dart';
import '../../data/db/database.dart';
import '../../data/repositories/fuel_repo.dart';
import '../../data/repositories/ride_repo.dart';
import '../../services/location_service.dart';
import '../../services/notification_service.dart';
import '../../services/settings_service.dart';
import '../vehicles/vehicle_controller.dart';

/// What to do about a ride that was still recording when the app died.
enum InterruptedRideChoice { resume, save, discard }

/// Records a ride.
///
/// Three rules shape everything here:
///
/// 1. **Every accepted point is written to the database immediately.** The
///    path is never held in memory alone, so killing the app mid-ride costs
///    at most the last sample.
/// 2. **Gaps are shown, not smoothed over.** When recording stops and
///    resumes, the next point is flagged so the polyline breaks rather than
///    drawing a straight line across a stretch that was never ridden.
/// 3. **A ride runs from Start to Finish, not from foreground to
///    background.** The position stream is opened behind an Android
///    foreground service and is cancelled by [stop], by [pause] and by
///    nothing else. Leaving the app, locking the screen or taking a call
///    does not touch it.
class RideTrackerController extends GetxController with WidgetsBindingObserver {
  RideTrackerController(
    this._rides,
    this._fuel,
    this._location,
    this._vehicles,
    this._settings,
    this._notifications,
  );

  final RideRepo _rides;
  final FuelRepo _fuel;
  final LocationService _location;
  final VehicleController _vehicles;
  final SettingsService _settings;
  final NotificationService _notifications;

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

  /// How long the ride has spent paused, so the UI can say plainly that a
  /// stretch is missing rather than pretending nothing happened.
  final pausedGapSeconds = 0.obs;

  /// The most recent accepted fix, published for the map to draw its "you are
  /// here" dot from.
  ///
  /// While a ride is recording this is the only GPS subscription the app
  /// needs — the map reads it instead of opening a second stream of its own,
  /// which would mean two location clients running against the same hardware
  /// for the same answer.
  final lastPoint = Rxn<GeoPoint>();

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
    // An ongoing notification outlives the process that posted it, so a ride
    // killed by the system leaves "Recording your ride" sitting in the shade
    // claiming something that stopped hours ago. Nothing is recording at this
    // point by definition; `_resume` reposts it if the rider picks the ride
    // back up.
    unawaited(_notifications.cancelRideProgress());
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

    // Android suppresses the recording notification without
    // POST_NOTIFICATIONS, and a ride recording invisibly in the background is
    // the one outcome this feature must never produce. Asked here, at the
    // moment the user taps Start, and before the clock starts below so a slow
    // answer to the dialog does not land inside the ride's duration.
    //
    // A refusal is not a reason to refuse the ride — the recording still
    // works, the rider just has nothing in the shade to look at.
    await _notifications.ensureAllowed();

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
    lastPoint.value = null;

    isRecording.value = true;
    isPaused.value = false;

    await _listen();
    _startTicker();
    await _applyWakelock();
    // Posted straight away rather than waiting for the first GPS point, which
    // can be twenty seconds out in a covered car park. "Recording your ride ·
    // 0.0 km" is the honest state, and the rider gets confirmation that the
    // tap worked.
    await _publishNotification();
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
    lastPoint.value = _lastAccepted;

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
    await _publishNotification();
  }

  /// Opens the position stream for the ride.
  ///
  /// This runs behind a foreground service for the whole ride, so it is
  /// deliberately *not* tied to the app lifecycle. The only things that close
  /// it are [stop] and [onClose] — [pause] leaves it open and drops the
  /// samples instead, because tearing the service down would mean *starting*
  /// one again on unpause, and Android 12+ forbids starting a foreground
  /// service from the background. A paused ride is usually a paused ride in a
  /// pocket.
  Future<void> _listen() async {
    await _positionSub?.cancel();
    _positionSub = _location.watchRide().listen(
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
    lastPoint.value = point;
    unawaited(_publishNotification());

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
  // The ride notification
  // -------------------------------------------------------------------

  /// Posts the notification the rider actually sees while a ride runs.
  ///
  /// Android forces geolocator's foreground-service notification into the
  /// shade, but geolocator hardcodes `IMPORTANCE_NONE` on its channel and
  /// recreates it on every start, so it cannot be given a sound or a
  /// status-bar icon from here. This is the visible one, and unlike
  /// geolocator's it can carry the distance so far.
  Future<void> _publishNotification() async {
    if (!isRecording.value) return;

    final fmt = _vehicles.fmt.value;
    await _notifications.showRideProgress(
      channelName: l10n.ridesNotificationChannel,
      title: isPaused.value
          ? l10n.ridesNotificationPaused
          : l10n.ridesNotificationTitle,
      body:
          '${fmt.distancePrecise(distanceM.value)} '
          '${fmt.distanceLabel.toLowerCase()}',
      startedAtMs: _startedAtMs,
      paused: isPaused.value,
    );
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
    // Republished immediately rather than on the next point: paused means no
    // more points are coming, so this is the last chance to stop the
    // notification claiming the ride is still running.
    unawaited(_publishNotification());
  }

  void unpause() {
    if (!isRecording.value || !isPaused.value) return;
    final pausedAt = _pausedAtMs;
    if (pausedAt != null) {
      pausedGapSeconds.value += ((Clock.nowMs - pausedAt) / 1000).round();
    }
    isPaused.value = false;
    _pausedAtMs = null;
    unawaited(_publishNotification());
  }

  Future<RideRow?> stop() async {
    final ride = activeRide.value;
    if (ride == null) return null;

    // Cancelling the subscription is what stops the foreground service and
    // clears its notification. Do it first, so nothing can land in the
    // database after the ride has been finalised.
    await _positionSub?.cancel();
    _positionSub = null;
    _ticker?.cancel();
    await _releaseWakelock();

    isRecording.value = false;
    isPaused.value = false;
    lastPoint.value = null;
    // Cleared here rather than in `_finalise`, so a ride that turns out to be
    // empty and gets discarded still takes its notification with it.
    await _notifications.cancelRideProgress();

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
  // App lifecycle
  // -------------------------------------------------------------------

  /// Backgrounding no longer stops anything.
  ///
  /// This observer used to pause the ride whenever the app left the screen,
  /// which is what made recording a foreground-only affair. It now does the
  /// opposite job: on the way back in, it checks the stream is still there
  /// and re-opens it if the platform tore it down while the app was away.
  /// Everything else about the ride carries on untouched.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state != AppLifecycleState.resumed) return;
    if (!isRecording.value || isPaused.value) return;
    if (_positionSub != null) return;

    // No subscription while recording means the stream died out of sight —
    // a killed service, a revoked permission that came back. The next point
    // starts a new segment, so the break is drawn rather than papered over.
    _startNewSegment = true;
    unawaited(_listen());
  }

  /// The honest message for a ride that spent time paused. Null when nothing
  /// was missed.
  String? get gapNotice {
    final seconds = pausedGapSeconds.value;
    if (seconds < 60) return null;

    final minutes = (seconds / 60).round();
    return 'Paused for $minutes min — that stretch is not part of the '
        'recorded distance.';
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
