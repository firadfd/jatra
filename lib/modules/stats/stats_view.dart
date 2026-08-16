import 'package:flutter/material.dart';
import 'package:get/get.dart' hide Value;

import '../../app/theme/app_dimens.dart';
import '../../app/theme/app_text.dart';
import '../../app/theme/app_theme.dart';
import '../../core/calc/date_range.dart';
import '../../core/utils/formatters.dart';
import '../../core/utils/units.dart';
import '../../data/models/enums.dart';
import '../../core/widgets/jatra_widgets.dart';
import '../../l10n/app_localizations.dart';
import '../vehicles/vehicle_controller.dart';
import 'stats_controller.dart';
import 'widgets/charts.dart';
import 'widgets/cost_per_km_card.dart';
import 'widgets/trip_calculator.dart';

class StatsView extends GetView<StatsController> {
  const StatsView({super.key});

  @override
  Widget build(BuildContext context) {
    final vehicles = Get.find<VehicleController>();

    return Scaffold(
      appBar: AppBar(title: Text(L.of(context).statsTitle)),
      body: Obx(() {
        if (vehicles.active.value == null) {
          return EmptyState(
            icon: Icons.insights_outlined,
            title: L.of(context).homeNoBikeTitle,
            message: L.of(context).statsNoBikeBody,
          );
        }

        return ContentColumn(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(Gap.md, Gap.md, Gap.md, Gap.xl),
            children: const [
              _RangeSelector(),
              SizedBox(height: Gap.md),
              CostPerKmCard(),
              SizedBox(height: Gap.md),
              TripCalculator(),
              SizedBox(height: Gap.md),
              _SummaryTiles(),
              SizedBox(height: Gap.md),
              _MileageChart(),
              SizedBox(height: Gap.md),
              _SpendChart(),
              SizedBox(height: Gap.md),
              _DistanceChart(),
              SizedBox(height: Gap.md),
              _CostPerKmChart(),
              SizedBox(height: Gap.md),
              _FuelPriceChart(),
            ],
          ),
        );
      }),
    );
  }
}

/// Filters live in one row above the charts, and every chart on the screen
/// respects the selection.
class _RangeSelector extends GetView<StatsController> {
  const _RangeSelector();

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            for (final preset in RangePreset.values)
              Padding(
                padding: const EdgeInsets.only(right: Gap.sm),
                child: ChoiceChip(
                  label: Text(_rangeLabel(L.of(context), preset)),
                  selected: controller.range.value.preset == preset,
                  onSelected: (_) => preset == RangePreset.custom
                      ? _pickCustom(context)
                      : controller.setPreset(preset),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickCustom(BuildContext context) async {
    final now = DateTime.now();
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: now,
      initialDateRange: DateTimeRange(
        start: DateTime(now.year, now.month - 1, now.day),
        end: now,
      ),
    );
    if (picked == null) return;
    controller.setCustomRange(
      picked.start.millisecondsSinceEpoch,
      picked.end.millisecondsSinceEpoch,
    );
  }
}

class _SummaryTiles extends GetView<StatsController> {
  const _SummaryTiles();

  @override
  Widget build(BuildContext context) {
    final vehicles = Get.find<VehicleController>();

    return Obx(() {
      final fmt = vehicles.fmt.value;
      final report = controller.report.value;
      final mileage = controller.mileageReport.value;

      final best = mileage.best;
      final worst = mileage.worst;
      final average = mileage.average(fmt.distanceUnit, fmt.volumeUnit);

      final tiles = <({String label, String value, String? unit})>[
        (
          label: L.of(context).statsDistance,
          value: report.hasDistance ? fmt.distance(report.distanceM) : Fmt.dash,
          unit: fmt.distanceLabel,
        ),
        (
          label: L.of(context).statsTotalSpent,
          value: fmt.amountRounded(report.runningCost),
          unit: null,
        ),
        (
          label: L.of(context).statsAverage,
          value: fmt.economyOf(average),
          unit: fmt.economyLabel,
        ),
        (
          label: L.of(context).statsBestTank,
          value: fmt.economyOf(best?.economy(fmt.distanceUnit, fmt.volumeUnit)),
          unit: fmt.economyLabel,
        ),
        (
          label: L.of(context).statsWorstTank,
          value: fmt.economyOf(
            worst?.economy(fmt.distanceUnit, fmt.volumeUnit),
          ),
          unit: fmt.economyLabel,
        ),
        (
          label: L.of(context).statsFills,
          value: '${controller.totalFills.value}',
          unit: null,
        ),
        (
          label: L.of(context).statsDaysOwned,
          value: '${controller.daysOwned.value}',
          unit: null,
        ),
        (
          label: L.of(context).statsFuelShare,
          value: fmt.percent(report.fuelShare),
          unit: null,
        ),
      ];

      return GridView.count(
        crossAxisCount: 2,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisSpacing: Gap.sm,
        mainAxisSpacing: Gap.sm,
        childAspectRatio: 2.1,
        children: [
          for (final tile in tiles)
            JatraCard(
              padding: const EdgeInsets.all(Gap.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SectionLabel(tile.label),
                  const SizedBox(height: Gap.xs),
                  StatValue(
                    value: tile.value,
                    unit: tile.unit,
                    style: AppText.numeralMd,
                  ),
                ],
              ),
            ),
        ],
      );
    });
  }
}

class _MileageChart extends GetView<StatsController> {
  const _MileageChart();

