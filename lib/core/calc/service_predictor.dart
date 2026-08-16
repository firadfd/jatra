import '../../data/db/database.dart';
import '../utils/clock.dart';

/// How far a service item is from its next due point, on both axes.
class ServiceDue {
  const ServiceDue({
    required this.item,
    required this.status,
    required this.usedFraction,
    this.dueOdometerM,
    this.remainingM,
    this.dueDateMs,
    this.remainingDays,
    this.dueDateIsEstimate = false,
  });

  final ServiceItemRow item;
  final ServiceStatus status;

  /// How much of the interval has been consumed. Greater than 1 means past
  /// due; the progress bar clamps it but the text does not, so an item that
  /// is 40% over reads as 140%.
  final double usedFraction;

  /// Distance axis. Null when the item has no distance interval.
  final int? dueOdometerM;
  final int? remainingM;

  /// Date axis. For a time-based interval this is exact. For a distance-based
  /// one it is projected from recent riding, and [dueDateIsEstimate] is true.
  final int? dueDateMs;
  final int? remainingDays;

  final bool dueDateIsEstimate;

  bool get needsAttention =>
      status == ServiceStatus.overdue ||
      status == ServiceStatus.dueNow ||
      status == ServiceStatus.dueSoon;

  bool get isPastDue =>
      status == ServiceStatus.overdue || status == ServiceStatus.dueNow;
}

/// Predicts when each service item falls due.
///
/// Thresholds, straight from the spec:
///
/// * `OK`       — more than 20% of the interval remaining
/// * `DUE SOON` — within 20% of the interval, or within 14 days
/// * `DUE NOW`  — at or past the interval
/// * `OVERDUE`  — more than 10% past it
///
/// An item may carry a distance interval, a time interval, or both. With
/// both, whichever falls due *first* governs — chain lube every 500 km and
/// brake fluid every two years are the same kind of promise, and the more
/// urgent one is the one worth showing.
abstract final class ServicePredictor {
  /// Fraction of the interval that must remain to still read `OK`.
  static const okHeadroom = 0.20;

  /// Days out at which an item starts reading `DUE SOON` regardless of how
  /// much interval is left in percentage terms.
  static const soonDays = 14;

  /// How far past the interval counts as `OVERDUE` rather than `DUE NOW`.
  static const overdueMargin = 0.10;

  /// Riding history window for the daily-distance estimate.
  static const estimateWindowDays = 60;

  /// Below this many days of history the estimate is too noisy to project
  /// from — one long weekend would double it.
  static const minEstimateSpanDays = 3;

  /// Average metres ridden per day, from odometer observations.
  ///
  /// Observations come from fuel entries, service logs and completed rides —
  /// anything that pins an odometer reading to a date. Prefers the last
  /// [estimateWindowDays]; falls back to the whole history when that window
  /// is too thin, and returns `null` when even that cannot support a
  /// projection. A null estimate means dates are omitted, not guessed.
  static double? dailyMetres(
    List<({int dateMs, int odometerM})> observations, {
    int? nowMs,
  }) {
    final now = nowMs ?? Clock.nowMs;
    final cutoff = Dates.addDays(now, -estimateWindowDays);

    final recent = observations.where((o) => o.dateMs >= cutoff).toList();
    return _rate(recent) ?? _rate(observations);
  }

  static double? _rate(List<({int dateMs, int odometerM})> observations) {
    if (observations.length < 2) return null;

    final sorted = [...observations]
      ..sort((a, b) => a.dateMs.compareTo(b.dateMs));

    final spanDays = Dates.daysBetween(sorted.first.dateMs, sorted.last.dateMs);
    if (spanDays < minEstimateSpanDays) return null;

    final distance = sorted.last.odometerM - sorted.first.odometerM;
    if (distance <= 0) return null;

    return distance / spanDays;
  }

