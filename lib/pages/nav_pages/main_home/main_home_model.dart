import '/components/home_page/home_name_card/home_name_card_widget.dart';
import '/app_core/app_util.dart';
import '/pages/nav_pages/web_nav/web_nav_widget.dart';
import 'main_home_widget.dart' show MainHomeWidget;
import 'package:flutter/material.dart';

class MainHomeModel extends AppModel<MainHomeWidget> {
  ///  State fields for stateful widgets in this page.

  // Model for webNav component.
  late WebNavModel webNavModel;
  // Models for HomeNameCard dynamic component.
  late AppDynamicModels<HomeNameCardModel> homeNameCardModels;

  @override
  void initState(BuildContext context) {
    webNavModel = createModel(context, () => WebNavModel());
    homeNameCardModels = AppDynamicModels(() => HomeNameCardModel());
  }

  @override
  void dispose() {
    webNavModel.dispose();
    homeNameCardModels.dispose();
  }
}
