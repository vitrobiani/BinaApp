import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

/// Book row INT-07 — golden-file coverage of the findings-overlay widget
/// across three device profiles: `iphone_11`, `pixel_5`, and
/// `tablet_landscape`. A canned JPEG + canned detections render into
/// each profile and the output is compared against a checked-in PNG.
///
/// **Status: scaffold, blocked on fonts.** Golden tests need the
/// deterministic paint that comes from bundled fonts. The design system
/// uses `GoogleFonts.readexPro` / `GoogleFonts.inter`, which try to fetch
/// from `fonts.gstatic.com` at first use — under
/// `GoogleFonts.config.allowRuntimeFetching = false` they throw, and
/// under `allowRuntimeFetching = true` they hit the network. Neither is
/// acceptable for repeatable golden diffs.
///
/// The fix is to bundle Inter + ReadexPro as local assets and register
/// them in `pubspec.yaml`, then load them in `setUpAll` via
/// `loadAppFonts` from `golden_toolkit`. Once that lands (a design-system
/// task, not a testing task), the scaffold below flips to real.
///
/// See also `test/widget/contrast_test.dart` — same font blocker, same
/// unblock path.
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets(
    'scaffold — enable when fonts are bundled and loaded in setUpAll',
    (tester) async {
      // TODO(w5-int07): implement per the plan. Cases:
      //   - Given a canned JPEG + canned detections, render the overlay
      //     in each of iphone_11 / pixel_5 / tablet_landscape.
      //   - Compare against test/golden/findings_overlay_<profile>.png.
      //   - Update-golden instructions in docs/testing/manual_procedures.md.
      markTestSkipped(
        'findings_overlay: scaffold only — blocked on font bundling. '
        'See file docstring.',
      );
    },
  );
}
