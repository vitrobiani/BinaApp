import '/app_core/app_theme.dart';
import 'package:flutter/material.dart';

/// A bottom action bar for multi-select mode operations.
/// Designed for extensibility - more actions can be added in the future.
class MultiSelectActionBar extends StatelessWidget {
  const MultiSelectActionBar({
    super.key,
    required this.selectedCount,
    required this.onDelete,
    this.onSelectAll,
    this.onDeselectAll,
  });

  final int selectedCount;
  final VoidCallback onDelete;
  final VoidCallback? onSelectAll;
  final VoidCallback? onDeselectAll;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.of(context).secondaryBackground,
        boxShadow: [
          BoxShadow(
            blurRadius: 8.0,
            color: Color(0x20000000),
            offset: Offset(0.0, -2.0),
          ),
        ],
      ),
      padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: SafeArea(
        top: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                if (onSelectAll != null)
                  TextButton(
                    onPressed: onSelectAll,
                    child: Text(
                      'Select All',
                      style: TextStyle(
                        color: AppTheme.of(context).primary,
                      ),
                    ),
                  ),
                if (onDeselectAll != null && selectedCount > 0)
                  TextButton(
                    onPressed: onDeselectAll,
                    child: Text(
                      'Deselect All',
                      style: TextStyle(
                        color: AppTheme.of(context).secondaryText,
                      ),
                    ),
                  ),
              ],
            ),
            ElevatedButton.icon(
              onPressed: selectedCount > 0 ? onDelete : null,
              icon: Icon(Icons.delete_outline),
              label: Text('Delete ($selectedCount)'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.of(context).error,
                foregroundColor: Colors.white,
                disabledBackgroundColor: AppTheme.of(context).alternate,
                disabledForegroundColor: AppTheme.of(context).secondaryText,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
