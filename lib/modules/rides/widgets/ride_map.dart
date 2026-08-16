import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_dimens.dart';
import '../../../app/theme/app_text.dart';
import '../../../app/theme/app_theme.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/utils/geo_utils.dart';
import '../../../data/db/database.dart';
import '../../../l10n/app_localizations.dart';

/// Renders a ride path over OpenStreetMap tiles.
///
/// Tiles come from OSM's standard server, which needs no account and no API
/// key. Two obligations come with that, and both are met here: the tile
/// requests carry an identifying User-Agent, and the map carries visible
/// attribution.
///
/// **Offline still works.** Tiles are the only part of this screen that needs
/// a network. When they fail to load, flutter_map simply draws nothing for
/// them and the faint grid behind shows through — so the polyline, the
/// endpoints and the scale bar are all still readable with no connection.
///
/// The path is simplified for display only — the database always keeps every
/// point.
class RideMap extends StatelessWidget {
  const RideMap({
    super.key,
    required this.points,
    required this.fmt,
    this.height = 260,
    this.interactive = true,
    this.fallbackCentre,
    this.myLocation,
    this.mapController,
  });

  final List<RidePointRow> points;
  final Fmt fmt;
  final double height;
  final bool interactive;

  /// The rider's current position, drawn as a dot with an accuracy halo.
  ///
  /// Null on every screen that has not asked for it — this widget never
  /// reaches for the GPS itself, it only draws what it is handed.
  final GeoPoint? myLocation;

  /// Lets the caller drive the camera (recentre on the dot, for instance).
  /// flutter_map expects this to be owned and disposed by whoever creates it.
  final MapController? mapController;

  /// Where to point the camera when there is no path to fit.
  ///
  /// Null — the default — keeps the "no path recorded" message, which is the
  /// honest answer on a ride detail screen: that ride genuinely has no path,
  /// and a map of somewhere else would be a lie. The Map *tab* passes a centre
  /// instead, because there a browsable map is the point of the screen.
  final LatLng? fallbackCentre;

  @override
  Widget build(BuildContext context) {
    final c = context.jatra;

    final hasPath = points.length >= 2;
    final me = myLocation;
    // With no path but a known position, "here" is a better opening view than
    // any fixed fallback.
    final centre =
        fallbackCentre ?? (me == null ? null : LatLng(me.lat, me.lng));

    if (!hasPath && centre == null) {
      return SizedBox(
        height: height,
        child: Center(
          child: Text(
            L.of(context).ridesNoPath,
            style: AppText.bodySm.copyWith(color: c.textMuted),
          ),
        ),
      );
    }

    // Split at gap markers so the polyline breaks instead of drawing a
    // straight line across a stretch that was never recorded.
    final segments = hasPath ? _segments(points) : const <List<LatLng>>[];
    final bounds = hasPath
        ? boundsOf([
            for (final p in points)
              GeoPoint(lat: p.lat, lng: p.lng, timestampMs: p.timestampMs),
          ])
        : null;

    final camera = bounds == null
        ? null
        : LatLngBounds(
            LatLng(bounds.minLat, bounds.minLng),
            LatLng(bounds.maxLat, bounds.maxLng),
          );

    // A path fits its own bounds; an empty map opens on the fallback at city
    // scale, which is close enough to recognise streets and wide enough to
    // orient.
    final hasSegments = segments.isNotEmpty;

    return ClipRRect(
      borderRadius: BorderRadius.circular(Radii.card),
      child: SizedBox(
        height: height,
        child: Stack(
          children: [
            Positioned.fill(
              child: CustomPaint(painter: _GridPainter(c.gridLine)),
            ),
            FlutterMap(
              mapController: mapController,
              options: MapOptions(
                initialCameraFit: camera == null
                    ? null
                    : CameraFit.bounds(
                        bounds: camera,
                        padding: const EdgeInsets.all(Gap.lg),
                        // A ride that has just started spans a few metres, and
                        // fitting that exactly asks for a zoom past anything
                        // OSM renders. Capped at street level, which is as
                        // close as the tiles go.
                        maxZoom: 18,
                      ),
                initialCenter: centre ?? const LatLng(0, 0),
                initialZoom: 12,
                interactionOptions: InteractionOptions(
                  flags: interactive
                      ? InteractiveFlag.pinchZoom | InteractiveFlag.drag
                      : InteractiveFlag.none,
                ),
                backgroundColor: Colors.transparent,
              ),
              children: [
                _tileLayer(),
                if (hasSegments) ...[
                  PolylineLayer(
                    polylines: [
                      for (final segment in segments)
                        Polyline(
                          points: segment,
                          // 2px, per the chart mark spec — the path is data.
                          strokeWidth: 3,
                          color: c.data,
                        ),
                    ],
                  ),
                  MarkerLayer(
                    markers: [
                      _endpoint(
                        segments.first.first,
                        c.ok,
                        L.of(context).mapStart,
                      ),
                      _endpoint(
                        segments.last.last,
                        c.overdue,
                        L.of(context).mapEnd,
                      ),
                    ],
                  ),
                ],
                // Drawn last so the dot sits above the path rather than
                // disappearing under it when the rider is on their own track.
                if (me != null) ..._myLocationLayers(me, c, L.of(context)),
              ],
            ),
            if (bounds != null)
              Positioned(
                left: Gap.sm,
                top: Gap.sm,
                child: _ScaleBar(bounds: bounds, fmt: fmt),
              ),
            // Required by OSM's tile usage policy, not decoration — so it
            // lives in the one corner nothing floats over. Map screens put
            // their controls bottom-right, and a button on top of the
            // attribution is the same as having no attribution.
            const Positioned(
              left: Gap.sm,
              bottom: Gap.sm,
              child: _AttributionBadge(),
            ),
            if (segments.length > 1)
              Positioned(
                right: Gap.sm,
                top: Gap.sm,
                child: _GapBadge(count: segments.length - 1),
              ),
          ],
        ),
      ),
    );
  }

