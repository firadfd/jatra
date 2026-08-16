import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart' hide Value;

import '../../app/theme/app_dimens.dart';
import '../../app/theme/app_text.dart';
import '../../app/theme/app_theme.dart';
import '../../core/widgets/jatra_widgets.dart';
import '../../l10n/app_localizations.dart';
import 'fuel_form_controller.dart';

/// The add/edit refuel form.
///
/// Optimised above every other screen: it is used weekly, one-handed, often
/// at a pump in poor light.
class FuelFormView extends GetView<FuelFormController> {
  const FuelFormView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // Not an Obx: `editId` is read from the route arguments in onInit and
        // never changes afterwards, so there is nothing here to observe — and
        // an Obx with no observable in it throws rather than rendering.
        title: Text(
          controller.isEditing ? L.of(context).fuelEdit : L.of(context).fuelAdd,
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
              children: const [
                _WhenAndWhere(),
                SizedBox(height: Gap.md),
                _AmountCard(),
                SizedBox(height: Gap.md),
                _TankCard(),
                SizedBox(height: Gap.md),
                _NotesCard(),
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
                  : L.of(context).fuelSave,
            ),
          ),
        ),
      ),
    );
  }
}

class _WhenAndWhere extends GetView<FuelFormController> {
  const _WhenAndWhere();

  @override
  Widget build(BuildContext context) {
    final c = context.jatra;
    return JatraCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionLabel(L.of(context).fuelWhen),
          const SizedBox(height: Gap.md),
          Obx(
            () => InkWell(
              borderRadius: BorderRadius.circular(Radii.input),
              onTap: () async {
                final now = DateTime.now();
                final picked = await showDatePicker(
                  context: context,
                  initialDate: DateTime.fromMillisecondsSinceEpoch(
                    controller.dateMs.value,
                  ),
                  firstDate: DateTime(2000),
                  lastDate: now,
                );
                if (picked != null) {
                  controller.dateMs.value = picked.millisecondsSinceEpoch;
                }
              },
              child: InputDecorator(
                decoration: InputDecoration(
                  labelText: L.of(context).fuelDate,
                  suffixIcon: const Icon(
                    Icons.calendar_today_outlined,
                    size: 18,
                  ),
                ),
                child: Text(controller.fmt.date(controller.dateMs.value)),
              ),
            ),
          ),
          const SizedBox(height: Gap.md),

          // --- Odometer, with its own override affordance ---
          Obx(
            () => TextFormField(
              controller: controller.odometerCtrl,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
              ],
              style: AppText.numeralMd.copyWith(color: c.textPrimary),
              decoration: InputDecoration(
                labelText: L.of(context).fuelOdometer,
                suffixText: controller.fmt.distanceLabel,
                helperText: controller.previousOdometerM.value > 0
                    ? L
                          .of(context)
                          .fuelLastReading(
                            controller.fmt.distance(
                              controller.previousOdometerM.value,
                            ),
                            controller.fmt.distanceLabel.toLowerCase(),
                          )
                    : null,
              ),
              validator: controller.validateOdometer,
              autovalidateMode: AutovalidateMode.onUserInteraction,
            ),
          ),
          Obx(() {
            if (controller.odometerOverridden.value) {
              return Padding(
                padding: const EdgeInsets.only(top: Gap.sm),
                child: Text(
                  L.of(context).fuelCorrectionAccepted,
                  style: AppText.caption.copyWith(color: c.textMuted),
                ),
              );
            }
            return Align(
              alignment: Alignment.centerLeft,
              child: TextButton(
                onPressed: () => _confirmOverride(context),
                child: Text(L.of(context).fuelOdometerResetAction),
              ),
            );
          }),
        ],
      ),
    );
  }

  Future<void> _confirmOverride(BuildContext context) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(L.of(context).fuelAllowLowerTitle),
        content: Text(L.of(context).fuelAllowLowerBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(L.of(context).actionCancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(L.of(context).fuelAllowLowerConfirm),
          ),
        ],
      ),
    );
    if (ok ?? false) controller.overrideOdometer();
  }
}

/// The three interdependent fields. Any two fill in the third.
class _AmountCard extends GetView<FuelFormController> {
  const _AmountCard();

  @override
  Widget build(BuildContext context) {
    final c = context.jatra;
    return JatraCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionLabel(
            L.of(context).fuelHowMuch,
            trailing: Text(
              L.of(context).fuelFillAnyTwo,
              style: AppText.caption.copyWith(color: c.textMuted),
            ),
          ),
          const SizedBox(height: Gap.md),
          Obx(
            () => TextFormField(
              controller: controller.volumeCtrl,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
              ],
              style: AppText.numeralMd.copyWith(color: c.textPrimary),
              decoration: InputDecoration(
                labelText: L.of(context).fuelAdded,
                suffixText: controller.fmt.volumeLabel,
              ),
              validator: controller.validateVolume,
              autovalidateMode: AutovalidateMode.onUserInteraction,
            ),
          ),
          const SizedBox(height: Gap.md),
          Obx(
            () => TextFormField(
              controller: controller.priceCtrl,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
              ],
              style: AppText.numeralMd.copyWith(color: c.textPrimary),
              decoration: InputDecoration(
                labelText: L.of(context).fuelPrice,
                prefixText: '${controller.fmt.currencySymbol} ',
                suffixText: controller.fmt.perVolumeLabel,
              ),
            ),
          ),
          const SizedBox(height: Gap.md),
          Obx(
            () => TextFormField(
              controller: controller.totalCtrl,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
              ],
              style: AppText.numeralMd.copyWith(color: c.textPrimary),
              decoration: InputDecoration(
                labelText: L.of(context).fuelTotalPaid,
                prefixText: '${controller.fmt.currencySymbol} ',
              ),
              validator: controller.validateTotal,
              autovalidateMode: AutovalidateMode.onUserInteraction,
            ),
          ),
        ],
      ),
    );
  }
}

class _TankCard extends GetView<FuelFormController> {
  const _TankCard();

  @override
  Widget build(BuildContext context) {
    final c = context.jatra;
    return JatraCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Obx(
            () => SwitchListTile.adaptive(
              contentPadding: EdgeInsets.zero,
              value: controller.isFullTank.value,
              onChanged: (v) => controller.isFullTank.value = v,
              title: Text(L.of(context).fuelFilledTank),
              subtitle: Text(
                controller.isFullTank.value
                    ? L.of(context).fuelFullTankExplain
                    : L.of(context).fuelPartialExplain,
                style: AppText.bodySm.copyWith(color: c.textMuted),
              ),
            ),
          ),
          Divider(color: c.border, height: Gap.lg),
          Obx(
            () => SwitchListTile.adaptive(
              contentPadding: EdgeInsets.zero,
              value: controller.isMissedEntry.value,
              onChanged: (v) => controller.isMissedEntry.value = v,
              title: Text(L.of(context).fuelMissedEntry),
              subtitle: Text(
                L.of(context).fuelMissedEntryExplain,
                style: AppText.bodySm.copyWith(color: c.textMuted),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NotesCard extends GetView<FuelFormController> {
  const _NotesCard();

  @override
  Widget build(BuildContext context) {
    return JatraCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionLabel(L.of(context).fuelOptional),
          const SizedBox(height: Gap.md),
          TextFormField(
            controller: controller.stationCtrl,
            textCapitalization: TextCapitalization.words,
            decoration: InputDecoration(
              labelText: L.of(context).fuelStation,
              hintText: L.of(context).fuelStationHint,
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
