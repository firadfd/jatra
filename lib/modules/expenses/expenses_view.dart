import 'package:flutter/material.dart';
import 'package:get/get.dart' hide Value;

import '../../app/routes/app_routes.dart';
import '../../app/theme/app_dimens.dart';
import '../../app/theme/app_text.dart';
import '../../app/theme/app_theme.dart';
import '../../core/utils/formatters.dart';
import '../../core/utils/money.dart';
import '../../core/widgets/jatra_widgets.dart';
import '../../data/db/database.dart';
import '../vehicles/vehicle_controller.dart';
import 'expenses_controller.dart';
import '../../l10n/app_localizations.dart';
import '../../core/utils/enum_labels.dart';

/// Insurance, tax token, fitness, registration and one-offs, with expiry
/// countdowns for the documents that have an end date.
class ExpensesView extends GetView<ExpensesController> {
  const ExpensesView({super.key});

  @override
  Widget build(BuildContext context) {
    final vehicles = Get.find<VehicleController>();

    return Scaffold(
      appBar: AppBar(
        title: Text(L.of(context).expensesTitle),
        actions: [
          Obx(
            () => vehicles.vehicles.length < 2
                ? const SizedBox.shrink()
                : IconButton(
                    icon: Icon(
                      controller.allVehicles.value
                          ? Icons.filter_alt_off_outlined
                          : Icons.filter_alt_outlined,
                    ),
                    tooltip: controller.allVehicles.value
                        ? L.of(context).expensesShowThisBike
                        : L.of(context).expensesShowAllBikes,
                    onPressed: () => controller.allVehicles.toggle(),
                  ),
          ),
        ],
      ),
      body: Obx(() {
        if (!controller.isReady.value) {
          return const Center(child: CircularProgressIndicator());
        }

        final groups = controller.monthGroups;
        if (groups.isEmpty) {
          return EmptyState(
            icon: Icons.receipt_long_outlined,
            title: L.of(context).expensesNoneTitle,
            message: L.of(context).expensesNoneBody,
            actionLabel: L.of(context).expensesAdd,
            onAction: () => Get.toNamed(Routes.expenseForm),
          );
        }

        final fmt = vehicles.fmt.value;

        return ContentColumn(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(Gap.md, Gap.md, Gap.md, 96),
            children: [
              const _DocumentCountdowns(),
              _SummaryCard(fmt: fmt),
              const SizedBox(height: Gap.lg),
              for (final group in groups) ...[
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: Gap.xs),
                  child: Row(
                    children: [
                      Expanded(
                        child: SectionLabel(fmt.month(group.monthStartMs)),
                      ),
                      Text(
                        fmt.amount(group.total),
                        style: AppText.numeralMd.copyWith(
                          color: context.jatra.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: Gap.sm),
                for (final expense in group.entries) ...[
                  _ExpenseRow(expense: expense, fmt: fmt),
                  const SizedBox(height: Gap.sm),
                ],
                const SizedBox(height: Gap.md),
              ],
            ],
          ),
        );
      }),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'fab-expenses',
        onPressed: () => Get.toNamed(Routes.expenseForm),
        icon: const Icon(Icons.add),
        label: Text(L.of(context).expensesAddTitle),
      ),
    );
  }
}

/// Documents that expire, soonest first, lapsed ones leading.
class _DocumentCountdowns extends GetView<ExpensesController> {
  const _DocumentCountdowns();

