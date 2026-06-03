import 'dart:io';

import 'package:flutter/foundation.dart' show kIsWeb;
import '/app_core/app_animations.dart';
import '/app_core/app_util.dart';
import '/bina_design/bina_design.dart';
import '/pages/nav_pages/web_nav/web_nav_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
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
        backgroundColor: BinaColors.surfaceAlt,
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
                          color: BinaColors.ink2,
                        ),
                        iconTwo: Icon(
                          Icons.remove_red_eye,
                          color: BinaColors.ink2,
                        ),
                        iconThree: Icon(
                          Icons.camera_alt,
                          color: BinaColors.primary,
                        ),
                        iconFour: Icon(
                          Icons.account_circle,
                          color: BinaColors.ink2,
                        ),
                        colorBgOne: BinaColors.surface,
                        colorBgTwo: BinaColors.surface,
                        colorBgThree: BinaColors.surfaceAlt,
                        colorBgFour: BinaColors.surface,
                        textOne: BinaColors.ink,
                        textTwo: BinaColors.ink2,
                        textThree: BinaColors.ink2,
                        textFour: BinaColors.ink2,
                        iconFive: Icon(
                          Icons.reduce_capacity,
                          color: BinaColors.ink2,
                        ),
                        colorBgFive: BinaColors.surface,
                        textFive: BinaColors.ink2,
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
                              color: BinaColors.surface,
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: BinaSpace.s4,
                                vertical: BinaSpace.s3,
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.max,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      BinaIconButton(
                                        icon: Icons.arrow_back_rounded,
                                        onPressed: () {
                                          context.goNamed('Main_Diagnose');
                                        },
                                      ),
                                      const SizedBox(width: BinaSpace.s3),
                                      Column(
                                        mainAxisSize: MainAxisSize.min,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Diagnosis Result',
                                            style: BinaType.headlineMd,
                                          ),
                                          if (widget.memberName != null)
                                            Text(
                                              'Patient: ${widget.memberName}',
                                              style: BinaType.labelMd,
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
                                    padding: const EdgeInsets.fromLTRB(
                                        BinaSpace.s4, BinaSpace.s4, BinaSpace.s4, 0),
                                    child: BinaCard(
                                      padding: const EdgeInsets.all(BinaSpace.s2),
                                      child: ConstrainedBox(
                                        constraints: const BoxConstraints(
                                          maxWidth: 800.0,
                                        ),
                                        child: widget.imagePath != null
                                            ? ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(BinaRadius.sm),
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
                                            : SizedBox(
                                                height: 300.0,
                                                child: Center(
                                                  child: Text(
                                                    'No image available',
                                                    style: BinaType.bodyMd.copyWith(
                                                      color: BinaColors.ink2,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                      ),
                                    ),
                                  ),
                                  // Summary section
                                  Padding(
                                    padding: const EdgeInsets.all(BinaSpace.s4),
                                    child: BinaCard(
                                      padding: const EdgeInsets.all(BinaSpace.s4),
                                      child: ConstrainedBox(
                                        constraints: const BoxConstraints(
                                          maxWidth: 800.0,
                                        ),
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Detection Summary',
                                              style: BinaType.titleLg,
                                            ),
                                            const SizedBox(height: BinaSpace.s3),
                                            Row(
                                              mainAxisSize: MainAxisSize.max,
                                              children: [
                                                if (issueDetections.isEmpty)
                                                  DxChip(kind: DxChipKind.good)
                                                else
                                                  Container(
                                                    padding: const EdgeInsets.symmetric(
                                                        horizontal: 12.0,
                                                        vertical: 6.0),
                                                    decoration: BoxDecoration(
                                                      color: BinaColors.dxCavity,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              BinaRadius.pill),
                                                    ),
                                                    child: Text(
                                                      '${issueDetections.length} Issue${issueDetections.length > 1 ? 's' : ''} Found',
                                                      style: BinaType.labelMd.copyWith(
                                                        color: Colors.white,
                                                        fontWeight: FontWeight.w600,
                                                      ),
                                                    ),
                                                  ),
                                                const SizedBox(width: BinaSpace.s2),
                                                Text(
                                                  '$detectionCount total detections',
                                                  style: BinaType.bodySm,
                                                ),
                                              ],
                                            ),
                                            // Issues Found Section
                                            if (issueDetections.isNotEmpty) ...[
                                              const SizedBox(height: BinaSpace.s4),
                                              Text(
                                                'Issues Found',
                                                style: BinaType.titleSm.copyWith(
                                                  color: BinaColors.dxCavity,
                                                ),
                                              ),
                                              const SizedBox(height: BinaSpace.s2),
                                              ...issueDetections.map((d) {
                                                final det = d as Map<String, dynamic>;
                                                final className = det['className'] as String;
                                                final confidence = det['confidence'] as double;
                                                final displayName = _formatClassName(className);
                                                // Determine issue color based on type
                                                final isPlaque = className.toLowerCase().contains('plaque') ||
                                                                 className.toLowerCase().contains('plack');
                                                final isCavity = className.toLowerCase().contains('cavity') ||
                                                                 className.toLowerCase().contains('caries');
                                                final issueColor = isPlaque
                                                    ? BinaColors.dxPlaque
                                                    : (isCavity ? BinaColors.dxCavity : BinaColors.dxMixed);
                                                final issueColorBg = isPlaque
                                                    ? BinaColors.dxPlaque100
                                                    : (isCavity ? BinaColors.dxCavity100 : BinaColors.dxMixed100);
                                                return Padding(
                                                  padding: const EdgeInsets.only(bottom: BinaSpace.s2),
                                                  child: Container(
                                                    width: double.infinity,
                                                    padding: const EdgeInsets.all(BinaSpace.s3),
                                                    decoration: BoxDecoration(
                                                      color: issueColorBg,
                                                      borderRadius: BorderRadius.circular(BinaRadius.sm),
                                                      border: Border.all(
                                                        color: issueColor.withOpacity(0.3),
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
                                                              color: issueColor,
                                                              size: 20.0,
                                                            ),
                                                            const SizedBox(width: BinaSpace.s2),
                                                            Text(
                                                              displayName,
                                                              style: BinaType.bodyMd.copyWith(
                                                                fontWeight: FontWeight.w500,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                        Container(
                                                          padding: const EdgeInsets.symmetric(
                                                              horizontal: 8.0, vertical: 4.0),
                                                          decoration: BoxDecoration(
                                                            color: issueColor,
                                                            borderRadius: BorderRadius.circular(BinaRadius.pill),
                                                          ),
                                                          child: Text(
                                                            '${(confidence * 100).toStringAsFixed(0)}%',
                                                            style: BinaType.labelSm.copyWith(
                                                              color: Colors.white,
                                                              fontWeight: FontWeight.w600,
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                );
                                              }),
                                            ],
                                            // Teeth Detected Section
                                            if (teethDetections.isNotEmpty) ...[
                                              const SizedBox(height: BinaSpace.s4),
                                              Text(
                                                'Teeth Detected',
                                                style: BinaType.titleSm,
                                              ),
                                              const SizedBox(height: BinaSpace.s2),
                                              Container(
                                                width: double.infinity,
                                                padding: const EdgeInsets.all(BinaSpace.s3),
                                                decoration: BoxDecoration(
                                                  color: BinaColors.surfaceSunken,
                                                  borderRadius: BorderRadius.circular(BinaRadius.sm),
                                                ),
                                                child: Wrap(
                                                  spacing: BinaSpace.s2,
                                                  runSpacing: BinaSpace.s2,
                                                  children: teethDetections.map((d) {
                                                    final det = d as Map<String, dynamic>;
                                                    final className = det['className'] as String;
                                                    final toothNumber = className.replaceFirst('tooth_', '');
                                                    return Container(
                                                      padding: const EdgeInsets.symmetric(
                                                          horizontal: 10.0, vertical: 6.0),
                                                      decoration: BoxDecoration(
                                                        color: BinaColors.dxGood,
                                                        borderRadius: BorderRadius.circular(BinaRadius.pill),
                                                      ),
                                                      child: Text(
                                                        '#$toothNumber',
                                                        style: BinaType.labelSm.copyWith(
                                                          color: Colors.white,
                                                          fontWeight: FontWeight.w600,
                                                        ),
                                                      ),
                                                    );
                                                  }).toList(),
                                                ),
                                              ),
                                            ],
                                            // No detections message
                                            if (detectionCount == 0) ...[
                                              const SizedBox(height: BinaSpace.s4),
                                              Container(
                                                width: double.infinity,
                                                padding: const EdgeInsets.all(BinaSpace.s3),
                                                decoration: BoxDecoration(
                                                  color: BinaColors.surfaceSunken,
                                                  borderRadius: BorderRadius.circular(BinaRadius.sm),
                                                ),
                                                child: Text(
                                                  'No detections found in the image. Try uploading a clearer dental image.',
                                                  style: BinaType.bodySm,
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
                          Padding(
                            padding: const EdgeInsets.fromLTRB(
                                BinaSpace.s4, BinaSpace.s3, BinaSpace.s4, BinaSpace.s6),
                            child: ConstrainedBox(
                              constraints: const BoxConstraints(
                                maxWidth: 570.0,
                              ),
                              child: BinaButton(
                                label: 'Back to Diagnose',
                                icon: Icons.arrow_back,
                                fullWidth: true,
                                size: BinaButtonSize.lg,
                                onPressed: () {
                                  context.goNamed('Main_Diagnose');
                                },
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
                  color: BinaColors.surface,
                  border: Border(
                    top: BorderSide(color: BinaColors.line, width: 1),
                  ),
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
                  backgroundColor: BinaColors.surface,
                  selectedItemColor: BinaColors.primary,
                  unselectedItemColor: BinaColors.ink3,
                  showSelectedLabels: true,
                  showUnselectedLabels: false,
                  type: BottomNavigationBarType.fixed,
                  items: const <BottomNavigationBarItem>[
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
