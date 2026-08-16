import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_dimens.dart';
import '../../app/theme/app_text.dart';
import '../../core/utils/formatters.dart';
import '../../core/utils/money.dart';
import '../../l10n/app_localizations.dart';
import 'widget_charts.dart';
import 'widget_shapes.dart';
import 'widget_snapshot.dart';

/// What the home-screen widget looks like.
///
/// A plain widget over a [WidgetSnapshot] and an explicit [JatraColors] — no
/// `Theme.of`, no `Localizations.of`, no GetX. It is rendered off-screen into
/// a bitmap by `HomeWidgetService`, where none of those ancestors exist, and
/// that same independence is what lets a test pump it directly.
///
/// Everything on it is **all-time**: the widget has no controls, so a range
/// it cannot show you the bounds of would be a figure you could not check.
///
/// [panel] decides how much of that gets drawn — the whole stack, the four
/// figures alone, or a single chart. Each is a separate widget on the home
/// screen and every one of them is this class.
class WidgetFace extends StatelessWidget {
  const WidgetFace({
    super.key,
    required this.panel,
    required this.snapshot,
    required this.colors,
    required this.l10n,
    required this.size,
  });

  final WidgetPanel panel;
  final WidgetSnapshot snapshot;
  final JatraColors colors;
  final L l10n;

  /// Logical size of the host widget. Type and spacing scale with it, so a
  /// 4×2 and a 5×4 both read correctly rather than one being a stretched
  /// copy of the other.
  final Size size;

  /// The width the proportions were drawn against — a 4-cell widget.
  static const designWidth = 320.0;

  /// Width, not height. Every piece of text on the face is bounded
  /// horizontally: four tiles share the width, and each chart's title, value
  /// and axis ticks share it too. Scaling off height instead lets a tall,
  /// narrow widget grow the type until two money figures meet in the middle.
  ///
  /// Height is absorbed by the charts, which take what is left and shed
  /// their axes when it runs short — see [_ChartRow].
  double get _scale => (size.width / designWidth).clamp(0.8, 1.4);

  @override
  Widget build(BuildContext context) {
    final pad = Gap.sm * _scale + 4;

    return Container(
      width: size.width,
      height: size.height,
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(Radii.card),
        border: Border.all(color: colors.border, width: Dimens.border),
      ),
      padding: EdgeInsets.all(pad),
      child: DefaultTextStyle(
        style: TextStyle(color: colors.textPrimary),
        child: switch (snapshot) {
          final s when !s.hasVehicle => _Message(
            text: l10n.widgetNoBike,
            colors: colors,
            scale: _scale,
          ),
          final s when !s.hasData => _Message(
            text: l10n.widgetNoData,
            colors: colors,
            scale: _scale,
          ),
          _ => _Content(
            panel: panel,
            snapshot: snapshot,
            colors: colors,
            l10n: l10n,
            scale: _scale,
          ),
        },
      ),
    );
  }
}

class _Content extends StatelessWidget {
  const _Content({
    required this.panel,
    required this.snapshot,
    required this.colors,
    required this.l10n,
    required this.scale,
  });

  final WidgetPanel panel;
  final WidgetSnapshot snapshot;
  final JatraColors colors;
  final L l10n;
  final double scale;

