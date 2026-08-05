import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:printing/printing.dart';

import '/app_state.dart';
import '/backend/schema/structs/index.dart';
import '/backend/sqlite/sqlite_manager.dart';
import '/backend/supabase/database/database.dart';
import 'gemma_service.dart';
import 'health_report_pdf_builder.dart';
import 'member_document_service.dart';

/// Data assembled for a single Bina Health Report export.
///
/// Produced by [HealthReportService.buildPayload]; consumed by the PDF
/// builder (Step 2 of W2). Keeping the two concerns split means the same
/// payload can be re-used later for previews, sharing, etc. without
/// re-running the DB + Gemma work.
class HealthReportPayload {
  final FamilyMemberStruct member;
  final String aiOverview;
  final List<SessionSlice> sessions;
  final DateTime generatedAt;

  const HealthReportPayload({
    required this.member,
    required this.aiOverview,
    required this.sessions,
    required this.generatedAt,
  });
}

class SessionSlice {
  final String id;
  final DateTime date;
  final Duration? duration;
  final String? gemmaAnalysis;
  final List<String> coveredRegions;
  final List<ImageSlice> images;

  const SessionSlice({
    required this.id,
    required this.date,
    required this.duration,
    required this.gemmaAnalysis,
    required this.coveredRegions,
    required this.images,
  });
}

class ImageSlice {
  final Uint8List bytes;
  final DateTime capturedAt;
  final String? estimatedRegion;
  final List<String> detectedClasses;

  const ImageSlice({
    required this.bytes,
    required this.capturedAt,
    required this.estimatedRegion,
    required this.detectedClasses,
  });
}

class HealthReportService {
  HealthReportService._();

  static const int _sessionLimit = 5;

