import '/app_core/app_theme.dart';
import '/app_core/app_util.dart';
import '/app_state.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'camera_selection_dialog_model.dart';
export 'camera_selection_dialog_model.dart';

enum CameraSource {
  phoneCamera,
  binaCamera,
}

class CameraSelectionDialogWidget extends StatefulWidget {
  const CameraSelectionDialogWidget({super.key});

  @override
  State<CameraSelectionDialogWidget> createState() =>
      _CameraSelectionDialogWidgetState();
}

class _CameraSelectionDialogWidgetState
    extends State<CameraSelectionDialogWidget> {
  late CameraSelectionDialogModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => CameraSelectionDialogModel());
  }

  @override
  void dispose() {
    _model.maybeDispose();
    super.dispose();
  }

  void _selectCamera(CameraSource source) {
    Navigator.of(context).pop(source);
  }

  @override
  Widget build(BuildContext context) {
    final cameraConnection = AppState().cameraConnection;
    final isBinaCameraConnected = cameraConnection.isCameraConnected();

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.of(context).secondaryBackground,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24.0),
          topRight: Radius.circular(24.0),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle bar
            Center(
              child: Container(
                width: 40.0,
                height: 4.0,
                decoration: BoxDecoration(
                  color: AppTheme.of(context).alternate,
                  borderRadius: BorderRadius.circular(2.0),
                ),
              ),
            ),
            const SizedBox(height: 24.0),

            // Title
            Text(
              'Select Camera',
              style: AppTheme.of(context).headlineSmall.override(
                    font: GoogleFonts.inter(),
                    letterSpacing: 0.0,
                  ),
            ),
            const SizedBox(height: 8.0),
            Text(
              'Choose which camera to use for capturing images',
              style: AppTheme.of(context).bodyMedium.override(
                    font: GoogleFonts.inter(),
                    color: AppTheme.of(context).secondaryText,
                    letterSpacing: 0.0,
                  ),
            ),
            const SizedBox(height: 24.0),

            // Phone Camera Option
            _CameraOptionTile(
              title: 'Phone Camera',
              subtitle: 'Use your device\'s built-in camera',
              icon: Icons.camera_alt,
              onTap: () => _selectCamera(CameraSource.phoneCamera),
            ),

            const SizedBox(height: 12.0),

            // Bina Camera Option
            _CameraOptionTile(
              title: 'Bina Camera',
              subtitle: isBinaCameraConnected
                  ? 'Connected - ${cameraConnection.cameraHost}'
                  : 'Not connected',
              icon: Icons.videocam,
              isEnabled: isBinaCameraConnected,
              isHighlighted: isBinaCameraConnected,
              onTap: isBinaCameraConnected
                  ? () => _selectCamera(CameraSource.binaCamera)
                  : null,
            ),

            if (!isBinaCameraConnected) ...[
              const SizedBox(height: 16.0),
              Container(
                padding: const EdgeInsets.all(12.0),
                decoration: BoxDecoration(
                  color: AppTheme.of(context).primaryBackground,
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      size: 20.0,
                      color: AppTheme.of(context).secondaryText,
                    ),
                    const SizedBox(width: 12.0),
                    Expanded(
                      child: Text(
                        'Connect to Bina Camera from the camera connection page to use it here.',
                        style: AppTheme.of(context).bodySmall.override(
                              font: GoogleFonts.inter(),
                              color: AppTheme.of(context).secondaryText,
                              letterSpacing: 0.0,
                            ),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 24.0),

            // Cancel button
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () => Navigator.of(context).pop(),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                ),
                child: Text(
                  'Cancel',
                  style: AppTheme.of(context).titleSmall.override(
                        font: GoogleFonts.inter(),
                        color: AppTheme.of(context).secondaryText,
                        letterSpacing: 0.0,
                      ),
                ),
              ),
            ),

            // Bottom safe area padding
            SizedBox(height: MediaQuery.of(context).padding.bottom),
          ],
        ),
      ),
    );
  }
}

class _CameraOptionTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final bool isEnabled;
  final bool isHighlighted;
  final VoidCallback? onTap;

  const _CameraOptionTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    this.isEnabled = true,
    this.isHighlighted = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: isEnabled ? onTap : null,
        borderRadius: BorderRadius.circular(16.0),
        child: Container(
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: isEnabled
                ? AppTheme.of(context).primaryBackground
                : AppTheme.of(context).primaryBackground.withOpacity(0.5),
            borderRadius: BorderRadius.circular(16.0),
            border: isHighlighted
                ? Border.all(
                    color: AppTheme.of(context).primary,
                    width: 2.0,
                  )
                : Border.all(
                    color: AppTheme.of(context).alternate,
                    width: 1.0,
                  ),
          ),
          child: Row(
            children: [
              Container(
                width: 48.0,
                height: 48.0,
                decoration: BoxDecoration(
                  color: isHighlighted
                      ? AppTheme.of(context).primary.withOpacity(0.1)
                      : AppTheme.of(context).secondaryBackground,
                  borderRadius: BorderRadius.circular(12.0),
                ),
                child: Icon(
                  icon,
                  size: 24.0,
                  color: isEnabled
                      ? (isHighlighted
                          ? AppTheme.of(context).primary
                          : AppTheme.of(context).primaryText)
                      : AppTheme.of(context).secondaryText,
                ),
              ),
              const SizedBox(width: 16.0),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTheme.of(context).titleSmall.override(
                            font: GoogleFonts.inter(),
                            color: isEnabled
                                ? AppTheme.of(context).primaryText
                                : AppTheme.of(context).secondaryText,
                            letterSpacing: 0.0,
                          ),
                    ),
                    const SizedBox(height: 4.0),
                    Text(
                      subtitle,
                      style: AppTheme.of(context).bodySmall.override(
                            font: GoogleFonts.inter(),
                            color: isHighlighted
                                ? AppTheme.of(context).success
                                : AppTheme.of(context).secondaryText,
                            letterSpacing: 0.0,
                          ),
                    ),
                  ],
                ),
              ),
              if (isEnabled)
                Icon(
                  Icons.chevron_right,
                  color: AppTheme.of(context).secondaryText,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Helper function to show the camera selection dialog
Future<CameraSource?> showCameraSelectionDialog(BuildContext context) {
  return showModalBottomSheet<CameraSource>(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (context) => const CameraSelectionDialogWidget(),
  );
}
