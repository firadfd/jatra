import '../../services/place_network.dart';

/// A trip: the places the rider chose, and the road between them.
class PlaceRoute {
  const PlaceRoute({
    required this.waypoints,
    required this.path,
    required this.legsM,
    required this.usesFerry,
  });

  /// What the rider asked for: start first, end last, chosen stops between.
  final List<Place> waypoints;

  /// Every place the road passes, [waypoints] included.
  final List<Place> path;

  /// Road distance between each pair of consecutive [waypoints].
  final List<int> legsM;

  final bool usesFerry;

  int get estimatedM => legsM.fold(0, (sum, leg) => sum + leg);

  Place get start => waypoints.first;
  Place get end => waypoints.last;

  /// The stops between start and end.
  List<Place> get via => waypoints.length < 3
      ? const []
      : waypoints.sublist(1, waypoints.length - 1);

  /// English names of the districts on the road, in travel order.
  List<String> get districts => _distinct((p) => p.district);

  /// The same, for showing to the rider.
  List<String> districtsIn(String locale) =>
      _distinct((p) => p.districtIn(locale));

  List<String> _distinct(String Function(Place) nameOf) {
    final names = <String>[];
    for (final place in path) {
      final name = nameOf(place);
      if (!names.contains(name)) names.add(name);
    }
    return names;
  }

  bool contains(String id) => waypoints.any((p) => p.id == id);

  /// Adds [stop] where it lengthens the trip least, which is nearly always
  /// where the rider means it. Dragging corrects the rest.
  PlaceRoute adding(PlaceNetwork network, Place stop) {
    if (contains(stop.id) || waypoints.length < 2) return this;

    final search = PlaceRouter._search(network, stop);
    var bestAt = -1;
    var bestLength = double.infinity;
    for (var at = 1; at < waypoints.length; at++) {
      final length =
          search.metres[waypoints[at - 1].index] +
          search.metres[waypoints[at].index] -
          legsM[at - 1];
      if (length < bestLength) {
        bestLength = length;
        bestAt = at;
      }
    }
    if (bestAt < 0 || bestLength == double.infinity) return this;
    return PlaceRouter.through(network, [...waypoints]..insert(bestAt, stop)) ??
        this;
  }

  /// Removes a stop on the way. The start and end change through their own
  /// pickers.
  PlaceRoute removing(PlaceNetwork network, String id) {
    if (!via.any((p) => p.id == id)) return this;
    return PlaceRouter.through(network, [
          for (final p in waypoints)
            if (p.id != id) p,
        ]) ??
        this;
  }

  /// Moves a stop within [via]. Both indices are positions in the list after
  /// the item has been taken out and put back.
  PlaceRoute movingVia(PlaceNetwork network, int from, int to) {
    final middle = [...via];
    if (from < 0 || from >= middle.length) return this;
    middle.insert(to.clamp(0, middle.length - 1), middle.removeAt(from));
    return PlaceRouter.through(network, [start, ...middle, end]) ?? this;
  }
}

/// Finds routes over the bundled road links.
///
/// Distances are real road lengths between upazila headquarters. A rider's
/// actual start is somewhere near one, which is why the result is still shown
/// as an estimate they can overwrite.
abstract final class PlaceRouter {
  /// Null when either id is unknown or no road connects them.
  static PlaceRoute? find(PlaceNetwork network, String from, String to) {
    final start = network.byId(from);
    final end = network.byId(to);
    if (start == null || end == null) return null;
    return through(network, from == to ? [start] : [start, end]);
  }

  /// The road through [stops] in order. Null when a leg has no road.
  static PlaceRoute? through(PlaceNetwork network, List<Place> stops) {
    if (stops.isEmpty) return null;

    final path = [stops.first];
    final legs = <int>[];
    var usesFerry = false;

    for (var i = 1; i < stops.length; i++) {
      final search = _search(network, stops[i - 1]);
      final end = stops[i].index;
      if (search.metres[end] == double.infinity) return null;

      final leg = <Place>[];
      for (var at = end; at != stops[i - 1].index; at = search.from[at]) {
        leg.add(network.places[at]);
        usesFerry = usesFerry || search.overFerry[at];
      }
      path.addAll(leg.reversed);
      legs.add(search.metres[end].round());
    }

    return PlaceRoute(
      waypoints: List.unmodifiable(stops),
      path: List.unmodifiable(path),
      legsM: List.unmodifiable(legs),
      usesFerry: usesFerry,
    );
  }

  /// Dijkstra from [source]. With some 500 places a linear scan for the
  /// minimum is plenty.
  static ({List<double> metres, List<int> from, List<bool> overFerry}) _search(
    PlaceNetwork network,
    Place source,
  ) {
    final count = network.places.length;
    final metres = List<double>.filled(count, double.infinity);
    final from = List<int>.filled(count, -1);
    final overFerry = List<bool>.filled(count, false);
    final done = List<bool>.filled(count, false);
    metres[source.index] = 0;

    while (true) {
      var current = -1;
      var lowest = double.infinity;
      for (var i = 0; i < count; i++) {
        if (!done[i] && metres[i] < lowest) {
          lowest = metres[i];
          current = i;
        }
      }
      if (current < 0) break;
      done[current] = true;

      for (final link in network.links[current]) {
        final through = lowest + link.metres;
        if (through < metres[link.to]) {
          metres[link.to] = through;
          from[link.to] = current;
          overFerry[link.to] = link.isFerry;
        }
      }
    }
    return (metres: metres, from: from, overFerry: overFerry);
  }
}
