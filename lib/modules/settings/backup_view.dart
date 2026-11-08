import 'package:flutter/material.dart';
import 'package:get/get.dart' hide Value;

import '../../app/theme/app_dimens.dart';
import '../../app/theme/app_text.dart';
import '../../app/theme/app_theme.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/jatra_widgets.dart';
import '../../data/models/backup.dart';
import '../../services/auto_backup_service.dart';
import '../vehicles/vehicle_controller.dart';
import 'backup_controller.dart';
import '../../l10n/app_localizations.dart';

class BackupView extends GetView<BackupController> {
  const BackupView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(L.of(context).backupTitle)),
      body: Stack(
        children: [
          ContentColumn(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(
                Gap.md,
                Gap.md,
                Gap.md,
                Gap.xl,
              ),
              children: const [
                _ErrorBanner(),
                _PendingImport(),
                _AutoBackupSection(),
                _ExportSection(),
                SizedBox(height: Gap.lg),
                _ImportSection(),
                SizedBox(height: Gap.lg),
                _BikeReportSection(),
                SizedBox(height: Gap.lg),
                _RawDatabaseSection(),
              ],
            ),
          ),
          Obx(
            () => controller.isBusy.value
                ? const _BusyOverlay()
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}

class _BusyOverlay extends GetView<BackupController> {
  const _BusyOverlay();

  @override
  Widget build(BuildContext context) {
    final c = context.jatra;
    return ColoredBox(
      color: c.background.withValues(alpha: 0.85),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: Gap.md),
            Obx(
              () => Text(
                controller.busyLabel.value,
                style: AppText.bodySm.copyWith(color: c.textSecondary),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Errors are specific and actionable, and they say plainly that nothing was
/// changed — the single most reassuring thing after a failed import.
class _ErrorBanner extends GetView<BackupController> {
  const _ErrorBanner();

  @override
  Widget build(BuildContext context) {
    final c = context.jatra;
    return Obx(() {
      final message = controller.error.value;
      if (message == null) return const SizedBox.shrink();

      return Padding(
        padding: const EdgeInsets.only(bottom: Gap.md),
        child: JatraCard(
          accent: c.danger,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.error_outline, size: 20, color: c.danger),
              const SizedBox(width: Gap.md),
              Expanded(
                child: Text(
                  message,
                  style: AppText.bodySm.copyWith(color: c.textSecondary),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close, size: 18),
                tooltip: L.of(context).backupDismiss,
                onPressed: () => controller.error.value = null,
              ),
            ],
          ),
        ),
      );
    });
  }
}

/// Android only: the folder is a Storage Access Framework grant.
class _AutoBackupSection extends GetView<BackupController> {
  const _AutoBackupSection();

  @override
  Widget build(BuildContext context) {
    if (!AutoBackupService.isSupported) return const SizedBox.shrink();

    final c = context.jatra;
    final l = L.of(context);
    final auto = Get.find<AutoBackupService>();
    final settings = controller.settings;

    return Padding(
      padding: const EdgeInsets.only(bottom: Gap.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionLabel(l.backupAutoTitle),
          const SizedBox(height: Gap.sm),
          JatraCard(
            child: Obx(() {
              final folder = settings.autoBackupFolderUri.value;
              final lastMs = settings.autoBackupLastMs.value;
              final failure = settings.autoBackupFailure.value;
              final busy = auto.isRunning.value;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l.backupAutoExplain,
                    style: AppText.bodySm.copyWith(color: c.textMuted),
                  ),
                  const SizedBox(height: Gap.md),
                  if (folder != null) ...[
                    DetailRow(
                      label: l.backupAutoFolder,
                      value: Flexible(
                        child: Text(
                          settings.autoBackupFolderLabel.value ?? '',
                          textAlign: TextAlign.right,
                          overflow: TextOverflow.ellipsis,
                          style: AppText.bodySm.copyWith(
                            color: c.textSecondary,
                          ),
                        ),
                      ),
                    ),
                    DetailRow(
                      label: l.backupAutoLast,
                      value: Text(
                        lastMs == null ? l.backupAutoNever : Fmt().date(lastMs),
                        style: AppText.bodySm.copyWith(color: c.textSecondary),
                      ),
                    ),
                    if (failure != null)
                      Padding(
                        padding: const EdgeInsets.only(top: Gap.sm),
                        child: Text(
                          failure == AutoBackupFailure.folderAccess.name
                              ? l.backupAutoErrorAccess
                              : l.backupAutoErrorWrite,
                          style: AppText.bodySm.copyWith(color: c.danger),
                        ),
                      ),
                    const SizedBox(height: Gap.md),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: busy ? null : auto.backUpNow,
                        icon: const Icon(Icons.backup_outlined),
                        label: Text(l.backupAutoNow),
                      ),
                    ),
                    const SizedBox(height: Gap.sm),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: busy ? null : auto.chooseFolder,
                            child: Text(l.backupAutoChange),
                          ),
                        ),
                        const SizedBox(width: Gap.sm),
                        Expanded(
                          child: OutlinedButton(
                            onPressed: busy ? null : auto.turnOff,
                            child: Text(l.backupAutoTurnOff),
                          ),
                        ),
                      ],
                    ),
                  ] else
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: auto.chooseFolder,
                        icon: const Icon(Icons.folder_open_outlined),
                        label: Text(l.backupAutoChoose),
                      ),
                    ),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }
}

