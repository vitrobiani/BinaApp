import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart' show AppLifecycleState;

/// Watches Android/iOS lifecycle transitions and auto-disconnects the Bina
/// camera after the app has been backgrounded for [idleAfter]. Extracted from
/// `_MyAppState._armCameraDisconnectTimer` so the timing rules can be
/// exercised under `fake_async` without spinning up the widget tree.
///
/// Contract:
/// - `paused` while connected → arm a one-shot timer; when it fires, call
///   [disconnect] (only if still connected).
/// - `resumed` → cancel the pending timer; no disconnect.
/// - `detached` → cancel any pending timer and fire [disconnect] synchronously
///   as a fallback (Dart timers may not survive the process shutdown).
/// - `paused` while not connected → do nothing.
/// - `inactive` / `hidden` → transient states, do nothing.
class LifecycleCameraSupervisor {
  LifecycleCameraSupervisor({
    this.idleAfter = const Duration(seconds: 60),
    required bool Function() isConnected,
    required Future<void> Function() disconnect,
  })  : _isConnected = isConnected,
        _disconnect = disconnect;

  final Duration idleAfter;
  final bool Function() _isConnected;
  final Future<void> Function() _disconnect;

  Timer? _timer;

  @visibleForTesting
  bool get isTimerActive => _timer?.isActive ?? false;

  void handleLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.paused:
        _arm();
        break;
      case AppLifecycleState.resumed:
        _cancel();
        break;
      case AppLifecycleState.detached:
        _cancel();
        unawaited(_disconnect());
        break;
      case AppLifecycleState.inactive:
      case AppLifecycleState.hidden:
        break;
    }
  }

  void _arm() {
    if (!_isConnected()) return;
    _cancel();
    _timer = Timer(idleAfter, () async {
      if (_isConnected()) {
        debugPrint(
            '[Lifecycle] auto-disconnecting camera after ${idleAfter.inSeconds}s in background');
        await _disconnect();
      }
    });
  }

  void _cancel() {
    _timer?.cancel();
    _timer = null;
  }

  void dispose() => _cancel();
}
