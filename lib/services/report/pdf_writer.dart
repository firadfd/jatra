import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

/// One page's image, already deflated.
class PdfPageImage {
  const PdfPageImage({
    required this.width,
    required this.height,
    required this.deflatedRgb,
  });

  final int width;
  final int height;
  final Uint8List deflatedRgb;

  /// Drops alpha and compresses. Page images are opaque. Top-level friendly,
  /// so it can run on a background isolate.
  static PdfPageImage fromRgba(
    ({Uint8List rgba, int width, int height}) source,
  ) {
    final rgba = source.rgba;
    final rgb = Uint8List(source.width * source.height * 3);
    for (var from = 0, to = 0; to < rgb.length; from += 4, to += 3) {
      rgb[to] = rgba[from];
      rgb[to + 1] = rgba[from + 1];
      rgb[to + 2] = rgba[from + 2];
    }
    return PdfPageImage(
      width: source.width,
      height: source.height,
      deflatedRgb: Uint8List.fromList(zlib.encode(rgb)),
    );
  }
}

/// Writes a PDF whose pages are full-bleed images.
///
/// Images rather than PDF text because PDF has no text shaping of its own: a
/// writer has to order Bangla conjuncts and vowel signs itself, and Dart's PDF
/// libraries do not, so workshop names come out garbled. Flutter already
/// shapes them correctly, so pages are drawn by Flutter. The cost is text
/// that cannot be selected.
///
/// The format needed for this is small enough not to justify a dependency.
abstract final class PdfWriter {
  static const a4WidthPt = 595.28;
  static const a4HeightPt = 841.89;

  static Uint8List build(List<PdfPageImage> pages) {
    final out = BytesBuilder(copy: false);
    final offsets = <int>[];

    void text(String s) => out.add(latin1.encode(s));

    void object(String body, [Uint8List? stream]) {
      offsets.add(out.length);
      text('${offsets.length} 0 obj\n$body\n');
      if (stream != null) {
        text('stream\n');
        out.add(stream);
        text('\nendstream\n');
      }
      text('endobj\n');
    }

    // Objects 1 and 2, then three per page: page, content, image.
    int pageObject(int index) => 3 + index * 3;

    text('%PDF-1.4\n');
    object('<< /Type /Catalog /Pages 2 0 R >>');
    final kids = [
      for (var i = 0; i < pages.length; i++) '${pageObject(i)} 0 R',
    ].join(' ');
    object('<< /Type /Pages /Kids [$kids] /Count ${pages.length} >>');

    for (var i = 0; i < pages.length; i++) {
      final page = pages[i];
      final number = pageObject(i);
      object(
        '<< /Type /Page /Parent 2 0 R '
        '/MediaBox [0 0 $a4WidthPt $a4HeightPt] '
        '/Contents ${number + 1} 0 R '
        '/Resources << /XObject << /Im0 ${number + 2} 0 R >> >> >>',
      );

      final content = latin1.encode(
        'q $a4WidthPt 0 0 $a4HeightPt 0 0 cm /Im0 Do Q',
      );
      object('<< /Length ${content.length} >>', content);

      object(
        '<< /Type /XObject /Subtype /Image '
        '/Width ${page.width} /Height ${page.height} '
        '/ColorSpace /DeviceRGB /BitsPerComponent 8 '
        '/Filter /FlateDecode /Length ${page.deflatedRgb.length} >>',
        page.deflatedRgb,
      );
    }

    final xrefAt = out.length;
    final count = offsets.length + 1;
    text('xref\n0 $count\n0000000000 65535 f \n');
    for (final offset in offsets) {
      text('${offset.toString().padLeft(10, '0')} 00000 n \n');
    }
    text(
      'trailer\n<< /Size $count /Root 1 0 R >>\nstartxref\n$xrefAt\n%%EOF\n',
    );

    return out.takeBytes();
  }
}
