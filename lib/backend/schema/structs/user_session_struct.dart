// ignore_for_file: unnecessary_getters_setters


import 'index.dart';
import '/app_core/app_util.dart';

class UserSessionStruct extends BaseStruct {
  UserSessionStruct({
    String? userID,
    String? name,
    String? email,
    String? sessionId,
    List<FamilyMemberStruct>? family,
    int? familyAmount,
    int? sumChecked,
    bool? isLocalSession,
    bool? isMock
  })  : _userID = userID,
        _name = name,
        _email = email,
        _sessionId = sessionId,
        _family = family,
        _familyAmount = familyAmount,
        _sumChecked = sumChecked,
        _isLocalSession = isLocalSession,
        _isMock = isMock;


  bool? _isMock;
  bool get isMock => _isMock ?? true;
  set isMock(bool? val) => _isMock = val;

  // "userID" field.
  String? _userID;
  String get userID => _userID ?? '';
  set userID(String? val) => _userID = val;

  bool hasUserID() => _userID != null;

  // "name" field.
  String? _name;
  String get name => _name ?? '';
  set name(String? val) => _name = val;

  bool hasName() => _name != null;

  // "email" field.
  String? _email;
  String get email => _email ?? '';
  set email(String? val) => _email = val;

  bool hasEmail() => _email != null;

  // "session_id" field.
  String? _sessionId;
  String get sessionId => _sessionId ?? '';
  set sessionId(String? val) => _sessionId = val;

  bool hasSessionId() => _sessionId != null;

  // "family" field.
  List<FamilyMemberStruct>? _family;
  List<FamilyMemberStruct> get family => _family ?? const [];
  set family(List<FamilyMemberStruct>? val) => _family = val;

  void updateFamily(Function(List<FamilyMemberStruct>) updateFn) {
    updateFn(_family ??= []);
  }

  bool hasFamily() => _family != null;

  // "familyAmount" field.
  int? _familyAmount;
  int get familyAmount => _familyAmount ?? 0;
  set familyAmount(int? val) => _familyAmount = val;

  void incrementFamilyAmount(int amount) =>
      familyAmount = familyAmount + amount;

  bool hasFamilyAmount() => _familyAmount != null;

  // "sumChecked" field.
  int? _sumChecked;
  int get sumChecked => _sumChecked ?? 0;
  set sumChecked(int? val) => _sumChecked = val;

  void incrementSumChecked(int amount) => sumChecked = sumChecked + amount;

  bool hasSumChecked() => _sumChecked != null;

  // "isLocalSession" field.
  bool? _isLocalSession;
  bool get isLocalSession => _isLocalSession ?? false;
  set isLocalSession(bool? val) => _isLocalSession = val;

  bool hasIsLocalSession() => _isLocalSession != null;

  static UserSessionStruct fromMap(Map<String, dynamic> data) =>
      UserSessionStruct(
        userID: data['userID'] as String?,
        name: data['name'] as String?,
        email: data['email'] as String?,
        sessionId: data['session_id'] as String?,
        family: getStructList(
          data['family'],
          FamilyMemberStruct.fromMap,
        ),
        familyAmount: castToType<int>(data['familyAmount']),
        sumChecked: castToType<int>(data['sumChecked']),
        isLocalSession: data['isLocalSession'] as bool?,
        isMock: data['isMock'] as bool?,
      );

  static UserSessionStruct? maybeFromMap(dynamic data) => data is Map
      ? UserSessionStruct.fromMap(data.cast<String, dynamic>())
      : null;

  Map<String, dynamic> toMap() => {
        'userID': _userID,
        'name': _name,
        'email': _email,
        'session_id': _sessionId,
        'family': _family?.map((e) => e.toMap()).toList(),
        'familyAmount': _familyAmount,
        'sumChecked': _sumChecked,
        'isLocalSession': _isLocalSession,
      }.withoutNulls;

  @override
  Map<String, dynamic> toSerializableMap() => {
        'userID': serializeParam(
          _userID,
          ParamType.String,
        ),
        'name': serializeParam(
          _name,
          ParamType.String,
        ),
        'email': serializeParam(
          _email,
          ParamType.String,
        ),
        'session_id': serializeParam(
          _sessionId,
          ParamType.String,
        ),
        'family': serializeParam(
          _family,
          ParamType.DataStruct,
          isList: true,
        ),
        'familyAmount': serializeParam(
          _familyAmount,
          ParamType.int,
        ),
        'sumChecked': serializeParam(
          _sumChecked,
          ParamType.int,
        ),
        'isLocalSession': serializeParam(
          _isLocalSession,
          ParamType.bool,
        ),
      }.withoutNulls;

  static UserSessionStruct fromSerializableMap(Map<String, dynamic> data) =>
      UserSessionStruct(
        userID: deserializeParam(
          data['userID'],
          ParamType.String,
          false,
        ),
        name: deserializeParam(
          data['name'],
          ParamType.String,
          false,
        ),
        email: deserializeParam(
          data['email'],
          ParamType.String,
          false,
        ),
        sessionId: deserializeParam(
          data['session_id'],
          ParamType.String,
          false,
        ),
        family: deserializeStructParam<FamilyMemberStruct>(
          data['family'],
          ParamType.DataStruct,
          true,
          structBuilder: FamilyMemberStruct.fromSerializableMap,
        ),
        familyAmount: deserializeParam(
          data['familyAmount'],
          ParamType.int,
          false,
        ),
        sumChecked: deserializeParam(
          data['sumChecked'],
          ParamType.int,
          false,
        ),
        isLocalSession: deserializeParam(
          data['isLocalSession'],
          ParamType.bool,
          false,
        ),
        isMock: deserializeParam(
          data['isMock'],
          ParamType.bool,
          false,
        ),
      );

  @override
  String toString() => 'UserSessionStruct(${toMap()})';

  @override
  bool operator ==(Object other) {
    const listEquality = ListEquality();
    return other is UserSessionStruct &&
        userID == other.userID &&
        name == other.name &&
        email == other.email &&
        sessionId == other.sessionId &&
        listEquality.equals(family, other.family) &&
        familyAmount == other.familyAmount &&
        sumChecked == other.sumChecked &&
        isLocalSession == other.isLocalSession;
  }

  @override
  int get hashCode => const ListEquality()
      .hash([userID, name, email, sessionId, family, familyAmount, sumChecked, isLocalSession]);
}

UserSessionStruct createUserSessionStruct({
  String? userID,
  String? name,
  String? email,
  String? sessionId,
  int? familyAmount,
  int? sumChecked,
  bool? isLocalSession,
  bool? isMock,
}) =>
    UserSessionStruct(
      userID: userID,
      name: name,
      email: email,
      sessionId: sessionId,
      familyAmount: familyAmount,
      sumChecked: sumChecked,
      isLocalSession: isLocalSession,
      isMock: isMock
    );
