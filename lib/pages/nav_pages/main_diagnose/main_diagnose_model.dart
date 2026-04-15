import '/backend/supabase/supabase.dart';
import '/components/diagnose_page/diagnose_card/diagnose_card_widget.dart';
import '/app_core/app_util.dart';
import '/pages/nav_pages/web_nav/web_nav_widget.dart';
import '/index.dart';
import 'main_diagnose_widget.dart' show MainDiagnoseWidget;
import 'package:flutter/material.dart';

class MainDiagnoseModel extends AppModel<MainDiagnoseWidget> {
  ///  State fields for stateful widgets in this page.

  // Model for webNav component.
  late WebNavModel webNavModel;
  // Models for diagnoseCard dynamic component.
  late AppDynamicModels<DiagnoseCardModel> diagnoseCardModels;
  // Stores action output result for [Backend Call - Update Row(s)] action in diagnoseCard widget.
  List<FamilyMembersRow>? uInfo;

  @override
  void initState(BuildContext context) {
    webNavModel = createModel(context, () => WebNavModel());
    diagnoseCardModels = AppDynamicModels(() => DiagnoseCardModel());
  }

  @override
  void dispose() {
    webNavModel.dispose();
    diagnoseCardModels.dispose();
  }
}
