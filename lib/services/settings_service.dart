import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import '../data/models/enums.dart';

/// App preferences.
///
/// `get_storage` holds *settings only* — never records. Anything that is
/// user data lives in SQLite, where it can be exported, imported and backed
/// up. If a value here is lost, the app still knows everything about the
/// user's bike.
class SettingsService extends GetxService {
  static const _boxName = 'odo_settings';

  late final GetStorage _box;

  // --- Keys ---
  static const _kThemeMode = 'themeMode';
  static const _kLocale = 'locale';
  static const _kActiveVehicleId = 'activeVehicleId';
  static const _kOnboardingComplete = 'onboardingComplete';
  static const _kMileageDropThreshold = 'mileageDropThreshold';
  static const _kTrackingMode = 'trackingMode';
  static const _kKeepScreenOn = 'keepScreenOnDuringRides';
  static const _kNotificationsEnabled = 'notificationsEnabled';
  static const _kIncludeRidePointsInExport = 'includeRidePointsInExport';
  static const _kPrettyPrintExport = 'prettyPrintExport';
  static const _kDefaultDepreciationPercent = 'defaultDepreciationPercent';
  static const _kAutoBackupFolderUri = 'autoBackupFolderUri';
  static const _kAutoBackupFolderLabel = 'autoBackupFolderLabel';
  static const _kAutoBackupLastMs = 'autoBackupLastMs';
  static const _kAutoBackupFailure = 'autoBackupFailure';
  static const _kRideCardUsername = 'rideCardUsername';
  static const _kRouteCardBike = 'routeCardBike';
  static const _kRouteCardPhoto = 'routeCardPhoto';

  Future<SettingsService> init() async {
    await GetStorage.init(_boxName);
    _box = GetStorage(_boxName);

    themeMode.value = ThemeMode.values.byName(
      _box.read<String>(_kThemeMode) ?? ThemeMode.dark.name,
    );
    localeCode.value = _box.read<String>(_kLocale) ?? 'en';
    activeVehicleId.value = _box.read<int>(_kActiveVehicleId) ?? 0;
    onboardingComplete.value = _box.read<bool>(_kOnboardingComplete) ?? false;
    mileageDropThreshold.value = _box.read<int>(_kMileageDropThreshold) ?? 12;
    trackingMode.value = _readTrackingMode();
    keepScreenOnDuringRides.value = _box.read<bool>(_kKeepScreenOn) ?? false;
    notificationsEnabled.value =
        _box.read<bool>(_kNotificationsEnabled) ?? false;
    includeRidePointsInExport.value =
        _box.read<bool>(_kIncludeRidePointsInExport) ?? false;
    prettyPrintExport.value = _box.read<bool>(_kPrettyPrintExport) ?? true;
    defaultDepreciationPercent.value =
        _box.read<double>(_kDefaultDepreciationPercent) ?? 12.0;
    autoBackupFolderUri.value = _box.read<String>(_kAutoBackupFolderUri);
    autoBackupFolderLabel.value = _box.read<String>(_kAutoBackupFolderLabel);
    autoBackupLastMs.value = _box.read<int>(_kAutoBackupLastMs);
    autoBackupFailure.value = _box.read<String>(_kAutoBackupFailure);
    rideCardUsername.value = _box.read<String>(_kRideCardUsername) ?? '';
    routeCardBike.value = _box.read<String>(_kRouteCardBike);
    routeCardPhoto.value = _box.read<String>(_kRouteCardPhoto);

    // Persist on change, so no caller has to remember to save.
    ever(themeMode, (v) => _box.write(_kThemeMode, v.name));
    ever(localeCode, (v) => _box.write(_kLocale, v));
    ever(activeVehicleId, (v) => _box.write(_kActiveVehicleId, v));
    ever(onboardingComplete, (v) => _box.write(_kOnboardingComplete, v));
    ever(mileageDropThreshold, (v) => _box.write(_kMileageDropThreshold, v));
    ever(trackingMode, (v) => _box.write(_kTrackingMode, v.name));
    ever(keepScreenOnDuringRides, (v) => _box.write(_kKeepScreenOn, v));
    ever(notificationsEnabled, (v) => _box.write(_kNotificationsEnabled, v));
    ever(
      includeRidePointsInExport,
      (v) => _box.write(_kIncludeRidePointsInExport, v),
    );
    ever(prettyPrintExport, (v) => _box.write(_kPrettyPrintExport, v));
    ever(
      defaultDepreciationPercent,
      (v) => _box.write(_kDefaultDepreciationPercent, v),
    );
    ever(autoBackupFolderUri, (v) => _box.write(_kAutoBackupFolderUri, v));
    ever(autoBackupFolderLabel, (v) => _box.write(_kAutoBackupFolderLabel, v));
    ever(autoBackupLastMs, (v) => _box.write(_kAutoBackupLastMs, v));
    ever(autoBackupFailure, (v) => _box.write(_kAutoBackupFailure, v));
    ever(rideCardUsername, (v) => _box.write(_kRideCardUsername, v));
    ever(routeCardBike, (v) => _box.write(_kRouteCardBike, v));
    ever(routeCardPhoto, (v) => _box.write(_kRouteCardPhoto, v));

    return this;
  }

