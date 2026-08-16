import 'dart:math' as math;

/// A position, stripped to what the maths needs. Keeps the geometry free of
/// both the Drift row type and the geolocator plugin type, so it can be
/// tested with plain numbers.
class GeoPoint {
  const GeoPoint({
    required this.lat,
    required this.lng,
    required this.timestampMs,
    this.accuracy,
    this.speed,
    this.altitude,
  });

  final double lat;
  final double lng;
  final int timestampMs;

  /// Horizontal accuracy in metres, as reported by the platform.
  final double? accuracy;

  /// Metres per second.
  final double? speed;

  final double? altitude;
}

/// Why a GPS sample was thrown away. Surfaced in debug and counted on the
/// ride detail screen, so a path full of holes has an explanation.
enum RejectReason {
  /// Worse than [GpsFilter.maxAccuracyMetres] — an urban-canyon fix.
  inaccurate,

  /// Implies a speed no motorcycle reaches; almost always a fix jumping
  /// between cell towers.
  impossibleSpeed,

  /// Closer to the previous point than [GpsFilter.minMoveMetres]. This is
  /// standing-still jitter, and it is the single biggest source of inflated
  /// distances.
  tooClose,

  /// Arrived out of order or with the same timestamp as the last one.
  outOfOrder,
}

/// The outcome of testing one sample against the previous accepted one.
class FilterResult {
  const FilterResult.accept(this.distanceFromPreviousM) : rejected = null;

  const FilterResult.reject(this.rejected) : distanceFromPreviousM = 0;

  final RejectReason? rejected;
  final double distanceFromPreviousM;

  bool get isAccepted => rejected == null;
}

/// Point-quality rules.
///
/// All four are applied, and they have to be: raw GPS on a phone in a city
/// produces a track that wanders several metres while the bike is stationary
/// at a signal, and a ride spent mostly in Dhaka traffic can come out 20–30%
/// long if that jitter is summed.
abstract final class GpsFilter {
  /// Discard fixes worse than this. 30 m is generous enough to keep a usable
  /// track under trees and tight enough to drop a cell-tower fix.
  static const maxAccuracyMetres = 30.0;

  /// Discard anything implying a speed above this. No motorcycle this app
  /// targets does 200 km/h, so a sample that says so is a bad fix.
  static const maxSpeedMps = 200 / 3.6;

  /// Discard points closer than this to the previous one — the jitter rule.
  static const minMoveMetres = 5.0;

  /// Below this speed the rider counts as stopped, so the time is excluded
  /// from `movingSeconds` and therefore from average speed. Walking pace,
  /// roughly.
  static const movingThresholdMps = 1.0;

  /// A silence longer than this means recording was interrupted — the app
  /// was backgrounded, or the GPS lost its fix entirely. The next point
  /// starts a new polyline segment rather than drawing a straight line
  /// across the missing stretch.
  static const gapSeconds = 90;

  /// Tests [candidate] against the last accepted point.
  ///
  /// [previous] is null for the first sample of a ride, which is always
  /// accepted provided it is accurate enough — there is nothing to compare
  /// it against.
  static FilterResult test(GeoPoint candidate, GeoPoint? previous) {
    final accuracy = candidate.accuracy;
    if (accuracy != null && accuracy > maxAccuracyMetres) {
      return const FilterResult.reject(RejectReason.inaccurate);
    }

    if (previous == null) return const FilterResult.accept(0);

    final elapsedMs = candidate.timestampMs - previous.timestampMs;
    if (elapsedMs <= 0) {
      return const FilterResult.reject(RejectReason.outOfOrder);
    }

    final distance = haversineMetres(
      previous.lat,
      previous.lng,
      candidate.lat,
      candidate.lng,
    );

    // Speed is checked before the jitter rule: a wild fix that happens to
    // land far away should be rejected as impossible, not accepted for
    // being far enough.
    final impliedMps = distance / (elapsedMs / 1000);
    if (impliedMps > maxSpeedMps) {
      return const FilterResult.reject(RejectReason.impossibleSpeed);
    }

    if (distance < minMoveMetres) {
      return const FilterResult.reject(RejectReason.tooClose);
    }

    return FilterResult.accept(distance);
  }

  /// True when the silence before [candidate] was long enough to count as a
  /// break in recording.
  static bool isGapAfter(GeoPoint previous, GeoPoint candidate) =>
      candidate.timestampMs - previous.timestampMs > gapSeconds * 1000;
}

/// Great-circle distance in metres.
///
/// The haversine formula rather than a flat-earth approximation: cheap
/// enough at these volumes and correct at any latitude.
double haversineMetres(double lat1, double lng1, double lat2, double lng2) {
  const earthRadiusM = 6371000.0;

  final dLat = _toRadians(lat2 - lat1);
  final dLng = _toRadians(lng2 - lng1);

  final a =
      math.sin(dLat / 2) * math.sin(dLat / 2) +
      math.cos(_toRadians(lat1)) *
          math.cos(_toRadians(lat2)) *
          math.sin(dLng / 2) *
          math.sin(dLng / 2);

  return earthRadiusM * 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
}

