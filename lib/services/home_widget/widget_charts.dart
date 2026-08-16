import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Charts sized for a home-screen widget.
///
/// The statistics screen's `fl_chart` charts are not reused here, and not
/// because of the dependency: they reserve 44px for a value axis and 28px
/// for a date axis, which is more than the entire height available to a
/// chart in a 4×3 widget. At this size axes are noise anyway — the figure
/// above the chart already says what the last bar is worth, and the shape is
/// the whole message.
///
/// Each painter is handed values already in the vehicle's units, and draws
/// bottom-anchored from zero so bar heights stay comparable between the
/// spend and distance charts.
abstract final class WidgetChartStyle {
  /// Bars never get thinner than this. Past ~60 months in the log the bars
  /// start touching instead, which reads as an area chart — still honest,
  /// just denser.
  static const minBarWidth = 1.5;
  static const maxBarWidth = 10.0;

  /// Nominal gap between bars, given up first as the series grows.
  static const barGap = 2.0;

  static const lineWidth = 1.6;

  /// Segment separator inside a stacked bar, drawn as a gap rather than a
  /// stroke so it works on any background.
  static const stackGap = 1.0;

  /// Bar width and gap for [count] bars across [width].
  ///
  /// Always spends the full width, so the last bar sits on the right edge
  /// under the last x-axis tick and the first sits on the left under the
  /// first. Spare room widens the gaps rather than the bars — a six-month
  /// log should not be drawn as six slabs.
  static ({double bar, double gap}) fit(int count, double width) {
    if (count <= 0) return (bar: 0, gap: 0);
    if (count == 1) return (bar: math.min(maxBarWidth, width), gap: 0);

    final ideal = (width - barGap * (count - 1)) / count;

    if (ideal > maxBarWidth) {
      return (
        bar: maxBarWidth,
        gap: (width - maxBarWidth * count) / (count - 1),
      );
    }
    if (ideal >= minBarWidth) return (bar: ideal, gap: barGap);

    // Too many months to keep a gap: give the gap up entirely and let the
    // bars butt together, which reads as an area chart. Still honest, just
    // denser.
    return (bar: math.max(width / count, 0.5), gap: 0);
  }
}

/// Stacked monthly bars — fuel, service, other — or plain bars when only one
/// segment is supplied.
class WidgetBarChart extends StatelessWidget {
  const WidgetBarChart({
    super.key,
    required this.stacks,
    required this.colours,
  });

  /// Per month, the segments bottom-up. All entries must be the same length.
  final List<List<double>> stacks;

  /// One colour per segment index.
  final List<Color> colours;

  @override
  Widget build(BuildContext context) =>
      CustomPaint(painter: _BarPainter(stacks, colours), size: Size.infinite);
}

class _BarPainter extends CustomPainter {
  const _BarPainter(this.stacks, this.colours);

  final List<List<double>> stacks;
  final List<Color> colours;

  @override
  void paint(Canvas canvas, Size size) {
    if (stacks.isEmpty) return;

    final totals = [
      for (final stack in stacks) stack.fold<double>(0, (sum, v) => sum + v),
    ];
    final maxTotal = totals.reduce((a, b) => a > b ? a : b);
    if (maxTotal <= 0) return;

    final metrics = WidgetChartStyle.fit(stacks.length, size.width);
    final step = metrics.bar + metrics.gap;

    final paint = Paint()..style = PaintingStyle.fill;
    final scale = size.height / maxTotal;

    for (var i = 0; i < stacks.length; i++) {
      final left = i * step;
      var cursor = size.height;

      for (var s = 0; s < stacks[i].length; s++) {
        final value = stacks[i][s];
        if (value <= 0) continue;

        final height = value * scale;
        final top = cursor - height;
        paint.color = colours[s % colours.length];

        // Only the topmost segment of the tallest bar earns a rounded cap;
        // rounding every segment at this size turns a 3px bar into a dot.
        final rect = Rect.fromLTRB(left, top, left + metrics.bar, cursor);
        if (s == stacks[i].length - 1 && metrics.bar >= 4 && height >= 4) {
          canvas.drawRRect(
            RRect.fromRectAndCorners(
              rect,
              topLeft: const Radius.circular(1.5),
              topRight: const Radius.circular(1.5),
            ),
            paint,
          );
        } else {
          canvas.drawRect(rect, paint);
        }

        cursor = top - WidgetChartStyle.stackGap;
      }
    }
  }

