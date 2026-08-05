import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

/// Book row INT-08 — the longest test in the suite: login → connect →
/// scan → diagnose → summary → save → history → open → verify. Runs
/// against both local and cloud UserSession.
///
/// **Status: scaffold.** Sits at the top of the dependency stack:
/// needs `int01` (Wi-Fi Direct + MJPEG), `int03` (YOLO + fake Gemma),
/// AND `int05` (history round-trip) to be real first. The cloud variant
/// additionally needs `BINA_TEST_SUPABASE_URL` /
/// `BINA_TEST_SUPABASE_ANON_KEY` — see
/// `docs/testing/supabase_test_project.md`.
///
/// Splitting the local + cloud paths into two separate tests keeps the
/// failure diagnostic clean (a cloud-only regression shouldn't red the
/// local flow), but both run the same widget-driven sequence.
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets(
    'local scaffold — enable when int01+int03+int05 land',
    (tester) async {
      // TODO(w5-int08): implement per the plan. Local variant:
      //   1. Cold-start into Auth2Login.
      //   2. Sign in with a local UserSession (offline auth path).
      //   3. Navigate: family → member detail → scan.
      //   4. Fake Wi-Fi Direct connect + MJPEG stream (int01 helpers).
      //   5. Capture → YOLO diagnose → summary (int03 helpers).
      //   6. Save session.
      //   7. Back to family → open history → open the saved session.
      //   8. Verify rendered detections match what was shown at scan time.
      markTestSkipped(
        'int08_full_end_to_end (local): scaffold only. See file docstring.',
      );
    },
  );

  testWidgets(
    'cloud scaffold — additionally needs bina-test env vars',
    (tester) async {
      // TODO(w5-int08): implement cloud variant per the plan. Same as
      // local but wrapped in withCleanUser so every row created during
      // the flow is deleted at the end. Uses the cloud backends
      // (Supabase + Storage) for family_members, scan_session,
      // scan_image, member_document.
      markTestSkipped(
        'int08_full_end_to_end (cloud): scaffold only. See file docstring.',
      );
    },
  );
}
