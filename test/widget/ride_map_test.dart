// RideMap now draws OpenStreetMap tiles under the recorded path.
//
// Tile *images* are not exercised here — flutter_map fetches them over the
// network, and a test that hit tile.openstreetmap.org would be slow, flaky
// and rude. What matters and is checked: the layer is wired up at all, it
// points at OSM, it carries the User-Agent and the attribution OSM's usage
// policy requires, and the path still renders when tiles fail (the offline
// case, which is what `flutter test` naturally simulates since HTTP is
// stubbed out to 400 by default).
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:jatra/app/theme/app_theme.dart';
import 'package:jatra/core/utils/formatters.dart';
import 'package:jatra/data/db/database.dart';
import 'package:jatra/modules/rides/widgets/ride_map.dart';
import 'package:jatra/l10n/app_localizations.dart';

void main() {
  /// Two points about 400 m apart in Dhaka.
  List<RidePointRow> path() => [
    for (var i = 0; i < 6; i++)
      RidePointRow(
        id: i + 1,
        rideId: 1,
        lat: 23.8103 + i * 0.0008,
        lng: 90.4125 + i * 0.0006,
        timestampMs: 1754308800000 + i * 10000,
        isGapStart: false,
      ),
  ];

  Widget host(Widget child) => MaterialApp(
    theme: AppTheme.dark,
    localizationsDelegates: L.localizationsDelegates,
    supportedLocales: L.supportedLocales,
    home: Scaffold(body: child),
  );

  testWidgets('draws an OSM tile layer under the path', (tester) async {
    await tester.pumpWidget(host(RideMap(points: path(), fmt: Fmt())));
    await tester.pump(const Duration(milliseconds: 100));

    final tileLayer = tester.widget<TileLayer>(find.byType(TileLayer));

    expect(
      tileLayer.urlTemplate,
      'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
      reason: 'OSM standard tiles need no API key',
    );
    // OSM blocks clients that do not identify themselves. flutter_map folds
    // `userAgentPackageName` into the provider's User-Agent header rather
    // than keeping it as a field, so that header is what to assert on.
    expect(
      tileLayer.tileProvider.headers['User-Agent'],
      'flutter_map (com.firad.jatra)',
    );
    // And requires visible credit wherever its tiles appear.
    expect(find.text('© OpenStreetMap'), findsOneWidget);
  });

  testWidgets('the path still renders with no tiles available', (tester) async {
    await tester.pumpWidget(host(RideMap(points: path(), fmt: Fmt())));
    await tester.pump(const Duration(milliseconds: 100));

    // No network in `flutter test`, so every tile fails — exactly the
    // offline case. The ride itself must survive that.
    expect(tester.takeException(), isNull);
    expect(find.byType(PolylineLayer), findsOneWidget);
    expect(find.byType(MarkerLayer), findsOneWidget);
    expect(find.textContaining('across'), findsOneWidget); // scale bar
  });

  testWidgets('a ride with no recorded path says so instead of drawing a map', (
    tester,
  ) async {
    await tester.pumpWidget(host(RideMap(points: const [], fmt: Fmt())));
    await tester.pump();

    expect(tester.takeException(), isNull);
    expect(find.byType(FlutterMap), findsNothing);
    expect(find.text('No path recorded for this ride.'), findsOneWidget);
  });
}
