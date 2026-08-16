// Draws the pictures Android shows in the widget picker.
//
//     flutter test tool/generate_widget_previews.dart
//
// Run it after changing anything about how a widget looks, and commit what
// it writes. It is deliberately *not* under `test/`, so `flutter test` in CI
// neither runs it nor fails on the files it produces.
//
// Why a generator rather than `android:previewLayout`: the picker renders
// its preview with the app not running, so a widget whose face is a bitmap
// pushed from Flutter has nothing to show — the launcher would draw the
// "open Jatra" placeholder, which is exactly the blank-looking entry this
// exists to fix. `previewLayout` is also API 31+, and below that a widget
// with no `previewImage` falls back to the launcher's default. A picture of
// the real thing works everywhere and is what the entry should show anyway.
//
// The data below is invented, and has to be: there is no user yet at the
// moment the picker is drawn. It is chosen to look like a plausible year of
// riding rather than to flatter — a couple of quiet months, one service, a
// fuel price that drifts.
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'package:jatra/app/theme/app_colors.dart';
import 'package:jatra/core/utils/formatters.dart';
import 'package:jatra/core/utils/money.dart';
import 'package:jatra/l10n/app_localizations.dart';
import 'package:jatra/services/home_widget/offscreen_renderer.dart';
import 'package:jatra/services/home_widget/widget_face.dart';
import 'package:jatra/services/home_widget/widget_shapes.dart';
import 'package:jatra/services/home_widget/widget_snapshot.dart';

/// Light previews sit in `drawable-nodpi`, dark in `drawable-night-nodpi`,
/// so the picker entry matches the sheet it is drawn on.
const _lightDir = 'android/app/src/main/res/drawable-nodpi';
const _darkDir = 'android/app/src/main/res/drawable-night-nodpi';

/// Enough to stay sharp in a picker that scales previews up, without
/// spending a megabyte of APK on pictures of the app.
const _pixelRatio = 2.0;

/// The shape each panel is previewed at: its default placed size, which is
/// the one the picker's entry is promising.
Size _previewShape(WidgetPanel panel) => switch (panel) {
  WidgetPanel.all => panel.shapes[3],
  WidgetPanel.info => panel.shapes[1],
  _ => panel.shapes[1],
};

/// The file name each panel's preview is referenced by from its
/// `appwidget-provider` XML.
String _previewName(WidgetPanel panel) => switch (panel) {
  WidgetPanel.all => 'widget_preview_all',
  WidgetPanel.info => 'widget_preview_info',
  WidgetPanel.spend => 'widget_preview_spend',
  WidgetPanel.distance => 'widget_preview_distance',
  WidgetPanel.fuelCost => 'widget_preview_fuel_cost',
};

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

  testWidgets('write widget previews', (tester) async {
    // English only. Localising the previews would mean a `drawable-bn`
    // set as well, doubling the pictures shipped so that a picker entry is
    // translated for the two seconds before the real widget — which does
    // localise — replaces it.
    final l10n = await L.delegate.load(const Locale('en'));
    final snapshot = _demoSnapshot();

    for (final directory in [_lightDir, _darkDir]) {
      Directory(directory).createSync(recursive: true);
    }

    var total = 0;
    for (final panel in WidgetPanel.values) {
      final size = _previewShape(panel);

      for (final (directory, colors) in [
        (_lightDir, JatraColors.light),
        (_darkDir, JatraColors.dark),
      ]) {
        final png = await tester.runAsync(
          () => OffscreenRenderer.toPng(
            size: size,
            pixelRatio: _pixelRatio,
            child: WidgetFace(
              panel: panel,
              snapshot: snapshot,
              colors: colors,
              l10n: l10n,
              size: size,
            ),
          ),
        );
        expect(png, isNotNull, reason: 'failed to render ${panel.name}');

        final file = File('$directory/${_previewName(panel)}.png')
          ..writeAsBytesSync(png!);
        total += png.length;
        debugPrint('${file.path}  ${png.length ~/ 1024} KB');
      }
    }
    debugPrint('${total ~/ 1024} KB total');
  });
}

/// Fourteen months of plausible riding.
///
/// Every figure on the face is derived from the three series below rather
/// than written out, because a preview that contradicts itself — a headline
/// cost per kilometre the chart underneath it never reaches — is worse than
/// no preview. The rate drifts the way a pump price does; the distance dips
/// in the wet months; a service lands twice.
WidgetSnapshot _demoSnapshot() {
  const distanceKm = <int>[
    742,
    688,
    810,
    776,
    634,
    852,
    764,
    712,
    868,
    798,
    662,
    824,
    748,
    786,
  ];
  const ratePerKm = <double>[
    3.72,
    3.68,
    3.81,
    3.95,
    3.88,
    4.14,
    4.32,
    4.21,
    4.08,
    3.96,
    4.02,
    4.18,
    4.35,
    4.28,
  ];
  const service = <double>[0, 1450, 0, 0, 0, 2100, 0, 0, 0, 1650, 0, 0, 0, 890];
  const other = <double>[900, 0, 0, 0, 1200, 0, 0, 0, 0, 0, 0, 1100, 0, 0];

  final months = [
    for (var i = 0; i < distanceKm.length; i++)
      WidgetMonth(
        monthStartMs: DateTime(2024, i + 1).millisecondsSinceEpoch,
        fuel: distanceKm[i] * ratePerKm[i],
        service: service[i],
        other: other[i],
        distanceM: distanceKm[i] * 1000,
        distance: distanceKm[i].toDouble(),
        fuelCostPerDistance: ratePerKm[i],
      ),
  ];

  final totalDistance = months.fold<double>(0, (sum, m) => sum + m.distance);
  final totalFuel = months.fold<double>(0, (sum, m) => sum + m.fuel);
  final totalSpend = months.fold<double>(0, (sum, m) => sum + m.spend);

  return WidgetSnapshot(
    vehicleName: 'My bike',
    fmt: Fmt(currency: 'BDT', locale: 'en'),
    distanceM: (totalDistance * 1000).round(),
    spend: Money.fromMajor(totalSpend),
    economy: 44.2,
    fuelCostPerDistance: totalFuel / totalDistance,
    months: months,
  );
}
