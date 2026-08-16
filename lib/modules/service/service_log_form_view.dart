import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart' hide Value;

import '../../app/theme/app_dimens.dart';
import '../../app/theme/app_text.dart';
import '../../app/theme/app_theme.dart';
import '../../core/utils/money.dart';
import '../../core/widgets/jatra_widgets.dart';
import 'service_log_form_controller.dart';
import '../../l10n/app_localizations.dart';

class ServiceLogFormView extends GetView<ServiceLogFormController> {
  const ServiceLogFormView({super.key});

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
              ? L.of(context).serviceLogEdit
              : L.of(context).serviceLogAction,
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
                      SectionLabel(L.of(context).serviceLogWhatDone),
                      const SizedBox(height: Gap.md),
                      Obx(
                        () => DropdownButtonFormField<int?>(
                          initialValue: controller.serviceItemId.value,
                          isExpanded: true,
                          decoration: InputDecoration(
                            labelText: L.of(context).serviceLogItem,
                            helperText: L.of(context).serviceLogItemHelp,
                            helperMaxLines: 2,
                          ),
                          items: [
                            DropdownMenuItem(
                              value: null,
                              child: Text(L.of(context).serviceLogOneOff),
                            ),
                            for (final item in controller.items)
                              DropdownMenuItem(
                                value: item.id,
                                child: Text(item.name),
                              ),
                          ],
                          onChanged: controller.selectItem,
                        ),
                      ),
                      const SizedBox(height: Gap.md),
                      TextFormField(
                        controller: controller.nameCtrl,
                        textCapitalization: TextCapitalization.sentences,
                        decoration: InputDecoration(
                          labelText: L.of(context).serviceLogDescription,
                          hintText: L.of(context).serviceLogDescriptionHint,
                        ),
                        validator: controller.validateName,
                      ),
                      const SizedBox(height: Gap.md),
                      Obx(
                        () => InkWell(
                          borderRadius: BorderRadius.circular(Radii.input),
                          onTap: () async {
                            final picked = await showDatePicker(
                              context: context,
                              initialDate: DateTime.fromMillisecondsSinceEpoch(
                                controller.dateMs.value,
                              ),
                              firstDate: DateTime(2000),
                              lastDate: DateTime.now(),
                            );
                            if (picked != null) {
                              controller.dateMs.value =
                                  picked.millisecondsSinceEpoch;
                            }
                          },
                          child: InputDecorator(
                            decoration: InputDecoration(
                              labelText: L.of(context).fuelDate,
                              suffixIcon: Icon(
                                Icons.calendar_today_outlined,
                                size: 18,
                              ),
                            ),
                            child: Text(
                              controller.fmt.date(controller.dateMs.value),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: Gap.md),
                      Obx(
                        () => TextFormField(
                          controller: controller.odometerCtrl,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(
                              RegExp(r'[0-9.]'),
                            ),
                          ],
                          style: AppText.numeralMd.copyWith(
                            color: c.textPrimary,
                          ),
                          decoration: InputDecoration(
                            labelText: L.of(context).fuelOdometer,
                            suffixText: controller.fmt.distanceLabel,
                          ),
                          validator: controller.validateOdometer,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: Gap.md),
                const _CostCard(),
                const SizedBox(height: Gap.md),
                const _DetailsCard(),
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
                  : L.of(context).serviceLogAction,
            ),
          ),
        ),
      ),
    );
  }
}

class _CostCard extends GetView<ServiceLogFormController> {
  const _CostCard();

  @override
  Widget build(BuildContext context) {
    final c = context.jatra;
    return JatraCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionLabel(L.of(context).serviceLogCost),
          const SizedBox(height: Gap.md),
          Row(
            children: [
              Expanded(
                child: Obx(
                  () => TextFormField(
                    controller: controller.partsCtrl,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: InputDecoration(
                      labelText: L.of(context).serviceLogParts,
                      prefixText:
                          '${MoneyFormatter.symbolFor(controller.fmt.currency)} ',
                    ),
                  ),
                ),
              ),
              const SizedBox(width: Gap.md),
              Expanded(
                child: Obx(
                  () => TextFormField(
                    controller: controller.laborCtrl,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: InputDecoration(
                      labelText: L.of(context).serviceLogLabour,
                      prefixText:
                          '${MoneyFormatter.symbolFor(controller.fmt.currency)} ',
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: Gap.md),
          Obx(
            () => TextFormField(
              controller: controller.totalCtrl,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              style: AppText.numeralMd.copyWith(color: c.textPrimary),
              decoration: InputDecoration(
                labelText: L.of(context).expensesTotal,
                helperText: L.of(context).serviceLogTotalHelp,
                helperMaxLines: 2,
                prefixText:
                    '${MoneyFormatter.symbolFor(controller.fmt.currency)} ',
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailsCard extends GetView<ServiceLogFormController> {
  const _DetailsCard();

  @override
  Widget build(BuildContext context) {
    return JatraCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionLabel(L.of(context).fuelOptional),
          const SizedBox(height: Gap.md),
          TextFormField(
            controller: controller.workshopCtrl,
            textCapitalization: TextCapitalization.words,
            decoration: InputDecoration(
              labelText: L.of(context).serviceLogWorkshop,
              hintText: L.of(context).serviceLogWorkshopHint,
            ),
          ),
          const SizedBox(height: Gap.md),
          TextFormField(
            controller: controller.partBrandCtrl,
            textCapitalization: TextCapitalization.words,
            decoration: InputDecoration(
              labelText: L.of(context).serviceLogPartBrand,
              hintText: L.of(context).serviceLogPartBrandHint,
            ),
          ),
          const SizedBox(height: Gap.md),
          TextFormField(
            controller: controller.notesCtrl,
            textCapitalization: TextCapitalization.sentences,
            maxLines: 3,
            minLines: 1,
            decoration: InputDecoration(labelText: L.of(context).fuelNotes),
          ),
        ],
      ),
    );
  }
}
