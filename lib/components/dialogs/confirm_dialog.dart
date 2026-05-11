import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '/app_core/app_theme.dart';

/// A reusable confirmation dialog for destructive actions.
///
/// Usage:
/// ```dart
/// final confirmed = await ConfirmDialog.show(
///   context: context,
///   title: 'Delete Item?',
///   message: 'This action cannot be undone.',
///   confirmText: 'Delete',
///   isDestructive: true,
/// );
/// if (confirmed) { /* perform action */ }
/// ```
class ConfirmDialog {
  /// Shows a confirmation dialog and returns true if confirmed, false otherwise.
  static Future<bool> show({
    required BuildContext context,
    required String title,
    required String message,
    String confirmText = 'Confirm',
    String cancelText = 'Cancel',
    bool isDestructive = false,
    IconData? icon,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => _ConfirmDialogContent(
        title: title,
        message: message,
        confirmText: confirmText,
        cancelText: cancelText,
        isDestructive: isDestructive,
        icon: icon,
      ),
    );
    return result ?? false;
  }
}

class _ConfirmDialogContent extends StatelessWidget {
  const _ConfirmDialogContent({
    required this.title,
    required this.message,
    required this.confirmText,
    required this.cancelText,
    required this.isDestructive,
    this.icon,
  });

  final String title;
  final String message;
  final String confirmText;
  final String cancelText;
  final bool isDestructive;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    final confirmColor = isDestructive ? theme.error : theme.primary;

    return AlertDialog(
      backgroundColor: theme.secondaryBackground,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
      ),
      title: Row(
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              color: isDestructive ? theme.error : theme.primary,
              size: 24.0,
            ),
            const SizedBox(width: 12.0),
          ],
          Expanded(
            child: Text(
              title,
              style: theme.titleMedium.override(
                font: GoogleFonts.inter(),
                color: theme.primaryText,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      content: Text(
        message,
        style: theme.bodyMedium.override(
          font: GoogleFonts.inter(),
          color: theme.secondaryText,
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(
            cancelText,
            style: GoogleFonts.inter(
              color: theme.secondaryText,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(true),
          style: TextButton.styleFrom(
            backgroundColor: confirmColor.withValues(alpha: 0.1),
          ),
          child: Text(
            confirmText,
            style: GoogleFonts.inter(
              color: confirmColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
