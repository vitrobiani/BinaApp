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

/// BEGIN GETRECENTSCANSESSIONSBYMEMBERID
Future<List<ScanSessionRow>> performGetRecentScanSessionsByMemberId(
  Database database, {
  String? memberId,
  int limit = 5,
}) async {
  final result = await database.rawQuery(
    'SELECT id, family_member_id, session_start, session_end, status, notes, total_images_captured FROM scan_session WHERE family_member_id = ? ORDER BY session_start DESC LIMIT ?',
    [memberId, limit],
  );
  return result.map((d) => ScanSessionRow(d)).toList();
}
/// END GETRECENTSCANSESSIONSBYMEMBERID

/// BEGIN GETSCANIMAGESBYSESSIONID
Future<List<ScanImageRow>> performGetScanImagesBySessionId(
  Database database, {
  String? sessionId,
}) async {
  final result = await database.rawQuery(
    'SELECT id, scan_session_id, image, diagnosed_image, captured_at, raw_response, pitch, roll, estimated_region FROM scan_image WHERE scan_session_id = ? ORDER BY captured_at ASC',
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
  int? get pitch => data['pitch'] as int?;
  int? get roll => data['roll'] as int?;
  String? get estimatedRegion => data['estimated_region'] as String?;
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

/// BEGIN GETCALIBRATIONBYMEMBERID
Future<List<FamilyMemberCalibrationRow>> performGetCalibrationByMemberId(
  Database database, {
  String? familyMemberId,
}) async {
  final result = await database.rawQuery(
    'SELECT id, family_member_id, region_code, avg_pitch, avg_roll, sample_count, calibrated_at FROM family_member_calibration WHERE family_member_id = ?',
    [familyMemberId],
  );
  return result.map((d) => FamilyMemberCalibrationRow(d)).toList();
}

class FamilyMemberCalibrationRow extends SqliteRow {
  FamilyMemberCalibrationRow(Map<String, dynamic> data) : super(data);

  String get id => data['id'] as String;
  String get familyMemberId => data['family_member_id'] as String;
  String get regionCode => data['region_code'] as String;
  int? get avgPitch => data['avg_pitch'] as int?;
  int? get avgRoll => data['avg_roll'] as int?;
  int? get sampleCount => data['sample_count'] as int?;
  int? get calibratedAt => data['calibrated_at'] as int?;
}
/// END GETCALIBRATIONBYMEMBERID

/// BEGIN GETMEMBERDOCUMENTSBYMEMBERID
Future<List<MemberDocumentRow>> performGetMemberDocumentsByMemberId(
  Database database, {
  String? familyMemberId,
}) async {
  final result = await database.rawQuery(
    'SELECT id, family_member_id, file_name, mime_type, byte_size, extracted_text, extraction_status, uploaded_at FROM member_document WHERE family_member_id = ? ORDER BY uploaded_at DESC',
    [familyMemberId],
  );
  return result.map((d) => MemberDocumentRow(d)).toList();
}

/// Fetch a single document row including its blob. Kept separate from the
/// list query so we only pay the memory cost when actually previewing.
Future<MemberDocumentRow?> performGetMemberDocumentWithBlob(
  Database database, {
  required String id,
}) async {
  final result = await database.rawQuery(
    'SELECT id, family_member_id, file_name, mime_type, byte_size, blob, extracted_text, extraction_status, uploaded_at FROM member_document WHERE id = ? LIMIT 1',
    [id],
  );
  if (result.isEmpty) return null;
  return MemberDocumentRow(result.first);
}

class MemberDocumentRow extends SqliteRow {
  MemberDocumentRow(Map<String, dynamic> data) : super(data);

  String get id => data['id'] as String;
  String get familyMemberId => data['family_member_id'] as String;
  String get fileName => data['file_name'] as String;
  String? get mimeType => data['mime_type'] as String?;
  int? get byteSize => data['byte_size'] as int?;
  List<int>? get blob => data['blob'] as List<int>?;
  String? get extractedText => data['extracted_text'] as String?;
  String? get extractionStatus => data['extraction_status'] as String?;
  int? get uploadedAt => data['uploaded_at'] as int?;
}
/// END GETMEMBERDOCUMENTSBYMEMBERID

/// BEGIN GETDOCUMENTCHUNKSBYMEMBERID
/// Fetch every chunk belonging to every doc attached to this member, with
/// the raw embedding bytes. One JOIN keeps it a single round-trip on the
/// hot path (retrieval runs on every user message).
Future<List<MemberDocumentChunkRow>> performGetChunksByMemberId(
  Database database, {
  required String familyMemberId,
}) async {
  final result = await database.rawQuery(
    'SELECT c.id, c.document_id, c.chunk_index, c.text, c.embedding, d.file_name '
    'FROM member_document_chunk c '
    'INNER JOIN member_document d ON d.id = c.document_id '
    'WHERE d.family_member_id = ? '
    'ORDER BY c.document_id, c.chunk_index',
    [familyMemberId],
  );
  return result.map((d) => MemberDocumentChunkRow(d)).toList();
}

class MemberDocumentChunkRow extends SqliteRow {
  MemberDocumentChunkRow(Map<String, dynamic> data) : super(data);

  String get id => data['id'] as String;
  String get documentId => data['document_id'] as String;
  int get chunkIndex => data['chunk_index'] as int;
  String get text => data['text'] as String;
  List<int> get embedding => data['embedding'] as List<int>;
  String? get fileName => data['file_name'] as String?;
}
/// END GETDOCUMENTCHUNKSBYMEMBERID