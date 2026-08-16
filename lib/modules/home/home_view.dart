import 'package:flutter/material.dart';
import 'package:get/get.dart' hide Value;

import '../../app/routes/app_routes.dart';
import '../../app/theme/app_dimens.dart';
import '../../app/theme/app_text.dart';
import '../../app/theme/app_theme.dart';
import '../../core/calc/mileage_calc.dart';
import '../../core/utils/formatters.dart';
import '../../core/utils/units.dart';
import '../../core/widgets/jatra_widgets.dart';
import '../../core/widgets/odometer_strip.dart';
import '../../l10n/app_localizations.dart';
import '../fuel/widgets/fuel_row.dart';
import '../../data/models/enums.dart';
import '../../services/settings_service.dart';
import '../shell/shell_controller.dart';
import '../vehicles/vehicle_controller.dart';
import 'home_controller.dart';
import 'widgets/mileage_drop_card.dart';
import 'widgets/next_service_card.dart';
import 'widgets/vehicle_switcher.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final vehicles = Get.find<VehicleController>();
    final l = L.of(context);

    return Scaffold(
      appBar: AppBar(
        titleSpacing: Gap.sm,
        title: const VehicleSwitcher(),
        actions: [
          IconButton(
            icon: const Icon(Icons.build_outlined),
            tooltip: l.navService,
            onPressed: () => Get.toNamed(Routes.service),
          ),
          IconButton(
            icon: const Icon(Icons.two_wheeler_outlined),
            tooltip: l.navBikes,
            onPressed: () => Get.toNamed(Routes.vehicles),
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            tooltip: l.navSettings,
            onPressed: () => Get.toNamed(Routes.settings),
          ),
        ],
      ),
      body: Obx(() {
        if (!vehicles.isReady.value) {
          return const Center(child: CircularProgressIndicator());
        }
        if (vehicles.active.value == null) {
          return EmptyState(
            icon: Icons.two_wheeler_outlined,
            title: l.homeNoBikeTitle,
            message: l.homeNoBikeBody,
            actionLabel: l.homeAddBike,
            onAction: () => Get.toNamed(Routes.vehicleForm),
          );
        }
        return const _HomeBody();
      }),

      // One primary action. Adding fuel is the most frequent thing anyone
      // does in this app by a wide margin, so it gets the FAB and nothing
      // competes with it.
      floatingActionButton: Obx(
        () => vehicles.active.value == null
            ? const SizedBox.shrink()
            : FloatingActionButton.extended(
                // Every FAB in the app carries an explicit tag. The shell
                // keeps Home, Fuel and Map alive at once, and a Hero tag is
                // only unique per subtree — three FABs on the default tag is
                // "multiple heroes share the same tag", every frame.
                heroTag: 'fab-home',
                onPressed: () => Get.toNamed(Routes.fuelForm),
                icon: const Icon(Icons.local_gas_station),
                label: Text(l.homeAddFuel),
              ),
      ),
    );
  }
}

class _HomeBody extends GetView<HomeController> {
  const _HomeBody();

  @override
  Widget build(BuildContext context) {
    final vehicles = Get.find<VehicleController>();
    final l = L.of(context);

    return ContentColumn(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(Gap.md, Gap.md, Gap.md, 96),
        children: [
          Obx(() {
            final fmt = vehicles.fmt.value;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SectionLabel(l.homeOdometer),
                const SizedBox(height: Gap.sm),
                OdometerStrip(
                  value: Units.metresTo(
                    controller.odometerM.value,
                    fmt.distanceUnit,
                  ).round(),
                  unitLabel: fmt.distanceLabel,
                ),
              ],
            );
          }),
          const SizedBox(height: Gap.lg),

          Obx(() {
            final drop = controller.report.drop;
            if (drop == null) return const SizedBox.shrink();
            return Padding(
              padding: const EdgeInsets.only(bottom: Gap.md),
              child: MileageDropCard(drop: drop, fmt: vehicles.fmt.value),
            );
          }),

          const _MileageTiles(),
          const SizedBox(height: Gap.lg),
          SectionLabel(l.homeNextService),
          const SizedBox(height: Gap.sm),
          const NextServiceCard(),
          const SizedBox(height: Gap.lg),
          const _Sections(),
          const SizedBox(height: Gap.lg),
          const _RecentActivity(),
        ],
      ),
    );
  }
}

