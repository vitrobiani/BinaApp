import 'dart:typed_data';

import 'package:bina_system/services/embedding/chunk_retriever.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final retriever = ChunkRetriever.instance;

  group('retrieveTopK — guard clauses (no embedder needed)', () {
    test('empty familyMemberId → empty list, no embedder call', () async {
      final result = await retriever.retrieveTopK(
        familyMemberId: '',
        userQuery: 'anything',
      );
      expect(result, isEmpty);
    });

    test('empty userQuery → empty list', () async {
      final result = await retriever.retrieveTopK(
        familyMemberId: 'fm-1',
        userQuery: '',
      );
      expect(result, isEmpty);
    });

    test('whitespace-only userQuery → empty list', () async {
      final result = await retriever.retrieveTopK(
        familyMemberId: 'fm-1',
        userQuery: '   \t\n  ',
      );
      expect(result, isEmpty);
    });
  });

  group('RetrievedChunk data class', () {
    test('carries all constructor fields', () {
      const chunk = RetrievedChunk(
        documentId: 'doc-1',
        fileName: 'report.pdf',
        chunkIndex: 3,
        text: 'hello',
        score: 0.87,
      );
      expect(chunk.documentId, equals('doc-1'));
      expect(chunk.fileName, equals('report.pdf'));
      expect(chunk.chunkIndex, equals(3));
      expect(chunk.text, equals('hello'));
      expect(chunk.score, closeTo(0.87, 0.001));
    });

    test('accepts null fileName', () {
      const chunk = RetrievedChunk(
        documentId: 'doc-1',
        fileName: null,
        chunkIndex: 0,
        text: 'text',
        score: 0.5,
      );
      expect(chunk.fileName, isNull);
    });
  });

  group('cosineForTesting', () {
    test('identical L2-normalised vectors → 1.0', () {
      // Two identical unit vectors along X.
      final a = Float32List.fromList([1.0, 0.0, 0.0]);
      final b = Float32List.fromList([1.0, 0.0, 0.0]);
      expect(ChunkRetriever.cosineForTesting(a, b), closeTo(1.0, 1e-6));
    });

    test('orthogonal unit vectors → 0.0', () {
      final a = Float32List.fromList([1.0, 0.0, 0.0]);
      final b = Float32List.fromList([0.0, 1.0, 0.0]);
      expect(ChunkRetriever.cosineForTesting(a, b), closeTo(0.0, 1e-6));
    });

    test('opposite unit vectors → -1.0', () {
      final a = Float32List.fromList([1.0, 0.0, 0.0]);
      final b = Float32List.fromList([-1.0, 0.0, 0.0]);
      expect(ChunkRetriever.cosineForTesting(a, b), closeTo(-1.0, 1e-6));
    });

    test('scoring is a plain dot product (assumes L2-normalised inputs)', () {
      final a = Float32List.fromList([0.6, 0.8]);
      final b = Float32List.fromList([0.8, 0.6]);
      // dot = 0.48 + 0.48 = 0.96.
      expect(
        ChunkRetriever.cosineForTesting(a, b),
        closeTo(0.96, 1e-6),
      );
    });
  });

  group('decodeEmbeddingForTesting', () {
    test('round-trips Float32List → Uint8List → Float32List', () {
      final original = Float32List.fromList([0.1, -0.5, 0.75, 1.0, -1.25]);
      final blob = original.buffer.asUint8List(
        original.offsetInBytes,
        original.lengthInBytes,
      );

      final decoded = ChunkRetriever.decodeEmbeddingForTesting(blob);

      expect(decoded.length, equals(original.length));
      for (var i = 0; i < original.length; i++) {
        expect(decoded[i], closeTo(original[i], 1e-6));
      }
    });

    test('handles misaligned Uint8List offset without crashing', () {
      final original = Float32List.fromList([1.0, 2.0, 3.0, 4.0]);
      final rawBytes = original.buffer.asUint8List(0, original.lengthInBytes);
      final padded = Uint8List(rawBytes.length + 3);
      padded.setRange(3, padded.length, rawBytes);
      final misaligned = padded.buffer.asUint8List(3, rawBytes.length);
      expect(misaligned.offsetInBytes, equals(3),
          reason: 'sanity: this view has a non-4-byte offset');

      final decoded = ChunkRetriever.decodeEmbeddingForTesting(misaligned);
      for (var i = 0; i < original.length; i++) {
        expect(decoded[i], closeTo(original[i], 1e-6));
      }
    });

    test('accepts a plain List<int> (not just Uint8List)', () {
      final original = Float32List.fromList([0.1, 0.2, 0.3]);
      final blob = original.buffer.asUint8List(0, original.lengthInBytes);
      final asPlainList = List<int>.from(blob);
      final decoded = ChunkRetriever.decodeEmbeddingForTesting(asPlainList);
      expect(decoded.length, equals(3));
      for (var i = 0; i < original.length; i++) {
        expect(decoded[i], closeTo(original[i], 1e-6));
      }
    });
  });

  group('defaultTopK', () {
    test('is 4 (contract fence - used at every callsite that omits k)', () {
      expect(ChunkRetriever.defaultTopK, equals(4));
    });
  });
}
