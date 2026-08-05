import 'package:bina_system/services/embedding/text_chunker.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('boundary cases', () {
    test('empty string → empty list', () {
      expect(TextChunker.chunk(''), isEmpty);
    });

    test('whitespace-only string → empty list', () {
      expect(TextChunker.chunk('   \n\n\t   '), isEmpty);
    });

    test('input shorter than minChunkChars → empty list', () {
      final tiny = 'abc';
      expect(tiny.length, lessThan(TextChunker.minChunkChars));
      expect(TextChunker.chunk(tiny), isEmpty);
    });

    test('input just above minChunkChars but below targetChars → single chunk',
        () {
      final s = 'A' * (TextChunker.minChunkChars + 5);
      final chunks = TextChunker.chunk(s);
      expect(chunks, hasLength(1));
      expect(chunks.first, equals(s));
    });

    test('input exactly targetChars → single chunk (no split)', () {
      final s = 'x' * TextChunker.defaultTargetChars;
      final chunks = TextChunker.chunk(s);
      expect(chunks, hasLength(1));
      expect(chunks.first.length, equals(TextChunker.defaultTargetChars));
    });
  });

  group('cut-point preferences', () {
    test('prefers the last paragraph break inside the window (max fill)',
        () {
      final block1 = 'A' * 200;
      final block2 = 'B' * 200;
      final block3 = 'C' * 200;
      final input = '$block1\n\n$block2\n\n$block3';
      final chunks = TextChunker.chunk(input);
      expect(chunks.length, equals(2));
      expect(chunks.first, contains(block1));
      expect(chunks.first, contains(block2));
      expect(chunks.first, isNot(contains('C')));
    });

    test('falls back to sentence terminator when no paragraph break', () {
      final head = 'The patient has a small cavity on the upper left molar. ';
      final tail = 'Follow-up recommended in six months.' * 20;
      final input = head + tail;
      final chunks = TextChunker.chunk(input);
      expect(chunks.length, greaterThan(1));
      // First chunk should end at a sentence terminator, not mid-word.
      expect(chunks.first.trimRight(), endsWith('.'));
    });

    test('Hebrew sentence terminator (׃) is a valid cut point', () {
      // Hebrew Sof Pasuq (U+05C3) — same role as period in the algorithm.
      final head = 'המטופל סובל מעששת קלה בשן העליונה השמאלית׃ ';
      final padding = 'א' * 500;
      final input = head + padding;
      final chunks = TextChunker.chunk(input);
      expect(chunks.length, greaterThan(1));
      expect(chunks.first.trimRight(), endsWith('׃'));
    });

    test('falls back to any whitespace when no punctuation in window', () {
      // No paragraph breaks or sentence terminators in the first 500 chars.
      final input =
          'word ' * 200; // 1000 chars, no \n\n, no . ! ?, only spaces.
      final chunks = TextChunker.chunk(input);
      expect(chunks.length, greaterThan(1));
      // The first chunk should not end mid-word (should end at a space that
      // gets trimmed off).
      for (final c in chunks) {
        expect(c.trimLeft(), equals(c),
            reason: 'chunk should start clean after trimming');
      }
    });

    test('hard cut when a single word exceeds targetChars (no infinite loop)',
        () {
      final oneHugeWord = 'x' * 1200; // No whitespace, no punctuation.
      final chunks = TextChunker.chunk(oneHugeWord);
      // Must produce at least one chunk and terminate.
      expect(chunks, isNotEmpty);
      // Every chunk stays within the target size.
      for (final c in chunks) {
        expect(c.length, lessThanOrEqualTo(TextChunker.defaultTargetChars));
      }
    });
  });

  group('overlap behaviour', () {
    test('adjacent chunks share up to overlapChars of tail/head text', () {
      // Two paragraphs, each 400 chars — should split at the paragraph break.
      final block1 = 'A' * 400;
      final block2 = 'B' * 400;
      final input = '$block1\n\n$block2';
      final chunks = TextChunker.chunk(input);
      expect(chunks.length, equals(2));
      expect(chunks[1].startsWith('A'), isTrue,
          reason: 'overlap should include tail of previous chunk');
      expect(chunks[1], contains('B' * 100));
    });

    test('every chunk respects targetChars ceiling', () {
      final long = ('Sentence ' * 400); // ~3200 chars, plenty of spaces.
      final chunks = TextChunker.chunk(long);
      for (final c in chunks) {
        expect(c.length, lessThanOrEqualTo(TextChunker.defaultTargetChars));
      }
    });
  });

  group('EOL normalisation', () {
    test('Windows CRLF and Unix LF produce identical chunk lists', () {
      final unix = ('Line one.\nLine two.\n' * 40);
      final windows = unix.replaceAll('\n', '\r\n');
      expect(TextChunker.chunk(unix), equals(TextChunker.chunk(windows)));
    });

    test('leading and trailing whitespace is trimmed from the whole input',
        () {
      final padded = '   \n\n' + ('word ' * 200) + '\n\n   ';
      final chunks = TextChunker.chunk(padded);
      expect(chunks.first.startsWith(' '), isFalse);
      expect(chunks.last.endsWith(' '), isFalse);
    });
  });

  group('custom parameters', () {
    test('smaller targetChars → more chunks', () {
      final input = 'word ' * 400; // 2000 chars.
      final large = TextChunker.chunk(input, targetChars: 500);
      final small = TextChunker.chunk(input, targetChars: 200);
      expect(small.length, greaterThan(large.length));
    });

    test('zero overlap still terminates (progress guarantee)', () {
      final input = 'word ' * 400;
      final chunks = TextChunker.chunk(input, targetChars: 200, overlapChars: 0);
      expect(chunks, isNotEmpty);
    });
  });
}
