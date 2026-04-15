import 'package:flutter/material.dart';
import '/backend/schema/structs/index.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:csv/csv.dart';
import 'package:synchronized/synchronized.dart';
import 'app_core/app_util.dart';

class AppState extends ChangeNotifier {
  static AppState _instance = AppState._internal();

  factory AppState() {
    return _instance;
  }

  AppState._internal();

  static void reset() {
    _instance = AppState._internal();
  }

  Future initializePersistedState() async {
    secureStorage = FlutterSecureStorage();
    await _safeInitAsync(() async {
      if (await secureStorage.read(key: 'app_UserSession') != null) {
        try {
          final serializedData =
              await secureStorage.getString('app_UserSession') ?? '{}';
          _UserSession =
              UserSessionStruct.fromSerializableMap(jsonDecode(serializedData));
        } catch (e) {
          print("Can't decode persisted data type. Error: $e.");
        }
      }
    });
    await _safeInitAsync(() async {
      if (await secureStorage.read(key: 'app_cameraConnection') != null) {
        try {
          final serializedData =
              await secureStorage.getString('app_cameraConnection') ?? '{}';
          _cameraConnection =
              CameraConnectionStruct.fromSerializableMap(jsonDecode(serializedData));
        } catch (e) {
          print("Can't decode persisted data type. Error: $e.");
        }
      }
    });
  }

  void update(VoidCallback callback) {
    callback();
    notifyListeners();
  }

  late FlutterSecureStorage secureStorage;

  UserSessionStruct _UserSession = UserSessionStruct();
  UserSessionStruct get UserSession => _UserSession;
  set UserSession(UserSessionStruct value) {
    _UserSession = value;
    secureStorage.setString('app_UserSession', value.serialize());
  }

  void deleteUserSession() {
    secureStorage.delete(key: 'app_UserSession');
  }

  void updateUserSessionStruct(Function(UserSessionStruct) updateFn) {
    updateFn(_UserSession);
    secureStorage.setString('app_UserSession', _UserSession.serialize());
  }

  CameraConnectionStruct _cameraConnection = CameraConnectionStruct();
  CameraConnectionStruct get cameraConnection => _cameraConnection;
  set cameraConnection(CameraConnectionStruct value) {
    _cameraConnection = value;
    secureStorage.setString('app_cameraConnection', value.serialize());
  }

  void deleteCameraConnection() {
    secureStorage.delete(key: 'app_cameraConnection');
  }

  void updateCameraConnectionStruct(Function(CameraConnectionStruct) updateFn) {
    updateFn(_cameraConnection);
    secureStorage.setString('app_cameraConnection', _cameraConnection.serialize());
  }
}

void _safeInit(Function() initializeField) {
  try {
    initializeField();
  } catch (_) {}
}

Future _safeInitAsync(Function() initializeField) async {
  try {
    await initializeField();
  } catch (_) {}
}

extension FlutterSecureStorageExtensions on FlutterSecureStorage {
  static final _lock = Lock();

  Future<void> writeSync({required String key, String? value}) async =>
      await _lock.synchronized(() async {
        await write(key: key, value: value);
      });

  void remove(String key) => delete(key: key);

  Future<String?> getString(String key) async => await read(key: key);
  Future<void> setString(String key, String value) async =>
      await writeSync(key: key, value: value);

  Future<bool?> getBool(String key) async => (await read(key: key)) == 'true';
  Future<void> setBool(String key, bool value) async =>
      await writeSync(key: key, value: value.toString());

  Future<int?> getInt(String key) async =>
      int.tryParse(await read(key: key) ?? '');
  Future<void> setInt(String key, int value) async =>
      await writeSync(key: key, value: value.toString());

  Future<double?> getDouble(String key) async =>
      double.tryParse(await read(key: key) ?? '');
  Future<void> setDouble(String key, double value) async =>
      await writeSync(key: key, value: value.toString());

  Future<List<String>?> getStringList(String key) async =>
      await read(key: key).then((result) {
        if (result == null || result.isEmpty) {
          return null;
        }
        return CsvToListConverter()
            .convert(result)
            .first
            .map((e) => e.toString())
            .toList();
      });
  Future<void> setStringList(String key, List<String> value) async =>
      await writeSync(key: key, value: ListToCsvConverter().convert([value]));
}
