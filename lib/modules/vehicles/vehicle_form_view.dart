import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart' hide Value;

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_dimens.dart';
import '../../app/theme/app_theme.dart';
import '../../core/utils/formatters.dart';
import '../../core/utils/money.dart';
import '../../core/utils/validators.dart';
import '../../core/widgets/jatra_widgets.dart';
import '../../data/models/enums.dart';
import 'vehicle_form_controller.dart';
import '../../l10n/app_localizations.dart';

class VehicleFormView extends GetView<VehicleFormController> {
  const VehicleFormView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // Not an Obx: `editId` is read from the route arguments in onInit and
        // never changes afterwards, so there is nothing here to observe — and
        // an Obx with no observable in it throws rather than rendering.
        title: Text(
          controller.isEditing
              ? L.of(context).vehiclesEdit
              : L.of(context).vehiclesAdd,
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
              padding: const EdgeInsets.fromLTRB(Gap.md, Gap.md, Gap.md, 96),
              children: const [
                _IdentitySection(),
                SizedBox(height: Gap.lg),
                _UnitsSection(),
                SizedBox(height: Gap.lg),
                _OwnershipSection(),
                SizedBox(height: Gap.lg),
                _AppearanceSection(),
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
                  : L.of(context).vehiclesAddShort,
            ),
          ),
        ),
      ),
    );
  }
}

class _IdentitySection extends GetView<VehicleFormController> {
  const _IdentitySection();

