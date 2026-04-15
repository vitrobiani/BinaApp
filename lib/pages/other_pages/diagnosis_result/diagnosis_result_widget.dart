import 'dart:io';

import 'package:flutter/foundation.dart' show kIsWeb;
import '/app_core/app_animations.dart';
import '/app_core/app_icon_button.dart';
import '/app_core/app_theme.dart';
import '/app_core/app_util.dart';
import '/app_core/app_widgets.dart';
import '/pages/nav_pages/web_nav/web_nav_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'diagnosis_result_model.dart';
export 'diagnosis_result_model.dart';

// Helper function to format class names for display
String _formatClassName(String className) {
  // Replace underscores with spaces and capitalize words
  final words = className.split('_');
  return words.map((word) {
    if (word.isEmpty) return word;
    return word[0].toUpperCase() + word.substring(1).toLowerCase();
  }).join(' ');
}

class DiagnosisResultWidget extends StatefulWidget {
  const DiagnosisResultWidget({
    super.key,
    this.imagePath,
    this.detections,
    this.memberName,
  });

  final String? imagePath;
  final List<dynamic>? detections;
  final String? memberName;

  static String routeName = 'DiagnosisResult';
  static String routePath = 'diagnosisResult';

  @override
  State<DiagnosisResultWidget> createState() => _DiagnosisResultWidgetState();
}

