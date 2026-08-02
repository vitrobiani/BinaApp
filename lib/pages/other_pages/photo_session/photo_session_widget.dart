import 'dart:async';
import 'dart:io';

import 'package:image/image.dart' as img;
import '/backend/supabase/supabase.dart';
import '/backend/sqlite/sqlite_manager.dart';
import '/backend/schema/structs/index.dart';
import 'dart:convert';
import '/bina_design/bina_design.dart';
import '/app_core/app_util.dart';
import '/custom_code/actions/index.dart' as actions;
import '/pages/nav_pages/web_nav/web_nav_widget.dart';
import '/index.dart';
import '/services/mjpeg_capture_service.dart';
import '/services/gyro_controller_service.dart';
import '/services/mouth_region_estimator.dart';
import '/components/dialogs/confirm_dialog.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mjpeg_stream/mjpeg_stream.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '/services/gemma_service.dart';
import '/services/llm_prompts.dart';
import 'photo_session_model.dart';
export 'photo_session_model.dart';

class PhotoSessionWidget extends StatefulWidget {
  const PhotoSessionWidget({
    super.key,
    this.memberId,
    this.memberName,
  });

  final String? memberId;
  final String? memberName;

  static String routeName = 'PhotoSession';
  static String routePath = 'photoSession';

  @override
  State<PhotoSessionWidget> createState() => _PhotoSessionWidgetState();
}

class _PhotoSessionWidgetState extends State<PhotoSessionWidget> {
  late PhotoSessionModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  String? _currentSessionId;
  List<ScanImageStruct> _sessionImages = [];
  bool _isProcessing = false;
  bool _isInitialized = false;

  // Camera preview state
  bool _isInPreviewMode = false;
  bool _isCapturingFromStream = false;

  // Real-time detection state
  Timer? _analysisTimer;
  List<Map<String, dynamic>> _realtimeDetections = [];
  bool _isAnalyzing = false;
  int _imageWidth = 640;
  int _imageHeight = 480;

