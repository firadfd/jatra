import 'dart:math' as math;

import '../../services/district_map.dart';

/// An ordered list of districts from a start to an end.
class DistrictRoute {
  const DistrictRoute({required this.districts, required this.estimatedM});

  /// Measures [stops] as given, in the order given.
  factory DistrictRoute.through(List<District> stops) => DistrictRoute(
    districts: List.unmodifiable(stops),
    estimatedM: (_legsMetres(stops) * DistrictRouter.roadFactor).round(),
  );

  /// Start first, end last, every district on the way between.
  final List<District> districts;

  final int estimatedM;

  /// The stops between start and end.
  List<District> get via => districts.length < 3
      ? const []
      : districts.sublist(1, districts.length - 1);

  bool contains(String district) => districts.any((d) => d.en == district);

  /// Adds [stop] where it lengthens the route least, which is nearly always
  /// where the rider means it. Dragging corrects the rest.
  DistrictRoute adding(District stop) {
    if (contains(stop.en) || districts.length < 2) return this;

    var bestAt = 1;
    var bestLength = double.infinity;
    for (var at = 1; at < districts.length; at++) {
      final length =
          _legsMetres([districts[at - 1], stop, districts[at]]) -
          _metres(districts[at - 1], districts[at]);
      if (length < bestLength) {
        bestLength = length;
        bestAt = at;
      }
    }
    return DistrictRoute.through([...districts]..insert(bestAt, stop));
  }

  /// Removes a stop on the way. The start and end are not removable here;
  /// they change through their own pickers.
  DistrictRoute removing(String district) {
    if (!via.any((d) => d.en == district)) return this;
    return DistrictRoute.through(
      districts.where((d) => d.en != district).toList(),
    );
  }

  /// Moves a stop within [via]. Both indices are positions in the list after
  /// the item has been taken out and put back.
  DistrictRoute movingVia(int from, int to) {
    final middle = [...via];
    if (from < 0 || from >= middle.length) return this;
    middle.insert(to.clamp(0, middle.length - 1), middle.removeAt(from));
    return DistrictRoute.through([districts.first, ...middle, districts.last]);
  }
}

double _legsMetres(List<District> stops) {
  var total = 0.0;
  for (var i = 1; i < stops.length; i++) {
    total += _metres(stops[i - 1], stops[i]);
  }
  return total;
}

double _metres(District a, District b) {
  const earthRadius = 6371000.0;
  final meanLat = (a.anchor.lat + b.anchor.lat) / 2 * math.pi / 180;
  final dx = (b.anchor.lng - a.anchor.lng) * math.pi / 180 * math.cos(meanLat);
  final dy = (b.anchor.lat - a.anchor.lat) * math.pi / 180;
  return math.sqrt(dx * dx + dy * dy) * earthRadius;
}

/// Estimates a route without road data or a network.
///
/// The shortest chain of neighbouring districts, measured centre to centre.
/// This shows the rough corridor; it does not know actual roads, bridges or
/// ferries, which is why the distance is always presented as an estimate the
/// rider can overwrite.
abstract final class DistrictRouter {
  /// Roads wander. Checked against ten well-known inter-city distances, the
  /// straight legs ran short by a mean factor of 1.22.
  static const roadFactor = 1.2;

  /// Null when either name is not on the map.
  static DistrictRoute? find(DistrictMap map, String from, String to) {
    final byName = {for (final d in map.districts) d.en: d};
    final start = byName[from];
    final end = byName[to];
    if (start == null || end == null) return null;

    // Dijkstra. With 64 nodes a linear scan for the minimum is plenty.
    final best = <String, double>{from: 0};
    final cameFrom = <String, String>{};
    final open = {from};
    final closed = <String>{};

    while (open.isNotEmpty) {
      final current = open.reduce((a, b) => best[a]! <= best[b]! ? a : b);
      if (current == to) break;
      open.remove(current);
      closed.add(current);

      for (final name in byName[current]!.neighbours) {
        final next = byName[name];
        if (next == null || closed.contains(name)) continue;
        final cost = best[current]! + _metres(byName[current]!, next);
        if (cost < (best[name] ?? double.infinity)) {
          best[name] = cost;
          cameFrom[name] = current;
          open.add(name);
        }
      }
    }

    if (best[to] == null) return null;

    final chain = <District>[end];
    while (chain.last.en != from) {
      chain.add(byName[cameFrom[chain.last.en]!]!);
    }

    return DistrictRoute.through(chain.reversed.toList());
  }
}
