import '/app_core/app_util.dart';
import 'family_widget.dart' show FamilyWidget;
import 'package:flutter/material.dart';

class FamilyModel extends AppModel<FamilyWidget> {
  @override
  void initState(BuildContext context) {
    // No additional state needed - family data comes from AppState
  }

  @override
  void dispose() {
    // Nothing to dispose
  }
}
