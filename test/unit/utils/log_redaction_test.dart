import 'dart:convert';
import 'dart:typed_data';

import 'package:bina_system/app_state.dart';
import 'package:bina_system/services/embedding/chunk_retriever.dart';
import 'package:bina_system/services/gyro_controller_service.dart';
import 'package:bina_system/services/motor_controller_service.dart';
import 'package:bina_system/services/wifi_direct_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import '../../helpers/fake_secure_storage.dart';
import '../../helpers/logging_capture.dart';

void main() {
  late List<String> logs;

  setUp(() {
    logs = installLoggingCapture();
    installFakeSecureStorage();
  });

  tearDown(() {
    uninstallLoggingCapture();
    uninstallFakeSecureStorage();
  });

  group('ChunkRetriever failure logs — [Retriever] tag', () {
    test('empty memberId emits a [Retriever] skip log', () async {
      await ChunkRetriever.instance.retrieveTopK(
        familyMemberId: '',
        userQuery: 'anything',
      );
      expect(
        logs.any((l) => l.contains('[Retriever]')),
        isTrue,
        reason: 'guard clause must be observable in bugreports',
      );
    });

    test('empty query emits a [Retriever] skip log', () async {
      await ChunkRetriever.instance.retrieveTopK(
        familyMemberId: 'fm-1',
        userQuery: '   ',
      );
      expect(logs.any((l) => l.contains('[Retriever]')), isTrue);
    });
  });

  group('GyroControllerService failure logs — Gyro tag', () {
    test('unconfigured readOrientation emits a [Gyro] skip log', () async {
      AppState.reset();
      await AppState().initializePersistedState();

      await GyroControllerService.instance.readOrientationInts();
      expect(
        logs.any((l) => l.contains('Gyro')),
        isTrue,
        reason: 'unconfigured read must trace something identifiable to gyro',
      );
    });

    test('HTTP failure emits a [Gyro] error log', () async {
      GyroControllerService.instance.httpClient = MockClient((_) async {
        throw const _FakeSocketException();
      });
      GyroControllerService.instance.configure(host: '127.0.0.1', port: 65535);

      await GyroControllerService.instance.readOrientation();
      expect(
        logs.any((l) => l.contains('[Gyro]')),
        isTrue,
        reason: 'failed HTTP round-trip must emit the bracket-tagged log',
      );
    });
  });

  group('MotorControllerService failure logs — Motor tag', () {
    test('HTTP failure on getStatus emits a MotorControllerService log',
        () async {
      MotorControllerService.instance.httpClient = MockClient((_) async {
        throw const _FakeSocketException();
      });
      MotorControllerService.instance.configure(host: '127.0.0.1', port: 65535);

      await MotorControllerService.instance.getStatus();
      expect(
        logs.any((l) => l.contains('MotorControllerService')),
        isTrue,
      );
    });
  });

  group('WifiDirectService failure logs — WifiDirectService tag', () {
    test('disconnect on an unbound platform channel emits a WifiDirect log',
        () async {
      await WifiDirectService.instance.disconnect();
      expect(
        logs.any((l) => l.contains('WifiDirectService')),
        isTrue,
      );
    });
  });

  group('AppState.disconnectCamera — traceable through WifiDirectService',
      () {
    test('disconnect emits SOMETHING recognisable when platform channel is '
        'unbound', () async {
      AppState.reset();
      await AppState().initializePersistedState();
      await AppState().disconnectCamera();
      expect(
        logs.any((l) =>
            l.contains('WifiDirectService') || l.contains('[Camera]')),
        isTrue,
        reason: 'disconnect path must be observable in bugreport logs',
      );
    });
  });

  group('No blobs leak into logs', () {
    test('running every guarded path above never surfaces a long payload',
        () async {
      AppState.reset();
      await AppState().initializePersistedState();
      await ChunkRetriever.instance
          .retrieveTopK(familyMemberId: '', userQuery: 'x');
      await AppState().disconnectCamera();

      for (final line in logs) {
        for (final token in line.split(RegExp(r'[\s,;:{}\[\]()"\047]+'))) {
          if (token.length > 80) {
            fail(
              'Long token detected in log line — probable blob leak.\n'
              'Line: $line\n'
              'Token (first 80): ${token.substring(0, 80)}...',
            );
          }
        }
      }
    });

    test('a raw JPEG byte pattern never appears in a captured line',
        () async {
      AppState.reset();
      await AppState().initializePersistedState();
      await ChunkRetriever.instance
          .retrieveTopK(familyMemberId: '', userQuery: 'x');

      const jpegMagicPatterns = ['[255, 216, 255', 'FFD8FF', 'ffd8ff'];
      for (final pattern in jpegMagicPatterns) {
        expect(
          logs.any((l) => l.contains(pattern)),
          isFalse,
          reason: 'JPEG magic bytes leaked into log: $pattern',
        );
      }
    });

    test('base64-looking blobs are absent from every captured line',
        () async {
      AppState.reset();
      await AppState().initializePersistedState();
      await AppState().disconnectCamera();

      final base64Rx = RegExp(r'[A-Za-z0-9+/=]{60,}');
      for (final line in logs) {
        expect(
          base64Rx.hasMatch(line),
          isFalse,
          reason: 'base64-looking blob leaked into log: $line',
        );
      }
    });
  });
}

class _FakeSocketException implements Exception {
  const _FakeSocketException();
  @override
  String toString() => 'FakeSocketException(no route to host)';
}

void _keepImports() {
  jsonEncode('x');
  Uint8List(0);
  http.Client();
}
