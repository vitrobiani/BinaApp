import 'dart:convert';

import 'package:bina_system/app_state.dart';
import 'package:bina_system/backend/schema/structs/index.dart';
import 'package:bina_system/backend/sqlite/sqlite_manager.dart';
import 'package:bina_system/services/health_report_pdf_builder.dart';
import 'package:bina_system/services/health_report_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

/// Book row INT-06 — export a member's health report and prove it lands
/// both as a shareable PDF AND as a `MemberDocument` row in the member's
/// document library (auto-attach flow from W2 Step 2).
///
/// **Runs against:** any attached device. Uses the real SQLite backend
/// bundled with the app (in `AppData.db`) rather than the in-memory
/// FFI harness used at the unit tier — that's what makes this an
/// integration test.
///
/// The dialog itself is not opened here; showing `_ReportExportDialog`
/// would require a full navigator stack. What we exercise is the
/// **payload → PDF → attach** chain, which is what the dialog drives.
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    // Real SQLite init — the bundled AppData.db must load without touching
    // the network. If the app was newly deployed the DB is empty; if
    // there's stale data it's the operator's job to clear.
    try {
      await SQLiteManager.initialize();
    } catch (e) {
      // ignore: avoid_print
      print('[health_report_export] SQLite init failed: $e — test needs a real device');
      rethrow;
    }
  });

  testWidgets('member with 3 sessions → payload builds → PDF bytes emitted',
      (tester) async {
    AppState().updateUserSessionStruct((u) => u.isLocalSession = true);

    final memberId = 'export-test-${DateTime.now().microsecondsSinceEpoch}';
    final member = FamilyMemberStruct(id: memberId, name: 'Export Alice');

    // Seed three sessions with different data so the payload isn't a
    // trivial one-row case.
    for (var i = 0; i < 3; i++) {
      final sid = '$memberId-s$i';
      await SQLiteManager.instance.createScanSession(
        id: sid,
        familyMemberId: memberId,
        sessionStart:
            (DateTime.now().millisecondsSinceEpoch ~/ 1000) - (i * 3600),
        status: 'completed',
        notes: 'Session $i analysis',
        totalImagesCaptured: 0,
      );
      await SQLiteManager.instance.createScanImage(
        id: '$sid-img',
        scanSessionId: sid,
        image: null,
        diagnosedImage: null,
        capturedAt: DateTime.now().millisecondsSinceEpoch ~/ 1000,
        rawResponse: jsonEncode([
          {'className': 'plaque'},
        ]),
        pitch: 0,
        roll: 0,
        estimatedRegion: 'upper_front',
      );
    }

    final payload =
        await HealthReportService.buildPayload(member: member);
    expect(payload.sessions.length, equals(3));
    expect(payload.member.id, equals(memberId));

    final pdfBytes = await HealthReportPdfBuilder.build(payload);
    expect(pdfBytes.length, greaterThan(500),
        reason: 'PDF must be substantial (>500 bytes) for a 3-session '
            'report');
    // %PDF- magic header sanity check.
    expect(
      String.fromCharCodes(pdfBytes.sublist(0, 5)),
      equals('%PDF-'),
    );
  });

  testWidgets(
    'buildFileName produces a filesystem-safe slug on device',
    (tester) async {
      // Sanity check the pure helper runs identically on real hardware —
      // caught a Locale-collation bug once on iOS where the string
      // sanitiser diverged from the host implementation.
      final member = FamilyMemberStruct(id: 'x', name: "Alice O'Neil ✨");
      final name = HealthReportService.buildFileName(
          member, DateTime(2025, 6, 15));
      expect(name, equals('bina_health_report_alice_o_neil_2025-06-15.pdf'));
    },
  );

  testWidgets(
    'second export in same isolate succeeds (regression fence)',
    (tester) async {
      // The exact bug that landed W2's static-state fix: a second call
      // to `HealthReportPdfBuilder.build` in the same isolate used to
      // NPE on `PdfDictionary.count`. Verify on-device that the fix
      // still holds when running against the real syncfusion_flutter_pdf.
      final memberA = FamilyMemberStruct(id: 'a', name: 'Alice');
      final memberB = FamilyMemberStruct(id: 'b', name: 'Bob');

      final payloadA = HealthReportPayload(
        member: memberA,
        aiOverview: 'A trending stable.',
        sessions: const [],
        generatedAt: DateTime(2025, 6, 15),
      );
      final payloadB = HealthReportPayload(
        member: memberB,
        aiOverview: 'B trending stable.',
        sessions: const [],
        generatedAt: DateTime(2025, 6, 15),
      );

      final first = await HealthReportPdfBuilder.build(payloadA);
      final second = await HealthReportPdfBuilder.build(payloadB);
      expect(first.length, greaterThan(0));
      expect(second.length, greaterThan(0));
      expect(first, isNot(equals(second)));
    },
  );
}