  TrackingMode _readTrackingMode() =>
      trackingModeFromStored(_box.read<String>(_kTrackingMode));

  /// Maps a stored tracking-mode name to a value this build has, tolerating
  /// names it no longer does.
  ///
  /// `appOpen` was removed once recording moved to a foreground service for
  /// every ride. An install storing it had tracking deliberately switched
  /// **on**, so it maps to [TrackingMode.background] rather than silently
  /// turning a rider's tracking off on upgrade. `byName` would throw on it,
  /// which where this is called — partway through `init` — would take the
  /// whole launch down.
  ///
  /// Static and pure so the upgrade path is testable without a storage box.
  static TrackingMode trackingModeFromStored(String? stored) {
    if (stored == null) return TrackingMode.off;
    if (stored == 'appOpen') return TrackingMode.background;
    return TrackingMode.values.asNameMap()[stored] ?? TrackingMode.off;
  }

  /// Dark is the default: this app is used at dusk, in a garage, at a fuel
  /// pump.
  final themeMode = ThemeMode.dark.obs;

  final localeCode = 'en'.obs;

  /// 0 ⇒ none selected yet.
  final activeVehicleId = 0.obs;

  final onboardingComplete = false.obs;

  /// Percent drop against the rolling median that triggers the mileage
  /// warning card. 0 ⇒ off.
  final mileageDropThreshold = 12.obs;

  /// Off by default. The app is fully usable by someone who never grants
  /// location permission.
  final trackingMode = TrackingMode.off.obs;

  final keepScreenOnDuringRides = false.obs;

  /// Opt-in. `true` here means the user asked for reminders *and* the
  /// platform permission was granted — never a default that would have Jatra
  /// asking for POST_NOTIFICATIONS on first launch.
  final notificationsEnabled = false.obs;

  /// GPS points dominate backup file size, so they are opt-in.
  final includeRidePointsInExport = false.obs;
  final prettyPrintExport = true.obs;

  /// Annual straight-line depreciation used when a vehicle has no
  /// `currentValueEstimate`.
  final defaultDepreciationPercent = 12.0.obs;

  /// Android tree URI of the automatic backup folder. Null ⇒ feature off.
  final autoBackupFolderUri = RxnString();
  final autoBackupFolderLabel = RxnString();
  final autoBackupLastMs = RxnInt();

  /// An `AutoBackupFailure` name, or null when the last attempt succeeded.
  final autoBackupFailure = RxnString();

  /// Remembered so the rider types it once. Empty ⇒ left off the card.
  final rideCardUsername = ''.obs;

  /// Bike name on route cards. Null ⇒ the active bike. Empty ⇒ left off.
  final routeCardBike = RxnString();

  /// Small base64 PNG of the rider's profile photo. Kept here rather than as
  /// a file so "delete all data" takes it along with the rest.
  final routeCardPhoto = RxnString();

  bool get mileageAlertEnabled => mileageDropThreshold.value > 0;

  Locale get locale => Locale(localeCode.value);

  void setActiveVehicle(int id) => activeVehicleId.value = id;

  /// Clears preferences only. Records are removed separately, through the
  /// database, so the two can never half-succeed.
  Future<void> resetToDefaults() async {
    await _box.erase();
    themeMode.value = ThemeMode.dark;
    localeCode.value = 'en';
    activeVehicleId.value = 0;
    onboardingComplete.value = false;
    mileageDropThreshold.value = 12;
    trackingMode.value = TrackingMode.off;
    keepScreenOnDuringRides.value = false;
    notificationsEnabled.value = false;
    includeRidePointsInExport.value = false;
    prettyPrintExport.value = true;
    defaultDepreciationPercent.value = 12.0;
    autoBackupFolderUri.value = null;
    autoBackupFolderLabel.value = null;
    autoBackupLastMs.value = null;
    autoBackupFailure.value = null;
    rideCardUsername.value = '';
    routeCardBike.value = null;
    routeCardPhoto.value = null;
  }
}
