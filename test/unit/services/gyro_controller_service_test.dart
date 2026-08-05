import 'dart:async';
import 'dart:convert';

import 'package:bina_system/app_state.dart';
import 'package:bina_system/backend/schema/structs/index.dart';
import 'package:bina_system/services/gyro_controller_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import '../../helpers/fake_secure_storage.dart';

void main() {
  final svc = GyroControllerService.instance;

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

    test('returns true and sets host from AppState.cameraConnection', () {
      AppState().cameraConnection = CameraConnectionStruct(
        isConnected: true,
        cameraIP: '10.0.0.5:8070',
      );
      expect(svc.configureFromCamera(), isTrue);
      expect(svc.host, equals('10.0.0.5'));
      expect(svc.port, equals(GyroControllerService.defaultPort));
    });
  });

  group('readOrientation', () {
    test('not configured → returns errored GyroOrientation', () async {
      final o = await svc.readOrientation();
      expect(o.hasError, isTrue);
      expect(o.error, contains('not configured'));
    });

    test('200 with valid JSON body → parses pitch/roll', () async {
      svc.configure(host: '10.0.0.5');
      svc.httpClient = MockClient((req) async {
        expect(req.url.path, equals('/gyro/orientation'));
        return http.Response(
          jsonEncode({'pitch': 12.4, 'roll': -7.9, 'unit': 'degrees'}),
          200,
        );
      });

      final o = await svc.readOrientation();
      expect(o.hasError, isFalse);
      expect(o.pitch, closeTo(12.4, 0.001));
      expect(o.roll, closeTo(-7.9, 0.001));
      expect(o.unit, equals('degrees'));
    });

    test('HTTP 500 with JSON error body → propagates error field', () async {
      svc.configure(host: '10.0.0.5');
      svc.httpClient = MockClient((req) async {
        return http.Response(
          jsonEncode({'error': 'sensor offline'}),
          500,
        );
      });

      final o = await svc.readOrientation();
      expect(o.hasError, isTrue);
      expect(o.error, equals('sensor offline'));
    });

    test('non-200/500 status → generic HTTP error', () async {
      svc.configure(host: '10.0.0.5');
      svc.httpClient = MockClient((req) async => http.Response('', 404));
      final o = await svc.readOrientation();
      expect(o.hasError, isTrue);
      expect(o.error, contains('HTTP 404'));
    });

    test('malformed JSON body → returns errored (no exception)', () async {
      svc.configure(host: '10.0.0.5');
      svc.httpClient = MockClient((req) async => http.Response('not json', 200));
      final o = await svc.readOrientation();
      expect(o.hasError, isTrue);
      expect(o.error, isNotEmpty);
    });

    test('timeout → returns errored (no exception)', () async {
      svc.configure(host: '10.0.0.5');
      svc.httpClient = MockClient((req) async {
        throw TimeoutException('probe timed out');
      });
      final o = await svc.readOrientation();
      expect(o.hasError, isTrue);
      expect(o.error, contains('TimeoutException'));
    });
  });

  group('readOrientationInts (self-healing wrapper)', () {
    test('no camera connection → returns (null, null)', () async {
      final r = await svc.readOrientationInts();
      expect(r.pitch, isNull);
      expect(r.roll, isNull);
    });

    test('auto-configures from AppState.cameraConnection on first call',
        () async {
      AppState().cameraConnection = CameraConnectionStruct(
        isConnected: true,
        cameraIP: '10.0.0.5',
      );
      svc.httpClient = MockClient(
        (req) async => http.Response(
          jsonEncode({'pitch': 3.2, 'roll': 44.7}),
          200,
        ),
      );

      final r = await svc.readOrientationInts();
      expect(svc.isConfigured, isTrue);
      expect(svc.host, equals('10.0.0.5'));
      expect(r.pitch, equals(3));
      expect(r.roll, equals(45));
    });

    test('clamps pitch and roll to [-180, 180]', () async {
      svc.configure(host: '10.0.0.5');
      svc.httpClient = MockClient(
        (req) async => http.Response(
          jsonEncode({'pitch': 350.0, 'roll': -900.0}),
          200,
        ),
      );
      final r = await svc.readOrientationInts();
      expect(r.pitch, equals(180));
      expect(r.roll, equals(-180));
    });

    test('backend error → returns (null, null)', () async {
      svc.configure(host: '10.0.0.5');
      svc.httpClient = MockClient(
        (req) async => http.Response(
          jsonEncode({'error': 'i2c bus busy'}),
          500,
        ),
      );
      final r = await svc.readOrientationInts();
      expect(r.pitch, isNull);
      expect(r.roll, isNull);
    });
  });

  group('readAccel', () {
    test('200 with body → parses xyz + unit', () async {
      svc.configure(host: '10.0.0.5');
      svc.httpClient = MockClient(
        (req) async => http.Response(
          jsonEncode({'x': 0.1, 'y': -0.2, 'z': 0.9, 'unit': 'g'}),
          200,
        ),
      );
      final a = await svc.readAccel();
      expect(a.hasError, isFalse);
      expect(a.x, closeTo(0.1, 0.001));
      expect(a.y, closeTo(-0.2, 0.001));
      expect(a.z, closeTo(0.9, 0.001));
      expect(a.unit, equals('g'));
    });

    test('not configured → errored', () async {
      final a = await svc.readAccel();
      expect(a.hasError, isTrue);
    });
  });

  group('testConnection', () {
    test('not configured → false', () async {
      expect(await svc.testConnection(), isFalse);
    });

    test('status.initialized true → true', () async {
      svc.configure(host: '10.0.0.5');
      svc.httpClient = MockClient(
        (req) async => http.Response(
          jsonEncode({'initialized': true, 'device_id': '0x33'}),
          200,
        ),
      );
      expect(await svc.testConnection(), isTrue);
    });

    test('status.initialized false → false', () async {
      svc.configure(host: '10.0.0.5');
      svc.httpClient = MockClient(
        (req) async =>
            http.Response(jsonEncode({'initialized': false}), 200),
      );
      expect(await svc.testConnection(), isFalse);
    });
  });

  group('GyroAccel.fromJson', () {
    test('canonical body → parses', () {
      final a =
          GyroAccel.fromJson({'x': 0.5, 'y': -0.5, 'z': 1.0, 'unit': 'g'});
      expect(a.x, equals(0.5));
      expect(a.hasError, isFalse);
    });

    test('missing fields default to 0.0', () {
      final a = GyroAccel.fromJson({});
      expect(a.x, equals(0.0));
      expect(a.y, equals(0.0));
      expect(a.z, equals(0.0));
      expect(a.unit, equals('g'));
    });

    test('error field → errored variant', () {
      final a = GyroAccel.fromJson({'error': 'boom'});
      expect(a.hasError, isTrue);
      expect(a.error, equals('boom'));
    });
  });

  group('GyroOrientation.fromJson', () {
    test('canonical body → parses', () {
      final o = GyroOrientation.fromJson({'pitch': 10.0, 'roll': -5.0});
      expect(o.pitch, equals(10.0));
      expect(o.roll, equals(-5.0));
    });

    test('error field → errored variant', () {
      final o = GyroOrientation.fromJson({'error': 'nope'});
      expect(o.hasError, isTrue);
    });
  });
}
