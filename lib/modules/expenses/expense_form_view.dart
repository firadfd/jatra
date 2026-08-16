import 'package:flutter/material.dart';
import 'package:get/get.dart' hide Value;

import '../../app/theme/app_dimens.dart';
import '../../app/theme/app_text.dart';
import '../../app/theme/app_theme.dart';
import '../../core/utils/formatters.dart';
import '../../core/utils/money.dart';
import '../../core/widgets/jatra_widgets.dart';
import '../../data/models/enums.dart';
import 'expense_form_controller.dart';
import '../../l10n/app_localizations.dart';

class ExpenseFormView extends GetView<ExpenseFormController> {
  const ExpenseFormView({super.key});

  @override
  Widget build(BuildContext context) {
    final c = context.jatra;

    return Scaffold(
      appBar: AppBar(
        // Not an Obx: `editId` is read from the route arguments in onInit and
        // never changes afterwards, so there is nothing here to observe — and
        // an Obx with no observable in it throws rather than rendering.
        title: Text(
          controller.isEditing
              ? L.of(context).expensesEdit
              : L.of(context).expensesAddTitle,
        ),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        return ContentColumn(
          child: Form(
            key: controller.formKey,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(
                Gap.md,
                Gap.md,
                Gap.md,
                Gap.xl,
              ),
              children: [
                JatraCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SectionLabel(L.of(context).expensesWhatFor),
                      const SizedBox(height: Gap.sm),
                      Obx(
                        () => Wrap(
                          spacing: Gap.sm,
                          runSpacing: Gap.sm,
                          children: [
                            for (final option in ExpenseCategory.values)
                              ChoiceChip(
                                label: Text(option.label),
                                selected: controller.category.value == option,
                                onSelected: (_) =>
                                    controller.category.value = option,
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(height: Gap.md),
                      Obx(
                        () => TextFormField(
                          controller: controller.amountCtrl,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          style: AppText.numeralMd.copyWith(
                            color: c.textPrimary,
                          ),
                          decoration: InputDecoration(
                            labelText: L.of(context).expensesAmount,
                            prefixText:
                                '${MoneyFormatter.symbolFor(controller.fmt.currency)} ',
                          ),
                          validator: controller.validateAmount,
                        ),
                      ),
                      const SizedBox(height: Gap.md),
                      Obx(
                        () => _DateField(
                          label: L.of(context).expensesPaidOn,
                          valueMs: controller.dateMs.value,
                          fmt: controller.fmt,
                          onChanged: (ms) {
                            if (ms != null) controller.dateMs.value = ms;
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: Gap.md),
                const _ValidityCard(),
                const SizedBox(height: Gap.md),
                JatraCard(
                  child: TextFormField(
                    controller: controller.notesCtrl,
                    textCapitalization: TextCapitalization.sentences,
                    maxLines: 3,
                    minLines: 1,
                    decoration: InputDecoration(
                      labelText: L.of(context).expensesNotes,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.all(Gap.md),
        child: Obx(
          () => FilledButton(
            onPressed: controller.isSaving.value ? null : controller.save,
            child: Text(
              controller.isEditing
                  ? L.of(context).actionSaveChanges
                  : L.of(context).expensesSave,
            ),
          ),
        ),
      ),
    );
  }
}

/// Only shown for categories that actually cover a period. A parking fee
/// does not expire.
class _ValidityCard extends GetView<ExpenseFormController> {
  const _ValidityCard();

  @override
  Widget build(BuildContext context) {
    final c = context.jatra;

    return Obx(() {
      if (!controller.showsValidity) return const SizedBox.shrink();

      return JatraCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SectionLabel(L.of(context).expensesCoverPeriod),
            const SizedBox(height: Gap.xs),
            Text(
              L.of(context).expensesCoverExplain,
              style: AppText.bodySm.copyWith(color: c.textMuted),
            ),
            const SizedBox(height: Gap.md),
            _DateField(
              label: L.of(context).expensesValidFrom,
              valueMs: controller.validFromMs.value,
              fmt: controller.fmt,
              onChanged: (ms) => controller.validFromMs.value = ms,
            ),
            const SizedBox(height: Gap.md),
            _DateField(
              label: L.of(context).expensesValidUntil,
              valueMs: controller.validUntilMs.value,
              fmt: controller.fmt,
              allowFuture: true,
              onChanged: (ms) => controller.validUntilMs.value = ms,
            ),
            Obx(() {
              final error = controller.validityError.value;
              if (error == null) return const SizedBox.shrink();
              return Padding(
                padding: const EdgeInsets.only(top: Gap.sm),
                child: Text(
                  error,
                  style: AppText.caption.copyWith(color: c.danger),
                ),
              );
            }),
          ],
        ),
      );
    });
  }
}

class _DateField extends StatelessWidget {
  const _DateField({
    required this.label,
    required this.valueMs,
    required this.fmt,
    required this.onChanged,
    this.allowFuture = false,
  });

  final String label;
  final int? valueMs;
  final Fmt fmt;
  final ValueChanged<int?> onChanged;

  /// Expiry dates are in the future; payment dates are not.
  final bool allowFuture;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(Radii.input),
      onTap: () async {
        final now = DateTime.now();
        final picked = await showDatePicker(
          context: context,
          initialDate: valueMs == null
              ? now
              : DateTime.fromMillisecondsSinceEpoch(valueMs!),
          firstDate: DateTime(2000),
          lastDate: allowFuture ? DateTime(now.year + 20) : now,
        );
        if (picked != null) onChanged(picked.millisecondsSinceEpoch);
      },
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          suffixIcon: const Icon(Icons.calendar_today_outlined, size: 18),
        ),
        child: Text(valueMs == null ? Fmt.dash : fmt.date(valueMs!)),
      ),
    );
  }
}
