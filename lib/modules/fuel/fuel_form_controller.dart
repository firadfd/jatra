import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:get/get.dart' hide Value;

import '../../app/routes/app_routes.dart';
import '../../core/utils/clock.dart';
import '../../core/utils/formatters.dart';
import '../../core/utils/money.dart';
import '../../core/utils/units.dart';
import '../../data/db/database.dart';
import '../../data/repositories/fuel_repo.dart';
import '../../services/reminder_service.dart';
import '../vehicles/vehicle_controller.dart';

/// Which of the three interdependent money fields was touched. The two most
/// recently touched are authoritative; the third is computed from them.
enum _Trio { volume, price, total }

/// Add / edit a refuel.
///
/// The most-used screen in the app, so it is the one optimised hardest:
/// every field pre-fills with the most likely value, any two of
/// {volume, price, total} fill in the third, and nothing is lost to a
/// rotation because all the state lives on the controller.
class FuelFormController extends GetxController {
  FuelFormController(this._repo, this._vehicles, this._reminders);

  final FuelRepo _repo;
  final VehicleController _vehicles;
  final ReminderService _reminders;

  final formKey = GlobalKey<FormState>();

  final odometerCtrl = TextEditingController();
  final volumeCtrl = TextEditingController();
  final priceCtrl = TextEditingController();
  final totalCtrl = TextEditingController();
  final stationCtrl = TextEditingController();
  final notesCtrl = TextEditingController();

  final dateMs = Clock.nowMs.obs;
  final isFullTank = true.obs;
  final isMissedEntry = false.obs;

  final isLoading = true.obs;
  final isSaving = false.obs;

  /// Highest reading already recorded, from fuel entries, service logs and
  /// rides. The odometer field pre-fills with it and validates against it.
  final previousOdometerM = 0.obs;

  /// Set once the user confirms a reading that goes backwards — a replaced
  /// cluster, or a digit misread last time.
  final odometerOverridden = false.obs;

  /// A non-blocking note shown after saving, e.g. a fill larger than the
  /// tank. Warnings never stop a save; the rider is standing at a pump.
  final warning = RxnString();

  int? editId;
  bool get isEditing => editId != null;

  Fmt get fmt => _vehicles.fmt.value;
  int get _vehicleId => _vehicles.activeId;
  int? get _tankCapacityMl => _vehicles.active.value?.tankCapacityMl;

  /// Most recently touched first. Seeded so that a user who types a volume
  /// into a form with a pre-filled price gets the total computed, which is
  /// the overwhelmingly common path.
  final _recent = <_Trio>[_Trio.price, _Trio.volume, _Trio.total];

  /// Guards the listeners against the writes they themselves cause.
  bool _recomputing = false;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    editId = args is Map ? args[RouteArgs.editId] as int? : null;

    volumeCtrl.addListener(() => _onEdited(_Trio.volume));
    priceCtrl.addListener(() => _onEdited(_Trio.price));
    totalCtrl.addListener(() => _onEdited(_Trio.total));

