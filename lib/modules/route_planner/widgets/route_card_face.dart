import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/widgets.dart';

import '../../../core/calc/place_route.dart';
import '../../../l10n/app_localizations.dart';
import '../../../services/district_map.dart';

const _paper = Color(0xFFEEF3F7);
const _land = Color(0xFFC6D4E0);
const _ink = Color(0xFF17201D);
const _muted = Color(0xFF66727E);
const _greenDark = Color(0xFF127556);
const _green = Color(0xFF1A8E67);
const _pin = Color(0xFFE5383B);
const _amber = Color(0xFFFFB020);
const _white = Color(0xFFFFFFFF);

/// Set in Hind Siliguri throughout: it carries Latin and Bangla together.
TextStyle _style(double size, Color color, {FontWeight? weight}) => TextStyle(
  fontFamily: 'HindSiliguri',
  fontSize: size,
  color: color,
  fontWeight: weight,
  height: 1.2,
  decoration: TextDecoration.none,
);

/// `398` → `৩৯৮` on a Bangla card. The app otherwise keeps Latin digits for
/// instrument readings, but this is prose on a poster.
String localDigits(String text, String locale) {
  if (locale != 'bn') return text;
  return text.replaceAllMapped(
    RegExp('[0-9]'),
    (m) => String.fromCharCode(0x09E6 + int.parse(m[0]!)),
  );
}

class RouteCardContent {
  const RouteCardContent({
    required this.route,
    required this.distanceM,
    required this.isEstimate,
    required this.name,
    required this.locale,
    required this.distanceText,
    required this.distanceUnit,
    this.bike = '',
    this.photo,
  });

  final PlaceRoute? route;
  final int? distanceM;

  /// Shown with `≈`, so an estimate is not posted as a measurement.
  final bool isEstimate;
  final String name;
  final String locale;
  final String distanceText;
  final String distanceUnit;

  /// Empty ⇒ left off the card.
  final String bike;

  /// Decoded ahead of time: an off-screen render is a single frame.
  final ui.Image? photo;
}

/// The shareable route poster, 3:4 at 1200 × 1600.
class RouteCardFace extends StatelessWidget {
  const RouteCardFace({
    super.key,
    required this.districts,
    required this.content,
    required this.l,
    this.onMapTap,
  });

  static const size = Size(600, 800);
  static const pixelRatio = 2.0;

  final DistrictMap districts;
  final RouteCardContent content;
  final L l;

