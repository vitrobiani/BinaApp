import 'package:flutter/foundation.dart';

import '/backend/sqlite/init.dart';
import 'queries/read.dart';
import 'queries/update.dart';
import 'queries/delete.dart';

import 'package:sqflite/sqflite.dart';
export 'queries/read.dart';
export 'queries/update.dart';
export 'queries/delete.dart';

class SQLiteManager {
  SQLiteManager._();

  static SQLiteManager? _instance;
  static SQLiteManager get instance => _instance ??= SQLiteManager._();

  static late Database _database;
  Database get database => _database;

  static Future initialize() async {
    if (kIsWeb) {
      return;
    }
    _database = await initializeDatabaseFromDbFile(
      'app_data',
      'AppData.db',
    );
  }

  /// START READ QUERY CALLS

  Future<List<GetUserByEmailRow>> getUserByEmail({
    String? email,
  }) =>
      performGetUserByEmail(
        _database,
        email: email,
      );

  Future<List<LoginByEmailRow>> loginByEmail({
    String? email,
    String? passwordHash,
  }) =>
      performLoginByEmail(
        _database,
        email: email,
        passwordHash: passwordHash,
      );

  Future<List<FamilyMemberRow>> getFamilyMembersByAccountId({
    String? accountId,
  }) =>
      performGetFamilyMembersByAccountId(
        _database,
        accountId: accountId,
      );

  Future<List<ScanSessionRow>> getScanSessionsByMemberId({
    String? memberId,
  }) =>
      performGetScanSessionsByMemberId(
        _database,
        memberId: memberId,
      );

  Future<List<ScanImageRow>> getScanImagesBySessionId({
    String? sessionId,
  }) =>
      performGetScanImagesBySessionId(
        _database,
        sessionId: sessionId,
      );

  Future<List<DentalRecordRow>> getDentalRecordsByMemberId({
    String? memberId,
  }) =>
      performGetDentalRecordsByMemberId(
        _database,
        memberId: memberId,
      );

  Future<List<ChatConversationRow>> getChatConversationsByMemberId({
    String? memberId,
  }) =>
      performGetChatConversationsByMemberId(
        _database,
        memberId: memberId,
      );

  Future<List<ChatConversationRow>> getAllChatConversations () =>
      performGetAllConversations(
        _database,
      );

  Future<List<ChatMessageRow>> getChatMessagesByConversationId({
    String? conversationId,
  }) =>
      performGetChatMessagesByConversationId(
        _database,
        conversationId: conversationId,
      );

  Future<List<FamilyMemberCalibrationRow>> getCalibrationByMemberId({
    String? familyMemberId,
  }) =>
      performGetCalibrationByMemberId(
        _database,
        familyMemberId: familyMemberId,
      );

  Future<List<MemberDocumentRow>> getMemberDocumentsByMemberId({
    String? familyMemberId,
  }) =>
      performGetMemberDocumentsByMemberId(
        _database,
        familyMemberId: familyMemberId,
      );

  Future<MemberDocumentRow?> getMemberDocumentWithBlob({
    required String id,
  }) =>
      performGetMemberDocumentWithBlob(_database, id: id);

  /// END READ QUERY CALLS

  /// START UPDATE QUERY CALLS

  Future registerNewUser({
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
  }) =>
      performRegisterNewUser(
        _database,
        id: id,
        email: email,
        phoneNumber: phoneNumber,
        createdAt: createdAt,
        lastActive: lastActive,
        passwordHash: passwordHash,
        familyMemberID: familyMemberID,
        name: name,
        birthday: birthday,
        gender: gender,
        relationship: relationship,
        lastChecked: lastChecked,
      );

  Future addFamilyMember({
    String? familyMemberID,
    String? accountID,
    int? birthday,
    String? gender,
    String? relationship,
    int? lastChecked,
    String? name,
  }) =>
      performAddFamilyMember(
        _database,
        familyMemberID: familyMemberID,
        accountID: accountID,
        birthday: birthday,
        gender: gender,
        relationship: relationship,
        lastChecked: lastChecked,
        name: name,
      );

  Future updateLastChecked({
    int? lastChecked,
    String? id,
  }) =>
      performUpdateLastChecked(
        _database,
        lastChecked: lastChecked,
        id: id,
      );

  Future createScanSession({
    String? id,
    String? familyMemberId,
    int? sessionStart,
    String? status,
    String? notes,
    int? totalImagesCaptured,
  }) =>
      performCreateScanSession(
        _database,
        id: id,
        familyMemberId: familyMemberId,
        sessionStart: sessionStart,
        status: status,
        notes: notes,
        totalImagesCaptured: totalImagesCaptured,
      );

