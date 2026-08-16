import 'dart:io';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart' hide Value;
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

/// Thin wrapper over the local-notification plugin.
///
/// Every notification this app posts is local. There is no push service, no
/// token, no server — a reminder is computed on the device from the device's
/// own data and handed to the system scheduler.
///
/// Nothing here runs until the user switches reminders on. `init` is safe to
/// call regardless; it neither asks for permission nor posts anything.
class NotificationService extends GetxService {
  static const _channelId = 'service_reminders';
  static const _channelName = 'Service reminders';
  static const _channelDescription =
      'Tells you when a service is coming due or a document is about to '
      'expire.';

  final _plugin = FlutterLocalNotificationsPlugin();

  bool _initialised = false;

  /// True once the platform has confirmed notifications are allowed. Read by
  /// the settings and service screens to decide whether to offer the prompt.
  final isAuthorised = false.obs;

  Future<NotificationService> init() async {
    if (_initialised) return this;

    // The timezone database is needed for scheduling. `tz.local` is left as
    // UTC on purpose: resolving the device's IANA zone name would mean
    // another plugin, and every reminder is scheduled from an absolute
    // instant anyway — see [_atInstant].
    tz_data.initializeTimeZones();

    await _plugin.initialize(
      settings: const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        iOS: DarwinInitializationSettings(
          // Asking during initialisation would be a permission prompt the
          // user did not trigger. Requested explicitly, on opt-in, instead.
          requestAlertPermission: false,
          requestBadgePermission: false,
          requestSoundPermission: false,
        ),
      ),
    );

    await _android?.createNotificationChannel(
      const AndroidNotificationChannel(
        _channelId,
        _channelName,
        description: _channelDescription,
        importance: Importance.defaultImportance,
      ),
    );

    _initialised = true;
    await refreshAuthorisation();
    return this;
  }

  AndroidFlutterLocalNotificationsPlugin? get _android => _plugin
      .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin
      >();

  IOSFlutterLocalNotificationsPlugin? get _ios => _plugin
      .resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin
      >();

  Future<void> refreshAuthorisation() async {
    if (!_initialised) {
      isAuthorised.value = false;
      return;
    }
    if (Platform.isAndroid) {
      isAuthorised.value = await _android?.areNotificationsEnabled() ?? false;
    } else {
      // iOS has no cheap "are we allowed" query; assume not until asked.
      isAuthorised.value = isAuthorised.value;
    }
  }

  /// Asks the platform for permission.
  ///
  /// Called at exactly one moment: when the user switches service reminders
  /// on. Never at launch, never speculatively.
  Future<bool> requestPermission() async {
    await init();

    final granted = Platform.isAndroid
        ? await _android?.requestNotificationsPermission() ?? false
        : await _ios?.requestPermissions(
                alert: true,
                badge: true,
                sound: true,
              ) ??
              false;

    isAuthorised.value = granted;
    return granted;
  }

  /// Schedules one reminder for a future instant.
  ///
  /// Uses [AndroidScheduleMode.inexactAllowWhileIdle]: a service due
  /// "sometime this week" does not need to wake the device to the second,
  /// and requesting exact alarms would drag a Play Store declaration along
  /// with it for no benefit to the rider.
  ///
  /// A [whenMs] in the past is silently skipped rather than fired
  /// immediately — recomputing on launch would otherwise re-announce
  /// everything already overdue every time the app opened.
  Future<void> schedule({
    required int id,
    required String title,
    required String body,
    required int whenMs,
  }) async {
    if (!_initialised || !isAuthorised.value) return;

    final when = _atInstant(whenMs);
    if (!when.isAfter(tz.TZDateTime.now(tz.UTC))) return;

    await _plugin.zonedSchedule(
      id: id,
      title: title,
      body: body,
      scheduledDate: when,
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId,
          _channelName,
          channelDescription: _channelDescription,
          importance: Importance.defaultImportance,
          priority: Priority.defaultPriority,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
    );
  }

  /// Posts immediately. Used when a recompute finds something already due —
  /// there is nothing to schedule, the rider needs to know now.
  Future<void> showNow({
    required int id,
    required String title,
    required String body,
  }) async {
    if (!_initialised || !isAuthorised.value) return;

    await _plugin.show(
      id: id,
      title: title,
      body: body,
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId,
          _channelName,
          channelDescription: _channelDescription,
          importance: Importance.defaultImportance,
          priority: Priority.defaultPriority,
        ),
        iOS: DarwinNotificationDetails(),
      ),
    );
  }

  Future<void> cancel(int id) async {
    if (!_initialised) return;
    await _plugin.cancel(id: id);
  }

  Future<void> cancelAll() async {
    if (!_initialised) return;
    await _plugin.cancelAll();
  }

  /// An epoch instant as a zoned time.
  ///
  /// Expressed in UTC rather than the device's civil zone. The scheduler
  /// works from the absolute instant, so the reminder lands at the right
  /// moment either way, and this avoids a dependency purely to learn the
  /// device's IANA timezone name.
  static tz.TZDateTime _atInstant(int ms) =>
      tz.TZDateTime.fromMillisecondsSinceEpoch(tz.UTC, ms);
}
