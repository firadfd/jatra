import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart' hide Value;
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';

import '../../core/calc/place_route.dart';
import '../../core/utils/formatters.dart';
import '../../core/utils/units.dart';
import '../../data/db/database.dart';
import '../../l10n/app_localizations.dart';
import '../../services/district_map.dart';
import '../../services/export_service.dart';
import '../../services/home_widget/offscreen_renderer.dart';
import '../../services/place_network.dart';
import '../../services/settings_service.dart';
import '../vehicles/vehicle_controller.dart';
import 'widgets/route_card_face.dart';

/// Pick two places, see the route, adjust the distance, share a card.
class RoutePlannerController extends GetxController {
  RoutePlannerController(this._vehicles, this._settings, this._export);

  final VehicleController _vehicles;
  final SettingsService _settings;
  final ExportService _export;

  final distanceCtrl = TextEditingController();
  final nameCtrl = TextEditingController();
  final bikeCtrl = TextEditingController();

  /// Enough for a 64-point circle at the card's 2x, with room to crop.
  static const _photoWidth = 320;

  final isLoading = true.obs;
  final isSharing = false.obs;
  final start = RxnString();
  final end = RxnString();
  final route = Rxn<PlaceRoute>();
  final name = ''.obs;
  final bike = ''.obs;
  final photo = Rxn<ui.Image>();

  /// True once the rider has changed the suggested stops.
  final isCustomRoute = false.obs;

  /// Set when the rider has typed their own distance. Null ⇒ the estimate.
  final manualM = RxnInt();

  DistrictMap districts = DistrictMap.empty;
  PlaceNetwork network = PlaceNetwork.empty;

  /// True once the rider has typed a bike name in this session.
  bool _bikeEdited = false;
  bool _fillingBike = false;

  /// Guards the listener against the field being filled in by code.
  bool _fillingDistance = false;

  String get locale => _settings.localeCode.value;
  Fmt get fmt => _vehicles.fmt.value;

  bool get isManual => manualM.value != null;
  int? get distanceM => manualM.value ?? route.value?.estimatedM;

  @override
  void onInit() {
    super.onInit();
    nameCtrl
      ..text = _settings.rideCardUsername.value
      ..addListener(() => name.value = nameCtrl.text.trim());
    name.value = nameCtrl.text.trim();
    distanceCtrl.addListener(_onDistanceEdited);
    bikeCtrl.addListener(() {
      bike.value = bikeCtrl.text.trim();
      if (!_fillingBike) _bikeEdited = true;
    });
    _fillBike();
    // The active bike arrives from the database after this tab is built.
    ever(_vehicles.active, (_) => _fillBike());
    _load();
  }

  @override
  void onClose() {
    distanceCtrl.dispose();
    nameCtrl.dispose();
    bikeCtrl.dispose();
    photo.value?.dispose();
    super.onClose();
  }

  Future<void> _load() async {
    districts = await DistrictMap.load();
    network = await PlaceNetwork.load();
    await _restorePhoto();
    isLoading.value = false;
  }

  /// The saved name wins, then the active bike. Never overwrites typing.
  void _fillBike() {
    if (_bikeEdited) return;
    final text =
        _settings.routeCardBike.value ?? _vehicles.active.value?.name ?? '';
    _fillingBike = true;
    bikeCtrl.text = text;
    _fillingBike = false;
  }

  Future<void> _restorePhoto() async {
    final saved = _settings.routeCardPhoto.value;
    if (saved == null) return;
    try {
      _setPhoto(await _decode(base64Decode(saved)));
    } on Object catch (e) {
      debugPrint('Saved profile photo unreadable: $e');
      _settings.routeCardPhoto.value = null;
    }
  }

  static Future<ui.Image> _decode(Uint8List bytes, {int? width}) async {
    final codec = await ui.instantiateImageCodec(bytes, targetWidth: width);
    final frame = await codec.getNextFrame();
    codec.dispose();
    return frame.image;
  }

