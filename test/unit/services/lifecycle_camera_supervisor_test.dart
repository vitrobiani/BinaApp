import 'package:bina_system/services/lifecycle_camera_supervisor.dart';
import 'package:fake_async/fake_async.dart';
import 'package:flutter/widgets.dart' show AppLifecycleState;
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('LifecycleCameraSupervisor', () {
    test('paused while connected → arms timer; fires after idleAfter', () {
      fakeAsync((async) {
        var connected = true;
        var disconnectCalls = 0;
        final sup = LifecycleCameraSupervisor(
          idleAfter: const Duration(seconds: 60),
          isConnected: () => connected,
          disconnect: () async {
            disconnectCalls++;
            connected = false;
          },
        );

        sup.handleLifecycleState(AppLifecycleState.paused);
        expect(sup.isTimerActive, isTrue,
            reason: 'paused-while-connected should arm the idle timer');

        async.elapse(const Duration(seconds: 59));
        expect(disconnectCalls, equals(0),
            reason: 'timer should not fire before idleAfter');

        async.elapse(const Duration(seconds: 2));
        expect(disconnectCalls, equals(1),
            reason: 'timer should fire once idleAfter has elapsed');
      });
    });

    test('paused while NOT connected → timer never armed', () {
      fakeAsync((async) {
        var disconnectCalls = 0;
        final sup = LifecycleCameraSupervisor(
          idleAfter: const Duration(seconds: 60),
          isConnected: () => false,
          disconnect: () async => disconnectCalls++,
        );

        sup.handleLifecycleState(AppLifecycleState.paused);
        expect(sup.isTimerActive, isFalse);

        async.elapse(const Duration(hours: 1));
        expect(disconnectCalls, equals(0));
      });
    });

    test('resumed within threshold → timer cancelled, no disconnect', () {
      fakeAsync((async) {
        var disconnectCalls = 0;
        final sup = LifecycleCameraSupervisor(
          idleAfter: const Duration(seconds: 60),
          isConnected: () => true,
          disconnect: () async => disconnectCalls++,
        );

        sup.handleLifecycleState(AppLifecycleState.paused);
        expect(sup.isTimerActive, isTrue);

        async.elapse(const Duration(seconds: 5));
        sup.handleLifecycleState(AppLifecycleState.resumed);
        expect(sup.isTimerActive, isFalse,
            reason: 'resumed should cancel the pending timer');

        async.elapse(const Duration(hours: 1));
        expect(disconnectCalls, equals(0),
            reason: 'cancelled timer should never invoke disconnect');
      });
    });

    test('detached fires disconnect immediately, cancels pending timer', () {
      fakeAsync((async) {
        var connected = true;
        var disconnectCalls = 0;
        final sup = LifecycleCameraSupervisor(
          idleAfter: const Duration(seconds: 60),
          isConnected: () => connected,
          disconnect: () async {
            disconnectCalls++;
            connected = false;
          },
        );

        sup.handleLifecycleState(AppLifecycleState.paused);
        expect(sup.isTimerActive, isTrue);

        sup.handleLifecycleState(AppLifecycleState.detached);
        async.flushMicrotasks();

        expect(disconnectCalls, equals(1),
            reason: 'detached should call disconnect once');
        expect(sup.isTimerActive, isFalse,
            reason: 'detached should also cancel the timer');
      });
    });

    test('inactive and hidden are no-ops', () {
      fakeAsync((async) {
        var disconnectCalls = 0;
        final sup = LifecycleCameraSupervisor(
          idleAfter: const Duration(seconds: 60),
          isConnected: () => true,
          disconnect: () async => disconnectCalls++,
        );

        sup.handleLifecycleState(AppLifecycleState.inactive);
        expect(sup.isTimerActive, isFalse);
        sup.handleLifecycleState(AppLifecycleState.hidden);
        expect(sup.isTimerActive, isFalse);

        async.elapse(const Duration(hours: 1));
        expect(disconnectCalls, equals(0));
      });
    });

    test('re-pausing before the timer fires resets the countdown', () {
      fakeAsync((async) {
        var disconnectCalls = 0;
        final sup = LifecycleCameraSupervisor(
          idleAfter: const Duration(seconds: 60),
          isConnected: () => true,
          disconnect: () async => disconnectCalls++,
        );

        sup.handleLifecycleState(AppLifecycleState.paused);
        async.elapse(const Duration(seconds: 30));
        sup.handleLifecycleState(AppLifecycleState.paused); // "re-pause"
        async.elapse(const Duration(seconds: 40));
        expect(disconnectCalls, equals(0),
            reason: 'second paused should reset the clock');

        async.elapse(const Duration(seconds: 25));
        expect(disconnectCalls, equals(1));
      });
    });

    test('disconnect skipped if camera got disconnected during background',
        () {
      fakeAsync((async) {
        var connected = true;
        var disconnectCalls = 0;
        final sup = LifecycleCameraSupervisor(
          idleAfter: const Duration(seconds: 60),
          isConnected: () => connected,
          disconnect: () async => disconnectCalls++,
        );

        sup.handleLifecycleState(AppLifecycleState.paused);
        async.elapse(const Duration(seconds: 30));
        connected = false;
        async.elapse(const Duration(seconds: 40));
        expect(disconnectCalls, equals(0),
            reason: 'timer body must re-check isConnected before disconnecting');
      });
    });

    test('dispose cancels a live timer', () {
      fakeAsync((async) {
        var disconnectCalls = 0;
        final sup = LifecycleCameraSupervisor(
          idleAfter: const Duration(seconds: 60),
          isConnected: () => true,
          disconnect: () async => disconnectCalls++,
        );

        sup.handleLifecycleState(AppLifecycleState.paused);
        expect(sup.isTimerActive, isTrue);
        sup.dispose();
        expect(sup.isTimerActive, isFalse);

        async.elapse(const Duration(hours: 1));
        expect(disconnectCalls, equals(0));
      });
    });
  });
}
