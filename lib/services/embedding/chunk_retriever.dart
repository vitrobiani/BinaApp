import 'package:flutter/foundation.dart';

import '/app_state.dart';
import '/backend/sqlite/sqlite_manager.dart';
import '/backend/supabase/database/database.dart';
import '../embedding_service.dart';

/// One chunk returned by [ChunkRetriever]. Carries the source file name so
/// injected passages can be labelled in the prompt and, later, cited in the
/// assistant's answer.
class RetrievedChunk {
  final String documentId;
  final String? fileName;
  final int chunkIndex;
  final String text;
  final double score; // cosine similarity in [-1, 1]
  const RetrievedChunk({
    required this.documentId,
    required this.fileName,
    required this.chunkIndex,
    required this.text,
    required this.score,
  });
}

/// Nearest-neighbour search over per-member document chunks.
///
/// Local backend: fetch every chunk for the member, decode each 3072-byte
/// blob into a Float32List, cosine-sort. At the volumes we expect (~tens to
/// low hundreds of chunks per member) a linear scan comfortably beats the
/// setup cost of a real ANN index.
///
/// Cloud backend: pgvector `<=>` operator against the HNSW index, executed
/// server-side via a stored function `match_document_chunks(...)` — the
/// query embedding never leaves the query, matching rows come back only.
class ChunkRetriever {
  ChunkRetriever._();
  static final ChunkRetriever instance = ChunkRetriever._();

  static const int defaultTopK = 4;

  /// Retrieve the top-[k] most relevant chunks for [userQuery] scoped to the
  /// documents attached to [familyMemberId]. Returns an empty list on any
  /// failure — the caller degrades gracefully by omitting the passage block.
  Future<List<RetrievedChunk>> retrieveTopK({
    required String familyMemberId,
    required String userQuery,
    int k = defaultTopK,
  }) async {
    if (familyMemberId.isEmpty || userQuery.trim().isEmpty) {
      debugPrint('[Retriever] skipped — empty memberId or query');
      return const [];
    }

    try {
      await EmbeddingService.instance.init();
    } catch (e) {
      debugPrint('[Retriever] embedder unavailable: $e');
      return const [];
    }

    final queryVec = await EmbeddingService.instance.embedQuery(userQuery);
    if (queryVec == null) {
      debugPrint('[Retriever] embedQuery returned null');
      return const [];
    }

    if (AppState().UserSession.isLocalSession) {
      return _retrieveLocal(familyMemberId, queryVec, k);
    }
    return _retrieveCloud(familyMemberId, queryVec, k);
  }

  Future<List<RetrievedChunk>> _retrieveLocal(
    String familyMemberId,
    Float32List queryVec,
    int k,
  ) async {
    final rows = await SQLiteManager.instance
        .getChunksByMemberId(familyMemberId: familyMemberId);
    if (rows.isEmpty) return const [];

    final scored = <RetrievedChunk>[];
    for (final r in rows) {
      final chunkVec = _decodeEmbedding(r.embedding);
      if (chunkVec.length != queryVec.length) continue;
      final score = _cosine(queryVec, chunkVec);
      scored.add(RetrievedChunk(
        documentId: r.documentId,
        fileName: r.fileName,
        chunkIndex: r.chunkIndex,
        text: r.text,
        score: score,
      ));
    }
    scored.sort((a, b) => b.score.compareTo(a.score));
    final top = scored.take(k).toList();
    debugPrint('[Retriever] scanned ${rows.length} chunks, top=${top.length} '
        'best=${top.isEmpty ? "-" : top.first.score.toStringAsFixed(3)}');
    return top;
  }

  Future<List<RetrievedChunk>> _retrieveCloud(
    String familyMemberId,
    Float32List queryVec,
    int k,
  ) async {
    // The Postgres function does the heavy lifting server-side; see the
    // "Amendment — RAG upgrade" section of docs/plans/w1_member_documents.md
    // for the definition to install.
    try {
      final resp = await SupaFlow.client.rpc(
        'match_document_chunks',
        params: {
          'p_family_member_id': familyMemberId,
          'p_query': AppState.pgvectorLiteral(queryVec),
          'p_top_k': k,
        },
      );
      if (resp is! List) return const [];
      final out = <RetrievedChunk>[];
      for (final r in resp) {
        if (r is! Map) continue;
        out.add(RetrievedChunk(
          documentId: r['document_id'] as String? ?? '',
          fileName: r['file_name'] as String?,
          chunkIndex: (r['chunk_index'] as num?)?.toInt() ?? 0,
          text: r['text'] as String? ?? '',
          score: 1.0 - ((r['distance'] as num?)?.toDouble() ?? 1.0),
        ));
      }
      return out;
    } catch (e) {
      debugPrint('[Retriever] cloud RPC failed: $e');
      return const [];
    }
  }

  static Float32List _decodeEmbedding(List<int> raw) {
    // sqflite gives blobs back as a Uint8List view onto a shared ByteBuffer,
    // and that view's `offsetInBytes` is *not* guaranteed to be a multiple
    // of 4 — asFloat32List() then throws "Offset must be a multiple of
    // BYTES_PER_ELEMENT". Copy into a fresh backing buffer (offset 0) so
    // the reinterpret always succeeds.
    final source = raw is Uint8List ? raw : Uint8List.fromList(raw);
    final aligned = Uint8List(source.length)..setAll(0, source);
    return aligned.buffer.asFloat32List(0, aligned.length ~/ 4);
  }

  static double _cosine(Float32List a, Float32List b) {
    // Both vectors are L2-normalised by EmbeddingService so a dot product IS
    // the cosine similarity — no division needed.
    double sum = 0;
    for (var i = 0; i < a.length; i++) {
      sum += a[i] * b[i];
    }
    return sum;
  }
}
