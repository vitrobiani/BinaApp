import 'package:bina_system/services/wifi_direct_service.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const methodChannel = MethodChannel('com.bina.system/wifi_direct');
  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;

  final svc = WifiDirectService.instance;

  tearDown(() {
    messenger.setMockMethodCallHandler(methodChannel, null);
  });

  MethodCall? _lastCall;
  void installMock(Future<Object?> Function(MethodCall) handler) {
    messenger.setMockMethodCallHandler(methodChannel, (call) {
      _lastCall = call;
      return handler(call);
    });
  }

  group('connectToBinaCamera', () {
    test('invokes connect with address + hard-coded pin 12345678', () async {
      installMock((_) async => true);

      final ok = await svc.connectToBinaCamera('aa:bb:cc:dd:ee:ff');

      expect(ok, isTrue);
      expect(_lastCall!.method, equals('connect'));
      expect(_lastCall!.arguments, isA<Map>());
      final args = _lastCall!.arguments as Map;
      expect(args['deviceAddress'], equals('aa:bb:cc:dd:ee:ff'));
      expect(args['pin'], equals('12345678'));
    });

    test('platform returns false → surface as false', () async {
      installMock((_) async => false);
      expect(await svc.connectToBinaCamera('x'), isFalse);
    });

    test('PlatformException does not propagate', () async {
      installMock((_) async {
        throw PlatformException(code: 'CONNECT_FAILED', message: 'boom');
      });
      expect(await svc.connectToBinaCamera('x'), isFalse);
    });
  });

  group('connect (generic)', () {
    test('forwards deviceAddress + pin', () async {
      installMock((_) async => true);
      await svc.connect('11:22:33:44:55:66', pin: '00000000');
      final args = _lastCall!.arguments as Map;
      expect(args['deviceAddress'], equals('11:22:33:44:55:66'));
      expect(args['pin'], equals('00000000'));
    });

    test('null pin is passed through as null', () async {
      installMock((_) async => true);
      await svc.connect('addr');
      final args = _lastCall!.arguments as Map;
      expect(args['pin'], isNull);
    });
  });

  group('disconnect', () {
    test('returns true on success', () async {
      installMock((_) async => true);
      expect(await svc.disconnect(), isTrue);
      expect(_lastCall!.method, equals('disconnect'));
    });

    test('returns false when platform throws', () async {
      installMock((_) async {
        throw PlatformException(code: 'ERR');
      });
      expect(await svc.disconnect(), isFalse);
    });
  });

  group('isSupported', () {
    test('true → true', () async {
      installMock((_) async => true);
      expect(await svc.isSupported(), isTrue);
    });

    test('false → false', () async {
      installMock((_) async => false);
      expect(await svc.isSupported(), isFalse);
    });

    test('null return → false (defensive)', () async {
      installMock((_) async => null);
      expect(await svc.isSupported(), isFalse);
    });

    test('exception → false', () async {
      installMock((_) async {
        throw PlatformException(code: 'ERR');
      });
      expect(await svc.isSupported(), isFalse);
    });
  });

  group('hasPermissions', () {
    test('true → true', () async {
      installMock((_) async => true);
      expect(await svc.hasPermissions(), isTrue);
    });

    test('false → false', () async {
      installMock((_) async => false);
      expect(await svc.hasPermissions(), isFalse);
    });

    test('exception → false', () async {
      installMock((_) async {
        throw PlatformException(code: 'ERR');
      });
      expect(await svc.hasPermissions(), isFalse);
    });
  });

  group('getConnectionInfo', () {
    test('parses returned map', () async {
      installMock((_) async => <String, dynamic>{
            'isGroupOwner': true,
            'groupOwnerAddress': '192.168.49.1',
          });
      final info = await svc.getConnectionInfo();
      expect(info, isNotNull);
      expect(info!['isGroupOwner'], isTrue);
      expect(info['groupOwnerAddress'], equals('192.168.49.1'));
    });

    test('exception → null', () async {
      installMock((_) async {
        throw PlatformException(code: 'ERR');
      });
      expect(await svc.getConnectionInfo(), isNull);
    });
  });

  group('WifiP2pDevice.fromMap', () {
    test('canonical map → parses all fields', () {
      final d = WifiP2pDevice.fromMap({
        'deviceName': 'Bina-Camera',
        'deviceAddress': 'aa:bb:cc:dd:ee:ff',
        'status': 'available',
        'isGroupOwner': false,
      });
      expect(d.deviceName, equals('Bina-Camera'));
      expect(d.deviceAddress, equals('aa:bb:cc:dd:ee:ff'));
      expect(d.status, equals('available'));
      expect(d.isGroupOwner, isFalse);
      expect(d.isAvailable, isTrue);
      expect(d.isConnected, isFalse);
      expect(d.isInvited, isFalse);
    });

    test('missing fields use safe defaults', () {
      final d = WifiP2pDevice.fromMap({});
      expect(d.deviceName, equals('Unknown'));
      expect(d.deviceAddress, isEmpty);
      expect(d.status, equals('unknown'));
      expect(d.isGroupOwner, isFalse);
    });

    test('status flags reflect connection lifecycle', () {
      final connected = WifiP2pDevice.fromMap({'status': 'connected'});
      final invited = WifiP2pDevice.fromMap({'status': 'invited'});
      expect(connected.isConnected, isTrue);
      expect(connected.isAvailable, isFalse);
      expect(invited.isInvited, isTrue);
    });
  });

  group('WifiDirectConnectionInfo.fromMap', () {
    test('canonical map → parses', () {
      final info = WifiDirectConnectionInfo.fromMap({
        'isGroupOwner': true,
        'groupOwnerAddress': '192.168.49.1',
        'deviceAddress': 'aa:bb:cc:dd:ee:ff',
      });
      expect(info.isGroupOwner, isTrue);
      expect(info.groupOwnerAddress, equals('192.168.49.1'));
      expect(info.deviceAddress, equals('aa:bb:cc:dd:ee:ff'));
    });

    test('missing fields → nulls / defaults', () {
      final info = WifiDirectConnectionInfo.fromMap({});
      expect(info.isGroupOwner, isFalse);
      expect(info.groupOwnerAddress, isNull);
      expect(info.deviceAddress, isNull);
    });
  });
}
