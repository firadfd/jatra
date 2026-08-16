import 'dart:async';

import 'package:drift/drift.dart' show Value;
import 'package:get/get.dart' hide Value;

import '../../core/calc/service_predictor.dart';
import '../../data/db/database.dart';
import '../../data/repositories/fuel_repo.dart';
import '../../data/repositories/service_repo.dart';
import '../../services/reminder_service.dart';
import '../vehicles/vehicle_controller.dart';

/// Service screen state: the urgency-sorted plan, plus the history below it.
class ServiceController extends GetxController {
  ServiceController(this._service, this._fuel, this._vehicles, this._reminders);

  final ServiceRepo _service;
  final FuelRepo _fuel;
  final VehicleController _vehicles;
  final ReminderService _reminders;

  StreamSubscription<List<ServiceItemRow>>? _itemSub;
  StreamSubscription<List<ServiceLogRow>>? _logSub;

  final items = <ServiceItemRow>[].obs;
  final logs = <ServiceLogRow>[].obs;

  /// Sorted most urgent first.
  final plan = <ServiceDue>[].obs;

  final currentOdometerM = 0.obs;

  /// Metres per day from the last 60 days of odometer observations, or null
  /// when there is not enough history to project from. Surfaced in the UI so
  /// an estimated date can be labelled as one.
  final dailyMetres = RxnDouble();

  final isReady = false.obs;

  @override
  void onInit() {
    super.onInit();
    ever(_vehicles.active, (_) => _bind());
    _bind();
  }

  @override
  void onClose() {
    _itemSub?.cancel();
    _logSub?.cancel();
    super.onClose();
  }

  void _bind() {
    _itemSub?.cancel();
    _logSub?.cancel();

    final id = _vehicles.activeId;
    if (id == 0) {
      items.clear();
      logs.clear();
      plan.clear();
      isReady.value = true;
      return;
    }

    isReady.value = false;
    _itemSub = _service.watchItems(id).listen((rows) {
      items.assignAll(rows);
      unawaited(refreshPlan());
    });
    _logSub = _service.watchLogs(id).listen(logs.assignAll);
  }

  /// Recomputes the plan against the latest odometer and riding rate.
  ///
  /// Kept as an explicit step rather than a getter because both inputs come
  /// from queries, and recomputing inside a build would hit the database on
  /// every frame.
  Future<void> refreshPlan() async {
    final id = _vehicles.activeId;
    if (id == 0) return;

    currentOdometerM.value = await _fuel.latestOdometerM(id);
    dailyMetres.value = ServicePredictor.dailyMetres(
      await _fuel.odometerObservations(id),
    );

    plan.assignAll(
      ServicePredictor.plan(
        items,
        currentOdometerM: currentOdometerM.value,
        dailyMetresEstimate: dailyMetres.value,
      ),
    );

    isReady.value = true;
  }

  /// The single most urgent item worth showing on the home screen, or null
  /// when nothing needs attention.
  ServiceDue? get mostUrgent {
    for (final due in plan) {
      if (due.needsAttention) return due;
    }
    return null;
  }

  /// How many items need attention at all — the count on the home card.
  int get needingAttention => plan.where((d) => d.needsAttention).length;

  Future<void> deleteItem(int id) async {
    await _service.softDeleteItem(id);
    await _reminders.recompute(_vehicles.activeId);
  }

  Future<void> setItemActive(int id, bool active) async {
    await _service.updateItem(
      id,
      ServiceItemsCompanion(isActive: Value(active)),
    );
    await _reminders.recompute(_vehicles.activeId);
  }

  Future<void> deleteLog(int id) async {
    await _service.softDeleteLog(id);
    await refreshPlan();
    await _reminders.recompute(_vehicles.activeId);
  }
}
