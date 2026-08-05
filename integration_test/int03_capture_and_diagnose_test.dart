import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

/// Book rows INT-03, NFR-03 — capture → diagnose (YOLO) → session summary,
/// with a p95 < 5 s timing gate over 50 iterations.
///
/// **Status: scaffold.** The full test needs:
///
///   1. A working `YoloInference` service against the bundled
///      `assets/best_model.tflite`. On a real device this loads via
///      `tflite_flutter`; on the host it needs either a CPU-only fallback
///      or a fake `YoloInference` that returns canned detections.
///
///   2. A `test/helpers/fake_gemma_service.dart` that returns a canned
///      summary string on `generateResponse` — the real Gemma init is
///      too heavy for a per-iteration test.
///
///   3. A canned JPEG that the fake camera returns; `MjpegCaptureService`
///      is bypassed since (1) needs bytes, not a stream.
///
/// See the plan (`docs/plans/w5_tests.md`) for the full case list.
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets(
    'scaffold — enable when fake_gemma_service + canned JPEG land',
    (tester) async {
      // TODO(w5-int03): implement per the plan. Cases:
      //   - E2E capture → diagnose → summary against real YOLO + fake
      //     Gemma returning canned text.
      //   - Timing gate: 50 iterations, assert p95 < 5 s wall time.
      markTestSkipped(
        'int03_capture_and_diagnose: scaffold only. See file docstring.',
      );
    },
  );
}
