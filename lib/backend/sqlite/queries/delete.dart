import 'package:sqflite/sqflite.dart';

/// Delete family member by member id
Future<int> performDeleteFamilyMemberByMemberId(
  Database database, {
    required String memberId,
}) async {
  return database.rawDelete(
    'DELETE FROM family_member WHERE id = ?',
    [memberId],
  );
}

/// Delete scan images by session ID
Future<int> performDeleteScanImagesBySessionId(
  Database database, {
  required String sessionId,
}) async {
  return database.rawDelete(
    'DELETE FROM scan_image WHERE scan_session_id = ?',
    [sessionId],
  );
}

/// Delete a scan session by ID
Future<int> performDeleteScanSession(
  Database database, {
  required String sessionId,
}) async {
  return database.rawDelete(
    'DELETE FROM scan_session WHERE id = ?',
    [sessionId],
  );
}

/// Delete multiple scan sessions with cascade (images first, then sessions)
Future<void> performDeleteScanSessionsCascade(
  Database database, {
  required List<String> sessionIds,
}) async {
  if (sessionIds.isEmpty) return;

  final batch = database.batch();
  for (final sessionId in sessionIds) {
    batch.rawDelete(
      'DELETE FROM scan_image WHERE scan_session_id = ?',
      [sessionId],
    );
    batch.rawDelete(
      'DELETE FROM scan_session WHERE id = ?',
      [sessionId],
    );
  }
  await batch.commit(noResult: true);
}

/// Delete chat messages by conversation ID
Future<int> performDeleteChatMessagesByConversationId(
  Database database, {
  required String conversationId,
}) async {
  return database.rawDelete(
    'DELETE FROM chat_message WHERE conversation_id = ?',
    [conversationId],
  );
}

/// Delete a chat conversation by ID
Future<int> performDeleteChatConversation(
  Database database, {
  required String conversationId,
}) async {
  return database.rawDelete(
    'DELETE FROM chat_conversation WHERE id = ?',
    [conversationId],
  );
}

/// Delete a chat conversation with cascade (messages first, then conversation)
Future<void> performDeleteChatConversationCascade(
  Database database, {
  required String conversationId,
}) async {
  final batch = database.batch();
  batch.rawDelete(
    'DELETE FROM chat_message WHERE conversation_id = ?',
    [conversationId],
  );
  batch.rawDelete(
    'DELETE FROM chat_conversation WHERE id = ?',
    [conversationId],
  );
  await batch.commit(noResult: true);
}
