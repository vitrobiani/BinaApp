import '/backend/sqlite/queries/sqlite_row.dart';
import 'package:sqflite/sqflite.dart';

/// BEGIN GETUSERBYEMAIL
Future<List<GetUserByEmailRow>> performGetUserByEmail(
  Database database, {
  String? email,
}) async {
  final result = await database.rawQuery(
    'SELECT id, email, phone_number, created_at, last_active, password_hash FROM users WHERE LOWER(email) = LOWER(?) LIMIT 1',
    [email],
  );
  return result.map((d) => GetUserByEmailRow(d)).toList();
}

class GetUserByEmailRow extends SqliteRow {
  GetUserByEmailRow(Map<String, dynamic> data) : super(data);

  String get id => data['id'] as String;
  String get email => data['email'] as String;
  String? get phoneNumber => data['phone_number'] as String?;
  int get createdAt => data['created_at'] as int;
  int? get lastActive => data['last_active'] as int?;
  String get passwordHash => data['password_hash'] as String;
}

/// END GETUSERBYEMAIL

/// BEGIN LOGINBYEMAIL
Future<List<LoginByEmailRow>> performLoginByEmail(
  Database database, {
  String? email,
  String? passwordHash,
}) async {
  final result = await database.rawQuery(
    'SELECT id, email, phone_number, created_at, last_active FROM users WHERE LOWER(email) = LOWER(?) AND password_hash = ? LIMIT 1',
    [email, passwordHash],
  );
  return result.map((d) => LoginByEmailRow(d)).toList();
}

class LoginByEmailRow extends SqliteRow {
  LoginByEmailRow(Map<String, dynamic> data) : super(data);

  String get id => data['id'] as String;
  String get email => data['email'] as String;
  String? get phoneNumber => data['phone_number'] as String?;
  int get createdAt => data['created_at'] as int;
  int? get lastActive => data['last_active'] as int?;
}

/// END LOGINBYEMAIL

/// BEGIN GETFAMILYMEMBERSBYACCOUNTID
Future<List<FamilyMemberRow>> performGetFamilyMembersByAccountId(
  Database database, {
  String? accountId,
}) async {
  final result = await database.rawQuery(
    'SELECT id, account_id, name, birthday, gender, relationship, last_checked FROM family_member WHERE account_id = ?',
    [accountId],
  );
  return result.map((d) => FamilyMemberRow(d)).toList();
}



class FamilyMemberRow extends SqliteRow {
  FamilyMemberRow(Map<String, dynamic> data) : super(data);

  String get id => data['id'] as String;
  String get accountId => data['account_id'] as String;
  String? get name => data['name'] as String?;
  int? get birthday => data['birthday'] as int?;
  String? get gender => data['gender'] as String?;
  String? get relationship => data['relationship'] as String?;
  int? get lastChecked => data['last_checked'] as int?;
}

/// END GETFAMILYMEMBERSBYACCOUNTID

/// BEGIN GETSCANSESSIONSBYMEMBERID
Future<List<ScanSessionRow>> performGetScanSessionsByMemberId(
  Database database, {
  String? memberId,
}) async {
  final result = await database.rawQuery(
    'SELECT id, family_member_id, session_start, session_end, status, notes, total_images_captured FROM scan_session WHERE family_member_id = ? ORDER BY session_start DESC',
    [memberId],
  );
  return result.map((d) => ScanSessionRow(d)).toList();
}

class ScanSessionRow extends SqliteRow {
  ScanSessionRow(Map<String, dynamic> data) : super(data);

  String get id => data['id'] as String;
  String get familyMemberId => data['family_member_id'] as String;
  int? get sessionStart => data['session_start'] as int?;
  int? get sessionEnd => data['session_end'] as int?;
  String get status => data['status'] as String;
  String? get notes => data['notes'] as String?;
  int get totalImagesCaptured => data['total_images_captured'] as int? ?? 0;
}

/// END GETSCANSESSIONSBYMEMBERID

