// ignore_for_file: unnecessary_getters_setters

import '/backend/schema/util/schema_util.dart';

import 'index.dart';
import '/app_core/app_util.dart';

/// One calibration sample per (family_member, mouth region).
/// Unique on (family_member_id, region_code) — recalibrating overwrites.
class FamilyMemberCalibrationStruct extends BaseStruct {
  FamilyMemberCalibrationStruct({
    String? id,
    String? familyMemberId,
    String? regionCode,
    int? avgPitch,
    int? avgRoll,
    int? sampleCount,
    DateTime? calibratedAt,
  })  : _id = id,
        _familyMemberId = familyMemberId,
        _regionCode = regionCode,
        _avgPitch = avgPitch,
        _avgRoll = avgRoll,
        _sampleCount = sampleCount,
        _calibratedAt = calibratedAt;

  String? _id;
  String get id => _id ?? '';
  set id(String? val) => _id = val;
  bool hasId() => _id != null;

  String? _familyMemberId;
  String get familyMemberId => _familyMemberId ?? '';
  set familyMemberId(String? val) => _familyMemberId = val;
  bool hasFamilyMemberId() => _familyMemberId != null;

  String? _regionCode;
  String get regionCode => _regionCode ?? '';
  set regionCode(String? val) => _regionCode = val;
  bool hasRegionCode() => _regionCode != null;

  int? _avgPitch;
  int? get avgPitch => _avgPitch;
  set avgPitch(int? val) => _avgPitch = val;
  bool hasAvgPitch() => _avgPitch != null;

  int? _avgRoll;
  int? get avgRoll => _avgRoll;
  set avgRoll(int? val) => _avgRoll = val;
  bool hasAvgRoll() => _avgRoll != null;

  int? _sampleCount;
  int? get sampleCount => _sampleCount;
  set sampleCount(int? val) => _sampleCount = val;
  bool hasSampleCount() => _sampleCount != null;

  DateTime? _calibratedAt;
  DateTime? get calibratedAt => _calibratedAt;
  set calibratedAt(DateTime? val) => _calibratedAt = val;
  bool hasCalibratedAt() => _calibratedAt != null;

  static FamilyMemberCalibrationStruct fromMap(Map<String, dynamic> data) =>
      FamilyMemberCalibrationStruct(
        id: data['id'] as String?,
        familyMemberId: data['family_member_id'] as String?,
        regionCode: data['region_code'] as String?,
        avgPitch: (data['avg_pitch'] as num?)?.toInt(),
        avgRoll: (data['avg_roll'] as num?)?.toInt(),
        sampleCount: (data['sample_count'] as num?)?.toInt(),
        calibratedAt: data['calibrated_at'] as DateTime?,
      );

  static FamilyMemberCalibrationStruct? maybeFromMap(dynamic data) =>
      data is Map
          ? FamilyMemberCalibrationStruct.fromMap(
              data.cast<String, dynamic>())
          : null;

  Map<String, dynamic> toMap() => {
        'id': _id,
        'family_member_id': _familyMemberId,
        'region_code': _regionCode,
        'avg_pitch': _avgPitch,
        'avg_roll': _avgRoll,
        'sample_count': _sampleCount,
        'calibrated_at': _calibratedAt,
      }.withoutNulls;

  @override
  Map<String, dynamic> toSerializableMap() => {
        'id': serializeParam(_id, ParamType.String),
        'family_member_id': serializeParam(_familyMemberId, ParamType.String),
        'region_code': serializeParam(_regionCode, ParamType.String),
        'avg_pitch': serializeParam(_avgPitch, ParamType.int),
        'avg_roll': serializeParam(_avgRoll, ParamType.int),
        'sample_count': serializeParam(_sampleCount, ParamType.int),
        'calibrated_at': serializeParam(_calibratedAt, ParamType.DateTime),
      }.withoutNulls;

  static FamilyMemberCalibrationStruct fromSerializableMap(
          Map<String, dynamic> data) =>
      FamilyMemberCalibrationStruct(
        id: deserializeParam(data['id'], ParamType.String, false),
        familyMemberId:
            deserializeParam(data['family_member_id'], ParamType.String, false),
        regionCode:
            deserializeParam(data['region_code'], ParamType.String, false),
        avgPitch: deserializeParam(data['avg_pitch'], ParamType.int, false),
        avgRoll: deserializeParam(data['avg_roll'], ParamType.int, false),
        sampleCount:
            deserializeParam(data['sample_count'], ParamType.int, false),
        calibratedAt: deserializeParam(
            data['calibrated_at'], ParamType.DateTime, false),
      );

  @override
  String toString() => 'FamilyMemberCalibrationStruct(${toMap()})';

  @override
  bool operator ==(Object other) {
    return other is FamilyMemberCalibrationStruct &&
        id == other.id &&
        familyMemberId == other.familyMemberId &&
        regionCode == other.regionCode &&
        avgPitch == other.avgPitch &&
        avgRoll == other.avgRoll &&
        sampleCount == other.sampleCount &&
        calibratedAt == other.calibratedAt;
  }

  @override
  int get hashCode => const ListEquality().hash([
        id,
        familyMemberId,
        regionCode,
        avgPitch,
        avgRoll,
        sampleCount,
        calibratedAt,
      ]);
}
