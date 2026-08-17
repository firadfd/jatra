import 'package:flutter/material.dart';
import 'package:get/get.dart' hide Value;

import '../../app/routes/app_routes.dart';
import '../../app/theme/app_dimens.dart';
import '../../app/theme/app_text.dart';
import '../../app/theme/app_theme.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/jatra_widgets.dart';
import '../../data/db/database.dart';
import '../../data/repositories/ride_repo.dart';
import '../vehicles/vehicle_controller.dart';
import 'widgets/ride_map.dart';
import '../../l10n/app_localizations.dart';

/// One ride: the path, the numbers, and the elevation profile if the device
/// reported altitude.
class RideDetailView extends StatefulWidget {
  const RideDetailView({super.key});

  @override
  State<RideDetailView> createState() => _RideDetailViewState();
}

class _RideDetailViewState extends State<RideDetailView> {
  late final int _rideId;
  RideRow? _ride;
  List<RidePointRow> _points = const [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    final args = Get.arguments;
    _rideId = args is Map ? args[RouteArgs.rideId] as int? ?? 0 : 0;
    _load();
  }

  Future<void> _load() async {
    final repo = Get.find<RideRepo>();
    final ride = await repo.getById(_rideId);
    // The full path is read once here. Simplification for rendering happens
    // inside RideMap; the database keeps every point.
    final points = ride == null
        ? <RidePointRow>[]
        : await repo.getPoints(_rideId);

    if (!mounted) return;
    setState(() {
      _ride = ride;
      _points = points;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final fmt = Get.find<VehicleController>().fmt.value;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _ride?.title ??
              (_ride == null
                  ? L.of(context).ridesFallbackTitle
                  : fmt.dateShort(_ride!.startTimeMs)),
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _ride == null
          ? EmptyState(
              icon: Icons.route_outlined,
              title: L.of(context).ridesNotFoundTitle,
              message: L.of(context).ridesNotFoundBody,
            )
          : _RideBody(ride: _ride!, points: _points, fmt: fmt),
    );
  }
}

class _RideBody extends StatelessWidget {
  const _RideBody({
    required this.ride,
    required this.points,
    required this.fmt,
  });

  final RideRow ride;
  final List<RidePointRow> points;
  final Fmt fmt;

  @override
  Widget build(BuildContext context) {
    final c = context.jatra;
    final gapCount = points.where((p) => p.isGapStart).length;

    return ContentColumn(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(Gap.md, Gap.md, Gap.md, Gap.xl),
        children: [
          RideMap(points: points, fmt: fmt),
          const SizedBox(height: Gap.md),

          if (gapCount > 0)
            Padding(
              padding: const EdgeInsets.only(bottom: Gap.md),
              child: JatraCard(
                accent: c.dueSoon,
                child: Text(
                  gapCount == 1
                      ? L.of(context).ridesGapOnce
                      : L.of(context).ridesGapMany(gapCount),
                  style: AppText.bodySm.copyWith(color: c.textSecondary),
                ),
              ),
            ),

          _StatGrid(ride: ride, fmt: fmt),
          const SizedBox(height: Gap.md),

          JatraCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SectionLabel(L.of(context).ridesDetails),
                const SizedBox(height: Gap.sm),
                DetailRow(
                  label: L.of(context).ridesStarted,
                  value: Text(
                    fmt.dateTime(ride.startTimeMs),
                    style: AppText.bodySm.copyWith(color: c.textSecondary),
                  ),
                ),
                if (ride.endTimeMs != null)
                  DetailRow(
                    label: L.of(context).ridesFinished,
                    value: Text(
                      fmt.dateTime(ride.endTimeMs!),
                      style: AppText.bodySm.copyWith(color: c.textSecondary),
                    ),
                  ),
                DetailRow(
                  label: L.of(context).ridesGpsPoints,
                  value: Text(
                    '${points.length}',
                    style: AppText.bodySm.copyWith(color: c.textSecondary),
                  ),
                ),
                if (ride.notes != null)
                  DetailRow(
                    label: L.of(context).ridesNotes,
                    value: Flexible(
                      child: Text(
                        ride.notes!,
                        textAlign: TextAlign.right,
                        style: AppText.bodySm.copyWith(color: c.textSecondary),
                      ),
                    ),
                  ),
              ],
            ),
          ),

          if (_hasAltitude(points)) ...[
            const SizedBox(height: Gap.md),
            _ElevationProfile(points: points, fmt: fmt),
          ],
        ],
      ),
    );
  }

  static bool _hasAltitude(List<RidePointRow> points) {
    final withAltitude = points.where((p) => p.altitude != null).toList();
    if (withAltitude.length < 5) return false;

    // Flat within a couple of metres is GPS noise, not terrain. Drawing a
    // profile of it would invent hills.
    final values = withAltitude.map((p) => p.altitude!);
    final min = values.reduce((a, b) => a < b ? a : b);
    final max = values.reduce((a, b) => a > b ? a : b);
    return max - min > 5;
  }
}

