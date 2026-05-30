import 'dart:io';

import '/backend/supabase/supabase.dart';
import '/backend/sqlite/sqlite_manager.dart';
import '/bina_design/bina_design.dart';
import '/app_core/app_util.dart';
import '/custom_code/actions/index.dart' as actions;
import '/pages/nav_pages/web_nav/web_nav_widget.dart';
import '/index.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'camera_model.dart';
export 'camera_model.dart';

class CameraWidget extends StatefulWidget {
  const CameraWidget({
    super.key,
    this.memberId,
    this.memberName,
  });

  final String? memberId;
  final String? memberName;

  static String routeName = 'Camera';
  static String routePath = 'camera';

  @override
  State<CameraWidget> createState() => _CameraWidgetState();
}

class _CameraWidgetState extends State<CameraWidget> {
  late CameraModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  String? _selectedImagePath;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => CameraModel());
    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1920,
      maxHeight: 1920,
      imageQuality: 90,
    );

    if (image != null) {
      safeSetState(() {
        _selectedImagePath = image.path;
      });
    }
  }

  Future<void> _runDiagnosis() async {
    if (_selectedImagePath == null) return;

    // Check if running on web
    if (kIsWeb) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Diagnosis is not available on web. Please use the mobile app.'),
          backgroundColor: BinaColors.warning,
        ),
      );
      return;
    }

    safeSetState(() {
      _isProcessing = true;
    });

    try {
      // Run YOLO inference
      final result = await actions.runYoloInference(_selectedImagePath!);

      // Check if we're on web (inference returns isWebPlatform = true)
      if (result.isWebPlatform) {
        safeSetState(() {
          _isProcessing = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Diagnosis is not available on web. Please use the mobile app.'),
            backgroundColor: BinaColors.warning,
          ),
        );
        return;
      }

      // Update last_checked in database if memberId is provided
      if (widget.memberId != null && widget.memberId!.isNotEmpty) {
        if (AppState().UserSession.isLocalSession) {
          // Update in SQLite for local sessions
          await SQLiteManager.instance.updateLastChecked(
            id: widget.memberId,
            lastChecked: getCurrentTimestamp.secondsSinceEpoch,
          );
        } else {
          // Update in Supabase for cloud sessions
          await FamilyMembersTable().update(
            data: {
              'last_checked': supaSerialize<DateTime>(getCurrentTimestamp),
            },
            matchingRows: (rows) => rows
                .eqOrNull('account_id', AppState().UserSession.userID)
                .eqOrNull('id', widget.memberId),
          );
        }

        // Update local state
        final familyIndex = AppState()
            .UserSession
            .family
            .indexWhere((m) => m.id == widget.memberId);
        if (familyIndex != -1) {
          AppState().UserSession.family[familyIndex].lastChecked =
              getCurrentTimestamp;
        }
      }

      safeSetState(() {
        _isProcessing = false;
      });

      // Navigate to result page
      if (mounted) {
        context.pushNamed(
          DiagnosisResultWidget.routeName,
          extra: <String, dynamic>{
            'imagePath': result.imagePath,
            'detections': result.detections,
            'memberName': widget.memberName ?? 'Unknown',
          },
        );
      }
    } catch (e) {
      safeSetState(() {
        _isProcessing = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error processing image: $e'),
          backgroundColor: BinaColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    context.watch<AppState>();
    final isDesktop = responsiveVisibility(
      context: context,
      phone: false,
      tablet: false,
    );

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: BinaColors.surfaceAlt,
        body: Row(
          children: [
            // Web navigation sidebar
            if (isDesktop)
              wrapWithModel(
                model: _model.webNavModel,
                updateCallback: () => safeSetState(() {}),
                child: const WebNavWidget(currentTab: BinaNavTab.scan),
              ),
            // Main content
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  SafeArea(
                    child: Column(
                      children: [
                        // Header
                        Container(
                          padding: const EdgeInsets.fromLTRB(8, 8, 16, 8),
                          decoration: BoxDecoration(
                            color: BinaColors.surface,
                            border: Border(bottom: BorderSide(color: BinaColors.line)),
                          ),
                          child: Row(
                            children: [
                              BinaIconButton(
                                icon: Icons.chevron_left_rounded,
                                onPressed: () => context.safePop(),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Diagnosis', style: BinaType.titleLg),
                                    if (widget.memberName != null)
                                      Text(
                                        'Patient: ${widget.memberName}',
                                        style: BinaType.bodySm.copyWith(color: BinaColors.ink2),
                                      ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Content
                        Expanded(
                          child: SingleChildScrollView(
                            padding: EdgeInsets.fromLTRB(
                              20,
                              20,
                              20,
                              isDesktop ? 20 : 120,
                            ),
                            child: Center(
                              child: ConstrainedBox(
                                constraints: const BoxConstraints(maxWidth: 500),
                                child: Column(
                                  children: [
                                    // Image upload card
                                    BinaCard(
                                      padding: const EdgeInsets.all(20),
                                      child: Column(
                                        children: [
                                          // Image preview area
                                          GestureDetector(
                                            onTap: _isProcessing ? null : _pickImage,
                                            child: Container(
                                              width: double.infinity,
                                              height: 280,
                                              decoration: BoxDecoration(
                                                color: BinaColors.surfaceSunken,
                                                borderRadius: BorderRadius.circular(16),
                                                border: Border.all(
                                                  color: BinaColors.line,
                                                  width: 2,
                                                ),
                                              ),
                                              clipBehavior: Clip.antiAlias,
                                              child: _selectedImagePath != null
                                                  ? kIsWeb
                                                      ? Image.network(
                                                          _selectedImagePath!,
                                                          fit: BoxFit.contain,
                                                        )
                                                      : Image.file(
                                                          File(_selectedImagePath!),
                                                          fit: BoxFit.contain,
                                                        )
                                                  : Column(
                                                      mainAxisAlignment: MainAxisAlignment.center,
                                                      children: [
                                                        Container(
                                                          width: 72,
                                                          height: 72,
                                                          decoration: BoxDecoration(
                                                            color: BinaColors.primary100,
                                                            borderRadius: BorderRadius.circular(20),
                                                          ),
                                                          child: Icon(
                                                            Icons.add_photo_alternate_rounded,
                                                            color: BinaColors.primary,
                                                            size: 36,
                                                          ),
                                                        ),
                                                        const SizedBox(height: 16),
                                                        Text(
                                                          'Tap to upload photo',
                                                          style: BinaType.titleSm.copyWith(color: BinaColors.ink2),
                                                        ),
                                                        const SizedBox(height: 4),
                                                        Text(
                                                          'Select a dental image for diagnosis',
                                                          style: BinaType.bodySm.copyWith(color: BinaColors.ink3),
                                                        ),
                                                      ],
                                                    ),
                                            ),
                                          ).animate()
                                              .fadeIn(duration: 400.ms)
                                              .moveY(begin: 20, end: 0, duration: 400.ms),
                                          const SizedBox(height: 16),
                                          // Upload button
                                          SizedBox(
                                            width: double.infinity,
                                            child: BinaButton(
                                              label: _selectedImagePath == null
                                                  ? 'Upload Photo'
                                                  : 'Change Photo',
                                              icon: Icons.upload_file_rounded,
                                              variant: BinaButtonVariant.secondary,
                                              enabled: !_isProcessing,
                                              onPressed: _pickImage,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 20),
                                    // Run diagnosis button
                                    SizedBox(
                                      width: double.infinity,
                                      child: BinaButton(
                                        label: _isProcessing ? 'Processing...' : 'Run Diagnosis',
                                        icon: _isProcessing ? null : Icons.medical_services_rounded,
                                        variant: BinaButtonVariant.primary,
                                        enabled: _selectedImagePath != null && !_isProcessing,
                                        onPressed: _runDiagnosis,
                                      ),
                                    ).animate()
                                        .fadeIn(delay: 200.ms, duration: 400.ms),
                                    // Processing indicator
                                    if (_isProcessing) ...[
                                      const SizedBox(height: 20),
                                      Container(
                                        padding: const EdgeInsets.all(16),
                                        decoration: BoxDecoration(
                                          color: BinaColors.primary100,
                                          borderRadius: BorderRadius.circular(14),
                                        ),
                                        child: Row(
                                          children: [
                                            SizedBox(
                                              width: 20,
                                              height: 20,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                                color: BinaColors.primary,
                                              ),
                                            ),
                                            const SizedBox(width: 14),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    'Analyzing image...',
                                                    style: BinaType.titleSm.copyWith(color: BinaColors.primary),
                                                  ),
                                                  Text(
                                                    'Running AI diagnosis on your dental image',
                                                    style: BinaType.bodySm.copyWith(color: BinaColors.ink2),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Floating nav for mobile
                  if (!isDesktop)
                    Positioned.fill(
                      child: BinaFloatingNav(
                        currentTab: BinaNavTab.scan,
                        onTabChanged: (tab) {
                          switch (tab) {
                            case BinaNavTab.home:
                              context.goNamed(MainHomeWidget.routeName);
                              break;
                            case BinaNavTab.family:
                              context.goNamed(FamilyWidget.routeName);
                              break;
                            case BinaNavTab.scan:
                              context.goNamed(MainDiagnoseWidget.routeName);
                              break;
                            case BinaNavTab.chat:
                              context.goNamed(ChatHistoryWidget.routeName);
                              break;
                            case BinaNavTab.profile:
                              context.goNamed(MainProfilePageWidget.routeName);
                              break;
                          }
                        },
                      ),
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