  /// Show the export dialog and drive it through generating → ready → share.
  /// Non-dismissible until either Close or the share sheet completes. Safe
  /// to call multiple times; each call opens its own dialog.
  static Future<void> exportAndShare(
    BuildContext context,
    FamilyMemberStruct member,
  ) async {
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => _ReportExportDialog(member: member),
    );
  }

  /// Query the last 5 sessions (newest first) for [member], collect their
  /// images, and ask Gemma for a short trend paragraph. Returns a fully
  /// hydrated payload; callers do no further DB work before rendering.
  static Future<HealthReportPayload> buildPayload({
    required FamilyMemberStruct member,
  }) async {
    final sessions = AppState().UserSession.isLocalSession
        ? await _loadLocalSessions(member.id)
        : await _loadCloudSessions(member.id);

    final aiOverview = await _generateAiOverview(member, sessions);

    return HealthReportPayload(
      member: member,
      aiOverview: aiOverview,
      sessions: sessions,
      generatedAt: DateTime.now(),
    );
  }

  static Future<List<SessionSlice>> _loadLocalSessions(String memberId) async {
    final rows = await SQLiteManager.instance.getRecentScanSessionsByMemberId(
      memberId: memberId,
      limit: _sessionLimit,
    );

    final out = <SessionSlice>[];
    for (final row in rows) {
      final imageRows = await SQLiteManager.instance
          .getScanImagesBySessionId(sessionId: row.id);

      final images = <ImageSlice>[];
      for (final img in imageRows) {
        final raw = img.diagnosedImage ?? img.image;
        if (raw == null || raw.isEmpty) continue;
        images.add(ImageSlice(
          bytes: raw is Uint8List ? raw : Uint8List.fromList(raw),
          capturedAt: img.capturedAt != null
              ? DateTime.fromMillisecondsSinceEpoch(img.capturedAt! * 1000)
              : DateTime.now(),
          estimatedRegion: img.estimatedRegion,
          detectedClasses: _parseDetections(img.rawResponse),
        ));
      }

      out.add(SessionSlice(
        id: row.id,
        date: row.sessionStart != null
            ? DateTime.fromMillisecondsSinceEpoch(row.sessionStart! * 1000)
            : DateTime.now(),
        duration: (row.sessionStart != null && row.sessionEnd != null)
            ? Duration(seconds: row.sessionEnd! - row.sessionStart!)
            : null,
        gemmaAnalysis: (row.notes ?? '').isEmpty ? null : row.notes,
        coveredRegions: _distinctRegions(images),
        images: images,
      ));
    }
    return out;
  }

  static Future<List<SessionSlice>> _loadCloudSessions(String memberId) async {
    final rows = await ScanSessionsTable().queryRows(
      queryFn: (q) => q
          .eq('family_member_id', memberId)
          .order('session_start', ascending: false)
          .limit(_sessionLimit),
    );

    final out = <SessionSlice>[];
    for (final row in rows) {
      final imageRows = await ScanImagesTable().queryRows(
        queryFn: (q) => q
            .eq('scan_session_id', row.id)
            .order('captured_at', ascending: true),
      );

      final images = <ImageSlice>[];
      for (final img in imageRows) {
        final raw = img.diagnosedImage ?? img.image;
        if (raw == null || raw.isEmpty) continue;
        images.add(ImageSlice(
          bytes: raw,
          capturedAt: img.capturedAt ?? DateTime.now(),
          estimatedRegion: img.estimatedRegion,
          detectedClasses: _parseDetections(img.rawResponse),
        ));
      }

      Duration? duration;
      if (row.sessionStart != null && row.sessionEnd != null) {
        duration = row.sessionEnd!.difference(row.sessionStart!);
      }

      out.add(SessionSlice(
        id: row.id,
        date: row.sessionStart ?? DateTime.now(),
        duration: duration,
        gemmaAnalysis: (row.notes ?? '').isEmpty ? null : row.notes,
        coveredRegions: _distinctRegions(images),
        images: images,
      ));
    }
    return out;
  }

  /// Parse a `scan_image.raw_response` JSON blob into a distinct list of
  /// detected class names, filtering out the per-tooth `tooth_*` entries
  /// (which are anatomy labels, not findings the caregiver cares about).
  static List<String> _parseDetections(String? raw) {
    if (raw == null || raw.isEmpty) return const [];
    try {
      final list = jsonDecode(raw);
      if (list is! List) return const [];
      final seen = <String>{};
      for (final d in list) {
        if (d is! Map) continue;
        final name = d['className'] as String?;
        if (name == null || name.isEmpty) continue;
        if (name.startsWith('tooth_')) continue;
        seen.add(name);
      }
      return seen.toList();
    } catch (_) {
      return const [];
    }
  }

  static List<String> _distinctRegions(List<ImageSlice> images) {
    final seen = <String>{};
    for (final i in images) {
      final r = i.estimatedRegion;
      if (r != null && r.isNotEmpty) seen.add(r);
    }
    return seen.toList();
  }

  /// Ask Gemma to synthesise a 3–4 sentence trend paragraph from the
  /// per-session analyses. Returns an empty string when no session has
  /// analysis text — the PDF omits the overview block in that case.
  static Future<String> _generateAiOverview(
    FamilyMemberStruct member,
    List<SessionSlice> sessions,
  ) async {
    final analysed = sessions
        .where((s) => (s.gemmaAnalysis ?? '').trim().isNotEmpty)
        .toList();
    if (analysed.isEmpty) return '';

    try {
      // `init()` is wrapped alongside `generateResponse` on purpose: on hosts
      // without the bundled model (e.g. unit tests, first-run before the
      // background download completes), init throws. A missing overview
      // should never kill the export — the caller falls back to the "No AI
      // overview available." line on the cover page.
      await GemmaService.instance.init();

      final buf = StringBuffer();
      for (var i = 0; i < analysed.length; i++) {
        final s = analysed[i];
        buf.writeln('--- Session ${i + 1} (${_isoDate(s.date)}) ---');
        buf.writeln(s.gemmaAnalysis!.trim());
        buf.writeln();
      }

      final prompt =
          'You are Bina, a dental health assistant. Below are the last '
          '${analysed.length} dental session analyses for '
          '${member.name.isEmpty ? "this member" : member.name}.\n\n'
          '${buf.toString()}'
          'In 3–4 sentences, describe the overall trend: what is improving, '
          'what is persistent, and what warrants a dentist visit. Do not '
          'repeat individual sessions — synthesise across them. Respond in '
          'English only.';

      final resp = await GemmaService.instance.generateResponse(prompt);
      final cleaned = resp.trim();
      if (cleaned.isEmpty || cleaned.startsWith('[ERROR')) {
        debugPrint('[HealthReport] AI overview failed: $cleaned');
        return '';
      }
      return cleaned;
    } catch (e) {
      debugPrint('[HealthReport] AI overview exception: $e');
      return '';
    }
  }

  static String _isoDate(DateTime d) =>
      '${d.year.toString().padLeft(4, "0")}-'
      '${d.month.toString().padLeft(2, "0")}-'
      '${d.day.toString().padLeft(2, "0")}';

  /// Filename used for the shared PDF. Sanitises the member name to keep
  /// share-sheet targets (Drive, Gmail) from choking on odd characters.
  static String buildFileName(FamilyMemberStruct member, DateTime generatedAt) {
    final rawName = member.name.isEmpty ? 'member' : member.name;
    final safeName = rawName
        .replaceAll(RegExp(r'[^A-Za-z0-9_-]+'), '_')
        .replaceAll(RegExp(r'_+'), '_')
        .replaceAll(RegExp(r'^_|_$'), '');
    final slug = safeName.isEmpty ? 'member' : safeName.toLowerCase();
    return 'bina_health_report_${slug}_${_isoDate(generatedAt)}.pdf';
  }
}