  /// OpenStreetMap's standard raster tiles.
  ///
  /// No account, no API key, no token. In exchange OSM's tile usage policy
  /// asks for two things:
  ///
  /// * **An identifying User-Agent.** [userAgentPackageName] is what
  ///   flutter_map puts in the header, so it must be this app's real package
  ///   id — a generic or absent agent is what gets a client blocked.
  /// * **Visible attribution**, which [_AttributionBadge] provides.
  ///
  /// Tiles stop at zoom 19 because that is as far as the standard style is
  /// rendered; `maxNativeZoom` lets the camera go closer by upscaling the
  /// last real tile rather than requesting one that does not exist.
  static Widget _tileLayer() => TileLayer(
    urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
    userAgentPackageName: 'com.firad.jatra',
    maxNativeZoom: 19,
    // A failed tile leaves a hole the grid shows through, which is the
    // offline fallback. Retrying harder would only queue requests that
    // cannot succeed.
    errorImage: null,
  );

  /// The "you are here" dot, with a halo showing how sure the GPS is.
  ///
  /// The halo is the reported accuracy drawn to scale in metres, so a poor fix
  /// looks poor instead of pretending to a precision it does not have. Below
  /// about 10 m it is smaller than the dot and effectively invisible, which is
  /// the right outcome for a good fix.
  List<Widget> _myLocationLayers(GeoPoint me, JatraColors c, L l) {
    final at = LatLng(me.lat, me.lng);
    final accuracy = me.accuracy;

    return [
      if (accuracy != null && accuracy > 0)
        CircleLayer(
          circles: [
            CircleMarker(
              point: at,
              radius: accuracy,
              useRadiusInMeter: true,
              color: c.signal.withValues(alpha: 0.12),
              borderColor: c.signal.withValues(alpha: 0.35),
              borderStrokeWidth: 1,
            ),
          ],
        ),
      MarkerLayer(
        markers: [
          Marker(
            point: at,
            width: 22,
            height: 22,
            child: Semantics(
              label: l.mapYourLocation,
              child: Container(
                decoration: BoxDecoration(
                  color: c.signal,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 3),
                ),
              ),
            ),
          ),
        ],
      ),
    ];
  }

  Marker _endpoint(LatLng at, Color colour, String label) => Marker(
    point: at,
    width: 16,
    height: 16,
    child: Semantics(
      label: label,
      child: Container(
        decoration: BoxDecoration(
          color: colour,
          shape: BoxShape.circle,
          // A 2px surface ring keeps the marker readable where the path
          // passes behind it.
          border: Border.all(color: Colors.white, width: 2),
        ),
      ),
    ),
  );

  /// Splits the path at `isGapStart` markers, then simplifies each piece to
  /// a shared render budget.
  static List<List<LatLng>> _segments(List<RidePointRow> points) {
    final raw = <List<RidePointRow>>[];
    var current = <RidePointRow>[];

    for (final p in points) {
      if (p.isGapStart && current.isNotEmpty) {
        raw.add(current);
        current = <RidePointRow>[];
      }
      current.add(p);
    }
    if (current.isNotEmpty) raw.add(current);

    // The budget is shared across segments, so a ride chopped into twenty
    // pieces does not render twenty times the points.
    final budget = (2000 / raw.length).floor().clamp(50, 2000);

    return [
      for (final segment in raw)
        if (segment.length >= 2)
          [
            for (final p in simplifyToBudget([
              for (final row in segment)
                GeoPoint(
                  lat: row.lat,
                  lng: row.lng,
                  timestampMs: row.timestampMs,
                ),
            ], targetPoints: budget))
              LatLng(p.lat, p.lng),
          ],
    ].where((s) => s.length >= 2).toList();
  }
}

