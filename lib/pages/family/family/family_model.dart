import '/app_core/app_util.dart';
import '/pages/family/family_row_detail/family_row_detail_widget.dart';
import '/index.dart';
import 'family_widget.dart' show FamilyWidget;
import 'package:flutter/material.dart';

class FamilyModel extends AppModel<FamilyWidget> {
  ///  State fields for stateful widgets in this page.

  // State field(s) for emailAddress widget.
  FocusNode? emailAddressFocusNode;
  TextEditingController? emailAddressTextController;
  String? Function(BuildContext, String?)? emailAddressTextControllerValidator;
  // Models for FamilyRowDetail dynamic component.
  late AppDynamicModels<FamilyRowDetailModel> familyRowDetailModels;

  @override
  void initState(BuildContext context) {
    familyRowDetailModels =
        AppDynamicModels(() => FamilyRowDetailModel());
  }

  @override
  void dispose() {
    emailAddressFocusNode?.dispose();
    emailAddressTextController?.dispose();

    familyRowDetailModels.dispose();
  }
}
