import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/widgets.dart';

import '../../../app/theme/app_text.dart';
import '../../../core/utils/card_route.dart';
import '../../../services/district_map.dart';

const _amber = Color(0xFFFFB020);
const _ink = Color(0xFF0B0F17);
const _inkRaised = Color(0xFF1A2433);
const _white = Color(0xFFFFFFFF);
const _soft = Color(0xB3FFFFFF);

class RideCardStat {
  const RideCardStat({required this.label, required this.value, this.unit});

  final String label;
  final String value;
  final String? unit;
}

/// Everything printed on a card.
class RideCardContent {
  const RideCardContent({
    required this.from,
    required this.to,
    required this.date,
    required this.stats,
    required this.username,
    required this.bikeName,
    required this.route,
    required this.highlightedDistricts,
    this.photo,
  });

  final String from;
  final String to;
  final String date;
  final List<RideCardStat> stats;
  final String username;
  final String bikeName;
  final CardRoute route;

  /// Districts to tint on the map, by English name.
  final Set<String> highlightedDistricts;

  /// Decoded ahead of time: an off-screen render is a single frame, so
  /// anything still loading would come out blank.
  final ui.Image? photo;
}

/// The shareable card, 4:5, the shape Facebook shows largest in a feed.
///
/// A fixed logical size rendered at 2x gives 1080 × 1350. The preview scales
/// this same widget, so what the rider sees is what gets posted.
class RideCardFace extends StatelessWidget {
  const RideCardFace({
    super.key,
    required this.content,
    required this.districts,
  });

  static const size = Size(540, 675);
  static const pixelRatio = 2.0;

  final RideCardContent content;
  final DistrictMap districts;

  @override
  Widget build(BuildContext context) {
    final photo = content.photo;

    return SizedBox.fromSize(
      size: size,
      child: ClipRect(
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (photo != null)
              RawImage(image: photo, fit: BoxFit.cover)
            else
              DecoratedBox(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [_inkRaised, _ink],
                  ),
                ),
                child: CustomPaint(
                  painter: _MapPainter(
                    districts: districts,
                    route: content.route,
                    highlighted: content.highlightedDistricts,
                  ),
                ),
              ),
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: [0, 0.2, 0.48, 1],
                  colors: [
                    Color(0x99000000),
                    Color(0x00000000),
                    Color(0x00000000),
                    Color(0xF2000000),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _topRow(),
                  const Spacer(),
                  _journey(),
                  const SizedBox(height: 12),
                  Container(width: 56, height: 4, color: _amber),
                  const SizedBox(height: 18),
                  _stats(),
                  if (content.username.isNotEmpty ||
                      content.bikeName.isNotEmpty) ...[
                    const SizedBox(height: 18),
                    Container(height: 1, color: const Color(0x33FFFFFF)),
                    const SizedBox(height: 14),
                    _riderRow(),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _topRow() => Row(
    children: [
      Text(
        'JATRA',
        style: _text(
          24,
          _amber,
          family: AppFonts.display,
          weight: FontWeight.w700,
          spacing: 5,
        ),
      ),
      const Spacer(),
      Text(content.date, style: _text(16, _white)),
    ],
  );

  Widget _journey() {
    final places = [
      content.from,
      content.to,
    ].where((p) => p.isNotEmpty).map(_display).toList();
    if (places.isEmpty) return const SizedBox.shrink();

    final style = _text(
      64,
      _white,
      family: AppFonts.display,
      weight: FontWeight.w700,
    );

    return SizedBox(
      width: double.infinity,
      child: FittedBox(
        fit: BoxFit.scaleDown,
        alignment: Alignment.centerLeft,
        child: Text.rich(
          TextSpan(
            style: style,
            children: [
              TextSpan(text: places.first),
              if (places.length > 1) ...[
                // Set in the body face: the display face has no arrow glyph.
                TextSpan(text: '  →  ', style: _text(46, _amber)),
                TextSpan(text: places.last),
              ],
            ],
          ),
          maxLines: 1,
        ),
      ),
    );
  }

  /// Capitals suit the condensed face. Bangla has no case, so it is unmoved.
  static String _display(String place) => place.toUpperCase();

  Widget _stats() => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      for (final stat in content.stats)
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                // Fixed, because a taka sign falls back to a taller font and
                // would otherwise push its label out of line.
                height: 54,
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text.rich(
                    TextSpan(
                      text: stat.value,
                      style: _text(
                        42,
                        _white,
                        family: AppFonts.display,
                        weight: FontWeight.w600,
                      ),
                      children: [
                        if (stat.unit != null)
                          TextSpan(
                            text: ' ${stat.unit}',
                            style: _text(16, _soft),
                          ),
                      ],
                    ),
                    maxLines: 1,
                  ),
                ),
              ),
              Text(
                stat.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: _text(14, _soft),
              ),
            ],
          ),
        ),
    ],
  );

  Widget _riderRow() => Row(
    children: [
      Expanded(
        child: Text(
          content.username,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: _text(20, _white, weight: FontWeight.w600),
        ),
      ),
      const SizedBox(width: 16),
      Expanded(
        child: Text(
          content.bikeName,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.right,
          style: _text(18, _amber, weight: FontWeight.w500),
        ),
      ),
    ],
  );

  static TextStyle _text(
    double size,
    Color color, {
    String family = AppFonts.body,
    FontWeight? weight,
    double? spacing,
  }) => TextStyle(
    fontFamily: family,
    fontFamilyFallback: AppFonts.fallback,
    fontSize: size,
    color: color,
    fontWeight: weight,
    letterSpacing: spacing,
    height: 1.2,
    decoration: TextDecoration.none,
  );
}