  Future createScanImage({
    String? id,
    String? scanSessionId,
    Uint8List? image,
    Uint8List? diagnosedImage,
    int? capturedAt,
    String? rawResponse,
    int? pitch,
    int? roll,
    String? estimatedRegion,
  }) =>
      performCreateScanImage(
        _database,
        id: id,
        scanSessionId: scanSessionId,
        image: image,
        diagnosedImage: diagnosedImage,
        capturedAt: capturedAt,
        rawResponse: rawResponse,
        pitch: pitch,
        roll: roll,
        estimatedRegion: estimatedRegion,
      );

  Future createDentalRecord({
    String? id,
    String? familyMemberId,
    String? scanSessionId,
    int? recordDate,
    String? findingsSnapshot,
    String? overallStatus,
  }) =>
      performCreateDentalRecord(
        _database,
        id: id,
        familyMemberId: familyMemberId,
        scanSessionId: scanSessionId,
        recordDate: recordDate,
        findingsSnapshot: findingsSnapshot,
        overallStatus: overallStatus,
      );

  Future updateScanSessionEnd({
    int? sessionEnd,
    String? status,
    int? totalImagesCaptured,
    String? id,
  }) =>
      performUpdateScanSessionEnd(
        _database,
        sessionEnd: sessionEnd,
        status: status,
        totalImagesCaptured: totalImagesCaptured,
        id: id,
      );

  Future updateScanSessionNotes({
    String? notes,
    String? id,
  }) =>
      performUpdateScanSessionNotes(
        _database,
        notes: notes,
        id: id,
      );

  Future createChatConversation({
    String? id,
    String? familyMemberId,
    String? title,
  }) =>
      performCreateNewConversation(
        _database,
        id: id,
        familyMemberId: familyMemberId,
        title: title,
        createdAt: DateTime.now().millisecondsSinceEpoch,
        lastUpdate: DateTime.now().millisecondsSinceEpoch,
      );

  Future updateConversationLastUpdate({
    int? lastUpdate,
    String? id,
  }) =>
      performUpdateConversationLastUpdate(
        _database,
        lastUpdate: lastUpdate,
        id: id,
      );

  Future updateConversationTitle({
    String? title,
    String? id,
  }) =>
      performUpdateConversationTitle(
        _database,
        title: title,
        id: id,
      );

  Future createChatMessage({
    String? id,
    String? conversationId,
    String? role,
    String? content,
  }) =>
      performCreateNewMessage(
        _database,
        id: id,
        conversationId: conversationId,
        role: role,
        content: content,
        timestamp: DateTime.now().millisecondsSinceEpoch,
      );

  Future upsertCalibration({
    String? id,
    String? familyMemberId,
    String? regionCode,
    int? avgPitch,
    int? avgRoll,
    int? sampleCount,
    int? calibratedAt,
  }) =>
      performUpsertCalibration(
        _database,
        id: id,
        familyMemberId: familyMemberId,
        regionCode: regionCode,
        avgPitch: avgPitch,
        avgRoll: avgRoll,
        sampleCount: sampleCount,
        calibratedAt: calibratedAt,
      );

  Future insertMemberDocument({
    String? id,
    String? familyMemberId,
    String? fileName,
    String? mimeType,
    int? byteSize,
    Uint8List? blob,
    String? extractedText,
    String? extractionStatus,
    int? uploadedAt,
  }) =>
      performInsertMemberDocument(
        _database,
        id: id,
        familyMemberId: familyMemberId,
        fileName: fileName,
        mimeType: mimeType,
        byteSize: byteSize,
        blob: blob,
        extractedText: extractedText,
        extractionStatus: extractionStatus,
        uploadedAt: uploadedAt,
      );

  Future<int> deleteMemberDocument({required String id}) =>
      performDeleteMemberDocument(_database, id: id);

  /// START DELETE QUERY CALLS

  /// Delete scan images by session ID
  Future<int> deleteScanImagesBySessionId({
    required String sessionId,
  }) =>
      performDeleteScanImagesBySessionId(
        _database,
        sessionId: sessionId,
      );

  /// Delete a scan session by ID
  Future<int> deleteScanSession({
    required String sessionId,
  }) =>
      performDeleteScanSession(
        _database,
        sessionId: sessionId,
      );

  /// Delete multiple scan sessions with cascade (images first, then sessions)
  Future<void> deleteScanSessionsCascade({
    required List<String> sessionIds,
  }) =>
      performDeleteScanSessionsCascade(
        _database,
        sessionIds: sessionIds,
      );

  /// END DELETE QUERY CALLS
}
