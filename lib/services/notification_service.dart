import 'dart:io';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart' hide Value;
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

import '../app/theme/app_colors.dart';

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

  /// The live ride notification gets a channel of its own.
  ///
  /// Not shared with reminders: they are different kinds of interruption, and
  /// a rider who silences one should not thereby silence the other.
  ///
  /// This exists because geolocator's foreground-service notification cannot
  /// be made visible. It hardcodes `IMPORTANCE_NONE` on its own channel and
  /// recreates it on every service start, and Android only lets an app *lower*
  /// an existing channel's importance — so there is no way to raise it from
  /// Dart. That notification stays, minimised, because Android requires a
  /// foreground service to have one. This is the one the rider actually sees.
  static const _rideChannelId = 'ride_recording';

  /// Reminder notification ids are `reminders` table row ids, which start at 1
  /// and count up. This sits far above anything that table will reach, so the
  /// ride notification can never overwrite a reminder or be overwritten by
  /// one.
  static const _rideNotificationId = 999000001;

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

  /// Makes sure the platform will actually *display* a notification, asking
  /// for permission only if it will not.
  ///
  /// This exists for the ride-recording notification, which is not posted by
  /// this service at all — Android posts it on behalf of the location
  /// foreground service. That distinction is invisible to POST_NOTIFICATIONS:
  /// since Android 13 a foreground service notification is suppressed like any
  /// other when the permission is missing. The service keeps running and the
  /// ride keeps recording, but the rider is given no sign of it, which is the
  /// one thing a background recorder must never do.
  ///
  /// Returns whether notifications will be shown. Callers should not treat
  /// `false` as a failure worth stopping for: an unseen notification is a
  /// worse ride, not a broken one.
  Future<bool> ensureAllowed() async {
    await init();
    await refreshAuthorisation();
    if (isAuthorised.value) return true;
    return requestPermission();
  }

  /// Asks the platform for permission.
  ///
  /// Called at two moments, both of them things the user just did: switching
  /// service reminders on, and starting a ride (via [ensureAllowed]). Never at
  /// launch, never speculatively.
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

  // -------------------------------------------------------------------
  // The live ride notification
  // -------------------------------------------------------------------

  /// Name the ride channel was last created with, so a locale change
  /// re-registers it instead of leaving an English label on a Bangla phone.
  String? _rideChannelName;

  /// Posts or updates the "recording your ride" notification.
  ///
  /// Called on every accepted GPS point, so two things matter:
  ///
  /// * `onlyAlertOnce` — the channel is loud enough to announce the *start* of
  ///   a ride, and would otherwise chime every few seconds for the rest of it.
  /// * `usesChronometer` — Android ticks the elapsed time itself from [startedAtMs].
  ///   The alternative is re-posting once a second purely to advance a clock.
  ///   Switched off when paused, where a running timer would be a lie.
  Future<void> showRideProgress({
    required String channelName,
    required String title,
    required String body,
    required int startedAtMs,
    required bool paused,
  }) async {
    if (!_initialised || !isAuthorised.value) return;

    await _ensureRideChannel(channelName);

    await _plugin.show(
      id: _rideNotificationId,
      title: title,
      body: body,
      notificationDetails: NotificationDetails(
        android: AndroidNotificationDetails(
          _rideChannelId,
          channelName,
          importance: Importance.defaultImportance,
          priority: Priority.defaultPriority,
          // Survives a swipe. A ride ends with Finish, not with a gesture
          // that leaves it recording invisibly.
          ongoing: true,
          autoCancel: false,
          onlyAlertOnce: true,
          usesChronometer: !paused,
          when: startedAtMs,
          showWhen: true,
          category: AndroidNotificationCategory.workout,
          color: Palette.signal,
        ),
        iOS: const DarwinNotificationDetails(
          // iOS has no ongoing notification, so this is a single quiet post
          // rather than a live tile. Better than nothing, and not worth
          // pretending otherwise.
          presentSound: false,
        ),
      ),
    );
  }

  /// Clears the ride notification. Safe to call when none is showing.
  Future<void> cancelRideProgress() async {
    if (!_initialised) return;
    await _plugin.cancel(id: _rideNotificationId);
  }

  Future<void> _ensureRideChannel(String name) async {
    if (_rideChannelName == name) return;

    await _android?.createNotificationChannel(
      AndroidNotificationChannel(
        _rideChannelId,
        name,
        // Default rather than low: the point of this notification is that
        // geolocator's is inaudible and has no status-bar icon. Low would
        // reproduce the problem it exists to solve.
        importance: Importance.defaultImportance,
      ),
    );
    _rideChannelName = name;
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
