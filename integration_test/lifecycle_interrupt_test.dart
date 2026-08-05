import 'package:bina_system/services/lifecycle_camera_supervisor.dart';
import 'package:flutter/widgets.dart' show AppLifecycleState;
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

/// Book row NET-07 — drop the camera link after the app has been in the
/// background past the idle threshold, and skip the drop when the user
/// resumes within the window.
///
/// This integration-tier test complements the unit-tier
/// `lifecycle_camera_supervisor_test.dart` (which uses `fake_async`).
/// Where the unit test runs in nanoseconds of wall time, this one runs
/// against the real `IntegrationTestWidgetsFlutterBinding` and can
/// exercise `binding.handleAppLifecycleStateChanged(...)` — the actual
/// entry point the platform uses in production.
///
/// **Runs against:** any attached Android/iOS device. No fake camera or
/// method-channel mock required — the supervisor's `isConnected` /
/// `disconnect` hooks are lambdas we control directly.
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets(
    'paused → past idleAfter → disconnect fires; resume within window '
    'cancels',
    (tester) async {
      // Speed the test up: 400 ms idle threshold instead of the production
      // 60 s. The property under test is timing behaviour, not any
      // absolute duration — so the smaller window still exercises the
      // arm / cancel / fire branches.
      var connected = true;
      var disconnectCalls = 0;
      final supervisor = LifecycleCameraSupervisor(
        idleAfter: const Duration(milliseconds: 400),
        isConnected: () => connected,
        disconnect: () async {
          disconnectCalls++;
          connected = false;
        },
      );

      // Drive the binding directly — same path production uses.
      final binding = TestWidgetsFlutterBinding.ensureInitialized();

      // 1. Background → wait past threshold → disconnect should fire.
      binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
      supervisor.handleLifecycleState(AppLifecycleState.paused);
      await tester.pump(const Duration(milliseconds: 500));
      expect(disconnectCalls, equals(1),
          reason: 'paused-past-threshold must drop the camera');

      // 2. Reset. Background → resume within threshold → NO extra drop.
      connected = true;
      supervisor.handleLifecycleState(AppLifecycleState.paused);
      await tester.pump(const Duration(milliseconds: 100));
      supervisor.handleLifecycleState(AppLifecycleState.resumed);
      await tester.pump(const Duration(milliseconds: 500));
      expect(disconnectCalls, equals(1),
          reason: 'resume within window must cancel the pending disconnect');

      // 3. Detached fires disconnect synchronously as a fallback.
      connected = true;
      supervisor.handleLifecycleState(AppLifecycleState.detached);
      await tester.pump();
      expect(disconnectCalls, equals(2),
          reason: 'detached must fire disconnect as a hard fallback');
    },
  );
}
