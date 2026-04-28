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

  // Multi-select mode state
  bool isMultiSelectMode = false;

  // Selected session IDs (using Set for O(1) lookup)
  Set<String> selectedSessionIds = {};

  // Callback to notify widget of state changes
  VoidCallback? onSelectionChanged;

  /// Enter multi-select mode
  void enterMultiSelectMode() {
    isMultiSelectMode = true;
    selectedSessionIds.clear();
    onSelectionChanged?.call();
  }

  /// Exit multi-select mode and clear selection
  void exitMultiSelectMode() {
    isMultiSelectMode = false;
    selectedSessionIds.clear();
    onSelectionChanged?.call();
  }

  /// Toggle session selection
  void toggleSessionSelection(String sessionId) {
    if (selectedSessionIds.contains(sessionId)) {
      selectedSessionIds.remove(sessionId);
    } else {
      selectedSessionIds.add(sessionId);
    }
    onSelectionChanged?.call();
  }

  /// Select all sessions from provided list
  void selectAllSessions(List<String> sessionIds) {
    selectedSessionIds.addAll(sessionIds);
    onSelectionChanged?.call();
  }

  /// Deselect all sessions
  void deselectAllSessions() {
    selectedSessionIds.clear();
    onSelectionChanged?.call();
  }

  /// Check if a session is selected
  bool isSessionSelected(String sessionId) {
    return selectedSessionIds.contains(sessionId);
  }

  /// Get the count of selected sessions
  int get selectedCount => selectedSessionIds.length;

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
