// The home-screen widget, from data to bitmap.
//
// Two things here are worth a test and neither is reachable through the app's
// own screens:
//
//  1. `OffscreenRenderer` drives a render tree by hand — no MaterialApp, no
//     binding-owned view. If that recipe breaks on a Flutter upgrade it fails
//     silently in production, because a widget that cannot be drawn is caught
//     and logged rather than thrown.
//  2. `WidgetFace` is laid out to a fixed pixel box that Android chose. There
//     is nothing to scroll and nowhere for a long figure to go, so an
//     overflow is a black-and-yellow stripe on someone's home screen.
//
// Both are checked at the extremes of the size range the provider allows.
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'package:jatra/app/theme/app_colors.dart';
import 'package:jatra/core/utils/formatters.dart';
import 'package:jatra/core/utils/money.dart';
import 'package:jatra/data/models/enums.dart';
import 'package:jatra/l10n/app_localizations.dart';
import 'package:jatra/services/home_widget/offscreen_renderer.dart';
import 'package:jatra/services/home_widget/widget_face.dart';
import 'package:jatra/services/home_widget/widget_shapes.dart';
import 'package:jatra/services/home_widget/widget_snapshot.dart';

/// Loads a bundled font family off disk into the test's font collection.
///
/// Without this every `Text` renders in the test framework's placeholder
/// font, whose metrics are nothing like Barlow's or Hind Siliguri's — and
/// the overflows this file exists to catch are exactly the ones caused by
/// real metrics. A tile whose value row is a pixel and a half taller than
/// predicted passes against the placeholder and stripes a home screen.
Future<void> _loadFont(String family, List<String> files) async {
  final loader = FontLoader(family);
  for (final file in files) {
    final bytes = File('assets/fonts/$file').readAsBytesSync();
    loader.addFont(Future.value(ByteData.sublistView(bytes)));
  }
  await loader.load();
}

