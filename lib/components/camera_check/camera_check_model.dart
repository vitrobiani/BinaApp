import '/app_core/app_util.dart';
import '/app_core/instant_timer.dart';
import 'camera_check_widget.dart' show CameraCheckWidget;
import 'package:flutter/material.dart';

class CameraCheckModel extends AppModel<CameraCheckWidget> {
  ///  Local state fields for this component.

  int? counter = 0;

  ///  State fields for stateful widgets in this component.

  InstantTimer? instantTimer;

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {
    instantTimer?.cancel();
  }
}