/// BEGIN GETSCANIMAGESBYSESSIONID
Future<List<ScanImageRow>> performGetScanImagesBySessionId(
  Database database, {
  String? sessionId,
}) async {
  final result = await database.rawQuery(
    'SELECT id, scan_session_id, image, diagnosed_image, captured_at, raw_response FROM scan_image WHERE scan_session_id = ? ORDER BY captured_at ASC',
    [sessionId],
  );
  return result.map((d) => ScanImageRow(d)).toList();
}

class ScanImageRow extends SqliteRow {
  ScanImageRow(Map<String, dynamic> data) : super(data);

  String get id => data['id'] as String;
  String get scanSessionId => data['scan_session_id'] as String;
  List<int>? get image => data['image'] as List<int>?;
  List<int>? get diagnosedImage => data['diagnosed_image'] as List<int>?;
  int? get capturedAt => data['captured_at'] as int?;
  String? get rawResponse => data['raw_response'] as String?;
}

/// END GETSCANIMAGESBYSESSIONID

/// BEGIN GETDENTALRECORDSBYMEMBERID
Future<List<DentalRecordRow>> performGetDentalRecordsByMemberId(
  Database database, {
  String? memberId,
}) async {
  final result = await database.rawQuery(
    'SELECT id, family_member_id, scan_session_id, record_date, findings_snapshot, overall_status FROM dental_record WHERE family_member_id = ? ORDER BY record_date DESC',
    [memberId],
  );
  return result.map((d) => DentalRecordRow(d)).toList();
}

class DentalRecordRow extends SqliteRow {
  DentalRecordRow(Map<String, dynamic> data) : super(data);

  String get id => data['id'] as String;
  String? get familyMemberId => data['family_member_id'] as String?;
  String? get scanSessionId => data['scan_session_id'] as String?;
  int? get recordDate => data['record_date'] as int?;
  String? get findingsSnapshot => data['findings_snapshot'] as String?;
  String get overallStatus => data['overall_status'] as String? ?? 'unknown';
}

/// END GETDENTALRECORDSBYMEMBERID

/// BEGIN GETCHATCONVERSATIONSBYMEMBERID & GETALLCONVERSATIONS
Future<List<ChatConversationRow>> performGetChatConversationsByMemberId(
  Database database, {
  String? memberId,
}) async {
  final result = await database.rawQuery(
    'SELECT id, family_member_id, title, created_at, last_updated_at FROM chat_conversation WHERE family_member_id = ? ORDER BY last_updated_at DESC',
    [memberId],
  );
  return result.map((d) => ChatConversationRow(d)).toList();
}

Future<List<ChatConversationRow>> performGetAllConversations(
  Database database,
) async {
  final result = await database.rawQuery(
    'SELECT id, family_member_id, title, created_at, last_updated_at FROM chat_conversation ORDER BY last_updated_at DESC',
  );
  return result.map((d) => ChatConversationRow(d)).toList();
}

class ChatConversationRow extends SqliteRow {
  ChatConversationRow(Map<String, dynamic> data) : super(data);

  String get id => data['id'] as String;
  String get familyMemberId => data['family_member_id'] as String;
  String get title => data['title'] as String;
  int? get createdAt => data['created_at'] as int?;
  int? get lastUpdatedAt => data['last_updated_at'] as int?;
}
/// END GETCHATCONVERSATIONSBYMEMBERID & GETALLCONVERSATIONS

/// BEGIN GETCHATMESSAGESBYCONVERSATIONID
Future<List<ChatMessageRow>> performGetChatMessagesByConversationId(
  Database database, {
  String? conversationId,
}) async {
  final result = await database.rawQuery(
    'SELECT id, conversation_id, role, content, timestamp FROM chat_message WHERE conversation_id = ? ORDER BY timestamp ASC',
    [conversationId],
  );
  return result.map((d) => ChatMessageRow(d)).toList();
}

class ChatMessageRow extends SqliteRow {
  ChatMessageRow(Map<String, dynamic> data) : super(data);

  String get id => data['id'] as String;
  String get conversationId => data['conversation_id'] as String;
  String get role => data['role'] as String;
  String get content => data['content'] as String;
  int? get timestamp => data['timestamp'] as int?;
}

/// END GETCHATMESSAGESBYCONVERSATIONID