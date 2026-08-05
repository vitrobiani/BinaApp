import 'package:bina_system/backend/sqlite/init.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/sqlite_test_db.dart';

void main() {
  setUpAll(initFfiSqlite);

  group('runMigrations — legacy DB (only users + family_member)', () {
    test('creates every expected table', () async {
      final db = await openLegacySqlite();
      await runMigrations(db);

      final tables = await tableNames(db);
      expect(
        tables,
        containsAll([
          'users',
          'family_member',
          'member_document',
          'scan_session',
          'scan_image',
          'family_member_calibration',
          'dental_record',
          'member_document_chunk',
        ]),
      );
      await db.close();
    });

    test('scan_image gains pitch, roll, estimated_region columns', () async {
      final db = await openLegacySqlite();
      await runMigrations(db);
      final cols = await columnNames(db, 'scan_image');
      expect(cols, containsAll(['pitch', 'roll', 'estimated_region']));
      await db.close();
    });

    test('member_document_chunk has an index on document_id', () async {
      final db = await openLegacySqlite();
      await runMigrations(db);
      final indexes = await db.rawQuery(
        "SELECT name FROM sqlite_master WHERE type = 'index' AND tbl_name = 'member_document_chunk'",
      );
      expect(
        indexes.map((r) => r['name']),
        contains('idx_chunk_doc'),
      );
      await db.close();
    });
  });

  group('runMigrations — pre-gyro DB (has scan_image without pitch/roll)', () {
    test('preserves existing rows through ALTER', () async {
      final db = await openPreGyroSqlite();
      // Seed a row using the OLD schema.
      await db.insert('scan_image', {
        'id': 'si-1',
        'scan_session_id': 'ss-1',
        'raw_response': '{"detections":[]}',
      });

      await runMigrations(db);

      // Row is still there with its original data.
      final rows = await db.query(
        'scan_image',
        where: 'id = ?',
        whereArgs: ['si-1'],
      );
      expect(rows, hasLength(1));
      expect(rows.first['raw_response'], equals('{"detections":[]}'));
      // And the new columns exist and are NULL for the pre-existing row.
      expect(rows.first['pitch'], isNull);
      expect(rows.first['roll'], isNull);
      expect(rows.first['estimated_region'], isNull);
      await db.close();
    });

    test('new inserts can use the new columns', () async {
      final db = await openPreGyroSqlite();
      await runMigrations(db);

      await db.insert('scan_image', {
        'id': 'si-2',
        'scan_session_id': 'ss-1',
        'pitch': -15,
        'roll': 42,
        'estimated_region': 'upper_left',
      });

      final row = (await db.query('scan_image')).single;
      expect(row['pitch'], equals(-15));
      expect(row['roll'], equals(42));
      expect(row['estimated_region'], equals('upper_left'));
      await db.close();
    });
  });

  group('runMigrations — idempotency', () {
    test('running twice produces the same schema and no errors', () async {
      final db = await openLegacySqlite();
      await runMigrations(db);
      final tablesAfterFirst = await tableNames(db);
      final scanImageColsAfterFirst = await columnNames(db, 'scan_image');

      // Second run must not throw — ALTERs are wrapped in try/catch, tables
      // use IF NOT EXISTS. If any of that regresses, this test lights up.
      await runMigrations(db);

      expect(await tableNames(db), equals(tablesAfterFirst));
      expect(await columnNames(db, 'scan_image'), equals(scanImageColsAfterFirst));
      await db.close();
    });

    test('running against already-modern DB is a no-op', () async {
      // Simulates the bundled AppData.db case — every table already exists.
      final db = await openLegacySqlite();
      // First run "installs" everything…
      await runMigrations(db);
      final tablesBefore = await tableNames(db);
      final scanImageColsBefore = await columnNames(db, 'scan_image');

      // …second run must observe no schema changes.
      await runMigrations(db);
      expect(await tableNames(db), equals(tablesBefore));
      expect(await columnNames(db, 'scan_image'), equals(scanImageColsBefore));
      await db.close();
    });
  });

  group('runMigrations — table structure sanity', () {
    late final columns = <String, Set<String>>{};

    setUpAll(() async {
      final db = await openLegacySqlite();
      await runMigrations(db);
      for (final t in const [
        'member_document',
        'family_member_calibration',
        'dental_record',
        'member_document_chunk',
      ]) {
        columns[t] = await columnNames(db, t);
      }
      await db.close();
    });

    test('member_document has the columns AppState.saveMemberDocument writes', () {
      expect(
        columns['member_document'],
        containsAll([
          'id',
          'family_member_id',
          'file_name',
          'mime_type',
          'byte_size',
          'blob',
          'extracted_text',
          'extraction_status',
          'uploaded_at',
        ]),
      );
    });

    test('family_member_calibration has UNIQUE (family_member_id, region_code)',
        () async {
      final db = await openLegacySqlite();
      await runMigrations(db);
      // Insert one row…
      await db.insert('family_member_calibration', {
        'id': 'cal-1',
        'family_member_id': 'fm-1',
        'region_code': 'upper_front',
        'avg_pitch': 10,
        'avg_roll': 5,
        'sample_count': 3,
        'calibrated_at': DateTime.now().millisecondsSinceEpoch,
      });
      // …a second insert with the same (member, region) must fail.
      expect(
        () => db.insert('family_member_calibration', {
          'id': 'cal-2',
          'family_member_id': 'fm-1',
          'region_code': 'upper_front',
          'avg_pitch': 20,
          'avg_roll': 15,
          'sample_count': 5,
          'calibrated_at': DateTime.now().millisecondsSinceEpoch,
        }),
        throwsA(anything),
      );
      await db.close();
    });

    test('member_document_chunk has embedding blob and chunk_index', () {
      expect(
        columns['member_document_chunk'],
        containsAll([
          'id',
          'document_id',
          'chunk_index',
          'text',
          'embedding',
        ]),
      );
    });
  });
}