  /// Evaluates one item.
  static ServiceDue evaluate(
    ServiceItemRow item, {
    required int currentOdometerM,
    double? dailyMetresEstimate,
    int? nowMs,
  }) {
    final now = nowMs ?? Clock.nowMs;

    final distance = _distanceAxis(
      item,
      currentOdometerM,
      dailyMetresEstimate,
      now: now,
    );
    final time = _timeAxis(item, now);

    if (distance == null && time == null) {
      return ServiceDue(
        item: item,
        status: ServiceStatus.unknown,
        usedFraction: 0,
      );
    }

    // Whichever axis is further through its interval is the one that
    // governs — it is the one that will come due first.
    final governing = switch ((distance, time)) {
      (final d?, final t?) => d.used >= t.used ? d : t,
      (final d?, null) => d,
      (null, final t?) => t,
      _ => throw StateError('unreachable'),
    };

    // Days remaining is taken from whichever axis can supply it, preferring
    // the governing one. A distance-based item still deserves a date if we
    // know roughly how much the bike gets ridden.
    final remainingDays =
        governing.remainingDays ??
        distance?.remainingDays ??
        time?.remainingDays;
    final dueDateMs =
        governing.dueDateMs ?? distance?.dueDateMs ?? time?.dueDateMs;
    final isEstimate = governing.dueDateMs != null
        ? governing.isEstimate
        : (distance?.dueDateMs != null ? true : false);

    return ServiceDue(
      item: item,
      status: _statusFor(governing.used, remainingDays),
      usedFraction: governing.used,
      dueOdometerM: distance?.dueValue,
      remainingM: distance?.remaining,
      dueDateMs: dueDateMs,
      remainingDays: remainingDays,
      dueDateIsEstimate: isEstimate,
    );
  }

  /// Evaluates every item and sorts by urgency — not alphabetically.
  ///
  /// A rider opening this screen wants to know what needs doing, and the
  /// answer is at the top.
  static List<ServiceDue> plan(
    List<ServiceItemRow> items, {
    required int currentOdometerM,
    double? dailyMetresEstimate,
    int? nowMs,
  }) {
    final dues = [
      for (final item in items)
        evaluate(
          item,
          currentOdometerM: currentOdometerM,
          dailyMetresEstimate: dailyMetresEstimate,
          nowMs: nowMs,
        ),
    ];

    dues.sort((a, b) {
      // ServiceStatus is declared most-urgent-first, so index ordering is
      // urgency ordering.
      final byStatus = a.status.index.compareTo(b.status.index);
      if (byStatus != 0) return byStatus;
      // Within a status, the one further through its interval comes first.
      final byFraction = b.usedFraction.compareTo(a.usedFraction);
      if (byFraction != 0) return byFraction;
      return a.item.name.compareTo(b.item.name);
    });

    return dues;
  }

  static ServiceStatus _statusFor(double used, int? remainingDays) {
    if (used > 1 + overdueMargin) return ServiceStatus.overdue;
    if (used >= 1) return ServiceStatus.dueNow;
    if (used >= 1 - okHeadroom) return ServiceStatus.dueSoon;
    if (remainingDays != null && remainingDays <= soonDays) {
      return ServiceStatus.dueSoon;
    }
    return ServiceStatus.ok;
  }

  static _Axis? _distanceAxis(
    ServiceItemRow item,
    int currentOdometerM,
    double? dailyMetresEstimate, {
    required int now,
  }) {
    final interval = item.intervalM;
    if (interval == null || interval <= 0) return null;

    final last = item.lastDoneOdometerM ?? 0;
    final dueAt = last + interval;
    final remaining = dueAt - currentOdometerM;
    final used = (currentOdometerM - last) / interval;

    // Project a date only when there is a usable riding rate. Guessing here
    // would put a confident-looking date on nothing.
    int? remainingDays;
    int? dueDateMs;
    if (dailyMetresEstimate != null && dailyMetresEstimate > 0) {
      remainingDays = (remaining / dailyMetresEstimate).floor();
      dueDateMs = Dates.addDays(now, remainingDays);
    }

    return _Axis(
      used: used,
      remaining: remaining,
      dueValue: dueAt,
      remainingDays: remainingDays,
      dueDateMs: dueDateMs,
      isEstimate: true,
    );
  }

  static _Axis? _timeAxis(ServiceItemRow item, int now) {
    final intervalDays = item.intervalDays;
    if (intervalDays == null || intervalDays <= 0) return null;

    final last = item.lastDoneDateMs ?? item.createdAt;
    final dueAt = Dates.addDays(last, intervalDays);
    final elapsedDays = Dates.daysBetween(last, now);

    return _Axis(
      used: elapsedDays / intervalDays,
      remaining: dueAt - now,
      dueValue: dueAt,
      remainingDays: Dates.daysBetween(now, dueAt),
      dueDateMs: dueAt,
      isEstimate: false,
    );
  }
}

/// One axis of an item's interval — distance or time — normalised so the two
/// can be compared directly.
class _Axis {
  const _Axis({
    required this.used,
    required this.remaining,
    required this.dueValue,
    required this.remainingDays,
    required this.dueDateMs,
    required this.isEstimate,
  });

  /// Fraction of the interval consumed.
  final double used;

  /// Metres (distance axis) or milliseconds (time axis) left.
  final int remaining;

  /// Odometer reading (distance axis) or timestamp (time axis) it falls due.
  final int dueValue;

  final int? remainingDays;
  final int? dueDateMs;
  final bool isEstimate;
}