  @override
  Widget build(BuildContext context) {
    final fmt = snapshot.fmt;
    final months = snapshot.months;
    final gap = Gap.sm * scale;

    // Stacked, not side by side. Three charts across a widget leaves each
    // about a thumb wide, which is enough for a shape and not enough for an
    // axis — and a chart whose scale you cannot read is decoration. Full
    // width each, with their own x and y ticks, costs height and buys a
    // figure the rider can actually check.
    //
    // Built as a map so a single-chart panel picks its one out by name and
    // the definitions stay in one place — the fuel-cost chart on its own
    // widget must be the same chart it is inside the stack.
    final charts = <WidgetPanel, Widget>{
      WidgetPanel.spend: _ChartRow(
        label: l10n.statsMonthlySpend,
        latest: months.isEmpty
            ? null
            : fmt.money.formatRounded(Money.fromMajor(months.last.spend)),
        values: [for (final m in months) m.spend],
        months: months,
        colors: colors,
        scale: scale,
        fmt: fmt,
        format: (v) => _compactMoney(v, fmt),
        // Zero-based, because a spend chart that starts at ৳3,000 makes a
        // quiet month look like a free one.
        zeroBased: true,
        plot: WidgetBarChart(
          stacks: [
            for (final m in months) [m.fuel, m.service, m.other],
          ],
          colours: colors.chartSeries,
        ),
      ),
      WidgetPanel.distance: _ChartRow(
        label: l10n.statsDistancePerMonth,
        latest: months.isEmpty || !snapshot.hasDistance
            ? null
            : _distanceLabel(months.last, fmt),
        values: [for (final m in months) m.distance],
        months: months,
        colors: colors,
        scale: scale,
        fmt: fmt,
        format: (v) => _compactNumber(v),
        zeroBased: true,
        // Distance needs two odometer readings inside one month. Until some
        // month has that, this chart has nothing true to say and says
        // nothing rather than drawing a row of zeros.
        plot: snapshot.hasDistance
            ? WidgetBarChart(
                stacks: [
                  for (final m in months) [m.distance],
                ],
                colours: [colors.chartSeries[1]],
              )
            : null,
      ),
      WidgetPanel.fuelCost: _ChartRow(
        label: l10n.widgetFuelCostPer(fmt.perDistanceLabel),
        latest: _lastRate(months, fmt),
        values: [
          for (final m in months)
            if (m.fuelCostPerDistance != null) m.fuelCostPerDistance!,
        ],
        months: months,
        colors: colors,
        scale: scale,
        fmt: fmt,
        format: fmt.rate,
        // A rate that has never been near zero is read for its movement, so
        // this one scales to its own range.
        zeroBased: false,
        plot: snapshot.hasDistance
            ? WidgetLineChart(
                values: [for (final m in months) m.fuelCostPerDistance],
                colour: colors.signal,
              )
            : null,
      ),
    };

    final header = _Header(
      snapshot: snapshot,
      colors: colors,
      l10n: l10n,
      scale: scale,
    );
    final tiles = _Tiles(
      snapshot: snapshot,
      colors: colors,
      l10n: l10n,
      scale: scale,
    );

    // The figures alone. They fill the face rather than sitting at the top
    // of it, because on its own widget that is all there is.
    if (panel == WidgetPanel.info) {
      return LayoutBuilder(
        builder: (context, constraints) {
          // At a single row the four figures are the entire widget and the
          // header will not fit above them. Losing the vehicle's name there
          // is the right trade — a strip that clips its own numbers is no
          // use to anyone, and the figures are what was asked for.
          final headed =
              constraints.maxHeight >=
              _headerHeight() + _tilesHeight() + gap * 0.75;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (headed) header,
              Expanded(child: _fitted(tiles, constraints.maxWidth)),
            ],
          );
        },
      );
    }

    final chart = charts[panel];
    if (chart != null) {
      return LayoutBuilder(
        builder: (context, constraints) {
          // The vehicle's name and the range are worth the two lines they
          // cost — with two bikes in the garage a chart that does not say
          // whose it is answers nothing — but not at the price of the chart
          // itself. On a single-row widget the chart's own title carries it.
          final headed =
              constraints.maxHeight >=
              (_ChartRow.minHeight + _headerHeight()) * scale + gap;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (headed) ...[header, SizedBox(height: gap * 0.75)],
              Expanded(child: chart),
            ],
          );
        },
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        // A widget squeezed to a single row has no room for a chart under
        // the figures. Rather than leave the bottom half empty, the figures
        // take the whole face — which is the right answer for a strip
        // anyway, and the four of them are what the widget is for.
        if (constraints.maxHeight - _fixedHeight() <
            _ChartRow.minHeight * scale) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              header,
              Expanded(child: Center(child: tiles)),
            ],
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            header,
            SizedBox(height: gap * 0.75),
            tiles,
            SizedBox(height: gap),
            Expanded(
              child: LayoutBuilder(
                builder: (context, chartArea) {
                  // Show as many charts as can be drawn properly, in order
                  // of what a rider checks first, and drop the rest. Three
                  // charts crushed to nine pixels each is worse than one
                  // chart and two absences: the tiles above are still the
                  // answer, and a shape too short to read only implies it
                  // has been given one.
                  final shown = charts.values
                      .take(_chartsThatFit(chartArea.maxHeight, gap))
                      .toList();
                  if (shown.isEmpty) return const SizedBox.shrink();

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    spacing: gap,
                    children: [for (final each in shown) Expanded(child: each)],
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  double _headerHeight() => _Type.label(scale).fontSize! * 1.1;

  /// The four figures, centred, and shrunk together if the widget is shorter
  /// than they are tall.
  ///
  /// [_tilesHeight] predicts that height from the type scale, but a
  /// prediction is the wrong thing to stake a home screen on: it is derived
  /// from font metrics, and Bangla's differ from Latin's. This makes the
  /// question moot — whatever the row turns out to need, it is scaled to
  /// what there is. The explicit width is because the row divides itself
  /// into four columns and cannot do that unbounded.
  Widget _fitted(Widget tiles, double width) => Center(
    child: FittedBox(
      fit: BoxFit.scaleDown,
      child: SizedBox(width: width, child: tiles),
    ),
  );

  /// Height the header, the tiles and the gaps around them will take.
  ///
  /// Derived from the same type scale those widgets use rather than
  /// measured, because the decision it feeds — whether to lay out for charts
  /// at all — has to be made before any of them is laid out. Rounded up, so
  /// an error here costs a chart rather than an overflow.
  double _fixedHeight() =>
      _headerHeight() + _tilesHeight() + Gap.sm * scale * 1.75;

  double _tilesHeight() =>
      _Type.unit(scale).fontSize! * 1.2 +
      _Type.numeral(scale).fontSize! +
      2 * scale;

  /// How many of the three chart rows fit in [height] at a legible size.
  int _chartsThatFit(double height, double gap) {
    for (var n = 3; n >= 1; n--) {
      final each = (height - gap * (n - 1)) / n;
      if (each >= _ChartRow.minHeight * scale) return n;
    }
    return 0;
  }

  /// Exact, unlike the axis ticks above it. This is a readout, and "1.4k KM"
  /// is a scale marker pretending to be one.
  static String _distanceLabel(WidgetMonth month, Fmt fmt) =>
      '${fmt.distance(month.distanceM)} ${fmt.distanceLabel}';

  /// The most recent month that actually produced a rate, which is not
  /// always the last one — a month with a single odometer reading has none.
  static String? _lastRate(List<WidgetMonth> months, Fmt fmt) {
    for (final m in months.reversed) {
      final rate = m.fuelCostPerDistance;
      if (rate != null) return fmt.rate(rate);
    }
    return null;
  }
}

/// `৳15k`, `৳3.2k`, `৳840` — an axis tick has room for a magnitude, not for
/// a total. The exact figure is on the tile above.
String _compactMoney(double value, Fmt fmt) =>
    '${fmt.currencySymbol}${_compactNumber(value)}';

String _compactNumber(double value) {
  final magnitude = value.abs();
  if (magnitude >= 100000) return '${(value / 1000).round()}k';
  if (magnitude >= 1000) {
    return '${(value / 1000).toStringAsFixed(1).replaceAll('.0', '')}k';
  }
  return value.round().toString();
}

class _Header extends StatelessWidget {
  const _Header({
    required this.snapshot,
    required this.colors,
    required this.l10n,
    required this.scale,
  });

  final WidgetSnapshot snapshot;
  final JatraColors colors;
  final L l10n;
  final double scale;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            snapshot.vehicleName,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: _Type.label(scale).copyWith(color: colors.textSecondary),
          ),
        ),
        SizedBox(width: Gap.sm * scale),
        // The range is stated rather than assumed. Every figure below it is
        // all-time, and a rider who cannot see that would reasonably read
        // the spend tile as this month's.
        Text(
          l10n.statsRangeAllTime.toUpperCase(),
          style: _Type.unit(scale).copyWith(color: colors.textMuted),
        ),
      ],
    );
  }
}

