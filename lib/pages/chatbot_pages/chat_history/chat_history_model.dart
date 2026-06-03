import '/app_core/app_util.dart';
import '/pages/nav_pages/web_nav/web_nav_widget.dart';
import 'chat_history_widget.dart' show ChatHistoryWidget;
import 'package:flutter/material.dart';

class ChatHistoryModel extends AppModel<ChatHistoryWidget> {
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
