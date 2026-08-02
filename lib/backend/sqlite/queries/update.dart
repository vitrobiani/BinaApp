import 'dart:typed_data';

import 'package:sqflite/sqflite.dart';

/// BEGIN REGISTERNEWUSER
Future performRegisterNewUser(
  Database database, {
  String? id,
  String? email,
  String? phoneNumber,
  int? createdAt,
  int? lastActive,
  String? passwordHash,
  String? familyMemberID,
  String? name,
  int? birthday,
  String? gender,
  String? relationship,
  int? lastChecked,
}) async {
  // Use a batch to execute multiple statements
  final batch = database.batch();

  batch.rawInsert(
    'INSERT INTO users (id, email, phone_number, created_at, last_active, password_hash) VALUES (?, ?, ?, ?, ?, ?)',
    [id, email, phoneNumber, createdAt, lastActive, passwordHash],
  );

  batch.rawInsert(
    'INSERT INTO family_member (id, account_id, name, birthday, gender, relationship, last_checked) VALUES (?, ?, ?, ?, ?, ?, ?)',
    [familyMemberID, id, name, birthday, gender, relationship, lastChecked],
  );

  return batch.commit();
}

/// END REGISTERNEWUSER

/// BEGIN ADDFAMILYMEMBER
Future performAddFamilyMember(
  Database database, {
  String? familyMemberID,
  String? accountID,
  int? birthday,
  String? gender,
  String? relationship,
  int? lastChecked,
  String? name,
}) async {
  return database.rawInsert(
    'INSERT INTO family_member (id, account_id, name, birthday, gender, relationship, last_checked) VALUES (?, ?, ?, ?, ?, ?, ?)',
    [familyMemberID, accountID, name, birthday, gender, relationship, lastChecked],
  );
}

/// END ADDFAMILYMEMBER

/// BEGIN UPDATELASTCHECKED
Future performUpdateLastChecked(
  Database database, {
  int? lastChecked,
  String? id,
}) async {
  return database.rawUpdate(
    'UPDATE family_member SET last_checked = ? WHERE id = ?',
    [lastChecked, id],
  );
}

/// END UPDATELASTCHECKED

/// BEGIN CREATESCANSESSION
Future performCreateScanSession(
  Database database, {
  String? id,
  String? familyMemberId,
  int? sessionStart,
  String? status,
  String? notes,
  int? totalImagesCaptured,
}) async {
  return database.rawInsert(
    'INSERT INTO scan_session (id, family_member_id, session_start, status, notes, total_images_captured) VALUES (?, ?, ?, ?, ?, ?)',
    [id, familyMemberId, sessionStart, status, notes, totalImagesCaptured ?? 0],
  );
}

/// END CREATESCANSESSION

/// BEGIN CREATESCANIMAGE
Future performCreateScanImage(
  Database database, {
  String? id,
  String? scanSessionId,
  Uint8List? image,
  Uint8List? diagnosedImage,
  int? capturedAt,
  String? rawResponse,
  int? pitch,
  int? roll,
  String? estimatedRegion,
}) async {
  return database.rawInsert(
    'INSERT INTO scan_image (id, scan_session_id, image, diagnosed_image, captured_at, raw_response, pitch, roll, estimated_region) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)',
    [id, scanSessionId, image, diagnosedImage, capturedAt, rawResponse, pitch, roll, estimatedRegion],
  );
}

/// END CREATESCANIMAGE

/// BEGIN CREATEDENTALRECORD
Future performCreateDentalRecord(
  Database database, {
  String? id,
  String? familyMemberId,
  String? scanSessionId,
  int? recordDate,
  String? findingsSnapshot,
  String? overallStatus,
}) async {
  return database.rawInsert(
    'INSERT INTO dental_record (id, family_member_id, scan_session_id, record_date, findings_snapshot, overall_status) VALUES (?, ?, ?, ?, ?, ?)',
    [id, familyMemberId, scanSessionId, recordDate, findingsSnapshot, overallStatus],
  );
}

/// END CREATEDENTALRECORD

