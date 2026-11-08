import 'dart:io';
import 'dart:ui' as ui;

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart' hide Value;
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';

import '../../app/routes/app_routes.dart';
import '../../core/calc/cost_calc.dart';
import '../../core/calc/date_range.dart';
import '../../core/utils/card_route.dart';
import '../../core/utils/formatters.dart';
import '../../core/utils/money.dart';
import '../../data/db/database.dart';
import '../../data/repositories/expense_repo.dart';
import '../../data/repositories/fuel_repo.dart';
import '../../data/repositories/ride_repo.dart';
import '../../data/repositories/service_repo.dart';
import '../../l10n/app_localizations.dart';
import '../../services/district_map.dart';
import '../../services/export_service.dart';
import '../../services/home_widget/offscreen_renderer.dart';
import '../../services/settings_service.dart';
import '../vehicles/vehicle_controller.dart';
import 'widgets/ride_card_face.dart';

/// Composes and shares the card for one finished ride.
class RideCardController extends GetxController {
  RideCardController(
    this._rides,
    this._fuel,
    this._service,
    this._expenses,
    this._vehicles,
    this._settings,
    this._export,
  );

  /// Wide enough to stay sharp on a 1080-pixel card even when cropped.
  static const _photoDecodeWidth = 1600;

  final RideRepo _rides;
  final FuelRepo _fuel;
  final ServiceRepo _service;
  final ExpenseRepo _expenses;
  final VehicleController _vehicles;
  final SettingsService _settings;
  final ExportService _export;

  final fromCtrl = TextEditingController();
  final toCtrl = TextEditingController();
  final usernameCtrl = TextEditingController();
  final bikeCtrl = TextEditingController();

  final isLoading = true.obs;
  final isSharing = false.obs;
  final notFound = false.obs;
  final showRoute = true.obs;
  final photo = Rxn<ui.Image>();

  // Mirrors of the text fields, so the preview follows typing.
  final _from = ''.obs;
  final _to = ''.obs;
  final _username = ''.obs;
  final _bike = ''.obs;

  DistrictMap districts = DistrictMap.empty;

  late RideRow _ride;
  late Fmt _fmt;
  CardRoute _route = CardRoute.empty;
  Set<String> _endDistricts = const {};
  TripEstimate? _estimate;

  @override
  void onInit() {
    super.onInit();
    void mirror(TextEditingController c, RxString target) =>
        c.addListener(() => target.value = c.text.trim());
    mirror(fromCtrl, _from);
    mirror(toCtrl, _to);
    mirror(usernameCtrl, _username);
    mirror(bikeCtrl, _bike);
    _load();
  }

  @override
  void onClose() {
    for (final c in [fromCtrl, toCtrl, usernameCtrl, bikeCtrl]) {
      c.dispose();
    }
    photo.value?.dispose();
    super.onClose();
  }

  Future<void> _load() async {
    final args = Get.arguments;
    final id = args is Map ? args[RouteArgs.rideId] as int? ?? 0 : 0;
    final ride = await _rides.getById(id);
    if (ride == null) {
      notFound.value = true;
      isLoading.value = false;
      return;
    }
    _ride = ride;

    final vehicle = _vehicles.vehicles.firstWhereOrNull(
      (v) => v.id == ride.vehicleId,
    );
    final locale = _settings.localeCode.value;
    _fmt = Fmt(
      distanceUnit: vehicle?.distanceUnit ?? DistanceUnit.km,
      volumeUnit: vehicle?.volumeUnit ?? VolumeUnit.l,
      currency: vehicle?.currency ?? 'BDT',
      locale: locale,
    );
    usernameCtrl.text = _settings.rideCardUsername.value;
    bikeCtrl.text = vehicle?.name ?? '';

    final points = await _rides.getPoints(id);
    _route = CardRoute.fromPoints([
      for (final p in points)
        (lat: p.lat, lng: p.lng, isGapStart: p.isGapStart),
    ]);

    districts = await DistrictMap.load();
    if (points.isNotEmpty) {
      final start = districts.locate(points.first.lat, points.first.lng);
      final end = districts.locate(points.last.lat, points.last.lng);
      fromCtrl.text = start?.nameIn(locale) ?? '';
      toCtrl.text = end?.nameIn(locale) ?? '';
      _endDistricts = {?start?.en, ?end?.en};
    }

    if (vehicle != null) _estimate = await _estimateCost(vehicle, ride);
    isLoading.value = false;
  }