/// The resale PDF for the active bike.
class _BikeReportSection extends GetView<BackupController> {
  const _BikeReportSection();

  @override
  Widget build(BuildContext context) {
    final c = context.jatra;
    final l = L.of(context);
    final vehicles = Get.find<VehicleController>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionLabel(l.reportTitle),
        const SizedBox(height: Gap.sm),
        JatraCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l.reportExplain,
                style: AppText.bodySm.copyWith(color: c.textMuted),
              ),
              const SizedBox(height: Gap.md),
              Obx(
                () => SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: vehicles.active.value == null
                        ? null
                        : () => controller.exportBikeReport(l.reportBuilding),
                    icon: const Icon(Icons.picture_as_pdf_outlined),
                    label: Text(l.reportAction),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ExportSection extends GetView<BackupController> {
  const _ExportSection();

  @override
  Widget build(BuildContext context) {
    final c = context.jatra;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionLabel(L.of(context).backupExport),
        const SizedBox(height: Gap.sm),
        JatraCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                L.of(context).backupExportExplain,
                style: AppText.bodySm.copyWith(color: c.textMuted),
              ),
              const SizedBox(height: Gap.sm),
              Obx(
                () => SwitchListTile.adaptive(
                  contentPadding: EdgeInsets.zero,
                  value: controller.settings.includeRidePointsInExport.value,
                  onChanged: (v) =>
                      controller.settings.includeRidePointsInExport.value = v,
                  title: Text(L.of(context).backupIncludeGps),
                  subtitle: Text(
                    L.of(context).backupIncludeGpsExplain,
                    style: AppText.caption.copyWith(color: c.textMuted),
                  ),
                ),
              ),
              Obx(
                () => SwitchListTile.adaptive(
                  contentPadding: EdgeInsets.zero,
                  value: controller.settings.prettyPrintExport.value,
                  onChanged: (v) =>
                      controller.settings.prettyPrintExport.value = v,
                  title: Text(L.of(context).backupReadable),
                  subtitle: Text(
                    L.of(context).backupReadableExplain,
                    style: AppText.caption.copyWith(color: c.textMuted),
                  ),
                ),
              ),
              const SizedBox(height: Gap.sm),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: controller.exportJson,
                  icon: const Icon(Icons.download_outlined),
                  label: Text(L.of(context).backupExportBackup),
                ),
              ),
              const SizedBox(height: Gap.sm),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: controller.exportCsv,
                  icon: const Icon(Icons.table_chart_outlined),
                  label: Text(L.of(context).backupExportCsv),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ImportSection extends GetView<BackupController> {
  const _ImportSection();

  @override
  Widget build(BuildContext context) {
    final c = context.jatra;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionLabel(L.of(context).backupImport),
        const SizedBox(height: Gap.sm),
        JatraCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                L.of(context).backupImportExplain,
                style: AppText.bodySm.copyWith(color: c.textMuted),
              ),
              const SizedBox(height: Gap.md),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: controller.pickBackupFile,
                  icon: const Icon(Icons.upload_file_outlined),
                  label: Text(L.of(context).backupChooseFile),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// The preview of what a chosen file contains, shown *before* the user picks
/// a merge strategy.
class _PendingImport extends GetView<BackupController> {
  const _PendingImport();

  @override
  Widget build(BuildContext context) {
    final c = context.jatra;
    final fmt = Fmt();

    return Obx(() {
      final backup = controller.pending.value;
      if (backup == null) return const SizedBox.shrink();

      final preview = backup.preview;
      final counts = preview.counts.entries
          .where((e) => e.value > 0)
          .map((e) => '${e.value} ${_label(L.of(context), e.key)}')
          .join(' · ');

      return Padding(
        padding: const EdgeInsets.only(bottom: Gap.lg),
        child: JatraCard(
          accent: c.signal,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      controller.pendingFileName.value,
                      style: AppText.titleMd.copyWith(color: c.textPrimary),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, size: 18),
                    tooltip: L.of(context).backupCancelImport,
                    onPressed: controller.cancelImport,
                  ),
                ],
              ),
              const SizedBox(height: Gap.sm),
              DetailRow(
                label: L.of(context).backupContains,
                value: Flexible(
                  child: Text(
                    counts.isEmpty ? L.of(context).backupNothing : counts,
                    textAlign: TextAlign.right,
                    style: AppText.bodySm.copyWith(color: c.textSecondary),
                  ),
                ),
              ),
              if (preview.vehicleNames.isNotEmpty)
                DetailRow(
                  label: L.of(context).vehiclesTitle,
                  value: Flexible(
                    child: Text(
                      preview.vehicleNames.join(', '),
                      textAlign: TextAlign.right,
                      style: AppText.bodySm.copyWith(color: c.textSecondary),
                    ),
                  ),
                ),
              if (preview.earliestMs != null && preview.latestMs != null)
                DetailRow(
                  label: L.of(context).backupCovers,
                  value: Text(
                    '${fmt.date(preview.earliestMs!)} – '
                    '${fmt.date(preview.latestMs!)}',
                    style: AppText.bodySm.copyWith(color: c.textSecondary),
                  ),
                ),
              if (preview.exportedAt != null)
                DetailRow(
                  label: L.of(context).backupExported,
                  value: Text(
                    fmt.date(preview.exportedAt!.millisecondsSinceEpoch),
                    style: AppText.bodySm.copyWith(color: c.textSecondary),
                  ),
                ),
              DetailRow(
                label: L.of(context).backupGpsData,
                value: Text(
                  preview.includesRidePoints
                      ? L.of(context).backupIncluded
                      : L.of(context).backupNotIncluded,
                  style: AppText.bodySm.copyWith(color: c.textSecondary),
                ),
              ),
              const SizedBox(height: Gap.md),
              SectionLabel(L.of(context).backupMergeQuestion),
              const SizedBox(height: Gap.sm),
              for (final strategy in MergeStrategy.values) ...[
                _StrategyTile(strategy: strategy),
                const SizedBox(height: Gap.sm),
              ],
            ],
          ),
        ),
      );
    });
  }

  static String _label(L l, String key) => switch (key) {
    'vehicles' => l.backupCountBikes,
    'fuelEntries' => l.backupCountFills,
    'serviceItems' => l.backupCountServiceItems,
    'serviceLogs' => l.backupCountServices,
    'expenses' => l.backupCountExpenses,
    'rides' => l.backupCountRides,
    'ridePoints' => l.backupCountGpsPoints,
    _ => key,
  };
}

