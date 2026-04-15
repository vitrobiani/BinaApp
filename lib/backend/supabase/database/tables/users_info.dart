import '../database.dart';

class UsersInfoTable extends SupabaseTable<UsersInfoRow> {
  @override
  String get tableName => 'users_info';

  @override
  UsersInfoRow createRow(Map<String, dynamic> data) => UsersInfoRow(data);
}

class UsersInfoRow extends SupabaseDataRow {
  UsersInfoRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => UsersInfoTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  DateTime get createdAt => getField<DateTime>('created_at')!;
  set createdAt(DateTime value) => setField<DateTime>('created_at', value);

  String? get name => getField<String>('name');
  set name(String? value) => setField<String>('name', value);

  DateTime? get lastSignIn => getField<DateTime>('last_sign_in');
  set lastSignIn(DateTime? value) => setField<DateTime>('last_sign_in', value);
}
