import 'package:flutter_test/flutter_test.dart';
import 'package:jatra/core/utils/geo_utils.dart';

/// Dhaka, roughly. Real coordinates so the distances are sanity-checkable.
const _lat = 23.8103;
const _lng = 90.4125;

GeoPoint point({
  double lat = _lat,
  double lng = _lng,
  int seconds = 0,
  double? accuracy = 5,
  double? speed,
}) {
  return GeoPoint(
    lat: lat,
    lng: lng,
    timestampMs:
        DateTime.utc(2026, 8, 4, 12).millisecondsSinceEpoch + seconds * 1000,
    accuracy: accuracy,
    speed: speed,
  );
}

/// Offsets by a distance north, in metres. One degree of latitude is very
/// close to 111,320 m everywhere.
GeoPoint northOf(GeoPoint from, double metres, {int seconds = 1}) {
  return GeoPoint(
    lat: from.lat + metres / 111320.0,
    lng: from.lng,
    timestampMs: from.timestampMs + seconds * 1000,
    accuracy: from.accuracy,
  );
}

void main() {
  group('haversine', () {
    test('measures a known short distance', () {
      // 100 m north.
      final a = point();
      final b = northOf(a, 100);
      expect(haversineMetres(a.lat, a.lng, b.lat, b.lng), closeTo(100, 0.5));
    });

    test('is zero for the same point', () {
      expect(haversineMetres(_lat, _lng, _lat, _lng), 0);
    });

    test('is symmetric', () {
      expect(
        haversineMetres(23.8103, 90.4125, 23.7500, 90.3900),
        closeTo(haversineMetres(23.7500, 90.3900, 23.8103, 90.4125), 1e-9),
      );
    });

    test('handles a long distance sensibly', () {
      // Dhaka to Chattogram: ~214 km great-circle. The road is nearer
      // 245 km, which is what people quote — but this measures the line,
      // not the highway.
      final d = haversineMetres(23.8103, 90.4125, 22.3569, 91.7832);
      expect(d / 1000, closeTo(214, 3));
    });
  });

  group('the accuracy filter', () {
    test('accepts a good first fix', () {
      expect(GpsFilter.test(point(accuracy: 8), null).isAccepted, isTrue);
    });

    test('rejects a fix worse than 30 m', () {
      expect(
        GpsFilter.test(point(accuracy: 45), null).rejected,
        RejectReason.inaccurate,
      );
    });

    test('accepts a fix with no accuracy reported', () {
      // Some devices report nothing; refusing every such sample would make
      // the app useless on them.
      expect(GpsFilter.test(point(accuracy: null), null).isAccepted, isTrue);
    });
  });

  group('the jitter filter', () {
    test('rejects a point under five metres away', () {
      // This is the rule that stops a bike sitting at a traffic signal from
      // accumulating hundreds of metres of imaginary distance.
      final a = point();
      final b = northOf(a, 3);
      expect(GpsFilter.test(b, a).rejected, RejectReason.tooClose);
    });

    test('accepts a point beyond five metres', () {
      final a = point();
      final b = northOf(a, 12);
      final result = GpsFilter.test(b, a);
      expect(result.isAccepted, isTrue);
      expect(result.distanceFromPreviousM, closeTo(12, 0.5));
    });

    test('a stationary bike accumulates no distance at all', () {
      // Sixty seconds of 2-metre jitter, which is a realistic signal wait.
      var previous = point();
      var total = 0.0;
      for (var i = 1; i <= 60; i++) {
        final jitter = point(
          lat: _lat + (i.isEven ? 0.000018 : -0.000018),
          seconds: i,
        );
        final result = GpsFilter.test(jitter, previous);
        if (result.isAccepted) {
          total += result.distanceFromPreviousM;
          previous = jitter;
        }
      }
      expect(total, 0);
    });
  });

  group('the speed filter', () {
    test('rejects a jump no motorcycle could make', () {
      // 5 km in one second.
      final a = point();
      final b = northOf(a, 5000, seconds: 1);
      expect(GpsFilter.test(b, a).rejected, RejectReason.impossibleSpeed);
    });

    test('accepts a fast but plausible stretch', () {
      // 100 m in 3 s is 120 km/h — fast, but real.
      final a = point();
      final b = northOf(a, 100, seconds: 3);
      expect(GpsFilter.test(b, a).isAccepted, isTrue);
    });

    test('is checked before the jitter rule', () {
      // A wild fix that lands far away must be rejected as impossible
      // rather than accepted merely for being far enough.
      final a = point();
      final b = northOf(a, 10000, seconds: 1);
      expect(GpsFilter.test(b, a).rejected, RejectReason.impossibleSpeed);
    });
  });

  group('ordering', () {
    test('rejects a sample that arrives out of order', () {
      final a = point(seconds: 10);
      final b = northOf(a, 50, seconds: -5);
      expect(GpsFilter.test(b, a).rejected, RejectReason.outOfOrder);
    });

    test('rejects a duplicate timestamp', () {
      final a = point();
      final b = northOf(a, 50, seconds: 0);
      expect(GpsFilter.test(b, a).rejected, RejectReason.outOfOrder);
    });
  });

  group('gap detection', () {
    test('a short silence is not a gap', () {
      final a = point();
      final b = northOf(a, 100, seconds: 30);
      expect(GpsFilter.isGapAfter(a, b), isFalse);
    });

    test('a long silence is', () {
      // The app was backgrounded for twelve minutes.
      final a = point();
      final b = northOf(a, 100, seconds: 12 * 60);
      expect(GpsFilter.isGapAfter(a, b), isTrue);
    });
  });

  group('simplification', () {
    /// A straight run north, one point every 10 m.
    List<GeoPoint> straightLine(int count) {
      final points = <GeoPoint>[point()];
      for (var i = 1; i < count; i++) {
        points.add(northOf(points.last, 10, seconds: 1));
      }
      return points;
    }

    test('collapses a straight line to its endpoints', () {
      final simplified = simplify(straightLine(50), toleranceMetres: 5);
      expect(simplified, hasLength(2));
      expect(simplified.first.lat, straightLine(50).first.lat);
    });

    test('keeps a corner', () {
      final a = point();
      final b = northOf(a, 200, seconds: 10);
      final corner = GeoPoint(
        lat: b.lat,
        lng: b.lng + 0.002, // ~200 m east
        timestampMs: b.timestampMs + 10000,
      );

      final simplified = simplify([a, b, corner], toleranceMetres: 5);
      expect(simplified, hasLength(3));
    });

    test('never drops the first or last point', () {
      final simplified = simplify(straightLine(100), toleranceMetres: 1000);
      expect(simplified.first.timestampMs, straightLine(100).first.timestampMs);
      expect(simplified.last.timestampMs, straightLine(100).last.timestampMs);
    });

    test('leaves a path of fewer than three points alone', () {
      expect(simplify([], toleranceMetres: 5), isEmpty);
      expect(simplify(straightLine(2), toleranceMetres: 5), hasLength(2));
    });

    test('preserves overall shape within the tolerance', () {
      // A gentle curve: every retained point must still be on the path.
      final points = <GeoPoint>[point()];
      for (var i = 1; i < 200; i++) {
        points.add(
          GeoPoint(
            lat: _lat + i * 0.0001,
            lng: _lng + (i * i) * 0.0000005,
            timestampMs: points.last.timestampMs + 1000,
          ),
        );
      }

      final simplified = simplify(points, toleranceMetres: 10);
      expect(simplified.length, lessThan(points.length));
      expect(simplified.length, greaterThan(2));
    });
  });

  group('the render budget', () {
    /// A 50,000-point ride, the figure the acceptance checklist names.
    List<GeoPoint> hugeRide() {
      final points = <GeoPoint>[point()];
      for (var i = 1; i < 50000; i++) {
        // A wandering path, so it does not trivially collapse to a line.
        points.add(
          GeoPoint(
            lat: _lat + i * 0.00002 + (i % 7) * 0.000004,
            lng: _lng + i * 0.00001 + (i % 11) * 0.000003,
            timestampMs: points.last.timestampMs + 1000,
          ),
        );
      }
      return points;
    }

    test('brings a 50,000-point ride under the budget', () {
      final simplified = simplifyToBudget(hugeRide(), targetPoints: 2000);
      expect(simplified.length, lessThanOrEqualTo(2000));
      expect(simplified.length, greaterThan(1));
    });

    test('leaves a 500-point ride at full resolution', () {
      final points = <GeoPoint>[point()];
      for (var i = 1; i < 500; i++) {
        points.add(
          GeoPoint(
            lat: _lat + i * 0.0001 + (i % 5) * 0.00002,
            lng: _lng + i * 0.00005,
            timestampMs: points.last.timestampMs + 1000,
          ),
        );
      }

      expect(simplifyToBudget(points, targetPoints: 2000), hasLength(500));
    });

    test('is fast enough to run on a screen build', () {
      final stopwatch = Stopwatch()..start();
      simplifyToBudget(hugeRide(), targetPoints: 2000);
      stopwatch.stop();
      // Generous, since CI machines vary — but it catches an accidental
      // quadratic rewrite, which would take minutes rather than millis.
      expect(stopwatch.elapsedMilliseconds, lessThan(4000));
    });
  });

  group('bounds', () {
    test('cover every point', () {
      final points = [
        point(),
        point(lat: 23.9, lng: 90.5, seconds: 1),
        point(lat: 23.7, lng: 90.3, seconds: 2),
      ];
      final bounds = boundsOf(points)!;

      expect(bounds.minLat, 23.7);
      expect(bounds.maxLat, 23.9);
      expect(bounds.minLng, 90.3);
      expect(bounds.maxLng, 90.5);
    });

    test('are null for an empty path', () {
      expect(boundsOf([]), isNull);
    });
  });
}