/// BEGIN UPDATESCANSESSIONEND
Future performUpdateScanSessionEnd(
  Database database, {
  int? sessionEnd,
  String? status,
  int? totalImagesCaptured,
  String? id,
}) async {
  return database.rawUpdate(
    'UPDATE scan_session SET session_end = ?, status = ?, total_images_captured = ? WHERE id = ?',
    [sessionEnd, status, totalImagesCaptured, id],
  );
}
/// END UPDATESCANSESSIONEND

/// BEGIN UPDATESCANSESSIONNOTES
Future performUpdateScanSessionNotes(
  Database database, {
  String? notes,
  String? id,
}) async {
  return database.rawUpdate(
    'UPDATE scan_session SET notes = ? WHERE id = ?',
    [notes, id],
  );
}
/// END UPDATESCANSESSIONNOTES

/// BEGIN CREATENEWCONVERSATION
Future performCreateNewConversation(
    Database database, {
      String? id,
      String? familyMemberId,
      String? title,
      int? createdAt,
      int? lastUpdate,
    }) async {
  return database.rawInsert(
    'INSERT INTO chat_conversation (id, family_member_id, title, created_at, last_updated_at) VALUES (?, ?, ?, ?, ?)',
    [id, familyMemberId, title, createdAt, lastUpdate],
  );
}

/// END CREATENEWCONVERSATION

/// BEGIN UPDATECONVERSATIONTITLE
Future performUpdateConversationTitle(
    Database database, {
      String? title,
      String? id,
    }) async {
  return database.rawUpdate(
    'UPDATE chat_conversation SET title = ? WHERE id = ?',
    [title, id],
  );
}

/// END UPDATECONVERSATIONTITLE

/// BEGIN UPDATECONVERSATIONLASTUPDATE
Future performUpdateConversationLastUpdate(
    Database database, {
      int? lastUpdate,
      String? id,
    }) async {
  return database.rawUpdate(
    'UPDATE chat_conversation SET last_updated_at = ? WHERE id = ?',
    [lastUpdate, id],
  );
}

/// END UPDATECONVERSATIONLASTUPDATE

/// BEGIN CREATENEWMESSAGE
Future performCreateNewMessage(
    Database database, {
      String? id,
      String? conversationId,
      String? role,
      String? content,
      int? timestamp,
    }) async {
  return database.rawInsert(
    'INSERT INTO chat_message (id, conversation_id, role, content, timestamp) VALUES (?, ?, ?, ?, ?)',
    [id, conversationId, role, content, timestamp],
  );
}

/// END CREATENEWMESSAGE

/// BEGIN UPSERTCALIBRATION
/// Insert or replace a calibration point for one (member, region).
/// The UNIQUE constraint on (family_member_id, region_code) ensures the
/// old row is replaced, so recalibration is idempotent.
Future performUpsertCalibration(
  Database database, {
  String? id,
  String? familyMemberId,
  String? regionCode,
  int? avgPitch,
  int? avgRoll,
  int? sampleCount,
  int? calibratedAt,
}) async {
  return database.rawInsert(
    'INSERT OR REPLACE INTO family_member_calibration (id, family_member_id, region_code, avg_pitch, avg_roll, sample_count, calibrated_at) VALUES (?, ?, ?, ?, ?, ?, ?)',
    [id, familyMemberId, regionCode, avgPitch, avgRoll, sampleCount, calibratedAt],
  );
}
/// END UPSERTCALIBRATION

/// BEGIN INSERTMEMBERDOCUMENT
Future performInsertMemberDocument(
  Database database, {
  String? id,
  String? familyMemberId,
  String? fileName,
  String? mimeType,
  int? byteSize,
  Uint8List? blob,
  String? extractedText,
  String? extractionStatus,
  int? uploadedAt,
}) async {
  return database.rawInsert(
    'INSERT INTO member_document (id, family_member_id, file_name, mime_type, byte_size, blob, extracted_text, extraction_status, uploaded_at) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)',
    [
      id,
      familyMemberId,
      fileName,
      mimeType,
      byteSize,
      blob,
      extractedText,
      extractionStatus,
      uploadedAt,
    ],
  );
}

Future<int> performDeleteMemberDocument(
  Database database, {
  required String id,
}) async {
  return database.rawDelete(
    'DELETE FROM member_document WHERE id = ?',
    [id],
  );
}
/// END INSERTMEMBERDOCUMENT