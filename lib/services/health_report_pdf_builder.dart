import 'dart:typed_data';
import 'dart:ui' show Offset, Rect;

import 'package:syncfusion_flutter_pdf/pdf.dart';

import 'health_report_service.dart';

/// Renders a [HealthReportPayload] as a Bina Health Report PDF.
///
/// Layout — cover page (title, member, AI overview) then one section per
/// session (header, analysis, 2-column image grid). Long text auto-paginates
/// via [PdfTextElement]. A persistent footer with page-x-of-y is applied via
/// [PdfDocument.template].
class HealthReportPdfBuilder {
  HealthReportPdfBuilder._();

  // ── Page geometry (A4 defaults from syncfusion, points). ──
  static const double _pageWidth = 595;
  static const double _pageHeight = 842;
  static const double _marginX = 40;
  static const double _marginTop = 40;
  static const double _marginBottom = 60; // room for the footer band
  static const double _contentWidth = _pageWidth - 2 * _marginX;
  static const double _contentBottom = _pageHeight - _marginBottom;

  // Image grid.
  static const double _imgColumnGap = 12;
  static const double _imgRowGap = 16;
  static const double _imgCellWidth =
      (_contentWidth - _imgColumnGap) / 2; // ~ 251.5 pt
  static const double _imgMaxHeight = 200;

  static Future<Uint8List> build(HealthReportPayload payload) async {
    final doc = PdfDocument();
    _installFooter(doc);

    var cursor = _Cursor(_newPage(doc));

    _drawCover(cursor, payload);

    for (var i = 0; i < payload.sessions.length; i++) {
      cursor = _startNewPage(doc); // one session per page — clean & predictable
      _drawSession(doc, cursor, payload.sessions[i], i + 1);
    }

    final bytes = await doc.save();
    doc.dispose();
    return Uint8List.fromList(bytes);
  }

  // ═══════════════════════════════════════════════════════════════
  // COVER
  // ═══════════════════════════════════════════════════════════════

  static void _drawCover(_Cursor c, HealthReportPayload p) {
    _drawText(c, 'Bina Health Report', _fontTitle, _brushInk);
    c.y += 6;
    _drawText(c, p.member.name.isEmpty ? 'Unnamed member' : p.member.name,
        _fontH1, _brushInk);
    c.y += 4;
    _drawText(
      c,
      'Generated ${_formatDate(p.generatedAt)} · ${p.sessions.length} '
      'session${p.sessions.length == 1 ? "" : "s"}',
      _fontMuted,
      _brushMuted,
    );

    c.y += 12;
    _drawDivider(c);
    c.y += 12;

    if (p.aiOverview.isNotEmpty) {
      _drawText(c, 'AI Overview', _fontH2, _brushInk);
      c.y += 4;
      _drawParagraph(c, p.aiOverview, _fontBody, _brushInk);
    } else {
      _drawText(c, 'No AI overview available.', _fontMuted, _brushMuted);
    }
  }

  // ═══════════════════════════════════════════════════════════════
  // SESSION SECTION
  // ═══════════════════════════════════════════════════════════════

  static void _drawSession(
    PdfDocument doc,
    _Cursor c,
    SessionSlice s,
    int index,
  ) {
    _drawText(c, 'Session $index — ${_formatDate(s.date)}', _fontH1, _brushInk);
    c.y += 2;

    final metaParts = <String>[];
    if (s.duration != null) metaParts.add('Duration ${_formatDuration(s.duration!)}');
    if (s.coveredRegions.isNotEmpty) {
      metaParts.add('Regions: ${s.coveredRegions.join(", ")}');
    } else {
      metaParts.add('Regions: —');
    }
    metaParts.add('Images: ${s.images.length}');
    _drawText(c, metaParts.join(' · '), _fontMuted, _brushMuted);
    c.y += 12;

    _drawText(c, 'Analysis', _fontH2, _brushInk);
    c.y += 4;
    if ((s.gemmaAnalysis ?? '').isEmpty) {
      _drawText(c, 'No analysis available.', _fontMuted, _brushMuted);
    } else {
      _drawParagraph(c, s.gemmaAnalysis!, _fontBody, _brushInk);
    }
    c.y += 12;

    if (s.images.isEmpty) return;
    _drawText(c, 'Captures', _fontH2, _brushInk);
    c.y += 6;
    _drawImageGrid(doc, c, s.images);
  }

