import '/app_core/app_util.dart';
import '/pages/nav_pages/web_nav/web_nav_widget.dart';
import 'photo_session_widget.dart' show PhotoSessionWidget;
import 'package:flutter/material.dart';

class PhotoSessionModel extends AppModel<PhotoSessionWidget> {
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
