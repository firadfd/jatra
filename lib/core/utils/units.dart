import '../../data/models/enums.dart';

/// Canonical storage units — the single most important convention in this
/// codebase. Everything in the database is an exact integer:
///
/// | quantity | column suffix | unit                       |
/// |----------|---------------|----------------------------|
/// | distance | `…M`          | metres                     |
/// | volume   | `…Ml`         | millilitres                |
/// | money    | `…Minor`      | minor units (paisa, cents) |
/// | time     | `…Ms`         | UTC epoch milliseconds     |
///
/// Nothing is stored as a floating-point number. Doubles appear only at the
/// moment a value is displayed or fed to a chart. This is what makes
/// "money totals exact to the paisa across 200+ entries" achievable rather
/// than aspirational.
///
/// The user's chosen `distanceUnit` / `volumeUnit` affect *display and input
/// parsing only*. Changing them never rewrites a row.
abstract final class Units {
  // --- Distance ---
  static const metresPerKm = 1000.0;
  static const metresPerMile = 1609.344;

  // --- Volume ---
  static const mlPerLitre = 1000.0;

  /// US liquid gallon.
  static const mlPerGallon = 3785.411784;

  static double metresToKm(int metres) => metres / metresPerKm;

  static double metresToMiles(int metres) => metres / metresPerMile;

  static double metresTo(int metres, DistanceUnit unit) => switch (unit) {
    DistanceUnit.km => metresToKm(metres),
    DistanceUnit.mi => metresToMiles(metres),
  };

  /// Rounds to the nearest metre. Odometers are read to 0.1 km at best, so
  /// sub-metre precision is noise.
  static int toMetres(double value, DistanceUnit unit) => switch (unit) {
    DistanceUnit.km => (value * metresPerKm).round(),
    DistanceUnit.mi => (value * metresPerMile).round(),
  };

  static double mlToLitres(int ml) => ml / mlPerLitre;

  static double mlToGallons(int ml) => ml / mlPerGallon;

  static double mlTo(int ml, VolumeUnit unit) => switch (unit) {
    VolumeUnit.l => mlToLitres(ml),
    VolumeUnit.gal => mlToGallons(ml),
  };

  static int toMl(double value, VolumeUnit unit) => switch (unit) {
    VolumeUnit.l => (value * mlPerLitre).round(),
    VolumeUnit.gal => (value * mlPerGallon).round(),
  };

  /// Fuel economy in the user's units.
  ///
  /// km/L is metres÷millilitres exactly (both scale by 1000), which is why the
  /// km branch needs no conversion factor at all.
  ///
  /// Returns `null` for a non-positive distance or volume — never 0, never
  /// infinity. Callers render `null` as an em dash, per the spec: the first
  /// fuel entry must show "—", not zero.
  static double? economy(int metres, int ml, DistanceUnit d, VolumeUnit v) {
    if (metres <= 0 || ml <= 0) return null;
    final distance = metresTo(metres, d);
    final volume = mlTo(ml, v);
    if (volume <= 0) return null;
    return distance / volume;
  }

  /// Re-expresses a km/L figure in the user's units.
  ///
  /// The calculators work in km/L internally so a percentage threshold means
  /// the same thing for every rider. Only the display converts.
  static double economyFromKmPerLitre(
    double kmPerLitre,
    DistanceUnit d,
    VolumeUnit v,
  ) {
    final volumePerUnit = switch (v) {
      VolumeUnit.l => mlPerLitre,
      VolumeUnit.gal => mlPerGallon,
    };
    final metresPerUnit = switch (d) {
      DistanceUnit.km => metresPerKm,
      DistanceUnit.mi => metresPerMile,
    };
    return kmPerLitre * volumePerUnit / metresPerUnit;
  }

  /// Label for a fuel-economy figure, e.g. `KM/L`, `MI/GAL`.
  static String economyLabel(DistanceUnit d, VolumeUnit v) =>
      '${d.label}/${v.label}';

  /// Label for a cost-per-distance figure, e.g. `/KM`.
  static String perDistanceLabel(DistanceUnit d) => '/${d.label}';

  /// Label for a price-per-volume figure, e.g. `/L`.
  static String perVolumeLabel(VolumeUnit v) => '/${v.label}';

  // --- Speed (rides) ---
  static const mpsToKmh = 3.6;

  static double speedTo(double metresPerSecond, DistanceUnit unit) =>
      switch (unit) {
        DistanceUnit.km => metresPerSecond * mpsToKmh,
        DistanceUnit.mi => metresPerSecond * mpsToKmh / 1.609344,
      };

  static String speedLabel(DistanceUnit d) => switch (d) {
    DistanceUnit.km => 'KM/H',
    DistanceUnit.mi => 'MPH',
  };
}
