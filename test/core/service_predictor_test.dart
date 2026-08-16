import 'package:flutter_test/flutter_test.dart';
import 'package:jatra/core/calc/service_predictor.dart';
import 'package:jatra/core/utils/clock.dart';
import 'package:jatra/data/db/database.dart';

final _now = DateTime.utc(2026, 8, 4, 12);
int get _nowMs => _now.millisecondsSinceEpoch;

ServiceItemRow item({
  String name = 'Engine oil',
  int? intervalKm,
  int? intervalDays,
  int? lastDoneKm,
  int? lastDoneDaysAgo,
}) {
  return ServiceItemRow(
    id: 1,
    vehicleId: 1,
    name: name,
    createdAt: Dates.addDays(_nowMs, -400),
    updatedAt: _nowMs,
    intervalM: intervalKm == null ? null : intervalKm * 1000,
    intervalDays: intervalDays,
    lastDoneOdometerM: lastDoneKm == null ? null : lastDoneKm * 1000,
    lastDoneDateMs: lastDoneDaysAgo == null
        ? null
        : Dates.addDays(_nowMs, -lastDoneDaysAgo),
    isActive: true,
    iconKey: 'oil',
    sortOrder: 0,
  );
}

ServiceDue evaluate(ServiceItemRow i, {required int atKm, double? dailyKm}) =>
    ServicePredictor.evaluate(
      i,
      currentOdometerM: atKm * 1000,
      dailyMetresEstimate: dailyKm == null ? null : dailyKm * 1000,
      nowMs: _nowMs,
    );

