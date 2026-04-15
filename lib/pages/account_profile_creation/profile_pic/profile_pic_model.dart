import '/app_core/app_util.dart';
import 'profile_pic_widget.dart' show ProfilePicWidget;
import 'package:flutter/material.dart';

class ProfilePicModel extends AppModel<ProfilePicWidget> {
  ///  State fields for stateful widgets in this component.

  bool isDataUploading_uploadDataUox = false;
  AppUploadedFile uploadedLocalFile_uploadDataUox =
      AppUploadedFile(bytes: Uint8List.fromList([]), originalFilename: '');

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {}
}