  @override
  bool shouldRepaint(_BarPainter old) =>
      old.stacks != stacks || old.colours != colours;
}

/// A single line over the months, with a soft fill beneath it.
///
/// Nulls are gaps, not zeros: a month with no measured distance has no cost
/// per kilometre, and drawing it at the baseline would invent a free month.
class WidgetLineChart extends StatelessWidget {
  const WidgetLineChart({
    super.key,
    required this.values,
    required this.colour,
  });

  final List<double?> values;
  final Color colour;

  @override
  Widget build(BuildContext context) =>
      CustomPaint(painter: _LinePainter(values, colour), size: Size.infinite);
}

class _LinePainter extends CustomPainter {
  const _LinePainter(this.values, this.colour);

  final List<double?> values;
  final Color colour;

  @override
  void paint(Canvas canvas, Size size) {
    final present = values.whereType<double>().toList();
    if (present.length < 2) {
      // One reading is a dot, not a line. Drawn mid-height, because a single
      // point carries no scale to place itself against.
      if (present.length == 1) {
        canvas.drawCircle(
          Offset(size.width / 2, size.height / 2),
          WidgetChartStyle.lineWidth,
          Paint()..color = colour,
        );
      }
      return;
    }

    final min = present.reduce((a, b) => a < b ? a : b);
    final max = present.reduce((a, b) => a > b ? a : b);

    // A flat series would divide by zero and, worse, render as a line pinned
    // to one edge. Give it a nominal span so it draws through the middle.
    final span = (max - min).abs() < 1e-9 ? 1.0 : max - min;
    final base = (max - min).abs() < 1e-9 ? min - 0.5 : min;

    final dx = values.length == 1 ? 0.0 : size.width / (values.length - 1);
    // Inset so the stroke is not clipped in half at the top and bottom.
    final inset = WidgetChartStyle.lineWidth;
    final usableHeight = size.height - inset * 2;

    Offset pointAt(int i, double value) => Offset(
      i * dx,
      inset + usableHeight - ((value - base) / span) * usableHeight,
    );

    // One subpath per unbroken run, so a gap month lifts the pen instead of
    // drawing a straight line across a period that was never measured.
    final line = Path();
    final fill = Path();
    var penDown = false;
    Offset? runStart;
    Offset? last;

    void closeRun() {
      final start = runStart;
      final end = last;
      if (penDown && start != null && end != null && end != start) {
        fill
          ..lineTo(end.dx, size.height)
          ..lineTo(start.dx, size.height)
          ..close();
      }
      penDown = false;
    }

    for (var i = 0; i < values.length; i++) {
      final value = values[i];
      if (value == null) {
        closeRun();
        continue;
      }

      final point = pointAt(i, value);
      if (!penDown) {
        line.moveTo(point.dx, point.dy);
        fill.moveTo(point.dx, point.dy);
        runStart = point;
        penDown = true;
      } else {
        line.lineTo(point.dx, point.dy);
        fill.lineTo(point.dx, point.dy);
      }
      last = point;
    }
    closeRun();

    canvas
      ..drawPath(fill, Paint()..color = colour.withValues(alpha: 0.14))
      ..drawPath(
        line,
        Paint()
          ..color = colour
          ..style = PaintingStyle.stroke
          ..strokeWidth = WidgetChartStyle.lineWidth
          ..strokeJoin = StrokeJoin.round
          ..strokeCap = StrokeCap.round,
      );

    // Mark where the series ends — the figure printed above the chart is
    // this point, and the dot ties the two together.
    if (last != null) {
      canvas.drawCircle(
        last,
        WidgetChartStyle.lineWidth,
        Paint()..color = colour,
      );
    }
  }

  @override
  bool shouldRepaint(_LinePainter old) =>
      old.values != values || old.colour != colour;
}
