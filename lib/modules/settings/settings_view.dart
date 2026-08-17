import 'package:flutter/material.dart';
import 'package:get/get.dart' hide Value;

import '../../app/routes/app_routes.dart';
import '../../app/theme/app_dimens.dart';
import '../../app/theme/app_text.dart';
import '../../app/theme/app_theme.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/jatra_widgets.dart';
import '../../l10n/app_localizations.dart';
import '../../data/repositories/ride_repo.dart';
import '../../services/notification_service.dart';
import 'widgets/map_cache_section.dart';
import 'widgets/tracking_section.dart';
import 'settings_controller.dart';

class SettingsView extends GetView<SettingsController> {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(L.of(context).settingsTitle)),
      body: ContentColumn(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(Gap.md, Gap.md, Gap.md, Gap.xl),
          children: const [
            _PrivacyCard(),
            SizedBox(height: Gap.lg),
            _AppearanceSection(),
            SizedBox(height: Gap.lg),
            _LanguageSection(),
            SizedBox(height: Gap.lg),
            _MileageAlertSection(),
            SizedBox(height: Gap.lg),
            _NotificationSection(),
            SizedBox(height: Gap.lg),
            _DepreciationSection(),
            SizedBox(height: Gap.lg),
            TrackingSection(),
            SizedBox(height: Gap.lg),
            // Directly after tracking: the map is what tracking produces, and
            // its storage is the question that follows from using it.
            MapCacheSection(),
            SizedBox(height: Gap.lg),
            _BikesSection(),
            SizedBox(height: Gap.lg),
            _DataSection(),
            SizedBox(height: Gap.lg),
            _AboutSection(),
          ],
        ),
      ),
    );
  }
}

/// The promise, stated in the UI as the brief requires — not buried in a
/// policy screen nobody opens.
class _PrivacyCard extends StatelessWidget {
  const _PrivacyCard();

  @override
  Widget build(BuildContext context) {
    final c = context.jatra;
    return JatraCard(
      accent: c.signal,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.lock_outline, size: 20, color: c.signal),
          const SizedBox(width: Gap.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  L.of(context).settingsPrivacyTitle,
                  style: AppText.titleMd.copyWith(color: c.textPrimary),
                ),
                const SizedBox(height: Gap.xs),
                Text(
                  L.of(context).settingsPrivacyBody,
                  style: AppText.bodySm.copyWith(color: c.textMuted),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AppearanceSection extends GetView<SettingsController> {
  const _AppearanceSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionLabel(L.of(context).settingsAppearance),
        const SizedBox(height: Gap.sm),
        JatraCard(
          child: Obx(
            () => SegmentedButton<ThemeMode>(
              segments: [
                ButtonSegment(
                  value: ThemeMode.dark,
                  label: Text(L.of(context).settingsThemeDark),
                ),
                ButtonSegment(
                  value: ThemeMode.light,
                  label: Text(L.of(context).settingsThemeLight),
                ),
                ButtonSegment(
                  value: ThemeMode.system,
                  label: Text(L.of(context).settingsThemeSystem),
                ),
              ],
              selected: {controller.settings.themeMode.value},
              onSelectionChanged: (s) => controller.setThemeMode(s.first),
            ),
          ),
        ),
      ],
    );
  }
}

/// Interface language.
///
/// Numbers stay in Latin digits in both languages — see [Fmt.numberLocale]
/// for why. Month names and all prose translate.
class _LanguageSection extends GetView<SettingsController> {
  const _LanguageSection();

  static const _languages = <({String code, String label})>[
    (code: 'en', label: 'English'),
    (code: 'bn', label: 'বাংলা'),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionLabel(L.of(context).settingsLanguage),
        const SizedBox(height: Gap.sm),
        JatraCard(
          child: Obx(
            () => SegmentedButton<String>(
              segments: [
                for (final language in _languages)
                  ButtonSegment(
                    value: language.code,
                    label: Text(language.label),
                  ),
              ],
              selected: {controller.settings.localeCode.value},
              onSelectionChanged: (s) => controller.setLocale(s.first),
            ),
          ),
        ),
      ],
    );
  }
}

/// How far mileage has to fall before Jatra says something.
///
/// Configurable because tank-to-tank variation differs enormously between a
/// city commuter and someone doing highway runs — one threshold cannot suit
/// both, and a warning that cries wolf gets switched off entirely.
class _MileageAlertSection extends GetView<SettingsController> {
  const _MileageAlertSection();

