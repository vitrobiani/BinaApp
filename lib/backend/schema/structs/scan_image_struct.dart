// ignore_for_file: unnecessary_getters_setters

import '/backend/schema/util/schema_util.dart';

import 'index.dart';
import '/app_core/app_util.dart';

class ScanImageStruct extends BaseStruct {
  ScanImageStruct({
    String? id,
    String? scanSessionId,
    String? imagePath,
    String? diagnosedImagePath,
    DateTime? capturedAt,
    String? rawResponse,
    int? pitch,
    int? roll,
    String? estimatedRegion,
  })  : _id = id,
        _scanSessionId = scanSessionId,
        _imagePath = imagePath,
        _diagnosedImagePath = diagnosedImagePath,
        _capturedAt = capturedAt,
        _rawResponse = rawResponse,
        _pitch = pitch,
        _roll = roll,
        _estimatedRegion = estimatedRegion;

  // "id" field.
  String? _id;
  String get id => _id ?? '';
  set id(String? val) => _id = val;

  bool hasId() => _id != null;

  // "scan_session_id" field.
  String? _scanSessionId;
  String get scanSessionId => _scanSessionId ?? '';
  set scanSessionId(String? val) => _scanSessionId = val;

  bool hasScanSessionId() => _scanSessionId != null;

  // "image_path" field (local file path for in-memory use).
  String? _imagePath;
  String get imagePath => _imagePath ?? '';
  set imagePath(String? val) => _imagePath = val;

  bool hasImagePath() => _imagePath != null;

  // "diagnosed_image_path" field (local file path for in-memory use).
  String? _diagnosedImagePath;
  String get diagnosedImagePath => _diagnosedImagePath ?? '';
  set diagnosedImagePath(String? val) => _diagnosedImagePath = val;

  bool hasDiagnosedImagePath() => _diagnosedImagePath != null;

  // "captured_at" field.
  DateTime? _capturedAt;
  DateTime? get capturedAt => _capturedAt;
  set capturedAt(DateTime? val) => _capturedAt = val;

  bool hasCapturedAt() => _capturedAt != null;

  // "raw_response" field (JSON string of detections).
  String? _rawResponse;
  String get rawResponse => _rawResponse ?? '';
  set rawResponse(String? val) => _rawResponse = val;

  bool hasRawResponse() => _rawResponse != null;

  // "pitch" field — gyro pitch in degrees, [-180, 180].
  int? _pitch;
  int? get pitch => _pitch;
  set pitch(int? val) => _pitch = val;

  bool hasPitch() => _pitch != null;

  // "roll" field — gyro roll in degrees, [-180, 180].
  int? _roll;
  int? get roll => _roll;
  set roll(int? val) => _roll = val;

  bool hasRoll() => _roll != null;

  // "estimated_region" field — mouth region name or ambiguous pair (e.g. "URI/ULO").
  String? _estimatedRegion;
  String? get estimatedRegion => _estimatedRegion;
  set estimatedRegion(String? val) => _estimatedRegion = val;

  bool hasEstimatedRegion() => _estimatedRegion != null;

  static ScanImageStruct fromMap(Map<String, dynamic> data) => ScanImageStruct(
        id: data['id'] as String?,
        scanSessionId: data['scan_session_id'] as String?,
        imagePath: data['image_path'] as String?,
        diagnosedImagePath: data['diagnosed_image_path'] as String?,
        capturedAt: data['captured_at'] as DateTime?,
        rawResponse: data['raw_response'] as String?,
        pitch: (data['pitch'] as num?)?.toInt(),
        roll: (data['roll'] as num?)?.toInt(),
        estimatedRegion: data['estimated_region'] as String?,
      );

  static ScanImageStruct? maybeFromMap(dynamic data) => data is Map
      ? ScanImageStruct.fromMap(data.cast<String, dynamic>())
      : null;

  Map<String, dynamic> toMap() => {
        'id': _id,
        'scan_session_id': _scanSessionId,
        'image_path': _imagePath,
        'diagnosed_image_path': _diagnosedImagePath,
        'captured_at': _capturedAt,
        'raw_response': _rawResponse,
        'pitch': _pitch,
        'roll': _roll,
        'estimated_region': _estimatedRegion,
      }.withoutNulls;

  @override
  Map<String, dynamic> toSerializableMap() => {
        'id': serializeParam(
          _id,
          ParamType.String,
        ),
        'scan_session_id': serializeParam(
          _scanSessionId,
          ParamType.String,
        ),
        'image_path': serializeParam(
          _imagePath,
          ParamType.String,
        ),
        'diagnosed_image_path': serializeParam(
          _diagnosedImagePath,
          ParamType.String,
        ),
        'captured_at': serializeParam(
          _capturedAt,
          ParamType.DateTime,
        ),
        'raw_response': serializeParam(
          _rawResponse,
          ParamType.String,
        ),
        'pitch': serializeParam(
          _pitch,
          ParamType.int,
        ),
        'roll': serializeParam(
          _roll,
          ParamType.int,
        ),
        'estimated_region': serializeParam(
          _estimatedRegion,
          ParamType.String,
        ),
      }.withoutNulls;

  static ScanImageStruct fromSerializableMap(Map<String, dynamic> data) =>
      ScanImageStruct(
        id: deserializeParam(
          data['id'],
          ParamType.String,
          false,
        ),
        scanSessionId: deserializeParam(
          data['scan_session_id'],
          ParamType.String,
          false,
        ),
        imagePath: deserializeParam(
          data['image_path'],
          ParamType.String,
          false,
        ),
        diagnosedImagePath: deserializeParam(
          data['diagnosed_image_path'],
          ParamType.String,
          false,
        ),
        capturedAt: deserializeParam(
          data['captured_at'],
          ParamType.DateTime,
          false,
        ),
        rawResponse: deserializeParam(
          data['raw_response'],
          ParamType.String,
          false,
        ),
        pitch: deserializeParam(
          data['pitch'],
          ParamType.int,
          false,
        ),
        roll: deserializeParam(
          data['roll'],
          ParamType.int,
          false,
        ),
        estimatedRegion: deserializeParam(
          data['estimated_region'],
          ParamType.String,
          false,
        ),
      );

  @override
  String toString() => 'ScanImageStruct(${toMap()})';

  @override
  bool operator ==(Object other) {
    return other is ScanImageStruct &&
        id == other.id &&
        scanSessionId == other.scanSessionId &&
        imagePath == other.imagePath &&
        diagnosedImagePath == other.diagnosedImagePath &&
        capturedAt == other.capturedAt &&
        rawResponse == other.rawResponse &&
        pitch == other.pitch &&
        roll == other.roll &&
        estimatedRegion == other.estimatedRegion;
  }

  @override
  int get hashCode => const ListEquality().hash([
        id,
        scanSessionId,
        imagePath,
        diagnosedImagePath,
        capturedAt,
        rawResponse,
        pitch,
        roll,
        estimatedRegion,
      ]);
}

ScanImageStruct createScanImageStruct({
  String? id,
  String? scanSessionId,
  String? imagePath,
  String? diagnosedImagePath,
  DateTime? capturedAt,
  String? rawResponse,
  int? pitch,
  int? roll,
  String? estimatedRegion,
}) =>
    ScanImageStruct(
      id: id,
      scanSessionId: scanSessionId,
      imagePath: imagePath,
      diagnosedImagePath: diagnosedImagePath,
      capturedAt: capturedAt,
      rawResponse: rawResponse,
      pitch: pitch,
      roll: roll,
      estimatedRegion: estimatedRegion,
    );