double _toRadians(double degrees) => degrees * math.pi / 180;

/// Douglas–Peucker polyline simplification.
///
/// Full resolution always stays in the database; this is for *display only*.
/// Past roughly two thousand points a polyline starts dropping frames on
/// mid-range hardware, and a 50,000-point ride is unusable without this.
///
/// [toleranceMetres] is the maximum distance a dropped point may sit from
/// the line that replaces it.
List<GeoPoint> simplify(List<GeoPoint> points, {double toleranceMetres = 5}) {
  if (points.length < 3) return points;

  final keep = List<bool>.filled(points.length, false);
  keep[0] = true;
  keep[points.length - 1] = true;

  // Iterative rather than recursive: a long ride would otherwise be able to
  // blow the stack on a pathological shape.
  final stack = <({int start, int end})>[(start: 0, end: points.length - 1)];

  while (stack.isNotEmpty) {
    final segment = stack.removeLast();
    var maxDistance = 0.0;
    var farthest = -1;

    for (var i = segment.start + 1; i < segment.end; i++) {
      final distance = _perpendicularDistanceMetres(
        points[i],
        points[segment.start],
        points[segment.end],
      );
      if (distance > maxDistance) {
        maxDistance = distance;
        farthest = i;
      }
    }

    if (maxDistance > toleranceMetres && farthest != -1) {
      keep[farthest] = true;
      stack
        ..add((start: segment.start, end: farthest))
        ..add((start: farthest, end: segment.end));
    }
  }

  return [
    for (var i = 0; i < points.length; i++)
      if (keep[i]) points[i],
  ];
}

/// Simplifies only as hard as it must to reach [targetPoints].
///
/// Doubles the tolerance until the path fits, so a short ride keeps full
/// detail while a 50,000-point one is coarsened just enough to render.
List<GeoPoint> simplifyToBudget(
  List<GeoPoint> points, {
  int targetPoints = 2000,
}) {
  if (points.length <= targetPoints) return points;

  var tolerance = 5.0;
  var result = simplify(points, toleranceMetres: tolerance);

  // 10 doublings takes the tolerance from 5 m to ~5 km, far past the point
  // where any real path survives — the loop is bounded, not hopeful.
  for (var i = 0; i < 10 && result.length > targetPoints; i++) {
    tolerance *= 2;
    result = simplify(points, toleranceMetres: tolerance);
  }
  return result;
}

/// Perpendicular distance from [point] to the segment [start]–[end].
///
/// Projected onto a local flat plane, with longitude scaled by the cosine of
/// latitude. Over the few hundred metres between two GPS samples the error
/// is far below the tolerance being tested against.
double _perpendicularDistanceMetres(
  GeoPoint point,
  GeoPoint start,
  GeoPoint end,
) {
  const metresPerDegreeLat = 111320.0;
  final metresPerDegreeLng =
      metresPerDegreeLat * math.cos(_toRadians(start.lat));

  final px = (point.lng - start.lng) * metresPerDegreeLng;
  final py = (point.lat - start.lat) * metresPerDegreeLat;
  final ex = (end.lng - start.lng) * metresPerDegreeLng;
  final ey = (end.lat - start.lat) * metresPerDegreeLat;

  final segmentLengthSquared = ex * ex + ey * ey;
  // A zero-length segment: fall back to point-to-point distance.
  if (segmentLengthSquared == 0) return math.sqrt(px * px + py * py);

  // Clamped projection, so a point beyond either end measures to that end
  // rather than to the infinite line.
  final t = ((px * ex + py * ey) / segmentLengthSquared).clamp(0.0, 1.0);
  final dx = px - t * ex;
  final dy = py - t * ey;

  return math.sqrt(dx * dx + dy * dy);
}

/// Bounding box of a path, for fitting the map to it.
({double minLat, double maxLat, double minLng, double maxLng})? boundsOf(
  List<GeoPoint> points,
) {
  if (points.isEmpty) return null;

  var minLat = points.first.lat;
  var maxLat = points.first.lat;
  var minLng = points.first.lng;
  var maxLng = points.first.lng;

  for (final p in points) {
    if (p.lat < minLat) minLat = p.lat;
    if (p.lat > maxLat) maxLat = p.lat;
    if (p.lng < minLng) minLng = p.lng;
    if (p.lng > maxLng) maxLng = p.lng;
  }

  return (minLat: minLat, maxLat: maxLat, minLng: minLng, maxLng: maxLng);
}
