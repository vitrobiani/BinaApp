import '../database.dart';

class ScanSessionsTable extends SupabaseTable<ScanSessionsRow> {
  @override
  String get tableName => 'scan_session';

  @override
  ScanSessionsRow createRow(Map<String, dynamic> data) => ScanSessionsRow(data);
}

class ScanSessionsRow extends SupabaseDataRow {
  ScanSessionsRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => ScanSessionsTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  String get familyMemberId => getField<String>('family_member_id')!;
  set familyMemberId(String value) => setField<String>('family_member_id', value);

  DateTime? get sessionStart => getField<DateTime>('session_start');
  set sessionStart(DateTime? value) => setField<DateTime>('session_start', value);

  DateTime? get sessionEnd => getField<DateTime>('session_end');
  set sessionEnd(DateTime? value) => setField<DateTime>('session_end', value);

  String get status => getField<String>('status')!;
  set status(String value) => setField<String>('status', value);

  String? get notes => getField<String>('notes');
  set notes(String? value) => setField<String>('notes', value);

  int get totalImagesCaptured => getField<int>('total_images_captured') ?? 0;
  set totalImagesCaptured(int value) => setField<int>('total_images_captured', value);
}
