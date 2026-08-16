import '../utils/clock.dart';

/// The scope selector shared by the cost figures and every chart.
enum RangePreset {
  thisMonth,
  last3Months,
  thisYear,
  allTime,
  custom;

  String get label => switch (this) {
    RangePreset.thisMonth => 'This month',
    RangePreset.last3Months => 'Last 3 months',
    RangePreset.thisYear => 'This year',
    RangePreset.allTime => 'All time',
    RangePreset.custom => 'Custom',
  };
}

/// A half-open-feeling but inclusive window over local days.
///
/// Boundaries are snapped to local midnight and local end-of-day, not UTC:
/// a fill logged at 9pm in Dhaka belongs to that day, not to tomorrow.
class DateRange {
  const DateRange({
    required this.fromMs,
    required this.toMs,
    required this.preset,
  });

  final int fromMs;
  final int toMs;
  final RangePreset preset;

  /// Everything ever logged. `fromMs` of 0 is the epoch, which predates any
  /// motorcycle this app will see.
  static DateRange allTime({int? nowMs}) => DateRange(
    fromMs: 0,
    toMs: Dates.endOfLocalDay(nowMs ?? Clock.nowMs),
    preset: RangePreset.allTime,
  );

  static DateRange thisMonth({int? nowMs}) {
    final now = nowMs ?? Clock.nowMs;
    return DateRange(
      fromMs: Dates.startOfLocalMonth(now),
      toMs: Dates.endOfLocalDay(now),
      preset: RangePreset.thisMonth,
    );
  }

  /// The current month plus the two before it.
  static DateRange last3Months({int? nowMs}) {
    final now = nowMs ?? Clock.nowMs;
    final d = DateTime.fromMillisecondsSinceEpoch(now);
    return DateRange(
      fromMs: DateTime(d.year, d.month - 2).millisecondsSinceEpoch,
      toMs: Dates.endOfLocalDay(now),
      preset: RangePreset.last3Months,
    );
  }

  static DateRange thisYear({int? nowMs}) {
    final now = nowMs ?? Clock.nowMs;
    return DateRange(
      fromMs: Dates.startOfLocalYear(now),
      toMs: Dates.endOfLocalDay(now),
      preset: RangePreset.thisYear,
    );
  }

  static DateRange custom(int fromMs, int toMs) => DateRange(
    fromMs: Dates.startOfLocalDay(fromMs),
    toMs: Dates.endOfLocalDay(toMs),
    preset: RangePreset.custom,
  );

  static DateRange of(RangePreset preset, {int? nowMs}) => switch (preset) {
    RangePreset.thisMonth => thisMonth(nowMs: nowMs),
    RangePreset.last3Months => last3Months(nowMs: nowMs),
    RangePreset.thisYear => thisYear(nowMs: nowMs),
    RangePreset.allTime => allTime(nowMs: nowMs),
    // A custom range has no defaults to derive; callers supply the dates.
    RangePreset.custom => allTime(nowMs: nowMs),
  };

  bool contains(int ms) => ms >= fromMs && ms <= toMs;

  /// Whole days covered, at least 1 — a single-day range still divides.
  int get days {
    final span = Dates.daysBetween(fromMs, toMs) + 1;
    return span < 1 ? 1 : span;
  }

  /// Overlap with another window, or `null` when they do not intersect.
  /// Used to prorate depreciation across the part of a range the bike was
  /// actually owned for.
  DateRange? intersect(int otherFromMs, int otherToMs) {
    final from = fromMs > otherFromMs ? fromMs : otherFromMs;
    final to = toMs < otherToMs ? toMs : otherToMs;
    if (from > to) return null;
    return DateRange(fromMs: from, toMs: to, preset: preset);
  }
}