class _StatGrid extends StatelessWidget {
  const _StatGrid({required this.ride, required this.fmt});

  final RideRow ride;
  final Fmt fmt;

  @override
  Widget build(BuildContext context) {
    final c = context.jatra;

    final tiles = <({String label, String value, String? unit, Color? colour})>[
      (
        label: L.of(context).statsDistance,
        value: fmt.distancePrecise(ride.distanceMeters),
        unit: fmt.distanceLabel,
        colour: c.data,
      ),
      (
        label: L.of(context).ridesMovingTime,
        value: fmt.duration(ride.movingSeconds),
        unit: null,
        colour: null,
      ),
      (
        label: L.of(context).ridesTotalTime,
        value: fmt.duration(ride.totalSeconds),
        unit: null,
        colour: null,
      ),
      (
        label: L.of(context).ridesAverageSpeed,
        value: fmt.speed(ride.avgSpeed),
        unit: fmt.speedLabel,
        colour: null,
      ),
      (
        label: L.of(context).ridesTopSpeed,
        value: fmt.speed(ride.maxSpeed),
        unit: fmt.speedLabel,
        colour: c.signal,
      ),
      (
        label: L.of(context).ridesStopped,
        value: fmt.duration(
          // Guard: a resumed ride can briefly report moving > total.
          (ride.totalSeconds - ride.movingSeconds).clamp(0, 1 << 31),
        ),
        unit: null,
        colour: null,
      ),
    ];

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: Gap.sm,
      mainAxisSpacing: Gap.sm,
      childAspectRatio: 2.1,
      children: [
        for (final tile in tiles)
          JatraCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SectionLabel(tile.label),
                const SizedBox(height: Gap.xs),
                StatValue(
                  value: tile.value,
                  unit: tile.unit,
                  style: AppText.numeralMd,
                  color: tile.colour,
                ),
              ],
            ),
          ),
      ],
    );
  }
}

/// Altitude over the ride, drawn directly rather than through the chart
/// library — it is a single filled sparkline with no axes, and a full chart
/// widget would be more scaffolding than shape.
class _ElevationProfile extends StatelessWidget {
  const _ElevationProfile({required this.points, required this.fmt});

  final List<RidePointRow> points;
  final Fmt fmt;

  @override
  Widget build(BuildContext context) {
    final c = context.jatra;
    final altitudes = [
      for (final p in points)
        if (p.altitude != null) p.altitude!,
    ];

    final min = altitudes.reduce((a, b) => a < b ? a : b);
    final max = altitudes.reduce((a, b) => a > b ? a : b);

    return JatraCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionLabel(
            L.of(context).ridesElevation,
            trailing: Text(
              '${min.round()} – ${max.round()} m',
              style: AppText.caption.copyWith(color: c.textMuted),
            ),
          ),
          const SizedBox(height: Gap.md),
          SizedBox(
            height: 80,
            width: double.infinity,
            child: CustomPaint(
              painter: _ElevationPainter(
                altitudes: altitudes,
                line: c.data,
                fill: c.data.withValues(alpha: 0.15),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ElevationPainter extends CustomPainter {
  const _ElevationPainter({
    required this.altitudes,
    required this.line,
    required this.fill,
  });

  final List<double> altitudes;
  final Color line;
  final Color fill;

  @override
  void paint(Canvas canvas, Size size) {
    if (altitudes.length < 2) return;

    final min = altitudes.reduce((a, b) => a < b ? a : b);
    final max = altitudes.reduce((a, b) => a > b ? a : b);
    final span = max - min;
    if (span <= 0) return;

    // Sampled down to roughly one point per pixel; more would be invisible.
    final step = (altitudes.length / size.width).ceil().clamp(1, 1 << 20);

    final path = Path();
    for (var i = 0, x = 0; i < altitudes.length; i += step, x++) {
      final dx = x.toDouble();
      final dy = size.height - ((altitudes[i] - min) / span) * size.height;
      if (i == 0) {
        path.moveTo(dx, dy);
      } else {
        path.lineTo(dx, dy);
      }
    }

    final area = Path.from(path)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    canvas
      ..drawPath(area, Paint()..color = fill)
      ..drawPath(
        path,
        Paint()
          ..color = line
          ..strokeWidth = 2
          ..style = PaintingStyle.stroke,
      );
  }

  @override
  bool shouldRepaint(_ElevationPainter oldDelegate) =>
      oldDelegate.altitudes != altitudes || oldDelegate.line != line;
}
