import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

List<String> installLoggingCapture() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final buffer = <String>[];
  _priorDebugPrint = debugPrint;
  debugPrint = (String? message, {int? wrapWidth}) {
    if (message != null) buffer.add(message);
  };
  return buffer;
}

/// Convenience form for tests that only need to capture within one block.
/// Restores the previous handler on the way out even if the body throws.
Future<List<String>> captureLogsAsync(
  Future<void> Function() body,
) async {
  final buffer = installLoggingCapture();
  try {
    await body();
    // Belt-and-suspenders: give any lingering throttled Timer.run from a
    // pre-shim debugPrint one microtask to fire so we don't miss it.
    await Future<void>.delayed(Duration.zero);
    return buffer;
  } finally {
    uninstallLoggingCapture();
  }
}

void uninstallLoggingCapture() {
  if (_priorDebugPrint != null) {
    debugPrint = _priorDebugPrint!;
    _priorDebugPrint = null;
  }
}

DebugPrintCallback? _priorDebugPrint;
