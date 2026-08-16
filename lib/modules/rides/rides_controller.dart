import 'dart:async';

import 'package:drift/drift.dart' show Value;
import 'package:get/get.dart' hide Value;

import '../../core/utils/clock.dart';
import '../../data/db/database.dart';
import '../../data/repositories/ride_repo.dart';
import '../vehicles/vehicle_controller.dart';

/// One month of rides, for the grouped list.
class RideMonthGroup {
  const RideMonthGroup({
    required this.monthStartMs,
    required this.rides,
    required this.distanceM,
  });

  final int monthStartMs;
  final List<RideRow> rides;
  final int distanceM;
}

class RidesController extends GetxController {
  RidesController(this._repo, this._vehicles);

  final RideRepo _repo;
  final VehicleController _vehicles;

  StreamSubscription<List<RideRow>>? _sub;

  final rides = <RideRow>[].obs;
  final isReady = false.obs;

  @override
  void onInit() {
    super.onInit();
    ever(_vehicles.active, (_) => _bind());
    _bind();
  }

  @override
  void onClose() {
    _sub?.cancel();
    super.onClose();
  }

  void _bind() {
    _sub?.cancel();
    final id = _vehicles.activeId;
    if (id == 0) {
      rides.clear();
      isReady.value = true;
      return;
    }
    isReady.value = false;
    _sub = _repo.watchForVehicle(id).listen((rows) {
      // An in-progress ride has no end time and belongs to the tracker, not
      // to the history list.
      rides.assignAll(rows.where((r) => r.endTimeMs != null));
      isReady.value = true;
    });
  }

  List<RideMonthGroup> get monthGroups {
    final buckets = <int, List<RideRow>>{};
    for (final r in rides) {
      buckets
          .putIfAbsent(Dates.startOfLocalMonth(r.startTimeMs), () => [])
          .add(r);
    }

    final keys = buckets.keys.toList()..sort((a, b) => b.compareTo(a));
    return [
      for (final key in keys)
        RideMonthGroup(
          monthStartMs: key,
          rides: buckets[key]!,
          distanceM: buckets[key]!.fold(0, (sum, r) => sum + r.distanceMeters),
        ),
    ];
  }

  int get totalDistanceM => rides.fold(0, (sum, r) => sum + r.distanceMeters);

  Future<List<RidePointRow>> pointsFor(int rideId) => _repo.getPoints(rideId);

  Future<int> pointCount(int rideId) => _repo.pointCount(rideId);

  Future<void> delete(int id) => _repo.softDelete(id);

  Future<void> undoDelete(int id) async {
    await _repo.update(id, const RidesCompanion(deletedAt: Value(null)));
  }

  /// Removes every recorded GPS path while keeping the ride summaries that
  /// statistics depend on. Wired to "delete location history" in settings.
  Future<int> deleteAllLocationHistory() => _repo.deleteAllLocationHistory();
}
