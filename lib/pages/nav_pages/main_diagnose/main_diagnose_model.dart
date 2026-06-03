import '/app_core/app_util.dart';
import '/pages/nav_pages/web_nav/web_nav_widget.dart';
import 'main_diagnose_widget.dart' show MainDiagnoseWidget;
import 'package:flutter/material.dart';

class MainDiagnoseModel extends AppModel<MainDiagnoseWidget> {
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
