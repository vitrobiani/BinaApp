import '/app_core/app_util.dart';
import '/pages/nav_pages/web_nav/web_nav_widget.dart';
import '/index.dart';
import 'main_profile_page_widget.dart' show MainProfilePageWidget;
import 'package:flutter/material.dart';

class MainProfilePageModel extends AppModel<MainProfilePageWidget> {
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
