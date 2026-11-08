import 'package:flutter/widgets.dart';

import '../../app/theme/app_text.dart';
import '../../core/calc/bike_report.dart';
import '../../core/utils/formatters.dart';
import '../../core/utils/money.dart';
import '../../l10n/app_localizations.dart';

const _ink = Color(0xFF16181D);
const _muted = Color(0xFF5F6673);
const _rule = Color(0xFFD9DCE2);
const _tint = Color(0xFFF3F4F6);
const _warn = Color(0xFFB3261E);
const _paper = Color(0xFFFFFFFF);

TextStyle _style(double size, Color color, {FontWeight? weight}) => TextStyle(
  fontFamily: AppFonts.body,
  fontFamilyFallback: AppFonts.fallback,
  fontSize: size,
  color: color,
  fontWeight: weight,
  height: 1.25,
  decoration: TextDecoration.none,
);

/// Lays a [BikeReport] out onto A4 pages, in PDF points.
///
/// Every row has a fixed height and truncates rather than wraps, so
/// pagination is plain arithmetic and a page can never overflow.
class BikeReportLayout {
  BikeReportLayout({
    required this.report,
    required this.l,
    required this.fmt,
    required this.generatedMs,
  });

  static const pageSize = Size(595, 842);
  static const _margin = 36.0;
  static const _footer = 26.0;
  static const _rowHeight = 20.0;
  static const _bodyHeight = 842 - _margin * 2 - _footer;

  final BikeReport report;
  final L l;
  final Fmt fmt;
  final int generatedMs;

