// ignore_for_file: unnecessary_getters_setters

import '/backend/schema/util/schema_util.dart';
import '/backend/schema/enums/enums.dart';

import 'index.dart';
import '/app_core/app_util.dart';

class FamilyMemberStruct extends BaseStruct {
  FamilyMemberStruct({
    String? id,
    String? name,
    bool? admin,
    double? score,
    DateTime? birthday,
    DateTime? lastChecked,
    String? profilePic,
    Relationships? relationship,
  })  : _id = id,
        _name = name,
        _admin = admin,
        _score = score,
        _birthday = birthday,
        _lastChecked = lastChecked,
        _profilePic = profilePic,
        _relationship = relationship;

  // "id" field.
  String? _id;
  String get id => _id ?? '';
  set id(String? val) => _id = val;

  bool hasId() => _id != null;

  // "name" field.
  String? _name;
  String get name => _name ?? '';
  set name(String? val) => _name = val;

  bool hasName() => _name != null;

  // "admin" field.
  bool? _admin;
  bool get admin => _admin ?? false;
  set admin(bool? val) => _admin = val;

  bool hasAdmin() => _admin != null;

  // "score" field.
  double? _score;
  double get score => _score ?? 0.0;
  set score(double? val) => _score = val;

  void incrementScore(double amount) => score = score + amount;

  bool hasScore() => _score != null;

  // "birthday" field.
  DateTime? _birthday;
  DateTime? get birthday => _birthday;
  set birthday(DateTime? val) => _birthday = val;

  bool hasBirthday() => _birthday != null;

  // "last_checked" field.
  DateTime? _lastChecked;
  DateTime? get lastChecked => _lastChecked;
  set lastChecked(DateTime? val) => _lastChecked = val;

  bool hasLastChecked() => _lastChecked != null;

  // "profile_pic" field.
  String? _profilePic;
  String get profilePic => _profilePic ?? '';
  set profilePic(String? val) => _profilePic = val;

  bool hasProfilePic() => _profilePic != null;

  // "relationship" field.
  Relationships? _relationship;
  Relationships? get relationship => _relationship;
  set relationship(Relationships? val) => _relationship = val;

  bool hasRelationship() => _relationship != null;

  static FamilyMemberStruct fromMap(Map<String, dynamic> data) =>
      FamilyMemberStruct(
        id: data['id'] as String?,
        name: data['name'] as String?,
        admin: data['admin'] as bool?,
        score: castToType<double>(data['score']),
        birthday: data['birthday'] as DateTime?,
        lastChecked: data['last_checked'] as DateTime?,
        profilePic: data['profile_pic'] as String?,
        relationship: data['relationship'] is Relationships
            ? data['relationship']
            : deserializeEnum<Relationships>(data['relationship']),
      );

  static FamilyMemberStruct? maybeFromMap(dynamic data) => data is Map
      ? FamilyMemberStruct.fromMap(data.cast<String, dynamic>())
      : null;

  Map<String, dynamic> toMap() => {
        'id': _id,
        'name': _name,
        'admin': _admin,
        'score': _score,
        'birthday': _birthday,
        'last_checked': _lastChecked,
        'profile_pic': _profilePic,
        'relationship': _relationship?.serialize(),
      }.withoutNulls;

  @override
  Map<String, dynamic> toSerializableMap() => {
        'id': serializeParam(
          _id,
          ParamType.String,
        ),
        'name': serializeParam(
          _name,
          ParamType.String,
        ),
        'admin': serializeParam(
          _admin,
          ParamType.bool,
        ),
        'score': serializeParam(
          _score,
          ParamType.double,
        ),
        'birthday': serializeParam(
          _birthday,
          ParamType.DateTime,
        ),
        'last_checked': serializeParam(
          _lastChecked,
          ParamType.DateTime,
        ),
        'profile_pic': serializeParam(
          _profilePic,
          ParamType.String,
        ),
        'relationship': serializeParam(
          _relationship,
          ParamType.Enum,
        ),
      }.withoutNulls;

  static FamilyMemberStruct fromSerializableMap(Map<String, dynamic> data) =>
      FamilyMemberStruct(
        id: deserializeParam(
          data['id'],
          ParamType.String,
          false,
        ),
        name: deserializeParam(
          data['name'],
          ParamType.String,
          false,
        ),
        admin: deserializeParam(
          data['admin'],
          ParamType.bool,
          false,
        ),
        score: deserializeParam(
          data['score'],
          ParamType.double,
          false,
        ),
        birthday: deserializeParam(
          data['birthday'],
          ParamType.DateTime,
          false,
        ),
        lastChecked: deserializeParam(
          data['last_checked'],
          ParamType.DateTime,
          false,
        ),
        profilePic: deserializeParam(
          data['profile_pic'],
          ParamType.String,
          false,
        ),
        relationship: deserializeParam<Relationships>(
          data['relationship'],
          ParamType.Enum,
          false,
        ),
      );

  @override
  String toString() => 'FamilyMemberStruct(${toMap()})';

  @override
  bool operator ==(Object other) {
    return other is FamilyMemberStruct &&
        id == other.id &&
        name == other.name &&
        admin == other.admin &&
        score == other.score &&
        birthday == other.birthday &&
        lastChecked == other.lastChecked &&
        profilePic == other.profilePic &&
        relationship == other.relationship;
  }

  @override
  int get hashCode => const ListEquality().hash([
        id,
        name,
        admin,
        score,
        birthday,
        lastChecked,
        profilePic,
        relationship
      ]);
}

FamilyMemberStruct createFamilyMemberStruct({
  String? id,
  String? name,
  bool? admin,
  double? score,
  DateTime? birthday,
  DateTime? lastChecked,
  String? profilePic,
  Relationships? relationship,
}) =>
    FamilyMemberStruct(
      id: id,
      name: name,
      admin: admin,
      score: score,
      birthday: birthday,
      lastChecked: lastChecked,
      profilePic: profilePic,
      relationship: relationship,
    );
