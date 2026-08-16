import 'package:flutter/material.dart';
import 'package:get/get.dart' hide Value;

import '../../app/routes/app_routes.dart';
import '../../data/db/database.dart';
import '../../services/notification_service.dart';
import '../../services/reminder_service.dart';
import '../../services/settings_service.dart';

class SettingsController extends GetxController {
  SettingsController(
    this.settings,
    this._db,
    this.reminders,
    this._notifications,
  );

  final SettingsService settings;
  final AppDatabase _db;
  final ReminderService reminders;
  final NotificationService _notifications;

  final isWiping = false.obs;

  void setThemeMode(ThemeMode mode) {
    settings.themeMode.value = mode;
    Get.changeThemeMode(mode);
  }

  /// Switches the interface language.
  ///
  /// `Get.updateLocale` rebuilds the whole tree, so every screen picks up the
  /// new strings without a restart.
  void setLocale(String code) {
    settings.localeCode.value = code;
    Get.updateLocale(Locale(code));
  }

  /// Wipes every record and every preference.
  ///
  /// Hard-deletes rather than tombstoning: the user asked for the data to be
  /// gone, and a tombstone is still the data. Preferences are cleared in the
  /// same action so the app genuinely returns to first-launch state, which
  /// means onboarding again.
  Future<void> deleteAllData() async {
    if (isWiping.value) return;
    isWiping.value = true;
    try {
      await _notifications.cancelAll();
      await _db.wipeAll();
      await settings.resetToDefaults();

      // `resetToDefaults` restores the stored values, but GetX keeps its own
      // copy of the active theme and locale — set by [setThemeMode] and
      // [setLocale] and preferred over what GetMaterialApp was built with.
      // Without these two lines a wipe leaves the app showing the old theme
      // and language while settings claim the defaults.
      Get.changeThemeMode(settings.themeMode.value);
      Get.updateLocale(settings.locale);

      Get.offAllNamed(Routes.onboarding);
    } finally {
      isWiping.value = false;
    }
  }
}