  /// Makes the preview's map editable. The shared image leaves it null.
  final void Function(double lat, double lng)? onMapTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox.fromSize(
      size: size,
      child: ColoredBox(
        color: _paper,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(40, 36, 40, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _header(),
              Expanded(child: LayoutBuilder(builder: _map)),
              _distance(),
              const SizedBox(height: 12),
              _promo(),
              const SizedBox(height: 12),
              Container(height: 1, color: _land),
              const SizedBox(height: 10),
              _brand(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _map(BuildContext context, BoxConstraints constraints) {
    final area = constraints.biggest;
    final map = CustomPaint(
      size: area,
      painter: _RoutePainter(
        districts: districts,
        route: content.route,
        locale: content.locale,
      ),
    );
    final onTap = onMapTap;
    if (onTap == null || districts.isEmpty) return map;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapUp: (details) {
        final point = _Fit.of(
          districts,
          area,
          content.route,
        ).invert(details.localPosition);
        if (districts.locate(point.lat, point.lng) != null) {
          onTap(point.lat, point.lng);
        }
      },
      child: map,
    );
  }

  Widget _header() {
    final stops = content.route?.waypoints;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _rider(),
        const SizedBox(height: 4),
        SizedBox(
          width: double.infinity,
          child: FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text.rich(
              TextSpan(
                style: _style(42, _ink, weight: FontWeight.w600),
                children: stops == null
                    ? [TextSpan(text: l.routeCardChoose)]
                    : [
                        TextSpan(text: stops.first.nameIn(content.locale)),
                        if (stops.length > 1) ...[
                          // Inter, because Hind Siliguri has no arrow glyph.
                          const TextSpan(
                            text: '  →  ',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 34,
                              color: _pin,
                            ),
                          ),
                          TextSpan(text: stops.last.nameIn(content.locale)),
                        ],
                      ],
              ),
              maxLines: 1,
            ),
          ),
        ),
      ],
    );
  }

  /// Photo, name and bike. Falls back to a plain caption when none is set.
  Widget _rider() {
    final name = content.name;
    final bike = content.bike;
    final photo = content.photo;

    final Widget text;
    if (bike.isEmpty) {
      text = Text(
        name.isEmpty ? l.routeCardKicker : l.routeCardNamed(name),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: _style(15, _muted, weight: FontWeight.w500),
      );
    } else {
      text = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (name.isNotEmpty)
            Text(
              name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: _style(18, _ink, weight: FontWeight.w600),
            ),
          Text(
            l.routeCardRideWith(bike),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: _style(15, _greenDark, weight: FontWeight.w500),
          ),
        ],
      );
    }

    return Row(
      children: [
        if (photo != null) ...[
          Container(
            width: 58,
            height: 58,
            padding: const EdgeInsets.all(2.5),
            decoration: const BoxDecoration(
              color: _greenDark,
              shape: BoxShape.circle,
            ),
            child: ClipOval(
              child: RawImage(image: photo, fit: BoxFit.cover),
            ),
          ),
          const SizedBox(width: 12),
        ],
        Expanded(child: text),
      ],
    );
  }

  Widget _distance() {
    final route = content.route;
    final districtCount = route?.districts.length ?? 0;
    final hasDistance =
        content.distanceText.isNotEmpty && (content.distanceM ?? 0) > 0;

    final via = [
      if (districtCount > 2)
        l.routeCardVia(localDigits('$districtCount', content.locale)),
      if (route?.usesFerry ?? false) l.routeCardFerry,
    ].join(' · ');

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          flex: 3,
          child: hasDistance
              ? FittedBox(
                  // A typed distance can be any length.
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text.rich(
                    TextSpan(
                      text:
                          '${content.isEstimate ? '≈ ' : ''}'
                          '${localDigits(content.distanceText, content.locale)}',
                      style: _style(54, _greenDark, weight: FontWeight.w600),
                      children: [
                        TextSpan(
                          text: ' ${content.distanceUnit}',
                          style: _style(20, _muted, weight: FontWeight.w600),
                        ),
                      ],
                    ),
                    maxLines: 1,
                  ),
                )
              : const SizedBox.shrink(),
        ),
        if (via.isNotEmpty) ...[
          const SizedBox(width: 12),
          // Expanded, not Flexible: the text needs the full slot to sit right.
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Text(
                via,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.right,
                style: _style(15, _muted),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _promo() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(l.routeCardPrompt, style: _style(14, _greenDark)),
      Text(
        l.routeCardPromptStrong,
        style: _style(22, _greenDark, weight: FontWeight.w600),
      ),
    ],
  );

  Widget _brand() => Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Container(
        width: 26,
        height: 26,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: _amber,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text('J', style: _style(17, _ink, weight: FontWeight.w600)),
      ),
      const SizedBox(width: 8),
      Text('Jatra', style: _style(17, _ink, weight: FontWeight.w600)),
      Text('  ·  ${l.routeCardTagline}', style: _style(14, _muted)),
    ],
  );
}

/// Fits the map into a box, and maps a tap back to a position.
class _Fit {
  _Fit._(this._midLat, this._midLng, this._stretch, this._scale, this._centre);

  /// Below this span in degrees, the card zooms to the districts on the
  /// route: on the country map a trip within a district would be a dot.
  static const _zoomBelowDegrees = 1.6;

  factory _Fit.of(DistrictMap map, Size size, PlaceRoute? route) {
    final onRoute = {...?route?.districts};
    final focus = map.districts.where((d) => onRoute.contains(d.en)).toList();

    var bounds = _bounds(focus);
    final zoomed =
        focus.isNotEmpty &&
        bounds.east - bounds.west < _zoomBelowDegrees &&
        bounds.north - bounds.south < _zoomBelowDegrees;
    if (!zoomed) bounds = _bounds(map.districts);

    final (:west, :east, :south, :north) = bounds;
    final midLat = (south + north) / 2;
    final stretch = math.cos(midLat * math.pi / 180);
    // Room for the labels of places near the edge.
    final inset = zoomed ? 36.0 : 10.0;
    final scale = math.min(
      (size.width - inset * 2) / ((east - west) * stretch),
      (size.height - inset * 2) / (north - south),
    );
    return _Fit._(
      midLat,
      (east + west) / 2,
      stretch,
      scale,
      size.center(Offset.zero),
    );
  }

  static ({double west, double east, double south, double north}) _bounds(
    Iterable<District> districts,
  ) {
    var west = double.infinity, east = -double.infinity;
    var south = double.infinity, north = -double.infinity;
    for (final district in districts) {
      for (final ring in district.rings) {
        for (var i = 0; i < ring.length; i += 2) {
          west = math.min(west, ring[i]);
          east = math.max(east, ring[i]);
          south = math.min(south, ring[i + 1]);
          north = math.max(north, ring[i + 1]);
        }
      }
    }
    return (west: west, east: east, south: south, north: north);
  }

