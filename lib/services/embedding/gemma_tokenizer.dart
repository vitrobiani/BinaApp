import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;

/// Byte-Pair-Encoding tokenizer for EmbeddingGemma-300M.
///
/// Loads Hugging Face `tokenizer.json` (~20 MB) and produces the exact same
/// token ids the model was trained on. Implements:
///   * `Replace(" ", "▁")` normalizer
///   * BPE with `byte_fallback` (rare bytes → `<0xNN>` tokens)
///   * `fuse_unk` (consecutive `<unk>` collapse into one)
///   * `TemplateProcessing` post-processor (`<bos> ... <eos>`)
///
/// The pre-tokenizer in the config splits on the raw space character, but the
/// normalizer already substitutes every space with `▁` before the pre-tokenizer
/// sees the string — so the split is a no-op for us and we skip it.
class GemmaTokenizer {
  GemmaTokenizer._({
    required this.vocab,
    required this.mergeRank,
    required this.bosId,
    required this.eosId,
    required this.padId,
    required this.unkId,
    required this.byteFallbackIds,
    required this.specialContent,
  });

  final Map<String, int> vocab;
  // Key format: "$left$right" → rank (lower = earlier merge, higher priority).
  final Map<String, int> mergeRank;
  final int bosId;
  final int eosId;
  final int padId;
  final int unkId;
  // Byte → id for byte_fallback (`<0xNN>` entries).
  final List<int> byteFallbackIds;
  // Exact strings the tokenizer treats as atomic (special/added tokens).
  final Set<String> specialContent;

  static Future<GemmaTokenizer> loadFromAsset(String assetKey) async {
    final sw = Stopwatch()..start();
    final jsonStr = await rootBundle.loadString(assetKey);
    debugPrint('[Tokenizer] read $assetKey (${jsonStr.length} chars) in '
        '${sw.elapsedMilliseconds}ms');

    final parsed = await compute(_parseTokenizerJson, jsonStr);
    debugPrint('[Tokenizer] parsed vocab=${parsed.vocab.length} '
        'merges=${parsed.mergeRank.length} in ${sw.elapsedMilliseconds}ms');
    return parsed;
  }

  /// Encode a raw text string to token ids, wrapped as `<bos> ... <eos>`.
  Uint32List encode(String text, {int? maxLength}) {
    final normalized = _normalize(text);
    final tokens = <String>[];
    for (final piece in _splitOnSpecials(normalized)) {
      if (piece.isSpecial) {
        tokens.add(piece.text);
      } else {
        tokens.addAll(_encodeSegment(piece.text));
      }
    }

    final ids = <int>[bosId];
    int lastId = -1;
    for (final tok in tokens) {
      var id = vocab[tok] ?? unkId;
      // fuse_unk: don't emit consecutive unks
      if (id == unkId && lastId == unkId) continue;
      ids.add(id);
      lastId = id;
    }
    ids.add(eosId);

    if (maxLength != null && ids.length > maxLength) {
      // Preserve BOS at index 0 and EOS at the end.
      final truncated = <int>[bosId];
      truncated.addAll(ids.sublist(1, maxLength - 1));
      truncated.add(eosId);
      return Uint32List.fromList(truncated);
    }
    return Uint32List.fromList(ids);
  }

  // ---------------------------------------------------------------------------
  //  Internals
  // ---------------------------------------------------------------------------

  static String _normalize(String text) => text.replaceAll(' ', '▁');

  Iterable<_Piece> _splitOnSpecials(String text) sync* {
    if (specialContent.isEmpty) {
      yield _Piece(text, false);
      return;
    }
    var idx = 0;
    while (idx < text.length) {
      int nearestPos = -1;
      String? nearestTok;
      for (final tok in specialContent) {
        final p = text.indexOf(tok, idx);
        if (p != -1 && (nearestPos == -1 || p < nearestPos)) {
          nearestPos = p;
          nearestTok = tok;
        }
      }
      if (nearestTok == null) {
        yield _Piece(text.substring(idx), false);
        return;
      }
      if (nearestPos > idx) {
        yield _Piece(text.substring(idx, nearestPos), false);
      }
      yield _Piece(nearestTok, true);
      idx = nearestPos + nearestTok.length;
    }
  }

