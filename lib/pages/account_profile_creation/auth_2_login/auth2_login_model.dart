import '/backend/sqlite/sqlite_manager.dart';
import '/app_core/app_util.dart';
import '/index.dart';
import 'auth2_login_widget.dart' show Auth2LoginWidget;
import 'package:flutter/material.dart';

class Auth2LoginModel extends AppModel<Auth2LoginWidget> {
  ///  State fields for stateful widgets in this page.

  // State field(s) for Switch widget.
  bool? switchValue;
  // State field(s) for emailAddress widget.
  FocusNode? emailAddressFocusNode;
  TextEditingController? emailAddressTextController;
  String? Function(BuildContext, String?)? emailAddressTextControllerValidator;
  // State field(s) for password widget.
  FocusNode? passwordFocusNode;
  TextEditingController? passwordTextController;
  late bool passwordVisibility;
  String? Function(BuildContext, String?)? passwordTextControllerValidator;
  // Stores action output result for [Custom Action - hashPassword] action in Button widget.
  String? hashedPW;
  // Stores action output result for [Backend Call - SQLite (LoginByEmail)] action in Button widget.
  List<LoginByEmailRow>? res;
  // Stores action output result for [Backend Call - SQLite (GetFamilyMembersByAccountId)] action in Button widget.
  List<FamilyMemberRow>? familyMembers;

  @override
  void initState(BuildContext context) {
    passwordVisibility = false;
  }

  @override
  void dispose() {
    emailAddressFocusNode?.dispose();
    emailAddressTextController?.dispose();

    passwordFocusNode?.dispose();
    passwordTextController?.dispose();
  }
}
