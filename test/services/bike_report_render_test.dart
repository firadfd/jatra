// The report's pages have nowhere to scroll, so an overflow is printed. This
// lays them out with the real fonts, in both languages, at awkward lengths.
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:jatra/core/calc/bike_report.dart';
import 'package:jatra/core/utils/formatters.dart';
import 'package:jatra/data/db/database.dart';
import 'package:jatra/l10n/app_localizations.dart';
import 'package:jatra/services/report/bike_report_pages.dart';
import 'package:jatra/services/report/pdf_writer.dart';

Future<void> _loadFont(String family, List<String> files) async {
  final loader = FontLoader(family);
  for (final file in files) {
    final bytes = File('assets/fonts/$file').readAsBytesSync();
    loader.addFont(Future.value(ByteData.sublistView(bytes)));
  }
  await loader.load();
}

BikeReport _report(int services) {
  final bike = VehicleRow(
    id: 1,
    createdAt: 0,
    updatedAt: 0,
    name: 'A very long bike name that goes on for a while and then some more',
    make: 'Bajaj',
    model: 'Pulsar 150',
    year: 2021,
    registrationNo: 'ঢাকা মেট্রো ল ১২-৩৪৫৬',
    fuelType: FuelType.petrol,
    initialOdometerM: 12000000,
    distanceUnit: DistanceUnit.km,
    volumeUnit: VolumeUnit.l,
    currency: 'BDT',
    isDefault: true,
    colorTag: 0,
    isArchived: false,
  );

  return BikeReport.build(
    vehicle: bike,
    fuel: const [],
    expenses: const [],
    services: [
      for (var i = 0; i < services; i++)
        ServiceLogRow(
          id: i,
          createdAt: 0,
          updatedAt: 0,
          vehicleId: 1,
          name: 'ইঞ্জিন অয়েল ও ফিল্টার পরিবর্তন এবং আরও অনেক লম্বা কাজের নাম',
          dateMs: DateTime(2024, 1 + i).millisecondsSinceEpoch,
          odometerM: i == 3 ? 100000 : 12000000 + i * 900000,
          partsCostMinor: 999999999,
          laborCostMinor: 0,
          totalCostMinor: 999999999,
          workshop: 'মিরপুর মোটরস অ্যান্ড সার্ভিস সেন্টার লিমিটেড',
          partBrand: 'Motul 7100 4T Synthetic',
        ),
    ],
  );
}

void main() {
  setUpAll(() async {
    await initializeDateFormatting();
    await _loadFont('Inter', ['Inter-Regular.ttf', 'Inter-SemiBold.ttf']);
    await _loadFont('HindSiliguri', [
      'HindSiliguri-Regular.ttf',
      'HindSiliguri-SemiBold.ttf',
    ]);
  });

  for (final code in ['en', 'bn']) {
    for (final services in [0, 7, 90]) {
      testWidgets('$code, $services services: pages lay out cleanly', (
        tester,
      ) async {
        tester.view.physicalSize = BikeReportLayout.pageSize;
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.reset);

        final pages = BikeReportLayout(
          report: _report(services),
          l: lookupL(Locale(code)),
          fmt: Fmt(locale: code),
          generatedMs: DateTime(2026, 11, 8).millisecondsSinceEpoch,
        ).pages();

        expect(pages, isNotEmpty);
        for (final page in pages) {
          await tester.pumpWidget(
            Directionality(textDirection: TextDirection.ltr, child: page),
          );
          expect(tester.takeException(), isNull);
        }
      });
    }
  }

  test('a heading is not stranded at the foot of a page', () {
    final blocks = [
      const ReportBlock(90, SizedBox()),
      const ReportBlock(20, SizedBox(), keepWithNext: true),
      const ReportBlock(20, SizedBox()),
    ];

    final pages = BikeReportLayout.paginate(blocks, 100);

    expect(pages.map((p) => p.length), [1, 2]);
  });

  test('PDF structure: one page and valid cross-references', () {
    final rgba = Uint8List.fromList(List.filled(2 * 2 * 4, 255));
    final page = PdfPageImage.fromRgba((rgba: rgba, width: 2, height: 2));
    final bytes = PdfWriter.build([page, page]);
    final text = latin1.decode(bytes);

    expect(text, startsWith('%PDF-1.4'));
    expect(text, contains('/Count 2'));
    expect(text, endsWith('%%EOF\n'));

    final xrefAt = int.parse(
      RegExp(r'startxref\n(\d+)').firstMatch(text)!.group(1)!,
    );
    expect(text.substring(xrefAt), startsWith('xref'));

    final entries = RegExp(
      r'(\d{10}) 00000 n',
    ).allMatches(text.substring(xrefAt)).toList();
    for (var i = 0; i < entries.length; i++) {
      final offset = int.parse(entries[i].group(1)!);
      expect(text.substring(offset), startsWith('${i + 1} 0 obj'));
    }
  });
}
