import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// One district's outline.
class District {
  District({
    required this.en,
    required this.bn,
    required this.neighbours,
    required this.rings,
  }) : _west = _bound(rings, 0, false),
       _east = _bound(rings, 0, true),
       _south = _bound(rings, 1, false),
       _north = _bound(rings, 1, true);

  final String en;
  final String bn;

  /// English names of the districts sharing a border, for route finding.
  final List<String> neighbours;

  /// Flat `[lng, lat, lng, lat, ...]` lists, implicitly closed.
  final List<List<double>> rings;

  final double _west;
  final double _east;
  final double _south;
  final double _north;

  String nameIn(String locale) => locale == 'bn' ? bn : en;

  /// The spellings people still search by, for districts renamed officially.
  static const _formerNames = {
    'Barishal': 'barisal',
    'Bogura': 'bogra',
    'Chattogram': 'chittagong ctg',
    'Cumilla': 'comilla',
    'Jashore': 'jessore',
    'Moulvibazar': 'maulvibazar',
    'Chapainawabganj': 'nawabganj',
    'Netrokona': 'netrakona',
    'Brahmanbaria': 'brahamanbaria',
  };

  /// Whether [query] appears in the Bangla, English or former name, ignoring
  /// case, spaces and the apostrophe people skip in Cox's Bazar.
  bool matches(String query) {
    final wanted = _plain(query);
    if (wanted.isEmpty) return true;
    return _plain(en).contains(wanted) ||
        _plain(bn).contains(wanted) ||
        _plain(_formerNames[en] ?? '').contains(wanted);
  }

  static String _plain(String text) =>
      text.toLowerCase().replaceAll(RegExp(r"[\s'’]"), '');

  /// Where to pin a label: the centre of the largest ring. A bounding-box
  /// centre can land outside a crescent-shaped district.
  late final ({double lat, double lng}) anchor = _anchor();

  ({double lat, double lng}) _anchor() {
    var bestArea = -1.0;
    var result = (lat: (_south + _north) / 2, lng: (_west + _east) / 2);
    for (final ring in rings) {
      final count = ring.length ~/ 2;
      var signed = 0.0, cx = 0.0, cy = 0.0;
      for (var i = 0, j = count - 1; i < count; j = i++) {
        final cross =
            ring[j * 2] * ring[i * 2 + 1] - ring[i * 2] * ring[j * 2 + 1];
        signed += cross;
        cx += (ring[j * 2] + ring[i * 2]) * cross;
        cy += (ring[j * 2 + 1] + ring[i * 2 + 1]) * cross;
      }
      if (signed.abs() > bestArea && signed != 0) {
        bestArea = signed.abs();
        result = (lat: cy / (3 * signed), lng: cx / (3 * signed));
      }
    }
    return result;
  }

  /// Even-odd across every ring, which handles islands and holes alike.
  bool contains(double lat, double lng) {
    if (lng < _west || lng > _east || lat < _south || lat > _north) {
      return false;
    }
    var inside = false;
    for (final ring in rings) {
      final count = ring.length ~/ 2;
      for (var i = 0, j = count - 1; i < count; j = i++) {
        final xi = ring[i * 2], yi = ring[i * 2 + 1];
        final xj = ring[j * 2], yj = ring[j * 2 + 1];
        if ((yi > lat) != (yj > lat) &&
            lng < (xj - xi) * (lat - yi) / (yj - yi) + xi) {
          inside = !inside;
        }
      }
    }
    return inside;
  }

  static double _bound(List<List<double>> rings, int offset, bool highest) {
    var value = highest ? -double.infinity : double.infinity;
    for (final ring in rings) {
      for (var i = offset; i < ring.length; i += 2) {
        if (highest ? ring[i] > value : ring[i] < value) value = ring[i];
      }
    }
    return value;
  }
}

/// Bangladesh's 64 districts, bundled so no lookup leaves the device.
class DistrictMap {
  const DistrictMap(this.districts);

  static const empty = DistrictMap([]);

  static const _asset = 'assets/geo/bd_districts.json';

  final List<District> districts;

  bool get isEmpty => districts.isEmpty;

  /// Null outside the outlines: abroad, or off the simplified coast.
  District? locate(double lat, double lng) {
    for (final district in districts) {
      if (district.contains(lat, lng)) return district;
    }
    return null;
  }

  static DistrictMap? _cached;

  static Future<DistrictMap> load() async {
    final cached = _cached;
    if (cached != null) return cached;

    final source = await rootBundle.loadString(_asset);
    final map = await compute(parse, source);
    _cached = map;
    return map;
  }

  /// Public and top-level friendly, for the isolate and for tests.
  static DistrictMap parse(String source) {
    final json = jsonDecode(source) as Map<String, dynamic>;
    return DistrictMap([
      for (final d in json['districts'] as List<dynamic>)
        District(
          en: (d as Map<String, dynamic>)['en'] as String,
          bn: d['bn'] as String,
          neighbours: [for (final n in d['n'] as List<dynamic>) n as String],
          rings: [
            for (final ring in d['r'] as List<dynamic>)
              [for (final n in ring as List<dynamic>) (n as num).toDouble()],
          ],
        ),
    ]);
  }
}
