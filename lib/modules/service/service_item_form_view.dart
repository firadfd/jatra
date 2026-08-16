import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart' hide Value;

import '../../app/theme/app_dimens.dart';
import '../../app/theme/app_text.dart';
import '../../app/theme/app_theme.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/jatra_widgets.dart';
import 'service_item_form_controller.dart';
import 'widgets/service_item_tile.dart';
import '../../l10n/app_localizations.dart';

class ServiceItemFormView extends GetView<ServiceItemFormController> {
  const ServiceItemFormView({super.key});

  @override
  Widget build(BuildContext context) {
    final c = context.jatra;

    return Scaffold(
      appBar: AppBar(
        // Neither of these is an Obx: `editId` is read from the route
        // arguments in onInit and never changes afterwards, so there is
        // nothing here to observe — and an Obx with no observable in it
        // throws rather than rendering.
        title: Text(
          controller.isEditing
              ? L.of(context).serviceItemEdit
              : L.of(context).serviceItemNew,
        ),
        actions: [
          if (controller.isEditing)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              tooltip: L.of(context).serviceItemDelete,
              onPressed: () => _confirmDelete(context),
            ),
        ],
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
                      SectionLabel(L.of(context).serviceItemJob),
                      const SizedBox(height: Gap.md),
                      TextFormField(
                        controller: controller.nameCtrl,
                        textCapitalization: TextCapitalization.sentences,
                        decoration: InputDecoration(
                          labelText: L.of(context).serviceItemName,
                          hintText: L.of(context).serviceItemNameHint,
                        ),
                        validator: controller.validateName,
                      ),
                      const SizedBox(height: Gap.md),
                      SectionLabel(L.of(context).serviceItemIcon),
                      const SizedBox(height: Gap.sm),
                      Obx(
                        () => Wrap(
                          spacing: Gap.sm,
                          runSpacing: Gap.sm,
                          children: [
                            for (final key
                                in ServiceItemFormController.iconKeys)
                              _IconChoice(
                                iconKey: key,
                                selected: controller.iconKey.value == key,
                                onTap: () => controller.iconKey.value = key,
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: Gap.md),
                const _IntervalCard(),
                const SizedBox(height: Gap.md),
                const _BaselineCard(),
                const SizedBox(height: Gap.md),
                JatraCard(
                  child: Obx(
                    () => SwitchListTile.adaptive(
                      contentPadding: EdgeInsets.zero,
                      value: controller.isActive.value,
                      onChanged: (v) => controller.isActive.value = v,
                      title: Text(L.of(context).serviceItemTrack),
                      subtitle: Text(
                        L.of(context).serviceItemTrackExplain,
                        style: AppText.bodySm.copyWith(color: c.textMuted),
                      ),
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
                  : L.of(context).serviceItemAdd,
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          L.of(context).serviceItemDeleteTitle(controller.nameCtrl.text.trim()),
        ),
        content: Text(L.of(context).serviceItemDeleteBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(L.of(context).serviceItemKeep),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: context.jatra.danger),
            child: Text(L.of(context).serviceItemDelete),
          ),
        ],
      ),
    );
    if (ok ?? false) await controller.delete();
  }
}

class _IconChoice extends StatelessWidget {
  const _IconChoice({
    required this.iconKey,
    required this.selected,
    required this.onTap,
  });

  final String iconKey;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.jatra;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(Radii.button),
      child: Container(
        width: Dimens.minTouchTarget,
        height: Dimens.minTouchTarget,
        decoration: BoxDecoration(
          color: selected ? c.signalDim : c.surfaceElevated,
          borderRadius: BorderRadius.circular(Radii.button),
          border: Border.all(
            color: selected ? c.signal : c.border,
            width: Dimens.border,
          ),
        ),
        child: Icon(
          serviceIcon(iconKey),
          size: 20,
          color: selected ? c.signal : c.textMuted,
        ),
      ),
    );
  }
}

class _IntervalCard extends GetView<ServiceItemFormController> {
  const _IntervalCard();

  @override
  Widget build(BuildContext context) {
    final c = context.jatra;
    return JatraCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionLabel(L.of(context).serviceItemHowOften),
          const SizedBox(height: Gap.xs),
          Text(
            L.of(context).serviceItemHowOftenExplain,
            style: AppText.bodySm.copyWith(color: c.textMuted),
          ),
          const SizedBox(height: Gap.md),
          Obx(
            () => TextFormField(
              controller: controller.intervalDistanceCtrl,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
              ],
              decoration: InputDecoration(
                labelText: L.of(context).serviceItemEvery,
                suffixText: controller.fmt.distanceLabel,
              ),
              onChanged: (_) => controller.intervalError.value = null,
            ),
          ),
          const SizedBox(height: Gap.md),
          TextFormField(
            controller: controller.intervalDaysCtrl,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: InputDecoration(
              labelText: L.of(context).serviceItemOrEvery,
              suffixText: L.of(context).serviceItemDays,
            ),
            onChanged: (_) => controller.intervalError.value = null,
          ),
          Obx(() {
            final error = controller.intervalError.value;
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
  }
}

class _BaselineCard extends GetView<ServiceItemFormController> {
  const _BaselineCard();

  @override
  Widget build(BuildContext context) {
    final c = context.jatra;
    return JatraCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionLabel(L.of(context).serviceItemLastDone),
          const SizedBox(height: Gap.xs),
          Text(
            L.of(context).serviceItemLastDoneExplain,
            style: AppText.bodySm.copyWith(color: c.textMuted),
          ),
          const SizedBox(height: Gap.md),
          Obx(
            () => TextFormField(
              controller: controller.lastDoneOdometerCtrl,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
              ],
              decoration: InputDecoration(
                labelText: L.of(context).serviceItemAtOdometer,
                suffixText: controller.fmt.distanceLabel,
              ),
            ),
          ),
          const SizedBox(height: Gap.md),
          Obx(
            () => InkWell(
              borderRadius: BorderRadius.circular(Radii.input),
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: controller.lastDoneDateMs.value == null
                      ? DateTime.now()
                      : DateTime.fromMillisecondsSinceEpoch(
                          controller.lastDoneDateMs.value!,
                        ),
                  firstDate: DateTime(2000),
                  lastDate: DateTime.now(),
                );
                if (picked != null) {
                  controller.lastDoneDateMs.value =
                      picked.millisecondsSinceEpoch;
                }
              },
              child: InputDecorator(
                decoration: InputDecoration(
                  labelText: L.of(context).serviceItemOnDate,
                  suffixIcon: controller.lastDoneDateMs.value == null
                      ? const Icon(Icons.calendar_today_outlined, size: 18)
                      : IconButton(
                          icon: const Icon(Icons.clear, size: 18),
                          tooltip: L.of(context).actionClear,
                          onPressed: () =>
                              controller.lastDoneDateMs.value = null,
                        ),
                ),
                child: Text(
                  controller.lastDoneDateMs.value == null
                      ? Fmt.dash
                      : controller.fmt.date(controller.lastDoneDateMs.value!),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