  Future<void> pickPhoto(L l) async {
    try {
      final picked = await FilePicker.platform.pickFiles(type: FileType.image);
      final path = picked?.files.single.path;
      if (path == null) return;

      final image = await _decode(
        await File(path).readAsBytes(),
        width: _photoWidth,
      );
      final png = await image.toByteData(format: ui.ImageByteFormat.png);
      _settings.routeCardPhoto.value = base64Encode(png!.buffer.asUint8List());
      _setPhoto(image);
    } on Object catch (e) {
      debugPrint('Profile photo failed: $e');
      Get.snackbar(
        l.routeTitle,
        l.routePhotoFailed,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  void removePhoto() {
    _settings.routeCardPhoto.value = null;
    _setPhoto(null);
  }

  void _setPhoto(ui.Image? image) {
    final old = photo.value;
    photo.value = image;
    old?.dispose();
  }

  void setStart(String? id) {
    start.value = id;
    _recompute();
  }

  void setEnd(String? id) {
    end.value = id;
    _recompute();
  }

  /// Tapping the map: toggles the place closest to the tap.
  void tapMap(double lat, double lng) {
    final place = network.nearest(lat, lng);
    if (place != null) toggleStop(place.id);
  }

  /// Adds a place as a stop, or removes it if already one.
  void toggleStop(String id) {
    final current = route.value;
    final place = network.byId(id);
    if (current == null || place == null) return;
    _edit(
      current.contains(id)
          ? current.removing(network, id)
          : current.adding(network, place),
    );
  }

  void addStop(String? id) {
    if (id != null && route.value?.contains(id) == false) toggleStop(id);
  }

  void removeStop(String id) {
    final current = route.value;
    if (current != null) _edit(current.removing(network, id));
  }

  void moveStop(int from, int to) {
    final current = route.value;
    if (current != null) _edit(current.movingVia(network, from, to));
  }

  /// A distance the rider typed stays put: they are correcting the path of
  /// the same trip. The estimate follows the stops.
  void _edit(PlaceRoute edited) {
    if (identical(edited, route.value)) return;
    route.value = edited;
    isCustomRoute.value = true;
    if (!isManual) _showEstimate();
  }

  /// Back to the computed route, for the same start and end.
  void resetRoute() => _recompute();

  /// A new route starts from a fresh estimate: a distance typed for the old
  /// one says nothing about this one.
  void _recompute() {
    final from = start.value;
    final to = end.value;
    route.value = from == null || to == null
        ? null
        : PlaceRouter.find(network, from, to);
    isCustomRoute.value = false;
    useEstimate();
  }

  /// Drops any typed distance and shows the estimate again.
  void useEstimate() {
    manualM.value = null;
    _showEstimate();
  }

  void _showEstimate() {
    final estimate = route.value?.estimatedM;
    _fillingDistance = true;
    distanceCtrl.text = estimate == null || estimate == 0
        ? ''
        : Units.metresTo(estimate, fmt.distanceUnit).round().toString();
    _fillingDistance = false;
  }

  void _onDistanceEdited() {
    if (_fillingDistance || route.value == null) return;
    final typed = double.tryParse(distanceCtrl.text.replaceAll(',', '').trim());
    if (typed == null || typed <= 0 || !typed.isFinite) {
      manualM.value = null;
      return;
    }
    manualM.value = Units.toMetres(typed, fmt.distanceUnit);
  }

  /// Reactive: reads every observable the preview depends on.
  RouteCardContent content() => RouteCardContent(
    route: route.value,
    distanceM: distanceM,
    isEstimate: !isManual,
    name: name.value,
    bike: bike.value,
    photo: photo.value,
    locale: locale,
    distanceText: distanceM == null ? '' : fmt.distance(distanceM!),
    distanceUnit: _unitLabel(),
  );

  String _unitLabel() => locale == 'bn' && fmt.distanceUnit == DistanceUnit.km
      ? 'কিমি'
      : fmt.distanceLabel;

  Future<void> share(L l) async {
    if (isSharing.value || route.value == null) return;
    isSharing.value = true;
    try {
      _settings.rideCardUsername.value = name.value;
      _settings.routeCardBike.value = bike.value;

      final png = await OffscreenRenderer.toPng(
        child: RouteCardFace(districts: districts, content: content(), l: l),
        size: RouteCardFace.size,
        pixelRatio: RouteCardFace.pixelRatio,
      );
      if (png == null) throw StateError('No view to render with');

      final stamp = DateFormat('yyyy-MM-dd_HHmmss').format(DateTime.now());
      final file = File(
        '${(await getTemporaryDirectory()).path}/jatra_route_$stamp.png',
      );
      await file.writeAsBytes(png);
      await _export.share([file], subject: l.routeTitle);
    } on Object catch (e) {
      debugPrint('Route card failed: $e');
      Get.snackbar(
        l.routeTitle,
        l.routeFailed,
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isSharing.value = false;
    }
  }
}
