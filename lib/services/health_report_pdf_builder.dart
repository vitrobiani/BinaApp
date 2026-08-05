import 'dart:ui' show Offset, Rect;

import 'package:flutter/foundation.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';

import 'health_report_service.dart';

/// Renders a [HealthReportPayload] as a Bina Health Report PDF.
///
/// Layout — cover page (title, member, AI overview) then one section per
/// session (header, analysis, 2-column image grid). Long text auto-paginates
/// via [PdfTextElement]. A persistent footer with page-x-of-y is applied via
/// [PdfDocument.template].
///
/// **Every build spins up a fresh instance.** Syncfusion binds internal
/// state (font resource dictionaries, cross-reference entries) to the first
/// [PdfDocument] a [PdfFont]/[PdfBrush] is drawn into — reusing those
/// objects across documents produces a null-check crash at save time on the
/// second export. Keeping them as instance fields makes the "one set per
/// document" invariant load-bearing and obvious.
class HealthReportPdfBuilder {
  HealthReportPdfBuilder._();

  // ── Page geometry (A4 defaults from syncfusion, points). Pure constants,
  //    safe to share across builds. ──
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

  /// Public entry point — build a PDF from [payload] and return its bytes.
  static Future<Uint8List> build(HealthReportPayload payload) {
    return HealthReportPdfBuilder._()._run(payload);
  }

  // ── Per-build state. Initialised in [_run] before any draw call. ──
  late final PdfFont _fontTitle;
  late final PdfFont _fontH1;
  late final PdfFont _fontH2;
  late final PdfFont _fontBody;
  late final PdfFont _fontMuted;
  late final PdfFont _fontSmall;

  late final PdfBrush _brushInk;
  late final PdfBrush _brushMuted;
  late final PdfBrush _brushAccent;

