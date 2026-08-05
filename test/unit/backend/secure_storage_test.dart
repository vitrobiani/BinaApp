import 'dart:convert';

import 'package:bina_system/app_state.dart';
import 'package:bina_system/backend/schema/structs/index.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/fake_secure_storage.dart';

void main() {
  setUp(() {
    AppState.reset();
  });

  tearDown(() {
    uninstallFakeSecureStorage();
  });

  test('empty storage → AppState carries default UserSession and CameraConnection',
      () async {
    installFakeSecureStorage();

    await AppState().initializePersistedState();

    expect(AppState().UserSession.userID, isEmpty);
    expect(AppState().UserSession.email, isEmpty);
    expect(AppState().UserSession.isLocalSession, isFalse);
    expect(AppState().cameraConnection.isConnected, isFalse);
    expect(AppState().cameraConnection.cameraIP, isNull);
    expect(AppState().cameraConnection.connectionType, equals('manual'));
  });

  test('stored UserSession is restored on init', () async {
    final persisted = UserSessionStruct(
      userID: 'u-42',
      name: 'Alice',
      email: 'a@example.com',
      sessionId: 'sess-1',
      isLocalSession: true,
      familyAmount: 3,
    );
    installFakeSecureStorage(
      initialValues: {'app_UserSession': persisted.serialize()},
    );

    await AppState().initializePersistedState();

    expect(AppState().UserSession.userID, equals('u-42'));
    expect(AppState().UserSession.email, equals('a@example.com'));
    expect(AppState().UserSession.isLocalSession, isTrue);
    expect(AppState().UserSession.familyAmount, equals(3));
  });

  test('stored CameraConnection is restored on init', () async {
    final persisted = CameraConnectionStruct(
      isConnected: true,
      cameraIP: '192.168.49.1:8070',
      cameraName: 'Bina-Camera',
      cameraMacAddress: 'AA:BB:CC:DD:EE:FF',
      connectionType: 'wifi_direct',
    );
    installFakeSecureStorage(
      initialValues: {'app_cameraConnection': persisted.serialize()},
    );

    await AppState().initializePersistedState();

    final cc = AppState().cameraConnection;
    expect(cc.isConnected, isTrue);
    expect(cc.cameraIP, equals('192.168.49.1:8070'));
    expect(cc.cameraName, equals('Bina-Camera'));
    expect(cc.cameraMacAddress, equals('AA:BB:CC:DD:EE:FF'));
    expect(cc.connectionType, equals('wifi_direct'));
    expect(cc.isBinaCameraConnected(), isTrue);
  });

  test('both keys populated → both restored', () async {
    final user = UserSessionStruct(userID: 'u-1', name: 'Bob');
    final cam = CameraConnectionStruct(isConnected: true, cameraIP: '10.0.0.5');
    installFakeSecureStorage(
      initialValues: {
        'app_UserSession': user.serialize(),
        'app_cameraConnection': cam.serialize(),
      },
    );

    await AppState().initializePersistedState();

    expect(AppState().UserSession.userID, equals('u-1'));
    expect(AppState().cameraConnection.cameraIP, equals('10.0.0.5'));
  });

  test('corrupted UserSession JSON does not throw; falls back to defaults',
      () async {
    installFakeSecureStorage(
      initialValues: {'app_UserSession': '{not valid json'},
    );

    // Must complete normally.
    await AppState().initializePersistedState();

    // Default struct is untouched.
    expect(AppState().UserSession.userID, isEmpty);
  });

  test('corrupted CameraConnection JSON does not throw; falls back to defaults',
      () async {
    installFakeSecureStorage(
      initialValues: {'app_cameraConnection': '{garbled'},
    );

    await AppState().initializePersistedState();

    expect(AppState().cameraConnection.isConnected, isFalse);
    expect(AppState().cameraConnection.connectionType, equals('manual'));
  });

  test('write after init round-trips through the fake store', () async {
    final store = installFakeSecureStorage();
    await AppState().initializePersistedState();

    AppState().UserSession = UserSessionStruct(userID: 'u-new', name: 'Carol');

    // The store now contains the serialized session under the expected key.
    expect(store, containsPair('app_UserSession', isNotEmpty));
    final restored = UserSessionStruct.fromSerializableMap(
      json.decode(store['app_UserSession']!) as Map<String, dynamic>,
    );
    expect(restored.userID, equals('u-new'));
    expect(restored.name, equals('Carol'));
  });
}