void main() {
  setUp(() => Clock.freeze(_now));
  tearDown(() => Clock.freeze(null));

  group('distance intervals', () {
    // Engine oil every 2,000 km, last done at 20,000.
    ServiceItemRow oil() => item(intervalKm: 2000, lastDoneKm: 20000);

    test('fresh service reads OK', () {
      final due = evaluate(oil(), atKm: 20100);
      expect(due.status, ServiceStatus.ok);
      expect(due.usedFraction, closeTo(0.05, 1e-9));
      expect(due.dueOdometerM, 22000 * 1000);
      expect(due.remainingM, 1900 * 1000);
    });

    test('OK holds until 20% of the interval remains', () {
      // 1,599 km in of 2,000 → 79.95% used, still OK.
      expect(evaluate(oil(), atKm: 21599).status, ServiceStatus.ok);
      // 1,600 km in → exactly 80% used, the DUE SOON boundary.
      expect(evaluate(oil(), atKm: 21600).status, ServiceStatus.dueSoon);
    });

    test('DUE NOW at the interval, OVERDUE past 10% beyond it', () {
      expect(evaluate(oil(), atKm: 21999).status, ServiceStatus.dueSoon);
      expect(evaluate(oil(), atKm: 22000).status, ServiceStatus.dueNow);
      expect(evaluate(oil(), atKm: 22200).status, ServiceStatus.dueNow);
      // 2,201 km in → 110.05% used.
      expect(evaluate(oil(), atKm: 22201).status, ServiceStatus.overdue);
    });

    test('overshoot is reported honestly rather than clamped', () {
      final due = evaluate(oil(), atKm: 22800);
      expect(due.usedFraction, closeTo(1.4, 1e-9));
      expect(due.remainingM, -800 * 1000);
    });
  });

  group('time intervals', () {
    // Brake fluid every 730 days.
    ServiceItemRow fluid({required int daysAgo}) =>
        item(name: 'Brake fluid', intervalDays: 730, lastDoneDaysAgo: daysAgo);

    test('a recent change reads OK', () {
      final due = evaluate(fluid(daysAgo: 30), atKm: 20000);
      expect(due.status, ServiceStatus.ok);
      expect(due.dueDateIsEstimate, isFalse);
      expect(due.remainingDays, 700);
    });

    test('the date is exact, not projected', () {
      final due = evaluate(fluid(daysAgo: 100), atKm: 20000);
      expect(due.dueDateMs, Dates.addDays(_nowMs, 630));
      expect(due.dueDateIsEstimate, isFalse);
    });

    test('crosses into DUE SOON, DUE NOW and OVERDUE on schedule', () {
      expect(
        evaluate(fluid(daysAgo: 583), atKm: 20000).status,
        ServiceStatus.ok,
      );
      expect(
        evaluate(fluid(daysAgo: 584), atKm: 20000).status,
        ServiceStatus.dueSoon,
      );
      expect(
        evaluate(fluid(daysAgo: 730), atKm: 20000).status,
        ServiceStatus.dueNow,
      );
      expect(
        evaluate(fluid(daysAgo: 804), atKm: 20000).status,
        ServiceStatus.overdue,
      );
    });
  });

  group('the fourteen-day rule', () {
    test('pulls an item forward even with interval left', () {
      // 1,000 km of a 2,000 km interval used — 50%, comfortably OK on
      // distance. But at 80 km/day the remaining 1,000 km is 12 days away.
      final due = evaluate(
        item(intervalKm: 2000, lastDoneKm: 20000),
        atKm: 21000,
        dailyKm: 80,
      );
      expect(due.usedFraction, closeTo(0.5, 1e-9));
      expect(due.remainingDays, 12);
      expect(due.status, ServiceStatus.dueSoon);
    });

    test('does not fire for a rider who barely rides', () {
      // Same 1,000 km left, but at 5 km/day that is 200 days out.
      final due = evaluate(
        item(intervalKm: 2000, lastDoneKm: 20000),
        atKm: 21000,
        dailyKm: 5,
      );
      expect(due.remainingDays, 200);
      expect(due.status, ServiceStatus.ok);
    });
  });

  group('items with both intervals', () {
    test('whichever is further through governs', () {
      // Distance: 500 of 2,000 km = 25%. Time: 600 of 730 days = 82%.
      // Time governs, so the item reads DUE SOON.
      final due = evaluate(
        item(
          intervalKm: 2000,
          lastDoneKm: 20000,
          intervalDays: 730,
          lastDoneDaysAgo: 600,
        ),
        atKm: 20500,
      );
      expect(due.usedFraction, closeTo(600 / 730, 1e-9));
      expect(due.status, ServiceStatus.dueSoon);
      // Both axes are still reported, so the UI can show either.
      expect(due.dueOdometerM, 22000 * 1000);
      expect(due.dueDateIsEstimate, isFalse);
    });

    test('and distance governs when it is the one running out', () {
      final due = evaluate(
        item(
          intervalKm: 2000,
          lastDoneKm: 20000,
          intervalDays: 730,
          lastDoneDaysAgo: 30,
        ),
        atKm: 21900,
      );
      expect(due.usedFraction, closeTo(0.95, 1e-9));
      expect(due.status, ServiceStatus.dueSoon);
    });
  });

  group('items with no interval', () {
    test('report unknown rather than overdue', () {
      final due = evaluate(item(lastDoneKm: 20000), atKm: 30000);
      expect(due.status, ServiceStatus.unknown);
      expect(due.usedFraction, 0);
    });
  });

  group('daily distance estimate', () {
    List<({int dateMs, int odometerM})> obs(List<(int, int)> pairs) => [
      for (final (daysAgo, km) in pairs)
        (dateMs: Dates.addDays(_nowMs, -daysAgo), odometerM: km * 1000),
    ];

    test('averages over recent observations', () {
      // 1,200 km across 30 days → 40 km/day.
      final rate = ServicePredictor.dailyMetres(
        obs([(30, 20000), (15, 20600), (0, 21200)]),
        nowMs: _nowMs,
      );
      expect(rate! / 1000, closeTo(40, 1e-9));
    });

    test('prefers the last sixty days over ancient history', () {
      // Someone who used to ride 100 km/day and now rides 20.
      final rate = ServicePredictor.dailyMetres(
        obs([
          (400, 0),
          (300, 10000),
          (50, 30000),
          (0, 31000), // 1,000 km in the last 50 days → 20 km/day
        ]),
        nowMs: _nowMs,
      );
      expect(rate! / 1000, closeTo(20, 1e-9));
    });

    test('falls back to all history when the recent window is too thin', () {
      // Nothing inside sixty days except a single reading.
      final rate = ServicePredictor.dailyMetres(
        obs([(200, 10000), (100, 20000), (1, 29900)]),
        nowMs: _nowMs,
      );
      expect(rate, isNotNull);
      // 19,900 km over 199 days.
      expect(rate! / 1000, closeTo(19900 / 199, 1e-6));
    });

    test('returns null rather than guessing from one observation', () {
      expect(
        ServicePredictor.dailyMetres(obs([(10, 20000)]), nowMs: _nowMs),
        isNull,
      );
      expect(ServicePredictor.dailyMetres([], nowMs: _nowMs), isNull);
    });

    test('returns null for a span too short to project from', () {
      // Two fills two days apart says nothing about a yearly rate.
      expect(
        ServicePredictor.dailyMetres(
          obs([(2, 20000), (0, 20300)]),
          nowMs: _nowMs,
        ),
        isNull,
      );
    });

    test('a distance-based item omits its date when there is no estimate', () {
      final due = evaluate(
        item(intervalKm: 2000, lastDoneKm: 20000),
        atKm: 21000,
      );
      expect(due.dueDateMs, isNull);
      expect(due.remainingDays, isNull);
      // Still knows the odometer answer, which needs no projection.
      expect(due.dueOdometerM, 22000 * 1000);
    });
  });

  group('the plan', () {
    test('sorts by urgency, not alphabetically', () {
      final items = [
        item(name: 'Air filter clean', intervalKm: 3000, lastDoneKm: 20000),
        item(name: 'Chain lube', intervalKm: 500, lastDoneKm: 20000),
        item(name: 'Engine oil', intervalKm: 2000, lastDoneKm: 20000),
        item(name: 'Battery', intervalDays: 1095, lastDoneDaysAgo: 10),
      ];

      final plan = ServicePredictor.plan(
        items,
        currentOdometerM: 20900 * 1000,
        nowMs: _nowMs,
      );

      expect(plan.map((d) => d.item.name), [
        'Chain lube', // 900 of 500 km → 180%, overdue
        'Engine oil', // 900 of 2,000 km → 45%
        'Air filter clean', // 900 of 3,000 km → 30%
        'Battery', // 10 of 1,095 days → 0.9%
      ]);
      expect(plan.first.status, ServiceStatus.overdue);
    });

    test('breaks ties within a status by how far through the interval', () {
      final plan = ServicePredictor.plan(
        [
          item(name: 'B item', intervalKm: 2000, lastDoneKm: 20000),
          item(name: 'A item', intervalKm: 4000, lastDoneKm: 20000),
        ],
        currentOdometerM: 20100 * 1000,
        nowMs: _nowMs,
      );

      // B is 5% through, A is 2.5%. Urgency beats the alphabet.
      expect(plan.map((d) => d.item.name), ['B item', 'A item']);
    });

    test('items with no interval sink to the bottom', () {
      final plan = ServicePredictor.plan(
        [
          item(name: 'Mystery'),
          item(name: 'Engine oil', intervalKm: 2000, lastDoneKm: 20000),
        ],
        currentOdometerM: 20100 * 1000,
        nowMs: _nowMs,
      );
      expect(plan.last.item.name, 'Mystery');
      expect(plan.last.status, ServiceStatus.unknown);
    });
  });
}
