import 'dart:typed_data';

import 'package:bina_system/app_constants.dart';
import 'package:bina_system/app_state.dart';
import 'package:bina_system/backend/sqlite/sqlite_manager.dart';
import 'package:bina_system/services/mouth_region_estimator.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/fake_secure_storage.dart';
import '../../helpers/sqlite_test_db.dart';

void main() {
  setUpAll(initFfiSqlite);

  setUp(() async {
    AppState.reset();
    installFakeSecureStorage();
    await AppState().initializePersistedState();
    AppState().updateUserSessionStruct((u) => u.isLocalSession = true);

    final db = await openMigratedSqlite();
    SQLiteManager.setDatabaseForTesting(db);
  });

  tearDown(uninstallFakeSecureStorage);

  group('loadMemberCalibration (local)', () {
    test('null memberId → defaults across all 14 regions', () async {
      await AppState().loadMemberCalibration(null);
      final loaded = AppState().memberCalibration;
      expect(loaded, equals(MouthRegionEstimator.defaultCalibration));
      expect(loaded, hasLength(Orientation.values.length));
    });

    test('empty memberId → defaults', () async {
      await AppState().loadMemberCalibration('');
      expect(AppState().memberCalibration,
          equals(MouthRegionEstimator.defaultCalibration));
    });

    test('unknown memberId → still returns 14 defaults, no throw', () async {
      await AppState().loadMemberCalibration('nobody');
      expect(AppState().memberCalibration,
          hasLength(Orientation.values.length));
    });

    test('personalised region overlays default; others fall through',
        () async {
      // Seed one calibration row directly via SQLiteManager to simulate a
      // prior save. loadMemberCalibration should honour that one region and
      // leave the rest at the default representative.
      await SQLiteManager.instance.upsertCalibration(
        id: 'cal-1',
        familyMemberId: 'fm-1',
        regionCode: Orientation.UFI.name,
        avgPitch: 42,
        avgRoll: -17,
        sampleCount: 5,
        calibratedAt: DateTime.now().millisecondsSinceEpoch ~/ 1000,
      );

      await AppState().loadMemberCalibration('fm-1');
      final loaded = AppState().memberCalibration;
      expect(loaded, hasLength(Orientation.values.length));

      final ufi = loaded.firstWhere((p) => p.region == Orientation.UFI);
      expect(ufi.pitch, equals(42));
      expect(ufi.roll, equals(-17));

      final expectedDlo = MouthRegionEstimator.defaultCalibration
          .firstWhere((p) => p.region == Orientation.DLO);
      final actualDlo =
          loaded.firstWhere((p) => p.region == Orientation.DLO);
      expect(actualDlo.pitch, equals(expectedDlo.pitch));
      expect(actualDlo.roll, equals(expectedDlo.roll));
    });

    test('rows with null pitch or roll are skipped', () async {
      await SQLiteManager.instance.upsertCalibration(
        id: 'cal-null',
        familyMemberId: 'fm-1',
        regionCode: Orientation.UFI.name,
        avgPitch: null,
        avgRoll: 5,
        sampleCount: 1,
        calibratedAt: 0,
      );
      await AppState().loadMemberCalibration('fm-1');
      final ufi = AppState()
          .memberCalibration
          .firstWhere((p) => p.region == Orientation.UFI);
      final defaultUfi = MouthRegionEstimator.defaultCalibration
          .firstWhere((p) => p.region == Orientation.UFI);
      expect(ufi.pitch, equals(defaultUfi.pitch),
          reason: 'null pitch means the personalised row is thrown away');
    });
  });

  group('saveCalibrationPoint (local)', () {
    test('writes a row that loadMemberCalibration can round-trip', () async {
      await AppState().saveCalibrationPoint(
        familyMemberId: 'fm-1',
        region: Orientation.URO,
        avgPitch: 33,
        avgRoll: 44,
        sampleCount: 7,
      );

      final rows = await SQLiteManager.instance
          .getCalibrationByMemberId(familyMemberId: 'fm-1');
      expect(rows, hasLength(1));
      expect(rows.single.regionCode, equals('URO'));
      expect(rows.single.avgPitch, equals(33));
      expect(rows.single.avgRoll, equals(44));

      await AppState().loadMemberCalibration('fm-1');
      final loaded = AppState()
          .memberCalibration
          .firstWhere((p) => p.region == Orientation.URO);
      expect(loaded.pitch, equals(33));
      expect(loaded.roll, equals(44));
    });
  });

  group('saveMemberDocument (local)', () {
    test('persists blob + metadata; struct returned has no storagePath',
        () async {
      final bytes = Uint8List.fromList([1, 2, 3, 4, 5, 6, 7, 8]);
      final saved = await AppState().saveMemberDocument(
        familyMemberId: 'fm-1',
        fileName: 'referral.pdf',
        mimeType: 'application/pdf',
        bytes: bytes,
        extractedText: 'Patient presents with plaque.',
        extractionStatus: 'ok',
      );

      // Local mode: blob is in SQLite, no storagePath.
      expect(saved.storagePath, isNull,
          reason: 'local writes do not touch Supabase Storage');
      expect(saved.byteSize, equals(bytes.length));
      expect(saved.extractionStatus, equals('ok'));

      final rows = await SQLiteManager.instance
          .getMemberDocumentsByMemberId(familyMemberId: 'fm-1');
      expect(rows, hasLength(1));
      expect(rows.single.fileName, equals('referral.pdf'));
      expect(rows.single.byteSize, equals(bytes.length));
      expect(rows.single.extractedText, equals('Patient presents with plaque.'));

      // In-memory list is updated too.
      expect(AppState().memberDocuments.map((d) => d.id),
          contains(saved.id));
    });

    test('new saves prepend to the in-memory list (freshest first)',
        () async {
      final first = await AppState().saveMemberDocument(
        familyMemberId: 'fm-1',
        fileName: 'a.pdf',
        mimeType: 'application/pdf',
        bytes: Uint8List.fromList([1]),
        extractedText: '',
        extractionStatus: 'empty',
      );
      final second = await AppState().saveMemberDocument(
        familyMemberId: 'fm-1',
        fileName: 'b.pdf',
        mimeType: 'application/pdf',
        bytes: Uint8List.fromList([2]),
        extractedText: '',
        extractionStatus: 'empty',
      );

      expect(AppState().memberDocuments.first.id, equals(second.id));
      expect(AppState().memberDocuments.last.id, equals(first.id));
    });
  });

  group('deleteMemberDocument (local)', () {
    test('removes the row AND scrubs its chunks first', () async {
      final saved = await AppState().saveMemberDocument(
        familyMemberId: 'fm-1',
        fileName: 'x.pdf',
        mimeType: 'application/pdf',
        bytes: Uint8List.fromList([1, 2]),
        extractedText: 'hi',
        extractionStatus: 'ok',
      );

      final embedding = Float32List.fromList(List<double>.filled(768, 0.01));
      await SQLiteManager.instance.insertMemberDocumentChunk(
        id: 'chunk-1',
        documentId: saved.id,
        chunkIndex: 0,
        text: 'chunk content',
        embedding: embedding.buffer.asUint8List(),
      );

      var chunks =
          await SQLiteManager.instance.getChunksByMemberId(familyMemberId: 'fm-1');
      expect(chunks, hasLength(1), reason: 'seed check');

      await AppState().deleteMemberDocument(saved);

      chunks = await SQLiteManager.instance
          .getChunksByMemberId(familyMemberId: 'fm-1');
      expect(chunks, isEmpty,
          reason: 'chunk rows must be deleted first (FKs are off in sqlite)');

      final docs = await SQLiteManager.instance
          .getMemberDocumentsByMemberId(familyMemberId: 'fm-1');
      expect(docs.where((d) => d.id == saved.id), isEmpty);
      expect(AppState().memberDocuments.where((d) => d.id == saved.id),
          isEmpty);
    });
  });

  group('saveDocumentChunk (local)', () {
    test('round-trips a 768-dim Float32 embedding through the blob column',
        () async {
      final saved = await AppState().saveMemberDocument(
        familyMemberId: 'fm-1',
        fileName: 'x.pdf',
        mimeType: 'application/pdf',
        bytes: Uint8List.fromList([1]),
        extractedText: 'text',
        extractionStatus: 'ok',
      );
      final embedding = Float32List.fromList(
        List<double>.generate(768, (i) => (i % 10) / 10.0),
      );
      await AppState().saveDocumentChunk(
        documentId: saved.id,
        chunkIndex: 0,
        text: 'a chunk',
        embedding: embedding,
      );
      final rows = await SQLiteManager.instance
          .getChunksByMemberId(familyMemberId: 'fm-1');
      expect(rows, hasLength(1));
      expect(rows.single.text, equals('a chunk'));
      expect(rows.single.embedding.length, equals(768 * 4),
          reason: '768 floats × 4 bytes = 3072-byte blob');
    });
  });

  group('disconnectCamera', () {
    test('safe to call when nothing is connected — no throw, clears fields',
        () async {
      await AppState().disconnectCamera();
      final conn = AppState().cameraConnection;
      expect(conn.isConnected, isFalse);
      expect(conn.cameraIP, isEmpty);
      expect(conn.cameraName, isNull);
    });
  });

  group('pgvectorLiteral', () {
    test('formats as pgvector-compatible bracketed float literal', () {
      final v = Float32List.fromList([0.1, -0.5, 1.0]);
      expect(AppState.pgvectorLiteral(v),
          equals('[0.100000,-0.500000,1.000000]'));
    });

    test('empty vector → empty brackets', () {
      expect(AppState.pgvectorLiteral(Float32List(0)), equals('[]'));
    });
  });
}