  List<Widget> pages() {
    final grouped = paginate(_blocks(), _bodyHeight);
    return [
      for (var i = 0; i < grouped.length; i++)
        ColoredBox(
          color: _paper,
          child: Padding(
            padding: const EdgeInsets.all(_margin),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ...grouped[i].map(
                  (b) => SizedBox(height: b.height, child: b.child),
                ),
                const Spacer(),
                _footerRow(i + 1, grouped.length),
              ],
            ),
          ),
        ),
    ];
  }

  /// Greedy fill. A block marked `keepWithNext` moves over with whatever
  /// follows it, so a heading is never stranded at the foot of a page.
  @visibleForTesting
  static List<List<ReportBlock>> paginate(
    List<ReportBlock> blocks,
    double pageHeight,
  ) {
    final pages = <List<ReportBlock>>[[]];
    var used = 0.0;

    for (var i = 0; i < blocks.length; i++) {
      var needed = blocks[i].height;
      for (var j = i; blocks[j].keepWithNext && j + 1 < blocks.length; j++) {
        needed += blocks[j + 1].height;
      }
      if (used + needed > pageHeight && pages.last.isNotEmpty) {
        pages.add([]);
        used = 0;
      }
      pages.last.add(blocks[i]);
      used += blocks[i].height;
    }
    return pages;
  }

  List<ReportBlock> _blocks() {
    final r = report;
    return [
      ReportBlock(58, _title()),
      ReportBlock(40, _disclaimer()),
      ReportBlock(116, _summary()),
      if (r.lowerReadingCount > 0) ReportBlock(26, _lowerReadingNotice()),

      ..._section(
        l.reportServiceHistory,
        [
          l.reportDate,
          l.reportOdometer,
          l.reportService,
          l.reportWorkshop,
          l.reportCost,
        ],
        const [78, 72, 0, 0, 78],
        [
          for (final s in r.services)
            [
              fmt.date(s.dateMs),
              _odo(s.odometerM),
              s.name,
              s.workshop ?? Fmt.dash,
              fmt.amount(Money(s.totalCostMinor)),
            ],
        ],
      ),
      ..._section(
        l.reportPartsReplaced,
        [
          l.reportDate,
          l.reportOdometer,
          l.reportPart,
          l.reportBrand,
          l.reportCost,
        ],
        const [78, 72, 0, 0, 78],
        [
          for (final s in r.parts)
            [
              fmt.date(s.dateMs),
              _odo(s.odometerM),
              s.name,
              s.partBrand ?? Fmt.dash,
              s.partsCostMinor > 0
                  ? fmt.amount(Money(s.partsCostMinor))
                  : Fmt.dash,
            ],
        ],
      ),
      ..._section(
        l.reportOdometerTimeline,
        [l.reportDate, l.reportOdometer, ''],
        const [78, 92, 0],
        [
          for (final o in r.odometer)
            [
              fmt.date(o.dateMs),
              _odo(o.odometerM),
              o.isLowerThanEarlier ? l.reportLowerReading : '',
            ],
        ],
      ),
    ];
  }

  String _odo(int metres) => '${fmt.distance(metres)} ${fmt.distanceLabel}';

  Widget _title() {
    final v = report.vehicle;
    final subtitle = [
      v.make,
      v.model,
      v.year?.toString(),
      v.registrationNo,
    ].whereType<String>().where((s) => s.trim().isNotEmpty).join(' · ');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l.reportTitle,
          style: _style(20, _ink, weight: FontWeight.w600),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        Text(
          subtitle.isEmpty ? v.name : '${v.name} · $subtitle',
          style: _style(11, _muted),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _disclaimer() => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: ColoredBox(
      color: _tint,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Align(
          alignment: Alignment.centerLeft,
          child: Text(
            l.reportDisclaimer,
            style: _style(9, _ink),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ),
    ),
  );

  Widget _summary() {
    final r = report;
    final since = r.firstRecordMs;
    Widget row(Widget a, Widget b) => Expanded(
      child: Row(
        children: [
          Expanded(child: a),
          const SizedBox(width: 16),
          Expanded(child: b),
        ],
      ),
    );

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        children: [
          row(
            _fact(l.reportLatestOdometer, _odo(r.latestOdometerM)),
            _fact(l.reportStartOdometer, _odo(r.vehicle.initialOdometerM)),
          ),
          row(
            _fact(
              l.reportRecordsSince,
              since == null ? Fmt.dash : fmt.date(since),
            ),
            _fact(l.reportTotalSpend, fmt.amount(r.total), strong: true),
          ),
          row(
            _fact(l.reportFuelSpend, fmt.amount(r.fuelTotal)),
            _fact(l.reportServiceSpend, fmt.amount(r.serviceTotal)),
          ),
          row(
            _fact(l.reportOtherSpend, fmt.amount(r.otherTotal)),
            _fact(l.reportGeneratedLabel, fmt.date(generatedMs)),
          ),
        ],
      ),
    );
  }

  Widget _fact(String label, String value, {bool strong = false}) => Row(
    children: [
      Expanded(
        child: Text(
          label,
          style: _style(9.5, _muted),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      const SizedBox(width: 6),
      Text(
        value,
        style: _style(10.5, _ink, weight: strong ? FontWeight.w600 : null),
        maxLines: 1,
      ),
    ],
  );

  Widget _lowerReadingNotice() => Text(
    l.reportLowerReadingCount(report.lowerReadingCount),
    style: _style(9.5, _warn),
    maxLines: 1,
    overflow: TextOverflow.ellipsis,
  );

  List<ReportBlock> _section(
    String title,
    List<String> headers,
    List<double> widths,
    List<List<String>> rows,
  ) {
    return [
      ReportBlock(
        34,
        Align(
          alignment: Alignment.bottomLeft,
          child: Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Text(
              title,
              style: _style(13, _ink, weight: FontWeight.w600),
            ),
          ),
        ),
        keepWithNext: true,
      ),
      if (rows.isEmpty)
        ReportBlock(
          _rowHeight,
          Text(l.reportNoRecords, style: _style(9.5, _muted)),
        )
      else ...[
        ReportBlock(
          _rowHeight,
          _row(headers, widths, _style(8.5, _muted, weight: FontWeight.w600)),
          keepWithNext: true,
        ),
        for (final row in rows)
          ReportBlock(_rowHeight, _row(row, widths, _rowStyle(row))),
      ],
    ];
  }

  TextStyle _rowStyle(List<String> row) =>
      row.last == l.reportLowerReading ? _style(9.5, _warn) : _style(9.5, _ink);

  /// A width of 0 shares whatever is left.
  Widget _row(List<String> cells, List<double> widths, TextStyle style) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: _rule, width: 0.5)),
      ),
      child: Row(
        children: [
          for (var i = 0; i < cells.length; i++)
            if (widths[i] > 0)
              SizedBox(width: widths[i], child: _cell(cells[i], style))
            else
              Expanded(child: _cell(cells[i], style)),
        ],
      ),
    );
  }

  Widget _cell(String text, TextStyle style) => Padding(
    padding: const EdgeInsets.only(right: 6),
    child: Text(
      text,
      style: style,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    ),
  );

  Widget _footerRow(int page, int total) => SizedBox(
    height: _footer,
    child: Align(
      alignment: Alignment.bottomCenter,
      child: Text(l.reportPage(page, total), style: _style(8.5, _muted)),
    ),
  );
}

/// A fixed-height slice of a report page.
class ReportBlock {
  const ReportBlock(this.height, this.child, {this.keepWithNext = false});

  final double height;
  final Widget child;
  final bool keepWithNext;
}