    _load();
  }

  @override
  void onClose() {
    for (final c in [
      odometerCtrl,
      volumeCtrl,
      priceCtrl,
      totalCtrl,
      stationCtrl,
      notesCtrl,
    ]) {
      c.dispose();
    }
    super.onClose();
  }

  // -------------------------------------------------------------------
  // Loading and pre-fill
  // -------------------------------------------------------------------

  Future<void> _load() async {
    previousOdometerM.value = await _repo.latestOdometerM(_vehicleId);

    final id = editId;
    if (id != null) {
      await _loadExisting(id);
    } else {
      await _prefillNew();
    }
    isLoading.value = false;
  }

  Future<void> _loadExisting(int id) async {
    final row = await _repo.getById(id);
    if (row == null) return;

    // Validate against everything *except* this entry, so re-saving an edit
    // does not fail against its own reading.
    final others = (await _repo.getForVehicle(
      _vehicleId,
    )).where((e) => e.id != id).where((e) => e.odometerM < row.odometerM);
    previousOdometerM.value = others.isEmpty
        ? 0
        : others.map((e) => e.odometerM).reduce((a, b) => a > b ? a : b);

    _recomputing = true;
    odometerCtrl.text = _trim(Units.metresTo(row.odometerM, fmt.distanceUnit));
    volumeCtrl.text = Units.mlTo(
      row.volumeMl,
      fmt.volumeUnit,
    ).toStringAsFixed(2);
    totalCtrl.text = Money(row.totalCostMinor).asMajor.toStringAsFixed(2);
    priceCtrl.text =
        (Money(row.totalCostMinor).asMajor /
                Units.mlTo(row.volumeMl, fmt.volumeUnit))
            .toStringAsFixed(2);
    _recomputing = false;

    stationCtrl.text = row.station ?? '';
    notesCtrl.text = row.notes ?? '';
    dateMs.value = row.dateMs;
    isFullTank.value = row.isFullTank;
    isMissedEntry.value = row.isMissedEntry;
  }

  Future<void> _prefillNew() async {
    _recomputing = true;

    // Pre-fill the odometer with the last known reading. If the rider
    // forgets to change it the validator catches it — better than a blank
    // field they have to reconstruct from memory at a pump.
    odometerCtrl.text = _trim(
      Units.metresTo(previousOdometerM.value, fmt.distanceUnit),
    );

    // Price per unit defaults to whatever they paid last time.
    final last = await _repo.latestEntry(_vehicleId);
    if (last != null && last.volumeMl > 0) {
      final perUnit =
          Money(last.totalCostMinor).asMajor /
          Units.mlTo(last.volumeMl, fmt.volumeUnit);
      priceCtrl.text = perUnit.toStringAsFixed(2);
    }

    _recomputing = false;
  }

  // -------------------------------------------------------------------
  // The auto-computing trio
  // -------------------------------------------------------------------

  void _onEdited(_Trio field) {
    if (_recomputing) return;
    _recent
      ..remove(field)
      ..insert(0, field);
    _recompute();
  }

  /// Fills in whichever of the three the user has *not* touched most
  /// recently, from the two they have.
  void _recompute() {
    final target = _recent.last;
    final volume = _parse(volumeCtrl);
    final price = _parse(priceCtrl);
    final total = _parse(totalCtrl);

    String? result;
    switch (target) {
      case _Trio.total:
        if (volume == null || price == null) return;
        result = (volume * price).toStringAsFixed(2);
      case _Trio.price:
        // Guard every division — a zero volume is a half-typed number, not
        // an infinite unit price.
        if (volume == null || total == null || volume <= 0) return;
        result = (total / volume).toStringAsFixed(2);
      case _Trio.volume:
        if (price == null || total == null || price <= 0) return;
        result = (total / price).toStringAsFixed(2);
    }

    final controller = switch (target) {
      _Trio.volume => volumeCtrl,
      _Trio.price => priceCtrl,
      _Trio.total => totalCtrl,
    };

    if (controller.text == result) return;
    _recomputing = true;
    controller.value = TextEditingValue(
      text: result,
      selection: TextSelection.collapsed(offset: result.length),
    );
    _recomputing = false;
  }

  // -------------------------------------------------------------------
  // Validation
  // -------------------------------------------------------------------

  String? validateOdometer(String? value) {
    final raw = value?.replaceAll(',', '').trim() ?? '';
    if (raw.isEmpty) return 'Enter the odometer reading.';
    final parsed = double.tryParse(raw);
    if (parsed == null) return 'Odometer must be a number.';
    if (parsed < 0) return 'Odometer cannot be negative.';

    if (odometerOverridden.value) return null;

    final entered = Units.toMetres(parsed, fmt.distanceUnit);
    if (entered <= previousOdometerM.value && previousOdometerM.value > 0) {
      return 'Odometer must be higher than your last reading of '
          '${fmt.distance(previousOdometerM.value)} '
          '${fmt.distanceLabel.toLowerCase()}.';
    }
    return null;
  }

  String? validateVolume(String? value) {
    final parsed = _parseString(value);
    if (parsed == null) return 'Enter how much fuel you added.';
    if (parsed <= 0) return 'Fuel added must be more than zero.';
    return null;
  }

  String? validateTotal(String? value) {
    final parsed = _parseString(value);
    if (parsed == null) return 'Enter what you paid.';
    if (parsed < 0) return 'Amount cannot be negative.';
    return null;
  }

  /// Lets a genuine correction through — a replaced instrument cluster, or a
  /// digit misread on the previous fill.
  void overrideOdometer() {
    odometerOverridden.value = true;
    formKey.currentState?.validate();
  }

  // -------------------------------------------------------------------
  // Saving
  // -------------------------------------------------------------------

  Future<void> save() async {
    if (!(formKey.currentState?.validate() ?? false)) return;
    if (isSaving.value) return;
    isSaving.value = true;

    try {
      final volumeMl = Units.toMl(_parse(volumeCtrl) ?? 0, fmt.volumeUnit);
      final total = Money.tryParse(totalCtrl.text) ?? Money.zero;
      final odometerM = Units.toMetres(
        _parse(odometerCtrl) ?? 0,
        fmt.distanceUnit,
      );

      // Canonical price is per *litre*, like every other stored quantity.
      // Derived from the exact volume/total pair rather than from the price
      // field, so the two can never disagree by a rounding step.
      final perLitre =
          Money.unitPrice(ml: volumeMl, total: total) ?? Money.zero;

      final companion = FuelEntriesCompanion(
        vehicleId: Value(_vehicleId),
        dateMs: Value(dateMs.value),
        odometerM: Value(odometerM),
        volumeMl: Value(volumeMl),
        pricePerUnitMinor: Value(perLitre.minor),
        totalCostMinor: Value(total.minor),
        isFullTank: Value(isFullTank.value),
        isMissedEntry: Value(isMissedEntry.value),
        station: Value(_text(stationCtrl)),
        notes: Value(_text(notesCtrl)),
      );

      final id = editId;
      if (id == null) {
        await _repo.create(
          companion.copyWith(
            createdAt: const Value(0),
            updatedAt: const Value(0),
          ),
        );
      } else {
        await _repo.update(id, companion);
      }

      // A fill moves the odometer, so service due points and their reminders
      // both need recomputing — "after any odometer-bearing entry".
      await _reminders.recompute(_vehicleId);

      final tank = _tankCapacityMl;
      final overTank = tank != null && tank > 0 && volumeMl > tank;

      Get.back<bool>(result: true);
      Get.snackbar(
        isEditing ? 'Fill updated' : 'Fill saved',
        overTank
            ? 'That is more than the tank holds — edit it if it was a typo.'
            : isFullTank.value
            ? 'Mileage updates on your next full tank.'
            : 'Partial fill. It counts toward your next full tank.',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isSaving.value = false;
    }
  }

  // -------------------------------------------------------------------
  // Helpers
  // -------------------------------------------------------------------

  static double? _parse(TextEditingController c) => _parseString(c.text);

  static double? _parseString(String? value) {
    final raw = value?.replaceAll(',', '').trim() ?? '';
    if (raw.isEmpty) return null;
    final parsed = double.tryParse(raw);
    if (parsed == null || !parsed.isFinite) return null;
    return parsed;
  }

  static String? _text(TextEditingController c) {
    final t = c.text.trim();
    return t.isEmpty ? null : t;
  }

  /// Drops a trailing `.0` so a whole-number odometer reads as `24180`.
  static String _trim(double value) => value == value.roundToDouble()
      ? value.round().toString()
      : value.toStringAsFixed(1);
}
