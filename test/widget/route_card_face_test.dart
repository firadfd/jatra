import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jatra/core/calc/place_route.dart';
import 'package:jatra/l10n/app_localizations.dart';
import 'package:jatra/modules/route_planner/widgets/route_card_face.dart';
import 'package:jatra/services/district_map.dart';
import 'package:jatra/services/place_network.dart';

void main() {
  final map = DistrictMap.parse(
    File('assets/geo/bd_districts.json').readAsStringSync(),
  );
  final network = PlaceNetwork.parse(
    File('assets/geo/bd_upazilas.json').readAsStringSync(),
  );

  setUpAll(() async {
    final loader = FontLoader('HindSiliguri');
    for (final file in [
      'HindSiliguri-Regular.ttf',
      'HindSiliguri-Medium.ttf',
      'HindSiliguri-SemiBold.ttf',
    ]) {
      final bytes = File('assets/fonts/$file').readAsBytesSync();
      loader.addFont(Future.value(ByteData.sublistView(bytes)));
    }
    await loader.load();
  });

  for (final locale in ['en', 'bn']) {
    final routes = <String, PlaceRoute?>{
      'none': null,
      'same': PlaceRouter.find(network, 'feni.feni-sadar', 'feni.feni-sadar'),
      'local': PlaceRouter.find(
        network,
        'rangpur.rangpur-sadar',
        'rangpur.pirganj',
      ),
      'long': PlaceRouter.find(
        network,
        'panchagarh.panchagarh-sadar',
        'cox-s-bazar.cox-s-bazar-sadar',
      ),
    };
    for (final MapEntry(:key, :value) in routes.entries) {
      for (final name in ['', 'Firad', 'A very long rider name indeed ' * 4]) {
        testWidgets('$locale, $key route, ${name.length} name', (tester) async {
          tester.view.physicalSize = RouteCardFace.size;
          tester.view.devicePixelRatio = 1;
          addTearDown(tester.view.reset);

          await tester.pumpWidget(
            Directionality(
              textDirection: TextDirection.ltr,
              child: RouteCardFace(
                districts: map,
                l: lookupL(Locale(locale)),
                content: RouteCardContent(
                  route: value,
                  distanceM: value?.estimatedM,
                  isEstimate: true,
                  name: name,
                  locale: locale,
                  distanceText: '123,456',
                  distanceUnit: 'KM',
                ),
              ),
            ),
          );

          expect(tester.takeException(), isNull);
        });
      }
    }
  }

  for (final locale in ['en', 'bn']) {
    testWidgets('$locale card holds a long name, bike and photo', (
      tester,
    ) async {
      tester.view.physicalSize = RouteCardFace.size;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      final image = await tester.runAsync(() {
        final recorder = ui.PictureRecorder();
        Canvas(recorder).drawColor(const Color(0xFF336699), BlendMode.src);
        return recorder.endRecording().toImage(64, 64);
      });
      addTearDown(image!.dispose);

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: RouteCardFace(
            districts: map,
            l: lookupL(Locale(locale)),
            content: RouteCardContent(
              route: PlaceRouter.find(
                network,
                'kurigram.kurigram-sadar',
                'dhaka.dhaka-city',
              ),
              distanceM: 300000,
              isEstimate: false,
              name: 'A very long rider name indeed ' * 4,
              bike: 'A very long motorcycle name as well ' * 4,
              photo: image,
              locale: locale,
              distanceText: '300',
              distanceUnit: 'KM',
            ),
          ),
        ),
      );

      expect(tester.takeException(), isNull);
      expect(find.byType(RawImage), findsOneWidget);
    });
  }

  testWidgets('tapping the map reports a point on land', (tester) async {
    tester.view.physicalSize = RouteCardFace.size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final tapped = <({double lat, double lng})>[];

    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: RouteCardFace(
          districts: map,
          l: lookupL(const Locale('en')),
          onMapTap: (lat, lng) => tapped.add((lat: lat, lng: lng)),
          content: const RouteCardContent(
            route: null,
            distanceM: null,
            isEstimate: true,
            name: '',
            locale: 'en',
            distanceText: '',
            distanceUnit: 'KM',
          ),
        ),
      ),
    );
    await tester.tap(find.byType(GestureDetector));

    expect(tapped, hasLength(1));
    expect(map.locate(tapped.single.lat, tapped.single.lng), isNotNull);
  });

  test('Bangla cards use Bangla digits', () {
    expect(localDigits('398', 'bn'), '৩৯৮');
    expect(localDigits('398', 'en'), '398');
  });
}
