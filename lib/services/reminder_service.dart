import 'dart:async';

import 'package:get/get.dart' hide Value;

import '../core/calc/service_predictor.dart';
import '../core/utils/clock.dart';
import '../core/utils/formatters.dart';
import '../data/db/database.dart';
import '../data/repositories/expense_repo.dart';
import '../data/repositories/fuel_repo.dart';
import '../data/repositories/reminder_repo.dart';
import '../data/repositories/service_repo.dart';
import '../data/repositories/vehicle_repo.dart';
import 'notification_service.dart';
import 'settings_service.dart';
import '../core/utils/l10n.dart';
import '../core/utils/enum_labels.dart';

/// Turns predicted service due points and document expiries into reminder
/// rows and local notifications.
///
/// Reminders are *derived* state. This runs on app launch and after any entry
/// that carries an odometer reading, exactly as the spec requires, and is
/// idempotent: running it twice changes nothing and re-notifies nobody.
class ReminderService extends GetxService {
  ReminderService({
    required this.vehicles,
    required this.service,
    required this.fuel,
    required this.expenses,
    required this.reminders,
    required this.notifications,
    required this.settings,
  });

  final VehicleRepo vehicles;
  final ServiceRepo service;
  final FuelRepo fuel;
  final ExpenseRepo expenses;
  final ReminderRepo reminders;
  final NotificationService notifications;
  final SettingsService settings;

  /// How far ahead a document expiry starts being worth mentioning.
  static const documentNoticeDays = 45;

  bool _running = false;

  @override
  void onReady() {
    super.onReady();
    // "Recompute on app launch", per the spec. `onReady` fires after the
    // first frame, so a slow first recompute never delays the UI appearing.
    unawaited(recomputeAll());
  }

  /// Recomputes for every vehicle. Called on launch.
  Future<void> recomputeAll() async {
    // Guard against overlapping runs: a launch recompute and a
    // save-triggered one arriving together would both write the same rows.
    if (_running) return;
    _running = true;
    try {
      for (final vehicle in await vehicles.getAll(includeArchived: false)) {
        await _recomputeVehicle(vehicle);
      }
    } finally {
      _running = false;
    }
  }

  /// Recomputes for one vehicle. Called after a fill, a service log or a
  /// ride — anything that moves the odometer.
  Future<void> recompute(int vehicleId) async {
    if (_running) return;
    _running = true;
    try {
      final vehicle = await vehicles.getById(vehicleId);
      if (vehicle != null) await _recomputeVehicle(vehicle);
    } finally {
      _running = false;
    }
  }

  Future<void> _recomputeVehicle(VehicleRow vehicle) async {
    final fmt = Fmt(
      distanceUnit: vehicle.distanceUnit,
      volumeUnit: vehicle.volumeUnit,
      currency: vehicle.currency,
    );

    final currentOdometerM = await fuel.latestOdometerM(vehicle.id);
    final observations = await fuel.odometerObservations(vehicle.id);
    final rate = ServicePredictor.dailyMetres(observations);

    final plan = ServicePredictor.plan(
      await service.getItems(vehicle.id),
      currentOdometerM: currentOdometerM,
      dailyMetresEstimate: rate,
    );

    for (final due in plan) {
      await _syncServiceReminder(vehicle, due, fmt);
    }

    for (final document in await expenses.expiringDocuments(
      vehicle.id,
      withinDays: documentNoticeDays,
    )) {
      await _syncDocumentReminder(vehicle, document, fmt);
    }
  }

  // -------------------------------------------------------------------
  // Service items
  // -------------------------------------------------------------------

