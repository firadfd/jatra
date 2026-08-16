import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../app/theme/app_dimens.dart';
import '../../../app/theme/app_text.dart';
import '../../../app/theme/app_theme.dart';
import '../../../core/utils/formatters.dart';
import '../../../l10n/app_localizations.dart';
import '../../../core/widgets/jatra_widgets.dart';
import '../stats_controller.dart';

/// Shared chart conventions, applied everywhere so the six charts on the
/// stats screen read as one system:
///
/// * 2px lines, ≥8px touch targets on points, thin bars with rounded tops;
/// * a 2px surface-coloured gap between stacked segments, so adjacent fills
///   never blur into one another;
/// * recessive grid — horizontal rules only, in the muted grid colour;
/// * axis labels in the mono face, values in the numeral face;
/// * no dual axes, ever. Two measures of different scale get two charts.
abstract final class ChartStyle {
  static const lineWidth = 2.0;
  static const dotRadius = 3.0;
  static const touchDotRadius = 5.0;
  static const barWidth = 14.0;

  /// Gap between stacked segments, drawn in the surface colour.
  static const stackGap = 2.0;

  static const height = 200.0;

  static FlGridData grid(BuildContext context) => FlGridData(
    drawVerticalLine: false,
    getDrawingHorizontalLine: (_) =>
        FlLine(color: context.jatra.gridLine, strokeWidth: 1),
  );

  static FlBorderData get border => FlBorderData(show: false);

  static TextStyle axisLabel(BuildContext context) =>
      AppText.unit.copyWith(color: context.jatra.textMuted);
}

/// A chart with its title, legend and empty state. Every chart on the stats
/// screen is wrapped in one of these so they share spacing and behaviour.
class ChartCard extends StatelessWidget {
  const ChartCard({
    super.key,
    required this.title,
    required this.child,
    this.subtitle,
    this.legend = const [],
    this.isEmpty = false,
    this.emptyMessage,
  });

  final String title;
  final String? subtitle;
  final Widget child;

  /// Present whenever there are two or more series — identity must never
  /// rest on colour alone.
  final List<({String label, Color color})> legend;

  final bool isEmpty;
  final String? emptyMessage;

  @override
  Widget build(BuildContext context) {
    final c = context.jatra;

    return JatraCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionLabel(title),
          if (subtitle != null) ...[
            const SizedBox(height: 2),
            Text(
              subtitle!,
              style: AppText.caption.copyWith(color: c.textMuted),
            ),
          ],
          const SizedBox(height: Gap.md),
          if (isEmpty)
            SizedBox(
              height: ChartStyle.height / 2,
              child: Center(
                child: Text(
                  emptyMessage ?? L.of(context).statsNotEnoughData,
                  textAlign: TextAlign.center,
                  style: AppText.bodySm.copyWith(color: c.textMuted),
                ),
              ),
            )
          else ...[
            SizedBox(height: ChartStyle.height, child: child),
            if (legend.isNotEmpty) ...[
              const SizedBox(height: Gap.md),
              Wrap(
                spacing: Gap.md,
                runSpacing: Gap.sm,
                children: [
                  for (final item in legend)
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                            color: item.color,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        const SizedBox(width: Gap.xs),
                        // Legend text wears text tokens, never the series
                        // colour — the swatch beside it carries identity.
                        Text(
                          item.label,
                          style: AppText.caption.copyWith(
                            color: c.textSecondary,
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ],
          ],
        ],
      ),
    );
  }
}

/// A single-series line over time. No legend: the title names the series.
class TimeLineChart extends StatelessWidget {
  const TimeLineChart({
    super.key,
    required this.points,
    required this.colour,
    required this.fmt,
    required this.formatValue,
  });

  final List<SeriesPoint> points;
  final Color colour;
  final Fmt fmt;
  final String Function(double) formatValue;

  @override
  Widget build(BuildContext context) {
    final c = context.jatra;

    // Plot against index rather than timestamp: fills are irregularly
    // spaced, and a time axis would bunch a busy month into a smear while
    // stretching a quiet one across half the chart.
    final spots = [
      for (var i = 0; i < points.length; i++)
        FlSpot(i.toDouble(), points[i].value),
    ];

    final values = points.map((p) => p.value);
    final min = values.reduce((a, b) => a < b ? a : b);
    final max = values.reduce((a, b) => a > b ? a : b);
    final pad = ((max - min).abs() * 0.15).clamp(0.5, double.infinity);

    return LineChart(
      LineChartData(
        minY: min - pad,
        maxY: max + pad,
        gridData: ChartStyle.grid(context),
        borderData: ChartStyle.border,
        titlesData: FlTitlesData(
          topTitles: const AxisTitles(),
          rightTitles: const AxisTitles(),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 44,
              getTitlesWidget: (value, meta) => Padding(
                padding: const EdgeInsets.only(right: Gap.xs),
                child: Text(
                  formatValue(value),
                  style: ChartStyle.axisLabel(context),
                  textAlign: TextAlign.right,
                ),
              ),
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 28,
              interval: (points.length / 4).ceilToDouble().clamp(1, 1e9),
              getTitlesWidget: (value, meta) {
                final i = value.round();
                if (i < 0 || i >= points.length) return const SizedBox.shrink();
                return Padding(
                  padding: const EdgeInsets.only(top: Gap.xs),
                  child: Text(
                    fmt.dateShort(points[i].dateMs),
                    style: ChartStyle.axisLabel(context),
                  ),
                );
              },
            ),
          ),
        ),
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            getTooltipColor: (_) => c.surfaceElevated,
            tooltipBorderRadius: BorderRadius.circular(Radii.button),
            getTooltipItems: (touched) => [
              for (final t in touched)
                LineTooltipItem(
                  '${formatValue(t.y)}\n',
                  AppText.numeralSm.copyWith(color: c.textPrimary),
                  children: [
                    TextSpan(
                      text: fmt.date(points[t.x.round()].dateMs),
                      style: AppText.caption.copyWith(color: c.textMuted),
                    ),
                  ],
                ),
            ],
          ),
          getTouchedSpotIndicator: (barData, indexes) => [
            for (final _ in indexes)
              TouchedSpotIndicatorData(
                FlLine(color: colour, strokeWidth: 1),
                FlDotData(
                  getDotPainter: (spot, percent, bar, index) =>
                      FlDotCirclePainter(
                        radius: ChartStyle.touchDotRadius,
                        color: colour,
                        // A 2px surface ring keeps the marker legible where the
                        // line passes behind it.
                        strokeWidth: 2,
                        strokeColor: c.surface,
                      ),
                ),
              ),
          ],
        ),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            color: colour,
            barWidth: ChartStyle.lineWidth,
            isCurved: false,
            dotData: FlDotData(
              // Points are only drawn on a short series; past that they
              // become noise.
              show: points.length <= 24,
              getDotPainter: (spot, percent, bar, index) => FlDotCirclePainter(
                radius: ChartStyle.dotRadius,
                color: colour,
                strokeWidth: 0,
              ),
            ),
            belowBarData: BarAreaData(
              show: true,
              color: colour.withValues(alpha: 0.12),
            ),
          ),
        ],
      ),
    );
  }
}