/// Districts and route on a plain equirectangular projection. Drawn without
/// tiles so a card needs no network.
class _MapPainter extends CustomPainter {
  const _MapPainter({
    required this.districts,
    required this.route,
    required this.highlighted,
  });

  final DistrictMap districts;
  final CardRoute route;
  final Set<String> highlighted;

  /// Keeps the very short rides from zooming in to street level.
  static const _minSpanDegrees = 0.3;

  /// Fractions of the height, leaving the text band at the bottom clear.
  static const _viewTop = 0.1;
  static const _viewBottom = 0.58;

  @override
  void paint(Canvas canvas, Size size) {
    final view = _viewport();
    if (view == null) return;

    final midLat = (view.south + view.north) / 2;
    final stretch = math.cos(midLat * math.pi / 180);
    final area = Rect.fromLTRB(
      24,
      size.height * _viewTop,
      size.width - 24,
      size.height * _viewBottom,
    );
    final scale = math.min(
      area.width / ((view.east - view.west) * stretch),
      area.height / (view.north - view.south),
    );
    final midLng = (view.east + view.west) / 2;

    Offset project(double lat, double lng) => Offset(
      area.center.dx + (lng - midLng) * stretch * scale,
      area.center.dy - (lat - midLat) * scale,
    );

    final land = Paint()..color = const Color(0xFF263345);
    final visited = Paint()..color = const Color(0x66FFB020);
    final border = Paint()
      ..color = const Color(0x33FFFFFF)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.7;

    for (final district in districts.districts) {
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
        ..drawPath(path, highlighted.contains(district.en) ? visited : land)
        ..drawPath(path, border);
    }

    if (route.isEmpty) return;

    final line = Path();
    for (final segment in route.segments) {
      for (var i = 0; i < segment.length; i++) {
        final point = project(segment[i].lat, segment[i].lng);
        i == 0
            ? line.moveTo(point.dx, point.dy)
            : line.lineTo(point.dx, point.dy);
      }
    }

    Paint stroke(Color color, double width) => Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = width
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    canvas
      ..drawPath(line, stroke(const Color(0x40FFB020), 12))
      ..drawPath(line, stroke(_amber, 3.5));

    final first = route.segments.first.first;
    final last = route.segments.last.last;
    for (final point in [first, last]) {
      final at = project(point.lat, point.lng);
      canvas
        ..drawCircle(at, 7, Paint()..color = _white)
        ..drawCircle(at, 4, Paint()..color = _amber);
    }
  }

  ({double west, double east, double south, double north})? _viewport() {
    final lats = <double>[];
    final lngs = <double>[];

    if (route.isEmpty) {
      for (final district in districts.districts) {
        for (final ring in district.rings) {
          for (var i = 0; i < ring.length; i += 2) {
            lngs.add(ring[i]);
            lats.add(ring[i + 1]);
          }
        }
      }
    } else {
      for (final segment in route.segments) {
        for (final point in segment) {
          lats.add(point.lat);
          lngs.add(point.lng);
        }
      }
    }
    if (lats.isEmpty) return null;

    final south = lats.reduce(math.min);
    final north = lats.reduce(math.max);
    final west = lngs.reduce(math.min);
    final east = lngs.reduce(math.max);

    final padding = route.isEmpty ? 1.0 : 1.3;
    final latSpan = math.max((north - south) * padding, _minSpanDegrees);
    final lngSpan = math.max((east - west) * padding, _minSpanDegrees);
    final midLat = (north + south) / 2;
    final midLng = (east + west) / 2;

    return (
      west: midLng - lngSpan / 2,
      east: midLng + lngSpan / 2,
      south: midLat - latSpan / 2,
      north: midLat + latSpan / 2,
    );
  }

  @override
  bool shouldRepaint(_MapPainter oldDelegate) =>
      oldDelegate.route != route ||
      oldDelegate.districts != districts ||
      oldDelegate.highlighted != highlighted;
}
