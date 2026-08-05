import 'dart:convert';
import 'dart:typed_data';

import 'package:bina_system/app_state.dart';
import 'package:bina_system/backend/schema/structs/index.dart';
import 'package:bina_system/backend/sqlite/sqlite_manager.dart';
import 'package:bina_system/services/health_report_service.dart';
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

  FamilyMemberStruct fm(String id, {String name = 'Test Member'}) =>
      FamilyMemberStruct(id: id, name: name);

  Future<void> insertSession({
    required String id,
    required String memberId,
    required int startEpochSec,
    int? endEpochSec,
    String status = 'completed',
    String? notes,
  }) =>
      SQLiteManager.instance.createScanSession(
        id: id,
        familyMemberId: memberId,
        sessionStart: startEpochSec,
        status: status,
        notes: notes,
        totalImagesCaptured: 0,
      ).then((_) {
        if (endEpochSec != null) {
          return SQLiteManager.instance.updateScanSessionEnd(
            id: id,
            sessionEnd: endEpochSec,
            status: status,
            totalImagesCaptured: 0,
          );
        }
      });

  Uint8List fakeJpeg() => Uint8List.fromList([0xFF, 0xD8, 0xFF, 0xD9]);

  Future<void> insertImage({
    required String id,
    required String sessionId,
    Uint8List? image,
    Uint8List? diagnosed,
    int? capturedAtSec,
    String? rawResponse,
    String? estimatedRegion,
  }) =>
      SQLiteManager.instance.createScanImage(
        id: id,
        scanSessionId: sessionId,
        image: image,
        diagnosedImage: diagnosed,
        capturedAt: capturedAtSec,
        rawResponse: rawResponse,
        pitch: 0,
        roll: 0,
        estimatedRegion: estimatedRegion,
      );

  group('buildPayload — local mode', () {
    test('empty member → payload has 0 sessions, empty overview', () async {
      final payload = await HealthReportService.buildPayload(
        member: fm('fm-empty'),
      );
      expect(payload.sessions, isEmpty);
      expect(payload.aiOverview, isEmpty);
      expect(payload.member.id, equals('fm-empty'));
    });

    test('returns sessions newest-first ordered by session_start', () async {
      await insertSession(
        id: 's-oldest',
        memberId: 'fm-1',
        startEpochSec: 1700000000,
      );
      await insertSession(
        id: 's-newest',
        memberId: 'fm-1',
        startEpochSec: 1700005000,
      );
      await insertSession(
        id: 's-middle',
        memberId: 'fm-1',
        startEpochSec: 1700002500,
      );

      final payload =
          await HealthReportService.buildPayload(member: fm('fm-1'));
      expect(
        payload.sessions.map((s) => s.id).toList(),
        equals(['s-newest', 's-middle', 's-oldest']),
      );
    });

    test('caps at 5 sessions (the _sessionLimit contract fence)', () async {
      for (var i = 0; i < 7; i++) {
        await insertSession(
          id: 's-$i',
          memberId: 'fm-1',
          startEpochSec: 1700000000 + i,
        );
      }
      final payload =
          await HealthReportService.buildPayload(member: fm('fm-1'));
      expect(payload.sessions, hasLength(5));
    });

    test('duration derived from start+end; null when end missing', () async {
      await insertSession(
        id: 's-done',
        memberId: 'fm-1',
        startEpochSec: 1700000000,
        endEpochSec: 1700000180, // 3-minute session
      );
      await insertSession(
        id: 's-ongoing',
        memberId: 'fm-1',
        startEpochSec: 1700001000,
      );

      final payload =
          await HealthReportService.buildPayload(member: fm('fm-1'));
      final done = payload.sessions.firstWhere((s) => s.id == 's-done');
      final ongoing = payload.sessions.firstWhere((s) => s.id == 's-ongoing');
      expect(done.duration, equals(const Duration(minutes: 3)));
      expect(ongoing.duration, isNull);
    });

    test('images: prefers diagnosed_image blob; falls back to image', () async {
      await insertSession(
        id: 's-1',
        memberId: 'fm-1',
        startEpochSec: 1700000000,
      );
      final rawJpeg = Uint8List.fromList([0xFF, 0xD8, 1, 2]);
      final diagJpeg = Uint8List.fromList([0xFF, 0xD8, 9, 9]);
      await insertImage(
        id: 'img-diagnosed',
        sessionId: 's-1',
        image: rawJpeg,
        diagnosed: diagJpeg,
        capturedAtSec: 1700000010,
        estimatedRegion: 'upper_front',
      );
      await insertImage(
        id: 'img-raw-only',
        sessionId: 's-1',
        image: rawJpeg,
        capturedAtSec: 1700000020,
      );

      final payload =
          await HealthReportService.buildPayload(member: fm('fm-1'));
      final images = payload.sessions.single.images;
      expect(images, hasLength(2));
      expect(images[0].bytes, equals(diagJpeg),
          reason: 'diagnosed_image wins when both are present');
      expect(images[1].bytes, equals(rawJpeg),
          reason: 'falls back to image when diagnosed_image is null');
    });

    test('images with null blob and empty blob are skipped', () async {
      await insertSession(
        id: 's-1',
        memberId: 'fm-1',
        startEpochSec: 1700000000,
      );
      await insertImage(id: 'img-null', sessionId: 's-1');
      await insertImage(
        id: 'img-empty',
        sessionId: 's-1',
        image: Uint8List(0),
      );
      await insertImage(
        id: 'img-ok',
        sessionId: 's-1',
        image: fakeJpeg(),
      );

      final payload =
          await HealthReportService.buildPayload(member: fm('fm-1'));
      final ids = payload.sessions.single.images.length;
      expect(ids, equals(1),
          reason: 'null and 0-byte blobs must not survive slicing');
    });

    test('coveredRegions is distinct + non-empty regions only', () async {
      await insertSession(
        id: 's-1',
        memberId: 'fm-1',
        startEpochSec: 1700000000,
      );
      await insertImage(
        id: 'img-a',
        sessionId: 's-1',
        image: fakeJpeg(),
        estimatedRegion: 'upper_front',
      );
      await insertImage(
        id: 'img-b',
        sessionId: 's-1',
        image: fakeJpeg(),
        estimatedRegion: 'upper_front', // duplicate
      );
      await insertImage(
        id: 'img-c',
        sessionId: 's-1',
        image: fakeJpeg(),
        estimatedRegion: 'lower_left',
      );
      await insertImage(
        id: 'img-d',
        sessionId: 's-1',
        image: fakeJpeg(),
        estimatedRegion: '', // must be filtered out
      );

      final payload =
          await HealthReportService.buildPayload(member: fm('fm-1'));
      expect(
        payload.sessions.single.coveredRegions.toSet(),
        equals({'upper_front', 'lower_left'}),
      );
    });

    test('detectedClasses parses raw_response; strips tooth_* anatomy labels',
        () async {
      await insertSession(
        id: 's-1',
        memberId: 'fm-1',
        startEpochSec: 1700000000,
      );
      final raw = jsonEncode([
        {'className': 'plaque'},
        {'className': 'cavity'},
        {'className': 'tooth_11'}, // anatomy — must be dropped
        {'className': 'tooth_26'},
        {'className': 'plaque'}, // duplicate — must be deduped
      ]);
      await insertImage(
        id: 'img-1',
        sessionId: 's-1',
        image: fakeJpeg(),
        rawResponse: raw,
      );

      final payload =
          await HealthReportService.buildPayload(member: fm('fm-1'));
      final detected = payload.sessions.single.images.single.detectedClasses;
      expect(detected.toSet(), equals({'plaque', 'cavity'}));
    });

    test('malformed raw_response JSON → empty detectedClasses, no throw',
        () async {
      await insertSession(
        id: 's-1',
        memberId: 'fm-1',
        startEpochSec: 1700000000,
      );
      await insertImage(
        id: 'img-1',
        sessionId: 's-1',
        image: fakeJpeg(),
        rawResponse: 'not a json array',
      );

      final payload =
          await HealthReportService.buildPayload(member: fm('fm-1'));
      expect(
          payload.sessions.single.images.single.detectedClasses, isEmpty);
    });

    test('gemmaAnalysis is populated from session.notes when non-empty',
        () async {
      await insertSession(
        id: 's-1',
        memberId: 'fm-1',
        startEpochSec: 1700000000,
        notes: 'Two small plaque patches, no cavities detected.',
      );
      await insertSession(
        id: 's-2',
        memberId: 'fm-1',
        startEpochSec: 1700000500,
        notes: '',
      );

      final payload =
          await HealthReportService.buildPayload(member: fm('fm-1'));
      final one = payload.sessions.firstWhere((s) => s.id == 's-1');
      final two = payload.sessions.firstWhere((s) => s.id == 's-2');
      expect(one.gemmaAnalysis, contains('plaque'));
      expect(two.gemmaAnalysis, isNull,
          reason: 'blank notes should map to null, not "" — PDF branches on it');
    });
  });

  group('buildFileName', () {
    final generatedAt = DateTime(2025, 6, 15, 10, 30);

    test('produces the expected shape with a clean name', () {
      expect(
        HealthReportService.buildFileName(fm('x', name: 'Alice'), generatedAt),
        equals('bina_health_report_alice_2025-06-15.pdf'),
      );
    });

    test('collapses spaces and punctuation into single underscores', () {
      expect(
        HealthReportService.buildFileName(
            fm('x', name: '  Alice   O\'Neil  '), generatedAt),
        equals('bina_health_report_alice_o_neil_2025-06-15.pdf'),
      );
    });

    test('drops non-Latin characters entirely (defaults to "member")', () {
      expect(
        HealthReportService.buildFileName(fm('x', name: 'שלום'), generatedAt),
        equals('bina_health_report_member_2025-06-15.pdf'),
      );
    });

    test('empty member name falls back to "member" too', () {
      expect(
        HealthReportService.buildFileName(fm('x', name: ''), generatedAt),
        equals('bina_health_report_member_2025-06-15.pdf'),
      );
    });

    test('date is zero-padded (leading zero preserved)', () {
      expect(
        HealthReportService.buildFileName(
            fm('x', name: 'Bob'), DateTime(2025, 1, 3)),
        equals('bina_health_report_bob_2025-01-03.pdf'),
      );
    });
  });
}
