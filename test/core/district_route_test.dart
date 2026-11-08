import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:jatra/core/calc/district_route.dart';
import 'package:jatra/services/district_map.dart';

void main() {
  final map = DistrictMap.parse(
    File('assets/geo/bd_districts.json').readAsStringSync(),
  );
  List<String> names(DistrictRoute r) => [for (final d in r.districts) d.en];

  test('every district can reach every other', () {
    for (final d in map.districts) {
      expect(DistrictRouter.find(map, 'Dhaka', d.en), isNotNull, reason: d.en);
    }
  });

  test('neighbours are recorded in both directions', () {
    final byName = {for (final d in map.districts) d.en: d};
    for (final d in map.districts) {
      for (final n in d.neighbours) {
        expect(byName[n]!.neighbours, contains(d.en));
      }
    }
  });

  test('a route runs start to end through neighbours', () {
    final route = DistrictRouter.find(map, 'Dhaka', "Cox's Bazar")!;
    final byName = {for (final d in map.districts) d.en: d};
    final chain = names(route);

    expect(chain.first, 'Dhaka');
    expect(chain.last, "Cox's Bazar");
    for (var i = 1; i < chain.length; i++) {
      expect(byName[chain[i - 1]]!.neighbours, contains(chain[i]));
    }
  });

  test('estimates land near well-known road distances', () {
    void near(String from, String to, double km) {
      final estimate = DistrictRouter.find(map, from, to)!.estimatedM / 1000;
      expect(estimate, closeTo(km, km * 0.25), reason: '$from to $to');
    }

    near('Dhaka', 'Chattogram', 250);
    near('Dhaka', "Cox's Bazar", 390);
    near('Dhaka', 'Sylhet', 240);
    near('Dhaka', 'Rajshahi', 255);
    near('Dhaka', 'Rangpur', 300);
  });

  test('the same district is a route of one with no distance', () {
    final route = DistrictRouter.find(map, 'Feni', 'Feni')!;

    expect(names(route), ['Feni']);
    expect(route.estimatedM, 0);
  });

  group('search', () {
    List<String> search(String query) => [
      for (final d in map.districts)
        if (d.matches(query)) d.en,
    ];

    test('finds part of an English name, in any case', () {
      expect(search('KURI'), ['Kurigram']);
    });

    test('finds a Bangla name', () {
      expect(search('কুড়িগ্রাম'), ['Kurigram']);
    });

    test('finds former spellings', () {
      expect(search('chittagong'), ['Chattogram']);
      expect(search('comilla'), ['Cumilla']);
    });

    test('ignores the apostrophe and spaces', () {
      expect(search('coxs bazar'), ["Cox's Bazar"]);
    });

    test('blank shows everything, nonsense nothing', () {
      expect(search('  '), hasLength(64));
      expect(search('zzzz'), isEmpty);
    });
  });

  group('editing', () {
    final byName = {for (final d in map.districts) d.en: d};
    DistrictRoute through(List<String> stops) =>
        DistrictRoute.through([for (final s in stops) byName[s]!]);

    test('a stop goes where it adds the least distance', () {
      final route = through(['Kurigram', 'Bogura', 'Dhaka']);

      expect(names(route.adding(byName['Sirajganj']!)), [
        'Kurigram',
        'Bogura',
        'Sirajganj',
        'Dhaka',
      ]);
    });

    test('adding lengthens the estimate, removing restores it', () {
      final route = through(['Kurigram', 'Dhaka']);
      final longer = route.adding(byName['Bogura']!);

      expect(longer.estimatedM, greaterThan(route.estimatedM));
      expect(longer.removing('Bogura').estimatedM, route.estimatedM);
    });

    test('a district is never added twice', () {
      final route = through(['Kurigram', 'Bogura', 'Dhaka']);

      expect(identical(route.adding(byName['Bogura']!), route), isTrue);
    });

    test('start and end cannot be removed', () {
      final route = through(['Kurigram', 'Bogura', 'Dhaka']);

      expect(identical(route.removing('Kurigram'), route), isTrue);
      expect(identical(route.removing('Dhaka'), route), isTrue);
    });

    test('moving reorders only the middle', () {
      final route = through(['Kurigram', 'Rangpur', 'Bogura', 'Dhaka']);

      expect(names(route.movingVia(0, 1)), [
        'Kurigram',
        'Bogura',
        'Rangpur',
        'Dhaka',
      ]);
    });
  });

  test('an unknown name has no route', () {
    expect(DistrictRouter.find(map, 'Dhaka', 'Atlantis'), isNull);
  });
}
