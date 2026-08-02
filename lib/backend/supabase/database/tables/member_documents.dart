import '../database.dart';

class MemberDocumentsTable extends SupabaseTable<MemberDocumentsRow> {
  @override
  String get tableName => 'member_document';

  @override
  MemberDocumentsRow createRow(Map<String, dynamic> data) =>
      MemberDocumentsRow(data);
}

class MemberDocumentsRow extends SupabaseDataRow {
  MemberDocumentsRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => MemberDocumentsTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  String get familyMemberId => getField<String>('family_member_id')!;
  set familyMemberId(String value) =>
      setField<String>('family_member_id', value);

  String get fileName => getField<String>('file_name')!;
  set fileName(String value) => setField<String>('file_name', value);

  String? get mimeType => getField<String>('mime_type');
  set mimeType(String? value) => setField<String>('mime_type', value);

  int? get byteSize => getField<int>('byte_size');
  set byteSize(int? value) => setField<int>('byte_size', value);

  // Path within the `member-documents` Supabase Storage bucket. The bytes
  // themselves live there, not in this row.
  String? get storagePath => getField<String>('storage_path');
  set storagePath(String? value) => setField<String>('storage_path', value);

  String? get extractedText => getField<String>('extracted_text');
  set extractedText(String? value) =>
      setField<String>('extracted_text', value);

  String? get extractionStatus => getField<String>('extraction_status');
  set extractionStatus(String? value) =>
      setField<String>('extraction_status', value);

  DateTime? get uploadedAt => getField<DateTime>('uploaded_at');
  set uploadedAt(DateTime? value) =>
      setField<DateTime>('uploaded_at', value);
}