  @override
  Widget build(BuildContext context) {
    return JatraCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionLabel(L.of(context).vehiclesTheBike),
          const SizedBox(height: Gap.md),
          TextFormField(
            controller: controller.nameCtrl,
            textCapitalization: TextCapitalization.words,
            decoration: InputDecoration(
              labelText: L.of(context).vehiclesName,
              hintText: L.of(context).vehiclesNameHint,
            ),
            validator: (v) => Validate.required(v, 'name'),
          ),
          const SizedBox(height: Gap.md),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: controller.makeCtrl,
                  textCapitalization: TextCapitalization.words,
                  decoration: InputDecoration(
                    labelText: L.of(context).vehiclesMake,
                  ),
                ),
              ),
              const SizedBox(width: Gap.md),
              Expanded(
                child: TextFormField(
                  controller: controller.modelCtrl,
                  textCapitalization: TextCapitalization.words,
                  decoration: InputDecoration(
                    labelText: L.of(context).vehiclesModel,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: Gap.md),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: controller.yearCtrl,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: InputDecoration(
                    labelText: L.of(context).vehiclesYear,
                  ),
                  validator: Validate.year,
                ),
              ),
              const SizedBox(width: Gap.md),
              Expanded(
                child: TextFormField(
                  controller: controller.engineCcCtrl,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: InputDecoration(
                    labelText: L.of(context).vehiclesEngine,
                    suffixText: 'CC',
                  ),
                  validator: Validate.engineCc,
                ),
              ),
            ],
          ),
          const SizedBox(height: Gap.md),
          TextFormField(
            controller: controller.registrationCtrl,
            textCapitalization: TextCapitalization.characters,
            decoration: InputDecoration(
              labelText: L.of(context).vehiclesRegistration,
              hintText: L.of(context).vehiclesRegistrationHint,
            ),
          ),
          const SizedBox(height: Gap.md),
          SectionLabel(L.of(context).statsFuel),
          const SizedBox(height: Gap.sm),
          Obx(
            () => Wrap(
              spacing: Gap.sm,
              runSpacing: Gap.sm,
              children: [
                for (final type in FuelType.values)
                  ChoiceChip(
                    label: Text(type.label),
                    selected: controller.fuelType.value == type,
                    onSelected: (_) => controller.fuelType.value = type,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _UnitsSection extends GetView<VehicleFormController> {
  const _UnitsSection();

  @override
  Widget build(BuildContext context) {
    return JatraCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionLabel(L.of(context).vehiclesUnitsCurrency),
          const SizedBox(height: Gap.md),
          Obx(
            () => SegmentedButton<DistanceUnit>(
              segments: [
                ButtonSegment(
                  value: DistanceUnit.km,
                  label: Text(L.of(context).unitKm),
                ),
                ButtonSegment(
                  value: DistanceUnit.mi,
                  label: Text(L.of(context).unitMiles),
                ),
              ],
              selected: {controller.distanceUnit.value},
              onSelectionChanged: (s) =>
                  controller.distanceUnit.value = s.first,
            ),
          ),
          const SizedBox(height: Gap.sm),
          Obx(
            () => SegmentedButton<VolumeUnit>(
              segments: [
                ButtonSegment(
                  value: VolumeUnit.l,
                  label: Text(L.of(context).unitLitres),
                ),
                ButtonSegment(
                  value: VolumeUnit.gal,
                  label: Text(L.of(context).unitGallons),
                ),
              ],
              selected: {controller.volumeUnit.value},
              onSelectionChanged: (s) => controller.volumeUnit.value = s.first,
            ),
          ),
          const SizedBox(height: Gap.md),
          Obx(
            () => DropdownButtonFormField<String>(
              initialValue: controller.currency.value,
              decoration: InputDecoration(
                labelText: L.of(context).vehiclesCurrency,
              ),
              items: [
                for (final code in MoneyFormatter.supportedCurrencies)
                  DropdownMenuItem(
                    value: code,
                    child: Text('$code  ${MoneyFormatter.symbolFor(code)}'),
                  ),
              ],
              onChanged: (v) => controller.currency.value = v ?? 'BDT',
            ),
          ),
        ],
      ),
    );
  }
}

class _OwnershipSection extends GetView<VehicleFormController> {
  const _OwnershipSection();

  @override
  Widget build(BuildContext context) {
    final c = context.jatra;
    return JatraCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionLabel(L.of(context).vehiclesOwnership),
          const SizedBox(height: Gap.xs),
          Text(
            L.of(context).vehiclesOwnershipExplain,
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: Gap.md),
          Obx(
            () => TextFormField(
              controller: controller.initialOdometerCtrl,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: InputDecoration(
                labelText: L.of(context).vehiclesStartingOdometer,
                suffixText: controller.distanceUnit.value.label,
              ),
              validator: (v) =>
                  Validate.nonNegativeNumber(v, 'Starting odometer'),
            ),
          ),
          const SizedBox(height: Gap.md),
          Obx(
            () => TextFormField(
              controller: controller.tankCapacityCtrl,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: InputDecoration(
                labelText: L.of(context).vehiclesTankCapacity,
                suffixText: controller.volumeUnit.value.label,
              ),
              validator: (v) => Validate.nonNegativeNumber(v, 'Tank capacity'),
            ),
          ),
          const SizedBox(height: Gap.md),
          Obx(
            () => _DateField(
              label: L.of(context).vehiclesPurchaseDate,
              valueMs: controller.purchaseDateMs.value,
              onChanged: (ms) => controller.purchaseDateMs.value = ms,
            ),
          ),
          const SizedBox(height: Gap.md),
          Obx(
            () => TextFormField(
              controller: controller.purchasePriceCtrl,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: InputDecoration(
                labelText: L.of(context).vehiclesPurchasePrice,
                prefixText:
                    '${MoneyFormatter.symbolFor(controller.currency.value)} ',
              ),
              validator: (v) =>
                  Validate.money(v, 'Purchase price', allowEmpty: true),
            ),
          ),
          const SizedBox(height: Gap.md),
          Obx(
            () => TextFormField(
              controller: controller.currentValueCtrl,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: InputDecoration(
                labelText: L.of(context).vehiclesCurrentValue,
                helperText: L.of(context).vehiclesDepreciationHelp,
                helperMaxLines: 2,
                prefixText:
                    '${MoneyFormatter.symbolFor(controller.currency.value)} ',
              ),
              validator: (v) =>
                  Validate.money(v, 'Current value', allowEmpty: true),
            ),
          ),
          const SizedBox(height: Gap.md),
          Obx(
            () => SwitchListTile.adaptive(
              contentPadding: EdgeInsets.zero,
              value: controller.isDefault.value,
              onChanged: (v) => controller.isDefault.value = v,
              title: Text(L.of(context).vehiclesMakeDefault),
              subtitle: Text(
                'Makes it the default vehicle.',
                style: TextStyle(color: c.textMuted),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AppearanceSection extends GetView<VehicleFormController> {
  const _AppearanceSection();

  @override
  Widget build(BuildContext context) {
    final c = context.jatra;
    return JatraCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionLabel('Colour tag'),
          const SizedBox(height: Gap.md),
          Obx(
            () => Wrap(
              spacing: Gap.sm,
              runSpacing: Gap.sm,
              children: [
                for (var i = 0; i < Palette.vehicleTags.length; i++)
                  Semantics(
                    selected: controller.colorTag.value == i,
                    button: true,
                    label: L.of(context).vehiclesColourN(i + 1),
                    child: InkWell(
                      onTap: () => controller.colorTag.value = i,
                      borderRadius: BorderRadius.circular(Radii.chip),
                      // 48dp target with a smaller visible swatch inside.
                      child: SizedBox(
                        width: Dimens.minTouchTarget,
                        height: Dimens.minTouchTarget,
                        child: Center(
                          child: Container(
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              color: Palette.vehicleTag(i),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: controller.colorTag.value == i
                                    ? c.textPrimary
                                    : Colors.transparent,
                                width: 2,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Date picker field. Shows [Fmt.dash] when unset rather than today's date,
/// so an untouched field never looks like an answer.
class _DateField extends StatelessWidget {
  const _DateField({
    required this.label,
    required this.valueMs,
    required this.onChanged,
  });

  final String label;
  final int? valueMs;
  final ValueChanged<int?> onChanged;

  @override
  Widget build(BuildContext context) {
    final fmt = Fmt();
    return InkWell(
      borderRadius: BorderRadius.circular(Radii.input),
      onTap: () async {
        final now = DateTime.now();
        final picked = await showDatePicker(
          context: context,
          initialDate: valueMs == null
              ? now
              : DateTime.fromMillisecondsSinceEpoch(valueMs!),
          firstDate: DateTime(1950),
          lastDate: now,
        );
        if (picked != null) onChanged(picked.millisecondsSinceEpoch);
      },
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          suffixIcon: valueMs == null
              ? const Icon(Icons.calendar_today_outlined, size: 18)
              : IconButton(
                  icon: const Icon(Icons.clear, size: 18),
                  onPressed: () => onChanged(null),
                  tooltip: L.of(context).actionClear,
                ),
        ),
        child: Text(valueMs == null ? Fmt.dash : fmt.date(valueMs!)),
      ),
    );
  }
}
