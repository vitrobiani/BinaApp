import 'dart:io';

import '/backend/schema/structs/index.dart';
import '/backend/sqlite/sqlite_manager.dart';
import '/backend/supabase/supabase.dart';
import '/app_core/app_util.dart';
import '/bina_design/bina_design.dart';
import '/pages/nav_pages/web_nav/web_nav_widget.dart';
import '/custom_code/actions/index.dart' as actions;
import '/index.dart';
import '/services/mjpeg_capture_service.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mjpeg_stream/mjpeg_stream.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'main_d_iagnostics_model.dart';
export 'main_d_iagnostics_model.dart';

class MainDIagnosticsWidget extends StatefulWidget {
  const MainDIagnosticsWidget({
    super.key,
    this.preselectedMemberId,
    this.preselectedMemberName,
  });

  final String? preselectedMemberId;
  final String? preselectedMemberName;

  static String routeName = 'Main_DIagnostics';
  static String routePath = 'mainDIagnostics';

  @override
  State<MainDIagnosticsWidget> createState() => _MainDIagnosticsWidgetState();
}

/// Captured image data for the scan session
class CapturedImage {
  final String id;
  final String originalPath;
  final String diagnosedPath;
  final List<dynamic> detections;
  final DateTime capturedAt;

  CapturedImage({
    required this.id,
    required this.originalPath,
    required this.diagnosedPath,
    required this.detections,
    required this.capturedAt,
  });

  int get issuesCount => detections.where((d) =>
    !(d['className'] as String).startsWith('tooth_')).length;

  int get teethCount => detections.where((d) =>
    (d['className'] as String).startsWith('tooth_')).length;
}

