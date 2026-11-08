// The card is a fixed canvas that gets posted publicly, so an overflow would
// be published. Checked with real fonts at awkward lengths.
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jatra/core/utils/card_route.dart';
import 'package:jatra/modules/rides/widgets/ride_card_face.dart';
import 'package:jatra/services/district_map.dart';

Future<void> _font(String family, List<String> files) async {
  final loader = FontLoader(family);
  for (final file in files) {
    final bytes = File('assets/fonts/$file').readAsBytesSync();
    loader.addFont(Future.value(ByteData.sublistView(bytes)));
  }
  await loader.load();
}

RideCardContent _content({
  String from = 'Dhaka',
  String to = "Cox's Bazar",
  String username = 'Sakib',
  String bike = 'Pulsar 150',
  ui.Image? photo,
  CardRoute route = CardRoute.empty,
}) => RideCardContent(
  from: from,
  to: to,
  date: '8 Nov 2026',
  username: username,
  bikeName: bike,
  route: route,
  highlightedDistricts: const {'Dhaka'},
  photo: photo,
  stats: const [
    RideCardStat(label: 'Distance', value: '12,398', unit: 'KM'),
    RideCardStat(label: 'Moving time', value: '128h 12m'),
    RideCardStat(label: 'True cost', value: '৳1,234,567'),
  ],
);

void main() {
  final districts = DistrictMap.parse(
    File('assets/geo/bd_districts.json').readAsStringSync(),
  );
  final route = CardRoute.fromPoints([
    for (var i = 0; i < 300; i++)
      (lat: 23.8 - i * 0.008, lng: 90.4 + i * 0.005, isGapStart: false),
  ]);

  setUpAll(() async {
    await _font('BarlowCondensed', ['BarlowCondensed-Bold.ttf']);
    await _font('Inter', ['Inter-Regular.ttf', 'Inter-SemiBold.ttf']);
    await _font('HindSiliguri', ['HindSiliguri-Regular.ttf']);
  });

  final cases = <String, RideCardContent>{
    'map with route': _content(route: route),
    'no route': _content(),
    'no name or bike': _content(username: '', bike: ''),
    'no places': _content(from: '', to: ''),
    'very long text': _content(
      from: 'ব্রাহ্মণবাড়িয়া জেলার একটি অনেক লম্বা জায়গার নাম',
      to: 'A destination with an extremely long name indeed',
      username: 'A rider whose name goes on and on and on forever',
      bike: 'A bike whose name also goes on and on and on',
      route: route,
    ),
  };

  for (final MapEntry(:key, :value) in cases.entries) {
    testWidgets('$key lays out cleanly', (tester) async {
      tester.view.physicalSize = RideCardFace.size;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: Center(
            child: RideCardFace(content: value, districts: districts),
          ),
        ),
      );

      expect(tester.takeException(), isNull);
    });
  }
}
