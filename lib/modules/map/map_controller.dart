import 'dart:async';

// Aliased: flutter_map exports its own `MapController`, which is the camera
// handle, not this class.
import 'package:flutter_map/flutter_map.dart' as fm;
import 'package:get/get.dart' hide Value;
import 'package:latlong2/latlong.dart';

import '../../core/utils/geo_utils.dart';
import '../../data/db/database.dart';
import '../../data/repositories/ride_repo.dart';
import '../../services/location_service.dart';
import '../rides/ride_tracker_controller.dart';
import '../shell/shell_controller.dart';
import '../vehicles/vehicle_controller.dart';

/// Backs the Map tab.
///
/// The tab always shows exactly one path, chosen by a single rule: **the ride
/// being recorded if there is one, otherwise the most recent finished ride.**
/// That keeps the screen useful in both states without a mode switch the user
/// has to think about.
///
/// This deliberately does *not* reuse [RidesController]. That controller is
/// owned by the `/rides` route's binding, so GetX disposes it when that screen
/// pops — which would leave the map tab, which outlives it inside the shell,
/// holding a dead controller. Watching the repo directly costs one extra
/// subscription and removes the lifecycle hazard entirely.
class MapController extends GetxController {
  MapController(
    this._repo,
    this._tracker,
    this._vehicles,
    this._location,
    this._shell,
  );

  final RideRepo _repo;
  final RideTrackerController _tracker;
  final VehicleController _vehicles;
  final LocationService _location;
  final ShellController _shell;

  StreamSubscription<List<RideRow>>? _ridesSub;
  StreamSubscription<List<RidePointRow>>? _pointsSub;
  StreamSubscription<GeoPoint>? _meSub;

  /// The ride whose path is on screen — live or historic.
  final ride = Rxn<RideRow>();

  /// That ride's full path. Simplification for rendering happens in `RideMap`.
  final points = <RidePointRow>[].obs;

  /// Most recent finished ride for the active vehicle, or null when there is
  /// none yet.
  final latestFinished = Rxn<RideRow>();

  /// False until the first rides query comes back, so the tab shows a spinner
  /// rather than flashing its empty state.
  final isReady = false.obs;

  /// True when the path on screen is the ride currently being recorded.
  bool get isLive => _tracker.isRecording.value;

  // -------------------------------------------------------------------
  // "You are here"
  // -------------------------------------------------------------------

  /// The latest fix, or null when the dot is off or nothing has arrived yet.
  final myLocation = Rxn<GeoPoint>();

  /// Whether the user has asked for the dot. Off until they tap the button —
  /// this app does not reach for the GPS on its own.
  final showMyLocation = false.obs;

  /// Set while a fix is being waited on, so the button can show progress
  /// instead of looking dead. The first fix can take several seconds.
  final locating = false.obs;

  /// The last permission answer, for the view to explain a refusal.
  final permission = LocationPermissionState.notRequested.obs;

  /// The map's camera, so the view can recentre on the dot. Owned here
  /// because `RideMap` is stateless and rebuilds on every new fix.
  final camera = fm.MapController();

  /// Whether the camera chases the dot.
  ///
  /// On, every new fix recentres the map, so a moving rider stays in the
  /// middle of the screen instead of walking off the edge of a static view.
  /// It is switched on by the locate button and off by the first drag —
  /// see [breakFollow]. A map that snaps back while you are trying to look at
  /// the road ahead is worse than one that does not follow at all.
  final followMe = false.obs;

  /// Centres the map on the latest fix, if there is one, and starts
  /// following.
  ///
  /// Zooms in only when currently further out than street level — someone who
  /// has deliberately zoomed in past that should not be yanked back out.
  void recentreOnMe() {
    followMe.value = true;
    _centreOnMe(zoomIn: true);
  }

  /// Stops the camera chasing the dot. Called when the user drags the map:
  /// a deliberate pan is a statement about where they want to be looking.
  void breakFollow() {
    if (followMe.value) followMe.value = false;
  }

  void _centreOnMe({required bool zoomIn}) {
    final me = myLocation.value;
    if (me == null) return;

    try {
      final zoom = camera.camera.zoom;
      camera.move(
        LatLng(me.lat, me.lng),
        zoomIn && zoom < _followZoom ? _followZoom : zoom,
      );
    } on Object {
      // `camera` throws until a FlutterMap has attached to it. Nothing to
      // recentre in that case, and it is not worth an error.
    }
  }

  /// Street level — close enough to tell which road you are on, wide enough
  /// to see the next junction coming.
  static const _followZoom = 16.0;