  @override
  Widget build(BuildContext context) {
    final vehicles = Get.find<VehicleController>();

    return Obx(() {
      final fmt = vehicles.fmt.value;
      final points = controller.mileageSeries;

      return ChartCard(
        title: L.of(context).statsMileageOverTime,
        subtitle: L.of(context).statsMileageSubtitle,
        isEmpty: points.length < 2,
        emptyMessage: L.of(context).statsMileageEmpty,
        child: TimeLineChart(
          points: points.toList(),
          colour: context.jatra.chartSeries[0],
          fmt: fmt,
          formatValue: (v) => v.toStringAsFixed(0),
        ),
      );
    });
  }
}

class _SpendChart extends GetView<StatsController> {
  const _SpendChart();

  @override
  Widget build(BuildContext context) {
    final c = context.jatra;
    final vehicles = Get.find<VehicleController>();

    return Obx(() {
      final fmt = vehicles.fmt.value;
      final months = controller.monthly;

      return ChartCard(
        title: L.of(context).statsMonthlySpend,
        subtitle: L.of(context).statsMonthlySpendSubtitle,
        isEmpty: months.isEmpty,
        legend: [
          (label: L.of(context).statsFuel, color: c.chartSeries[0]),
          (label: L.of(context).navService, color: c.chartSeries[1]),
          (label: L.of(context).statsOther, color: c.chartSeries[2]),
        ],
        child: MonthlyBarChart(
          months: [for (final m in months) m.monthStartMs],
          stacks: [
            for (final m in months)
              [
                (value: m.fuel.asMajor, color: c.chartSeries[0]),
                (value: m.service.asMajor, color: c.chartSeries[1]),
                (value: m.other.asMajor, color: c.chartSeries[2]),
              ],
          ],
          fmt: fmt,
          formatValue: (v) => _compact(v, fmt),
        ),
      );
    });
  }
}

class _DistanceChart extends GetView<StatsController> {
  const _DistanceChart();

  @override
  Widget build(BuildContext context) {
    final c = context.jatra;
    final vehicles = Get.find<VehicleController>();

    return Obx(() {
      final fmt = vehicles.fmt.value;
      final months = controller.monthly.where((m) => m.distanceM > 0).toList();

      return ChartCard(
        title: L.of(context).statsDistancePerMonth,
        isEmpty: months.isEmpty,
        emptyMessage: L.of(context).statsDistanceEmpty,
        child: MonthlyBarChart(
          months: [for (final m in months) m.monthStartMs],
          stacks: [
            for (final m in months)
              [
                (
                  value: Units.metresTo(m.distanceM, fmt.distanceUnit),
                  color: c.chartSeries[1],
                ),
              ],
          ],
          fmt: fmt,
          formatValue: (v) => v.round().toString(),
        ),
      );
    });
  }
}

class _CostPerKmChart extends GetView<StatsController> {
  const _CostPerKmChart();

  @override
  Widget build(BuildContext context) {
    final vehicles = Get.find<VehicleController>();

    return Obx(() {
      final fmt = vehicles.fmt.value;
      final points = [
        for (final m in controller.monthly)
          if (m.costPerMetreMinor != null)
            SeriesPoint(
              dateMs: m.monthStartMs,
              // Minor units per metre → major units per display distance unit.
              value:
                  m.costPerMetreMinor! /
                  100 *
                  (fmt.distanceUnit == DistanceUnit.km
                      ? Units.metresPerKm
                      : Units.metresPerMile),
            ),
      ];

      return ChartCard(
        title: L
            .of(context)
            .statsRunningCostPer(fmt.perDistanceLabel.toLowerCase()),
        subtitle: L.of(context).statsRunningCostSubtitle,
        isEmpty: points.length < 2,
        child: TimeLineChart(
          points: points,
          colour: context.jatra.chartSeries[2],
          fmt: fmt,
          formatValue: (v) => v.toStringAsFixed(1),
        ),
      );
    });
  }
}

class _FuelPriceChart extends GetView<StatsController> {
  const _FuelPriceChart();

  @override
  Widget build(BuildContext context) {
    final vehicles = Get.find<VehicleController>();

    return Obx(() {
      final fmt = vehicles.fmt.value;
      final points = controller.priceSeries;

      return ChartCard(
        title: L.of(context).statsFuelPricePaid,
        subtitle: L
            .of(context)
            .statsFuelPriceSubtitle(fmt.volumeLabel.toLowerCase()),
        isEmpty: points.length < 2,
        child: TimeLineChart(
          points: points.toList(),
          colour: context.jatra.chartSeries[0],
          fmt: fmt,
          formatValue: (v) => v.toStringAsFixed(0),
        ),
      );
    });
  }
}

/// Axis labels stay short so they never collide: `1.2k` beats `1,240`.
String _compact(double value, Fmt fmt) {
  if (value.abs() >= 100000) return '${(value / 1000).round()}k';
  if (value.abs() >= 1000) return '${(value / 1000).toStringAsFixed(1)}k';
  return value.round().toString();
}

/// The range chips, named in the user's language.
///
/// `RangePreset` deliberately carries no strings of its own — `lib/core` is
/// pure calculation and knows nothing about localisation.
String _rangeLabel(L l, RangePreset preset) => switch (preset) {
  RangePreset.thisMonth => l.statsRangeThisMonth,
  RangePreset.last3Months => l.statsRangeLast3Months,
  RangePreset.thisYear => l.statsRangeThisYear,
  RangePreset.allTime => l.statsRangeAllTime,
  RangePreset.custom => l.statsRangeCustom,
};
