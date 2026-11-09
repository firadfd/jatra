import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'district_map.dart';

/// An upazila, a city, or a whole district, located at its headquarters.
class Place {
  Place({
    required this.index,
    required this.id,
    required this.en,
    required this.bn,
    required this.district,
    required this.districtBn,
    required this.lat,
    required this.lng,
    this.aliases = '',
    this.isDistrict = false,
  });

  /// Position of this place's road junction in [PlaceNetwork.places]. A
  /// district shares the index of its main town.
  final int index;

  /// Names repeat across districts (Kaliganj, Pirganj), so this is the key.
  final String id;
  final String en;
  final String bn;

  /// English district name, matching [District.en].
  final String district;
  final String districtBn;
  final double lat;
  final double lng;

  /// Other spellings people search by, such as "rangpur city".
  final String aliases;

  /// A whole district rather than one upazila within it.
  final bool isDistrict;

  String nameIn(String locale) => locale == 'bn' ? bn : en;
  String districtIn(String locale) => locale == 'bn' ? districtBn : district;

  /// `Pirganj, Rangpur`.
  String labelIn(String locale) =>
      isDistrict ? nameIn(locale) : '${nameIn(locale)}, ${districtIn(locale)}';

  bool get isDistrictSeat => en.endsWith(' Sadar') || en.endsWith(' City');

  static String _plain(String text) =>
      text.toLowerCase().replaceAll(RegExp(r"[\s'’]"), '');

  bool _nameMatches(String wanted) =>
      _plain(en).contains(wanted) ||
      _plain(bn).contains(wanted) ||
      _plain(aliases).contains(wanted);

  bool _districtMatches(String wanted) =>
      _plain(district).contains(wanted) ||
      _plain(districtBn).contains(wanted) ||
      _plain(District.formerNameOf(district)).contains(wanted);
}

/// A stretch of road between two nearby places.
class PlaceLink {
  const PlaceLink(this.to, this.metres, this.isFerry);

  final int to;
  final int metres;
  final bool isFerry;
}

/// Every upazila and the roads between them, bundled so no lookup leaves the
/// device. Built ahead of time by `tool/build_upazila_network.py`.
class PlaceNetwork {
  const PlaceNetwork(this.places, this.links, [this.districts = const []]);

  static const empty = PlaceNetwork([], []);

  static const _asset = 'assets/geo/bd_upazilas.json';

  final List<Place> places;

  /// One entry per district, routed from its main town.
  final List<Place> districts;

  /// Outgoing links, by [Place.index].
  final List<List<PlaceLink>> links;

  bool get isEmpty => places.isEmpty;

  Place? byId(String? id) {
    if (id == null) return null;
    for (final place in [...districts, ...places]) {
      if (place.id == id) return place;
    }
    return null;
  }

  /// The place closest to a point, for taps on the map.
  Place? nearest(double lat, double lng) {
    Place? best;
    var bestSquared = double.infinity;
    for (final place in places) {
      final dLat = place.lat - lat;
      final dLng = place.lng - lng;
      final squared = dLat * dLat + dLng * dLng;
      if (squared < bestSquared) {
        bestSquared = squared;
        best = place;
      }
    }
    return best;
  }

  /// Matches for [query] in the given language's alphabetical order. A
  /// matching district comes first, then places named by the query, then the
  /// rest of the district, so "Rangpur" offers the district, then its upazilas.
  List<Place> search(
    String query,
    String locale, {
    Set<String> exclude = const {},
  }) {
    final wanted = Place._plain(query);
    int rank(Place place) {
      if (wanted.isEmpty) return place.isDistrict ? 0 : 1;
      if (place._nameMatches(wanted)) return place.isDistrict ? 0 : 1;
      if (place._districtMatches(wanted)) return place.isDistrictSeat ? 2 : 3;
      return -1;
    }

    final ranked = [
      for (final place in [...districts, ...places])
        if (!exclude.contains(place.id) && rank(place) >= 0) place,
    ];
    return ranked..sort((a, b) {
      final byRank = rank(a).compareTo(rank(b));
      return byRank != 0
          ? byRank
          : a.labelIn(locale).compareTo(b.labelIn(locale));
    });
  }

  static PlaceNetwork? _cached;

  static Future<PlaceNetwork> load() async {
    final cached = _cached;
    if (cached != null) return cached;

    final source = await rootBundle.loadString(_asset);
    final network = await compute(parse, source);
    _cached = network;
    return network;
  }

  /// Public and top-level friendly, for the isolate and for tests.
  static PlaceNetwork parse(String source) {
    final json = jsonDecode(source) as Map<String, dynamic>;
    final rawPlaces = json['places'] as List<dynamic>;
    final places = [
      for (var i = 0; i < rawPlaces.length; i++)
        () {
          final p = rawPlaces[i] as Map<String, dynamic>;
          final at = p['a'] as List<dynamic>;
          return Place(
            index: i,
            id: p['id'] as String,
            en: p['en'] as String,
            bn: p['bn'] as String,
            district: p['d'] as String,
            districtBn: p['db'] as String,
            lat: (at[0] as num).toDouble(),
            lng: (at[1] as num).toDouble(),
            aliases: (p['k'] as String?) ?? '',
          );
        }(),
    ];

    final links = [for (final _ in places) <PlaceLink>[]];
    for (final raw in json['links'] as List<dynamic>) {
      final link = raw as List<dynamic>;
      final a = link[0] as int;
      final b = link[1] as int;
      final metres = (link[2] as int) * 100;
      final isFerry = link[3] == 1;
      links[a].add(PlaceLink(b, metres, isFerry));
      links[b].add(PlaceLink(a, metres, isFerry));
    }
    return PlaceNetwork(places, links, _districtsOf(places));
  }

  /// A district's main town: its city if it has one, otherwise its sadar.
  static List<Place> _districtsOf(List<Place> places) {
    final seats = <String, Place>{};
    int score(Place p) => p.en.endsWith(' City')
        ? 2
        : p.isDistrictSeat
        ? 1
        : 0;
    for (final place in places) {
      final current = seats[place.district];
      if (current == null || score(place) > score(current)) {
        seats[place.district] = place;
      }
    }
    return [
      for (final seat in seats.values)
        Place(
          index: seat.index,
          id: 'district.${seat.district.toLowerCase().replaceAll(RegExp('[^a-z]+'), '-')}',
          en: seat.district,
          bn: seat.districtBn,
          district: seat.district,
          districtBn: seat.districtBn,
          lat: seat.lat,
          lng: seat.lng,
          aliases: District.formerNameOf(seat.district),
          isDistrict: true,
        ),
    ];
  }
}
