import '/app_core/app_util.dart';
import 'diagnosis_cavity_widget.dart' show DiagnosisCavityWidget;
import 'package:flutter/material.dart';

class DiagnosisCavityModel extends AppModel<DiagnosisCavityWidget> {
  ///  State fields for stateful widgets in this page.

  bool isDataUploading_uploadDataS7k = false;
  AppUploadedFile uploadedLocalFile_uploadDataS7k =
      AppUploadedFile(bytes: Uint8List.fromList([]), originalFilename: '');

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {}
}
