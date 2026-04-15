import 'dart:io';

import 'package:flutter/foundation.dart' show kIsWeb;
import '/app_core/app_theme.dart';
import '/app_core/app_util.dart';
import '/services/gemma_service.dart';
import '/services/llm_prompts.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'image_detail_sheet_model.dart';
export 'image_detail_sheet_model.dart';

// Helper function to format class names for display
String _formatClassName(String className) {
  final words = className.split('_');
  return words.map((word) {
    if (word.isEmpty) return word;
    return word[0].toUpperCase() + word.substring(1).toLowerCase();
  }).join(' ');
}

class ImageDetailSheetWidget extends StatefulWidget {
  const ImageDetailSheetWidget({
    super.key,
    this.originalImagePath,
    this.diagnosedImagePath,
    this.detections,
    this.llmInterpretation,
    this.detectionsJson,
  });

  final String? originalImagePath;
  final String? diagnosedImagePath;
  final List<dynamic>? detections;
  final String? llmInterpretation;
  final String? detectionsJson;

  @override
  State<ImageDetailSheetWidget> createState() => _ImageDetailSheetWidgetState();
}

class _ImageDetailSheetWidgetState extends State<ImageDetailSheetWidget> {
  late ImageDetailSheetModel _model;
  String? _interpretation;
  bool _isGenerating = false;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => ImageDetailSheetModel());
    _interpretation = widget.llmInterpretation;
    if (_interpretation == null || _interpretation!.isEmpty) {
      _generateInterpretation();
    }
  }

  Future<void> _generateInterpretation() async {
    if (!GemmaService.instance.isModelLoaded) return;
    final json = widget.detectionsJson;
    if (json == null || json.isEmpty) return;

    setState(() => _isGenerating = true);
    try {
      final prompt = LlmPrompts.buildImageInterpretationPrompt(json);
      final response = await GemmaService.instance.generateResponse(prompt);
      if (response.isNotEmpty && mounted) {
        setState(() => _interpretation = response);
      }
    } catch (e) {
      debugPrint('LLM interpretation error: $e');
    } finally {
      if (mounted) setState(() => _isGenerating = false);
    }
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final issueDetections = widget.detections?.where((d) {
          final className = (d as Map<String, dynamic>)['className'] as String;
          return !className.startsWith('tooth_');
        }).toList() ??
        [];
    final teethDetections = widget.detections?.where((d) {
          final className = (d as Map<String, dynamic>)['className'] as String;
          return className.startsWith('tooth_');
        }).toList() ??
        [];

    return Material(
      color: Colors.transparent,
      child: Container(
        height: MediaQuery.of(context).size.height * 0.85,
        decoration: BoxDecoration(
          color: AppTheme.of(context).secondaryBackground,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(16.0),
            topRight: Radius.circular(16.0),
          ),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Drag handle
              Center(
                child: Container(
                  width: 40.0,
                  height: 4.0,
                  margin: EdgeInsets.symmetric(vertical: 12.0),
                  decoration: BoxDecoration(
                    color: AppTheme.of(context).alternate,
                    borderRadius: BorderRadius.circular(2.0),
                  ),
                ),
              ),
              // Original Image Section
              Padding(
                padding: EdgeInsetsDirectional.fromSTEB(16.0, 8.0, 16.0, 0.0),
                child: Text(
                  'Original Image',
                  style: AppTheme.of(context).titleMedium.override(
                        font: GoogleFonts.inter(
                          fontWeight:
                              AppTheme.of(context).titleMedium.fontWeight,
                          fontStyle:
                              AppTheme.of(context).titleMedium.fontStyle,
                        ),
                        letterSpacing: 0.0,
                      ),
                ),
              ),
              SizedBox(height: 8.0),
              if (widget.originalImagePath != null)
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0),
                  child: Container(
                    width: double.infinity,
                    constraints: BoxConstraints(maxHeight: 250.0),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12.0),
                      border: Border.all(
                        color: AppTheme.of(context).alternate,
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(11.0),
                      child: kIsWeb
                          ? Image.network(
                              widget.originalImagePath!,
                              fit: BoxFit.contain,
                            )
                          : Image.file(
                              File(widget.originalImagePath!),
                              fit: BoxFit.contain,
                            ),
                    ),
                  ),
                ),
              SizedBox(height: 16.0),
              // Diagnosed Image Section
              Padding(
                padding: EdgeInsetsDirectional.fromSTEB(16.0, 0.0, 16.0, 0.0),
                child: Text(
                  'Diagnosed Image',
                  style: AppTheme.of(context).titleMedium.override(
                        font: GoogleFonts.inter(
                          fontWeight:
                              AppTheme.of(context).titleMedium.fontWeight,
                          fontStyle:
                              AppTheme.of(context).titleMedium.fontStyle,
                        ),
                        letterSpacing: 0.0,
                      ),
                ),
              ),
              SizedBox(height: 8.0),
              if (widget.diagnosedImagePath != null)
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0),
                  child: Container(
                    width: double.infinity,
                    constraints: BoxConstraints(maxHeight: 250.0),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12.0),
                      border: Border.all(
                        color: AppTheme.of(context).alternate,
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(11.0),
                      child: kIsWeb
                          ? Image.network(
                              widget.diagnosedImagePath!,
                              fit: BoxFit.contain,
                            )
                          : Image.file(
                              File(widget.diagnosedImagePath!),
                              fit: BoxFit.contain,
                            ),
                    ),
                  ),
                ),
              SizedBox(height: 16.0),
              // Detection Summary Section
              Padding(
                padding: EdgeInsetsDirectional.fromSTEB(16.0, 0.0, 16.0, 0.0),
                child: Text(
                  'Detection Summary',
                  style: AppTheme.of(context).titleMedium.override(
                        font: GoogleFonts.inter(
                          fontWeight:
                              AppTheme.of(context).titleMedium.fontWeight,
                          fontStyle:
                              AppTheme.of(context).titleMedium.fontStyle,
                        ),
                        letterSpacing: 0.0,
                      ),
                ),
              ),
              SizedBox(height: 12.0),
              // Issues Found Section
              if (issueDetections.isNotEmpty)
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Issues Found',
                        style: AppTheme.of(context).titleSmall.override(
                              font: GoogleFonts.inter(
                                fontWeight: FontWeight.w600,
                                fontStyle: AppTheme.of(context)
                                    .titleSmall
                                    .fontStyle,
                              ),
                              color: AppTheme.of(context).error,
                              letterSpacing: 0.0,
                            ),
                      ),
                      SizedBox(height: 8.0),
                      ...issueDetections.map((d) {
                        final det = d as Map<String, dynamic>;
                        final className = det['className'] as String;
                        final confidence = det['confidence'] as double;
                        final displayName = _formatClassName(className);
                        return Padding(
                          padding: EdgeInsets.only(bottom: 8.0),
                          child: Container(
                            width: double.infinity,
                            padding: EdgeInsets.all(12.0),
                            decoration: BoxDecoration(
                              color: AppTheme.of(context)
                                  .error
                                  .withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8.0),
                              border: Border.all(
                                color: AppTheme.of(context)
                                    .error
                                    .withOpacity(0.3),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      Icons.warning_amber_rounded,
                                      color: AppTheme.of(context).error,
                                      size: 20.0,
                                    ),
                                    SizedBox(width: 8.0),
                                    Text(
                                      displayName,
                                      style: AppTheme.of(context)
                                          .bodyMedium
                                          .override(
                                            font: GoogleFonts.inter(
                                              fontWeight: FontWeight.w500,
                                              fontStyle:
                                                  AppTheme.of(context)
                                                      .bodyMedium
                                                      .fontStyle,
                                            ),
                                            letterSpacing: 0.0,
                                          ),
                                    ),
                                  ],
                                ),
                                Container(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 8.0, vertical: 4.0),
                                  decoration: BoxDecoration(
                                    color: AppTheme.of(context).error,
                                    borderRadius: BorderRadius.circular(12.0),
                                  ),
                                  child: Text(
                                    '${(confidence * 100).toStringAsFixed(0)}%',
                                    style: AppTheme.of(context)
                                        .bodySmall
                                        .override(
                                          font: GoogleFonts.inter(
                                            fontWeight: FontWeight.w600,
                                            fontStyle:
                                                AppTheme.of(context)
                                                    .bodySmall
                                                    .fontStyle,
                                          ),
                                          color: Colors.white,
                                          letterSpacing: 0.0,
                                        ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ],
                  ),
                ),
              // No issues message
              if (issueDetections.isEmpty)
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0),
                  child: Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(12.0),
                    decoration: BoxDecoration(
                      color: AppTheme.of(context).success.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8.0),
                      border: Border.all(
                        color:
                            AppTheme.of(context).success.withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.check_circle,
                          color: AppTheme.of(context).success,
                          size: 20.0,
                        ),
                        SizedBox(width: 8.0),
                        Text(
                          'No issues detected',
                          style:
                              AppTheme.of(context).bodyMedium.override(
                                    font: GoogleFonts.inter(
                                      fontWeight: FontWeight.w500,
                                      fontStyle: AppTheme.of(context)
                                          .bodyMedium
                                          .fontStyle,
                                    ),
                                    color: AppTheme.of(context).success,
                                    letterSpacing: 0.0,
                                  ),
                        ),
                      ],
                    ),
                  ),
                ),
              SizedBox(height: 16.0),
              // Teeth Detected Section
              if (teethDetections.isNotEmpty)
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Teeth Detected',
                        style: AppTheme.of(context).titleSmall.override(
                              font: GoogleFonts.inter(
                                fontWeight: FontWeight.w600,
                                fontStyle: AppTheme.of(context)
                                    .titleSmall
                                    .fontStyle,
                              ),
                              letterSpacing: 0.0,
                            ),
                      ),
                      SizedBox(height: 8.0),
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(12.0),
                        decoration: BoxDecoration(
                          color: AppTheme.of(context).primaryBackground,
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        child: Wrap(
                          spacing: 8.0,
                          runSpacing: 8.0,
                          children: teethDetections.map((d) {
                            final det = d as Map<String, dynamic>;
                            final className = det['className'] as String;
                            final toothNumber =
                                className.replaceFirst('tooth_', '');
                            return Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 10.0, vertical: 6.0),
                              decoration: BoxDecoration(
                                color: AppTheme.of(context).success,
                                borderRadius: BorderRadius.circular(16.0),
                              ),
                              child: Text(
                                '#$toothNumber',
                                style: AppTheme.of(context)
                                    .bodySmall
                                    .override(
                                      font: GoogleFonts.inter(
                                        fontWeight: FontWeight.w600,
                                        fontStyle: AppTheme.of(context)
                                            .bodySmall
                                            .fontStyle,
                                      ),
                                      color: Colors.white,
                                      letterSpacing: 0.0,
                                    ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ),
                ),
              // AI Interpretation Section
              if (_interpretation != null &&
                  _interpretation!.isNotEmpty) ...[
                SizedBox(height: 16.0),
                Padding(
                  padding: EdgeInsetsDirectional.fromSTEB(16.0, 0.0, 16.0, 0.0),
                  child: Text(
                    'AI Interpretation',
                    style: AppTheme.of(context).titleMedium.override(
                          font: GoogleFonts.inter(
                            fontWeight:
                                AppTheme.of(context).titleMedium.fontWeight,
                            fontStyle:
                                AppTheme.of(context).titleMedium.fontStyle,
                          ),
                          letterSpacing: 0.0,
                        ),
                  ),
                ),
                SizedBox(height: 8.0),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0),
                  child: Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(12.0),
                    decoration: BoxDecoration(
                      color: AppTheme.of(context)
                          .primary
                          .withOpacity(0.05),
                      borderRadius: BorderRadius.circular(8.0),
                      border: Border.all(
                        color: AppTheme.of(context)
                            .primary
                            .withOpacity(0.2),
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.smart_toy,
                          color: AppTheme.of(context).primary,
                          size: 20.0,
                        ),
                        SizedBox(width: 8.0),
                        Expanded(
                          child: Text(
                            _interpretation!,
                            style: AppTheme.of(context)
                                .bodyMedium
                                .override(
                                  font: GoogleFonts.inter(
                                    fontWeight: AppTheme.of(context)
                                        .bodyMedium
                                        .fontWeight,
                                    fontStyle: AppTheme.of(context)
                                        .bodyMedium
                                        .fontStyle,
                                  ),
                                  letterSpacing: 0.0,
                                ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ] else if (_isGenerating) ...[
                SizedBox(height: 16.0),
                Padding(
                  padding: EdgeInsetsDirectional.fromSTEB(16.0, 0.0, 16.0, 0.0),
                  child: Text(
                    'AI Interpretation',
                    style: AppTheme.of(context).titleMedium.override(
                          font: GoogleFonts.inter(
                            fontWeight:
                                AppTheme.of(context).titleMedium.fontWeight,
                            fontStyle:
                                AppTheme.of(context).titleMedium.fontStyle,
                          ),
                          letterSpacing: 0.0,
                        ),
                  ),
                ),
                SizedBox(height: 8.0),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0),
                  child: Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      color: AppTheme.of(context)
                          .primary
                          .withOpacity(0.05),
                      borderRadius: BorderRadius.circular(8.0),
                      border: Border.all(
                        color: AppTheme.of(context)
                            .primary
                            .withOpacity(0.2),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 18.0,
                          height: 18.0,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.0,
                            color: AppTheme.of(context).primary,
                          ),
                        ),
                        SizedBox(width: 12.0),
                        Text(
                          'Generating AI interpretation...',
                          style: AppTheme.of(context)
                              .bodyMedium
                              .override(
                                font: GoogleFonts.inter(
                                  fontWeight: AppTheme.of(context)
                                      .bodyMedium
                                      .fontWeight,
                                  fontStyle: AppTheme.of(context)
                                      .bodyMedium
                                      .fontStyle,
                                ),
                                color: AppTheme.of(context).primary,
                                letterSpacing: 0.0,
                              ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
              SizedBox(height: 24.0),
            ],
          ),
        ),
      ),
    );
  }
}
