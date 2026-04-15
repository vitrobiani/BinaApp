import '/app_core/app_util.dart';
import '/pages/nav_pages/web_nav/web_nav_widget.dart';
import '/index.dart';
import 'main_d_iagnostics_widget.dart' show MainDIagnosticsWidget;
import 'package:flutter/material.dart';

class MainDIagnosticsModel extends AppModel<MainDIagnosticsWidget> {
  ///  State fields for stateful widgets in this page.

  // Model for webNav component.
  late WebNavModel webNavModel;
  // State field(s) for TabBar widget.
  TabController? tabBarController;
  int get tabBarCurrentIndex =>
      tabBarController != null ? tabBarController!.index : 0;
  int get tabBarPreviousIndex =>
      tabBarController != null ? tabBarController!.previousIndex : 0;

  // Loading state
  bool isLoading = true;

  @override
  void initState(BuildContext context) {
    webNavModel = createModel(context, () => WebNavModel());
  }

  @override
  void dispose() {
    webNavModel.dispose();
    tabBarController?.dispose();
  }
}
