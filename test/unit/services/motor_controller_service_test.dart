import 'dart:async';
import 'dart:convert';

import 'package:bina_system/app_state.dart';
import 'package:bina_system/backend/schema/structs/index.dart';
import 'package:bina_system/services/motor_controller_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import '../../helpers/fake_secure_storage.dart';

void main() {
  final svc = MotorControllerService.instance;

  setUp(() async {
    AppState.reset();
    installFakeSecureStorage();
    await AppState().initializePersistedState();
    svc.disconnect();
  });

  tearDown(uninstallFakeSecureStorage);

  group('configureFromCamera', () {
    test('returns false when no camera connected', () {
      expect(svc.configureFromCamera(), isFalse);
      expect(svc.isConfigured, isFalse);
    });

    test('picks up host from AppState.cameraConnection', () {
      AppState().cameraConnection = CameraConnectionStruct(
        isConnected: true,
        cameraIP: '10.0.0.9:8071',
      );
      expect(svc.configureFromCamera(), isTrue);
      expect(svc.host, equals('10.0.0.9'));
      expect(svc.port, equals(MotorControllerService.defaultPort));
    });
  });

  group('getStatus', () {
    test('not configured → errored MotorStatus', () async {
      final s = await svc.getStatus();
      expect(s.error, contains('not configured'));
    });

    test('200 with valid body → parses fields', () async {
      svc.configure(host: '10.0.0.5');
      svc.httpClient = MockClient(
        (req) async => http.Response(
          jsonEncode({
            'is_enabled': true,
            'is_moving': false,
            'current_position': 1024,
          }),
          200,
        ),
      );

      final s = await svc.getStatus();
      expect(s.error, isNull);
      expect(s.isEnabled, isTrue);
      expect(s.isMoving, isFalse);
      expect(s.currentPosition, equals(1024));
    });

    test('accepts alternate key names (enabled, moving, position)', () async {
      svc.configure(host: '10.0.0.5');
      svc.httpClient = MockClient(
        (req) async => http.Response(
          jsonEncode({
            'enabled': true,
            'moving': true,
            'position': 42,
          }),
          200,
        ),
      );

      final s = await svc.getStatus();
      expect(s.isEnabled, isTrue);
      expect(s.isMoving, isTrue);
      expect(s.currentPosition, equals(42));
    });

    test('non-200 → errored', () async {
      svc.configure(host: '10.0.0.5');
      svc.httpClient = MockClient((_) async => http.Response('', 503));
      final s = await svc.getStatus();
      expect(s.error, contains('HTTP 503'));
    });

    test('exception → errored (no rethrow)', () async {
      svc.configure(host: '10.0.0.5');
      svc.httpClient = MockClient((_) async {
        throw TimeoutException('boom');
      });
      final s = await svc.getStatus();
      expect(s.error, contains('TimeoutException'));
    });
  });

  group('move', () {
    test('forward → direction=1 in JSON body', () async {
      svc.configure(host: '10.0.0.5');
      Map<String, dynamic>? capturedBody;
      String? capturedPath;
      svc.httpClient = MockClient((req) async {
        capturedPath = req.url.path;
        capturedBody = jsonDecode(req.body) as Map<String, dynamic>;
        return http.Response(jsonEncode({'success': true}), 200);
      });

      final r = await svc.move(steps: 100);
      expect(r.success, isTrue);
      expect(capturedPath, equals('/move'));
      expect(capturedBody!['steps'], equals(100));
      expect(capturedBody!['direction'], equals(1));
    });

    test('backward → direction=0 in JSON body', () async {
      svc.configure(host: '10.0.0.5');
      Map<String, dynamic>? capturedBody;
      svc.httpClient = MockClient((req) async {
        capturedBody = jsonDecode(req.body) as Map<String, dynamic>;
        return http.Response(jsonEncode({'success': true}), 200);
      });

      await svc.move(steps: 50, direction: MotorDirection.backward);
      expect(capturedBody!['direction'], equals(0));
    });

    test('not configured → failure result', () async {
      final r = await svc.move(steps: 100);
      expect(r.success, isFalse);
      expect(r.error, contains('not configured'));
    });

    test('HTTP failure → failure result', () async {
      svc.configure(host: '10.0.0.5');
      svc.httpClient = MockClient((_) async => http.Response('', 500));
      final r = await svc.move(steps: 100);
      expect(r.success, isFalse);
      expect(r.error, contains('HTTP 500'));
    });
  });

  group('rotate', () {
    test('POSTs to /rotate with revolutions + direction', () async {
      svc.configure(host: '10.0.0.5');
      String? path;
      Map<String, dynamic>? body;
      svc.httpClient = MockClient((req) async {
        path = req.url.path;
        body = jsonDecode(req.body) as Map<String, dynamic>;
        return http.Response(jsonEncode({'success': true}), 200);
      });

      await svc.rotate(revolutions: 2.5);
      expect(path, equals('/rotate'));
      expect(body!['revolutions'], equals(2.5));
      expect(body!['direction'], equals(1));
    });
  });

  group('stop / enable / disable', () {
    test('stop() POSTs to /stop', () async {
      svc.configure(host: '10.0.0.5');
      String? path;
      svc.httpClient = MockClient((req) async {
        path = req.url.path;
        return http.Response(jsonEncode({'success': true}), 200);
      });
      final r = await svc.stop();
      expect(path, equals('/stop'));
      expect(r.success, isTrue);
    });

    test('enable() POSTs to /enable', () async {
      svc.configure(host: '10.0.0.5');
      String? path;
      svc.httpClient = MockClient((req) async {
        path = req.url.path;
        return http.Response(jsonEncode({'success': true}), 200);
      });
      await svc.enable();
      expect(path, equals('/enable'));
    });

    test('disable() POSTs to /disable', () async {
      svc.configure(host: '10.0.0.5');
      String? path;
      svc.httpClient = MockClient((req) async {
        path = req.url.path;
        return http.Response(jsonEncode({'success': true}), 200);
      });
      await svc.disable();
      expect(path, equals('/disable'));
    });
  });

  group('blinkLed', () {
    test('POSTs to /led with count in body', () async {
      svc.configure(host: '10.0.0.5');
      Map<String, dynamic>? body;
      svc.httpClient = MockClient((req) async {
        body = jsonDecode(req.body) as Map<String, dynamic>;
        return http.Response(jsonEncode({'success': true}), 200);
      });
      await svc.blinkLed(count: 3);
      expect(body!['count'], equals(3));
    });
  });

  group('testConnection', () {
    test('not configured → false', () async {
      expect(await svc.testConnection(), isFalse);
    });

    test('200 → true', () async {
      svc.configure(host: '10.0.0.5');
      svc.httpClient = MockClient((_) async => http.Response('{}', 200));
      expect(await svc.testConnection(), isTrue);
    });

    test('non-200 → false', () async {
      svc.configure(host: '10.0.0.5');
      svc.httpClient = MockClient((_) async => http.Response('', 500));
      expect(await svc.testConnection(), isFalse);
    });
  });

  group('MotorStatus.fromJson', () {
    test('missing optional fields default to safe values', () {
      final s = MotorStatus.fromJson({});
      expect(s.isEnabled, isFalse);
      expect(s.isMoving, isFalse);
      expect(s.currentPosition, equals(0));
      expect(s.error, isNull);
    });
  });

  group('MotorApiInfo.fromJson', () {
    test('missing fields use defaults', () {
      final i = MotorApiInfo.fromJson({});
      expect(i.name, equals('Motor Control API'));
      expect(i.version, equals('unknown'));
      expect(i.endpoints, isEmpty);
    });

    test('endpoints list is preserved', () {
      final i = MotorApiInfo.fromJson({
        'name': 'MotorAPI',
        'version': '1.2',
        'endpoints': ['/move', '/rotate', '/stop'],
      });
      expect(i.endpoints, equals(['/move', '/rotate', '/stop']));
    });
  });
}
