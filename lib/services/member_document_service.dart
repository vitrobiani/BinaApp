import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';

import '/app_state.dart';
import '/backend/schema/structs/index.dart';

/// A PDF the user just picked, with text already extracted. Handed off to
/// [MemberDocumentService.attachToMember] for persistence.
class PickedDocument {
  final String fileName;
  final String? mimeType;
  final Uint8List bytes;
  final String extractedText;
  final String extractionStatus; // 'ok' | 'empty' | 'error'

  const PickedDocument({
    required this.fileName,
    required this.mimeType,
    required this.bytes,
    required this.extractedText,
    required this.extractionStatus,
  });

  int get byteSize => bytes.length;
}

/// End-to-end pipeline for the member-documents feature: pick a PDF from
/// the device, extract its text with syncfusion_flutter_pdf, and hand it
/// to [AppState] for dual-backend persistence.
class MemberDocumentService {
  MemberDocumentService._();
  static final MemberDocumentService instance = MemberDocumentService._();

  /// Below this many non-whitespace chars, we treat the PDF as text-less
  /// (typically a scanned image) and mark it 'empty' so we don't try to
  /// feed it to Gemma.
  static const int _emptyThreshold = 40;

  Future<PickedDocument?> pickAndExtract() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: const ['pdf'],
      withData: true,
    );
    if (result == null || result.files.isEmpty) return null;
    final f = result.files.single;
    final bytes = f.bytes;
    if (bytes == null) return null;

    return _extractFromBytes(
      fileName: f.name,
      mimeType: 'application/pdf',
      bytes: bytes,
    );
  }

  /// Public so the widget layer / tests can extract from a known byte
  /// buffer (fixture, drag-and-drop, etc.) without going through the picker.
  PickedDocument _extractFromBytes({
    required String fileName,
    required String? mimeType,
    required Uint8List bytes,
  }) {
    String text = '';
    String status;
    try {
      final doc = PdfDocument(inputBytes: bytes);
      text = PdfTextExtractor(doc).extractText();
      doc.dispose();
      final compact = text.replaceAll(RegExp(r'\s+'), '');
      status = compact.length < _emptyThreshold ? 'empty' : 'ok';
    } catch (e) {
      debugPrint('[MemberDocument] extraction failed: $e');
      status = 'error';
      text = '';
    }
    return PickedDocument(
      fileName: fileName,
      mimeType: mimeType,
      bytes: bytes,
      extractedText: text,
      extractionStatus: status,
    );
  }

  Future<MemberDocumentStruct> attachToMember({
    required String familyMemberId,
    required PickedDocument doc,
  }) {
    return AppState().saveMemberDocument(
      familyMemberId: familyMemberId,
      fileName: doc.fileName,
      mimeType: doc.mimeType,
      bytes: doc.bytes,
      extractedText: doc.extractedText,
      extractionStatus: doc.extractionStatus,
    );
  }

  Future<void> deleteFromMember(MemberDocumentStruct doc) {
    return AppState().deleteMemberDocument(doc);
  }
}
