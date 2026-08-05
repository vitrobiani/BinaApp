import 'dart:async';
import 'dart:typed_data';

import 'package:bina_system/services/mjpeg_capture_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  final svc = MjpegCaptureService.instance;
  final validJpegHead = Uint8List.fromList([0xFF, 0xD8, 0xFF, 0xD9]);

  group('captureFrameBytes (snapshot endpoint)', () {
    test('200 with JPEG body → returns bytes with 0xFFD8 magic', () async {
      String? capturedUrl;
      svc.httpClient = MockClient((req) async {
        capturedUrl = req.url.toString();
        return http.Response.bytes(validJpegHead, 200);
      });

      final bytes = await svc.captureFrameBytes(cameraIP: '10.0.0.5');
      expect(bytes, isNotNull);
      expect(bytes!.length, greaterThan(0));
      expect(bytes[0], equals(0xFF));
      expect(bytes[1], equals(0xD8));
      expect(capturedUrl, equals('http://10.0.0.5:8070/snapshot.jpg'));
    });

    test('respects custom port in the URL', () async {
      String? capturedUrl;
      svc.httpClient = MockClient((req) async {
        capturedUrl = req.url.toString();
        return http.Response.bytes(validJpegHead, 200);
      });

      await svc.captureFrameBytes(cameraIP: '10.0.0.5', port: 9000);
      expect(capturedUrl, equals('http://10.0.0.5:9000/snapshot.jpg'));
    });

    test('non-200 → returns null', () async {
      svc.httpClient = MockClient(
        (req) async => http.Response.bytes(Uint8List(0), 503),
      );
      final bytes = await svc.captureFrameBytes(cameraIP: '10.0.0.5');
      expect(bytes, isNull);
    });

    test('timeout → returns null (no rethrow)', () async {
      svc.httpClient = MockClient((req) async {
        throw TimeoutException('camera did not respond');
      });
      final bytes = await svc.captureFrameBytes(cameraIP: '10.0.0.5');
      expect(bytes, isNull);
    });

    test('generic exception → returns null', () async {
      svc.httpClient = MockClient((req) async {
        throw StateError('socket exploded');
      });
      final bytes = await svc.captureFrameBytes(cameraIP: '10.0.0.5');
      expect(bytes, isNull);
    });
  });

  group('testConnection', () {
    test('snapshot HEAD 200 → true', () async {
      String? path;
      svc.httpClient = MockClient((req) async {
        expect(req.method, equals('HEAD'));
        path = req.url.path;
        return http.Response('', 200);
      });
      expect(await svc.testConnection(cameraIP: '10.0.0.5'), isTrue);
      expect(path, equals('/snapshot.jpg'));
    });

    test('snapshot HEAD throws → falls back to stream HEAD', () async {
      final paths = <String>[];
      var call = 0;
      svc.httpClient = MockClient((req) async {
        paths.add(req.url.path);
        call++;
        if (call == 1) throw StateError('snapshot unreachable');
        return http.Response('', 200);
      });
      expect(await svc.testConnection(cameraIP: '10.0.0.5'), isTrue);
      expect(paths, equals(['/snapshot.jpg', '/stream.mjpg']));
    });

    test('both endpoints unreachable → false', () async {
      svc.httpClient = MockClient((req) async {
        throw StateError('no network');
      });
      expect(await svc.testConnection(cameraIP: '10.0.0.5'), isFalse);
    });
  });

  group('URL builders (pure)', () {
    test('getStreamUrl uses default port', () {
      expect(
        svc.getStreamUrl(cameraIP: '10.0.0.5'),
        equals('http://10.0.0.5:8070/stream.mjpg'),
      );
    });

    test('getSnapshotUrl uses default port', () {
      expect(
        svc.getSnapshotUrl(cameraIP: '10.0.0.5'),
        equals('http://10.0.0.5:8070/snapshot.jpg'),
      );
    });

    test('custom port flows through both builders', () {
      expect(
        svc.getStreamUrl(cameraIP: '10.0.0.5', port: 9000),
        equals('http://10.0.0.5:9000/stream.mjpg'),
      );
      expect(
        svc.getSnapshotUrl(cameraIP: '10.0.0.5', port: 9000),
        equals('http://10.0.0.5:9000/snapshot.jpg'),
      );
    });
  });
}