class _MainDIagnosticsWidgetState extends State<MainDIagnosticsWidget>
    with TickerProviderStateMixin {
  late MainDIagnosticsModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  List<FamilyMemberStruct> _familyMembers = [];

  // Track which view we're showing
  bool _showingTargetSelector = true;
  FamilyMemberStruct? _selectedMember;

  // Captured images for current session
  List<CapturedImage> _capturedImages = [];
  bool _isProcessingImage = false;
  String? _currentSessionId;
  bool _isFinishingSession = false;

  // Camera preview state
  bool _isInPreviewMode = false;
  bool _isCapturingFromStream = false;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => MainDIagnosticsModel());
    _model.onSelectionChanged = () => safeSetState(() {});

    SchedulerBinding.instance.addPostFrameCallback((_) async {
      await _loadFamilyMembers();
    });
  }

  Future<void> _loadFamilyMembers() async {
    final family = AppState().UserSession.family.toList();
    if (family.isNotEmpty) {
      safeSetState(() {
        _familyMembers = family;
        _model.tabBarController = TabController(
          vsync: this,
          length: family.length,
          initialIndex: 0,
        )..addListener(() {
            if (_model.isMultiSelectMode) {
              _model.exitMultiSelectMode();
            }
            safeSetState(() {});
          });
        _model.isLoading = false;
      });
    } else {
      safeSetState(() {
        _model.isLoading = false;
      });
    }

    // Auto-select preselected member if provided
    if (widget.preselectedMemberId != null && widget.preselectedMemberName != null) {
      // Find the member in the family list or create one
      FamilyMemberStruct? member;
      final index = _familyMembers.indexWhere((m) => m.id == widget.preselectedMemberId);
      if (index >= 0) {
        member = _familyMembers[index];
      } else {
        // Create a member struct if not found (e.g., for self scan)
        member = FamilyMemberStruct(
          id: widget.preselectedMemberId!,
          name: widget.preselectedMemberName!,
        );
      }
      // Automatically start a session for this member
      await _selectMember(member);
    }
  }

  Future<void> _selectMember(FamilyMemberStruct member) async {
    // Don't create session yet - wait until first photo is captured
    // This prevents empty sessions from being created
    safeSetState(() {
      _currentSessionId = null; // Reset session ID
      _capturedImages = [];
      _selectedMember = member;
      _showingTargetSelector = false;
      // Update tab to match selected member
      final index = _familyMembers.indexWhere((m) => m.id == member.id);
      if (index >= 0 && _model.tabBarController != null) {
        _model.tabBarController!.animateTo(index);
      }
    });
  }

  /// Creates the session in the database when the first photo is captured
  Future<String?> _ensureSessionCreated() async {
    if (_currentSessionId != null) {
      return _currentSessionId;
    }

    if (_selectedMember == null) {
      return null;
    }

    final sessionId = const Uuid().v4();
    final now = DateTime.now();

    try {
      if (AppState().UserSession.isLocalSession) {
        await SQLiteManager.instance.createScanSession(
          id: sessionId,
          familyMemberId: _selectedMember!.id,
          sessionStart: now.millisecondsSinceEpoch ~/ 1000,
          status: 'in_progress',
          notes: '',
          totalImagesCaptured: 0,
        );
      } else {
        // Retry up to 3 times for network issues
        int attempts = 0;
        while (attempts < 3) {
          try {
            await ScanSessionsTable().insert({
              'id': sessionId,
              'family_member_id': _selectedMember!.id,
              'session_start': supaSerialize<DateTime>(now),
              'status': 'in_progress',
              'notes': '',
              'total_images_captured': 0,
            });
            break; // Success, exit loop
          } catch (e) {
            attempts++;
            if (attempts >= 3) {
              rethrow;
            }
            // Wait a bit before retrying
            await Future.delayed(const Duration(milliseconds: 500));
          }
        }
      }

      _currentSessionId = sessionId;
      return sessionId;
    } catch (e) {
      debugPrint('Error creating session: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Failed to start session. Please check your connection and try again.'),
            backgroundColor: BinaColors.error,
          ),
        );
      }
      return null;
    }
  }

  void _goBackToSelector() {
    safeSetState(() {
      _showingTargetSelector = true;
      _selectedMember = null;
      _currentSessionId = null;
      _capturedImages = [];
    });
  }

  Future<void> _captureFromCamera() async {
    if (kIsWeb) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Camera is not available on web'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (_selectedMember == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a family member first')),
      );
      return;
    }

    final cameraConnection = AppState().cameraConnection;

    // If Bina camera is connected, enter preview mode
    if (cameraConnection.isCameraConnected()) {
      safeSetState(() {
        _isInPreviewMode = true;
      });
      return;
    }

    // Otherwise use phone camera
    final picker = ImagePicker();
    final image = await picker.pickImage(
      source: ImageSource.camera,
      maxWidth: 1920,
      maxHeight: 1920,
      imageQuality: 90,
    );

    if (image != null) {
      await _processImageFromPath(image.path);
    }
  }

  void _exitPreviewMode() {
    safeSetState(() {
      _isInPreviewMode = false;
      _isCapturingFromStream = false;
    });
  }

  Future<void> _captureFromStream() async {
    if (_isCapturingFromStream) return;

    final cameraConnection = AppState().cameraConnection;
    if (!cameraConnection.isCameraConnected()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Camera disconnected'),
          backgroundColor: BinaColors.error,
        ),
      );
      _exitPreviewMode();
      return;
    }

    safeSetState(() {
      _isCapturingFromStream = true;
    });

    try {
      final imagePath = await MjpegCaptureService.instance.captureFrame(
        cameraIP: cameraConnection.cameraHost,
        port: cameraConnection.cameraPort,
      );

      if (imagePath != null) {
        // Stay in preview mode - just reset capturing state
        safeSetState(() {
          _isCapturingFromStream = false;
        });

        // Process the image in background while staying in preview
        await _processImageFromPath(imagePath);

        // Show success feedback
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.check_circle, color: Colors.white, size: 20),
                  const SizedBox(width: 8),
                  Text('Photo captured! (${_capturedImages.length} total)'),
                ],
              ),
              backgroundColor: BinaColors.success,
              duration: const Duration(seconds: 1),
            ),
          );
        }
      } else {
        safeSetState(() {
          _isCapturingFromStream = false;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Failed to capture photo'),
              backgroundColor: BinaColors.error,
            ),
          );
        }
      }
    } catch (e) {
      safeSetState(() {
        _isCapturingFromStream = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error capturing photo: $e'),
            backgroundColor: BinaColors.error,
          ),
        );
      }
    }
  }

  Future<void> _processImageFromPath(String imagePath) async {
    safeSetState(() => _isProcessingImage = true);

    try {
      final result = await actions.runYoloInference(imagePath);

      if (result.isWebPlatform) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Diagnosis is not available on web')),
        );
        return;
      }

      // Ensure session exists before saving the image
      final sessionId = await _ensureSessionCreated();
      if (sessionId == null) {
        safeSetState(() => _isProcessingImage = false);
        return;
      }

      final imageId = const Uuid().v4();
      final now = DateTime.now();

      // Save image to database
      try {
        final originalBytes = await File(imagePath).readAsBytes();
        final diagnosedBytes = result.imagePath.isNotEmpty
            ? await File(result.imagePath).readAsBytes()
            : originalBytes;

        if (AppState().UserSession.isLocalSession) {
          await SQLiteManager.instance.createScanImage(
            id: imageId,
            scanSessionId: sessionId,
            image: originalBytes,
            diagnosedImage: diagnosedBytes,
            capturedAt: now.millisecondsSinceEpoch ~/ 1000,
            rawResponse: jsonEncode(result.detections),
          );
        } else {
          await ScanImagesTable().insert({
            'id': imageId,
            'scan_session_id': sessionId,
            'image_path': imagePath,
            'diagnosed_image_path': result.imagePath,
            'captured_at': supaSerialize<DateTime>(now),
            'raw_response': jsonEncode(result.detections),
          });
        }
      } catch (e) {
        debugPrint('Error saving image to database: $e');
      }

      // Add to captured images list
      final capturedImage = CapturedImage(
        id: imageId,
        originalPath: imagePath,
        diagnosedPath: result.imagePath,
        detections: result.detections,
        capturedAt: now,
      );

      safeSetState(() {
        _capturedImages.add(capturedImage);
      });
    } finally {
      if (mounted) {
        safeSetState(() => _isProcessingImage = false);
      }
    }
  }

  Future<void> _selectFromGallery() async {
    if (kIsWeb) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gallery is not available on web')),
      );
      return;
    }

    if (_selectedMember == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a family member first')),
      );
      return;
    }

    try {
      final picker = ImagePicker();
      final image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 90,
      );

      if (image != null && mounted) {
        // Show loading state
        safeSetState(() => _isProcessingImage = true);

        try {
          final result = await actions.runYoloInference(image.path);

          if (result.isWebPlatform) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Diagnosis is not available on web')),
            );
            return;
          }

          // Ensure session exists before saving the image
          final sessionId = await _ensureSessionCreated();
          if (sessionId == null) {
            safeSetState(() => _isProcessingImage = false);
            return;
          }

          final imageId = const Uuid().v4();
          final now = DateTime.now();

          // Save image to database
          try {
            final originalBytes = await File(image.path).readAsBytes();
            final diagnosedBytes = result.imagePath.isNotEmpty
                ? await File(result.imagePath).readAsBytes()
                : originalBytes;

            if (AppState().UserSession.isLocalSession) {
              await SQLiteManager.instance.createScanImage(
                id: imageId,
                scanSessionId: sessionId,
                image: originalBytes,
                diagnosedImage: diagnosedBytes,
                capturedAt: now.millisecondsSinceEpoch ~/ 1000,
                rawResponse: jsonEncode(result.detections),
              );
            } else {
              await ScanImagesTable().insert({
                'id': imageId,
                'scan_session_id': sessionId,
                'image_path': image.path,
                'diagnosed_image_path': result.imagePath,
                'captured_at': supaSerialize<DateTime>(now),
                'raw_response': jsonEncode(result.detections),
              });
            }
          } catch (e) {
            debugPrint('Error saving image to database: $e');
          }

          // Add to captured images list
          final capturedImage = CapturedImage(
            id: imageId,
            originalPath: image.path,
            diagnosedPath: result.imagePath,
            detections: result.detections,
            capturedAt: now,
          );

          safeSetState(() {
            _capturedImages.add(capturedImage);
          });
        } finally {
          if (mounted) {
            safeSetState(() => _isProcessingImage = false);
          }
        }
      }
    } catch (e) {
      safeSetState(() => _isProcessingImage = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error processing image: $e')),
        );
      }
    }
  }

  Map<String, dynamic> _aggregateFindings() {
    final allDetections = <Map<String, dynamic>>[];
    for (final image in _capturedImages) {
      for (final d in image.detections) {
        allDetections.add(d as Map<String, dynamic>);
      }
    }

    final issues = allDetections.where((d) => !(d['className'] as String).startsWith('tooth_')).toList();
    final teeth = allDetections.where((d) => (d['className'] as String).startsWith('tooth_')).toList();

    return {
      'total_images': _capturedImages.length,
      'total_detections': allDetections.length,
      'issues_count': issues.length,
      'teeth_count': teeth.length,
      'issues': issues,
      'teeth': teeth,
    };
  }

  Widget _buildCameraPreview() {
    final cameraConnection = AppState().cameraConnection;
    final streamUrl = 'http://${cameraConnection.cameraHost}:${cameraConnection.cameraPort}/stream.mjpg';

    return Column(
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
                icon: Icons.arrow_back_rounded,
                onPressed: _exitPreviewMode,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppLocalizations.of(context).getText('diag_camera_preview'),
                      style: BinaType.titleLg,
                    ),
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
                          '${AppLocalizations.of(context).getText('diag_connected')} · ${cameraConnection.cameraHost}',
                          style: BinaType.bodySm.copyWith(color: BinaColors.ink2),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Photo count badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: BinaColors.primary100,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${_capturedImages.length} ${AppLocalizations.of(context).getText('member_photos')}',
                  style: BinaType.labelSm.copyWith(
                    color: BinaColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),

        // Camera stream
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: BinaColors.surfaceSunken,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: BinaColors.line, width: 2),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(22),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    // MJPEG Stream
                    MJPEGStreamScreen(
                      streamUrl: streamUrl,
                      fit: BoxFit.contain,
                      showLiveIcon: false,
                    ),
                    // LIVE badge
                    Positioned(
                      top: 16,
                      left: 16,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: BinaColors.error,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              AppLocalizations.of(context).getText('diag_live'),
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
                  ],
                ),
              ),
            ),
          ),
        ),

        // Capture button area
        Container(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          decoration: BoxDecoration(
            color: BinaColors.surface,
            border: Border(top: BorderSide(color: BinaColors.line)),
          ),
          child: Column(
            children: [
              // Capture button
              _CapturePhotoButton(
                isCapturing: _isCapturingFromStream,
                onPressed: _captureFromStream,
              ),
              const SizedBox(height: 12),
              // Instructions
              Text(
                AppLocalizations.of(context).getText('diag_position_teeth'),
                style: BinaType.bodySm.copyWith(color: BinaColors.ink3),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _finishSession() async {
    if (_capturedImages.isEmpty || _selectedMember == null || _currentSessionId == null) {
      return;
    }

    safeSetState(() => _isFinishingSession = true);

    final now = DateTime.now();
    final recordId = const Uuid().v4();
    final findings = _aggregateFindings();
    final overallStatus = (findings['issues_count'] as int) > 0 ? 'attention_needed' : 'healthy';

    try {
      if (AppState().UserSession.isLocalSession) {
        // Update session status
        await SQLiteManager.instance.updateScanSessionEnd(
          id: _currentSessionId,
          sessionEnd: now.millisecondsSinceEpoch ~/ 1000,
          status: 'completed',
          totalImagesCaptured: _capturedImages.length,
        );

        // Create dental record
        await SQLiteManager.instance.createDentalRecord(
          id: recordId,
          familyMemberId: _selectedMember!.id,
          scanSessionId: _currentSessionId,
          recordDate: now.millisecondsSinceEpoch ~/ 1000,
          findingsSnapshot: jsonEncode(findings),
          overallStatus: overallStatus,
        );

        // Update last_checked
        await SQLiteManager.instance.updateLastChecked(
          id: _selectedMember!.id,
          lastChecked: now.millisecondsSinceEpoch ~/ 1000,
        );
      } else {
        // Update session status in Supabase
        await ScanSessionsTable().update(
          data: {
            'session_end': supaSerialize<DateTime>(now),
            'status': 'completed',
            'total_images_captured': _capturedImages.length,
          },
          matchingRows: (rows) => rows.eq('id', _currentSessionId!),
        );

        // Create dental record in Supabase
        await DentalRecordsTable().insert({
          'id': recordId,
          'family_member_id': _selectedMember!.id,
          'scan_session_id': _currentSessionId,
          'record_date': supaSerialize<DateTime>(now),
          'findings_snapshot': jsonEncode(findings),
          'overall_status': overallStatus,
        });

        // Update last_checked in Supabase
        await FamilyMembersTable().update(
          data: {
            'last_checked': supaSerialize<DateTime>(now),
          },
          matchingRows: (rows) => rows
              .eqOrNull('account_id', AppState().UserSession.userID)
              .eqOrNull('id', _selectedMember!.id),
        );
      }

      // Update local state
      final familyIndex = AppState()
          .UserSession
          .family
          .indexWhere((m) => m.id == _selectedMember!.id);
      if (familyIndex != -1) {
        AppState().UserSession.family[familyIndex].lastChecked = now;
      }

      // Navigate to summary
      if (mounted) {
        context.pushReplacementNamed(
          SessionSummaryWidget.routeName,
          extra: <String, dynamic>{
            'sessionId': _currentSessionId,
            'imageCount': _capturedImages.length,
            'memberName': _selectedMember!.name,
            'overallStatus': overallStatus,
          },
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error finishing session: $e'),
            backgroundColor: BinaColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        safeSetState(() => _isFinishingSession = false);
      }
    }
  }

  void _showImageDetail(CapturedImage image) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _ImageDetailSheet(
        image: image,
        memberName: _selectedMember?.name ?? 'Unknown',
      ),
    );
  }

  // Calculate totals from all captured images
  int get _totalTeeth => _capturedImages.fold(0, (sum, img) => sum + img.teethCount);
  int get _totalIssues => _capturedImages.fold(0, (sum, img) => sum + img.issuesCount);

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    context.watch<AppState>();

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
            // Web nav for larger screens
            if (responsiveVisibility(
              context: context,
              phone: false,
              tablet: false,
            ))
              wrapWithModel(
                model: _model.webNavModel,
                updateCallback: () => safeSetState(() {}),
                child: const WebNavWidget(),
              ),
            // Main content
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // Content based on state - Positioned.fill ensures nav sticks to bottom
                  if (_isInPreviewMode)
                    Positioned.fill(
                      child: SafeArea(
                        child: _buildCameraPreview(),
                      ),
                    )
                  else if (_showingTargetSelector)
                    Positioned.fill(
                      child: SafeArea(
                        child: _ScanTargetSelector(
                          familyMembers: _familyMembers,
                          isLoading: _model.isLoading,
                          onSelectMember: _selectMember,
                          onCancel: () => context.pop(),
                        ),
                      ),
                    )
                  else
                    Positioned.fill(
                      child: SafeArea(
                        child: _ScanSessionView(
                          member: _selectedMember,
                          familyMembers: _familyMembers,
                          model: _model,
                          onBack: _goBackToSelector,
                          onReload: () => safeSetState(() {}),
                          onCameraPressed: _captureFromCamera,
                          onGalleryPressed: _selectFromGallery,
                          onFinishSession: _finishSession,
                          capturedImages: _capturedImages,
                        isProcessing: _isProcessingImage,
                        isFinishing: _isFinishingSession,
                        onImageTap: _showImageDetail,
                          totalTeeth: _totalTeeth,
                          totalIssues: _totalIssues,
                        ),
                      ),
                    ),
                  // Floating bottom nav (phone only) - hide when in preview mode
                  if (!_isInPreviewMode && responsiveVisibility(
                    context: context,
                    tablet: false,
                    tabletLandscape: false,
                    desktop: false,
                  ))
                    const BinaFloatingNav(currentTab: BinaNavTab.scan),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// SCAN TARGET SELECTOR
// ═══════════════════════════════════════════════════════════════

class _ScanTargetSelector extends StatelessWidget {
  const _ScanTargetSelector({
    required this.familyMembers,
    required this.isLoading,
    required this.onSelectMember,
    required this.onCancel,
  });

  final List<FamilyMemberStruct> familyMembers;
  final bool isLoading;
  final void Function(FamilyMemberStruct) onSelectMember;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    final user = AppState().UserSession;

    return SingleChildScrollView(
      padding: const EdgeInsets.only(
        top: 12,
        bottom: 120,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: Row(
              children: [
                BinaIconButton(
                  icon: Icons.chevron_left_rounded,
                  onPressed: onCancel,
                ),
                const Spacer(),
                Text(
                  AppLocalizations.of(context).getText('diag_step_1'),
                  style: BinaType.labelMd,
                ),
                const Spacer(),
                const SizedBox(width: 44),
              ],
            ),
          ).animate()
              .fadeIn(duration: 400.ms)
              .moveY(begin: 10, end: 0, duration: 400.ms),

          // Title
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppLocalizations.of(context).getText('diag_who_scanning'),
                  style: BinaType.displaySm,
                ),
                const SizedBox(height: 8),
                Text(
                  AppLocalizations.of(context).getText('diag_pick_member'),
                  style: BinaType.bodyLg.copyWith(color: BinaColors.ink2),
                ),
              ],
            ),
          ).animate()
              .fadeIn(delay: 100.ms, duration: 400.ms)
              .moveY(begin: 20, end: 0, delay: 100.ms, duration: 400.ms),

          // "Scan myself" hero card
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
            child: _SelfScanCard(
              userName: user.name,
              onTap: () {
                // Create a self member struct
                final selfMember = FamilyMemberStruct(
                  id: user.userID,
                  name: user.name,
                  admin: true,
                );
                onSelectMember(selfMember);
              },
            ),
          ).animate()
              .fadeIn(delay: 200.ms, duration: 400.ms)
              .moveY(begin: 20, end: 0, delay: 200.ms, duration: 400.ms),

          // Family members list
          if (isLoading)
            const Padding(
              padding: EdgeInsets.all(40),
              child: Center(child: CircularProgressIndicator()),
            )
          else if (familyMembers.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 8),
              child: Text(
                AppLocalizations.of(context).getText('diag_family_members'),
                style: BinaType.overline,
              ),
            ).animate()
                .fadeIn(delay: 300.ms, duration: 400.ms),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: familyMembers.asMap().entries.map((entry) {
                  final index = entry.key;
                  final member = entry.value;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _MemberSelectCard(
                      member: member,
                      onTap: () => onSelectMember(member),
                    ),
                  ).animate()
                      .fadeIn(
                        delay: Duration(milliseconds: 350 + (index * 80)),
                        duration: 400.ms,
                      )
                      .moveY(
                        begin: 20,
                        end: 0,
                        delay: Duration(milliseconds: 350 + (index * 80)),
                        duration: 400.ms,
                      );
                }).toList(),
              ),
            ),
          ] else
            Padding(
              padding: const EdgeInsets.all(40),
              child: Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.groups_outlined,
                      size: 48,
                      color: BinaColors.ink3,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      AppLocalizations.of(context).getText('diag_no_family'),
                      style: BinaType.titleMd.copyWith(color: BinaColors.ink2),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      AppLocalizations.of(context).getText('diag_add_members'),
                      style: BinaType.bodySm,
                    ),
                  ],
                ),
              ),
            ).animate()
                .fadeIn(delay: 300.ms, duration: 400.ms),
        ],
      ),
    );
  }
}