  /// 0 is "off" and is rendered as such.
  static const _options = [0, 10, 12, 15, 20];

  @override
  Widget build(BuildContext context) {
    final c = context.jatra;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionLabel(L.of(context).settingsMileageAlert),
        const SizedBox(height: Gap.sm),
        JatraCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                L.of(context).settingsMileageAlertPrompt,
                style: AppText.bodySm.copyWith(color: c.textSecondary),
              ),
              const SizedBox(height: Gap.md),
              Obx(
                () => Wrap(
                  spacing: Gap.sm,
                  runSpacing: Gap.sm,
                  children: [
                    for (final option in _options)
                      ChoiceChip(
                        label: Text(
                          option == 0
                              ? L.of(context).settingsMileageAlertOff
                              : '$option%',
                        ),
                        selected:
                            controller.settings.mileageDropThreshold.value ==
                            option,
                        onSelected: (_) =>
                            controller.settings.mileageDropThreshold.value =
                                option,
                      ),
                  ],
                ),
              ),
              const SizedBox(height: Gap.sm),
              Obx(
                () => Text(
                  controller.settings.mileageAlertEnabled
                      ? 'Compared against the median of your last five '
                            'reliable tanks, so one unusual week does not '
                            'trigger it.'
                      : 'Jatra will not comment on mileage changes.',
                  style: AppText.caption.copyWith(color: c.textMuted),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Service and document reminders.
///
/// Switching this on is the only thing in the whole app that asks for an
/// Android permission, and it asks at that moment — never at launch.
class _NotificationSection extends GetView<SettingsController> {
  const _NotificationSection();

  @override
  Widget build(BuildContext context) {
    final c = context.jatra;
    final notifications = Get.find<NotificationService>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionLabel(L.of(context).settingsReminders),
        const SizedBox(height: Gap.sm),
        JatraCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Obx(
                () => SwitchListTile.adaptive(
                  contentPadding: EdgeInsets.zero,
                  value:
                      controller.settings.notificationsEnabled.value &&
                      notifications.isAuthorised.value,
                  onChanged: (wanted) async {
                    if (!wanted) {
                      controller.settings.notificationsEnabled.value = false;
                      await notifications.cancelAll();
                      return;
                    }
                    final granted =
                        notifications.isAuthorised.value ||
                        await notifications.requestPermission();
                    controller.settings.notificationsEnabled.value = granted;
                    if (granted) await controller.reminders.recomputeAll();
                  },
                  title: Text(L.of(context).settingsRemindersTitle),
                  subtitle: Text(
                    'Posted on this phone, worked out from your own log. '
                    'Nothing is sent anywhere.',
                    style: AppText.bodySm.copyWith(color: c.textMuted),
                  ),
                ),
              ),
              Obx(() {
                final blocked =
                    controller.settings.notificationsEnabled.value &&
                    !notifications.isAuthorised.value;
                if (!blocked) return const SizedBox.shrink();
                return Padding(
                  padding: const EdgeInsets.only(top: Gap.sm),
                  child: Text(
                    'Notifications are switched off for Jatra in your Android '
                    'settings. Turn them back on there and this will start '
                    'working again.',
                    style: AppText.caption.copyWith(color: c.dueSoon),
                  ),
                );
              }),
            ],
          ),
        ),
      ],
    );
  }
}

/// The fallback annual depreciation rate.
///
/// Only used for bikes with a purchase price but no current-value estimate.
/// A bike that has one depreciates on the straight line between the two.
class _DepreciationSection extends GetView<SettingsController> {
  const _DepreciationSection();

  static const _options = [8.0, 10.0, 12.0, 15.0, 20.0];

