import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '/app_core/app_theme.dart';

/// A reusable loading dialog for long-running operations.
///
/// Usage:
/// ```dart
/// // Show loading
/// LoadingDialog.show(context: context, message: 'Saving...');
///
/// // Do async work
/// await someAsyncOperation();
///
/// // Hide loading
/// LoadingDialog.hide(context);
/// ```
///
/// Or use the helper:
/// ```dart
/// await LoadingDialog.run(
///   context: context,
///   message: 'Saving...',
///   operation: () async {
///     await someAsyncOperation();
///   },
/// );
/// ```
class LoadingDialog {
  static bool _isShowing = false;

  /// Shows a loading dialog with a message.
  static void show({
    required BuildContext context,
    String message = 'Loading...',
  }) {
    if (_isShowing) return;
    _isShowing = true;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => _LoadingDialogContent(message: message),
    );
  }

  /// Hides the loading dialog.
  static void hide(BuildContext context) {
    if (!_isShowing) return;
    _isShowing = false;
    Navigator.of(context, rootNavigator: true).pop();
  }

  /// Runs an async operation while showing a loading dialog.
  /// Returns the result of the operation.
  static Future<T?> run<T>({
    required BuildContext context,
    required Future<T> Function() operation,
    String message = 'Loading...',
    String? successMessage,
    String? errorMessage,
  }) async {
    show(context: context, message: message);

    try {
      final result = await operation();
      hide(context);

      if (successMessage != null && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(successMessage),
            backgroundColor: AppTheme.of(context).success,
          ),
        );
      }

      return result;
    } catch (e) {
      hide(context);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage ?? 'An error occurred: $e'),
            backgroundColor: AppTheme.of(context).error,
          ),
        );
      }

      return null;
    }
  }
}

class _LoadingDialogContent extends StatelessWidget {
  const _LoadingDialogContent({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);

    return PopScope(
      canPop: false,
      child: Dialog(
        backgroundColor: theme.secondaryBackground,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.0),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(
                color: theme.primary,
              ),
              const SizedBox(height: 16.0),
              Text(
                message,
                textAlign: TextAlign.center,
                style: theme.bodyMedium.override(
                  font: GoogleFonts.inter(),
                  color: theme.primaryText,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
