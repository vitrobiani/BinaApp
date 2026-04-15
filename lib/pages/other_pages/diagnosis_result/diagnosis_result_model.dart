import '/app_core/app_util.dart';
import '/pages/nav_pages/web_nav/web_nav_widget.dart';
import 'diagnosis_result_widget.dart' show DiagnosisResultWidget;
import 'package:flutter/material.dart';

class DiagnosisResultModel extends AppModel<DiagnosisResultWidget> {
  ///  State fields for stateful widgets in this page.

  // Model for webNav component.
  late WebNavModel webNavModel;

  @override
  void initState(BuildContext context) {
    webNavModel = createModel(context, () => WebNavModel());
  }

  @override
  void dispose() {
    webNavModel.dispose();
  }
}