  static void _drawImageGrid(
    PdfDocument doc,
    _Cursor c,
    List<ImageSlice> images,
  ) {
    for (var i = 0; i < images.length; i += 2) {
      final left = images[i];
      final right = i + 1 < images.length ? images[i + 1] : null;

      final leftHeight = _measureCell(left);
      final rightHeight = right == null ? 0.0 : _measureCell(right);
      final rowHeight = leftHeight > rightHeight ? leftHeight : rightHeight;

      if (c.y + rowHeight > _contentBottom) {
        c.page = _newPage(doc);
        c.y = _marginTop;
      }

      final rowTop = c.y;
      _drawImageCell(c.page, left, _marginX, rowTop);
      if (right != null) {
        _drawImageCell(
            c.page, right, _marginX + _imgCellWidth + _imgColumnGap, rowTop);
      }
      c.y = rowTop + rowHeight + _imgRowGap;
    }
  }

  /// Height of a single image cell — image (aspect-ratio-preserved, capped)
  /// plus caption + optional classes line.
  static double _measureCell(ImageSlice img) {
    final bitmap = PdfBitmap(img.bytes);
    final imgH = _fitHeight(bitmap.width.toDouble(), bitmap.height.toDouble());
    var h = imgH + 4 + _fontSmall.height; // image + gap + caption
    if (img.detectedClasses.isNotEmpty) h += 2 + _fontSmall.height;
    return h;
  }

  static double _fitHeight(double srcW, double srcH) {
    final scale = _imgCellWidth / srcW;
    final scaledH = srcH * scale;
    return scaledH > _imgMaxHeight ? _imgMaxHeight : scaledH;
  }

  static void _drawImageCell(PdfPage page, ImageSlice img, double x, double y) {
    final bitmap = PdfBitmap(img.bytes);
    final h = _fitHeight(bitmap.width.toDouble(), bitmap.height.toDouble());
    page.graphics.drawImage(bitmap, Rect.fromLTWH(x, y, _imgCellWidth, h));

    final captionY = y + h + 4;
    final region = img.estimatedRegion?.isNotEmpty == true
        ? img.estimatedRegion!
        : '—';
    final caption = '$region · ${_formatTime(img.capturedAt)}';
    page.graphics.drawString(
      caption,
      _fontSmall,
      brush: _brushMuted,
      bounds: Rect.fromLTWH(x, captionY, _imgCellWidth, _fontSmall.height),
    );

    if (img.detectedClasses.isNotEmpty) {
      final classY = captionY + _fontSmall.height + 2;
      page.graphics.drawString(
        img.detectedClasses.join(', '),
        _fontSmall,
        brush: _brushAccent,
        bounds: Rect.fromLTWH(x, classY, _imgCellWidth, _fontSmall.height),
      );
    }
  }

  // ═══════════════════════════════════════════════════════════════
  // FLOW HELPERS
  // ═══════════════════════════════════════════════════════════════

  static _Cursor _startNewPage(PdfDocument doc) => _Cursor(_newPage(doc));

  static PdfPage _newPage(PdfDocument doc) {
    final page = doc.pages.add();
    return page;
  }

  /// One-line text at the current cursor. Advances `y` by the font height.
  static void _drawText(_Cursor c, String text, PdfFont font, PdfBrush brush) {
    c.page.graphics.drawString(
      text,
      font,
      brush: brush,
      bounds: Rect.fromLTWH(_marginX, c.y, _contentWidth, font.height + 2),
    );
    c.y += font.height + 2;
  }