  /// Encode one segment of ordinary text via BPE.
  List<String> _encodeSegment(String text) {
    if (text.isEmpty) return const [];

    // Step 1: split into base tokens. Prefer direct vocab hits per Unicode
    // grapheme (via runes); anything unknown drops to per-byte fallback.
    final base = <String>[];
    for (final rune in text.runes) {
      final ch = String.fromCharCode(rune);
      if (vocab.containsKey(ch)) {
        base.add(ch);
      } else {
        // Byte fallback: emit `<0xNN>` per UTF-8 byte.
        for (final byte in utf8.encode(ch)) {
          base.add(_byteFallbackToken(byte));
        }
      }
    }

    // Step 2: greedily apply the best-ranked adjacent merge until none remain.
    var toks = base;
    while (toks.length > 1) {
      int bestRank = -1;
      int bestIdx = -1;
      for (var i = 0; i < toks.length - 1; i++) {
        final rank = mergeRank[_pairKey(toks[i], toks[i + 1])];
        if (rank == null) continue;
        if (bestRank == -1 || rank < bestRank) {
          bestRank = rank;
          bestIdx = i;
        }
      }
      if (bestIdx == -1) break;
      final merged = <String>[];
      merged.addAll(toks.take(bestIdx));
      merged.add(toks[bestIdx] + toks[bestIdx + 1]);
      merged.addAll(toks.skip(bestIdx + 2));
      toks = merged;
    }
    return toks;
  }

  String _byteFallbackToken(int byte) {
    final hex = byte.toRadixString(16).padLeft(2, '0').toUpperCase();
    return '<0x$hex>';
  }
}

class _Piece {
  const _Piece(this.text, this.isSpecial);
  final String text;
  final bool isSpecial;
}

String _pairKey(String a, String b) => '$a$b';

/// Runs in a background isolate via `compute()` so the 20 MB JSON parse and
/// map builds don't block the UI thread on startup.
GemmaTokenizer _parseTokenizerJson(String jsonStr) {
  final json = jsonDecode(jsonStr) as Map<String, dynamic>;
  final model = json['model'] as Map<String, dynamic>;

  final rawVocab = model['vocab'] as Map<String, dynamic>;
  final vocab = <String, int>{};
  rawVocab.forEach((k, v) => vocab[k] = (v as num).toInt());

  final rawMerges = model['merges'] as List<dynamic>;
  final mergeRank = <String, int>{};
  for (var i = 0; i < rawMerges.length; i++) {
    final entry = rawMerges[i];
    String left;
    String right;
    if (entry is List) {
      left = entry[0] as String;
      right = entry[1] as String;
    } else {
      // Legacy space-separated format "a b".
      final parts = (entry as String).split(' ');
      left = parts[0];
      right = parts.sublist(1).join(' ');
    }
    mergeRank[_pairKey(left, right)] = i;
  }

  // Collect the atomic strings (added_tokens + everything with special:true).
  final specialContent = <String>{};
  final addedTokens = json['added_tokens'] as List<dynamic>?;
  if (addedTokens != null) {
    for (final t in addedTokens) {
      final m = t as Map<String, dynamic>;
      final content = m['content'] as String;
      // Skip the pure ids that would otherwise trigger huge global scans.
      // BOS/EOS/PAD/UNK are added by the post-processor, not found inline.
      if (content == '<bos>' ||
          content == '<eos>' ||
          content == '<pad>' ||
          content == '<unk>') {
        continue;
      }
      specialContent.add(content);
    }
  }

  // Byte-fallback lookup: byte value → token id.
  final byteFallbackIds = List<int>.filled(256, -1);
  for (var b = 0; b < 256; b++) {
    final hex = b.toRadixString(16).padLeft(2, '0').toUpperCase();
    final id = vocab['<0x$hex>'];
    if (id != null) byteFallbackIds[b] = id;
  }

  return GemmaTokenizer._(
    vocab: vocab,
    mergeRank: mergeRank,
    bosId: vocab['<bos>'] ?? 2,
    eosId: vocab['<eos>'] ?? 1,
    padId: vocab['<pad>'] ?? 0,
    unkId: vocab['<unk>'] ?? 3,
    byteFallbackIds: byteFallbackIds,
    specialContent: specialContent,
  );
}