class _DiagnosisResultWidgetState extends State<DiagnosisResultWidget>
    with TickerProviderStateMixin {
  late DiagnosisResultModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  final animationsMap = <String, AnimationInfo>{};

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => DiagnosisResultModel());

    animationsMap.addAll({
      'imageOnPageLoadAnimation': AnimationInfo(
        trigger: AnimationTrigger.onPageLoad,
        effectsBuilder: () => [
          FadeEffect(
            curve: Curves.easeInOut,
            delay: 0.0.ms,
            duration: 600.0.ms,
            begin: 0.0,
            end: 1.0,
          ),
          ScaleEffect(
            curve: Curves.easeInOut,
            delay: 0.0.ms,
            duration: 600.0.ms,
            begin: Offset(0.95, 0.95),
            end: Offset(1.0, 1.0),
          ),
        ],
      ),
      'containerOnPageLoadAnimation': AnimationInfo(
        trigger: AnimationTrigger.onPageLoad,
        effectsBuilder: () => [
          FadeEffect(
            curve: Curves.easeInOut,
            delay: 300.0.ms,
            duration: 600.0.ms,
            begin: 0.0,
            end: 1.0,
          ),
          MoveEffect(
            curve: Curves.easeInOut,
            delay: 300.0.ms,
            duration: 600.0.ms,
            begin: Offset(0.0, 50.0),
            end: Offset(0.0, 0.0),
          ),
        ],
      ),
    });

    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    context.watch<AppState>();

    final detectionCount = widget.detections?.length ?? 0;
    final issueDetections = widget.detections?.where((d) {
      final className = (d as Map<String, dynamic>)['className'] as String;
      return !className.startsWith('tooth_');
    }).toList() ?? [];
    final teethDetections = widget.detections?.where((d) {
      final className = (d as Map<String, dynamic>)['className'] as String;
      return className.startsWith('tooth_');
    }).toList() ?? [];

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: AppTheme.of(context).primaryBackground,
        body: Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            Expanded(
              child: Row(
                mainAxisSize: MainAxisSize.max,
                children: [
                  // Web navigation sidebar
                  if (responsiveVisibility(
                    context: context,
                    phone: false,
                    tablet: false,
                  ))
                    wrapWithModel(
                      model: _model.webNavModel,
                      updateCallback: () => safeSetState(() {}),
                      child: WebNavWidget(
                        iconOne: Icon(
                          Icons.home_rounded,
                          color: AppTheme.of(context).secondaryText,
                        ),
                        iconTwo: Icon(
                          Icons.remove_red_eye,
                          color: AppTheme.of(context).secondaryText,
                        ),
                        iconThree: Icon(
                          Icons.camera_alt,
                          color: AppTheme.of(context).primary,
                        ),
                        iconFour: Icon(
                          Icons.account_circle,
                          color: AppTheme.of(context).secondaryText,
                        ),
                        colorBgOne:
                            AppTheme.of(context).secondaryBackground,
                        colorBgTwo:
                            AppTheme.of(context).secondaryBackground,
                        colorBgThree:
                            AppTheme.of(context).primaryBackground,
                        colorBgFour:
                            AppTheme.of(context).secondaryBackground,
                        textOne: AppTheme.of(context).primaryText,
                        textTwo: AppTheme.of(context).secondaryText,
                        textThree: AppTheme.of(context).secondaryText,
                        textFour: AppTheme.of(context).secondaryText,
                        iconFive: Icon(
                          Icons.reduce_capacity,
                          color: AppTheme.of(context).secondaryText,
                        ),
                        colorBgFive:
                            AppTheme.of(context).secondaryBackground,
                        textFive: AppTheme.of(context).secondaryText,
                      ),
                    ),
                  // Main content
                  Expanded(
                    child: SafeArea(
                      child: Column(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          // App bar
                          Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: AppTheme.of(context)
                                  .secondaryBackground,
                            ),
                            child: Padding(
                              padding: EdgeInsetsDirectional.fromSTEB(
                                  16.0, 12.0, 16.0, 12.0),
                              child: Row(
                                mainAxisSize: MainAxisSize.max,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      AppIconButton(
                                        borderColor:
                                            AppTheme.of(context)
                                                .alternate,
                                        borderRadius: 12.0,
                                        borderWidth: 1.0,
                                        buttonSize: 40.0,
                                        fillColor: AppTheme.of(context)
                                            .secondaryBackground,
                                        icon: Icon(
                                          Icons.arrow_back_rounded,
                                          color: AppTheme.of(context)
                                              .primaryText,
                                          size: 24.0,
                                        ),
                                        onPressed: () async {
                                          context.goNamed('Main_Diagnose');
                                        },
                                      ),
                                      SizedBox(width: 12.0),
                                      Column(
                                        mainAxisSize: MainAxisSize.min,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Diagnosis Result',
                                            style: AppTheme.of(context)
                                                .headlineMedium
                                                .override(
                                                  font: GoogleFonts.readexPro(
                                                    fontWeight:
                                                        AppTheme.of(
                                                                context)
                                                            .headlineMedium
                                                            .fontWeight,
                                                    fontStyle:
                                                        AppTheme.of(
                                                                context)
                                                            .headlineMedium
                                                            .fontStyle,
                                                  ),
                                                  letterSpacing: 0.0,
                                                ),
                                          ),
                                          if (widget.memberName != null)
                                            Text(
                                              'Patient: ${widget.memberName}',
                                              style:
                                                  AppTheme.of(context)
                                                      .labelMedium
                                                      .override(
                                                        font: GoogleFonts.inter(
                                                          fontWeight:
                                                              AppTheme.of(
                                                                      context)
                                                                  .labelMedium
                                                                  .fontWeight,
                                                          fontStyle:
                                                              AppTheme.of(
                                                                      context)
                                                                  .labelMedium
                                                                  .fontStyle,
                                                        ),
                                                        letterSpacing: 0.0,
                                                      ),
                                            ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                          // Content
                          Expanded(
                            child: SingleChildScrollView(
                              child: Column(
                                mainAxisSize: MainAxisSize.max,
                                children: [
                                  // Image with bounding boxes
                                  Padding(
                                    padding: EdgeInsetsDirectional.fromSTEB(
                                        16.0, 16.0, 16.0, 0.0),
                                    child: Container(
                                      width: double.infinity,
                                      constraints: BoxConstraints(
                                        maxWidth: 800.0,
                                      ),
                                      decoration: BoxDecoration(
                                        color: AppTheme.of(context)
                                            .secondaryBackground,
                                        borderRadius:
                                            BorderRadius.circular(12.0),
                                        border: Border.all(
                                          color: AppTheme.of(context)
                                              .alternate,
                                        ),
                                      ),
                                      child: Padding(
                                        padding: EdgeInsets.all(8.0),
                                        child: widget.imagePath != null
                                            ? ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(8.0),
                                                child: kIsWeb
                                                    ? Image.network(
                                                        widget.imagePath!,
                                                        width: double.infinity,
                                                        fit: BoxFit.contain,
                                                      )
                                                    : Image.file(
                                                        File(widget.imagePath!),
                                                        width: double.infinity,
                                                        fit: BoxFit.contain,
                                                      ),
                                              ).animateOnPageLoad(animationsMap[
                                                'imageOnPageLoadAnimation']!)
                                            : Container(
                                                height: 300.0,
                                                child: Center(
                                                  child: Text(
                                                    'No image available',
                                                    style: AppTheme.of(
                                                            context)
                                                        .bodyMedium
                                                        .override(
                                                          font:
                                                              GoogleFonts.inter(
                                                            fontWeight:
                                                                AppTheme.of(
                                                                        context)
                                                                    .bodyMedium
                                                                    .fontWeight,
                                                            fontStyle:
                                                                AppTheme.of(
                                                                        context)
                                                                    .bodyMedium
                                                                    .fontStyle,
                                                          ),
                                                          letterSpacing: 0.0,
                                                        ),
                                                  ),
                                                ),
                                              ),
                                      ),
                                    ),
                                  ),
                                  // Summary section (placeholder for future text)
                                  Padding(
                                    padding: EdgeInsetsDirectional.fromSTEB(
                                        16.0, 16.0, 16.0, 16.0),
                                    child: Container(
                                      width: double.infinity,
                                      constraints: BoxConstraints(
                                        maxWidth: 800.0,
                                      ),
                                      decoration: BoxDecoration(
                                        color: AppTheme.of(context)
                                            .secondaryBackground,
                                        borderRadius:
                                            BorderRadius.circular(12.0),
                                        border: Border.all(
                                          color: AppTheme.of(context)
                                              .alternate,
                                        ),
                                      ),
                                      child: Padding(
                                        padding: EdgeInsets.all(16.0),
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Detection Summary',
                                              style:
                                                  AppTheme.of(context)
                                                      .titleMedium
                                                      .override(
                                                        font:
                                                            GoogleFonts.inter(
                                                          fontWeight:
                                                              AppTheme.of(
                                                                      context)
                                                                  .titleMedium
                                                                  .fontWeight,
                                                          fontStyle:
                                                              AppTheme.of(
                                                                      context)
                                                                  .titleMedium
                                                                  .fontStyle,
                                                        ),
                                                        letterSpacing: 0.0,
                                                      ),
                                            ),
                                            SizedBox(height: 12.0),
                                            Row(
                                              mainAxisSize: MainAxisSize.max,
                                              children: [
                                                Container(
                                                  padding: EdgeInsets.symmetric(
                                                      horizontal: 12.0,
                                                      vertical: 6.0),
                                                  decoration: BoxDecoration(
                                                    color: issueDetections
                                                            .isEmpty
                                                        ? AppTheme.of(
                                                                context)
                                                            .success
                                                        : AppTheme.of(
                                                                context)
                                                            .warning,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            20.0),
                                                  ),
                                                  child: Text(
                                                    issueDetections.isEmpty
                                                        ? 'No Issues Detected'
                                                        : '${issueDetections.length} Issue${issueDetections.length > 1 ? 's' : ''} Found',
                                                    style: AppTheme.of(
                                                            context)
                                                        .bodySmall
                                                        .override(
                                                          font:
                                                              GoogleFonts.inter(
                                                            fontWeight:
                                                                FontWeight.w600,
                                                            fontStyle:
                                                                AppTheme.of(
                                                                        context)
                                                                    .bodySmall
                                                                    .fontStyle,
                                                          ),
                                                          color: Colors.white,
                                                          letterSpacing: 0.0,
                                                        ),
                                                  ),
                                                ),
                                                SizedBox(width: 8.0),
                                                Text(
                                                  '$detectionCount total detections',
                                                  style: AppTheme.of(
                                                          context)
                                                      .bodySmall
                                                      .override(
                                                        font: GoogleFonts.inter(
                                                          fontWeight:
                                                              AppTheme.of(
                                                                      context)
                                                                  .bodySmall
                                                                  .fontWeight,
                                                          fontStyle:
                                                              AppTheme.of(
                                                                      context)
                                                                  .bodySmall
                                                                  .fontStyle,
                                                        ),
                                                        color:
                                                            AppTheme.of(
                                                                    context)
                                                                .secondaryText,
                                                        letterSpacing: 0.0,
                                                      ),
                                                ),
                                              ],
                                            ),
                                            // Issues Found Section
                                            if (issueDetections.isNotEmpty) ...[
                                              SizedBox(height: 16.0),
                                              Text(
                                                'Issues Found',
                                                style:
                                                    AppTheme.of(context)
                                                        .titleSmall
                                                        .override(
                                                          font: GoogleFonts.inter(
                                                            fontWeight: FontWeight.w600,
                                                            fontStyle:
                                                                AppTheme.of(context)
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
                                                      mainAxisAlignment:
                                                          MainAxisAlignment.spaceBetween,
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
                                            // Teeth Detected Section
                                            if (teethDetections.isNotEmpty) ...[
                                              SizedBox(height: 16.0),
                                              Text(
                                                'Teeth Detected',
                                                style:
                                                    AppTheme.of(context)
                                                        .titleSmall
                                                        .override(
                                                          font: GoogleFonts.inter(
                                                            fontWeight: FontWeight.w600,
                                                            fontStyle:
                                                                AppTheme.of(context)
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
                                                  color: AppTheme.of(context)
                                                      .primaryBackground,
                                                  borderRadius: BorderRadius.circular(8.0),
                                                ),
                                                child: Wrap(
                                                  spacing: 8.0,
                                                  runSpacing: 8.0,
                                                  children: teethDetections.map((d) {
                                                    final det = d as Map<String, dynamic>;
                                                    final className = det['className'] as String;
                                                    final toothNumber = className.replaceFirst('tooth_', '');
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
                                                                fontStyle:
                                                                    AppTheme.of(context)
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
                                            // No detections message
                                            if (detectionCount == 0) ...[
                                              SizedBox(height: 16.0),
                                              Container(
                                                width: double.infinity,
                                                padding: EdgeInsets.all(12.0),
                                                decoration: BoxDecoration(
                                                  color: AppTheme.of(context)
                                                      .primaryBackground,
                                                  borderRadius: BorderRadius.circular(8.0),
                                                ),
                                                child: Text(
                                                  'No detections found in the image. Try uploading a clearer dental image.',
                                                  style: AppTheme.of(context)
                                                      .bodySmall
                                                      .override(
                                                        font: GoogleFonts.inter(
                                                          fontWeight:
                                                              AppTheme.of(context)
                                                                  .bodySmall
                                                                  .fontWeight,
                                                          fontStyle:
                                                              AppTheme.of(context)
                                                                  .bodySmall
                                                                  .fontStyle,
                                                        ),
                                                        color: AppTheme.of(context)
                                                            .secondaryText,
                                                        letterSpacing: 0.0,
                                                      ),
                                                ),
                                              ),
                                            ],
                                          ],
                                        ),
                                      ),
                                    ).animateOnPageLoad(animationsMap[
                                        'containerOnPageLoadAnimation']!),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          // Bottom button
                          Container(
                            width: double.infinity,
                            constraints: BoxConstraints(
                              maxWidth: 570.0,
                            ),
                            decoration: BoxDecoration(),
                            child: Padding(
                              padding: EdgeInsetsDirectional.fromSTEB(
                                  16.0, 12.0, 16.0, 24.0),
                              child: AppButtonWidget(
                                onPressed: () async {
                                  context.goNamed('Main_Diagnose');
                                },
                                text: 'Back to Diagnose',
                                icon: Icon(
                                  Icons.arrow_back,
                                  size: 20.0,
                                ),
                                options: AppButtonOptions(
                                  width: double.infinity,
                                  height: 52.0,
                                  padding: EdgeInsetsDirectional.fromSTEB(
                                      24.0, 0.0, 24.0, 0.0),
                                  iconPadding: EdgeInsetsDirectional.fromSTEB(
                                      0.0, 0.0, 8.0, 0.0),
                                  color: AppTheme.of(context).primary,
                                  textStyle: AppTheme.of(context)
                                      .titleSmall
                                      .override(
                                        font: GoogleFonts.inter(
                                          fontWeight:
                                              AppTheme.of(context)
                                                  .titleSmall
                                                  .fontWeight,
                                          fontStyle:
                                              AppTheme.of(context)
                                                  .titleSmall
                                                  .fontStyle,
                                        ),
                                        color: Colors.white,
                                        letterSpacing: 0.0,
                                      ),
                                  elevation: 3.0,
                                  borderSide: BorderSide(
                                    color: Colors.transparent,
                                    width: 1.0,
                                  ),
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Bottom navigation bar for mobile
            if (responsiveVisibility(
              context: context,
              tabletLandscape: false,
              desktop: false,
            ))
              Container(
                decoration: BoxDecoration(
                  color: AppTheme.of(context).secondaryBackground,
                ),
                child: BottomNavigationBar(
                  currentIndex: 2,
                  onTap: (i) {
                    final pages = [
                      'Main_Home',
                      'Main_DIagnostics',
                      'Main_Diagnose',
                      'Main_profilePage',
                    ];
                    context.goNamed(pages[i]);
                  },
                  backgroundColor:
                      AppTheme.of(context).secondaryBackground,
                  selectedItemColor: AppTheme.of(context).primary,
                  unselectedItemColor:
                      AppTheme.of(context).secondaryText,
                  showSelectedLabels: true,
                  showUnselectedLabels: false,
                  type: BottomNavigationBarType.fixed,
                  items: <BottomNavigationBarItem>[
                    BottomNavigationBarItem(
                      icon: Icon(Icons.home_outlined, size: 24.0),
                      activeIcon: Icon(Icons.home, size: 32.0),
                      label: '__',
                      tooltip: '',
                    ),
                    BottomNavigationBarItem(
                      icon: Icon(Icons.remove_red_eye_outlined, size: 24.0),
                      activeIcon: Icon(Icons.remove_red_eye, size: 32.0),
                      label: '__',
                      tooltip: '',
                    ),
                    BottomNavigationBarItem(
                      icon: Icon(Icons.camera_alt_outlined, size: 24.0),
                      activeIcon: Icon(Icons.camera_alt, size: 32.0),
                      label: '__',
                      tooltip: '',
                    ),
                    BottomNavigationBarItem(
                      icon: Icon(Icons.account_circle_outlined, size: 24.0),
                      activeIcon: Icon(Icons.account_circle, size: 32.0),
                      label: '__',
                      tooltip: '',
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
