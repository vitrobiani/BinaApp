// ignore_for_file: unnecessary_getters_setters

import '/backend/schema/util/schema_util.dart';
import '/backend/schema/enums/enums.dart';

import 'index.dart';
import '/app_core/app_util.dart';

class DentalRecordStruct extends BaseStruct {
  DentalRecordStruct({
    String? id,
    String? familyMemberId,
    String? scanSessionId,
    DateTime? recordDate,
    String? findingsSnapshot,
    DentalRecordStatus? overallStatus,
  })  : _id = id,
        _familyMemberId = familyMemberId,
        _scanSessionId = scanSessionId,
        _recordDate = recordDate,
        _findingsSnapshot = findingsSnapshot,
        _overallStatus = overallStatus;

  // "id" field.
  String? _id;
  String get id => _id ?? '';
  set id(String? val) => _id = val;

  bool hasId() => _id != null;

  // "family_member_id" field.
  String? _familyMemberId;
  String get familyMemberId => _familyMemberId ?? '';
  set familyMemberId(String? val) => _familyMemberId = val;

  bool hasFamilyMemberId() => _familyMemberId != null;

  // "scan_session_id" field.
  String? _scanSessionId;
  String get scanSessionId => _scanSessionId ?? '';
  set scanSessionId(String? val) => _scanSessionId = val;

  bool hasScanSessionId() => _scanSessionId != null;

  // "record_date" field.
  DateTime? _recordDate;
  DateTime? get recordDate => _recordDate;
  set recordDate(DateTime? val) => _recordDate = val;

  bool hasRecordDate() => _recordDate != null;

  // "findings_snapshot" field (JSON string).
  String? _findingsSnapshot;
  String get findingsSnapshot => _findingsSnapshot ?? '';
  set findingsSnapshot(String? val) => _findingsSnapshot = val;

  bool hasFindingsSnapshot() => _findingsSnapshot != null;

  // "overall_status" field.
  DentalRecordStatus? _overallStatus;
  DentalRecordStatus? get overallStatus => _overallStatus;
  set overallStatus(DentalRecordStatus? val) => _overallStatus = val;

  bool hasOverallStatus() => _overallStatus != null;

  static DentalRecordStruct fromMap(Map<String, dynamic> data) =>
      DentalRecordStruct(
        id: data['id'] as String?,
        familyMemberId: data['family_member_id'] as String?,
        scanSessionId: data['scan_session_id'] as String?,
        recordDate: data['record_date'] as DateTime?,
        findingsSnapshot: data['findings_snapshot'] as String?,
        overallStatus: data['overall_status'] is DentalRecordStatus
            ? data['overall_status']
            : deserializeEnum<DentalRecordStatus>(data['overall_status']),
      );

  static DentalRecordStruct? maybeFromMap(dynamic data) => data is Map
      ? DentalRecordStruct.fromMap(data.cast<String, dynamic>())
      : null;

  Map<String, dynamic> toMap() => {
        'id': _id,
        'family_member_id': _familyMemberId,
        'scan_session_id': _scanSessionId,
        'record_date': _recordDate,
        'findings_snapshot': _findingsSnapshot,
        'overall_status': _overallStatus?.serialize(),
      }.withoutNulls;

  @override
  Map<String, dynamic> toSerializableMap() => {
        'id': serializeParam(
          _id,
          ParamType.String,
        ),
        'family_member_id': serializeParam(
          _familyMemberId,
          ParamType.String,
        ),
        'scan_session_id': serializeParam(
          _scanSessionId,
          ParamType.String,
        ),
        'record_date': serializeParam(
          _recordDate,
          ParamType.DateTime,
        ),
        'findings_snapshot': serializeParam(
          _findingsSnapshot,
          ParamType.String,
        ),
        'overall_status': serializeParam(
          _overallStatus,
          ParamType.Enum,
        ),
      }.withoutNulls;

  static DentalRecordStruct fromSerializableMap(Map<String, dynamic> data) =>
      DentalRecordStruct(
        id: deserializeParam(
          data['id'],
          ParamType.String,
          false,
        ),
        familyMemberId: deserializeParam(
          data['family_member_id'],
          ParamType.String,
          false,
        ),
        scanSessionId: deserializeParam(
          data['scan_session_id'],
          ParamType.String,
          false,
        ),
        recordDate: deserializeParam(
          data['record_date'],
          ParamType.DateTime,
          false,
        ),
        findingsSnapshot: deserializeParam(
          data['findings_snapshot'],
          ParamType.String,
          false,
        ),
        overallStatus: deserializeParam<DentalRecordStatus>(
          data['overall_status'],
          ParamType.Enum,
          false,
        ),
      );

  @override
  String toString() => 'DentalRecordStruct(${toMap()})';

  @override
  bool operator ==(Object other) {
    return other is DentalRecordStruct &&
        id == other.id &&
        familyMemberId == other.familyMemberId &&
        scanSessionId == other.scanSessionId &&
        recordDate == other.recordDate &&
        findingsSnapshot == other.findingsSnapshot &&
        overallStatus == other.overallStatus;
  }

  @override
  int get hashCode => const ListEquality().hash([
        id,
        familyMemberId,
        scanSessionId,
        recordDate,
        findingsSnapshot,
        overallStatus
      ]);
}

DentalRecordStruct createDentalRecordStruct({
  String? id,
  String? familyMemberId,
  String? scanSessionId,
  DateTime? recordDate,
  String? findingsSnapshot,
  DentalRecordStatus? overallStatus,
}) =>
    DentalRecordStruct(
      id: id,
      familyMemberId: familyMemberId,
      scanSessionId: scanSessionId,
      recordDate: recordDate,
      findingsSnapshot: findingsSnapshot,
      overallStatus: overallStatus,
    );
