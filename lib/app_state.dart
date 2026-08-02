import 'package:flutter/material.dart' hide Orientation;
import '/backend/schema/structs/index.dart';
import '/backend/sqlite/sqlite_manager.dart';
import '/backend/supabase/database/database.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:csv/csv.dart';
import 'package:synchronized/synchronized.dart';
import 'app_core/app_util.dart';
import 'services/mouth_region_estimator.dart';
import 'services/wifi_direct_service.dart';

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

  int _scansVersion = 0;
  int get scansVersion => _scansVersion;
  void notifyScansUpdated() {
    _scansVersion++;
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

  /// Tears down the Wi-Fi Direct group and clears the in-memory
  /// `cameraConnection` fields. Safe to call when not connected — the
  /// service's `disconnect()` is a no-op in that case.
  Future<void> disconnectCamera() async {
    try {
      await WifiDirectService.instance.disconnect();
    } catch (e) {
      debugPrint('[Camera] disconnect failed: $e');
    }
    updateCameraConnectionStruct((conn) {
      conn.isConnected = false;
      conn.cameraIP = '';
      conn.cameraName = null;
      conn.cameraMacAddress = null;
      conn.connectionType = 'manual';
    });
    notifyListeners();
  }

  void updateCameraConnectionStruct(Function(CameraConnectionStruct) updateFn) {
    updateFn(_cameraConnection);
    secureStorage.setString('app_cameraConnection', _cameraConnection.serialize());
  }

  List<CalibrationPoint> _memberCalibration =
      MouthRegionEstimator.defaultCalibration;
  List<CalibrationPoint> get memberCalibration => _memberCalibration;

  /// Load the mouth-region calibration for a family member. Any region the
  /// member hasn't calibrated falls back to the default representative from
  /// [MouthRegionEstimator.defaultCalibration], so the returned list always
  /// covers all 14 regions.
  Future<void> loadMemberCalibration(String? familyMemberId) async {
    if (familyMemberId == null || familyMemberId.isEmpty) {
      _memberCalibration = MouthRegionEstimator.defaultCalibration;
      notifyListeners();
      return;
    }

    final calibrated = <Orientation, CalibrationPoint>{};
    try {
      if (_UserSession.isLocalSession) {
        final rows = await SQLiteManager.instance
            .getCalibrationByMemberId(familyMemberId: familyMemberId);
        for (final r in rows) {
          if (r.avgPitch == null || r.avgRoll == null) continue;
          final region = _orientationFromName(r.regionCode);
          if (region == null) continue;
          calibrated[region] = CalibrationPoint(
            region: region,
            pitch: r.avgPitch!,
            roll: r.avgRoll!,
          );
        }
      } else {
        final rows = await FamilyMemberCalibrationsTable().queryRows(
          queryFn: (q) => q.eq('family_member_id', familyMemberId),
        );
        for (final r in rows) {
          if (r.avgPitch == null || r.avgRoll == null) continue;
          final region = _orientationFromName(r.regionCode);
          if (region == null) continue;
          calibrated[region] = CalibrationPoint(
            region: region,
            pitch: r.avgPitch!,
            roll: r.avgRoll!,
          );
        }
      }
    } catch (e) {
      debugPrint('[Calibration] load failed for $familyMemberId: $e');
    }

    _memberCalibration = MouthRegionEstimator.defaultCalibration
        .map((d) => calibrated[d.region] ?? d)
        .toList();
    notifyListeners();
  }

  /// Persist a single calibration point for a family member. Writes to the
  /// active backend (local SQLite or Supabase) and refreshes in-memory state.
  Future<void> saveCalibrationPoint({
    required String familyMemberId,
    required Orientation region,
    required int avgPitch,
    required int avgRoll,
    required int sampleCount,
  }) async {
    final now = DateTime.now();
    final rowId = _uuidLike();

    if (_UserSession.isLocalSession) {
      await SQLiteManager.instance.upsertCalibration(
        id: rowId,
        familyMemberId: familyMemberId,
        regionCode: region.name,
        avgPitch: avgPitch,
        avgRoll: avgRoll,
        sampleCount: sampleCount,
        calibratedAt: now.millisecondsSinceEpoch ~/ 1000,
      );
    } else {
      // Delete-then-insert to emulate an upsert on (family_member_id, region_code).
      await FamilyMemberCalibrationsTable().delete(
        matchingRows: (rows) => rows
            .eq('family_member_id', familyMemberId)
            .eq('region_code', region.name),
      );
      await FamilyMemberCalibrationsTable().insert({
        'id': rowId,
        'family_member_id': familyMemberId,
        'region_code': region.name,
        'avg_pitch': avgPitch,
        'avg_roll': avgRoll,
        'sample_count': sampleCount,
        'calibrated_at': supaSerialize<DateTime>(now),
      });
    }
  }

  static const String _documentsBucket = 'member-documents';

  List<MemberDocumentStruct> _memberDocuments = const [];
  List<MemberDocumentStruct> get memberDocuments => _memberDocuments;

  /// Load all documents for a family member into memory. Called once per
  /// member on chat init and on the docs page. Falls back to an empty list
  /// on any error — Gemma just gets no doc context in that case.
  Future<void> loadMemberDocuments(String? familyMemberId) async {
    if (familyMemberId == null || familyMemberId.isEmpty) {
      _memberDocuments = const [];
      notifyListeners();
      return;
    }
    final loaded = <MemberDocumentStruct>[];
    try {
      if (_UserSession.isLocalSession) {
        final rows = await SQLiteManager.instance
            .getMemberDocumentsByMemberId(familyMemberId: familyMemberId);
        for (final r in rows) {
          loaded.add(MemberDocumentStruct(
            id: r.id,
            familyMemberId: r.familyMemberId,
            fileName: r.fileName,
            mimeType: r.mimeType,
            byteSize: r.byteSize,
            extractedText: r.extractedText,
            extractionStatus: r.extractionStatus,
            uploadedAt: r.uploadedAt != null
                ? DateTime.fromMillisecondsSinceEpoch(r.uploadedAt! * 1000)
                : null,
          ));
        }
      } else {
        final rows = await MemberDocumentsTable().queryRows(
          queryFn: (q) =>
              q.eq('family_member_id', familyMemberId).order('uploaded_at'),
        );
        for (final r in rows) {
          loaded.add(MemberDocumentStruct(
            id: r.id,
            familyMemberId: r.familyMemberId,
            fileName: r.fileName,
            mimeType: r.mimeType,
            byteSize: r.byteSize,
            storagePath: r.storagePath,
            extractedText: r.extractedText,
            extractionStatus: r.extractionStatus,
            uploadedAt: r.uploadedAt,
          ));
        }
      }
    } catch (e) {
      debugPrint('[MemberDocuments] load failed for $familyMemberId: $e');
    }
    _memberDocuments = loaded;
    notifyListeners();
  }

  /// Persist a new document. Local session writes the blob to SQLite; cloud
  /// session uploads to the `member-documents` Storage bucket and stores
  /// the relative path in the row. Returns the struct now in state.
  Future<MemberDocumentStruct> saveMemberDocument({
    required String familyMemberId,
    required String fileName,
    String? mimeType,
    required Uint8List bytes,
    required String extractedText,
    required String extractionStatus,
  }) async {
    final now = DateTime.now();
    final rowId = _uuidLike();

    MemberDocumentStruct saved;
    if (_UserSession.isLocalSession) {
      await SQLiteManager.instance.insertMemberDocument(
        id: rowId,
        familyMemberId: familyMemberId,
        fileName: fileName,
        mimeType: mimeType,
        byteSize: bytes.length,
        blob: bytes,
        extractedText: extractedText,
        extractionStatus: extractionStatus,
        uploadedAt: now.millisecondsSinceEpoch ~/ 1000,
      );
      saved = MemberDocumentStruct(
        id: rowId,
        familyMemberId: familyMemberId,
        fileName: fileName,
        mimeType: mimeType,
        byteSize: bytes.length,
        extractedText: extractedText,
        extractionStatus: extractionStatus,
        uploadedAt: now,
      );
    } else {
      final storagePath = '$familyMemberId/$rowId.pdf';
      await SupaFlow.client.storage
          .from(_documentsBucket)
          .uploadBinary(
            storagePath,
            bytes,
            fileOptions: FileOptions(
              contentType: mimeType ?? 'application/pdf',
              upsert: true,
            ),
          );
      await MemberDocumentsTable().insert({
        'id': rowId,
        'family_member_id': familyMemberId,
        'file_name': fileName,
        if (mimeType != null) 'mime_type': mimeType,
        'byte_size': bytes.length,
        'storage_path': storagePath,
        'extracted_text': extractedText,
        'extraction_status': extractionStatus,
        'uploaded_at': supaSerialize<DateTime>(now),
      });
      saved = MemberDocumentStruct(
        id: rowId,
        familyMemberId: familyMemberId,
        fileName: fileName,
        mimeType: mimeType,
        byteSize: bytes.length,
        storagePath: storagePath,
        extractedText: extractedText,
        extractionStatus: extractionStatus,
        uploadedAt: now,
      );
    }

    _memberDocuments = [saved, ..._memberDocuments];
    notifyListeners();
    return saved;
  }

  /// Delete a document. Local session drops the row (which drops the blob).
  /// Cloud session deletes the Storage object first, then the row.
  Future<void> deleteMemberDocument(MemberDocumentStruct doc) async {
    if (_UserSession.isLocalSession) {
      await SQLiteManager.instance.deleteMemberDocument(id: doc.id);
    } else {
      final path = doc.storagePath;
      if (path != null && path.isNotEmpty) {
        try {
          await SupaFlow.client.storage
              .from(_documentsBucket)
              .remove([path]);
        } catch (e) {
          debugPrint('[MemberDocuments] storage delete failed: $e');
        }
      }
      await MemberDocumentsTable().delete(
        matchingRows: (rows) => rows.eq('id', doc.id),
      );
    }
    _memberDocuments =
        _memberDocuments.where((d) => d.id != doc.id).toList();
    notifyListeners();
  }
}

Orientation? _orientationFromName(String name) {
  for (final o in Orientation.values) {
    if (o.name == name) return o;
  }
  return null;
}

// Lightweight uuid substitute so app_state doesn't need to pull in the uuid pkg.
String _uuidLike() {
  final now = DateTime.now().microsecondsSinceEpoch;
  final rand = now ^ (now >> 17);
  return '${now.toRadixString(16)}-${rand.toRadixString(16)}';
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