class _StrategyTile extends GetView<BackupController> {
  const _StrategyTile({required this.strategy});

  final MergeStrategy strategy;

  @override
  Widget build(BuildContext context) {
    final c = context.jatra;
    final destructive = strategy.isDestructive;

    return JatraCard(
      accent: destructive ? c.danger : null,
      padding: const EdgeInsets.symmetric(horizontal: Gap.md, vertical: Gap.sm),
      onTap: () => destructive
          ? _confirmDestructive(context)
          : controller.applyPending(strategy),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  strategy.label,
                  style: AppText.titleMd.copyWith(
                    color: destructive ? c.danger : c.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  strategy.description,
                  style: AppText.caption.copyWith(color: c.textMuted),
                ),
              ],
            ),
          ),
          Icon(Icons.chevron_right, color: c.textMuted),
        ],
      ),
    );
  }

  /// Replace-all needs typed confirmation. A tap is far too cheap for an
  /// action that deletes everything on the phone.
  Future<void> _confirmDestructive(BuildContext context) async {
    const phrase = 'REPLACE';
    final input = TextEditingController();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(L.of(context).backupReplaceTitle),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'This deletes every bike, fill, service, expense and ride on '
              'this phone, then restores the backup in their place.\n\n'
              'Jatra saves a copy of your current data first, so this can be '
              'undone by a developer if it goes wrong — but not from inside '
              'the app.\n\nType REPLACE to confirm.',
            ),
            const SizedBox(height: Gap.md),
            TextField(
              controller: input,
              autofocus: true,
              textCapitalization: TextCapitalization.characters,
              decoration: const InputDecoration(hintText: phrase),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(L.of(context).actionCancel),
          ),
          ListenableBuilder(
            listenable: input,
            builder: (context, _) => TextButton(
              onPressed: input.text.trim().toUpperCase() == phrase
                  ? () => Navigator.of(context).pop(true)
                  : null,
              style: TextButton.styleFrom(
                foregroundColor: context.jatra.danger,
              ),
              child: Text(L.of(context).backupReplaceConfirm),
            ),
          ),
        ],
      ),
    );

    input.dispose();
    if (confirmed ?? false) await controller.applyPending(strategy);
  }
}

