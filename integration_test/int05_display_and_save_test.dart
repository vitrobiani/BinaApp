import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

/// Book rows INT-05, DB-01, INT-09 — full local flow: scan → save →
/// re-open history → verify detections rendered on the saved session
/// match the ones displayed at scan time. Plus the cloud-backend variant
/// under `withCleanUser`.
///
/// **Status: scaffold.** Depends on the two above (`int01` and `int03`)
/// being real: this test drives the whole capture chain end-to-end, so
/// every prereq of both prior scaffolds must be in place first.
///
/// The cloud-variant additionally needs `BINA_TEST_SUPABASE_URL` /
/// `BINA_TEST_SUPABASE_ANON_KEY` set — see
/// `docs/testing/supabase_test_project.md`.
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets(
    'scaffold — enable when int01 + int03 helpers land',
    (tester) async {
      // TODO(w5-int05): implement per the plan. Cases:
      //   - Local flow: scan → save → open history → open session →
      //     detections match what was shown at scan time (INT-09 auto).
      //   - Cloud flow: same, wrapped in withCleanUser against bina-test.
      markTestSkipped(
        'int05_display_and_save: scaffold only. See file docstring.',
      );
    },
  );
}
