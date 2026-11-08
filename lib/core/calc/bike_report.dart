import '../../data/db/database.dart';
import '../utils/clock.dart';
import '../utils/money.dart';

/// One row of the odometer timeline.
class OdometerRow {
  const OdometerRow({
    required this.dateMs,
    required this.odometerM,
    required this.isLowerThanEarlier,
  });

  final int dateMs;
  final int odometerM;

  /// Below a reading logged earlier. Could be a replaced cluster or a typo,
  /// but a buyer is entitled to see it either way.
  final bool isLowerThanEarlier;
}

/// Everything the resale report prints, worked out from the raw log.
class BikeReport {
  const BikeReport({
    required this.vehicle,
    required this.services,
    required this.parts,
    required this.odometer,
    required this.lowerReadingCount,
    required this.latestOdometerM,
    required this.firstRecordMs,
    required this.fuelTotal,
    required this.serviceTotal,
    required this.otherTotal,
  });

  final VehicleRow vehicle;

  /// Oldest first, the way a service book reads.
  final List<ServiceLogRow> services;

  /// The subset of [services] that involved a part.
  final List<ServiceLogRow> parts;

  /// The last reading of each month, plus every lower-than-earlier reading.
  final List<OdometerRow> odometer;

  /// Counted over all readings.
  final int lowerReadingCount;
  final int latestOdometerM;
  final int? firstRecordMs;

  final Money fuelTotal;
  final Money serviceTotal;
  final Money otherTotal;

  Money get total => fuelTotal + serviceTotal + otherTotal;

  /// [fuel], [services] and [expenses] must already exclude deleted rows,
  /// which every repository read does.
  static BikeReport build({
    required VehicleRow vehicle,
    required List<FuelEntryRow> fuel,
    required List<ServiceLogRow> services,
    required List<ExpenseRow> expenses,
  }) {
    final byDate = [...services]
      ..sort((a, b) {
        final d = a.dateMs.compareTo(b.dateMs);
        return d != 0 ? d : a.odometerM.compareTo(b.odometerM);
      });

    final readings =
        <({int dateMs, int odometerM})>[
          for (final f in fuel) (dateMs: f.dateMs, odometerM: f.odometerM),
          for (final s in services) (dateMs: s.dateMs, odometerM: s.odometerM),
        ]..sort((a, b) {
          // Odometer as tiebreaker: two entries from one day have no reliable
          // order between them, and must not read as a rollback.
          final d = a.dateMs.compareTo(b.dateMs);
          return d != 0 ? d : a.odometerM.compareTo(b.odometerM);
        });

    final timeline = <OdometerRow>[];
    var highest = vehicle.initialOdometerM;
    var lowerCount = 0;
    int? openMonth;

    for (final r in readings) {
      final isLower = r.odometerM < highest;
      if (isLower) lowerCount++;
      if (r.odometerM > highest) highest = r.odometerM;

      final month = Dates.startOfLocalMonth(r.dateMs);
      final previousIsReplaceable =
          month == openMonth &&
          timeline.isNotEmpty &&
          !timeline.last.isLowerThanEarlier;
      if (previousIsReplaceable) timeline.removeLast();
      timeline.add(
        OdometerRow(
          dateMs: r.dateMs,
          odometerM: r.odometerM,
          isLowerThanEarlier: isLower,
        ),
      );
      openMonth = month;
    }

    Money sum<T>(List<T> rows, int Function(T) minor) =>
        rows.fold(Money.zero, (total, row) => total + Money(minor(row)));

    return BikeReport(
      vehicle: vehicle,
      services: byDate,
      parts: [
        for (final s in byDate)
          if (s.partsCostMinor > 0 || (s.partBrand?.trim().isNotEmpty ?? false))
            s,
      ],
      odometer: timeline,
      lowerReadingCount: lowerCount,
      latestOdometerM: highest,
      firstRecordMs: readings.isEmpty ? null : readings.first.dateMs,
      fuelTotal: sum(fuel, (f) => f.totalCostMinor),
      serviceTotal: sum(services, (s) => s.totalCostMinor),
      otherTotal: sum(expenses, (e) => e.amountMinor),
    );
  }
}