  final double _midLat;
  final double _midLng;
  final double _stretch;
  final double _scale;
  final Offset _centre;

  Offset project(double lat, double lng) => Offset(
    _centre.dx + (lng - _midLng) * _stretch * _scale,
    _centre.dy - (lat - _midLat) * _scale,
  );

  ({double lat, double lng}) invert(Offset point) => (
    lat: _midLat - (point.dy - _centre.dy) / _scale,
    lng: _midLng + (point.dx - _centre.dx) / (_stretch * _scale),
  );
}

class _RoutePainter extends CustomPainter {
  const _RoutePainter({
    required this.districts,
    required this.route,
    required this.locale,
  });

  final DistrictMap districts;
  final PlaceRoute? route;
  final String locale;

  @override
  void paint(Canvas canvas, Size size) {
    if (districts.isEmpty) return;

    // Zoomed in, neighbouring districts run past the edge of the map.
    canvas.clipRect(Offset.zero & size);
    final fit = _Fit.of(districts, size, route);
    Offset project(double lat, double lng) => fit.project(lat, lng);

    final onRoute = {...?route?.districts};

    final land = Paint()..color = _land;
    final highlighted = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [_greenDark, _green],
      ).createShader(Offset.zero & size);
    final border = Paint()
      ..color = _paper
      ..style = PaintingStyle.stroke
      ..strokeJoin = StrokeJoin.round
      ..strokeWidth = 1.6;

    // Route districts last, so their borders are not painted over.
    for (final district in [
      ...districts.districts.where((d) => !onRoute.contains(d.en)),
      ...districts.districts.where((d) => onRoute.contains(d.en)),
    ]) {
      final path = Path()..fillType = PathFillType.evenOdd;
      for (final ring in district.rings) {
        for (var i = 0; i < ring.length; i += 2) {
          final point = project(ring[i + 1], ring[i]);
          i == 0
              ? path.moveTo(point.dx, point.dy)
              : path.lineTo(point.dx, point.dy);
        }
        path.close();
      }
      canvas
        ..drawPath(path, onRoute.contains(district.en) ? highlighted : land)
        ..drawPath(path, border);
    }

    final current = route;
    if (current == null) return;

    final points = [for (final p in current.path) project(p.lat, p.lng)];

    if (points.length > 1) {
      final line = Path()..moveTo(points.first.dx, points.first.dy);
      for (final point in points.skip(1)) {
        line.lineTo(point.dx, point.dy);
      }
      Paint stroke(Color color, double width) => Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = width
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round;
      canvas
        ..drawPath(line, stroke(_white, 6))
        ..drawPath(line, stroke(_pin, 3));
    }

    // Only what the rider chose is named; the road passes many more.
    final stops = current.waypoints;
    for (var i = 0; i < stops.length; i++) {
      final isEnd = i == 0 || i == stops.length - 1;
      final radius = isEnd ? 6.0 : 4.0;
      final point = project(stops[i].lat, stops[i].lng);
      canvas
        ..drawCircle(point, radius + 1.5, Paint()..color = _white)
        ..drawCircle(point, radius, Paint()..color = _pin);
      _label(
        canvas,
        stops[i].nameIn(locale),
        point,
        isEnd ? 13.0 : 10.0,
        radius,
      );
    }
  }

  /// Ink with a white halo, so a name reads over green and cream alike.
  void _label(
    Canvas canvas,
    String text,
    Offset pin,
    double fontSize,
    double radius,
  ) {
    TextPainter layout(TextStyle style) => TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: TextDirection.ltr,
    )..layout();

    final base = TextStyle(
      fontFamily: 'HindSiliguri',
      fontSize: fontSize,
      fontWeight: FontWeight.w600,
      height: 1.1,
    );
    final halo = layout(
      base.copyWith(
        foreground: Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = fontSize / 3.5
          ..strokeJoin = StrokeJoin.round
          ..color = _white,
      ),
    );
    final ink = layout(base.copyWith(color: _ink));

    final at = pin - Offset(ink.width / 2, ink.height + radius + 2);
    halo.paint(canvas, at);
    ink.paint(canvas, at);
    halo.dispose();
    ink.dispose();
  }

  @override
  bool shouldRepaint(_RoutePainter oldDelegate) =>
      oldDelegate.route != route ||
      oldDelegate.districts != districts ||
      oldDelegate.locale != locale;
}
