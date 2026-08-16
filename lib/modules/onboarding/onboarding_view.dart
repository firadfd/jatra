import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart' hide Value;

import '../../app/theme/app_dimens.dart';
import '../../app/theme/app_text.dart';
import '../../app/theme/app_theme.dart';
import '../../core/widgets/jatra_widgets.dart';
import '../../core/widgets/odometer_strip.dart';
import '../../data/models/enums.dart';
import 'onboarding_controller.dart';
import '../../l10n/app_localizations.dart';

class OnboardingView extends GetView<OnboardingController> {
  const OnboardingView({super.key});

  @override
  Widget build(BuildContext context) {
    final c = context.jatra;

    return Scaffold(
      body: SafeArea(
        child: ContentColumn(
          child: Column(
            children: [
              const _StepIndicator(),
              Expanded(
                child: PageView(
                  controller: controller.pageController,
                  physics: const NeverScrollableScrollPhysics(),
                  onPageChanged: (i) => controller.page.value = i,
                  children: const [_BikeStep(), _OdometerStep(), _DoneStep()],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(Gap.lg),
                child: Obx(() {
                  final isLast =
                      controller.page.value == OnboardingController.lastPage;
                  return Row(
                    children: [
                      if (controller.page.value > 0)
                        TextButton(
                          onPressed: controller.back,
                          child: Text(L.of(context).actionBack),
                        ),
                      const Spacer(),
                      FilledButton(
                        onPressed: controller.isSaving.value
                            ? null
                            : controller.next,
                        child: Text(
                          isLast
                              ? L.of(context).onboardingStart
                              : L.of(context).actionContinue,
                        ),
                      ),
                    ],
                  );
                }),
              ),
            ],
          ),
        ),
      ),
      backgroundColor: c.background,
    );
  }
}

class _StepIndicator extends GetView<OnboardingController> {
  const _StepIndicator();

  @override
  Widget build(BuildContext context) {
    final c = context.jatra;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: Gap.lg, vertical: Gap.md),
      child: Obx(
        () => Row(
          children: [
            for (var i = 0; i <= OnboardingController.lastPage; i++) ...[
              Expanded(
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 220),
                  height: 3,
                  decoration: BoxDecoration(
                    color: i <= controller.page.value
                        ? c.signal
                        : c.surfaceElevated,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              if (i < OnboardingController.lastPage)
                const SizedBox(width: Gap.sm),
            ],
          ],
        ),
      ),
    );
  }
}

/// Step 1 — the bike.
class _BikeStep extends GetView<OnboardingController> {
  const _BikeStep();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: Gap.lg),
      children: [
        _StepHeading(
          label: L.of(context).onboardingStep(1, 3),
          title: L.of(context).onboardingBikeTitle,
          body: L.of(context).onboardingBikeBody,
        ),
        const SizedBox(height: Gap.lg),
        Obx(
          () => TextField(
            controller: controller.nameCtrl,
            textCapitalization: TextCapitalization.words,
            textInputAction: TextInputAction.next,
            autofocus: true,
            decoration: InputDecoration(
              labelText: L.of(context).onboardingBikeName,
              hintText: L.of(context).vehiclesNameHint,
              errorText: controller.nameError.value,
            ),
            onChanged: (_) => controller.nameError.value = null,
          ),
        ),
        const SizedBox(height: Gap.md),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: controller.makeCtrl,
                textCapitalization: TextCapitalization.words,
                decoration: InputDecoration(
                  labelText: L.of(context).onboardingMake,
                  hintText: L.of(context).onboardingMakeHint,
                ),
              ),
            ),
            const SizedBox(width: Gap.md),
            Expanded(
              child: TextField(
                controller: controller.modelCtrl,
                textCapitalization: TextCapitalization.words,
                decoration: InputDecoration(
                  labelText: L.of(context).onboardingModel,
                  hintText: L.of(context).onboardingModelHint,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: Gap.lg),
        SectionLabel(L.of(context).onboardingFuel),
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
    );
  }
}