/// Monthly bars — stacked when [stacked] series are supplied, plain
/// otherwise.
class MonthlyBarChart extends StatelessWidget {
  const MonthlyBarChart({
    super.key,
    required this.months,
    required this.stacks,
    required this.fmt,
    required this.formatValue,
  });

  final List<int> months;

  /// Per month, the segments bottom-up. A single-element list gives a plain
  /// bar chart.
  final List<List<({double value, Color color})>> stacks;

  final Fmt fmt;
  final String Function(double) formatValue;

  @override
  Widget build(BuildContext context) {
    final c = context.jatra;

    final totals = [
      for (final stack in stacks)
        stack.fold<double>(0, (sum, s) => sum + s.value),
    ];
    final maxTotal = totals.isEmpty
        ? 0.0
        : totals.reduce((a, b) => a > b ? a : b);

    return BarChart(
      BarChartData(
        maxY: maxTotal * 1.15,
        gridData: ChartStyle.grid(context),
        borderData: ChartStyle.border,
        titlesData: FlTitlesData(
          topTitles: const AxisTitles(),
          rightTitles: const AxisTitles(),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 44,
              getTitlesWidget: (value, meta) => Padding(
                padding: const EdgeInsets.only(right: Gap.xs),
                child: Text(
                  formatValue(value),
                  style: ChartStyle.axisLabel(context),
                  textAlign: TextAlign.right,
                ),
              ),
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 28,
              getTitlesWidget: (value, meta) {
                final i = value.round();
                if (i < 0 || i >= months.length) return const SizedBox.shrink();
                // Only every other label when months get tight, so they
                // never collide.
                if (months.length > 6 && i.isOdd) {
                  return const SizedBox.shrink();
                }
                return Padding(
                  padding: const EdgeInsets.only(top: Gap.xs),
                  child: Text(
                    fmt.monthAbbrev(months[i]).toUpperCase(),
                    style: ChartStyle.axisLabel(context),
                  ),
                );
              },
            ),
          ),
        ),
        barTouchData: BarTouchData(
          touchTooltipData: BarTouchTooltipData(
            getTooltipColor: (_) => c.surfaceElevated,
            tooltipBorderRadius: BorderRadius.circular(Radii.button),
            getTooltipItem: (group, groupIndex, rod, rodIndex) =>
                BarTooltipItem(
                  '${formatValue(totals[groupIndex])}\n',
                  AppText.numeralSm.copyWith(color: c.textPrimary),
                  children: [
                    TextSpan(
                      text: fmt.month(months[groupIndex]),
                      style: AppText.caption.copyWith(color: c.textMuted),
                    ),
                  ],
                ),
          ),
        ),
        barGroups: [
          for (var i = 0; i < stacks.length; i++)
            BarChartGroupData(
              x: i,
              barRods: [
                BarChartRodData(
                  toY: totals[i],
                  width: ChartStyle.barWidth,
                  // Rounded data-end anchored to the baseline: the top is
                  // rounded, the bottom sits square on the axis.
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(4),
                  ),
                  rodStackItems: _stackItems(stacks[i]),
                  color: stacks[i].isEmpty
                      ? c.signalDim
                      : stacks[i].first.color,
                ),
              ],
            ),
        ],
      ),
    );
  }

  /// Converts segment values into cumulative from/to pairs, leaving a 2px
  /// gap between neighbours so adjacent fills stay distinguishable even for
  /// a reader who cannot tell the two hues apart.
  List<BarChartRodStackItem> _stackItems(
    List<({double value, Color color})> segments,
  ) {
    if (segments.length < 2) return const [];

    final items = <BarChartRodStackItem>[];
    var cursor = 0.0;
    for (var i = 0; i < segments.length; i++) {
      final s = segments[i];
      if (s.value <= 0) continue;
      final from = i == 0 ? cursor : cursor + ChartStyle.stackGap;
      final to = cursor + s.value;
      if (to > from) items.add(BarChartRodStackItem(from, to, s.color));
      cursor = to;
    }
    return items;
  }
}
