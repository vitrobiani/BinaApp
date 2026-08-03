import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';

import '/app_state.dart';
import '/backend/schema/structs/index.dart';
import 'embedding/text_chunker.dart';
import 'embedding_service.dart';

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

/// Progress event emitted during an [MemberDocumentService.attachToMember]
/// call. Consumers show a bar going from `stage: saving` through
/// `stage: embedding` (with `current/total` chunks) to `stage: done`.
class AttachProgress {
  final AttachStage stage;
  final int current;
  final int total;
  const AttachProgress(this.stage, {this.current = 0, this.total = 0});
}

enum AttachStage { saving, embedding, done }

typedef AttachProgressCallback = void Function(AttachProgress event);

/// End-to-end pipeline for the member-documents feature: pick a PDF from
/// the device, extract its text with syncfusion_flutter_pdf, save the doc
/// row, then chunk + embed the text and save chunks for RAG.
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

    return buildFromBytes(
      fileName: f.name,
      mimeType: 'application/pdf',
      bytes: bytes,
    );
  }

  /// Public entry point for callers that already have PDF bytes on hand
  /// (e.g. the health-report exporter feeding its own generated PDF back
  /// into the RAG pipeline). Runs extraction + status tagging so the caller
  /// can then hand the result to [attachToMember].
  PickedDocument buildFromBytes({
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

  /// Save the document, then chunk + embed its text and persist each chunk.
  /// [onProgress] fires: once with `saving`, then once per chunk with
  /// `embedding` (current/total), then once with `done`. Embedding is done
  /// on the main isolate with `await Future.delayed(Duration.zero)` yielded
  /// between chunks so the UI stays responsive.
  Future<MemberDocumentStruct> attachToMember({
    required String familyMemberId,
    required PickedDocument doc,
    AttachProgressCallback? onProgress,
  }) async {
    onProgress?.call(const AttachProgress(AttachStage.saving));
    final saved = await AppState().saveMemberDocument(
      familyMemberId: familyMemberId,
      fileName: doc.fileName,
      mimeType: doc.mimeType,
      bytes: doc.bytes,
      extractedText: doc.extractedText,
      extractionStatus: doc.extractionStatus,
    );

    // Skip embedding for 'empty' (scanned image) and 'error' extractions.
    // The doc row is still persisted so the user sees it in the list with
    // the amber "no text" badge.
    if (doc.extractionStatus != 'ok' || doc.extractedText.trim().isEmpty) {
      onProgress?.call(const AttachProgress(AttachStage.done));
      return saved;
    }

    // Make sure the embedder is loaded before we spin the progress bar.
    try {
      await EmbeddingService.instance.init();
    } catch (e) {
      debugPrint('[MemberDocument] embedder not available: $e');
      onProgress?.call(const AttachProgress(AttachStage.done));
      return saved;
    }

    final chunks = TextChunker.chunk(doc.extractedText);
    debugPrint('[MemberDocument] chunked ${doc.fileName} into '
        '${chunks.length} pieces');

    for (var i = 0; i < chunks.length; i++) {
      onProgress?.call(AttachProgress(
        AttachStage.embedding,
        current: i,
        total: chunks.length,
      ));
      final vec = await EmbeddingService.instance.embedDocument(chunks[i]);
      if (vec == null) {
        debugPrint('[MemberDocument] embed returned null for chunk $i, '
            'skipping remainder');
        break;
      }
      await AppState().saveDocumentChunk(
        documentId: saved.id,
        chunkIndex: i,
        text: chunks[i],
        embedding: vec,
      );
      // Yield back to the event loop so taps, animations, etc. can process
      // between chunks. Cheap on Dart, invisible to users, keeps ANR at bay.
      await Future.delayed(Duration.zero);
    }

    onProgress?.call(AttachProgress(
      AttachStage.done,
      current: chunks.length,
      total: chunks.length,
    ));
    return saved;
  }

  Future<void> deleteFromMember(MemberDocumentStruct doc) {
    return AppState().deleteMemberDocument(doc);
  }
}
