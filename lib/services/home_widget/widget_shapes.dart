import 'dart:ui' show Size;

/// The home-screen widgets Jatra offers, and the shapes each is drawn at.
///
/// Five separate widgets rather than one, because a home screen is personal:
/// somebody who only wants to watch fuel prices should be able to put that
/// one chart on it without the other two and four figures coming along.
/// [all] is still there for anyone who wants the lot in one place.
///
/// **Every name here is also a component in `AndroidManifest.xml`.** Renaming
/// one without renaming its provider class orphans the widgets people have
/// already placed, so treat these as fixed.
enum WidgetPanel {
  /// Everything: the four figures over all three charts.
  all(_stackShapes),

  /// The four figures alone — distance, spend, average, fuel cost per unit.
  /// A strip, so its shapes run much wider than the rest.
  info(_stripShapes),

  /// Monthly spend, split by fuel, service and everything else.
  spend(_chartShapes),

  /// Distance per month.
  distance(_chartShapes),

  /// Fuel cost per distance unit, month by month.
  fuelCost(_chartShapes);

  const WidgetPanel(this.shapes);

  /// The sizes this panel's face is drawn at, widest first.
  ///
  /// The widget is a bitmap, so it can only be redrawn while the app is
  /// running — and a resize happens on the home screen, with the app closed.
  /// Rendering one bitmap per placed widget therefore meant a resized widget
  /// kept its old proportions until the next time the app was opened, which
  /// for a fuel tracker can be a fortnight. It read as a widget that could
  /// not be resized at all.
  ///
  /// So the app draws each face once per shape instead. Android keeps them
  /// all and, the moment a widget is resized, picks the one whose aspect
  /// ratio is closest and scales it to fit. Resizing is immediate and needs
  /// no Flutter at all.
  ///
  /// Uniform scaling is what makes that honest: the layout is chosen for the
  /// shape rather than the exact pixel size, and stretching a 320dp-wide
  /// face across a 480dp widget only makes the same design larger — which is
  /// what a bigger widget should look like anyway.
  ///
  /// The widths are deliberately close together, so [aspectOf] is what
  /// really separates one shape from the next.
  final List<Size> shapes;

  static double aspectOf(Size shape) => shape.width / shape.height;

  /// 4x1 up to 4x5. The stack needs the height: three charts with axes.
  static const _stackShapes = [
    Size(380, 145),
    Size(340, 200),
    Size(330, 280),
    Size(320, 350),
    Size(320, 460),
  ];

  /// 4x1 up to 4x3. Four figures need width, not height — even the tallest
  /// here only buys them room to breathe.
  static const _stripShapes = [
    Size(400, 72),
    Size(380, 100),
    Size(350, 140),
    Size(330, 200),
  ];

  /// 4x1 up to 4x4. One chart reads at a single row and improves all the way
  /// up, since the height goes straight into the plot.
  static const _chartShapes = [
    Size(400, 90),
    Size(380, 130),
    Size(350, 180),
    Size(330, 250),
    Size(320, 340),
  ];
}