/// A faint reference grid behind the path, so an empty background still
/// reads as a map rather than as a rendering failure.
class _GridPainter extends CustomPainter {
  const _GridPainter(this.colour);

  final Color colour;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = colour.withValues(alpha: 0.4)
      ..strokeWidth = 1;

    const spacing = 40.0;
    for (var x = 0.0; x < size.width; x += spacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (var y = 0.0; y < size.height; y += spacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(_GridPainter oldDelegate) => oldDelegate.colour != colour;
}

/// Rough scale for the visible extent. Without tiles there is no other cue
/// for how big the path is.
class _ScaleBar extends StatelessWidget {
  const _ScaleBar({required this.bounds, required this.fmt});

  final ({double minLat, double maxLat, double minLng, double maxLng}) bounds;
  final Fmt fmt;

  @override
  Widget build(BuildContext context) {
    final c = context.jatra;

    final widthM = haversineMetres(
      bounds.minLat,
      bounds.minLng,
      bounds.minLat,
      bounds.maxLng,
    );

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: Gap.sm, vertical: 2),
      decoration: BoxDecoration(
        color: c.background.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(Radii.chip),
      ),
      child: Text(
        L
            .of(context)
            .mapScaleAcross(
              fmt.distancePrecise(widthM.round()),
              fmt.distanceLabel.toLowerCase(),
            ),
        style: AppText.unit.copyWith(color: c.textMuted),
      ),
    );
  }
}

/// OpenStreetMap attribution.
///
/// Not optional and not decorative: OSM's tile usage policy requires visible
/// credit wherever its tiles are shown. Kept to the same pill treatment as
/// the scale bar so it reads as chrome rather than as content.
class _AttributionBadge extends StatelessWidget {
  const _AttributionBadge();

  @override
  Widget build(BuildContext context) {
    final c = context.jatra;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: Gap.sm, vertical: 2),
      decoration: BoxDecoration(
        color: c.background.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(Radii.chip),
      ),
      child: Text(
        '© OpenStreetMap',
        style: AppText.unit.copyWith(color: c.textMuted),
      ),
    );
  }
}

/// Says plainly that the path has holes in it, rather than letting the user
/// wonder why the line jumps.
class _GapBadge extends StatelessWidget {
  const _GapBadge({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    final c = context.jatra;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: Gap.sm, vertical: 2),
      decoration: BoxDecoration(
        color: c.background.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(Radii.chip),
        border: Border.all(color: c.dueSoon, width: Dimens.border),
      ),
      child: Text(
        L.of(context).mapGapCount(count),
        style: AppText.unit.copyWith(color: c.dueSoon),
      ),
    );
  }
}
