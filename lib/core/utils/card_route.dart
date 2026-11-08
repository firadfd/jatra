import 'dart:math' as math;

/// A latitude/longitude pair.
typedef LatLng2 = ({double lat, double lng});

/// A ride's path, prepared for a card that may be posted publicly.
class CardRoute {
  const CardRoute(this.segments);

  /// Each list is an unbroken stretch. Recording gaps stay gaps.
  final List<List<LatLng2>> segments;

  static const empty = CardRoute([]);

  bool get isEmpty => segments.isEmpty;

  /// Rides usually begin and end at home, so that much of the line is never
  /// drawn, whatever the rider chooses.
  static const hiddenEndMetres = 1000.0;

  /// A card is at most about a thousand pixels across.
  static const maxPoints = 600;

  static CardRoute fromPoints(
    List<({double lat, double lng, bool isGapStart})> points,
  ) {
    if (points.length < 2) return empty;

    final travelled = List<double>.filled(points.length, 0);
    for (var i = 1; i < points.length; i++) {
      final step = points[i].isGapStart
          ? 0.0
          : _metres(points[i - 1], points[i]);
      travelled[i] = travelled[i - 1] + step;
    }

    final total = travelled.last;
    // Below this, what remained would be the neighbourhood itself.
    if (total < hiddenEndMetres * 3) return empty;

    final kept = <int>[
      for (var i = 0; i < points.length; i++)
        if (travelled[i] >= hiddenEndMetres &&
            travelled[i] <= total - hiddenEndMetres)
          i,
    ];
    final stride = (kept.length / maxPoints).ceil().clamp(1, 1 << 20);

    final segments = <List<LatLng2>>[];
    var current = <LatLng2>[];
    int? previous;
    var sinceKept = 0;

    for (final index in kept) {
      final point = points[index];
      final breaks = previous != null && _hasGap(points, previous, index);
      if (breaks) {
        if (current.length >= 2) segments.add(current);
        current = [];
        sinceKept = 0;
      }
      if (sinceKept % stride == 0 || index == kept.last) {
        current.add((lat: point.lat, lng: point.lng));
      }
      sinceKept++;
      previous = index;
    }
    if (current.length >= 2) segments.add(current);

    return CardRoute(segments);
  }

  static bool _hasGap(
    List<({double lat, double lng, bool isGapStart})> points,
    int from,
    int to,
  ) {
    for (var i = from + 1; i <= to; i++) {
      if (points[i].isGapStart) return true;
    }
    return false;
  }

  static double _metres(
    ({double lat, double lng, bool isGapStart}) a,
    ({double lat, double lng, bool isGapStart}) b,
  ) {
    const earthRadius = 6371000.0;
    final meanLat = (a.lat + b.lat) / 2 * math.pi / 180;
    final dx = (b.lng - a.lng) * math.pi / 180 * math.cos(meanLat);
    final dy = (b.lat - a.lat) * math.pi / 180;
    return math.sqrt(dx * dx + dy * dy) * earthRadius;
  }
}