class _Tiles extends StatelessWidget {
  const _Tiles({
    required this.snapshot,
    required this.colors,
    required this.l10n,
    required this.scale,
  });

  final WidgetSnapshot snapshot;
  final JatraColors colors;
  final L l10n;
  final double scale;

  @override
  Widget build(BuildContext context) {
    final fmt = snapshot.fmt;
    final economy = snapshot.economy;
    final fuelCost = snapshot.fuelCostPerDistance;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      // A gutter, because each figure is shrunk to fit its own column and a
      // long one fills that column edge to edge. Without this, ৳86,420 and
      // 44.2 in the next tile touch and read as one number.
      spacing: Gap.sm * scale,
      children: [
        _Tile(
          label: l10n.statsDistance,
          value: fmt.distance(snapshot.distanceM),
          unit: fmt.distanceLabel,
          colors: colors,
          scale: scale,
        ),
        _Tile(
          label: l10n.statsTotalSpent,
          value: fmt.amountRounded(snapshot.spend),
          colors: colors,
          scale: scale,
        ),
        _Tile(
          label: l10n.statsAverage,
          value: fmt.economyOf(economy),
          unit: economy == null ? null : fmt.economyLabel,
          colors: colors,
          scale: scale,
        ),
        // Fuel only, and labelled so. Running cost — which folds in
        // servicing, parts and fixed costs — is the more complete answer and
        // the one the statistics screen leads with, but it needs the
        // explanation printed beside it there. Unexplained on a home screen
        // it reads as the pump figure and quietly overstates it.
        _Tile(
          label: l10n.widgetFuelCostPer(fmt.perDistanceLabel),
          value: fuelCost == null ? Fmt.dash : fmt.rate(fuelCost),
          colors: colors,
          scale: scale,
          // The one figure the app is really about, so it wears the accent.
          emphasis: true,
        ),
      ],
    );
  }
}

