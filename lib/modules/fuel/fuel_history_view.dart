import 'package:flutter/material.dart';
import 'package:get/get.dart' hide Value;

import '../../app/routes/app_routes.dart';
import '../../app/theme/app_dimens.dart';
import '../../app/theme/app_text.dart';
import '../../app/theme/app_theme.dart';
import '../../core/utils/money.dart';
import '../../core/widgets/jatra_widgets.dart';
import '../../data/db/database.dart';
import '../../l10n/app_localizations.dart';
import '../vehicles/vehicle_controller.dart';
import 'fuel_controller.dart';
import 'widgets/fuel_row.dart';

/// Every fill, grouped by month with a subtotal header.
///
/// Swipe a row left to delete (with undo) or right to edit — the two things
/// people actually do to a logged fill.
class FuelHistoryView extends GetView<FuelController> {
  const FuelHistoryView({super.key});

  @override
  Widget build(BuildContext context) {
    final vehicles = Get.find<VehicleController>();
    final l = L.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(l.fuelHistory)),
      body: Obx(() {
        if (!controller.isReady.value) {
          return const Center(child: CircularProgressIndicator());
        }

        final groups = controller.monthGroups;
        if (groups.isEmpty) {
          return EmptyState(
            icon: Icons.local_gas_station_outlined,
            title: l.fuelNoFillsTitle,
            message: l.fuelNoFillsBody,
            actionLabel: l.fuelAdd,
            onAction: () => Get.toNamed(Routes.fuelForm),
          );
        }

        final fmt = vehicles.fmt.value;

        return ContentColumn(
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(Gap.md, Gap.md, Gap.md, 96),
            itemCount: groups.length,
            itemBuilder: (context, i) {
              final group = groups[i];
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (i > 0) const SizedBox(height: Gap.lg),
                  _MonthHeader(
                    label: fmt.month(group.monthStartMs),
                    total: fmt.amount(group.totalCost),
                    volume:
                        '${fmt.volume(group.totalVolumeMl)} '
                        '${fmt.volumeLabel.toLowerCase()}',
                    fills: group.entries.length,
                  ),
                  const SizedBox(height: Gap.sm),
                  for (final entry in group.entries) ...[
                    _SwipeableFuelRow(entry: entry),
                    const SizedBox(height: Gap.sm),
                  ],
                ],
              );
            },
          ),
        );
      }),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'fab-fuel',
        onPressed: () => Get.toNamed(Routes.fuelForm),
        icon: const Icon(Icons.local_gas_station),
        label: Text(l.fuelAdd),
      ),
    );
  }
}

class _MonthHeader extends StatelessWidget {
  const _MonthHeader({
    required this.label,
    required this.total,
    required this.volume,
    required this.fills,
  });

  final String label;
  final String total;
  final String volume;
  final int fills;

  @override
  Widget build(BuildContext context) {
    final c = context.jatra;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: Gap.xs),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SectionLabel(label),
                const SizedBox(height: 2),
                Text(
                  '${L.of(context).fuelCountFills(fills)} · $volume',
                  style: AppText.caption.copyWith(color: c.textMuted),
                ),
              ],
            ),
          ),
          Text(total, style: AppText.numeralMd.copyWith(color: c.textPrimary)),
        ],
      ),
    );
  }
}

class _SwipeableFuelRow extends GetView<FuelController> {
  const _SwipeableFuelRow({required this.entry});

  final FuelEntryRow entry;

  @override
  Widget build(BuildContext context) {
    final c = context.jatra;
    final vehicles = Get.find<VehicleController>();

    void edit() =>
        Get.toNamed(Routes.fuelForm, arguments: {RouteArgs.editId: entry.id});

    return Dismissible(
      key: ValueKey('fuel-${entry.id}'),
      background: _SwipeAction(
        alignment: Alignment.centerLeft,
        colour: c.signal,
        icon: Icons.edit_outlined,
        label: L.of(context).actionEdit,
      ),
      secondaryBackground: _SwipeAction(
        alignment: Alignment.centerRight,
        colour: c.danger,
        icon: Icons.delete_outline,
        label: L.of(context).actionDelete,
      ),
      confirmDismiss: (direction) async {
        // Swiping right opens the editor instead of dismissing the row.
        if (direction == DismissDirection.startToEnd) {
          edit();
          return false;
        }
        return true;
      },
      onDismissed: (_) => _deleteWithUndo(context),
      child: Obx(
        () => FuelRow(
          entry: entry,
          window: controller.windowFor(entry.id),
          fmt: vehicles.fmt.value,
          onTap: edit,
        ),
      ),
    );
  }

  /// Soft-deletes and offers an undo, rather than asking first. A confirm
  /// dialog on every swipe is friction; a reversible action is not.
  Future<void> _deleteWithUndo(BuildContext context) async {
    await controller.delete(entry.id);
    if (!context.mounted) return;

    final fmt = Get.find<VehicleController>().fmt.value;
    final l = L.of(context);
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            l.fuelDeletedSnack(
              fmt.dateShort(entry.dateMs),
              fmt.amount(Money(entry.totalCostMinor)),
            ),
          ),
          action: SnackBarAction(
            label: l.actionUndo,
            onPressed: () => controller.undoDelete(entry.id),
          ),
          duration: const Duration(seconds: 6),
        ),
      );
  }
}

class _SwipeAction extends StatelessWidget {
  const _SwipeAction({
    required this.alignment,
    required this.colour,
    required this.icon,
    required this.label,
  });

  final Alignment alignment;
  final Color colour;
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: alignment,
      padding: const EdgeInsets.symmetric(horizontal: Gap.lg),
      decoration: BoxDecoration(
        color: colour.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(Radii.card),
        border: Border.all(color: colour, width: Dimens.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: colour, size: 20),
          const SizedBox(width: Gap.sm),
          Text(label, style: AppText.button.copyWith(color: colour)),
        ],
      ),
    );
  }
}
