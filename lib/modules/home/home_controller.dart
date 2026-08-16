import 'dart:async';

import 'package:get/get.dart' hide Value;

import '../../core/calc/cost_calc.dart';
import '../../core/calc/date_range.dart';
import '../../core/calc/mileage_calc.dart';
import '../../data/repositories/expense_repo.dart';
import '../../data/repositories/fuel_repo.dart';
import '../../data/repositories/service_repo.dart';
import '../../services/settings_service.dart';
import '../fuel/fuel_controller.dart';
import '../vehicles/vehicle_controller.dart';

/// Home screen state.
///
/// The mileage figures come from the shared [FuelController] rather than
/// being recomputed here, so home and the history screen can never disagree
/// mid-write. This controller owns the live odometer reading and the
/// lifetime cost summary that backs the cost-per-distance tile.
class HomeController extends GetxController {
  HomeController(
    this._fuelRepo,
    this._serviceRepo,
    this._expenseRepo,
    this._vehicles,
    this._settings,
    this.fuel,
  );

  final FuelRepo _fuelRepo;
  final ServiceRepo _serviceRepo;
  final ExpenseRepo _expenseRepo;
  final VehicleController _vehicles;
  final SettingsService _settings;
  final FuelController fuel;

  StreamSubscription<int>? _odometerSub;

  /// Current reading in metres, across fuel entries, service logs and rides.
  final odometerM = 0.obs;

  /// Lifetime costs. Home shows the all-time figure because it is the stable
  /// one; the stats screen is where a rider goes to scope it to a period.
  final costReport = CostReport.empty.obs;

  MileageReport get report => fuel.report.value;

  @override
  void onInit() {
    super.onInit();
    ever(_vehicles.active, (_) => _bind());
    // Any change to the fuel log also changes the cost picture.
    ever(fuel.entries, (_) => _loadCosts());
    _bind();
  }

  @override
  void onClose() {
    _odometerSub?.cancel();
    super.onClose();
  }

  void _bind() {
    _odometerSub?.cancel();
    final id = _vehicles.activeId;
    if (id == 0) {
      odometerM.value = 0;
      costReport.value = CostReport.empty;
      return;
    }
    _odometerSub = _fuelRepo
        .watchLatestOdometerM(id)
        .listen((value) => odometerM.value = value);
    unawaited(_loadCosts());
  }

  Future<void> _loadCosts() async {
    final vehicle = _vehicles.active.value;
    if (vehicle == null) return;

    final range = DateRange.allTime();
    final observations = await _fuelRepo.odometerObservations(vehicle.id);
    final distance = CostCalculator.distanceIn(observations, range: range);

    costReport.value = CostCalculator.compute(
      vehicle: vehicle,
      range: range,
      fuelEntries: await _fuelRepo.getForVehicle(vehicle.id),
      serviceLogs: await _serviceRepo.getLogs(vehicle.id),
      expenses: await _expenseRepo.getForVehicle(vehicle.id),
      distanceM: distance.distanceM,
      observationCount: distance.count,
      defaultAnnualDepreciationPercent:
          _settings.defaultDepreciationPercent.value,
    );
  }
}
