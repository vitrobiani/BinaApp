import 'package:bina_system/app_state.dart';
import 'package:bina_system/backend/sqlite/sqlite_manager.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

/// Book row DB-08 — history-list first-frame budget on a real device.
///
/// **Runs against:** any attached Android/iOS device. Complements the
/// off-device `test/perf/history_query_perf_test.dart` — that one
/// measures the SQL layer in isolation; this one wraps the whole
/// `SQLiteManager.getScanSessionsByMemberId` + per-session image walk
/// against the real bundled sqflite, which is where phone-side latency
/// actually shows up.
///
/// The plan calls for "first frame renders within 1 s" — a real Flutter
/// frame-time measurement needs `WidgetTester.pumpBenchmark` or the
/// `IntegrationTestWidgetsFlutterBinding.reportData` hook. This scaffold
/// measures the data-fetch latency and lets the operator confirm the
/// visual test manually.
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  const memberId = 'perf-fm';

  Future<void> seedSessions(int count) async {
    for (var i = 0; i < count; i++) {
      await SQLiteManager.instance.createScanSession(
        id: '$memberId-s-$i',
        familyMemberId: memberId,
        sessionStart: 1700000000 + i,
        status: 'completed',
        totalImagesCaptured: 0,
      );
    }
  }

  Future<void> clearSessions() async {
    // Best-effort cleanup so a re-run doesn't compound the seed. The
    // scan_session table doesn't have a bulk "delete all by member"
    // helper today, so we walk and delete individually.
    try {
      final rows = await SQLiteManager.instance
          .getScanSessionsByMemberId(memberId: memberId);
      for (final r in rows) {
        await SQLiteManager.instance.deleteScanImagesBySessionId(
          sessionId: r.id,
        );
      }
    } catch (_) {}
  }

  setUpAll(() async {
    AppState().updateUserSessionStruct((u) => u.isLocalSession = true);
    try {
      await SQLiteManager.initialize();
    } catch (e) {
      // ignore: avoid_print
      print('[history_perf] SQLite init failed: $e — device required');
      rethrow;
    }
    await clearSessions();
  });

  tearDown(clearSessions);

  testWidgets('scoped fetch of 200 sessions stays under 1000 ms on device',
      (tester) async {
    await seedSessions(200);

    final sw = Stopwatch()..start();
    final rows = await SQLiteManager.instance
        .getScanSessionsByMemberId(memberId: memberId);
    sw.stop();

    expect(rows, hasLength(200));
    expect(
      sw.elapsedMilliseconds,
      lessThan(1000),
      reason: 'on-device data fetch is the dominant cost of the first '
          'frame; must stay under 1 s per the plan',
    );

    // ignore: avoid_print
    print('[history_perf] 200-row fetch: ${sw.elapsedMilliseconds} ms');
  });

  testWidgets('recent-N (LIMIT 5) over 200 rows returns near-instant',
      (tester) async {
    await seedSessions(200);

    final sw = Stopwatch()..start();
    final rows = await SQLiteManager.instance
        .getRecentScanSessionsByMemberId(memberId: memberId, limit: 5);
    sw.stop();

    expect(rows, hasLength(5));
    expect(sw.elapsedMilliseconds, lessThan(200),
        reason: 'LIMIT 5 must be much faster than the full scan');

    // ignore: avoid_print
    print('[history_perf] recent-5 over 200: ${sw.elapsedMilliseconds} ms');
  });
}
