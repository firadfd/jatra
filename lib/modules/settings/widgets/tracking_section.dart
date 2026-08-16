import 'package:flutter/material.dart';
import 'package:get/get.dart' hide Value;

import '../../../app/theme/app_dimens.dart';
import '../../../app/theme/app_text.dart';
import '../../../app/theme/app_theme.dart';
import '../../../core/widgets/jatra_widgets.dart';
import '../../../l10n/app_localizations.dart';
import '../../../data/models/enums.dart';
import '../../../services/location_service.dart';
import '../../../services/settings_service.dart';

/// Ride tracking mode, and the permission flow behind it.
///
/// The whole point of this widget is *when* it asks. Nothing here runs at
/// launch; the permission request happens at the moment the user picks a
/// mode that needs it, after a plain-language explanation of what it is for.
class TrackingSection extends StatefulWidget {
  const TrackingSection({super.key});

  @override
  State<TrackingSection> createState() => _TrackingSectionState();
}

class _TrackingSectionState extends State<TrackingSection>
    with WidgetsBindingObserver {
  final _settings = Get.find<SettingsService>();
  final _location = Get.find<LocationService>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // Reads the current state without prompting — safe at any time.
    if (_settings.trackingMode.value != TrackingMode.off) {
      _location.check();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // The Android 11+ background grant happens in Settings, not in a dialog,
    // so the answer only arrives when the user comes back.
    if (state == AppLifecycleState.resumed &&
        _settings.trackingMode.value != TrackingMode.off) {
      _location.check();
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.jatra;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionLabel(L.of(context).settingsTracking),
        const SizedBox(height: Gap.sm),
        JatraCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                L.of(context).settingsTrackingBody,
                style: AppText.bodySm.copyWith(color: c.textMuted),
              ),
              const SizedBox(height: Gap.md),
              Obx(
                () => Column(
                  children: [
                    for (final mode in TrackingMode.values)
                      _ModeTile(
                        mode: mode,
                        selected: _settings.trackingMode.value == mode,
                        onTap: () => _select(mode),
                      ),
                  ],
                ),
              ),
              Obx(
                () => _PermissionNotice(
                  mode: _settings.trackingMode.value,
                  state: _location.permission.value,
                  onOpenSettings: _location.openAppSettings,
                  onOpenLocationSettings: _location.openLocationSettings,
                ),
              ),
              Obx(() {
                if (_settings.trackingMode.value == TrackingMode.off) {
                  return const SizedBox.shrink();
                }
                return SwitchListTile.adaptive(
                  contentPadding: EdgeInsets.zero,
                  value: _settings.keepScreenOnDuringRides.value,
                  onChanged: (v) => _settings.keepScreenOnDuringRides.value = v,
                  title: Text(L.of(context).settingsKeepScreenOn),
                  subtitle: Text(
                    L.of(context).settingsKeepScreenOnExplain,
                    style: AppText.caption.copyWith(color: c.textMuted),
                  ),
                );
              }),
            ],
          ),
        ),
      ],
    );
  }

  /// Selecting a mode is what triggers the request — never launch, never a
  /// speculative prompt.
  Future<void> _select(TrackingMode mode) async {
    if (mode == TrackingMode.off) {
      _settings.trackingMode.value = TrackingMode.off;
      return;
    }

    final agreed = await _explain(mode);
    if (!agreed) return;

    final state = mode == TrackingMode.background
        ? await _location.requestBackground()
        : await _location.requestForeground();

    // Falling back rather than leaving a mode selected that cannot work:
    // background asked for but only foreground granted still gives a useful
    // app-open mode, and the notice below explains the shortfall.
    if (mode == TrackingMode.background && !state.allowsBackground) {
      _settings.trackingMode.value = state.allowsForeground
          ? TrackingMode.appOpen
          : TrackingMode.off;
      return;
    }
    if (!state.allowsForeground) {
      _settings.trackingMode.value = TrackingMode.off;
      return;
    }

    _settings.trackingMode.value = mode;
  }

  /// The plain-language explanation, shown *before* the system dialog.
  Future<bool> _explain(TrackingMode mode) async {
    final background = mode == TrackingMode.background;

    final agreed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          background
              ? L.of(context).trackingAskBackgroundTitle
              : L.of(context).trackingAskForegroundTitle,
        ),
        content: Text(
          background
              ? L.of(context).trackingAskBackgroundBody
              : L.of(context).trackingAskForegroundBody,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(L.of(context).actionNotNow),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(L.of(context).actionContinue),
          ),
        ],
      ),
    );
    return agreed ?? false;
  }
}

