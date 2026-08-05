import 'dart:convert';
import 'dart:typed_data';

import 'package:bina_system/backend/schema/structs/index.dart';
import 'package:bina_system/services/health_report_pdf_builder.dart';
import 'package:bina_system/services/health_report_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';

void main() {
  FamilyMemberStruct fm(String name) =>
      FamilyMemberStruct(id: 'fm-1', name: name);

  SessionSlice sliceWithImages(List<ImageSlice> images, {String? notes}) =>
      SessionSlice(
        id: 's-1',
        date: DateTime(2025, 6, 15, 10, 0),
        duration: const Duration(minutes: 3, seconds: 20),
        gemmaAnalysis: notes,
        coveredRegions: const ['upper_front', 'lower_left'],
        images: images,
      );

  final tinyJpeg = _buildTinyJpeg();

  HealthReportPayload payload({
    String name = 'Alice',
    String aiOverview = 'Overall trend is stable.',
    List<SessionSlice>? sessions,
  }) =>
      HealthReportPayload(
        member: fm(name),
        aiOverview: aiOverview,
        sessions: sessions ?? const [],
        generatedAt: DateTime(2025, 6, 15, 10, 0),
      );

  group('build — output validity', () {
    test('returns a valid PDF (magic header + parseable structure)', () async {
      final bytes = await HealthReportPdfBuilder.build(payload());

      expect(bytes, isA<Uint8List>());
      expect(bytes.length, greaterThan(200),
          reason: 'a real PDF is never sub-200 bytes');
      expect(String.fromCharCodes(bytes.sublist(0, 5)), equals('%PDF-'));

      final doc = PdfDocument(inputBytes: bytes);
      expect(doc.pages.count, greaterThanOrEqualTo(1));
      doc.dispose();
    });

    test('second build in the same isolate succeeds (regression fence)',
        () async {
      final first =
          await HealthReportPdfBuilder.build(payload(name: 'Alice'));
      final second =
          await HealthReportPdfBuilder.build(payload(name: 'Bob'));

      expect(first.length, greaterThan(0));
      expect(second.length, greaterThan(0));
      expect(first, isNot(equals(second)));
    });

    test('cover page renders when there are no sessions', () async {
      final bytes = await HealthReportPdfBuilder.build(payload(sessions: []));
      final doc = PdfDocument(inputBytes: bytes);
      expect(doc.pages.count, equals(1),
          reason: 'empty sessions list → cover-only PDF');
      doc.dispose();
    });

    test('one page per session (plus the cover)', () async {
      final threeSessions = [
        for (var i = 0; i < 3; i++)
          SessionSlice(
            id: 's-$i',
            date: DateTime(2025, 6, 10 + i),
            duration: null,
            gemmaAnalysis: null,
            coveredRegions: const [],
            images: const [],
          ),
      ];
      final bytes = await HealthReportPdfBuilder.build(
          payload(sessions: threeSessions));
      final doc = PdfDocument(inputBytes: bytes);
      expect(doc.pages.count, equals(4));
      doc.dispose();
    });

    test('long analysis paginates onto additional pages', () async {
      final longText = List.generate(
        250,
        (i) =>
            'This is a very long analysis sentence number $i, packed with '
            'enough words that the paragraph will surely overflow a single '
            'page at eleven-point body text. ',
      ).join();
      final session = SessionSlice(
        id: 's-long',
        date: DateTime(2025, 6, 15),
        duration: null,
        gemmaAnalysis: longText,
        coveredRegions: const [],
        images: const [],
      );
      final bytes = await HealthReportPdfBuilder.build(
        payload(sessions: [session]),
      );
      final doc = PdfDocument(inputBytes: bytes);
      expect(doc.pages.count, greaterThanOrEqualTo(3),
          reason: '16k chars of analysis must paginate');
      doc.dispose();
    });

    test('unparseable image bytes are dropped, PDF still generates', () async {
      final junk = Uint8List.fromList(List.filled(64, 0x00));
      final session = sliceWithImages([
        ImageSlice(
          bytes: junk,
          capturedAt: DateTime(2025, 6, 15),
          estimatedRegion: 'upper_front',
          detectedClasses: const ['plaque'],
        ),
      ]);
      final bytes = await HealthReportPdfBuilder.build(
        payload(sessions: [session]),
      );
      expect(bytes.length, greaterThan(200));
      final doc = PdfDocument(inputBytes: bytes);
      expect(doc.pages.count, greaterThanOrEqualTo(2));
      doc.dispose();
    });

    test('mixed image list: valid + junk → valid ones survive, no crash',
        () async {
      final session = sliceWithImages([
        ImageSlice(
          bytes: tinyJpeg,
          capturedAt: DateTime(2025, 6, 15, 10, 0),
          estimatedRegion: 'upper_front',
          detectedClasses: const ['plaque'],
        ),
        ImageSlice(
          bytes: Uint8List.fromList(List.filled(32, 0)),
          capturedAt: DateTime(2025, 6, 15, 10, 1),
          estimatedRegion: null,
          detectedClasses: const [],
        ),
        ImageSlice(
          bytes: tinyJpeg,
          capturedAt: DateTime(2025, 6, 15, 10, 2),
          estimatedRegion: 'lower_left',
          detectedClasses: const [],
        ),
      ]);
      final bytes = await HealthReportPdfBuilder.build(
        payload(sessions: [session]),
      );
      expect(bytes.length, greaterThan(0));
    });

    test('footer template text is embedded in the output', () async {
      final bytes = await HealthReportPdfBuilder.build(payload());
      final doc = PdfDocument(inputBytes: bytes);
      final extracted = PdfTextExtractor(doc).extractText();
      expect(extracted, contains('Bina Health Report'));
      doc.dispose();
    });
  });

  group('sanitizeForTesting — Windows-1252 fallback table', () {
    test('preserves ASCII verbatim', () {
      expect(
        HealthReportPdfBuilder.sanitizeForTesting('Hello, world! 123'),
        equals('Hello, world! 123'),
      );
    });

    test('preserves tab, LF, CR', () {
      expect(HealthReportPdfBuilder.sanitizeForTesting('a\tb\nc\rd'),
          equals('a\tb\nc\rd'));
    });

    test('preserves Latin-1 supplement (accented letters, middle dot)', () {
      expect(
        HealthReportPdfBuilder.sanitizeForTesting('café · naïve'),
        equals('café · naïve'),
      );
    });

    test('em-dash and en-dash collapse to hyphen', () {
      expect(HealthReportPdfBuilder.sanitizeForTesting('a–b—c'),
          equals('a-b-c'));
    });

    test('curly quotes collapse to straight ASCII quotes', () {
      expect(HealthReportPdfBuilder.sanitizeForTesting('‘hi’'),
          equals("'hi'"));
      expect(HealthReportPdfBuilder.sanitizeForTesting('“hi”'),
          equals('"hi"'));
    });

    test('ellipsis expands to three dots', () {
      expect(HealthReportPdfBuilder.sanitizeForTesting('wait…'),
          equals('wait...'));
    });

    test('Cyrillic О (U+041E) — the exact byte that used to crash the app '
        '— degrades to ?', () {
      expect(HealthReportPdfBuilder.sanitizeForTesting('О is not O'),
          equals('? is not O'));
    });

    test('Hebrew, CJK, emoji all degrade to ? rather than throwing', () {
      final input = 'שלום 你好 🦷';
      final result = HealthReportPdfBuilder.sanitizeForTesting(input);
      expect(result, isNot(contains('שלום')));
      expect(result.replaceAll('?', '').trim(), equals(''));
    });

    test('Windows-1252 undefined slots collapse to ?', () {
      final input = String.fromCharCodes([0x41, 0x81, 0x8D, 0x8F, 0x90, 0x9D, 0x42]);
      final result = HealthReportPdfBuilder.sanitizeForTesting(input);
      expect(result, equals('A?????B'));
    });
  });
}

