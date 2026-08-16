/// Single source of "now".
///
/// Every timestamp written to the database goes through here so tests can
/// freeze time and assert on due-date predictions and mileage windows
/// deterministically. Calling `DateTime.now()` directly anywhere outside this
/// file makes those tests flaky.
abstract final class Clock {
  static int Function() _source = () => DateTime.now().millisecondsSinceEpoch;

  /// UTC epoch milliseconds.
  static int get nowMs => _source();

  static DateTime get now => DateTime.fromMillisecondsSinceEpoch(nowMs);

  /// Test hook. Pass `null` to restore the real clock.
  static void freeze(DateTime? at) {
    if (at == null) {
      _source = () => DateTime.now().millisecondsSinceEpoch;
    } else {
      final fixed = at.millisecondsSinceEpoch;
      _source = () => fixed;
    }
  }
}

/// Date arithmetic used by service prediction and the stats range selector.
abstract final class Dates {
  static const msPerDay = 86400000;

  static int daysBetween(int fromMs, int toMs) =>
      ((toMs - fromMs) / msPerDay).floor();

  static int addDays(int ms, int days) => ms + days * msPerDay;

  /// Midnight local time on the day containing [ms], as epoch millis.
  ///
  /// Grouping and range filtering must happen in the user's local day, not in
  /// UTC — otherwise a fill logged at 9pm in Dhaka lands in tomorrow's bucket.
  static int startOfLocalDay(int ms) {
    final d = DateTime.fromMillisecondsSinceEpoch(ms);
    return DateTime(d.year, d.month, d.day).millisecondsSinceEpoch;
  }

  static int endOfLocalDay(int ms) {
    final d = DateTime.fromMillisecondsSinceEpoch(ms);
    return DateTime(
      d.year,
      d.month,
      d.day,
      23,
      59,
      59,
      999,
    ).millisecondsSinceEpoch;
  }

  static int startOfLocalMonth(int ms) {
    final d = DateTime.fromMillisecondsSinceEpoch(ms);
    return DateTime(d.year, d.month).millisecondsSinceEpoch;
  }

  static int startOfLocalYear(int ms) {
    final d = DateTime.fromMillisecondsSinceEpoch(ms);
    return DateTime(d.year).millisecondsSinceEpoch;
  }

  /// Stable sort key for month grouping: `202608`.
  static int monthKey(int ms) {
    final d = DateTime.fromMillisecondsSinceEpoch(ms);
    return d.year * 100 + d.month;
  }
}