  @override
  Widget build(BuildContext context) {
    final c = context.jatra;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionLabel(L.of(context).settingsDepreciation),
        const SizedBox(height: Gap.sm),
        JatraCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                L.of(context).settingsDepreciationPrompt,
                style: AppText.bodySm.copyWith(color: c.textSecondary),
              ),
              const SizedBox(height: Gap.md),
              Obx(
                () => Wrap(
                  spacing: Gap.sm,
                  runSpacing: Gap.sm,
                  children: [
                    for (final option in _options)
                      ChoiceChip(
                        label: Text('${option.toStringAsFixed(0)}%'),
                        selected:
                            controller
                                .settings
                                .defaultDepreciationPercent
                                .value ==
                            option,
                        onSelected: (_) =>
                            controller
                                    .settings
                                    .defaultDepreciationPercent
                                    .value =
                                option,
                      ),
                  ],
                ),
              ),
              const SizedBox(height: Gap.sm),
              Text(
                'Only used for bikes with no current-value estimate. True '
                'cost per kilometre is always an estimate.',
                style: AppText.caption.copyWith(color: c.textMuted),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _BikesSection extends StatelessWidget {
  const _BikesSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionLabel(L.of(context).settingsBikes),
        const SizedBox(height: Gap.sm),
        JatraCard(
          padding: EdgeInsets.zero,
          child: ListTile(
            title: Text(L.of(context).settingsManageBikes),
            subtitle: Text(L.of(context).settingsManageBikesBody),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Get.toNamed(Routes.vehicles),
          ),
        ),
      ],
    );
  }
}

class _DataSection extends GetView<SettingsController> {
  const _DataSection();

  @override
  Widget build(BuildContext context) {
    final c = context.jatra;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionLabel(L.of(context).settingsData),
        const SizedBox(height: Gap.sm),
        const _LocationHistoryTile(),
        const SizedBox(height: Gap.sm),
        JatraCard(
          padding: EdgeInsets.zero,
          child: ListTile(
            title: Text(L.of(context).settingsBackup),
            subtitle: Text(L.of(context).settingsBackupBody),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Get.toNamed(Routes.backup),
          ),
        ),
        const SizedBox(height: Gap.sm),
        JatraCard(
          padding: EdgeInsets.zero,
          child: ListTile(
            title: Text(
              L.of(context).settingsDeleteAll,
              style: AppText.titleMd.copyWith(color: c.danger),
            ),
            subtitle: Text(L.of(context).settingsDeleteAllBody),
            onTap: () => _confirm(context),
          ),
        ),
      ],
    );
  }

  Future<void> _confirm(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(L.of(context).settingsDeleteAllTitle),
        content: const Text(
          'This removes every bike, fuel entry, service log, expense and '
          'ride from this phone, and resets your settings. It cannot be '
          'undone.\n\nExport a backup first if there is any chance you want '
          'this data back.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(L.of(context).settingsKeepMyData),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: context.jatra.danger),
            child: Text(L.of(context).settingsDeleteEverything),
          ),
        ],
      ),
    );
    if (confirmed ?? false) await controller.deleteAllData();
  }
}

/// Deletes recorded GPS paths while keeping the ride summaries that
/// statistics depend on. A separate, gentler action than "delete all data" —
/// plenty of people want the distances without the map.
class _LocationHistoryTile extends StatelessWidget {
  const _LocationHistoryTile();

  @override
  Widget build(BuildContext context) {
    return JatraCard(
      padding: EdgeInsets.zero,
      child: ListTile(
        title: Text(L.of(context).settingsDeleteLocationHistory),
        subtitle: Text(L.of(context).settingsDeleteLocationHistoryBody),
        onTap: () => _confirm(context),
      ),
    );
  }

  Future<void> _confirm(BuildContext context) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(L.of(context).settingsDeleteRoutesTitle),
        content: const Text(
          'The GPS paths are deleted permanently. Your rides keep their '
          'distance, duration and speeds, so statistics are unaffected.\n\n'
          'This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(L.of(context).settingsKeepThem),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: context.jatra.danger),
            child: Text(L.of(context).settingsDeleteRoutes),
          ),
        ],
      ),
    );
    if (!(ok ?? false)) return;

    final removed = await Get.find<RideRepo>().deleteAllLocationHistory();
    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          removed == 0
              ? 'There were no recorded routes to delete.'
              : 'Deleted $removed GPS points.',
        ),
      ),
    );
  }
}

class _AboutSection extends StatelessWidget {
  const _AboutSection();

  @override
  Widget build(BuildContext context) {
    final c = context.jatra;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionLabel(L.of(context).settingsAbout),
        const SizedBox(height: Gap.sm),
        JatraCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Jatra 1.0.0',
                style: AppText.titleMd.copyWith(color: c.textPrimary),
              ),
              const SizedBox(height: Gap.xs),
              Text(
                L.of(context).settingsAboutBody,
                style: AppText.bodySm.copyWith(color: c.textMuted),
              ),
              const SizedBox(height: Gap.md),
              Text(
                L.of(context).settingsFontCredit,
                style: AppText.caption.copyWith(color: c.textMuted),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
