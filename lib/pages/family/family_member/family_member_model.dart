import '/backend/supabase/supabase.dart';
import '/app_core/app_util.dart';
import '/app_core/form_field_controller.dart';
import 'family_member_widget.dart' show FamilyMemberWidget;
import 'package:flutter/material.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

class FamilyMemberModel extends AppModel<FamilyMemberWidget> {
  ///  State fields for stateful widgets in this component.

  // State field(s) for name widget.
  FocusNode? nameFocusNode;
  TextEditingController? nameTextController;
  String? Function(BuildContext, String?)? nameTextControllerValidator;
  // State field(s) for birthday widget.
  FocusNode? birthdayFocusNode;
  TextEditingController? birthdayTextController;
  late MaskTextInputFormatter birthdayMask;
  String? Function(BuildContext, String?)? birthdayTextControllerValidator;
  DateTime? datePicked;
  // State field(s) for gender widget.
  String? genderValue;
  FormFieldController<String>? genderValueController;
  // Stores action output result for [Custom Action - getUUID] action in Button widget.
  String? uid;
  // Stores action output result for [Backend Call - Insert Row] action in Button widget.
  FamilyMembersRow? uInfo;

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {
    nameFocusNode?.dispose();
    nameTextController?.dispose();

    birthdayFocusNode?.dispose();
    birthdayTextController?.dispose();
  }
}
