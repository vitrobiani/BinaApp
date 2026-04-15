import '/app_core/app_util.dart';
import 'diagnose_card_widget.dart' show DiagnoseCardWidget;
import 'package:flutter/material.dart';

class DiagnoseCardModel extends AppModel<DiagnoseCardWidget> {
  ///  Local state fields for this component.

  bool? didCheckPastWeek;

  ///  State fields for stateful widgets in this component.

  // Stores action output result for [Custom Action - daysSinceLastCheck] action in diagnoseCard widget.
  int? daysSince;

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {}
}