  /// The ride's distance at this bike's all-time cost per km. Null until the
  /// log has enough fuel history to give a rate.
  Future<TripEstimate?> _estimateCost(VehicleRow vehicle, RideRow ride) async {
    final range = DateRange.allTime();
    final observations = await _fuel.odometerObservations(vehicle.id);
    final distance = CostCalculator.distanceIn(observations, range: range);
    final report = CostCalculator.compute(
      vehicle: vehicle,
      range: range,
      fuelEntries: await _fuel.getForVehicle(vehicle.id),
      serviceLogs: await _service.getLogs(vehicle.id),
      expenses: await _expenses.getForVehicle(vehicle.id),
      distanceM: distance.distanceM,
      observationCount: distance.count,
      defaultAnnualDepreciationPercent:
          _settings.defaultDepreciationPercent.value,
    );
    return CostCalculator.estimateTrip(
      report: report,
      distanceM: ride.distanceMeters,
      unit: vehicle.distanceUnit,
    );
  }

  /// Reactive: reads every observable the preview depends on.
  RideCardContent content(L l) {
    final estimate = _estimate;
    final Money? cost = estimate?.trueCost ?? estimate?.fuelCost;

    return RideCardContent(
      from: _from.value,
      to: _to.value,
      date: _fmt.date(_ride.startTimeMs),
      username: _username.value,
      bikeName: _bike.value,
      route: showRoute.value ? _route : CardRoute.empty,
      highlightedDistricts: _endDistricts,
      photo: photo.value,
      stats: [
        RideCardStat(
          label: l.statsDistance,
          value: _fmt.distance(_ride.distanceMeters),
          unit: _fmt.distanceLabel,
        ),
        RideCardStat(
          label: l.ridesMovingTime,
          value: _fmt.duration(_ride.movingSeconds),
        ),
        if (cost != null)
          RideCardStat(
            label: estimate?.trueCost != null
                ? l.ridesCardTrueCost
                : l.ridesCardFuelCost,
            value: _fmt.amountRounded(cost),
          )
        else
          RideCardStat(
            label: l.ridesTopSpeed,
            value: _fmt.speed(_ride.maxSpeed),
            unit: _fmt.speedLabel,
          ),
      ],
    );
  }

  Future<void> pickPhoto(L l) async {
    try {
      final picked = await FilePicker.platform.pickFiles(type: FileType.image);
      final path = picked?.files.single.path;
      if (path == null) return;

      final codec = await ui.instantiateImageCodec(
        await File(path).readAsBytes(),
        targetWidth: _photoDecodeWidth,
      );
      final frame = await codec.getNextFrame();
      codec.dispose();
      _setPhoto(frame.image);
    } on Object catch (e) {
      debugPrint('Ride card photo failed: $e');
      Get.snackbar(
        l.ridesCardTitle,
        l.ridesCardPhotoFailed,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  void removePhoto() => _setPhoto(null);

  void _setPhoto(ui.Image? image) {
    final old = photo.value;
    photo.value = image;
    old?.dispose();
  }

  Future<void> share(L l) async {
    if (isSharing.value) return;
    isSharing.value = true;
    try {
      _settings.rideCardUsername.value = _username.value;

      final png = await OffscreenRenderer.toPng(
        child: RideCardFace(content: content(l), districts: districts),
        size: RideCardFace.size,
        pixelRatio: RideCardFace.pixelRatio,
      );
      if (png == null) throw StateError('No view to render with');

      final stamp = DateFormat('yyyy-MM-dd_HHmmss').format(DateTime.now());
      final file = File(
        '${(await getTemporaryDirectory()).path}/jatra_ride_$stamp.png',
      );
      await file.writeAsBytes(png);

      final places = [_from.value, _to.value].where((p) => p.isNotEmpty);
      await _export.share([file], subject: places.join(' → '));
    } on Object catch (e) {
      debugPrint('Ride card failed: $e');
      Get.snackbar(
        l.ridesCardTitle,
        l.ridesCardFailed,
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isSharing.value = false;
    }
  }
}
