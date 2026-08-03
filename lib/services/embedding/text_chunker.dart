/// Splits extracted PDF text into overlapping chunks suitable for embedding.
///
/// Strategy: greedy pack up to [targetChars], preferring cut points in this
/// order — double-newline (paragraph), sentence terminator (`.`, `!`, `?`,
/// Hebrew `׃`), then any whitespace, then a hard cut. Adjacent chunks share
/// [overlapChars] of tail/head text so a fact split across a boundary stays
/// retrievable from either side.
class TextChunker {
  static const int defaultTargetChars = 500;
  static const int defaultOverlapChars = 50;
  static const int minChunkChars = 40;

  static List<String> chunk(
    String raw, {
    int targetChars = defaultTargetChars,
    int overlapChars = defaultOverlapChars,
  }) {
    final normalised = raw.replaceAll('\r\n', '\n').trim();
    if (normalised.length <= targetChars) {
      return normalised.length >= minChunkChars ? [normalised] : const [];
    }

    final chunks = <String>[];
    var start = 0;
    while (start < normalised.length) {
      final hardEnd = (start + targetChars).clamp(0, normalised.length);
      var end = hardEnd;
      if (end < normalised.length) {
        // Prefer the last paragraph break in the window.
        var cut = normalised.lastIndexOf('\n\n', hardEnd);
        if (cut > start + minChunkChars) {
          end = cut;
        } else {
          // Then the last sentence terminator.
          cut = _lastSentenceBreak(normalised, start, hardEnd);
          if (cut > start + minChunkChars) {
            end = cut;
          } else {
            // Then any whitespace.
            cut = normalised.lastIndexOf(RegExp(r'\s'), hardEnd);
            if (cut > start + minChunkChars) {
              end = cut;
            }
          }
        }
      }

      final piece = normalised.substring(start, end).trim();
      if (piece.length >= minChunkChars) {
        chunks.add(piece);
      }

      if (end >= normalised.length) break;
      // Step forward with overlap; guarantee progress.
      final next = end - overlapChars;
      start = next > start ? next : end;
    }
    return chunks;
  }

  static int _lastSentenceBreak(String text, int start, int end) {
    for (var i = end - 1; i > start; i--) {
      final c = text[i];
      if (c == '.' || c == '!' || c == '?' || c == '׃') {
        return i + 1;
      }
    }
    return -1;
  }
}