/// Step 2 — the current reading.
class _OdometerStep extends GetView<OnboardingController> {
  const _OdometerStep();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: Gap.lg),
      children: [
        _StepHeading(
          label: L.of(context).onboardingStep(2, 3),
          title: L.of(context).onboardingOdometerTitle,
          body: L.of(context).onboardingOdometerBody,
        ),
        const SizedBox(height: Gap.lg),
        Obx(
          () => TextField(
            controller: controller.odometerCtrl,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
            ],
            style: AppText.numeralLg.copyWith(color: context.jatra.textPrimary),
            decoration: InputDecoration(
              labelText: L.of(context).onboardingOdometerLabel,
              hintText: L.of(context).onboardingOdometerHint,
              suffixText: controller.distanceUnit.value.label,
              errorText: controller.odometerError.value,
            ),
            onChanged: (_) => controller.odometerError.value = null,
          ),
        ),
        const SizedBox(height: Gap.lg),
        SectionLabel(L.of(context).onboardingUnits),
        const SizedBox(height: Gap.sm),
        Obx(
          () => Row(
            children: [
              Expanded(
                child: SegmentedButton<DistanceUnit>(
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
            ],
          ),
        ),
        const SizedBox(height: Gap.sm),
        Obx(
          () => Row(
            children: [
              Expanded(
                child: SegmentedButton<VolumeUnit>(
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
                  onSelectionChanged: (s) =>
                      controller.volumeUnit.value = s.first,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Step 3 — the promise.
class _DoneStep extends GetView<OnboardingController> {
  const _DoneStep();

  @override
  Widget build(BuildContext context) {
    final c = context.jatra;
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: Gap.lg),
      children: [
        _StepHeading(
          label: L.of(context).onboardingStep(3, 3),
          title: L.of(context).onboardingDoneTitle,
          body:
              'Log every refuel and Jatra works out your real mileage, when '
              'your next service is due, and what a kilometre actually costs '
              'you.',
        ),
        const SizedBox(height: Gap.lg),
        Center(
          // Listens to the text controller directly — a TextEditingController
          // is a Listenable, not an Rx, so `Obx` alone would never rebuild.
          child: ListenableBuilder(
            listenable: controller.odometerCtrl,
            builder: (context, _) => Obx(
              () => OdometerStrip(
                value:
                    int.tryParse(
                      controller.odometerCtrl.text
                          .replaceAll(',', '')
                          .split('.')
                          .first,
                    ) ??
                    0,
                unitLabel: controller.distanceUnit.value.label,
              ),
            ),
          ),
        ),
        const SizedBox(height: Gap.xl),
        JatraCard(
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
                      'Everything stays on this phone',
                      style: AppText.titleMd.copyWith(color: c.textPrimary),
                    ),
                    const SizedBox(height: Gap.xs),
                    Text(
                      'No account, no cloud, no analytics. Your fuel, '
                      'service and expense records never leave this phone, '
                      'and all of that works in airplane mode. Export a full '
                      'backup whenever you want it.\n\n'
                      'The one exception: if you record a ride, the map '
                      'behind it loads from OpenStreetMap, which sees '
                      'roughly where that ride was.',
                      style: AppText.bodySm.copyWith(color: c.textMuted),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: Gap.md),
        Text(
          'Location tracking is off, and Jatra will not ask for any permission '
          'until you turn on a feature that needs one.',
          style: AppText.caption.copyWith(color: c.textMuted),
        ),
      ],
    );
  }
}

class _StepHeading extends StatelessWidget {
  const _StepHeading({
    required this.label,
    required this.title,
    required this.body,
  });

  final String label;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    final c = context.jatra;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: Gap.lg),
        SectionLabel(label),
        const SizedBox(height: Gap.sm),
        Text(title, style: AppText.headline.copyWith(color: c.textPrimary)),
        const SizedBox(height: Gap.sm),
        Text(body, style: AppText.body.copyWith(color: c.textMuted)),
      ],
    );
  }
}
