import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

/// Book rows INT-10, NFR-09 — repeated scan-and-save cycles on the same
/// member must NOT grow memory (or file handles, or DB cursors) with
/// each iteration.
///
/// **Status: scaffold.** Depends on the same helpers as `int03` and
/// `int05`: fake camera + `fake_gemma_service` + a mounted app tree.
/// Once those land, the standard variant runs 5 back-to-back sessions;
/// the soak variant (tagged `@Tags(['soak'])`) runs 25.
///
/// Assertion pattern:
///   - Capture `ProcessInfo.currentRss` before and after.
///   - Fail if `after > 1.3 * before` (30 % headroom for baseline
///     variance across runs; a real leak grows an order of magnitude).
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets(
    'scaffold — enable when int03 + int05 helpers land',
    (tester) async {
      // TODO(w5-int10): implement per the plan. Cases:
      //   - 5 back-to-back scan sessions on the same member.
      //   - RSS after < 1.3 × RSS before.
      //   - Soak variant behind @Tags(['soak']): 25 sessions, same
      //     RSS bound, no crash.
      markTestSkipped(
        'int10_sequential_scans: scaffold only. See file docstring.',
      );
    },
  );

  testWidgets(
    'soak scaffold — 25 iterations',
    (tester) async {
      markTestSkipped(
        'int10_sequential_scans soak: scaffold only. See file docstring.',
      );
    },
    tags: ['soak'],
  );
}
