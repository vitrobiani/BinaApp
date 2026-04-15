import '/app_core/app_util.dart';
import 'chat_room_widget.dart' show ChatRoomWidget;
import 'package:flutter/material.dart';

class ChatRoomModel extends AppModel<ChatRoomWidget> {
  // State field for message input.
  final TextEditingController messageController = TextEditingController();
  final FocusNode messageFocusNode = FocusNode();

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {
    messageController.dispose();
    messageFocusNode.dispose();
  }
}
