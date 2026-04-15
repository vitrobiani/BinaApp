// ignore_for_file: unnecessary_getters_setters

import '/backend/schema/util/schema_util.dart';
import '/backend/schema/enums/enums.dart';

import 'index.dart';
import '/app_core/app_util.dart';

class ScanSessionStruct extends BaseStruct {
  ScanSessionStruct({
    String? id,
    String? familyMemberId,
    DateTime? sessionStart,
    DateTime? sessionEnd,
    ScanSessionStatus? status,
    String? notes,
    int? totalImagesCaptured,
  })  : _id = id,
        _familyMemberId = familyMemberId,
        _sessionStart = sessionStart,
        _sessionEnd = sessionEnd,
        _status = status,
        _notes = notes,
        _totalImagesCaptured = totalImagesCaptured;

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

  // "session_start" field.
  DateTime? _sessionStart;
  DateTime? get sessionStart => _sessionStart;
  set sessionStart(DateTime? val) => _sessionStart = val;

  bool hasSessionStart() => _sessionStart != null;

  // "session_end" field.
  DateTime? _sessionEnd;
  DateTime? get sessionEnd => _sessionEnd;
  set sessionEnd(DateTime? val) => _sessionEnd = val;

  bool hasSessionEnd() => _sessionEnd != null;

  // "status" field.
  ScanSessionStatus? _status;
  ScanSessionStatus? get status => _status;
  set status(ScanSessionStatus? val) => _status = val;

  bool hasStatus() => _status != null;

  // "notes" field.
  String? _notes;
  String get notes => _notes ?? '';
  set notes(String? val) => _notes = val;

  bool hasNotes() => _notes != null;

  // "total_images_captured" field.
  int? _totalImagesCaptured;
  int get totalImagesCaptured => _totalImagesCaptured ?? 0;
  set totalImagesCaptured(int? val) => _totalImagesCaptured = val;

  bool hasTotalImagesCaptured() => _totalImagesCaptured != null;

  static ScanSessionStruct fromMap(Map<String, dynamic> data) =>
      ScanSessionStruct(
        id: data['id'] as String?,
        familyMemberId: data['family_member_id'] as String?,
        sessionStart: data['session_start'] as DateTime?,
        sessionEnd: data['session_end'] as DateTime?,
        status: data['status'] is ScanSessionStatus
            ? data['status']
            : deserializeEnum<ScanSessionStatus>(data['status']),
        notes: data['notes'] as String?,
        totalImagesCaptured: castToType<int>(data['total_images_captured']),
      );

  static ScanSessionStruct? maybeFromMap(dynamic data) => data is Map
      ? ScanSessionStruct.fromMap(data.cast<String, dynamic>())
      : null;

  Map<String, dynamic> toMap() => {
        'id': _id,
        'family_member_id': _familyMemberId,
        'session_start': _sessionStart,
        'session_end': _sessionEnd,
        'status': _status?.serialize(),
        'notes': _notes,
        'total_images_captured': _totalImagesCaptured,
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
        'session_start': serializeParam(
          _sessionStart,
          ParamType.DateTime,
        ),
        'session_end': serializeParam(
          _sessionEnd,
          ParamType.DateTime,
        ),
        'status': serializeParam(
          _status,
          ParamType.Enum,
        ),
        'notes': serializeParam(
          _notes,
          ParamType.String,
        ),
        'total_images_captured': serializeParam(
          _totalImagesCaptured,
          ParamType.int,
        ),
      }.withoutNulls;

  static ScanSessionStruct fromSerializableMap(Map<String, dynamic> data) =>
      ScanSessionStruct(
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
        sessionStart: deserializeParam(
          data['session_start'],
          ParamType.DateTime,
          false,
        ),
        sessionEnd: deserializeParam(
          data['session_end'],
          ParamType.DateTime,
          false,
        ),
        status: deserializeParam<ScanSessionStatus>(
          data['status'],
          ParamType.Enum,
          false,
        ),
        notes: deserializeParam(
          data['notes'],
          ParamType.String,
          false,
        ),
        totalImagesCaptured: deserializeParam(
          data['total_images_captured'],
          ParamType.int,
          false,
        ),
      );

  @override
  String toString() => 'ScanSessionStruct(${toMap()})';

  @override
  bool operator ==(Object other) {
    return other is ScanSessionStruct &&
        id == other.id &&
        familyMemberId == other.familyMemberId &&
        sessionStart == other.sessionStart &&
        sessionEnd == other.sessionEnd &&
        status == other.status &&
        notes == other.notes &&
        totalImagesCaptured == other.totalImagesCaptured;
  }

  @override
  int get hashCode => const ListEquality().hash([
        id,
        familyMemberId,
        sessionStart,
        sessionEnd,
        status,
        notes,
        totalImagesCaptured
      ]);
}

ScanSessionStruct createScanSessionStruct({
  String? id,
  String? familyMemberId,
  DateTime? sessionStart,
  DateTime? sessionEnd,
  ScanSessionStatus? status,
  String? notes,
  int? totalImagesCaptured,
}) =>
    ScanSessionStruct(
      id: id,
      familyMemberId: familyMemberId,
      sessionStart: sessionStart,
      sessionEnd: sessionEnd,
      status: status,
      notes: notes,
      totalImagesCaptured: totalImagesCaptured,
    );
