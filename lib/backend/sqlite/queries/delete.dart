import 'package:sqflite/sqflite.dart';

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