class _Tile extends StatelessWidget {
  const _Tile({
    required this.label,
    required this.value,
    required this.colors,
    required this.scale,
    this.unit,
    this.emphasis = false,
  });

  final String label;
  final String value;
  final String? unit;
  final JatraColors colors;
  final double scale;
  final bool emphasis;

  @override
  Widget build(BuildContext context) {
    final unitLabel = unit;

    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label.toUpperCase(),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: _Type.unit(scale).copyWith(color: colors.textMuted),
          ),
          SizedBox(height: 2 * scale),
          // Money runs long — ৳1,24,850 in a quarter of a small widget — and
          // truncating a total is worse than shrinking it. The unit rides
          // inside the same box so it shrinks in step.
          //
          // Held to a fixed height as well as a fixed width. Baseline-
          // aligning the numeral face against the mono one makes the row
          // taller than either of them — by how much depends on the two
          // fonts' metrics, which differ between Latin and Bangla — and
          // `_Content._tilesHeight` has to be able to predict this exactly.
          SizedBox(
            height: _Type.valueRowHeight(scale),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    value,
                    style: _Type.numeral(scale).copyWith(
                      color: emphasis ? colors.signal : colors.textPrimary,
                    ),
                  ),
                  if (unitLabel != null) ...[
                    SizedBox(width: 2 * scale),
                    Text(
                      unitLabel,
                      style: _Type.unit(
                        scale,
                      ).copyWith(color: colors.textMuted),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// One full-width chart with its own axes.
///
/// Reading order is title, then the current value, then the shape, then the
/// scale — so the row is laid out that way:
///
///     MONTHLY SPEND                                    ৳4,820
///     ৳6k ┬───────────────────────────────────────────────────
///         │      ▁▃▅▂▇▄▃▅▂▇▃▅▆▂
///      ৳0 ┴───────────────────────────────────────────────────
///         AUG 24                 FEB 25                MAR 26
///
/// The two y ticks are the extremes of the plot, sitting on the rules that
/// bound it, so a bar touching the top rule is worth exactly the figure
/// printed beside it. Only two, because a widget-sized chart is read for
/// magnitude and direction, and a third tick would cost a quarter of the
/// plot's height to say something the first two already imply.
class _ChartRow extends StatelessWidget {
  const _ChartRow({
    required this.label,
    required this.latest,
    required this.values,
    required this.months,
    required this.colors,
    required this.scale,
    required this.format,
    required this.fmt,
    required this.zeroBased,
    required this.plot,
  });

  final String label;

  /// The series' current value, printed beside the title. Null when there
  /// isn't one to print.
  final String? latest;

  /// The plotted values, used only to label the axis — the painter does its
  /// own scaling over the same numbers.
  final List<double> values;

  final List<WidgetMonth> months;
  final JatraColors colors;
  final double scale;
  final String Function(double) format;
  final Fmt fmt;

  /// Whether the plot's baseline is zero or the series minimum. Must match
  /// what the painter does, or the bottom tick lies.
  final bool zeroBased;

  /// Null when this chart has nothing to draw.
  final Widget? plot;

  /// The shortest a row can be and still be worth drawing: its title, and a
  /// plot about as tall again. `_Content` shows fewer charts rather than let
  /// any of them fall below this.
  ///
  /// Set at the point where a bare shape still reads — a 14px sparkline
  /// under a title is a small chart, not a broken one — because the
  /// alternative on a 4x1 banner is no chart at all, and a strip of four
  /// figures with an empty half is worse than a strip with one trend on it.
  static const minHeight = 30.0;

  /// Below this, the x ticks are dropped: a month label under a plot only
  /// three times its own height crowds out the thing it is labelling.
  static const _minHeightForXAxis = 52.0;

  /// And below this, the y ticks go too, leaving a bare shape.
  static const _minHeightForYAxis = 30.0;

  @override
  Widget build(BuildContext context) {
    final muted = _Type.unit(scale).copyWith(color: colors.textMuted);
    final yAxisWidth = 30 * scale;
    final gutter = Gap.xs * scale;

    return LayoutBuilder(
      builder: (context, constraints) {
        final height = constraints.maxHeight;
        // Scaled with the type, since what these thresholds are really
        // asking is whether a plot survives once the labels have taken
        // their share.
        final showX = height >= _minHeightForXAxis * scale && months.isNotEmpty;
        final showY = height >= _minHeightForYAxis * scale && values.isNotEmpty;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    label.toUpperCase(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: muted,
                  ),
                ),
                if (latest != null) ...[
                  SizedBox(width: gutter),
                  Text(
                    latest!,
                    style: _Type.numeralSm(
                      scale,
                    ).copyWith(color: colors.textPrimary),
                  ),
                ],
              ],
            ),
            SizedBox(height: gutter),
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (showY)
                    SizedBox(
                      width: yAxisWidth,
                      child: _YAxis(
                        max: values.reduce(math.max),
                        min: zeroBased ? 0 : values.reduce(math.min),
                        format: format,
                        style: muted,
                      ),
                    ),
                  if (showY) SizedBox(width: gutter),
                  Expanded(
                    child: DecoratedBox(
                      // Horizontal rules only, in the muted grid colour —
                      // the same convention the statistics screen's charts
                      // follow.
                      decoration: BoxDecoration(
                        border: Border(
                          top: BorderSide(color: colors.gridLine),
                          bottom: BorderSide(color: colors.gridLine),
                        ),
                      ),
                      child:
                          plot ?? Center(child: Text(Fmt.dash, style: muted)),
                    ),
                  ),
                ],
              ),
            ),
            if (showX) ...[
              SizedBox(height: gutter * 0.6),
              Padding(
                padding: EdgeInsets.only(left: showY ? yAxisWidth + gutter : 0),
                child: _XAxis(months: months, style: muted, fmt: fmt),
              ),
            ],
          ],
        );
      },
    );
  }
}