  /// Multi-line body text that auto-paginates. Updates cursor to the final
  /// line's bottom on the last page it landed on.
  static void _drawParagraph(
    _Cursor c,
    String text,
    PdfFont font,
    PdfBrush brush,
  ) {
    final element = PdfTextElement(text: text, font: font, brush: brush);
    final format = PdfLayoutFormat(
      layoutType: PdfLayoutType.paginate,
      paginateBounds: Rect.fromLTWH(
        _marginX,
        _marginTop,
        _contentWidth,
        _contentBottom - _marginTop,
      ),
    );
    final result = element.draw(
      page: c.page,
      bounds: Rect.fromLTWH(
        _marginX,
        c.y,
        _contentWidth,
        _contentBottom - c.y,
      ),
      format: format,
    );
    if (result != null) {
      c.page = result.page;
      c.y = result.bounds.bottom + 4;
    }
  }

  static void _drawDivider(_Cursor c) {
    c.page.graphics.drawLine(
      PdfPen(PdfColor(220, 220, 220)),
      Offset(_marginX, c.y),
      Offset(_marginX + _contentWidth, c.y),
    );
    c.y += 1;
  }

  /// Persistent page-number footer via document template — drawn on every
  /// page automatically. Uses [PdfPageNumberField] so we don't have to
  /// second-guess total-page counts.
  static void _installFooter(PdfDocument doc) {
    final footer = PdfPageTemplateElement(
      Rect.fromLTWH(_marginX, 0, _contentWidth, 30),
    );
    final compositeField = PdfCompositeField(
      font: _fontSmall,
      brush: _brushMuted,
      text: 'Bina Health Report · Page {0} of {1}',
      fields: <PdfAutomaticField>[
        PdfPageNumberField(font: _fontSmall, brush: _brushMuted),
        PdfPageCountField(font: _fontSmall, brush: _brushMuted),
      ],
    );
    compositeField.draw(footer.graphics, Offset(0, 10));
    doc.template.bottom = footer;
  }

  // ═══════════════════════════════════════════════════════════════
  // FORMATTING
  // ═══════════════════════════════════════════════════════════════

  static String _formatDate(DateTime d) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${d.day} ${months[d.month - 1]} ${d.year}';
  }

  static String _formatTime(DateTime d) =>
      '${d.hour.toString().padLeft(2, "0")}:'
      '${d.minute.toString().padLeft(2, "0")}';

  static String _formatDuration(Duration d) {
    final m = d.inMinutes;
    final s = d.inSeconds % 60;
    return m > 0
        ? '${m}m ${s.toString().padLeft(2, "0")}s'
        : '${s}s';
  }

  // ═══════════════════════════════════════════════════════════════
  // FONTS / BRUSHES (built once, reused for every draw call)
  // ═══════════════════════════════════════════════════════════════

  static final PdfFont _fontTitle = PdfStandardFont(
      PdfFontFamily.helvetica, 24,
      style: PdfFontStyle.bold);
  static final PdfFont _fontH1 = PdfStandardFont(
      PdfFontFamily.helvetica, 18,
      style: PdfFontStyle.bold);
  static final PdfFont _fontH2 = PdfStandardFont(
      PdfFontFamily.helvetica, 14,
      style: PdfFontStyle.bold);
  static final PdfFont _fontBody = PdfStandardFont(PdfFontFamily.helvetica, 11);
  static final PdfFont _fontMuted = PdfStandardFont(PdfFontFamily.helvetica, 10);
  static final PdfFont _fontSmall = PdfStandardFont(PdfFontFamily.helvetica, 8);

  static final PdfBrush _brushInk = PdfSolidBrush(PdfColor(30, 30, 30));
  static final PdfBrush _brushMuted = PdfSolidBrush(PdfColor(120, 120, 120));
  static final PdfBrush _brushAccent = PdfSolidBrush(PdfColor(20, 90, 160));
}

/// Mutable pointer into the growing document — which page we're on and how
/// far down it we've drawn. Passed by reference so helpers can advance both.
class _Cursor {
  _Cursor(this.page) : y = HealthReportPdfBuilder._marginTop;
  PdfPage page;
  double y;
}
