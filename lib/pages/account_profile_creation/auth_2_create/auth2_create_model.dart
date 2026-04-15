import '/app_core/app_util.dart';
import '/app_core/form_field_controller.dart';
import '/index.dart';
import 'auth2_create_widget.dart' show Auth2CreateWidget;
import 'package:flutter/material.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

class Auth2CreateModel extends AppModel<Auth2CreateWidget> {
  ///  State fields for stateful widgets in this page.

  // State field(s) for Switch widget.
  bool? switchValue;
  // State field(s) for name widget.
  FocusNode? nameFocusNode;
  TextEditingController? nameTextController;
  String? Function(BuildContext, String?)? nameTextControllerValidator;
  // State field(s) for emailAddress widget.
  FocusNode? emailAddressFocusNode;
  TextEditingController? emailAddressTextController;
  String? Function(BuildContext, String?)? emailAddressTextControllerValidator;
  // State field(s) for password widget.
  FocusNode? passwordFocusNode;
  TextEditingController? passwordTextController;
  late bool passwordVisibility;
  String? Function(BuildContext, String?)? passwordTextControllerValidator;
  // State field(s) for age widget.
  FocusNode? ageFocusNode;
  TextEditingController? ageTextController;
  late MaskTextInputFormatter ageMask;
  String? Function(BuildContext, String?)? ageTextControllerValidator;
  DateTime? datePicked;
  // State field(s) for gender widget.
  String? genderValue;
  FormFieldController<String>? genderValueController;
  // Stores action output result for [Custom Action - getUUID] action in Button widget.
  String? userID;
  // Stores action output result for [Custom Action - getUUID] action in Button widget.
  String? familyMemberID;
  // Stores action output result for [Custom Action - hashPassword] action in Button widget.
  String? hashedPW;

  @override
  void initState(BuildContext context) {
    passwordVisibility = false;
  }

  @override
  void dispose() {
    nameFocusNode?.dispose();
    nameTextController?.dispose();

    emailAddressFocusNode?.dispose();
    emailAddressTextController?.dispose();

    passwordFocusNode?.dispose();
    passwordTextController?.dispose();

    ageFocusNode?.dispose();
    ageTextController?.dispose();
  }
}