class _SelfScanCard extends StatefulWidget {
  const _SelfScanCard({
    required this.userName,
    required this.onTap,
  });

  final String userName;
  final VoidCallback onTap;

  @override
  State<_SelfScanCard> createState() => _SelfScanCardState();
}

class _SelfScanCardState extends State<_SelfScanCard> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final initials = widget.userName.isNotEmpty
        ? widget.userName.substring(0, widget.userName.length.clamp(0, 2)).toUpperCase()
        : 'ME';

    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: widget.onTap,
      child: AnimatedContainer(
        duration: BinaMotion.d1,
        transform: _isPressed
            ? (Matrix4.identity()..setEntry(0, 0, 0.98)..setEntry(1, 1, 0.98))
            : Matrix4.identity(),
        transformAlignment: Alignment.center,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: BinaColors.gradHero,
          borderRadius: BorderRadius.circular(18),
          boxShadow: BinaElevation.shHero,
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  initials,
                  style: BinaType.titleMd.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppLocalizations.of(context).getText('diag_scan_myself'),
                    style: BinaType.titleLg.copyWith(color: Colors.white),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    widget.userName.isNotEmpty ? widget.userName : AppLocalizations.of(context).getText('diag_your_account'),
                    style: BinaType.bodySm.copyWith(
                      color: Colors.white.withValues(alpha: 0.85),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: Colors.white.withValues(alpha: 0.8),
              size: 24,
            ),
          ],
        ),
      ),
    );
  }
}