  @override
  Widget build(BuildContext context) {
    final c = context.jatra;
    final fmt = Get.find<VehicleController>().fmt.value;

    return Obx(() {
      final documents = controller.documents;
      if (documents.isEmpty) return const SizedBox.shrink();

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionLabel(L.of(context).expensesDocuments),
          const SizedBox(height: Gap.sm),
          for (final doc in documents) ...[
            JatraCard(
              accent: doc.isUrgent
                  ? (doc.hasExpired ? c.overdue : c.dueSoon)
                  : null,
              onTap: () => Get.toNamed(
                Routes.expenseForm,
                arguments: {RouteArgs.editId: doc.expense.id},
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: Gap.md,
                vertical: Gap.sm,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          doc.expense.category.labelOf(L.of(context)),
                          style: AppText.titleMd.copyWith(color: c.textPrimary),
                        ),
                        Text(
                          L
                              .of(context)
                              .expensesUntil(
                                fmt.date(doc.expense.validUntilMs!),
                              ),
                          style: AppText.bodySm.copyWith(color: c.textMuted),
                        ),
                      ],
                    ),
                  ),
                  StatusPill(
                    text: doc.hasExpired
                        ? L.of(context).expensesExpired
                        : doc.daysRemaining == 0
                        ? L.of(context).expensesExpiresToday
                        : L.of(context).expensesDaysLeft(doc.daysRemaining),
                    color: doc.hasExpired
                        ? c.overdue
                        : doc.isUrgent
                        ? c.dueSoon
                        : c.ok,
                  ),
                ],
              ),
            ),
            const SizedBox(height: Gap.sm),
          ],
          const SizedBox(height: Gap.md),
        ],
      );
    });
  }
}

class _SummaryCard extends GetView<ExpensesController> {
  const _SummaryCard({required this.fmt});

  final Fmt fmt;

  @override
  Widget build(BuildContext context) {
    final c = context.jatra;

    return Obx(() {
      final byCategory = controller.byCategory;

      return JatraCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SectionLabel(
              controller.allVehicles.value
                  ? L.of(context).expensesAllBikes
                  : L.of(context).expensesTotal,
            ),
            const SizedBox(height: Gap.sm),
            StatValue(
              value: fmt.amount(controller.total),
              style: AppText.numeralLg,
            ),
            const SizedBox(height: Gap.md),
            for (final row in byCategory.take(4))
              Padding(
                padding: const EdgeInsets.only(bottom: Gap.xs),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        row.category.labelOf(L.of(context)),
                        style: AppText.bodySm.copyWith(color: c.textMuted),
                      ),
                    ),
                    Text(
                      fmt.amount(row.total),
                      style: AppText.numeralSm.copyWith(color: c.textSecondary),
                    ),
                  ],
                ),
              ),
          ],
        ),
      );
    });
  }
}

class _ExpenseRow extends GetView<ExpensesController> {
  const _ExpenseRow({required this.expense, required this.fmt});

  final ExpenseRow expense;
  final Fmt fmt;

  @override
  Widget build(BuildContext context) {
    final c = context.jatra;

    return Dismissible(
      key: ValueKey('expense-${expense.id}'),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: Gap.lg),
        decoration: BoxDecoration(
          color: c.danger.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(Radii.card),
          border: Border.all(color: c.danger, width: Dimens.border),
        ),
        child: Icon(Icons.delete_outline, color: c.danger),
      ),
      onDismissed: (_) => _deleteWithUndo(context),
      child: JatraCard(
        onTap: () => Get.toNamed(
          Routes.expenseForm,
          arguments: {RouteArgs.editId: expense.id},
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: Gap.md,
          vertical: Gap.sm,
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    expense.category.labelOf(L.of(context)),
                    style: AppText.titleMd.copyWith(color: c.textPrimary),
                  ),
                  Text(
                    expense.notes == null
                        ? fmt.date(expense.dateMs)
                        : '${fmt.date(expense.dateMs)} · ${expense.notes}',
                    style: AppText.bodySm.copyWith(color: c.textMuted),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: Gap.sm),
            Text(
              fmt.amount(Money(expense.amountMinor)),
              style: AppText.numeralMd.copyWith(color: c.textPrimary),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _deleteWithUndo(BuildContext context) async {
    await controller.delete(expense.id);
    if (!context.mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            L
                .of(context)
                .expensesDeletedSnack(
                  expense.category.labelOf(L.of(context)),
                  fmt.amount(Money(expense.amountMinor)),
                ),
          ),
          action: SnackBarAction(
            label: L.of(context).actionUndo,
            onPressed: () => controller.undoDelete(expense.id),
          ),
          duration: const Duration(seconds: 6),
        ),
      );
  }
}
