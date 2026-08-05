import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

/// Book rows INT-01, INT-02, NET-01 — Wi-Fi Direct connect flow + MJPEG
/// stream rendering.
///
/// **Status: scaffold.** The full test needs three pieces we don't have
/// wired yet:
///
///   1. **`test/helpers/fake_wifi_direct.dart`** — intercepts the
///      `com.bina.system/wifi_direct` method channel and emits fake
///      `onPeersChanged` / `onConnectionChanged` events. `wifi_direct_service_test.dart`
///      does the request-side half; this file needs the event-side half too.
///
///   2. **An in-process MJPEG server** — bind an `HttpServer` on
///      `127.0.0.1:<random>` that streams three canned multipart-JPEG
///      frames. The [MjpegCaptureService] then parses them like it would
///      a real Bina-Camera Pi.
///
///   3. **Real app boot with a mounted `CameraConnectionWidget`** —
///      routing / navigator + AppState provider chain. Simpler to write
///      once (1) and (2) exist.
///
/// See the plan (`docs/plans/w5_tests.md`) for the full case list. When
/// the helpers land, replace the placeholder below with the real
/// implementation.
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets(
    'scaffold — enable when fake_wifi_direct + MJPEG server land',
    (tester) async {
      // TODO(w5-int01): implement per the plan once fake_wifi_direct and
      // an in-process MJPEG server helper exist. Cases to cover:
      //   - Cold start → tap "Scan" → see fake Bina-Camera peer → tap
      //     it → connection state reaches connected within 10 s.
      //   - Live stream widget renders frames from the in-process server.
      //   - Unit-off path — service returns PlatformException → error
      //     dialog appears.
      //   - 10 iterations connect/disconnect — no memory growth per
      //     ProcessInfo.currentRss.
      markTestSkipped(
        'int01_connect_and_stream: scaffold only. See file docstring.',
      );
    },
  );
}
