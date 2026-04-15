import '../database.dart';

class FamilyMembersTable extends SupabaseTable<FamilyMembersRow> {
  @override
  String get tableName => 'family_members';

  @override
  FamilyMembersRow createRow(Map<String, dynamic> data) =>
      FamilyMembersRow(data);
}

class FamilyMembersRow extends SupabaseDataRow {
  FamilyMembersRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => FamilyMembersTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  String get accountId => getField<String>('account_id')!;
  set accountId(String value) => setField<String>('account_id', value);

  String? get name => getField<String>('name');
  set name(String? value) => setField<String>('name', value);

  DateTime? get birthday => getField<DateTime>('birthday');
  set birthday(DateTime? value) => setField<DateTime>('birthday', value);

  String? get gender => getField<String>('gender');
  set gender(String? value) => setField<String>('gender', value);

  String? get relationship => getField<String>('relationship');
  set relationship(String? value) => setField<String>('relationship', value);

  DateTime? get lastChecked => getField<DateTime>('last_checked');
  set lastChecked(DateTime? value) => setField<DateTime>('last_checked', value);

  double? get score => getField<double>('score');
  set score(double? value) => setField<double>('score', value);

  bool? get admin => getField<bool>('admin');
  set admin(bool? value) => setField<bool>('admin', value);
}
