import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:jatra/core/calc/place_route.dart';
import 'package:jatra/services/place_network.dart';

void main() {
  final network = PlaceNetwork.parse(
    File('assets/geo/bd_upazilas.json').readAsStringSync(),
  );
  Place at(String id) => network.byId(id)!;
  PlaceRoute route(String from, String to) =>
      PlaceRouter.find(network, from, to)!;
  List<String> districts(PlaceRoute r) => r.districts;

  const dhaka = 'dhaka.dhaka-city';

  group('data', () {
    test('every place has a unique id and both names', () {
      expect(
        network.places.map((p) => p.id).toSet(),
        hasLength(network.places.length),
      );
      for (final p in network.places) {
        expect(p.en, isNotEmpty, reason: p.id);
        expect(p.bn, isNotEmpty, reason: p.id);
      }
    });

    test('covers the upazilas of Rangpur', () {
      final found = network.places.where((p) => p.district == 'Rangpur');
      expect(found, hasLength(8));
    });

    test('every place can reach every other', () {
      for (final p in network.places) {
        expect(PlaceRouter.find(network, dhaka, p.id), isNotNull, reason: p.id);
      }
    });

    test('every link is a usable road length', () {
      for (final links in network.links) {
        for (final link in links) {
          // Zero is real: a city and its sadar can share a junction.
          expect(link.metres, greaterThanOrEqualTo(0));
          expect(link.metres, lessThanOrEqualTo(70100));
        }
      }
    });
  });

  group('within a district', () {
    test('Rangpur Sadar to another Rangpur upazila has a road distance', () {
      final trip = route('rangpur.rangpur-sadar', 'rangpur.pirganj');

      expect(trip.estimatedM / 1000, closeTo(40, 12));
      expect(districts(trip), ['Rangpur']);
    });

    test('the same place is a route of one with no distance', () {
      final trip = route('feni.feni-sadar', 'feni.feni-sadar');

      expect(trip.waypoints, hasLength(1));
      expect(trip.estimatedM, 0);
    });
  });

  group('corridors follow real roads', () {
    test('Dhaka to Rangpur crosses the Jamuna at Sirajganj', () {
      final path = districts(route(dhaka, 'rangpur.rangpur-sadar'));

      expect(path, containsAll(['Tangail', 'Sirajganj', 'Bogura']));
      expect(path, isNot(contains('Jamalpur')));
    });

    test('Dhaka to Chattogram runs by Cumilla and Feni', () {
      final path = districts(route(dhaka, 'chattogram.chattogram-city'));

      expect(path, containsAll(['Cumilla', 'Feni']));
      expect(path, isNot(contains('Noakhali')));
    });

    test('Dhaka to Rajshahi does not cross at Pabna', () {
      final path = districts(route(dhaka, 'rajshahi.rajshahi-city'));

      expect(path, contains('Sirajganj'));
      expect(path, isNot(contains('Manikganj')));
    });

    test('distances land near well-known road distances', () {
      void near(String to, double km) {
        expect(
          route(dhaka, to).estimatedM / 1000,
          closeTo(km, km * 0.12),
          reason: to,
        );
      }

      near('chattogram.chattogram-city', 250);
      near('sylhet.sylhet-sadar', 240);
      near('rajshahi.rajshahi-city', 255);
      near('rangpur.rangpur-sadar', 305);
      near('narayanganj.narayanganj-city', 18);
    });

    test('an island needs a ferry', () {
      expect(
        route('bhola.bhola-sadar', 'lakshmipur.lakshmipur-sadar').usesFerry,
        isTrue,
      );
    });

    test('a mainland road trip does not', () {
      expect(
        route('rangpur.rangpur-sadar', 'rangpur.pirganj').usesFerry,
        isFalse,
      );
    });
  });

  group('search', () {
    List<String> search(String q, [String locale = 'en']) => [
      for (final p in network.search(q, locale)) p.id,
    ];

    test('finds an upazila, in any case', () {
      expect(search('PIRGANJ'), contains('rangpur.pirganj'));
    });

    test('a repeated name is offered once per district', () {
      final districts = {
        for (final p in network.search('kaliganj', 'en')) p.district,
      };
      expect(districts.length, greaterThan(1));
    });

    test('finds a Bangla name', () {
      expect(search('পীরগঞ্জ', 'bn'), contains('rangpur.pirganj'));
    });

    test('a district lists its seat first, then its upazilas', () {
      final results = network.search('rangpur', 'en');

      expect(results.first.id, 'district.rangpur');
      expect(results[1].id, isNot('district.rangpur'));
      expect(results.map((p) => p.id), contains('rangpur.badarganj'));
    });

    test('a city name finds its sadar upazila', () {
      expect(search('rangpur city').first, 'rangpur.rangpur-sadar');
    });

    test('finds a former district name', () {
      expect(search('comilla'), contains('cumilla.cumilla-sadar'));
    });

    test('corrected spellings keep the old one searchable', () {
      expect(search('syedpur'), contains('nilphamari.saidpur'));
    });

    test('blank shows everything, nonsense nothing', () {
      expect(
        search('  '),
        hasLength(network.places.length + network.districts.length),
      );
      expect(search('zzzz'), isEmpty);
    });
  });

  group('districts', () {
    test('all 64 can be chosen', () {
      expect(network.districts, hasLength(64));
    });

    test('a district routes from its main town under its own name', () {
      final trip = PlaceRouter.find(
        network,
        'district.rangpur',
        'district.dhaka',
      )!;

      expect(trip.start.labelIn('en'), 'Rangpur');
      expect(trip.end.labelIn('en'), 'Dhaka');
      expect(trip.estimatedM, greaterThan(250000));
    });

    test('a district can be mixed with an upazila', () {
      final trip = route('district.rangpur', 'rangpur.pirganj');

      expect(trip.estimatedM, greaterThan(20000));
      expect(trip.districts, ['Rangpur']);
    });

    test('a district that also has a stop keeps a valid route', () {
      final trip = route('district.rangpur', 'dhaka.dhaka-city');

      expect(trip.adding(network, at('district.bogura')).via, hasLength(1));
    });
  });

  group('editing', () {
    PlaceRoute trip() => route('rangpur.rangpur-sadar', 'dhaka.dhaka-city');

    test('a stop goes on the leg it lengthens least', () {
      final edited = trip()
          .adding(network, at('bogura.bogura-sadar'))
          .adding(network, at('sirajganj.sirajganj-sadar'));

      expect(edited.via.map((p) => p.id), [
        'bogura.bogura-sadar',
        'sirajganj.sirajganj-sadar',
      ]);
    });

    test('a detour lengthens the estimate, removing restores it', () {
      final base = trip();
      final longer = base.adding(network, at('sylhet.sylhet-sadar'));

      expect(longer.estimatedM, greaterThan(base.estimatedM));
      expect(
        longer.removing(network, 'sylhet.sylhet-sadar').estimatedM,
        base.estimatedM,
      );
    });

    test('a stop is never added twice', () {
      final edited = trip().adding(network, at('bogura.bogura-sadar'));

      expect(
        identical(edited.adding(network, at('bogura.bogura-sadar')), edited),
        isTrue,
      );
    });

    test('start and end cannot be removed', () {
      final base = trip();

      expect(identical(base.removing(network, base.start.id), base), isTrue);
      expect(identical(base.removing(network, base.end.id), base), isTrue);
    });

    test('moving reorders only the middle', () {
      final edited = trip()
          .adding(network, at('bogura.bogura-sadar'))
          .adding(network, at('sirajganj.sirajganj-sadar'))
          .movingVia(network, 0, 1);

      expect(edited.via.map((p) => p.id), [
        'sirajganj.sirajganj-sadar',
        'bogura.bogura-sadar',
      ]);
      expect(edited.start.id, 'rangpur.rangpur-sadar');
      expect(edited.end.id, 'dhaka.dhaka-city');
    });
  });

  test('an unknown id has no route', () {
    expect(PlaceRouter.find(network, dhaka, 'nowhere.atlantis'), isNull);
  });
}
