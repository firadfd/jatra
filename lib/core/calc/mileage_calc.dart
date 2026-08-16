import '../../data/db/database.dart';
import '../utils/money.dart';
import '../utils/units.dart';

/// One full-tank-to-full-tank measurement.
///
/// This is the *only* thing that can produce a fuel-economy figure. A partial
/// fill never gets its own number — its volume is accumulated into the window
/// that the next full tank closes.
class MileageWindow {
  const MileageWindow({
    required this.openingEntryId,
    required this.closingEntryId,
    required this.closingDateMs,
    required this.closingOdometerM,
    required this.distanceM,
    required this.volumeMl,
    required this.cost,
    required this.fillCount,
    required this.isReliable,
  });

  /// The full tank that opened the window. Its own volume is *excluded* —
  /// that fuel was burned before the window started.
  final int openingEntryId;

  /// The full tank that closed it. This is the entry a history row hangs the
  /// figure off.
  final int closingEntryId;

  final int closingDateMs;
  final int closingOdometerM;

  /// Odometer difference between the two full tanks.
  final int distanceM;

  /// Every millilitre added after the opening fill, up to and including the
  /// closing one.
  final int volumeMl;

  /// What that fuel cost, summed across the window's fills.
  final Money cost;

  /// How many fills went into the window. Greater than one means partial
  /// fills were rolled in.
  final int fillCount;

  /// False when any fill in the window is flagged as following a missed
  /// entry. The window is still shown in the list — flagged — but never
  /// counted in an average, a best/worst, or a drop comparison.
  final bool isReliable;

  /// Fuel economy in the user's units, or `null` when the window cannot
  /// produce one. Never zero, never infinity.
  double? economy(DistanceUnit d, VolumeUnit v) =>
      Units.economy(distanceM, volumeMl, d, v);

  /// km/L specifically — the internal comparison basis for drop detection,
  /// so the threshold behaves identically for a rider using miles.
  double? get economyKmPerLitre =>
      Units.economy(distanceM, volumeMl, DistanceUnit.km, VolumeUnit.l);

  /// Fuel-only cost per metre, in minor units. `null` for a zero distance.
  double? get costPerMetreMinor =>
      distanceM <= 0 ? null : cost.minor / distanceM;
}

/// A meaningful fall in economy against recent history.
class MileageDrop {
  const MileageDrop({
    required this.latest,
    required this.baseline,
    required this.dropFraction,
    required this.sampleCount,
  });

  /// The latest reliable reading, in km/L.
  final double latest;

  /// Rolling median of the readings before it, in km/L. A median rather than
  /// a mean because one freak tank — a long highway run, a week of gridlock —
  /// should not move the line everything is judged against.
  final double baseline;

  /// How far below [baseline] the latest reading sits, as a positive
  /// fraction. 0.14 ⇒ down 14%.
  final double dropFraction;

  /// How many previous readings the median was taken over.
  final int sampleCount;

  /// The causes worth checking first on a commuter motorcycle, cheapest and
  /// most likely first.
  static const commonCauses = 'tyre pressure, air filter, chain tension';
}

/// Everything the fuel screens need, computed in one pass.
class MileageReport {
  const MileageReport({
    required this.windows,
    required this.windowsByClosingEntry,
    required this.drop,
    required this.totalDistanceM,
    required this.totalVolumeMl,
    required this.totalFuelCost,
  });

  /// Chronological, oldest first. Includes unreliable windows.
  final List<MileageWindow> windows;

  /// Lookup for the history list: does this entry close a window, and which?
  final Map<int, MileageWindow> windowsByClosingEntry;

  /// Non-null when the latest reliable reading has fallen past the
  /// configured threshold.
  final MileageDrop? drop;

  /// Totals across *reliable* windows only — the honest denominator for an
  /// average, since an unreliable window has fuel missing from it.
  final int totalDistanceM;
  final int totalVolumeMl;
  final Money totalFuelCost;

  static const empty = MileageReport(
    windows: [],
    windowsByClosingEntry: {},
    drop: null,
    totalDistanceM: 0,
    totalVolumeMl: 0,
    totalFuelCost: Money.zero,
  );

  List<MileageWindow> get reliableWindows =>
      windows.where((w) => w.isReliable).toList();

  /// Most recent reliable window, or `null` if there is not one yet.
  MileageWindow? get latest =>
      reliableWindows.isEmpty ? null : reliableWindows.last;

  MileageWindow? get previous {
    final r = reliableWindows;
    return r.length < 2 ? null : r[r.length - 2];
  }

  /// Lifetime average, weighted by volume — total distance over total fuel,
  /// not the mean of the per-window figures. Averaging ratios would let a
  /// short tank count as much as a long one.
  double? average(DistanceUnit d, VolumeUnit v) =>
      Units.economy(totalDistanceM, totalVolumeMl, d, v);

  MileageWindow? get best => _extreme(highest: true);
  MileageWindow? get worst => _extreme(highest: false);

  /// Change from the previous reliable window to the latest, as a signed
  /// fraction. Drives the trend arrow on the home screen.
  double? get trendFraction {
    final a = previous?.economyKmPerLitre;
    final b = latest?.economyKmPerLitre;
    if (a == null || b == null || a <= 0) return null;
    return (b - a) / a;
  }

