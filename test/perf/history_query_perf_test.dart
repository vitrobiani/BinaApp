import 'package:bina_system/backend/sqlite/sqlite_manager.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/sqlite_test_db.dart';

void main() {
  setUpAll(initFfiSqlite);

  const _budget1 = Duration(milliseconds: 50);
  const _budget20 = Duration(milliseconds: 100);
  const _budget200 = Duration(milliseconds: 500);

  Future<void> seedSessions(int count, String memberId) async {
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

  setUp(() async {
    final db = await openMigratedSqlite();
    SQLiteManager.setDatabaseForTesting(db);
  });

  test('1 session — query returns within ${_budget1.inMilliseconds} ms',
      () async {
    await seedSessions(1, 'fm-1');
    final sw = Stopwatch()..start();
    final rows = await SQLiteManager.instance
        .getScanSessionsByMemberId(memberId: 'fm-1');
    sw.stop();
    expect(rows, hasLength(1));
    expect(
      sw.elapsed,
      lessThan(_budget1),
      reason: 'trivial single-row query should be near-instant; got '
          '${sw.elapsedMicroseconds} µs',
    );
  });

  test('20 sessions — query returns within ${_budget20.inMilliseconds} ms',
      () async {
    await seedSessions(20, 'fm-1');
    final sw = Stopwatch()..start();
    final rows = await SQLiteManager.instance
        .getScanSessionsByMemberId(memberId: 'fm-1');
    sw.stop();
    expect(rows, hasLength(20));
    expect(
      sw.elapsed,
      lessThan(_budget20),
      reason: '20 rows should stay comfortably inside a UI frame budget; '
          'got ${sw.elapsedMilliseconds} ms',
    );
  });

  test('200 sessions — query returns within ${_budget200.inMilliseconds} ms',
      () async {
    await seedSessions(200, 'fm-1');
    final sw = Stopwatch()..start();
    final rows = await SQLiteManager.instance
        .getScanSessionsByMemberId(memberId: 'fm-1');
    sw.stop();
    expect(rows, hasLength(200));
    expect(
      sw.elapsed,
      lessThan(_budget200),
      reason: '200 rows is the realistic long-tail — must stay under '
          '${_budget200.inMilliseconds} ms; got ${sw.elapsedMilliseconds} ms',
    );
  });

  test('scoped queries do NOT scan the whole table', () async {
    await seedSessions(100, 'fm-a');
    await seedSessions(100, 'fm-b');

    final sw = Stopwatch()..start();
    final rows = await SQLiteManager.instance
        .getScanSessionsByMemberId(memberId: 'fm-a');
    sw.stop();

    expect(rows, hasLength(100));
    expect(
      sw.elapsed,
      lessThan(_budget200),
      reason: 'scoped query on 200-total-row DB must stay bounded; '
          'got ${sw.elapsedMilliseconds} ms',
    );
  });

  test('recent-N query (LIMIT clause) does not degrade with total rows',
      () async {
    await seedSessions(200, 'fm-1');
    final sw = Stopwatch()..start();
    final rows = await SQLiteManager.instance
        .getRecentScanSessionsByMemberId(memberId: 'fm-1', limit: 5);
    sw.stop();
    expect(rows, hasLength(5));
    expect(
      sw.elapsed,
      lessThan(_budget20),
      reason: 'LIMIT 5 over 200 rows must be near-instant; got '
          '${sw.elapsedMilliseconds} ms',
    );
  });
}
