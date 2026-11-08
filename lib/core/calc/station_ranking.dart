import '../../data/db/database.dart';
import '../utils/units.dart';
import 'mileage_calc.dart';

/// What one fuel station's tanks returned.
class StationStat {
  const StationStat({
    required this.name,
    required this.windowCount,
    required this.distanceM,
    required this.volumeMl,
  });

  /// The spelling used on the station's most recent fill.
  final String name;
  final int windowCount;
  final int distanceM;
  final int volumeMl;

  double? get economyKmPerLitre =>
      Units.economy(distanceM, volumeMl, DistanceUnit.km, VolumeUnit.l);
}

/// Ranks fuel stations by the mileage their fuel delivered.
///
/// **A window is credited to the fuel it burned**, which is not the fuel that
/// closed it. The bike covers a window's distance on what went in at the
/// opening full tank plus any partial top-ups along the way; the closing fill
/// only measures how much of that was used, and its own fuel is burned in the
/// *next* window. So the closing fill's station has no bearing here.
///
/// A window counts only when every fill it burned names the same station. A
/// blank station or a mix of two says nothing about either, and is dropped
/// rather than split.
abstract final class StationRanking {
  /// One tank is an anecdote: a single highway run would top the table.
  static const minWindows = 2;

  /// Best first. [windows] come from [MileageEngine.compute] over [entries];
  /// unreliable ones are ignored. [closedWithin] limits which windows count
  /// by closing date, for the statistics range.
  static List<StationStat> compute(
    List<FuelEntryRow> entries,
    List<MileageWindow> windows, {
    bool Function(int closingDateMs)? closedWithin,
  }) {
    final ordered = MileageEngine.inWindowOrder(entries);
    final positionOf = {
      for (var i = 0; i < ordered.length; i++) ordered[i].id: i,
    };

    final totals = <String, _Tally>{};
    for (final window in windows) {
      if (!window.isReliable) continue;
      if (closedWithin != null && !closedWithin(window.closingDateMs)) continue;

      final from = positionOf[window.openingEntryId];
      final to = positionOf[window.closingEntryId];
      if (from == null || to == null || from >= to) continue;

      final key = _soleStation(ordered.sublist(from, to));
      if (key == null) continue;

      (totals[key] ??= _Tally())
        ..windows += 1
        ..distanceM += window.distanceM
        ..volumeMl += window.volumeMl;
    }

    // Named after the newest spelling anywhere in the log, so a corrected
    // name shows even if that fill has not closed a window yet.
    final names = <String, String>{};
    for (final entry in [...entries]..sort((a, b) => a.dateMs - b.dateMs)) {
      final key = _key(entry.station);
      if (key != null) names[key] = entry.station!.trim();
    }

    final stats = [
      for (final MapEntry(:key, :value) in totals.entries)
        if (value.windows >= minWindows)
          StationStat(
            name: names[key] ?? key,
            windowCount: value.windows,
            distanceM: value.distanceM,
            volumeMl: value.volumeMl,
          ),
    ];

    return stats..sort(
      (a, b) => (b.economyKmPerLitre ?? 0).compareTo(a.economyKmPerLitre ?? 0),
    );
  }

  /// The one station all of [fills] came from, or null if there is not one.
  static String? _soleStation(List<FuelEntryRow> fills) {
    final first = _key(fills.first.station);
    if (first == null) return null;
    return fills.every((f) => _key(f.station) == first) ? first : null;
  }

  /// "Meghna  Pump" and "meghna pump" are one place.
  static String? _key(String? station) {
    final key = station?.trim().replaceAll(RegExp(r'\s+'), ' ').toLowerCase();
    return key == null || key.isEmpty ? null : key;
  }
}

class _Tally {
  int windows = 0;
  int distanceM = 0;
  int volumeMl = 0;
}