  MileageWindow? _extreme({required bool highest}) {
    MileageWindow? found;
    double? bestValue;
    for (final w in reliableWindows) {
      final value = w.economyKmPerLitre;
      if (value == null) continue;
      if (bestValue == null ||
          (highest ? value > bestValue : value < bestValue)) {
        bestValue = value;
        found = w;
      }
    }
    return found;
  }
}

/// The mileage engine.
///
/// The rules, in the order they matter:
///
/// 1. Economy is only ever measured full tank to full tank.
/// 2. Partial fills accumulate into the next full-tank window; they never
///    produce a figure of their own.
/// 3. `distance ÷ (volumes after the opening full fill, including the
///    closing one)`. The opening fill's own volume is excluded — it was
///    burned before the window began.
/// 4. A window containing a fill flagged `isMissedEntry` is unreliable: it is
///    shown, flagged, and excluded from every aggregate.
/// 5. The first fuel entry can never produce a figure. Callers render `—`.
abstract final class MileageEngine {
  /// [entries] may arrive in any order; they are sorted by odometer here,
  /// with date as a tiebreaker for two fills at the same reading.
  ///
  /// [dropThresholdPercent] of 0 disables drop detection.
  static MileageReport compute(
    List<FuelEntryRow> entries, {
    int dropThresholdPercent = 12,
  }) {
    if (entries.isEmpty) return MileageReport.empty;

    final sorted = [...entries]
      ..sort((a, b) {
        final byOdometer = a.odometerM.compareTo(b.odometerM);
        return byOdometer != 0 ? byOdometer : a.dateMs.compareTo(b.dateMs);
      });

    final windows = <MileageWindow>[];

    // The open window's anchor. Null until the first full tank is seen —
    // fills logged before it describe fuel burned off the record.
    FuelEntryRow? opening;
    var pendingVolumeMl = 0;
    var pendingCost = Money.zero;
    var pendingFills = 0;
    var pendingReliable = true;

    for (final entry in sorted) {
      if (opening == null) {
        // Still looking for a starting point. Only a full tank can be one.
        if (entry.isFullTank) {
          opening = entry;
          pendingVolumeMl = 0;
          pendingCost = Money.zero;
          pendingFills = 0;
          pendingReliable = true;
        }
        continue;
      }

      // Everything after the anchor counts toward the open window, partial
      // or not.
      pendingVolumeMl += entry.volumeMl;
      pendingCost += Money(entry.totalCostMinor);
      pendingFills++;
      if (entry.isMissedEntry) pendingReliable = false;

      if (!entry.isFullTank) continue;

      final distanceM = entry.odometerM - opening.odometerM;

      // Guard every division. A non-positive distance means a duplicate or
      // corrected reading, not a measurement — drop the window but keep the
      // fuel, by rolling the anchor forward without emitting anything.
      if (distanceM > 0 && pendingVolumeMl > 0) {
        windows.add(
          MileageWindow(
            openingEntryId: opening.id,
            closingEntryId: entry.id,
            closingDateMs: entry.dateMs,
            closingOdometerM: entry.odometerM,
            distanceM: distanceM,
            volumeMl: pendingVolumeMl,
            cost: pendingCost,
            fillCount: pendingFills,
            isReliable: pendingReliable,
          ),
        );
      }

      opening = entry;
      pendingVolumeMl = 0;
      pendingCost = Money.zero;
      pendingFills = 0;
      pendingReliable = true;
    }

    var totalDistanceM = 0;
    var totalVolumeMl = 0;
    var totalCost = Money.zero;
    for (final w in windows) {
      if (!w.isReliable) continue;
      totalDistanceM += w.distanceM;
      totalVolumeMl += w.volumeMl;
      totalCost += w.cost;
    }

    return MileageReport(
      windows: windows,
      windowsByClosingEntry: {for (final w in windows) w.closingEntryId: w},
      drop: detectDrop(windows, thresholdPercent: dropThresholdPercent),
      totalDistanceM: totalDistanceM,
      totalVolumeMl: totalVolumeMl,
      totalFuelCost: totalCost,
    );
  }

  /// How many previous readings the median is taken over, at most.
  static const dropLookback = 5;

  /// Fewer than this and there is no "usual" to compare against yet — a new
  /// rider's second tank should not be told their mileage is collapsing.
  static const dropMinSamples = 3;

  /// Compares the latest reliable reading against the rolling median of the
  /// previous [dropLookback].
  static MileageDrop? detectDrop(
    List<MileageWindow> windows, {
    required int thresholdPercent,
  }) {
    if (thresholdPercent <= 0) return null;

    final readings = <double>[
      for (final w in windows)
        if (w.isReliable && w.economyKmPerLitre != null) w.economyKmPerLitre!,
    ];
    if (readings.length < dropMinSamples + 1) return null;

    final latest = readings.last;
    final priors = readings
        .sublist(0, readings.length - 1)
        .reversed
        .take(dropLookback)
        .toList();

    final baseline = _median(priors);
    if (baseline <= 0) return null;

    final dropFraction = (baseline - latest) / baseline;
    if (dropFraction * 100 <= thresholdPercent) return null;

    return MileageDrop(
      latest: latest,
      baseline: baseline,
      dropFraction: dropFraction,
      sampleCount: priors.length,
    );
  }

  static double _median(List<double> values) {
    if (values.isEmpty) return 0;
    final sorted = [...values]..sort();
    final mid = sorted.length ~/ 2;
    return sorted.length.isOdd
        ? sorted[mid]
        : (sorted[mid - 1] + sorted[mid]) / 2;
  }
}