void main() {
  setUpAll(initializeDateFormatting);

  setUpAll(() async {
    await _loadFont('BarlowCondensed', [
      'BarlowCondensed-Regular.ttf',
      'BarlowCondensed-Medium.ttf',
      'BarlowCondensed-SemiBold.ttf',
      'BarlowCondensed-Bold.ttf',
    ]);
    await _loadFont('Inter', [
      'Inter-Regular.ttf',
      'Inter-Medium.ttf',
      'Inter-SemiBold.ttf',
    ]);
    await _loadFont('JetBrainsMono', [
      'JetBrainsMono-Regular.ttf',
      'JetBrainsMono-Medium.ttf',
    ]);
    await _loadFont('HindSiliguri', [
      'HindSiliguri-Regular.ttf',
      'HindSiliguri-Medium.ttf',
      'HindSiliguri-SemiBold.ttf',
    ]);
  });

  late L en;
  late L bn;

  setUp(() async {
    en = await L.delegate.load(const Locale('en'));
    bn = await L.delegate.load(const Locale('bn'));
  });

  /// Twenty months of it, which is more than the bars can keep a gap
  /// between — the case the widget actually ships into after a couple of
  /// years of logging.
  WidgetSnapshot snapshot({
    int months = 20,
    bool withDistance = true,
    String currency = 'BDT',
  }) {
    final fmt = Fmt(currency: currency, locale: 'en');
    return WidgetSnapshot(
      vehicleName: 'Yamaha FZS',
      fmt: fmt,
      distanceM: withDistance ? 24180000 : 0,
      spend: const Money(8642000),
      economy: 44.2,
      // No measured distance means no cost per distance either — the same
      // guard the calculator applies.
      fuelCostPerDistance: withDistance ? 2.414 : null,
      months: [
        for (var i = 0; i < months; i++)
          WidgetMonth(
            monthStartMs: DateTime.utc(2024, i + 1).millisecondsSinceEpoch,
            fuel: 3200 + i * 90,
            service: i.isEven ? 0 : 1450,
            other: i % 5 == 0 ? 900 : 0,
            distanceM: withDistance ? (780 + i * 12) * 1000 : 0,
            distance: withDistance ? 780 + i * 12 : 0,
            // A month with no second odometer reading has no cost per
            // kilometre. The line must break there rather than plot zero.
            fuelCostPerDistance: !withDistance || i == 4
                ? null
                : 2.1 + i * 0.04,
          ),
      ],
    );
  }

  Widget face(
    WidgetSnapshot data,
    Size size, {
    L? l10n,
    JatraColors? colors,
    WidgetPanel? panel,
  }) => MediaQuery(
    data: MediaQueryData(size: size, textScaler: TextScaler.noScaling),
    child: Directionality(
      textDirection: TextDirection.ltr,
      child: Center(
        child: WidgetFace(
          panel: panel ?? WidgetPanel.all,
          snapshot: data,
          colors: colors ?? JatraColors.dark,
          l10n: l10n ?? en,
          size: size,
        ),
      ),
    ),
  );

  group('WidgetFace', () {
    // Every shape the app actually draws, plus the extremes of the range the
    // provider allows a widget to be dragged to.
    for (final panel in WidgetPanel.values) {
      for (final size in [
        ...panel.shapes,
        const Size(140, 100),
        const Size(800, 800),
      ]) {
        testWidgets('${panel.name} lays out at ${size.width}x${size.height}', (
          tester,
        ) async {
          tester.view.physicalSize = const Size(1200, 1200);
          tester.view.devicePixelRatio = 1;
          addTearDown(tester.view.reset);

          await tester.pumpWidget(face(snapshot(), size, panel: panel));

          expect(tester.takeException(), isNull);
          // The vehicle's name is the first thing dropped when a panel runs
          // out of height, so it is only asserted where there is room for
          // it — the panel's largest shape.
          if (size == panel.shapes.last) {
            expect(find.text('Yamaha FZS'), findsOneWidget);
          }
        });
      }
    }

    testWidgets('shows all-time totals, not a month', (tester) async {
      await tester.pumpWidget(face(snapshot(), const Size(400, 220)));

      expect(find.text('24,180'), findsOneWidget); // distance, km
      expect(find.text('৳86,420'), findsOneWidget); // running cost
      expect(find.text('44.2'), findsOneWidget); // economy
      expect(find.text('৳2.41'), findsOneWidget); // fuel cost per km
      expect(find.text('ALL TIME'), findsOneWidget);
    });

    testWidgets('follows the vehicle to miles and dollars', (tester) async {
      final fmt = Fmt(
        distanceUnit: DistanceUnit.mi,
        volumeUnit: VolumeUnit.gal,
        currency: 'USD',
        locale: 'en',
      );
      final data = WidgetSnapshot(
        vehicleName: 'Bonneville',
        fmt: fmt,
        distanceM: 24180000,
        spend: const Money(120000),
        economy: 58.4,
        fuelCostPerDistance: 0.079,
        months: snapshot().months,
      );

      await tester.pumpWidget(face(data, const Size(400, 220)));

      expect(find.text('15,025'), findsOneWidget); // miles, not km
      expect(find.text(r'$1,200'), findsOneWidget);
      expect(find.text('MI/GAL'), findsOneWidget);
      // Sub-unit rates get a third decimal — see MoneyFormatter.formatRate.
      expect(find.text(r'$0.079'), findsOneWidget);
    });

    testWidgets('costs per km on fuel alone, and says so', (tester) async {
      final data = WidgetSnapshot(
        vehicleName: 'Yamaha FZS',
        fmt: Fmt(currency: 'BDT', locale: 'en'),
        distanceM: 1000000,
        spend: const Money(500000),
        economy: 44.2,
        // Fuel is ৳2.00/km here; running cost — the figure that folds in
        // servicing and fixed costs — would be ৳5.00/km. Only the first may
        // appear, unexplained on a home screen the second reads as the
        // pump figure and overstates it.
        fuelCostPerDistance: 2,
        months: snapshot().months,
      );

      await tester.pumpWidget(face(data, const Size(320, 330)));

      expect(find.text('৳2.00'), findsOneWidget);
      expect(find.text('৳5.00'), findsNothing);
      expect(
        find.text(en.widgetFuelCostPer('/KM').toUpperCase()),
        findsNWidgets(2),
      );
    });

    testWidgets('stacks the charts with x and y ticks', (tester) async {
      await tester.pumpWidget(face(snapshot(months: 14), const Size(320, 330)));

      // All three charts, each with its own axes.
      expect(find.text('MONTHLY SPEND'), findsOneWidget);
      expect(find.text('DISTANCE PER MONTH'), findsOneWidget);

      // x ticks: first, middle and last month of the series. The log spans
      // two calendar years, so each carries one.
      expect(find.text('JAN 24'), findsNWidgets(3));
      expect(find.text('FEB 25'), findsNWidgets(3));

      // y ticks: a zero-based chart names its baseline, and every chart
      // names its ceiling.
      expect(find.text('৳0'), findsOneWidget);
      expect(find.text('0'), findsOneWidget);
    });

    testWidgets('drops the year from x ticks inside one year', (tester) async {
      await tester.pumpWidget(face(snapshot(months: 6), const Size(320, 330)));

      expect(find.text('JAN'), findsNWidgets(3));
      expect(find.text('JAN 24'), findsNothing);
    });

    // A three-month log has a first, a middle and a last, and used to show
    // only the ends — the middle tick was gated on an arbitrary five months
    // rather than on whether it fits.
    testWidgets('names the middle month from three months on', (tester) async {
      await tester.pumpWidget(face(snapshot(months: 3), const Size(320, 350)));

      expect(find.text('JAN'), findsNWidgets(3));
      expect(find.text('FEB'), findsNWidgets(3));
      expect(find.text('MAR'), findsNWidgets(3));
    });

    // 140dp is the provider's minResizeWidth, so in practice the midpoint
    // survives everywhere a widget can actually be dragged to. The guard is
    // for the launchers that ignore that floor.
    testWidgets('keeps the middle tick down to the resize floor', (
      tester,
    ) async {
      await tester.pumpWidget(face(snapshot(months: 14), const Size(140, 350)));

      expect(tester.takeException(), isNull);
      expect(find.text('AUG 24'), findsWidgets);
    });

    testWidgets('drops the middle tick below it rather than colliding', (
      tester,
    ) async {
      await tester.pumpWidget(face(snapshot(months: 14), const Size(130, 350)));

      expect(tester.takeException(), isNull);
      expect(find.text('AUG 24'), findsNothing);
      // The ends still bound the range; only the midpoint gives way.
      expect(find.text('JAN 24'), findsWidgets);
    });

    testWidgets('gives the figures the whole face on a strip', (tester) async {
      // Too short for even one chart: the tiles take the height instead of
      // sitting above an empty half.
      await tester.pumpWidget(face(snapshot(), const Size(380, 96)));

      expect(tester.takeException(), isNull);
      expect(find.text('24,180'), findsOneWidget);
      expect(find.text('MONTHLY SPEND'), findsNothing);
    });

    testWidgets('sheds charts rather than crushing them', (tester) async {
      // A 4x3 widget has room for the tiles and two charts, not three.
      await tester.pumpWidget(face(snapshot(), const Size(320, 180)));

      expect(tester.takeException(), isNull);
      expect(find.text('MONTHLY SPEND'), findsOneWidget);
      expect(find.text('DISTANCE PER MONTH'), findsOneWidget);
      expect(
        find.text(en.widgetFuelCostPer('/KM').toUpperCase()),
        // The tile only — the third chart is dropped.
        findsOneWidget,
      );
    });

    testWidgets('says so when there is no bike', (tester) async {
      await tester.pumpWidget(
        face(WidgetSnapshot.empty(Fmt(locale: 'en')), const Size(320, 180)),
      );

      expect(find.text(en.widgetNoBike), findsOneWidget);
      expect(find.text('ALL TIME'), findsNothing);
    });

    testWidgets('renders Bangla without falling back to tofu', (tester) async {
      await tester.pumpWidget(face(snapshot(), const Size(320, 180), l10n: bn));

      expect(tester.takeException(), isNull);
      // Words translate; instrument readings stay in Latin digits.
      expect(find.text(bn.statsRangeAllTime.toUpperCase()), findsOneWidget);
      expect(find.text('24,180'), findsOneWidget);
    });

    testWidgets('holds up in the light theme', (tester) async {
      await tester.pumpWidget(
        face(snapshot(), const Size(320, 180), colors: JatraColors.light),
      );

      expect(tester.takeException(), isNull);
    });

    testWidgets('hides the distance charts until a month is measured', (
      tester,
    ) async {
      await tester.pumpWidget(
        face(snapshot(withDistance: false), const Size(320, 330)),
      );

      expect(tester.takeException(), isNull);
      // Both distance-derived charts fall back to a dash rather than a chart
      // of zeros, and so does the cost-per-km tile. The spend chart and the
      // three money figures still draw.
      expect(find.text(Fmt.dash), findsNWidgets(3));
      expect(find.text('৳86,420'), findsOneWidget);
    });
  });

  // `toImage` is completed by the engine's raster thread. Awaiting it under
  // `testWidgets`' fake clock deadlocks — the future can only complete on the
  // real one — so every render here runs inside `runAsync`.
  group('OffscreenRenderer', () {
    testWidgets('produces a PNG at the requested pixel size', (tester) async {
      const size = Size(320, 180);
      const ratio = 2.5;

      final png = await tester.runAsync(
        () => OffscreenRenderer.toPng(
          size: size,
          pixelRatio: ratio,
          child: WidgetFace(
            panel: WidgetPanel.all,
            snapshot: snapshot(),
            colors: JatraColors.dark,
            l10n: en,
            size: size,
          ),
        ),
      );

      expect(png, isNotNull);
      expect(png!.length, greaterThan(1000));

      // PNG magic, then the IHDR width and height as big-endian uint32s at
      // offsets 16 and 20. Cheaper than decoding, and it proves the render
      // honoured pixelRatio rather than drawing at 1x.
      expect(png.sublist(1, 4), equals('PNG'.codeUnits));
      final header = png.buffer.asByteData();
      expect(header.getUint32(16), (size.width * ratio).round());
      expect(header.getUint32(20), (size.height * ratio).round());
    });

    testWidgets('renders the no-bike face too', (tester) async {
      final png = await tester.runAsync(
        () => OffscreenRenderer.toPng(
          size: const Size(250, 110),
          pixelRatio: 2,
          child: WidgetFace(
            panel: WidgetPanel.all,
            snapshot: WidgetSnapshot.empty(Fmt(locale: 'en')),
            colors: JatraColors.light,
            l10n: en,
            size: const Size(250, 110),
          ),
        ),
      );

      expect(png, isNotNull);
    });
  });
}
