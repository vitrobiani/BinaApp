import '../database.dart';

/// Cloud-side chunks + embeddings for RAG. Column `embedding` is a Postgres
/// `vector(768)` (pgvector). We rarely round-trip the embedding into Dart:
/// similarity search runs server-side via the `<=>` cosine-distance operator
/// against the HNSW index, and the RPC returns matching rows only.
class MemberDocumentChunksTable
    extends SupabaseTable<MemberDocumentChunksRow> {
  @override
  String get tableName => 'member_document_chunk';

  @override
  MemberDocumentChunksRow createRow(Map<String, dynamic> data) =>
      MemberDocumentChunksRow(data);
}

class MemberDocumentChunksRow extends SupabaseDataRow {
  MemberDocumentChunksRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => MemberDocumentChunksTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  String get documentId => getField<String>('document_id')!;
  set documentId(String value) => setField<String>('document_id', value);

  int get chunkIndex => getField<int>('chunk_index')!;
  set chunkIndex(int value) => setField<int>('chunk_index', value);

  String get text => getField<String>('text')!;
  set text(String value) => setField<String>('text', value);
}
