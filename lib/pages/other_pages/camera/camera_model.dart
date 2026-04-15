import '/app_core/app_util.dart';
import '/pages/nav_pages/web_nav/web_nav_widget.dart';
import 'camera_widget.dart' show CameraWidget;
import 'package:flutter/material.dart';

class CameraModel extends AppModel<CameraWidget> {
  ///  State fields for stateful widgets in this page.

  final formKey = GlobalKey<FormState>();

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
