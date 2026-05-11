import '/app_core/app_util.dart';
import 'help_support_widget.dart' show HelpSupportWidget;
import 'package:flutter/material.dart';

class HelpSupportModel extends AppModel<HelpSupportWidget> {
  // Text controllers for feedback form
  TextEditingController? feedbackController;

  // Track expanded FAQ items
  Set<int> expandedFaqItems = {};

  @override
  void initState(BuildContext context) {
    feedbackController = TextEditingController();
  }

  @override
  void dispose() {
    feedbackController?.dispose();
  }

  void toggleFaqItem(int index) {
    if (expandedFaqItems.contains(index)) {
      expandedFaqItems.remove(index);
    } else {
      expandedFaqItems.add(index);
    }
  }

  bool isFaqExpanded(int index) => expandedFaqItems.contains(index);
}