class _RawDatabaseSection extends GetView<BackupController> {
  const _RawDatabaseSection();

  @override
  Widget build(BuildContext context) {
    final c = context.jatra;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionLabel('Raw database'),
        const SizedBox(height: Gap.sm),
        JatraCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'A byte-for-byte copy. Faster and more exact than JSON for '
                'moving between phones running the same version of Jatra — but '
                'only that. Use a JSON backup if you are unsure.',
                style: AppText.bodySm.copyWith(color: c.textMuted),
              ),
              const SizedBox(height: Gap.sm),
              Obx(
                () => Text(
                  'Current size: '
                  '${Fmt.fileSize(controller.databaseSizeBytes.value)}',
                  style: AppText.caption.copyWith(color: c.textMuted),
                ),
              ),
              const SizedBox(height: Gap.md),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: controller.exportDatabase,
                  icon: const Icon(Icons.save_alt_outlined),
                  label: Text(L.of(context).backupCopyDatabase),
                ),
              ),
              const SizedBox(height: Gap.sm),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => _confirmRestore(context),
                  icon: const Icon(Icons.restore_outlined),
                  label: Text(L.of(context).backupRestoreDatabase),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _confirmRestore(BuildContext context) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(L.of(context).backupRestoreTitle),
        content: const Text(
          'This replaces everything on this phone with the contents of the '
          'file you pick, and closes Jatra. Open it again afterwards.\n\n'
          'The file must be a .sqlite backup made by this version of Jatra.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(L.of(context).actionCancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: context.jatra.danger),
            child: Text(L.of(context).backupPickFile),
          ),
        ],
      ),
    );
    if (!(ok ?? false)) return;

    final restored = await controller.restoreDatabaseFile();
    if (!restored || !context.mounted) return;

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text(L.of(context).backupRestoredTitle),
        content: const Text(
          'Close Jatra completely and open it again to load the restored data.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(L.of(context).actionGotIt),
          ),
        ],
      ),
    );
  }
}