Uint8List _buildTinyJpeg() {
  const base64Payload =
      '/9j/4AAQSkZJRgABAQEASABIAAD/2wBDAAgGBgcGBQgHBwcJCQgKDBQNDAsLDBkSEw8UHRofHh0aHBwgJC4nICIsIxwcKDcpLDAxNDQ0Hyc5PTgyPC4zNDL/2wBDAQkJCQwLDBgNDRgyIRwhMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjL/wAARCAABAAEDASIAAhEBAxEB/8QAHwAAAQUBAQEBAQEAAAAAAAAAAAECAwQFBgcICQoL/8QAtRAAAgEDAwIEAwUFBAQAAAF9AQIDAAQRBRIhMUEGE1FhByJxFDKBkaEII0KxwRVS0fAkM2JyggkKFhcYGRolJicoKSo0NTY3ODk6Q0RFRkdISUpTVFVWV1hZWmNkZWZnaGlqc3R1dnd4eXqDhIWGh4iJipKTlJWWl5iZmqKjpKWmp6ipqrKztLW2t7i5usLDxMXGx8jJytLT1NXW19jZ2uHi4+Tl5ufo6erx8vP09fb3+Pn6/8QAHwEAAwEBAQEBAQEBAQAAAAAAAAECAwQFBgcICQoL/8QAtREAAgECBAQDBAcFBAQAAQJ3AAECAxEEBSExBhJBUQdhcRMiMoEIFEKRobHBCSMzUvAVYnLRChYkNOEl8RcYGRomJygpKjU2Nzg5OkNERUZHSElKU1RVVldYWVpjZGVmZ2hpanN0dXZ3eHl6goOEhYaHiImKkpOUlZaXmJmaoqOkpaanqKmqsrO0tba3uLm6wsPExcbHyMnK0tPU1dbX2Nna4uPk5ebn6Onq8vP09fb3+Pn6/9oADAMBAAIRAxEAPwD3+iiigD//2Q==';
  return Uint8List.fromList(base64Decode(base64Payload));
}