/// Last mileage with a trend arrow, alongside what that tank cost to run.
class _MileageTiles extends GetView<HomeController> {
  const _MileageTiles();

  @override
  Widget build(BuildContext context) {
    final c = context.jatra;
    final vehicles = Get.find<VehicleController>();
    final l = L.of(context);

    return Obx(() {
      final fmt = vehicles.fmt.value;
      final report = controller.report;
      final latest = report.latest;

      // `stretch` sizes the two cards to the taller of the pair, but it
      // stretches to the incoming maxHeight — and inside a ListView that is
      // infinite, which throws during layout and takes the whole screen with
      // it. IntrinsicHeight measures the tallest child first, so stretch has
      // a real number to stretch to.
      return IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: JatraCard(
                // A tab switch rather than a push: fuel is a destination in the
                // bottom nav, and pushing it would hide the bar the user just
                // navigated with.
                onTap: () => Get.find<ShellController>().go(ShellTab.fuel),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SectionLabel(l.homeLastTank),
                    const SizedBox(height: Gap.sm),
                    StatValue(
                      value: fmt.economyOf(
                        latest?.economy(fmt.distanceUnit, fmt.volumeUnit),
                      ),
                      unit: fmt.economyLabel,
                      color: latest == null ? c.textMuted : c.signal,
                      prefix: _TrendArrow(fraction: report.trendFraction),
                    ),
                    const SizedBox(height: Gap.xs),
                    Text(
                      _lastTankCaption(l, report, fmt),
                      style: AppText.caption.copyWith(color: c.textMuted),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: Gap.sm),
            Expanded(
              child: JatraCard(
                onTap: () => Get.find<ShellController>().go(ShellTab.stats),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SectionLabel(l.homeRunningCost),
                    const SizedBox(height: Gap.sm),
                    Builder(
                      builder: (context) {
                        final rate = controller.costReport.value
                            .runningPerDistance(fmt.distanceUnit);
                        return StatValue(
                          value: rate == null ? Fmt.dash : fmt.rate(rate),
                          unit: fmt.perDistanceLabel,
                          color: rate == null ? c.textMuted : c.textPrimary,
                        );
                      },
                    ),
                    const SizedBox(height: Gap.xs),
                    Text(
                      // Named precisely. Fuel-only and true cost are separate
                      // figures, and all three live on the stats screen.
                      'Fuel, service and fixed',
                      style: AppText.caption.copyWith(color: c.textMuted),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    });
  }

  String _lastTankCaption(L l, MileageReport report, Fmt fmt) {
    final latest = report.latest;
    if (latest == null) {
      return report.windows.isEmpty
          ? l.homeNeedsTwoTanks
          : l.homeLatestUnreliable;
    }
    final average = report.average(fmt.distanceUnit, fmt.volumeUnit);
    if (average == null) return fmt.date(latest.closingDateMs);
    return l.homeAverage(
      fmt.economyOf(average),
      fmt.economyLabel.toLowerCase(),
    );
  }
}

/// The app's other sections. Home answers "is anything wrong?"; these are
/// the ways in to the detail.
class _Sections extends StatelessWidget {
  const _Sections();

  @override
  Widget build(BuildContext context) {
    // Wrapped in Obx because the section list depends on the tracking mode,
    // which the settings screen can change while home is still mounted.
    return Obx(() => _build(context));
  }

  Widget _build(BuildContext context) {
    final c = context.jatra;
    final l = L.of(context);
    final shell = Get.find<ShellController>();

    // Rides only appears once tracking is switched on — with it off there
    // is nothing behind that door but an explainer.
    final trackingOn =
        Get.find<SettingsService>().trackingMode.value != TrackingMode.off;

    // Cards that lead to a bottom-nav destination switch tabs; the rest push
    // a route over the shell. Both are one tap, and neither leaves the user
    // somewhere the nav bar cannot get them back from.
    final sections = <({String label, IconData icon, VoidCallback onTap})>[
      (
        label: l.navFuelLog,
        icon: Icons.local_gas_station_outlined,
        onTap: () => shell.go(ShellTab.fuel),
      ),
      (
        label: l.navService,
        icon: Icons.build_outlined,
        onTap: () => Get.toNamed(Routes.service),
      ),
      (
        label: l.navExpenses,
        icon: Icons.receipt_long_outlined,
        onTap: () => Get.toNamed(Routes.expenses),
      ),
      if (trackingOn)
        (
          label: l.navRides,
          icon: Icons.route_outlined,
          onTap: () => shell.go(ShellTab.map),
        ),
      (
        label: l.navStatistics,
        icon: Icons.insights_outlined,
        onTap: () => shell.go(ShellTab.stats),
      ),
    ];

    return Row(
      children: [
        for (final section in sections) ...[
          Expanded(
            child: JatraCard(
              onTap: section.onTap,
              padding: const EdgeInsets.symmetric(vertical: Gap.md),
              child: Column(
                children: [
                  Icon(section.icon, size: 22, color: c.textSecondary),
                  const SizedBox(height: Gap.sm),
                  Text(
                    section.label,
                    style: AppText.caption.copyWith(color: c.textMuted),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                  ),
                ],
              ),
            ),
          ),
          if (section != sections.last) const SizedBox(width: Gap.sm),
        ],
      ],
    );
  }
}

/// Up, down or nothing. Silent when there is no previous reading to compare
/// against — an arrow pointing nowhere is worse than no arrow.
class _TrendArrow extends StatelessWidget {
  const _TrendArrow({required this.fraction});

  final double? fraction;

  @override
  Widget build(BuildContext context) {
    final c = context.jatra;
    final f = fraction;
    if (f == null || f.abs() < 0.005) return const SizedBox.shrink();

    return Icon(
      f > 0 ? Icons.arrow_upward : Icons.arrow_downward,
      size: 16,
      color: f > 0 ? c.ok : c.overdue,
    );
  }
}

class _RecentActivity extends GetView<HomeController> {
  const _RecentActivity();

  @override
  Widget build(BuildContext context) {
    final vehicles = Get.find<VehicleController>();
    final l = L.of(context);

    return Obx(() {
      final entries = controller.fuel.newestFirst.take(4).toList();
      final fmt = vehicles.fmt.value;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionLabel(
            l.homeRecentFills,
            trailing: entries.isEmpty
                ? null
                : TextButton(
                    onPressed: () =>
                        Get.find<ShellController>().go(ShellTab.fuel),
                    child: Text(l.actionSeeAll),
                  ),
          ),
          const SizedBox(height: Gap.sm),
          if (entries.isEmpty)
            JatraCard(
              padding: const EdgeInsets.symmetric(
                horizontal: Gap.md,
                vertical: Gap.lg,
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.local_gas_station_outlined,
                    size: 32,
                    color: context.jatra.textMuted,
                  ),
                  const SizedBox(height: Gap.md),
                  Text(
                    l.homeNoFillsTitle,
                    style: AppText.titleMd.copyWith(
                      color: context.jatra.textPrimary,
                    ),
                  ),
                  const SizedBox(height: Gap.xs),
                  Text(
                    l.homeNoFillsBody,
                    style: AppText.bodySm.copyWith(
                      color: context.jatra.textMuted,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: Gap.md),
                  FilledButton(
                    onPressed: () => Get.toNamed(Routes.fuelForm),
                    child: Text(l.homeAddFuel),
                  ),
                ],
              ),
            )
          else
            for (final entry in entries) ...[
              FuelRow(
                entry: entry,
                window: controller.fuel.windowFor(entry.id),
                fmt: fmt,
                onTap: () => Get.toNamed(
                  Routes.fuelForm,
                  arguments: {RouteArgs.editId: entry.id},
                ),
              ),
              const SizedBox(height: Gap.sm),
            ],
        ],
      );
    });
  }
}
