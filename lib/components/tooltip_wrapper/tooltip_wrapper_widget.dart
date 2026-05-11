import 'package:flutter/material.dart';
import '/services/accessibility_settings_service.dart';

/// A wrapper widget that shows tooltips on long-press when hints mode is enabled.
///
/// Usage:
/// ```dart
/// TooltipWrapper(
///   message: 'This button saves your progress',
///   child: SaveButton(),
/// )
/// ```
///
/// The tooltip will only appear if:
/// 1. Hints mode is enabled in AccessibilitySettingsService
/// 2. The user long-presses on the widget
///
/// You can also force the tooltip to always show (ignoring hints setting)
/// by setting [alwaysShow] to true.
class TooltipWrapper extends StatelessWidget {
  const TooltipWrapper({
    super.key,
    required this.message,
    required this.child,
    this.alwaysShow = false,
    this.preferBelow = true,
    this.verticalOffset,
    this.showDuration = const Duration(seconds: 2),
  });

  /// The tooltip message to display
  final String message;

  /// The child widget to wrap
  final Widget child;

  /// If true, always show tooltip regardless of hints setting
  final bool alwaysShow;

  /// Whether to prefer showing the tooltip below the widget
  final bool preferBelow;

  /// Vertical offset from the widget
  final double? verticalOffset;

  /// How long to show the tooltip
  final Duration showDuration;

  @override
  Widget build(BuildContext context) {
    // Check if hints are enabled
    bool hintsEnabled;
    try {
      hintsEnabled = AccessibilitySettingsService.instance.hintsEnabled;
    } catch (_) {
      hintsEnabled = false;
    }

    // If hints disabled and not forced, just return child
    if (!hintsEnabled && !alwaysShow) {
      return child;
    }

    // Wrap with Tooltip
    return Tooltip(
      message: message,
      preferBelow: preferBelow,
      verticalOffset: verticalOffset ?? 24.0,
      showDuration: showDuration,
      triggerMode: TooltipTriggerMode.longPress,
      child: child,
    );
  }
}

/// Extension to easily wrap any widget with a tooltip
extension TooltipExtension on Widget {
  /// Wraps this widget with a TooltipWrapper
  ///
  /// Usage:
  /// ```dart
  /// MyButton().withTooltip('Click to save')
  /// ```
  Widget withTooltip(String message, {bool alwaysShow = false}) {
    return TooltipWrapper(
      message: message,
      alwaysShow: alwaysShow,
      child: this,
    );
  }
}