enum _DialogStage { working, ready, error }
enum _SaveStatus { idle, saving, saved, failed }

class _ReportExportDialog extends StatefulWidget {
  const _ReportExportDialog({required this.member});
  final FamilyMemberStruct member;

  @override
  State<_ReportExportDialog> createState() => _ReportExportDialogState();
}

class _ReportExportDialogState extends State<_ReportExportDialog> {
  _DialogStage _stage = _DialogStage.working;
  _SaveStatus _saveStatus = _SaveStatus.idle;
  Uint8List? _pdfBytes;
  String? _fileName;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _generate();
  }

  Future<void> _generate() async {
    try {
      final payload =
          await HealthReportService.buildPayload(member: widget.member);
      final bytes = await HealthReportPdfBuilder.build(payload);
      if (!mounted) return;
      final fileName =
          HealthReportService.buildFileName(widget.member, payload.generatedAt);
      setState(() {
        _pdfBytes = bytes;
        _fileName = fileName;
        _stage = _DialogStage.ready;
        _saveStatus = _SaveStatus.saving;
      });
      // Fire-and-forget the RAG attach so Share isn't blocked. The dialog
      // may get dismissed before this finishes — that's fine, the singleton
      // services and DB writes don't depend on this widget staying alive.
      unawaited(_attachToMemberDocuments(bytes, fileName));
    } catch (e, st) {
      debugPrint('[HealthReport] export failed: $e\n$st');
      if (!mounted) return;
      setState(() {
        _errorMessage = e.toString();
        _stage = _DialogStage.error;
      });
    }
  }

  Future<void> _attachToMemberDocuments(
    Uint8List bytes,
    String fileName,
  ) async {
    try {
      final picked = MemberDocumentService.instance.buildFromBytes(
        fileName: fileName,
        mimeType: 'application/pdf',
        bytes: bytes,
      );
      await MemberDocumentService.instance.attachToMember(
        familyMemberId: widget.member.id,
        doc: picked,
      );
      if (!mounted) return;
      setState(() => _saveStatus = _SaveStatus.saved);
    } catch (e) {
      debugPrint('[HealthReport] auto-save to documents failed: $e');
      if (!mounted) return;
      setState(() => _saveStatus = _SaveStatus.failed);
    }
  }

  Future<void> _share() async {
    final bytes = _pdfBytes;
    final name = _fileName;
    if (bytes == null || name == null) return;
    try {
      await Printing.sharePdf(bytes: bytes, filename: name);
    } catch (e) {
      debugPrint('[HealthReport] share failed: $e');
    }
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    switch (_stage) {
      case _DialogStage.working:
        return const AlertDialog(
          content: SizedBox(
            width: 220,
            child: Row(
              children: [
                SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2.5),
                ),
                SizedBox(width: 16),
                Expanded(child: Text('Generating report…')),
              ],
            ),
          ),
        );

      case _DialogStage.ready:
        return AlertDialog(
          title: const Text('Report ready'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Finished creating the summary.'),
              const SizedBox(height: 12),
              _SaveStatusLine(status: _saveStatus),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
            FilledButton.icon(
              icon: const Icon(Icons.ios_share_rounded),
              label: const Text('Share'),
              onPressed: _share,
            ),
          ],
        );

      case _DialogStage.error:
        return AlertDialog(
          title: const Text('Couldn\'t generate report'),
          content: Text(
            _errorMessage == null || _errorMessage!.isEmpty
                ? 'Something went wrong while building the report.'
                : _errorMessage!,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        );
    }
  }
}

/// Small status row shown beneath the "Report ready" copy while the report
/// is being chunked + embedded into the member's document library. Non-
/// blocking — the user can Share or Close at any time.
class _SaveStatusLine extends StatelessWidget {
  const _SaveStatusLine({required this.status});
  final _SaveStatus status;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final mutedStyle =
        theme.textTheme.bodySmall?.copyWith(color: theme.hintColor);

    switch (status) {
      case _SaveStatus.idle:
        return const SizedBox.shrink();
      case _SaveStatus.saving:
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(
              width: 12,
              height: 12,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            const SizedBox(width: 8),
            Text('Saving to member documents…', style: mutedStyle),
          ],
        );
      case _SaveStatus.saved:
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle_outline_rounded,
                size: 14, color: Colors.green),
            const SizedBox(width: 6),
            Text('Saved to member documents.', style: mutedStyle),
          ],
        );
      case _SaveStatus.failed:
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline_rounded,
                size: 14, color: Colors.orange),
            const SizedBox(width: 6),
            Text('Couldn\'t save to member documents.', style: mutedStyle),
          ],
        );
    }
  }
}
