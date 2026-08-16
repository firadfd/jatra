import 'package:flutter_test/flutter_test.dart';
import 'package:jatra/services/export_service.dart';

/// The CSV writer is hand-rolled rather than pulled from a package, so its
/// escaping is worth pinning down. A station name with a comma in it is not
/// an exotic case — "Meghna Petrol Pump, Mirpur" is exactly what people type.
void main() {
  group('csvEscape', () {
    test('leaves ordinary values alone', () {
      expect(
        ExportService.csvEscape('Meghna Petrol Pump'),
        'Meghna Petrol Pump',
      );
      expect(ExportService.csvEscape('1250.75'), '1250.75');
      expect(ExportService.csvEscape(''), '');
    });

    test('quotes values containing a comma', () {
      expect(
        ExportService.csvEscape('Meghna Petrol Pump, Mirpur'),
        '"Meghna Petrol Pump, Mirpur"',
      );
    });

    test('doubles embedded quotes', () {
      expect(
        ExportService.csvEscape('He said "fill it up"'),
        '"He said ""fill it up"""',
      );
    });

    test('quotes values containing newlines', () {
      expect(
        ExportService.csvEscape('line one\nline two'),
        '"line one\nline two"',
      );
      expect(ExportService.csvEscape('carriage\rreturn'), '"carriage\rreturn"');
    });
  });

  group('csvTable', () {
    test('writes a header and one line per row', () {
      final csv = ExportService.csvTable(
        ['Date', 'Total'],
        [
          ['2026-08-04', '1250.75'],
          ['2026-08-11', '980.00'],
        ],
      );

      expect(csv.trim().split('\n'), [
        'Date,Total',
        '2026-08-04,1250.75',
        '2026-08-11,980.00',
      ]);
    });

    test('a field with a comma does not shift the column count', () {
      final csv = ExportService.csvTable(
        ['Station', 'Total'],
        [
          ['Padma, Mirpur', '980.00'],
        ],
      );
      expect(csv.trim().split('\n').last, '"Padma, Mirpur",980.00');
    });

    test('an empty table is still a valid file with its header', () {
      final csv = ExportService.csvTable(['Date', 'Total'], []);
      expect(csv.trim(), 'Date,Total');
    });
  });
}
