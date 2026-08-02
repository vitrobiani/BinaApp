import '../database.dart';

class FamilyMemberCalibrationsTable
    extends SupabaseTable<FamilyMemberCalibrationsRow> {
  @override
  String get tableName => 'family_member_calibration';

  @override
  FamilyMemberCalibrationsRow createRow(Map<String, dynamic> data) =>
      FamilyMemberCalibrationsRow(data);
}

class FamilyMemberCalibrationsRow extends SupabaseDataRow {
  FamilyMemberCalibrationsRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => FamilyMemberCalibrationsTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  String get familyMemberId => getField<String>('family_member_id')!;
  set familyMemberId(String value) =>
      setField<String>('family_member_id', value);

  String get regionCode => getField<String>('region_code')!;
  set regionCode(String value) => setField<String>('region_code', value);

  int? get avgPitch => getField<int>('avg_pitch');
  set avgPitch(int? value) => setField<int>('avg_pitch', value);

  int? get avgRoll => getField<int>('avg_roll');
  set avgRoll(int? value) => setField<int>('avg_roll', value);

  int? get sampleCount => getField<int>('sample_count');
  set sampleCount(int? value) => setField<int>('sample_count', value);

  DateTime? get calibratedAt => getField<DateTime>('calibrated_at');
  set calibratedAt(DateTime? value) =>
      setField<DateTime>('calibrated_at', value);
}
