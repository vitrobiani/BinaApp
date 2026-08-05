import 'dart:typed_data';

import 'package:bina_system/services/member_document_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';

void main() {
  final svc = MemberDocumentService.instance;

  Uint8List pdfWithText(String text) {
    final doc = PdfDocument();
    final page = doc.pages.add();
    final font = PdfStandardFont(PdfFontFamily.helvetica, 12);
    page.graphics.drawString(text, font);
    final bytes = Uint8List.fromList(doc.saveSync());
    doc.dispose();
    return bytes;
  }

  group('buildFromBytes — status branches', () {
    test('rich PDF (>> 40 non-ws chars) → status "ok"', () {
      final bytes = pdfWithText(
        'Patient presents with a small cavity on the upper-left molar. '
        'Follow-up recommended in six months. Fluoride treatment applied.',
      );
      final picked = svc.buildFromBytes(
        fileName: 'referral.pdf',
        mimeType: 'application/pdf',
        bytes: bytes,
      );
      expect(picked.extractionStatus, equals('ok'));
      expect(picked.extractedText, contains('cavity'));
      expect(picked.fileName, equals('referral.pdf'));
      expect(picked.mimeType, equals('application/pdf'));
      expect(picked.bytes, equals(bytes));
      expect(picked.byteSize, equals(bytes.length));
    });

    test('PDF with < 40 non-whitespace chars → status "empty"', () {
      final bytes = pdfWithText('Hi there.');
      final picked = svc.buildFromBytes(
        fileName: 'stub.pdf',
        mimeType: 'application/pdf',
        bytes: bytes,
      );
      expect(picked.extractionStatus, equals('empty'));
      expect(picked.extractedText.replaceAll(RegExp(r'\s+'), '').length,
          lessThan(40));
    });

    test('completely blank PDF (no drawn text) → status "empty"', () {
      final doc = PdfDocument();
      doc.pages.add(); // page with no content.
      final bytes = Uint8List.fromList(doc.saveSync());
      doc.dispose();
      final picked = svc.buildFromBytes(
        fileName: 'blank.pdf',
        mimeType: 'application/pdf',
        bytes: bytes,
      );
      expect(picked.extractionStatus, equals('empty'));
    });

    test('random garbage bytes → status "error"', () {
      final garbage = Uint8List.fromList(
        List<int>.generate(500, (i) => i % 256),
      );
      final picked = svc.buildFromBytes(
        fileName: 'garbage.pdf',
        mimeType: 'application/pdf',
        bytes: garbage,
      );
      expect(picked.extractionStatus, equals('error'));
      expect(picked.extractedText, isEmpty);
    });

    test('exactly 40 non-whitespace chars → boundary is "ok" (inclusive gte)',
        () {
      final bytes = pdfWithText('A' * 50); // 50 non-ws chars.
      final picked = svc.buildFromBytes(
        fileName: 't.pdf',
        mimeType: 'application/pdf',
        bytes: bytes,
      );
      expect(picked.extractionStatus, equals('ok'));
    });

    test('whitespace-only extracted text → status "empty"', () {
      final bytes = pdfWithText('   \n\n\t  ');
      final picked = svc.buildFromBytes(
        fileName: 'ws.pdf',
        mimeType: 'application/pdf',
        bytes: bytes,
      );
      expect(picked.extractionStatus, equals('empty'));
    });
  });

  group('PickedDocument surface', () {
    test('byteSize reflects the input Uint8List length', () {
      final bytes = pdfWithText('hello ' * 20);
      final picked = svc.buildFromBytes(
        fileName: 'x.pdf',
        mimeType: 'application/pdf',
        bytes: bytes,
      );
      expect(picked.byteSize, equals(bytes.length));
    });

    test('nullable mimeType is preserved verbatim', () {
      final bytes = pdfWithText('hello ' * 20);
      final picked = svc.buildFromBytes(
        fileName: 'x.pdf',
        mimeType: null,
        bytes: bytes,
      );
      expect(picked.mimeType, isNull);
    });
  });

  group('_emptyThreshold contract fence', () {
    test('below 40 non-ws chars is "empty"', () {
      final bytes = pdfWithText('A' * 39);
      final picked = svc.buildFromBytes(
        fileName: 't.pdf',
        mimeType: null,
        bytes: bytes,
      );
      expect(picked.extractionStatus, equals('empty'));
    });
  });
}