  Future<Uint8List> _run(HealthReportPayload payload) async {
    _initStyles();

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

  void _initStyles() {
    _fontTitle = PdfStandardFont(PdfFontFamily.helvetica, 24,
        style: PdfFontStyle.bold);
    _fontH1 = PdfStandardFont(PdfFontFamily.helvetica, 18,
        style: PdfFontStyle.bold);
    _fontH2 = PdfStandardFont(PdfFontFamily.helvetica, 14,
        style: PdfFontStyle.bold);
    _fontBody = PdfStandardFont(PdfFontFamily.helvetica, 11);
    _fontMuted = PdfStandardFont(PdfFontFamily.helvetica, 10);
    _fontSmall = PdfStandardFont(PdfFontFamily.helvetica, 8);

    _brushInk = PdfSolidBrush(PdfColor(30, 30, 30));
    _brushMuted = PdfSolidBrush(PdfColor(120, 120, 120));
    _brushAccent = PdfSolidBrush(PdfColor(20, 90, 160));
  }

  // ═══════════════════════════════════════════════════════════════
  // COVER
  // ═══════════════════════════════════════════════════════════════

  void _drawCover(_Cursor c, HealthReportPayload p) {
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

  void _drawSession(
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

    // Prepare bitmaps once, up-front. Any image that syncfusion can't parse
    // (unexpected format, truncated blob from an unfinished write) is dropped
    // here with a debug log — one bad capture doesn't kill the whole report.
    final cells = <_PreparedCell>[];
    for (final img in s.images) {
      final cell = _prepareCell(img);
      if (cell != null) cells.add(cell);
    }
    if (cells.isEmpty) return;

    _drawText(c, 'Captures', _fontH2, _brushInk);
    c.y += 6;
    _drawImageGrid(doc, c, cells);
  }

  void _drawImageGrid(
    PdfDocument doc,
    _Cursor c,
    List<_PreparedCell> cells,
  ) {
    for (var i = 0; i < cells.length; i += 2) {
      final left = cells[i];
      final right = i + 1 < cells.length ? cells[i + 1] : null;

      final rowHeight = right == null
          ? left.cellHeight
          : (left.cellHeight > right.cellHeight
              ? left.cellHeight
              : right.cellHeight);

      if (c.y + rowHeight > _contentBottom) {
        c.page = _newPage(doc);
        c.y = _marginTop;
      }

      final rowTop = c.y;
      _drawPreparedCell(c.page, left, _marginX, rowTop);
      if (right != null) {
        _drawPreparedCell(
            c.page, right, _marginX + _imgCellWidth + _imgColumnGap, rowTop);
      }
      c.y = rowTop + rowHeight + _imgRowGap;
    }
  }

  /// Build a [PdfBitmap] once and precompute its scaled draw height + total
  /// cell height. Returns null when the image bytes can't be decoded — the
  /// caller skips this cell so the export still succeeds.
  _PreparedCell? _prepareCell(ImageSlice img) {
    try {
      final bitmap = PdfBitmap(img.bytes);
      final w = bitmap.width.toDouble();
      final h = bitmap.height.toDouble();
      if (w <= 0 || h <= 0) {
        debugPrint(
            '[HealthReport] skipping image with zero dimensions (${img.bytes.length} bytes)');
        return null;
      }
      final drawHeight = _fitHeight(w, h);
      var cellHeight = drawHeight + 4 + _fontSmall.height;
      if (img.detectedClasses.isNotEmpty) {
        cellHeight += 2 + _fontSmall.height;
      }
      return _PreparedCell(
        bitmap: bitmap,
        drawHeight: drawHeight,
        cellHeight: cellHeight,
        capturedAt: img.capturedAt,
        estimatedRegion: img.estimatedRegion,
        detectedClasses: img.detectedClasses,
      );
    } catch (e) {
      debugPrint(
          '[HealthReport] failed to decode image (${img.bytes.length} bytes): $e');
      return null;
    }
  }

  static double _fitHeight(double srcW, double srcH) {
    final scale = _imgCellWidth / srcW;
    final scaledH = srcH * scale;
    return scaledH > _imgMaxHeight ? _imgMaxHeight : scaledH;
  }

  void _drawPreparedCell(
    PdfPage page,
    _PreparedCell cell,
    double x,
    double y,
  ) {
    page.graphics.drawImage(
      cell.bitmap,
      Rect.fromLTWH(x, y, _imgCellWidth, cell.drawHeight),
    );

    final captionY = y + cell.drawHeight + 4;
    final region = cell.estimatedRegion?.isNotEmpty == true
        ? cell.estimatedRegion!
        : '—';
    final caption = '$region · ${_formatTime(cell.capturedAt)}';
    page.graphics.drawString(
      _sanitize(caption),
      _fontSmall,
      brush: _brushMuted,
      bounds: Rect.fromLTWH(x, captionY, _imgCellWidth, _fontSmall.height),
    );

    if (cell.detectedClasses.isNotEmpty) {
      final classY = captionY + _fontSmall.height + 2;
      page.graphics.drawString(
        _sanitize(cell.detectedClasses.join(', ')),
        _fontSmall,
        brush: _brushAccent,
        bounds: Rect.fromLTWH(x, classY, _imgCellWidth, _fontSmall.height),
      );
    }
  }

  /// Test-only alias for [_sanitize] — lets unit tests pin the character
  /// mapping table (em-dash → `-`, ellipsis → `...`, Cyrillic `О` → `?`,
  /// etc.) without going through a full PDF round-trip.
  @visibleForTesting
  static String sanitizeForTesting(String s) => _sanitize(s);

  /// Replace characters that [PdfStandardFont] (Windows-1252) can't render
  /// with `?`. Preserves ASCII, Latin-1 supplement (accented Latin, middle
  /// dot, em/en dashes via Windows-1252 mapping), tabs, and newlines. Any
  /// stray Cyrillic/Hebrew/CJK/etc from Gemma output or session notes gets
  /// downgraded to `?` — the alternative is the whole export crashing.
  static String _sanitize(String s) {
    final buf = StringBuffer();
    for (final code in s.runes) {
      if (code == 0x09 || code == 0x0A || code == 0x0D) {
        buf.writeCharCode(code);
        continue;
      }
      // Windows-1252 undefined slots.
      const undefined = {0x81, 0x8D, 0x8F, 0x90, 0x9D};
      if (code >= 0x20 && code <= 0xFF && !undefined.contains(code)) {
        buf.writeCharCode(code);
        continue;
      }
      // Common typographic characters that live above Latin-1 but map to
      // Windows-1252 — collapse to ASCII equivalents so we don't lose them.
      switch (code) {
        case 0x2013: // en dash
        case 0x2014: // em dash
          buf.write('-');
          break;
        case 0x2018: // left single quote
        case 0x2019: // right single quote / apostrophe
          buf.write("'");
          break;
        case 0x201C: // left double quote
        case 0x201D: // right double quote
          buf.write('"');
          break;
        case 0x2026: // ellipsis
          buf.write('...');
          break;
        default:
          buf.write('?');
      }
    }
    return buf.toString();
  }

  // ═══════════════════════════════════════════════════════════════
  // FLOW HELPERS
  // ═══════════════════════════════════════════════════════════════

  _Cursor _startNewPage(PdfDocument doc) => _Cursor(_newPage(doc));

  PdfPage _newPage(PdfDocument doc) {
    final page = doc.pages.add();
    return page;
  }

  /// One-line text at the current cursor. Advances `y` by the font height.
  void _drawText(_Cursor c, String text, PdfFont font, PdfBrush brush) {
    c.page.graphics.drawString(
      _sanitize(text),
      font,
      brush: brush,
      bounds: Rect.fromLTWH(_marginX, c.y, _contentWidth, font.height + 2),
    );
    c.y += font.height + 2;
  }

  /// Multi-line body text that auto-paginates. Updates cursor to the final
  /// line's bottom on the last page it landed on.
  void _drawParagraph(
    _Cursor c,
    String text,
    PdfFont font,
    PdfBrush brush,
  ) {
    final element = PdfTextElement(
      text: _sanitize(text),
      font: font,
      brush: brush,
    );
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

  void _drawDivider(_Cursor c) {
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
  void _installFooter(PdfDocument doc) {
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
}

/// Mutable pointer into the growing document — which page we're on and how
/// far down it we've drawn. Passed by reference so helpers can advance both.
class _Cursor {
  _Cursor(this.page) : y = HealthReportPdfBuilder._marginTop;
  PdfPage page;
  double y;
}

/// One image ready to draw: bitmap constructed exactly once, plus the
/// precomputed heights the grid layout needs before it decides row breaks.
class _PreparedCell {
  final PdfBitmap bitmap;
  final double drawHeight;
  final double cellHeight;
  final DateTime capturedAt;
  final String? estimatedRegion;
  final List<String> detectedClasses;

  const _PreparedCell({
    required this.bitmap,
    required this.drawHeight,
    required this.cellHeight,
    required this.capturedAt,
    required this.estimatedRegion,
    required this.detectedClasses,
  });
}