/// The plot's two extremes, pinned to the rules that bound it.
class _YAxis extends StatelessWidget {
  const _YAxis({
    required this.max,
    required this.min,
    required this.format,
    required this.style,
  });

  final double max;
  final double min;
  final String Function(double) format;
  final TextStyle style;

  @override
  Widget build(BuildContext context) {
    // A flat series would print the same figure twice, which reads as a
    // rendering fault rather than as "this has not moved".
    final showMin = (max - min).abs() > 1e-9;

    return LayoutBuilder(
      builder: (context, constraints) {
        final lineHeight = (style.fontSize ?? 8) * (style.height ?? 1.2);

        // Two ticks need two lines' worth of plot to sit at either end of.
        // Short of that the ceiling is the one worth keeping: it is what
        // every bar is measured against, and the floor of a zero-based
        // chart is already implied by the baseline it rests on.
        if (!showMin || constraints.maxHeight < lineHeight * 2) {
          return Align(
            alignment: Alignment.topRight,
            child: _tick(format(max)),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [_tick(format(max)), _tick(format(min))],
        );
      },
    );
  }

  Widget _tick(String text) => FittedBox(
    fit: BoxFit.scaleDown,
    alignment: Alignment.centerRight,
    child: Text(text, maxLines: 1, style: style),
  );
}

/// First, middle and last month under the plot.
///
/// Three ticks, not one per bar: at widget scale a label per month would
/// overlap after about five of them, and this axis is read to place the
/// series in time rather than to identify a particular bar.
///
/// Which three actually appear is decided by measuring them, not by counting
/// months. A narrow widget, a long month name or a Bangla label can each make
/// the middle tick collide with its neighbours, and the middle one is dropped
/// before that happens — the ends bound the range and matter more.
class _XAxis extends StatelessWidget {
  const _XAxis({required this.months, required this.style, required this.fmt});

  final List<WidgetMonth> months;
  final TextStyle style;
  final Fmt fmt;

  /// Clear space either side of the middle tick before it counts as crowded.
  static const _minGap = 8.0;

