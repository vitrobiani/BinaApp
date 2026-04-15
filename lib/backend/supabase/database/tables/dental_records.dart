import '../database.dart';

class DentalRecordsTable extends SupabaseTable<DentalRecordsRow> {
  @override
  String get tableName => 'dental_record';

  @override
  DentalRecordsRow createRow(Map<String, dynamic> data) => DentalRecordsRow(data);
}

class DentalRecordsRow extends SupabaseDataRow {
  DentalRecordsRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => DentalRecordsTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  String? get familyMemberId => getField<String>('family_member_id');
  set familyMemberId(String? value) => setField<String>('family_member_id', value);

  String? get scanSessionId => getField<String>('scan_session_id');
  set scanSessionId(String? value) => setField<String>('scan_session_id', value);

  DateTime? get recordDate => getField<DateTime>('record_date');
  set recordDate(DateTime? value) => setField<DateTime>('record_date', value);

  String? get findingsSnapshot => getField<String>('findings_snapshot');
  set findingsSnapshot(String? value) => setField<String>('findings_snapshot', value);

  String get overallStatus => getField<String>('overall_status') ?? 'unknown';
  set overallStatus(String value) => setField<String>('overall_status', value);
}
