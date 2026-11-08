import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:jatra/core/utils/card_route.dart';
import 'package:jatra/services/district_map.dart';

/// Straight north, about 111 m per step.
List<({double lat, double lng, bool isGapStart})> _line(
  int steps, {
  int? gapAt,
}) => [
  for (var i = 0; i < steps; i++)
    (lat: 23 + i * 0.001, lng: 90.0, isGapStart: i == gapAt),
];

void main() {
  group('CardRoute', () {
    test('never includes the first or last kilometre', () {
      final route = CardRoute.fromPoints(_line(100));
      final kept = route.segments.expand((s) => s).toList();

      // 1 km is about 9 steps of 111 m.
      expect(kept.first.lat, greaterThan(23.0085));
      expect(kept.last.lat, lessThan(23 + 99 * 0.001 - 0.0085));
    });

    test('a ride too short to hide its ends draws nothing', () {
      expect(CardRoute.fromPoints(_line(20)).isEmpty, isTrue);
    });

    test('a recording gap stays a gap', () {
      expect(
        CardRoute.fromPoints(_line(100, gapAt: 50)).segments,
        hasLength(2),
      );
    });

    test('a long ride is thinned to what a card can show', () {
      final points = CardRoute.fromPoints(
        _line(20000),
      ).segments.expand((s) => s);

      expect(points.length, lessThanOrEqualTo(CardRoute.maxPoints + 1));
    });
  });

  group('DistrictMap', () {
    final map = DistrictMap.parse(
      File('assets/geo/bd_districts.json').readAsStringSync(),
    );

    test('holds all 64 districts, named in both languages', () {
      expect(map.districts, hasLength(64));
      expect(
        map.districts.every((d) => d.en.isNotEmpty && d.bn.isNotEmpty),
        isTrue,
      );
    });

    test('finds well-known places', () {
      expect(map.locate(23.8103, 90.4125)?.en, 'Dhaka');
      expect(map.locate(24.8949, 91.8687)?.en, 'Sylhet');
      expect(map.locate(22.3569, 91.7832)?.en, 'Chattogram');
      expect(map.locate(21.4272, 92.0058)?.en, "Cox's Bazar");
      expect(map.locate(24.3745, 88.6042)?.en, 'Rajshahi');
      expect(map.locate(26.3360, 88.5517)?.en, 'Panchagarh');
    });

    test('names follow the language', () {
      expect(map.locate(23.8103, 90.4125)?.nameIn('bn'), 'ঢাকা');
    });

    test('is null outside the country', () {
      expect(map.locate(19.0, 90.0), isNull);
      expect(map.locate(28.6, 77.2), isNull);
    });
  });
}
