import 'package:flutter/material.dart';
import 'package:get/get.dart' hide Value;

import '../../app/routes/app_routes.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_dimens.dart';
import '../../app/theme/app_text.dart';
import '../../app/theme/app_theme.dart';
import '../../core/widgets/jatra_widgets.dart';
import '../../data/db/database.dart';
import '../../data/repositories/vehicle_repo.dart';
import 'vehicle_controller.dart';
import '../../l10n/app_localizations.dart';

/// Add, edit, set default, archive and delete vehicles.
class VehiclesView extends GetView<VehicleController> {
  const VehiclesView({super.key});

  @override
  Widget build(BuildContext context) {
    final repo = Get.find<VehicleRepo>();

    return Scaffold(
      appBar: AppBar(title: Text(L.of(context).vehiclesTitle)),
      body: StreamBuilder<List<VehicleRow>>(
        stream: repo.watchAll(includeArchived: true),
        builder: (context, snapshot) {
          final rows = snapshot.data;
          if (rows == null) {
            return const Center(child: CircularProgressIndicator());
          }
          if (rows.isEmpty) {
            return EmptyState(
              icon: Icons.two_wheeler_outlined,
              title: L.of(context).vehiclesNoneTitle,
              message: L.of(context).homeNoBikeBody,
              actionLabel: L.of(context).vehiclesAdd,
              onAction: () => Get.toNamed(Routes.vehicleForm),
            );
          }

          final active = rows.where((v) => !v.isArchived).toList();
          final archived = rows.where((v) => v.isArchived).toList();

          return ContentColumn(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(Gap.md, Gap.md, Gap.md, 96),
              children: [
                for (final v in active) ...[
                  _VehicleTile(vehicle: v),
                  const SizedBox(height: Gap.sm),
                ],
                if (archived.isNotEmpty) ...[
                  const SizedBox(height: Gap.md),
                  SectionLabel(L.of(context).vehiclesArchived),
                  const SizedBox(height: Gap.sm),
                  for (final v in archived) ...[
                    _VehicleTile(vehicle: v),
                    const SizedBox(height: Gap.sm),
                  ],
                ],
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'fab-vehicles',
        onPressed: () => Get.toNamed(Routes.vehicleForm),
        icon: const Icon(Icons.add),
        label: Text(L.of(context).vehiclesAddShort),
      ),
    );
  }
}

class _VehicleTile extends StatelessWidget {
  const _VehicleTile({required this.vehicle});

  final VehicleRow vehicle;

  @override
  Widget build(BuildContext context) {
    final c = context.jatra;
    final repo = Get.find<VehicleRepo>();
    final tag = Palette.vehicleTag(vehicle.colorTag);

    final subtitleParts = [
      if (vehicle.make != null) vehicle.make!,
      if (vehicle.model != null) vehicle.model!,
      if (vehicle.year != null) '${vehicle.year}',
      if (vehicle.engineCc != null) '${vehicle.engineCc}cc',
    ];

    return JatraCard(
      onTap: () => Get.toNamed(
        Routes.vehicleForm,
        arguments: {RouteArgs.editId: vehicle.id},
      ),
      padding: const EdgeInsets.symmetric(horizontal: Gap.md, vertical: Gap.sm),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 40,
            decoration: BoxDecoration(
              color: vehicle.isArchived ? c.border : tag,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: Gap.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        vehicle.name,
                        style: AppText.titleMd.copyWith(
                          color: vehicle.isArchived
                              ? c.textMuted
                              : c.textPrimary,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (vehicle.isDefault) ...[
                      const SizedBox(width: Gap.sm),
                      StatusPill(
                        text: L.of(context).vehiclesDefault,
                        color: c.signal,
                      ),
                    ],
                  ],
                ),
                if (subtitleParts.isNotEmpty)
                  Text(
                    subtitleParts.join(' · '),
                    style: AppText.bodySm.copyWith(color: c.textMuted),
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            tooltip: L.of(context).vehiclesOptionsFor(vehicle.name),
            onSelected: (action) => _handle(context, action, repo),
            itemBuilder: (context) => [
              if (!vehicle.isDefault && !vehicle.isArchived)
                PopupMenuItem(
                  value: 'default',
                  child: Text(L.of(context).vehiclesMakeDefault),
                ),
              PopupMenuItem(
                value: 'archive',
                child: Text(
                  vehicle.isArchived
                      ? L.of(context).vehiclesUnarchive
                      : L.of(context).vehiclesArchive,
                ),
              ),
              PopupMenuItem(
                value: 'delete',
                child: Text(L.of(context).actionDelete),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _handle(
    BuildContext context,
    String action,
    VehicleRepo repo,
  ) async {
    switch (action) {
      case 'default':
        await repo.setDefault(vehicle.id);
        Get.find<VehicleController>().setActive(vehicle.id);
      case 'archive':
        await repo.setArchived(vehicle.id, !vehicle.isArchived);
      case 'delete':
        if (!context.mounted) return;
        await _confirmDelete(context, repo);
    }
  }

  /// Names exactly what goes with the bike before deleting it.
  Future<void> _confirmDelete(BuildContext context, VehicleRepo repo) async {
    // Resolved before the awaits below, so the snackbar afterwards never
    // reaches for a context that may have gone.
    final l = L.of(context);
    final counts = await repo.deletionCounts(vehicle.id);
    if (!context.mounted) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(L.of(context).vehiclesDeleteTitle(vehicle.name)),
        content: Text(
          counts.isEmpty
              ? L.of(context).vehiclesDeleteEmptyBody
              : L.of(context).vehiclesDeleteBody(counts.describe()),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(L.of(context).serviceItemKeep),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: context.jatra.danger),
            child: Text(L.of(context).vehiclesDeleteConfirm),
          ),
        ],
      ),
    );

    if (confirmed ?? false) {
      await repo.softDelete(vehicle.id);
      Get.snackbar(
        l.vehiclesDeleted,
        l.vehiclesDeletedBody(vehicle.name),
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }
}