  @override
  Widget build(BuildContext context) {
    final tick = _tickFormat();

    return LayoutBuilder(
      builder: (context, constraints) {
        final labels = _labelsThatFit(constraints.maxWidth, tick);
        if (labels.isEmpty) return const SizedBox.shrink();

        return Row(
          mainAxisAlignment: labels.length == 1
              ? MainAxisAlignment.start
              : MainAxisAlignment.spaceBetween,
          children: [for (final l in labels) Text(l, style: style)],
        );
      },
    );
  }

  /// Ends first, then the midpoint if there is clear space for it.
  List<String> _labelsThatFit(double width, String Function(int) tick) {
    String at(int i) => tick(months[i].monthStartMs).toUpperCase();

    final last = months.length - 1;
    if (last <= 0) return [at(0)];

    final ends = [at(0), at(last)];
    if (_widthOf(ends) + _minGap > width) return const [];

    // From three months on there is a distinct middle to name; below that
    // the two ends already are every month there is.
    if (months.length < 3) return ends;

    final middle = at(months.length ~/ 2);
    final all = [ends.first, middle, ends.last];
    return _widthOf(all) + _minGap * 2 <= width ? all : ends;
  }

  double _widthOf(List<String> labels) {
    var total = 0.0;
    for (final label in labels) {
      final painter = TextPainter(
        text: TextSpan(text: label, style: style),
        textDirection: TextDirection.ltr,
        maxLines: 1,
      )..layout();
      total += painter.width;
      painter.dispose();
    }
    return total;
  }

  /// A log inside one calendar year does not need the year on every tick.
  String Function(int) _tickFormat() {
    final first = DateTime.fromMillisecondsSinceEpoch(
      months.first.monthStartMs,
    );
    final last = DateTime.fromMillisecondsSinceEpoch(months.last.monthStartMs);
    return first.year == last.year ? fmt.monthAbbrev : fmt.monthYearAbbrev;
  }
}

/// Whole-widget states: no bike, or a bike with nothing logged against it.
class _Message extends StatelessWidget {
  const _Message({
    required this.text,
    required this.colors,
    required this.scale,
  });

  final String text;
  final JatraColors colors;
  final double scale;

  @override
  Widget build(BuildContext context) => Center(
    child: Text(
      text,
      textAlign: TextAlign.center,
      style: _Type.body(scale).copyWith(color: colors.textSecondary),
    ),
  );
}

/// The widget's own type scale.
///
/// [AppText] starts at 40/28/20/16 for numerals, which is the right scale for
/// a phone screen held at reading distance and far too large for a 4×3 tile
/// on a home screen. Same three faces, same tabular figures, smaller steps —
/// and multiplied by [WidgetFace._scale] so a larger widget gets larger type
/// rather than more empty space.
abstract final class _Type {
  static TextStyle numeral(double scale) => TextStyle(
    fontFamily: AppFonts.display,
    fontFamilyFallback: AppFonts.fallback,
    fontSize: 21 * scale,
    height: 1.0,
    fontWeight: FontWeight.w600,
    fontFeatures: const [FontFeature.tabularFigures()],
  );

  /// Height a tile's value row is pinned to, numeral and unit together.
  /// The 1.2 is headroom for the descenders of whichever two faces end up
  /// baseline-aligned in it — Barlow against JetBrains Mono in English,
  /// Hind Siliguri against either in Bangla.
  static double valueRowHeight(double scale) => 21 * scale * 1.2;

  /// 13 — the current value printed beside each chart's title.
  static TextStyle numeralSm(double scale) => TextStyle(
    fontFamily: AppFonts.display,
    fontFamilyFallback: AppFonts.fallback,
    fontSize: 13 * scale,
    height: 1.0,
    fontWeight: FontWeight.w600,
    fontFeatures: const [FontFeature.tabularFigures()],
  );

  static TextStyle unit(double scale) => TextStyle(
    fontFamily: AppFonts.mono,
    fontFamilyFallback: AppFonts.fallback,
    fontSize: 7.5 * scale,
    height: 1.2,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.4,
  );

  static TextStyle label(double scale) => TextStyle(
    fontFamily: AppFonts.body,
    fontFamilyFallback: AppFonts.fallback,
    fontSize: 10.5 * scale,
    height: 1.1,
    fontWeight: FontWeight.w600,
  );

  static TextStyle body(double scale) => TextStyle(
    fontFamily: AppFonts.body,
    fontFamilyFallback: AppFonts.fallback,
    fontSize: 11.5 * scale,
    height: 1.3,
    fontWeight: FontWeight.w400,
  );
}
