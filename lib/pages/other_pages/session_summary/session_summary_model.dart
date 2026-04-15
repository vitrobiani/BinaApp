import '/app_core/app_util.dart';
import '/pages/nav_pages/web_nav/web_nav_widget.dart';
import 'session_summary_widget.dart' show SessionSummaryWidget;
import 'package:flutter/material.dart';

class SessionSummaryModel extends AppModel<SessionSummaryWidget> {
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