  final Map<String, String> _imageInterpretations = {};
  final Set<String> _interpretingImages = {};

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => PhotoSessionModel());

    SchedulerBinding.instance.addPostFrameCallback((_) async {
      await _initSession();
      if (widget.memberId != null && widget.memberId!.isNotEmpty) {
        await AppState().loadMemberCalibration(widget.memberId);
      }
    });
  }

  @override
  void dispose() {
    _analysisTimer?.cancel();
    _model.dispose();
    super.dispose();
  }

  Future<void> _initSession() async {
    // Check if memberId is valid
    if (widget.memberId == null || widget.memberId!.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('No family member selected. Please select a member to scan.'),
            backgroundColor: BinaColors.error,
          ),
        );
      }
      return;
    }

    // Don't create the session yet - wait until first photo is captured
    // This prevents empty sessions from being created
    safeSetState(() {
      _isInitialized = true;
    });
  }

  /// Creates the session in the database when the first photo is captured
  Future<String?> _ensureSessionCreated() async {
    if (_currentSessionId != null) {
      return _currentSessionId;
    }

    final sessionId = const Uuid().v4();
    final now = DateTime.now();

    try {
      if (AppState().UserSession.isLocalSession) {
        await SQLiteManager.instance.createScanSession(
          id: sessionId,
          familyMemberId: widget.memberId,
          sessionStart: now.millisecondsSinceEpoch ~/ 1000,
          status: 'in_progress',
          totalImagesCaptured: 0,
        );
      } else {
        await ScanSessionsTable().insert({
          'id': sessionId,
          'family_member_id': widget.memberId,
          'session_start': supaSerialize<DateTime>(now),
          'status': 'in_progress',
          'total_images_captured': 0,
        });
      }

      _currentSessionId = sessionId;
      return sessionId;
    } catch (e) {
      debugPrint('Session creation error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to start session: $e'),
            backgroundColor: BinaColors.error,
          ),
        );
      }
      return null;
    }
  }

  Future<void> _captureFromCamera() async {
    debugPrint('>>> _captureFromCamera called');
    if (kIsWeb) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context).getText('phts020')),
          backgroundColor: BinaColors.warning,
        ),
      );
      return;
    }

    final cameraConnection = AppState().cameraConnection;
    debugPrint('>>> Camera connected: ${cameraConnection.isCameraConnected()}');
    debugPrint('>>> Camera host: ${cameraConnection.cameraHost}:${cameraConnection.cameraPort}');

    // If Bina camera is connected, enter preview mode
    if (cameraConnection.isCameraConnected()) {
      debugPrint('>>> Entering preview mode');
      safeSetState(() {
        _isInPreviewMode = true;
      });
      _startRealtimeAnalysis();
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
      await _processImage(image.path);
    }
  }

  void _exitPreviewMode() {
    _stopRealtimeAnalysis();
    safeSetState(() {
      _isInPreviewMode = false;
      _isCapturingFromStream = false;
      _realtimeDetections = [];
    });
  }

  // ═══════════════════════════════════════════════════════════════
  // REAL-TIME DETECTION
  // ═══════════════════════════════════════════════════════════════

  void _startRealtimeAnalysis() {
    debugPrint('>>> Starting real-time analysis');
    _analysisTimer = Timer.periodic(const Duration(milliseconds: 500), (timer) {
      _analyzeCurrentFrame();
    });
  }

  void _stopRealtimeAnalysis() {
    debugPrint('>>> Stopping real-time analysis');
    _analysisTimer?.cancel();
    _analysisTimer = null;
  }

  Future<void> _analyzeCurrentFrame() async {
    debugPrint('>>> _analyzeCurrentFrame: isAnalyzing=$_isAnalyzing, isInPreviewMode=$_isInPreviewMode');
    if (_isAnalyzing || !_isInPreviewMode) return;
    _isAnalyzing = true;

    try {
      final cameraConnection = AppState().cameraConnection;
      debugPrint('>>> _analyzeCurrentFrame: camera connected=${cameraConnection.isCameraConnected()}');
      if (!cameraConnection.isCameraConnected()) return;

      final imagePath = await MjpegCaptureService.instance.captureFrame(
        cameraIP: cameraConnection.cameraHost,
        port: cameraConnection.cameraPort,
      );

      if (imagePath != null) {
        // Get image dimensions
        final imageBytes = await File(imagePath).readAsBytes();
        final decodedImage = img.decodeImage(imageBytes);
        if (decodedImage != null) {
          _imageWidth = decodedImage.width;
          _imageHeight = decodedImage.height;
        }

        final result = await actions.runYoloInference(imagePath);
        debugPrint('=== RT DETECTIONS: ${result.detections.length} ===');

        if (mounted) {
          safeSetState(() {
            _realtimeDetections = result.detections;
          });
        }
      }
    } catch (e) {
      debugPrint('>>> RT analysis error: $e');
    } finally {
      _isAnalyzing = false;
    }
  }

  Widget _buildDetectionOverlay() {
    if (_realtimeDetections.isEmpty) {
      return const SizedBox.shrink();
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final widgetWidth = constraints.maxWidth;
        final widgetHeight = constraints.maxHeight;

        final imageAspect = _imageWidth / _imageHeight;
        final widgetAspect = widgetWidth / widgetHeight;

        double scale, offsetX = 0, offsetY = 0;

        if (imageAspect > widgetAspect) {
          scale = widgetWidth / _imageWidth;
          offsetY = (widgetHeight - (_imageHeight * scale)) / 2;
        } else {
          scale = widgetHeight / _imageHeight;
          offsetX = (widgetWidth - (_imageWidth * scale)) / 2;
        }

        return Stack(
          children: [
            for (final det in _realtimeDetections)
              Positioned(
                left: (det['x1'] as double) * scale + offsetX,
                top: (det['y1'] as double) * scale + offsetY,
                width: ((det['x2'] as double) - (det['x1'] as double)) * scale,
                height: ((det['y2'] as double) - (det['y1'] as double)) * scale,
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

  Future<void> _captureFromStream() async {
    if (_isCapturingFromStream) return;

    final cameraConnection = AppState().cameraConnection;
    if (!cameraConnection.isCameraConnected()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Camera disconnected'),
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
        await _processImage(imagePath);

        // Show success feedback
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.white, size: 20),
                  const SizedBox(width: 8),
                  Text('Photo captured! (${_sessionImages.length} total)'),
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
              content: Text('Failed to capture photo'),
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

  Future<void> _selectFromGallery() async {
    try {
      if (Platform.isAndroid) {
        final androidInfo = await Permission.photos.status;
        if (androidInfo.isDenied || androidInfo.isPermanentlyDenied) {
          final status = await Permission.photos.request();
          if (status.isPermanentlyDenied) {
            if (mounted) {
              final shouldOpenSettings = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  backgroundColor: BinaColors.surface,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  title: Text('Permission Required', style: BinaType.headlineSm),
                  content: Text(
                    'Photo access is required to select images from your gallery. Please enable it in Settings.',
                    style: BinaType.bodyMd,
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: Text('Cancel', style: BinaType.labelLg.copyWith(color: BinaColors.ink2)),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: Text('Open Settings', style: BinaType.labelLg.copyWith(color: BinaColors.primary)),
                    ),
                  ],
                ),
              );
              if (shouldOpenSettings == true) {
                await openAppSettings();
              }
            }
            return;
          }
        }
      }

      final picker = ImagePicker();
      final image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 90,
      );

      if (image != null) {
        await _processImage(image.path);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not access gallery: $e'),
            backgroundColor: BinaColors.error,
          ),
        );
      }
    }
  }

  Future<void> _processImage(String originalPath) async {
    if (kIsWeb) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context).getText('phts022')),
          backgroundColor: BinaColors.warning,
        ),
      );
      return;
    }

    safeSetState(() => _isProcessing = true);

    try {
      final result = await actions.runYoloInference(originalPath);

      if (result.isWebPlatform) {
        safeSetState(() => _isProcessing = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context).getText('phts022')),
            backgroundColor: BinaColors.warning,
          ),
        );
        return;
      }

      // Ensure session exists before saving the image
      final sessionId = await _ensureSessionCreated();
      if (sessionId == null) {
        safeSetState(() => _isProcessing = false);
        return;
      }

      final imageId = const Uuid().v4();
      final originalBytes = await File(originalPath).readAsBytes();
      final diagnosedBytes = await File(result.imagePath).readAsBytes();
      final orientation =
          await GyroControllerService.instance.readOrientationInts();
      final estimatedRegion = (orientation.pitch != null && orientation.roll != null)
          ? MouthRegionEstimator.estimate(
              orientation.pitch!,
              orientation.roll!,
              AppState().memberCalibration,
            )
          : null;

      if (AppState().UserSession.isLocalSession) {
        await SQLiteManager.instance.createScanImage(
          id: imageId,
          scanSessionId: sessionId,
          image: originalBytes,
          diagnosedImage: diagnosedBytes,
          capturedAt: DateTime.now().millisecondsSinceEpoch ~/ 1000,
          rawResponse: jsonEncode(result.detections),
          pitch: orientation.pitch,
          roll: orientation.roll,
          estimatedRegion: estimatedRegion,
        );
      } else {
        await ScanImagesTable().insert({
          'id': imageId,
          'scan_session_id': sessionId,
          'image': originalBytes,
          'diagnosed_image': diagnosedBytes,
          'captured_at': supaSerialize<DateTime>(DateTime.now()),
          'raw_response': jsonEncode(result.detections),
          if (orientation.pitch != null) 'pitch': orientation.pitch,
          if (orientation.roll != null) 'roll': orientation.roll,
          if (estimatedRegion != null) 'estimated_region': estimatedRegion,
        });
      }

      final detectionsJson = jsonEncode(result.detections);

      safeSetState(() {
        _sessionImages.add(ScanImageStruct(
          id: imageId,
          scanSessionId: _currentSessionId,
          imagePath: originalPath,
          diagnosedImagePath: result.imagePath,
          capturedAt: DateTime.now(),
          rawResponse: detectionsJson,
          pitch: orientation.pitch,
          roll: orientation.roll,
          estimatedRegion: estimatedRegion,
        ));
        _isProcessing = false;
      });

      _generateImageInterpretation(imageId, detectionsJson);
    } catch (e) {
      safeSetState(() => _isProcessing = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${AppLocalizations.of(context).getText('phts025')} $e'),
          backgroundColor: BinaColors.error,
        ),
      );
    }
  }

  Future<void> _generateImageInterpretation(String imageId, String detectionsJson) async {
    if (!GemmaService.instance.isModelLoaded) return;
    if (_interpretingImages.contains(imageId)) return;

    _interpretingImages.add(imageId);

    try {
      final prompt = LlmPrompts.buildImageInterpretationPrompt(detectionsJson);
      final response = await GemmaService.instance.generateResponse(prompt);
      if (response.isNotEmpty && mounted) {
        safeSetState(() => _imageInterpretations[imageId] = response);
      }
    } catch (e) {
      debugPrint('LLM interpretation error for $imageId: $e');
    } finally {
      _interpretingImages.remove(imageId);
    }
  }

  void _showImageDetailSheet(ScanImageStruct image) {
    final rawJson = image.rawResponse.isNotEmpty ? image.rawResponse : '[]';
    final detections = jsonDecode(rawJson) as List<dynamic>;
    final interpretation = _imageInterpretations[image.id];

    showModalBottomSheet(
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      enableDrag: true,
      context: context,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.8,
        decoration: BoxDecoration(
          color: BinaColors.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            // Handle
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: BinaColors.line,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            // Title
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text('Image Details', style: BinaType.titleLg),
            ),
            // Image
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (image.diagnosedImagePath.isNotEmpty)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.file(
                          File(image.diagnosedImagePath),
                          fit: BoxFit.contain,
                        ),
                      )
                    else if (image.imagePath.isNotEmpty)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.file(
                          File(image.imagePath),
                          fit: BoxFit.contain,
                        ),
                      ),
                    const SizedBox(height: 12),
                    Text(
                      (image.pitch != null && image.roll != null)
                          ? 'Orientation · pitch ${image.pitch}° · roll ${image.roll}°'
                              '${image.estimatedRegion != null ? ' · region ${image.estimatedRegion}' : ''}'
                          : 'Orientation · unavailable',
                      style: BinaType.bodySm.copyWith(color: BinaColors.ink3),
                    ),
                    const SizedBox(height: 16),
                    Text('Detections: ${detections.length}', style: BinaType.titleMd),
                    const SizedBox(height: 8),
                    ...detections.map((d) => Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Text(
                        '• ${d['className']} (${((d['confidence'] as num) * 100).toStringAsFixed(1)}%)',
                        style: BinaType.bodyMd,
                      ),
                    )),
                    if (interpretation != null) ...[
                      const SizedBox(height: 16),
                      Text('AI Analysis', style: BinaType.titleMd),
                      const SizedBox(height: 8),
                      Text(interpretation, style: BinaType.bodyMd),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Map<String, dynamic> _aggregateFindings() {
    final allDetections = <Map<String, dynamic>>[];
    for (final image in _sessionImages) {
      final detections = jsonDecode(image.rawResponse.isNotEmpty ? image.rawResponse : '[]') as List<dynamic>;
      for (final d in detections) {
        allDetections.add(d as Map<String, dynamic>);
      }
    }

    final issues = allDetections.where((d) => !(d['className'] as String).startsWith('tooth_')).toList();
    final teeth = allDetections.where((d) => (d['className'] as String).startsWith('tooth_')).toList();

    return {
      'total_images': _sessionImages.length,
      'total_detections': allDetections.length,
      'issues_count': issues.length,
      'teeth_count': teeth.length,
      'issues': issues,
      'teeth': teeth,
    };
  }

  Future<void> _finishSession() async {
    if (_sessionImages.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context).getText('phts023')),
          backgroundColor: BinaColors.warning,
        ),
      );
      return;
    }

    final uncovered = MouthRegionEstimator.uncoveredRegions(
      _sessionImages
          .map((i) => i.estimatedRegion)
          .whereType<String>(),
    );
    if (uncovered.isNotEmpty) {
      final proceed = await ConfirmDialog.show(
        context: context,
        title: 'Some regions weren\'t scanned',
        message:
            'You haven\'t captured: ${uncovered.map((o) => o.name).join(', ')}.\n\nEnd the session anyway, or keep scanning?',
        confirmText: 'End session',
        cancelText: 'Continue scanning',
      );
      if (!proceed) return;
    }

    final now = DateTime.now();
    final recordId = const Uuid().v4();
    final findings = _aggregateFindings();

    try {
      if (AppState().UserSession.isLocalSession) {
        await SQLiteManager.instance.updateScanSessionEnd(
          id: _currentSessionId,
          sessionEnd: now.millisecondsSinceEpoch ~/ 1000,
          status: 'completed',
          totalImagesCaptured: _sessionImages.length,
        );

        await SQLiteManager.instance.createDentalRecord(
          id: recordId,
          familyMemberId: widget.memberId,
          scanSessionId: _currentSessionId,
          recordDate: now.millisecondsSinceEpoch ~/ 1000,
          findingsSnapshot: jsonEncode(findings),
          overallStatus: (findings['issues_count'] as int) > 0 ? 'attention_needed' : 'healthy',
        );

        await SQLiteManager.instance.updateLastChecked(
          id: widget.memberId,
          lastChecked: now.millisecondsSinceEpoch ~/ 1000,
        );
      } else {
        await ScanSessionsTable().update(
          data: {
            'session_end': supaSerialize<DateTime>(now),
            'status': 'completed',
            'total_images_captured': _sessionImages.length,
          },
          matchingRows: (rows) => rows.eq('id', _currentSessionId!),
        );

        await DentalRecordsTable().insert({
          'id': recordId,
          'family_member_id': widget.memberId,
          'scan_session_id': _currentSessionId,
          'record_date': supaSerialize<DateTime>(now),
          'findings_snapshot': jsonEncode(findings),
          'overall_status': (findings['issues_count'] as int) > 0 ? 'attention_needed' : 'healthy',
        });

        await FamilyMembersTable().update(
          data: {'last_checked': supaSerialize<DateTime>(now)},
          matchingRows: (rows) => rows
              .eqOrNull('account_id', AppState().UserSession.userID)
              .eqOrNull('id', widget.memberId),
        );
      }

      final familyIndex = AppState().UserSession.family.indexWhere((m) => m.id == widget.memberId);
      if (familyIndex != -1) {
        AppState().UserSession.family[familyIndex].lastChecked = now;
      }

      if (mounted) {
        context.pushReplacementNamed(
          SessionSummaryWidget.routeName,
          extra: <String, dynamic>{
            'sessionId': _currentSessionId,
            'imageCount': _sessionImages.length,
            'memberName': widget.memberName,
            'overallStatus': (findings['issues_count'] as int) > 0 ? 'attention_needed' : 'healthy',
            // 'gemmaAnalysis': '',
          },
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${AppLocalizations.of(context).getText('phts026')} $e'),
          backgroundColor: BinaColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    context.watch<AppState>();
    final isDesktop = responsiveVisibility(context: context, phone: false, tablet: false);

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
                    child: _isInPreviewMode
                        ? _buildCameraPreview()
                        : _buildSessionContent(isDesktop),
                  ),
                  // Floating nav for mobile (only when not in preview mode)
                  if (!isDesktop && !_isInPreviewMode)
                    Positioned.fill(
                      child: BinaFloatingNav(
                        currentTab: BinaNavTab.scan,
                        onTabChanged: (tab) {
                          switch (tab) {
                            case BinaNavTab.none:
                              break;
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

  Widget _buildCameraPreview() {
    debugPrint('>>> _buildCameraPreview rendering');
    final cameraConnection = AppState().cameraConnection;
    final streamUrl = 'http://${cameraConnection.cameraHost}:${cameraConnection.cameraPort}/stream.mjpg';
    debugPrint('>>> Stream URL: $streamUrl');

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
                      'Camera Preview',
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
                          'Connected · ${cameraConnection.cameraHost}',
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
                  '${_sessionImages.length} photos',
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
                    // Real-time detection overlay
                    _buildDetectionOverlay(),
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
                'Position the teeth clearly in frame and tap to capture',
                style: BinaType.bodySm.copyWith(color: BinaColors.ink3),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSessionContent(bool isDesktop) {
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
                onPressed: () => context.safePop(),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppLocalizations.of(context).getText('phts001'),
                      style: BinaType.titleLg,
                    ),
                    if (widget.memberName != null)
                      Text(
                        '${AppLocalizations.of(context).getText('phts014')} ${widget.memberName}',
                        style: BinaType.bodySm.copyWith(color: BinaColors.ink2),
                      ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: BinaColors.primary100,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${_sessionImages.length} ${AppLocalizations.of(context).getText('phts015')}',
                  style: BinaType.labelSm.copyWith(
                    color: BinaColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
        // Image Grid Area
        Expanded(
          child: _sessionImages.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: BinaColors.surfaceSunken,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Icon(
                          Icons.photo_library_outlined,
                          color: BinaColors.ink3,
                          size: 40,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        AppLocalizations.of(context).getText('phts016'),
                        style: BinaType.titleMd.copyWith(color: BinaColors.ink2),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        AppLocalizations.of(context).getText('phts017'),
                        style: BinaType.bodySm.copyWith(color: BinaColors.ink3),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: _sessionImages.map((image) {
                      return GestureDetector(
                        onTap: () => _showImageDetailSheet(image),
                        child: Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            color: BinaColors.surface,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: BinaColors.line, width: 2),
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              kIsWeb
                                  ? Image.network(image.diagnosedImagePath, fit: BoxFit.cover)
                                  : Image.file(File(image.diagnosedImagePath), fit: BoxFit.cover),
                              Positioned(
                                bottom: 4,
                                right: 4,
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: BinaColors.ink.withValues(alpha: 0.6),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: const Icon(Icons.zoom_in, color: Colors.white, size: 14),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
        ),
        // Processing indicator
        if (_isProcessing)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 12),
            color: BinaColors.primary100,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: BinaColors.primary,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  AppLocalizations.of(context).getText('phts018'),
                  style: BinaType.bodyMd.copyWith(color: BinaColors.primary),
                ),
              ],
            ),
          ),
        // Capture buttons
        Container(
          padding: EdgeInsets.fromLTRB(16, 16, 16, isDesktop ? 16 : 100),
          decoration: BoxDecoration(
            color: BinaColors.surface,
            border: Border(top: BorderSide(color: BinaColors.line)),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: BinaButton(
                      label: AppLocalizations.of(context).getText('phts013'),
                      icon: Icons.camera_alt_rounded,
                      variant: BinaButtonVariant.primary,
                      enabled: !_isProcessing && _isInitialized,
                      onPressed: _captureFromCamera,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: BinaButton(
                      label: AppLocalizations.of(context).getText('phts012'),
                      icon: Icons.photo_library_rounded,
                      variant: BinaButtonVariant.secondary,
                      enabled: !_isProcessing && _isInitialized,
                      onPressed: _selectFromGallery,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: BinaButton(
                  label: AppLocalizations.of(context).getText('phts019'),
                  icon: Icons.check_circle_rounded,
                  variant: BinaButtonVariant.ghost,
                  enabled: !_isProcessing && _isInitialized,
                  onPressed: _finishSession,
                ),
              ),
            ],
          ),
        ),
      ],
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
