import '../../data/models/enums.dart';
import 'formatters.dart';
import 'money.dart';
import 'units.dart';

/// Form validation.
///
/// Every message names the specific thing that is wrong and, where possible,
/// the value it conflicts with:
///
///   "Odometer must be higher than your last reading of 24,180 km."
///
/// Never "Invalid input."
abstract final class Validate {
  static String? required(String? value, String field) {
    if (value == null || value.trim().isEmpty) return 'Enter a $field.';
    return null;
  }

  /// A plain positive number, e.g. a volume or a distance.
  static String? positiveNumber(String? value, String field) {
    if (value == null || value.trim().isEmpty) return 'Enter a $field.';
    final parsed = double.tryParse(value.replaceAll(',', '').trim());
    if (parsed == null) return '$field must be a number.';
    if (parsed <= 0) return '$field must be greater than zero.';
    if (!parsed.isFinite) return '$field is too large.';
    return null;
  }

  static String? nonNegativeNumber(String? value, String field) {
    if (value == null || value.trim().isEmpty) return null;
    final parsed = double.tryParse(value.replaceAll(',', '').trim());
    if (parsed == null) return '$field must be a number.';
    if (parsed < 0) return '$field cannot be negative.';
    return null;
  }

  static String? money(String? value, String field, {bool allowEmpty = false}) {
    if (value == null || value.trim().isEmpty) {
      return allowEmpty ? null : 'Enter a $field.';
    }
    final parsed = Money.tryParse(value);
    if (parsed == null) return '$field must be an amount, like 1250.50.';
    if (parsed.minor < 0) return '$field cannot be negative.';
    return null;
  }

  /// Odometer readings must increase. Returns a message naming the previous
  /// reading, which the user can override with a confirmation for a genuine
  /// correction (a replaced cluster, a misread digit).
  ///
  /// [previousMetres] is the highest reading already recorded for this
  /// vehicle across fuel entries, service logs and rides.
  static String? odometerAgainst(
    String? value, {
    required int previousMetres,
    required DistanceUnit unit,
    required Fmt fmt,
  }) {
    final base = positiveNumber(value, 'odometer reading');
    if (base != null) return base;

    final entered = Units.toMetres(
      double.parse(value!.replaceAll(',', '').trim()),
      unit,
    );
    if (entered < previousMetres) {
      return 'Odometer must be higher than your last reading of '
          '${fmt.distance(previousMetres)} ${unit.label.toLowerCase()}.';
    }
    return null;
  }

  /// Year sanity for a vehicle. Wide bounds on purpose — people log
  /// classic bikes.
  static String? year(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    final parsed = int.tryParse(value.trim());
    if (parsed == null) return 'Year must be a number, like 2021.';
    final thisYear = DateTime.now().year;
    if (parsed < 1900 || parsed > thisYear + 1) {
      return 'Year must be between 1900 and ${thisYear + 1}.';
    }
    return null;
  }

  static String? engineCc(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    final parsed = int.tryParse(value.trim());
    if (parsed == null) return 'Engine size must be a whole number of cc.';
    if (parsed <= 0 || parsed > 5000) {
      return 'Engine size must be between 1 and 5000 cc.';
    }
    return null;
  }

  /// Warns when a fill is larger than the tank it went into — usually a
  /// typo, occasionally a jerry can, so this is a warning and not a block.
  static String? volumeAgainstTank({
    required int volumeMl,
    required int? tankCapacityMl,
    required Fmt fmt,
  }) {
    if (tankCapacityMl == null || tankCapacityMl <= 0) return null;
    if (volumeMl <= tankCapacityMl) return null;
    return 'That is more than the ${fmt.volume(tankCapacityMl)} '
        '${fmt.volumeLabel.toLowerCase()} tank holds. Saved anyway — '
        'edit it if it was a typo.';
  }
}