  @override
  void onInit() {
    super.onInit();
    ever(_vehicles.active, (_) => _bindRides());
    // A ride starting or finishing swaps which path the tab should show.
    ever(_tracker.activeRide, (_) => _pickRide());
    // Leaving the tab drops the GPS subscription and coming back restores it.
    // The shell keeps this tab alive forever, so without this the dot would
    // hold the GPS open for the life of the process.
    ever(_shell.tab, (_) => _syncLocationStream());
    // A recording ride is already streaming positions behind its foreground
    // service. The dot rides along on those rather than opening a second
    // location client to ask the same hardware the same question.
    ever(_tracker.isRecording, _onRecordingChanged);
    ever(_tracker.lastPoint, (point) {
      if (point != null && _tracker.isRecording.value) _onFix(point);
    });
    _bindRides();
  }

  /// Starting a ride turns the dot and follow mode on by itself.
  ///
  /// No permission is requested here and none is needed: a ride cannot be
  /// recording without location already granted. Someone who has just tapped
  /// Start and opened the map wants to watch themselves move, and making them
  /// tap a second button for a GPS that is already running is friction for
  /// its own sake.
  void _onRecordingChanged(bool recording) {
    if (recording) {
      showMyLocation.value = true;
      followMe.value = true;
      final point = _tracker.lastPoint.value;
      if (point != null) _onFix(point);
    }
    // Swaps between the tracker's stream and the map's own, in whichever
    // direction the ride just went.
    _syncLocationStream();
  }

  /// One new fix, from whichever source is live.
  void _onFix(GeoPoint point) {
    myLocation.value = point;
    locating.value = false;
    // Zoom is left alone here. The rider set it; a camera that re-zooms on
    // every sample is unusable.
    if (followMe.value) _centreOnMe(zoomIn: false);
  }

  @override
  void onClose() {
    _ridesSub?.cancel();
    _pointsSub?.cancel();
    _meSub?.cancel();
    camera.dispose();
    super.onClose();
  }

  /// Turns the dot on, asking for permission if this is the first time.
  ///
  /// Returns the resulting permission state so the caller can explain a
  /// refusal — a denial is not an error to swallow, and "deniedForever" or
  /// "servicesDisabled" both need a different sentence and a different button.
  Future<LocationPermissionState> enableMyLocation() async {
    final state = await _location.requestForeground();
    permission.value = state;

    if (!state.allowsForeground) {
      showMyLocation.value = false;
      return state;
    }

    showMyLocation.value = true;
    followMe.value = true;
    _syncLocationStream();

    // The stream can take a few seconds to produce its first sample, so a
    // one-shot fix fills the dot in immediately where one is available.
    locating.value = myLocation.value == null;
    final fix = await _location.currentPosition();
    if (fix != null) _onFix(fix);
    locating.value = false;

    return state;
  }

  void disableMyLocation() {
    showMyLocation.value = false;
    followMe.value = false;
    myLocation.value = null;
    locating.value = false;
    _syncLocationStream();
  }

  /// The dot streams only while it is switched on, the map is the tab on
  /// screen, **and** no ride is supplying fixes already.
  ///
  /// All three conditions matter. This runs in a shell that never disposes the
  /// tab, so "is it visible" is the only thing standing between a live GPS
  /// subscription and one that outlives the user's interest in it — and during
  /// a ride the tracker's own stream is already running, so opening a second
  /// one would double the battery cost for an identical answer.
  void _syncLocationStream() {
    final wanted =
        showMyLocation.value &&
        _shell.tab.value == ShellTab.map &&
        !_tracker.isRecording.value;

    if (!wanted) {
      _meSub?.cancel();
      _meSub = null;
      return;
    }
    if (_meSub != null) return;

    _meSub = _location.watchForeground().listen(
      _onFix,
      onError: (_) {
        // Permission revoked from the notification shade, or GPS switched
        // off mid-session. Drop the dot rather than leave a stale one
        // claiming the rider is somewhere they left ten minutes ago.
        disableMyLocation();
      },
    );
  }

  void _bindRides() {
    _ridesSub?.cancel();

    final id = _vehicles.activeId;
    if (id == 0) {
      latestFinished.value = null;
      isReady.value = true;
      _pickRide();
      return;
    }

    isReady.value = false;
    _ridesSub = _repo.watchForVehicle(id).listen((rows) {
      // `watchForVehicle` is already newest-first, and an in-progress ride has
      // no end time — that one belongs to the tracker, not to history.
      final finished = rows.where((r) => r.endTimeMs != null);
      latestFinished.value = finished.isEmpty ? null : finished.first;
      isReady.value = true;
      _pickRide();
    });
  }

  /// Live ride wins; otherwise the newest finished one.
  void _pickRide() {
    final next = _tracker.activeRide.value ?? latestFinished.value;
    if (next?.id == ride.value?.id) return;

    ride.value = next;
    _bindPoints(next?.id);
  }

  void _bindPoints(int? rideId) {
    _pointsSub?.cancel();
    _pointsSub = null;
    points.clear();

    if (rideId == null) return;
    // Watched rather than fetched, so a recording ride redraws as each
    // accepted sample lands.
    _pointsSub = _repo.watchPoints(rideId).listen(points.assignAll);
  }
}