/// The enum carries English fallbacks for logs and tests; the interface
/// reads these instead, so the data type stays free of presentation.
String _modeLabel(BuildContext context, TrackingMode mode) => switch (mode) {
  TrackingMode.off => L.of(context).trackingOff,
  TrackingMode.appOpen => L.of(context).trackingAppOpen,
  TrackingMode.background => L.of(context).trackingBackground,
};

String _modeDescription(BuildContext context, TrackingMode mode) =>
    switch (mode) {
      TrackingMode.off => L.of(context).trackingOffExplain,
      TrackingMode.appOpen => L.of(context).trackingAppOpenExplain,
      TrackingMode.background => L.of(context).trackingBackgroundExplain,
    };

class _ModeTile extends StatelessWidget {
  const _ModeTile({
    required this.mode,
    required this.selected,
    required this.onTap,
  });

  final TrackingMode mode;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.jatra;

    return Padding(
      padding: const EdgeInsets.only(bottom: Gap.sm),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(Radii.button),
        child: Container(
          padding: const EdgeInsets.all(Gap.md),
          decoration: BoxDecoration(
            color: selected ? c.signalDim.withValues(alpha: 0.3) : null,
            borderRadius: BorderRadius.circular(Radii.button),
            border: Border.all(
              color: selected ? c.signal : c.border,
              width: Dimens.border,
            ),
          ),
          child: Row(
            children: [
              Icon(
                selected
                    ? Icons.radio_button_checked
                    : Icons.radio_button_unchecked,
                size: 20,
                color: selected ? c.signal : c.textMuted,
              ),
              const SizedBox(width: Gap.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          _modeLabel(context, mode),
                          style: AppText.titleMd.copyWith(color: c.textPrimary),
                        ),
                        if (mode == TrackingMode.off) ...[
                          const SizedBox(width: Gap.sm),
                          StatusPill(
                            text: L.of(context).trackingDefault,
                            color: c.textMuted,
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _modeDescription(context, mode),
                      style: AppText.caption.copyWith(color: c.textMuted),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Explains a permission shortfall and offers the only route that fixes it.
///
/// The Android 11+ case matters most: "Allow all the time" simply is not
/// offered in the standard dialog, so asking again would do nothing. The
/// dialog is never looped — the user is sent to Settings and the state is
/// re-checked on resume.
class _PermissionNotice extends StatelessWidget {
  const _PermissionNotice({
    required this.mode,
    required this.state,
    required this.onOpenSettings,
    required this.onOpenLocationSettings,
  });

  final TrackingMode mode;
  final LocationPermissionState state;
  final Future<bool> Function() onOpenSettings;
  final Future<bool> Function() onOpenLocationSettings;

  @override
  Widget build(BuildContext context) {
    final c = context.jatra;

    final ({String message, String action, bool locationSettings})? notice =
        switch ((mode, state)) {
          (TrackingMode.off, _) => null,
          (_, LocationPermissionState.servicesDisabled) => (
            message: L.of(context).trackingServicesDisabled,
            action: L.of(context).trackingOpenLocationSettings,
            locationSettings: true,
          ),
          (_, LocationPermissionState.deniedForever) => (
            message: L.of(context).trackingBlocked,
            action: L.of(context).trackingOpenAppSettings,
            locationSettings: false,
          ),
          (_, LocationPermissionState.denied) => (
            message: L.of(context).trackingNotGranted,
            action: L.of(context).trackingOpenAppSettings,
            locationSettings: false,
          ),
          (TrackingMode.background, LocationPermissionState.whileInUse) => (
            // The Android 11+ reality: this cannot be granted from a dialog.
            message: L.of(context).trackingBackgroundNeedsSettings,
            action: L.of(context).trackingOpenAppSettings,
            locationSettings: false,
          ),
          _ => null,
        };

    if (notice == null) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(top: Gap.sm, bottom: Gap.sm),
      child: Container(
        padding: const EdgeInsets.all(Gap.md),
        decoration: BoxDecoration(
          color: c.dueSoon.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(Radii.button),
          border: Border.all(color: c.dueSoon, width: Dimens.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              notice.message,
              style: AppText.bodySm.copyWith(color: c.textSecondary),
            ),
            const SizedBox(height: Gap.sm),
            OutlinedButton(
              onPressed: () => notice.locationSettings
                  ? onOpenLocationSettings()
                  : onOpenSettings(),
              child: Text(notice.action),
            ),
          ],
        ),
      ),
    );
  }
}