class _MemberSelectCard extends StatelessWidget {
  const _MemberSelectCard({
    required this.member,
    required this.onTap,
  });

  final FamilyMemberStruct member;
  final VoidCallback onTap;

  int? get _age {
    if (!member.hasBirthday()) return null;
    return DateTime.now().difference(member.birthday!).inDays ~/ 365;
  }

  String _getLastCheckedStr(BuildContext context) {
    if (!member.hasLastChecked()) return AppLocalizations.of(context).getText('member_never_checked');
    final date = member.lastChecked!;
    final diff = DateTime.now().difference(date);
    if (diff.inDays == 0) return AppLocalizations.of(context).getText('diag_checked_today');
    if (diff.inDays == 1) return AppLocalizations.of(context).getText('diag_checked_yesterday');
    if (diff.inDays < 7) return '${AppLocalizations.of(context).getText('diag_checked_today').split(' ')[0]} ${diff.inDays} ${AppLocalizations.of(context).getText('family_days_ago')}';
    return '${AppLocalizations.of(context).getText('member_last_checked_date')} ${DateFormat('d MMM').format(date)}';
  }

  BinaAvatarTone get _avatarTone {
    final hash = member.name.hashCode;
    final tones = BinaAvatarTone.values;
    return tones[hash.abs() % (tones.length - 1)];
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: BinaColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: BinaColors.line),
          boxShadow: BinaElevation.sh1,
        ),
        child: Row(
          children: [
            BinaAvatar(
              name: member.name,
              size: 44,
              tone: _avatarTone,
              imageUrl: member.profilePic.isNotEmpty ? member.profilePic : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    member.name,
                    style: BinaType.titleMd,
                  ),
                  const SizedBox(height: 1),
                  Text(
                    '${_age != null ? '$_age ${AppLocalizations.of(context).getText('diag_yrs')} · ' : ''}${_getLastCheckedStr(context)}',
                    style: BinaType.bodySm.copyWith(color: BinaColors.ink3),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: BinaColors.ink3,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// SCAN SESSION VIEW (shows after selecting a member)
// ═══════════════════════════════════════════════════════════════

class _ScanSessionView extends StatelessWidget {
  const _ScanSessionView({
    required this.member,
    required this.familyMembers,
    required this.model,
    required this.onBack,
    required this.onReload,
    required this.onCameraPressed,
    required this.onGalleryPressed,
    required this.onFinishSession,
    required this.capturedImages,
    required this.isProcessing,
    required this.isFinishing,
    required this.onImageTap,
    required this.totalTeeth,
    required this.totalIssues,
  });

  final FamilyMemberStruct? member;
  final List<FamilyMemberStruct> familyMembers;
  final MainDIagnosticsModel model;
  final VoidCallback onBack;
  final VoidCallback onReload;
  final VoidCallback onCameraPressed;
  final VoidCallback onGalleryPressed;
  final VoidCallback onFinishSession;
  final List<CapturedImage> capturedImages;
  final bool isProcessing;
  final bool isFinishing;
  final void Function(CapturedImage) onImageTap;
  final int totalTeeth;
  final int totalIssues;

  @override
  Widget build(BuildContext context) {
    final photoCount = capturedImages.length;

    return Stack(
      children: [
        SingleChildScrollView(
          padding: const EdgeInsets.only(
            top: 12,
            bottom: 120,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                child: Row(
                  children: [
                    BinaIconButton(
                      icon: Icons.chevron_left_rounded,
                      onPressed: onBack,
                    ),
                    const Spacer(),
                    Column(
                      children: [
                        Text(
                          AppLocalizations.of(context).getText('phts001'), // Photo Session
                          style: BinaType.titleMd,
                        ),
                        Text(
                          member?.name ?? 'Unknown',
                          style: BinaType.bodySm.copyWith(color: BinaColors.ink2),
                        ),
                      ],
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: BinaColors.primary100,
                        borderRadius: BorderRadius.circular(BinaRadius.pill),
                      ),
                      child: Text(
                        '$photoCount photo${photoCount == 1 ? '' : 's'}',
                        style: BinaType.labelMd.copyWith(
                          color: BinaColors.primary700,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Summary stats card
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: BinaColors.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: BinaColors.line),
                    boxShadow: BinaElevation.sh1,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: _StatColumn(label: 'PHOTOS', value: '$photoCount', tone: 'primary'),
                      ),
                      Container(width: 1, height: 36, color: BinaColors.line),
                      Expanded(
                        child: _StatColumn(label: 'TEETH', value: '$totalTeeth', tone: 'ink'),
                      ),
                      Container(width: 1, height: 36, color: BinaColors.line),
                      Expanded(
                        child: _StatColumn(
                          label: 'ISSUES',
                          value: '$totalIssues',
                          tone: totalIssues == 0 ? 'good' : 'cavity',
                        ),
                      ),
                    ],
                  ),
                ),
              ),

          // Camera connection button
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
            child: GestureDetector(
              onTap: () {
                context.pushNamed(CameraConnectionWidget.routeName);
              },
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: BinaColors.surface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: BinaColors.lineStrong,
                    style: BorderStyle.solid,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: BinaColors.surfaceSunken,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        Icons.camera_alt_rounded,
                        color: BinaColors.ink2,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            AppLocalizations.of(context).getText('diag_connect_camera'),
                            style: BinaType.titleSm,
                          ),
                          Text(
                            AppLocalizations.of(context).getText('diag_phone_or_bina'),
                            style: BinaType.bodySm.copyWith(color: BinaColors.ink3),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.chevron_right_rounded,
                      color: BinaColors.ink3,
                      size: 18,
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Captured photos section
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(AppLocalizations.of(context).getText('diag_captured_photos'), style: BinaType.headlineSm),
                const SizedBox(height: 12),
                if (capturedImages.isEmpty)
                  // Empty state
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 20),
                    decoration: BoxDecoration(
                      color: BinaColors.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: BinaColors.lineStrong,
                        style: BorderStyle.solid,
                      ),
                    ),
                    child: Column(
                      children: [
                        Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            color: BinaColors.primary100,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Icon(
                            Icons.camera_alt_rounded,
                            color: BinaColors.primary,
                            size: 28,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          AppLocalizations.of(context).getText('diag_no_photos'),
                          style: BinaType.titleMd,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          AppLocalizations.of(context).getText('diag_capture_instructions'),
                          style: BinaType.bodySm.copyWith(color: BinaColors.ink3),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  )
                else
                  // Photo grid
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 8,
                    ),
                    itemCount: capturedImages.length,
                    itemBuilder: (context, index) {
                      final image = capturedImages[index];
                      return GestureDetector(
                        onTap: () => onImageTap(image),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: image.issuesCount > 0
                                  ? BinaColors.dxCavity
                                  : BinaColors.dxGood,
                              width: 2,
                            ),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                Image.file(
                                  File(image.diagnosedPath),
                                  fit: BoxFit.cover,
                                ),
                                // Issue badge
                                if (image.issuesCount > 0)
                                  Positioned(
                                    top: 4,
                                    right: 4,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 6,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: BinaColors.dxCavity,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        '${image.issuesCount}',
                                        style: BinaType.labelSm.copyWith(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                // Tap indicator
                                Positioned(
                                  bottom: 4,
                                  right: 4,
                                  child: Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: BoxDecoration(
                                      color: Colors.black54,
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: const Icon(
                                      Icons.zoom_in,
                                      color: Colors.white,
                                      size: 14,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
              ],
            ),
          ),

          // Capture buttons
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: BinaButton(
                        label: AppLocalizations.of(context).getText('phts013'), // Camera
                        icon: Icons.camera_alt_rounded,
                        onPressed: onCameraPressed,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: BinaButton(
                        label: AppLocalizations.of(context).getText('phts012'), // Gallery
                        variant: BinaButtonVariant.ghost,
                        icon: Icons.photo_library_rounded,
                        onPressed: onGalleryPressed,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: BinaButton(
                    label: isFinishing
                        ? AppLocalizations.of(context).getText('phts011') // Processing...
                        : AppLocalizations.of(context).getText('phts019'), // Finish Session
                    variant: capturedImages.isNotEmpty
                        ? BinaButtonVariant.primary
                        : BinaButtonVariant.ghost,
                    icon: isFinishing ? null : Icons.check_rounded,
                    fullWidth: true,
                    enabled: capturedImages.isNotEmpty && !isFinishing,
                    onPressed: capturedImages.isNotEmpty && !isFinishing
                        ? onFinishSession
                        : null,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      ),
      // Loading overlay
      if (isProcessing)
        Positioned.fill(
          child: Container(
            color: Colors.black.withValues(alpha: 0.5),
            child: Center(
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: BinaColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: BinaElevation.sh3,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(
                      width: 48,
                      height: 48,
                      child: CircularProgressIndicator(
                        strokeWidth: 3,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      AppLocalizations.of(context).getText('diag_analyzing'),
                      style: BinaType.titleSm,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      AppLocalizations.of(context).getText('diag_may_take'),
                      style: BinaType.bodySm.copyWith(color: BinaColors.ink2),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      // Finishing overlay
      if (isFinishing)
        Positioned.fill(
          child: Container(
            color: Colors.black.withValues(alpha: 0.5),
            child: Center(
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: BinaColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: BinaElevation.sh3,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(
                      width: 48,
                      height: 48,
                      child: CircularProgressIndicator(
                        strokeWidth: 3,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      AppLocalizations.of(context).getText('diag_saving'),
                      style: BinaType.titleSm,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      AppLocalizations.of(context).getText('diag_creating_record'),
                      style: BinaType.bodySm.copyWith(color: BinaColors.ink2),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _StatColumn extends StatelessWidget {
  const _StatColumn({
    required this.label,
    required this.value,
    required this.tone,
  });

  final String label;
  final String value;
  final String tone;

  Color get _valueColor {
    switch (tone) {
      case 'primary': return BinaColors.primary;
      case 'good': return BinaColors.dxGood;
      case 'cavity': return BinaColors.dxCavity;
      default: return BinaColors.ink;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: BinaType.headlineMd.copyWith(
            color: _valueColor,
            letterSpacing: -0.01 * 22,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: BinaType.labelSm.copyWith(
            color: BinaColors.ink3,
            letterSpacing: 0.08 * 11,
          ),
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// IMAGE DETAIL SHEET (floating view when tapping a photo)
// ═══════════════════════════════════════════════════════════════

class _ImageDetailSheet extends StatelessWidget {
  const _ImageDetailSheet({
    required this.image,
    required this.memberName,
  });

  final CapturedImage image;
  final String memberName;

  String _formatClassName(String className) {
    final words = className.split('_');
    return words.map((word) {
      if (word.isEmpty) return word;
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }).join(' ');
  }

  @override
  Widget build(BuildContext context) {
    final issues = image.detections.where((d) =>
      !(d['className'] as String).startsWith('tooth_')).toList();
    final teeth = image.detections.where((d) =>
      (d['className'] as String).startsWith('tooth_')).toList();

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: BoxDecoration(
        color: BinaColors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: BinaColors.ink3,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(AppLocalizations.of(context).getText('diag_photo_detail'), style: BinaType.headlineSm),
                    Text(
                      memberName,
                      style: BinaType.bodySm.copyWith(color: BinaColors.ink2),
                    ),
                  ],
                ),
                BinaIconButton(
                  icon: Icons.close_rounded,
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Image
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Diagnosed image
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.file(
                      File(image.diagnosedPath),
                      width: double.infinity,
                      fit: BoxFit.contain,
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Status summary
                  Row(
                    children: [
                      if (issues.isEmpty)
                        const DxChip(kind: DxChipKind.good)
                      else
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: BinaColors.dxCavity,
                            borderRadius: BorderRadius.circular(BinaRadius.pill),
                          ),
                          child: Text(
                            '${issues.length} Issue${issues.length > 1 ? 's' : ''} Found',
                            style: BinaType.labelMd.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      const SizedBox(width: 8),
                      Text(
                        '${teeth.length} ${AppLocalizations.of(context).getText('diag_teeth_detected').toLowerCase()}',
                        style: BinaType.bodySm,
                      ),
                    ],
                  ),

                  // Issues list
                  if (issues.isNotEmpty) ...[
                    const SizedBox(height: 20),
                    Text(
                      AppLocalizations.of(context).getText('diag_issues_found'),
                      style: BinaType.titleSm.copyWith(color: BinaColors.dxCavity),
                    ),
                    const SizedBox(height: 8),
                    ...issues.map((d) {
                      final className = d['className'] as String;
                      final confidence = d['confidence'] as double;
                      final displayName = _formatClassName(className);

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: BinaColors.dxCavity100,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: BinaColors.dxCavity.withValues(alpha: 0.3),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.warning_amber_rounded,
                                    color: BinaColors.dxCavity,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
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
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: BinaColors.dxCavity,
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

                  // Teeth detected
                  if (teeth.isNotEmpty) ...[
                    const SizedBox(height: 20),
                    Text(AppLocalizations.of(context).getText('diag_teeth_detected'), style: BinaType.titleSm),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: teeth.map((d) {
                        final className = d['className'] as String;
                        final toothNumber = className.replaceFirst('tooth_', '');
                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
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
                  ],

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// CAPTURE PHOTO BUTTON
// ═══════════════════════════════════════════════════════════════

class _CapturePhotoButton extends StatefulWidget {
  const _CapturePhotoButton({
    required this.isCapturing,
    required this.onPressed,
  });

  final bool isCapturing;
  final VoidCallback onPressed;

  @override
  State<_CapturePhotoButton> createState() => _CapturePhotoButtonState();
}

class _CapturePhotoButtonState extends State<_CapturePhotoButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: !widget.isCapturing ? (_) => setState(() => _isPressed = true) : null,
      onTapUp: !widget.isCapturing ? (_) => setState(() => _isPressed = false) : null,
      onTapCancel: !widget.isCapturing ? () => setState(() => _isPressed = false) : null,
      onTap: !widget.isCapturing ? widget.onPressed : null,
      child: AnimatedContainer(
        duration: BinaMotion.d1,
        width: 80,
        height: 80,
        transform: _isPressed
            ? (Matrix4.identity()..scale(0.9, 0.9))
            : Matrix4.identity(),
        transformAlignment: Alignment.center,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: widget.isCapturing ? null : BinaColors.gradHero,
          color: widget.isCapturing ? BinaColors.surfaceSunken : null,
          boxShadow: widget.isCapturing ? null : BinaElevation.shHero,
        ),
        child: widget.isCapturing
            ? Center(
                child: SizedBox(
                  width: 32,
                  height: 32,
                  child: CircularProgressIndicator(
                    strokeWidth: 3,
                    color: BinaColors.primary,
                  ),
                ),
              )
            : const Icon(
                Icons.camera_alt_rounded,
                color: Colors.white,
                size: 36,
              ),
      ),
    );
  }
}
