import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '/app_core/app_theme.dart';
import '/services/gemma_service.dart';

/// A widget that shows Gemma model download progress
/// Use this in screens that need the Gemma model
class GemmaDownloadProgressWidget extends StatefulWidget {
  const GemmaDownloadProgressWidget({
    super.key,
    this.onModelReady,
  });

  /// Called when the model is loaded and ready to use
  final VoidCallback? onModelReady;

  @override
  State<GemmaDownloadProgressWidget> createState() =>
      _GemmaDownloadProgressWidgetState();
}

class _GemmaDownloadProgressWidgetState
    extends State<GemmaDownloadProgressWidget> {
  final GemmaService _gemmaService = GemmaService.instance;
  Timer? _refreshTimer;
  bool _hasError = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _startModelInit();
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  void _startModelInit() {
    // Start refreshing UI to show progress
    _refreshTimer = Timer.periodic(const Duration(milliseconds: 500), (_) {
      if (mounted) {
        setState(() {});
        if (_gemmaService.isModelLoaded) {
          _refreshTimer?.cancel();
          widget.onModelReady?.call();
        }
      }
    });

    // Start download if not already in progress
    if (!_gemmaService.isModelLoaded && !_gemmaService.isDownloading) {
      _gemmaService.init().catchError((e) {
        if (mounted) {
          setState(() {
            _hasError = true;
            _errorMessage = e.toString();
          });
        }
      });
    }
  }

  void _retry() {
    setState(() {
      _hasError = false;
      _errorMessage = '';
    });
    _startModelInit();
  }

  @override
  Widget build(BuildContext context) {
    if (_gemmaService.isModelLoaded) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.all(16.0),
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: AppTheme.of(context).primaryBackground,
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(
          color: AppTheme.of(context).alternate,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Icon
          Icon(
            _hasError ? Icons.error_outline : Icons.download_rounded,
            size: 48.0,
            color: _hasError
                ? AppTheme.of(context).error
                : AppTheme.of(context).primary,
          ),
          const SizedBox(height: 16.0),

          // Title
          Text(
            _hasError
                ? 'Download Failed'
                : _gemmaService.isDownloading
                    ? 'Downloading AI Model'
                    : 'Preparing AI Model',
            style: AppTheme.of(context).titleMedium.override(
                  font: GoogleFonts.inter(),
                  letterSpacing: 0.0,
                ),
          ),
          const SizedBox(height: 8.0),

          // Model info
          Text(
            '${_gemmaService.modelName} (${_gemmaService.modelSizeDescription})',
            style: AppTheme.of(context).bodySmall.override(
                  font: GoogleFonts.inter(),
                  color: AppTheme.of(context).secondaryText,
                  letterSpacing: 0.0,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16.0),

          if (_hasError) ...[
            // Error message
            Text(
              _errorMessage,
              style: AppTheme.of(context).bodySmall.override(
                    font: GoogleFonts.inter(),
                    color: AppTheme.of(context).error,
                    letterSpacing: 0.0,
                  ),
              textAlign: TextAlign.center,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 16.0),
            // Retry button
            ElevatedButton.icon(
              onPressed: _retry,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.of(context).primary,
                foregroundColor: Colors.white,
              ),
            ),
          ] else ...[
            // Progress bar
            ClipRRect(
              borderRadius: BorderRadius.circular(8.0),
              child: LinearProgressIndicator(
                value: _gemmaService.isDownloading
                    ? _gemmaService.downloadProgress
                    : null, // Indeterminate if not downloading yet
                minHeight: 8.0,
                backgroundColor: AppTheme.of(context).alternate,
                valueColor: AlwaysStoppedAnimation<Color>(
                  AppTheme.of(context).primary,
                ),
              ),
            ),
            const SizedBox(height: 8.0),

            // Status text
            Text(
              _gemmaService.downloadStatus.isNotEmpty
                  ? _gemmaService.downloadStatus
                  : 'Initializing...',
              style: AppTheme.of(context).bodySmall.override(
                    font: GoogleFonts.inter(),
                    color: AppTheme.of(context).secondaryText,
                    letterSpacing: 0.0,
                  ),
            ),

            if (_gemmaService.isDownloading) ...[
              const SizedBox(height: 4.0),
              Text(
                '${(_gemmaService.downloadProgress * 100).toInt()}%',
                style: AppTheme.of(context).titleSmall.override(
                      font: GoogleFonts.inter(),
                      color: AppTheme.of(context).primary,
                      letterSpacing: 0.0,
                    ),
              ),
            ],
          ],
        ],
      ),
    );
  }
}
