import 'dart:async';
import 'dart:io';

import 'package:bina_system/custom_code/actions/index.dart';
import 'package:flutter/material.dart';
import 'package:mjpeg_stream/mjpeg_stream.dart';
import 'package:image/image.dart' as img;
import '/bina_design/bina_design.dart';
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
  Timer? _analysisTimer;
  bool _isCapturing = false;
  String? _errorMessage;
  YoloResult? _detections;
  bool _isAnalyzing = false;

  // Image dimensions from last capture (for scaling overlay)
  int _imageWidth = 640;
  int _imageHeight = 480;

  String get streamUrl => 'http://${widget.cameraIP}:${widget.cameraPort}/stream.mjpg';

  @override
  void initState() {
    super.initState();
    debugPrint('>>> BinaCameraPreviewWidget initState - starting real-time analysis');
    _startRealTimeAnalysis();
  }

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

  void _startRealTimeAnalysis() {
    debugPrint('>>> Starting real-time analysis timer (500ms interval)');
    // Run every 500ms (2 fps) - adjust as needed
    _analysisTimer = Timer.periodic(Duration(milliseconds: 500), (timer) {
      _captureAndAnalyze();
    });
  }

  void _stopRealTimeAnalysis() {
    _analysisTimer?.cancel();
    _analysisTimer = null;
  }

  @override
  void dispose() {
    _analysisTimer?.cancel();
    super.dispose();
  }

  Future<void> _captureAndAnalyze() async {
    debugPrint('>>> _captureAndAnalyze called, _isAnalyzing=$_isAnalyzing');
    if (_isAnalyzing) return;
    _isAnalyzing = true;

    try {
      debugPrint('>>> Capturing frame from ${widget.cameraIP}:${widget.cameraPort}');
      final imagePath = await MjpegCaptureService.instance.captureFrame(
        cameraIP: widget.cameraIP,
        port: widget.cameraPort,
      );
      debugPrint('>>> Captured: $imagePath');
      if (imagePath != null){
        // Get image dimensions for scaling
        final imageBytes = await File(imagePath).readAsBytes();
        final decodedImage = img.decodeImage(imageBytes);
        if (decodedImage != null) {
          _imageWidth = decodedImage.width;
          _imageHeight = decodedImage.height;
        }

        YoloResult res = await runYoloInference(imagePath);
        debugPrint('=== DETECTIONS: ${res.detections.length} (image: ${_imageWidth}x${_imageHeight}) ===');
        for (final det in res.detections) {
          debugPrint('  ${det['className']}: ${(det['confidence'] * 100).toStringAsFixed(1)}% at (${det['x1'].toStringAsFixed(0)}, ${det['y1'].toStringAsFixed(0)}) -> (${det['x2'].toStringAsFixed(0)}, ${det['y2'].toStringAsFixed(0)})');
        }
        if (mounted) {
          setState(() {
            _detections = res;
          });
        }
      }
      else
        _detections = null;
    } catch (e, stack) {
      debugPrint(">>> ERROR in _captureAndAnalyze: $e");
      debugPrint(">>> Stack: $stack");
    } finally {
      _isAnalyzing = false;
    }
  }

  Widget _BboxOverlay() {
    if (_detections == null || _detections!.detections.isEmpty) {
      return const SizedBox.shrink();
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        // Calculate scale factors from image coords to widget coords
        // The video uses BoxFit.contain, so we need to account for aspect ratio
        final widgetWidth = constraints.maxWidth;
        final widgetHeight = constraints.maxHeight;

        final imageAspect = _imageWidth / _imageHeight;
        final widgetAspect = widgetWidth / widgetHeight;

        double scaleX, scaleY, offsetX = 0, offsetY = 0;

        if (imageAspect > widgetAspect) {
          // Image is wider - letterbox top/bottom
          scaleX = widgetWidth / _imageWidth;
          scaleY = scaleX;
          offsetY = (widgetHeight - (_imageHeight * scaleY)) / 2;
        } else {
          // Image is taller - pillarbox left/right
          scaleY = widgetHeight / _imageHeight;
          scaleX = scaleY;
          offsetX = (widgetWidth - (_imageWidth * scaleX)) / 2;
        }

        debugPrint('Overlay scale: ${scaleX.toStringAsFixed(3)} offset: ($offsetX, $offsetY)');

        return Stack(
          children: [
            for (final det in _detections!.detections)
              Positioned(
                left: (det['x1'] as double) * scaleX + offsetX,
                top: (det['y1'] as double) * scaleY + offsetY,
                width: ((det['x2'] as double) - (det['x1'] as double)) * scaleX,
                height: ((det['y2'] as double) - (det['y1'] as double)) * scaleY,
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.red, width: 2),
                  ),
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                      color: Colors.red,
                      child: Text(
                        '${det['className']} ${((det['confidence'] as double) * 100).toStringAsFixed(0)}%',
                        style: const TextStyle(color: Colors.white, fontSize: 10),
                      ),
                    ),
                  ),
                ),
              )
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: BoxDecoration(
        color: BinaColors.surface,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Column(
        children: [
          // Handle bar
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: BinaColors.lineStrong,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 12, 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Bina Camera',
                      style: BinaType.headlineSm,
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: BinaColors.success,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Connected · ${widget.cameraIP}',
                          style: BinaType.bodySm.copyWith(color: BinaColors.ink2),
                        ),
                      ],
                    ),
                  ],
                ),
                BinaIconButton(
                  icon: Icons.close_rounded,
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),

          // Stream preview
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: BinaColors.surfaceSunken,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: BinaColors.line, width: 2),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(18),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      // Stream
                      MJPEGStreamScreen(
                        streamUrl: streamUrl,
                        fit: BoxFit.contain,
                        showLiveIcon: true,
                      ),
                      // Live indicator overlay
                      Positioned(
                        top: 12,
                        left: 12,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: BinaColors.error,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 6,
                                height: 6,
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'LIVE',
                                style: BinaType.labelSm.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      _BboxOverlay(),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Error message
          if (_errorMessage != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: BinaColors.error100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.error_outline_rounded,
                      color: BinaColors.error,
                      size: 20,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        _errorMessage!,
                        style: BinaType.bodySm.copyWith(color: BinaColors.error),
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // Capture button
          Padding(
            padding: EdgeInsets.fromLTRB(16, 16, 16, 16 + bottomPadding),
            child: Row(
              children: [
                // Cancel button
                Expanded(
                  child: BinaButton(
                    label: 'Cancel',
                    variant: BinaButtonVariant.secondary,
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ),
                const SizedBox(width: 12),
                // Capture button
                Expanded(
                  flex: 2,
                  child: _CaptureButton(
                    isCapturing: _isCapturing,
                    onPressed: _capturePhoto,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// CAPTURE BUTTON
// ═══════════════════════════════════════════════════════════════

class _CaptureButton extends StatefulWidget {
  const _CaptureButton({
    required this.isCapturing,
    required this.onPressed,
  });

  final bool isCapturing;
  final VoidCallback onPressed;

  @override
  State<_CaptureButton> createState() => _CaptureButtonState();
}

class _CaptureButtonState extends State<_CaptureButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final isEnabled = !widget.isCapturing;

    return GestureDetector(
      onTapDown: isEnabled ? (_) => setState(() => _isPressed = true) : null,
      onTapUp: isEnabled ? (_) => setState(() => _isPressed = false) : null,
      onTapCancel: isEnabled ? () => setState(() => _isPressed = false) : null,
      onTap: isEnabled ? widget.onPressed : null,
      child: AnimatedContainer(
        duration: BinaMotion.d1,
        height: 56,
        transform: _isPressed
            ? (Matrix4.identity()..scale(0.97, 0.97))
            : Matrix4.identity(),
        transformAlignment: Alignment.center,
        decoration: BoxDecoration(
          gradient: isEnabled ? BinaColors.gradHero : null,
          color: isEnabled ? null : BinaColors.surfaceSunken,
          borderRadius: BorderRadius.circular(16),
          boxShadow: isEnabled ? BinaElevation.shHero : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (widget.isCapturing) ...[
              SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white.withValues(alpha: 0.8),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                'Capturing...',
                style: BinaType.labelLg.copyWith(
                  color: Colors.white,
                ),
              ),
            ] else ...[
              const Icon(
                Icons.camera_alt_rounded,
                color: Colors.white,
                size: 22,
              ),
              const SizedBox(width: 10),
              Text(
                'Capture Photo',
                style: BinaType.labelLg.copyWith(
                  color: Colors.white,
                ),
              ),
            ],
          ],
        ),
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