  Future<void> _syncServiceReminder(
    VehicleRow vehicle,
    ServiceDue due,
    Fmt fmt,
  ) async {
    final existing = await reminders.findBySource(
      vehicleId: vehicle.id,
      type: ReminderType.service,
      sourceId: due.item.id,
    );

    // Back in the clear — a service was logged, or the interval was edited.
    // Withdraw the reminder and its pending notification.
    if (!due.needsAttention) {
      if (existing != null) {
        await notifications.cancel(existing.id);
        await reminders.softDeleteForSource(
          type: ReminderType.service,
          sourceId: due.item.id,
        );
      }
      return;
    }

    // The due point moving forward means a new cycle, so a reminder the user
    // dismissed last time deserves to speak again.
    final movedOn =
        existing != null &&
        (existing.dueOdometerM != due.dueOdometerM ||
            existing.dueDateMs != due.dueDateMs);

    final id = await reminders.upsertForSource(
      vehicleId: vehicle.id,
      type: ReminderType.service,
      sourceId: due.item.id,
      title: due.item.name,
      dueDateMs: due.dueDateMs,
      dueOdometerM: due.dueOdometerM,
    );

    if (movedOn && (existing.isDismissed || existing.notifiedAtMs != null)) {
      // Only reset when the change is a genuine new cycle rather than the
      // estimated date drifting by a day, which happens on every recompute.
      final driftOnly = existing.dueOdometerM == due.dueOdometerM;
      if (!driftOnly) await reminders.reactivate(id);
    }

    await _notifyOnce(
      id: id,
      vehicleName: vehicle.name,
      title: l10n.reminderServiceTitle(
        due.item.name,
        due.status.labelOf(l10n).toLowerCase(),
      ),
      body: _serviceBody(vehicle, due, fmt),
      whenMs: due.dueDateMs,
      isPastDue: due.isPastDue,
    );
  }

  String _serviceBody(VehicleRow vehicle, ServiceDue due, Fmt fmt) {
    final parts = <String>[];

    if (due.dueOdometerM != null) {
      parts.add(
        'Due at ${fmt.distance(due.dueOdometerM!)} '
        '${fmt.distanceLabel.toLowerCase()}',
      );
    }
    if (due.dueDateMs != null) {
      final when = relativeDayOf(l10n, due.dueDateMs!);
      parts.add(due.dueDateIsEstimate ? 'roughly $when' : when);
    }

    final detail = parts.isEmpty ? '' : ' · ${parts.join(', ')}';
    return '${vehicle.name}$detail';
  }

  // -------------------------------------------------------------------
  // Document expiry
  // -------------------------------------------------------------------

  Future<void> _syncDocumentReminder(
    VehicleRow vehicle,
    ExpenseRow document,
    Fmt fmt,
  ) async {
    final expiresMs = document.validUntilMs;
    if (expiresMs == null) return;

    final id = await reminders.upsertForSource(
      vehicleId: vehicle.id,
      type: ReminderType.documentExpiry,
      sourceId: document.id,
      title: document.category.label,
      dueDateMs: expiresMs,
    );

    final expired = expiresMs <= Clock.nowMs;

    await _notifyOnce(
      id: id,
      vehicleName: vehicle.name,
      title: expired
          ? '${document.category.label} has expired'
          : '${document.category.labelOf(l10n)} expires '
                '${relativeDayOf(l10n, expiresMs)}',
      body: '${vehicle.name} · ${fmt.date(expiresMs)}',
      // Fire a fortnight ahead, not on the day — renewing a fitness
      // certificate is not a same-day errand.
      whenMs: Dates.addDays(expiresMs, -14),
      isPastDue: expired,
    );
  }

  // -------------------------------------------------------------------
  // Notification dispatch
  // -------------------------------------------------------------------

  /// Posts or schedules at most once per reminder cycle.
  ///
  /// Without the `notifiedAtMs` gate, recomputing on every launch would
  /// re-announce everything overdue each time the app opened — the fastest
  /// way to get a rider to turn reminders off for good.
  Future<void> _notifyOnce({
    required int id,
    required String vehicleName,
    required String title,
    required String body,
    required int? whenMs,
    required bool isPastDue,
  }) async {
    if (!settings.notificationsEnabled.value) return;
    if (!notifications.isAuthorised.value) return;

    final current = await reminders.byId(id);
    if (current == null || current.isDismissed) return;
    if (current.notifiedAtMs != null) return;

    if (isPastDue) {
      await notifications.showNow(id: id, title: title, body: body);
    } else if (whenMs != null) {
      await notifications.schedule(
        id: id,
        title: title,
        body: body,
        whenMs: whenMs,
      );
    } else {
      // No date to schedule against — a distance-based item on a bike with
      // too little history to project from. Say it now rather than never.
      await notifications.showNow(id: id, title: title, body: body);
    }

    await reminders.markNotified(id);
  }
}
