import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:get/get.dart' hide Value;
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';

import '../../core/calc/bike_report.dart';
import '../../core/utils/clock.dart';
import '../../core/utils/formatters.dart';
import '../../data/db/database.dart';
import '../../data/repositories/expense_repo.dart';
import '../../data/repositories/fuel_repo.dart';
import '../../data/repositories/service_repo.dart';
import '../../l10n/app_localizations.dart';
import '../home_widget/offscreen_renderer.dart';
import '../settings_service.dart';
import 'bike_report_pages.dart';
import 'pdf_writer.dart';

/// Builds the PDF a seller hands to a buyer.
///
/// Prints the log and nothing private beyond it: no purchase price, free-text
/// notes or ride routes.
class BikeReportService extends GetxService {
  BikeReportService(this._fuel, this._service, this._expenses, this._settings);

  /// 2.5 device pixels per point is about 180 dpi: sharp in print while
  /// keeping pages to roughly a hundred kilobytes.
  static const _pixelRatio = 2.5;

  final FuelRepo _fuel;
  final ServiceRepo _service;
  final ExpenseRepo _expenses;
  final SettingsService _settings;

  Future<File> build(VehicleRow vehicle) async {
    final report = BikeReport.build(
      vehicle: vehicle,
      fuel: await _fuel.getForVehicle(vehicle.id),
      services: await _service.getLogs(vehicle.id),
      expenses: await _expenses.getForVehicle(vehicle.id),
    );

    final locale = _settings.localeCode.value;
    final layout = BikeReportLayout(
      report: report,
      l: lookupL(_settings.locale),
      fmt: Fmt(
        distanceUnit: vehicle.distanceUnit,
        volumeUnit: vehicle.volumeUnit,
        currency: vehicle.currency,
        locale: locale,
      ),
      generatedMs: Clock.nowMs,
    );

    final images = <PdfPageImage>[];
    for (final page in layout.pages()) {
      final png = await OffscreenRenderer.toPng(
        child: page,
        size: BikeReportLayout.pageSize,
        pixelRatio: _pixelRatio,
      );
      if (png == null) {
        throw StateError('The report could not be drawn on this device.');
      }
      images.add(await compute(PdfPageImage.fromRgba, await _decode(png)));
    }

    final bytes = await compute(PdfWriter.build, images);
    final stamp = DateFormat('yyyy-MM-dd_HHmm').format(DateTime.now());
    final file = File(
      '${(await getTemporaryDirectory()).path}/jatra_bike_report_$stamp.pdf',
    );
    return file.writeAsBytes(bytes);
  }

  static Future<({Uint8List rgba, int width, int height})> _decode(
    Uint8List png,
  ) async {
    final codec = await ui.instantiateImageCodec(png);
    final frame = await codec.getNextFrame();
    final image = frame.image;
    try {
      final data = await image.toByteData(format: ui.ImageByteFormat.rawRgba);
      return (
        rgba: data!.buffer.asUint8List(),
        width: image.width,
        height: image.height,
      );
    } finally {
      image.dispose();
      codec.dispose();
    }
  }
}
