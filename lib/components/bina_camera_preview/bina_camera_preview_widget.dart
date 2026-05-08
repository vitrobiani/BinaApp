import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mjpeg_stream/mjpeg_stream.dart';
import '/app_core/app_theme.dart';
import '/app_core/app_util.dart';
import '/app_core/app_widgets.dart';
import '/services/mjpeg_capture_service.dart';

class BinaCameraPreviewWidget extends StatefulWidget {
  const BinaCameraPreviewWidget({
    super.key,
    required this.cameraIP,
    required this.cameraPort,
  });

  final String cameraIP;
  final int cameraPort;

  @override
  State<BinaCameraPreviewWidget> createState() => _BinaCameraPreviewWidgetState();
}

class _BinaCameraPreviewWidgetState extends State<BinaCameraPreviewWidget> {
  bool _isCapturing = false;
  String? _errorMessage;

  String get streamUrl => 'http://${widget.cameraIP}:${widget.cameraPort}/stream.mjpg';

  Future<void> _capturePhoto() async {
    if (_isCapturing) return;

    setState(() {
      _isCapturing = true;
      _errorMessage = null;
    });

    try {
      final imagePath = await MjpegCaptureService.instance.captureFrame(
        cameraIP: widget.cameraIP,
        port: widget.cameraPort,
      );

      if (imagePath != null) {
        if (mounted) {
          Navigator.of(context).pop(imagePath);
        }
      } else {
        setState(() {
          _errorMessage = 'Failed to capture image';
          _isCapturing = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error: ${e.toString()}';
        _isCapturing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: BoxDecoration(
        color: AppTheme.of(context).secondaryBackground,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24.0),
          topRight: Radius.circular(24.0),
        ),
      ),
      child: Column(
        children: [
          // Handle bar
          Padding(
            padding: const EdgeInsets.only(top: 12.0),
            child: Container(
              width: 40.0,
              height: 4.0,
              decoration: BoxDecoration(
                color: AppTheme.of(context).alternate,
                borderRadius: BorderRadius.circular(2.0),
              ),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Bina Camera Preview',
                  style: AppTheme.of(context).headlineSmall.override(
                        font: GoogleFonts.inter(),
                        letterSpacing: 0.0,
                      ),
                ),
                IconButton(
                  icon: Icon(
                    Icons.close,
                    color: AppTheme.of(context).secondaryText,
                  ),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),

          // Stream preview
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppTheme.of(context).primaryBackground,
                  borderRadius: BorderRadius.circular(16.0),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16.0),
                  child: MJPEGStreamScreen(
                    streamUrl: streamUrl,
                    fit: BoxFit.contain,
                    showLiveIcon: true,
                  ),
                ),
              ),
            ),
          ),

          // Error message
          if (_errorMessage != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Container(
                padding: const EdgeInsets.all(12.0),
                decoration: BoxDecoration(
                  color: AppTheme.of(context).error.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.error_outline,
                      color: AppTheme.of(context).error,
                      size: 20.0,
                    ),
                    const SizedBox(width: 8.0),
                    Expanded(
                      child: Text(
                        _errorMessage!,
                        style: AppTheme.of(context).bodySmall.override(
                              font: GoogleFonts.inter(),
                              color: AppTheme.of(context).error,
                              letterSpacing: 0.0,
                            ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // Capture button
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: AppButtonWidget(
                    onPressed: () => Navigator.of(context).pop(),
                    text: 'Cancel',
                    options: AppButtonOptions(
                      height: 56.0,
                      color: AppTheme.of(context).primaryBackground,
                      textStyle: AppTheme.of(context).titleSmall.override(
                            font: GoogleFonts.inter(),
                            color: AppTheme.of(context).primaryText,
                            letterSpacing: 0.0,
                          ),
                      elevation: 0.0,
                      borderSide: BorderSide(
                        color: AppTheme.of(context).alternate,
                        width: 1.0,
                      ),
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                  ),
                ),
                const SizedBox(width: 16.0),
                Expanded(
                  flex: 2,
                  child: AppButtonWidget(
                    onPressed: _isCapturing ? null : _capturePhoto,
                    text: _isCapturing ? 'Capturing...' : 'Capture Photo',
                    icon: _isCapturing
                        ? null
                        : Icon(
                            Icons.camera_alt,
                            color: Colors.white,
                            size: 24.0,
                          ),
                    options: AppButtonOptions(
                      height: 56.0,
                      color: AppTheme.of(context).primary,
                      textStyle: AppTheme.of(context).titleSmall.override(
                            font: GoogleFonts.inter(),
                            color: Colors.white,
                            letterSpacing: 0.0,
                          ),
                      elevation: 3.0,
                      borderRadius: BorderRadius.circular(12.0),
                      disabledColor: AppTheme.of(context).alternate,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Bottom safe area
          SizedBox(height: MediaQuery.of(context).padding.bottom),
        ],
      ),
    );
  }
}

/// Shows the Bina Camera preview and returns the captured image path, or null if cancelled
Future<String?> showBinaCameraPreview(
  BuildContext context, {
  required String cameraIP,
  required int cameraPort,
}) {
  return showModalBottomSheet<String>(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    isDismissible: true,
    enableDrag: true,
    builder: (context) => BinaCameraPreviewWidget(
      cameraIP: cameraIP,
      cameraPort: cameraPort,
    ),
  );
}
