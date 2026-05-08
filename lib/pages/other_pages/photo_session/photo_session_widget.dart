import 'dart:io';

import '/backend/supabase/supabase.dart';
import '/backend/sqlite/sqlite_manager.dart';
import '/backend/schema/structs/index.dart';
import '/components/photo_session/image_detail_sheet/image_detail_sheet_widget.dart';
import '/app_core/app_icon_button.dart';
import '/app_core/app_theme.dart';
import '/app_core/app_util.dart';
import '/app_core/app_widgets.dart';
import '/custom_code/actions/index.dart' as actions;
import '/pages/nav_pages/web_nav/web_nav_widget.dart';
import '/index.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '/services/gemma_service.dart';
import '/services/llm_prompts.dart';
import '/services/mjpeg_capture_service.dart';
import '/components/camera_selection_dialog/camera_selection_dialog_widget.dart';
import '/components/bina_camera_preview/bina_camera_preview_widget.dart';
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

  /// Per-image LLM interpretations keyed by image ID.
  final Map<String, String> _imageInterpretations = {};
  final Set<String> _interpretingImages = {};

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => PhotoSessionModel());

    SchedulerBinding.instance.addPostFrameCallback((_) async {
      await _initSession();
    });
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  Future<void> _initSession() async {
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

      safeSetState(() {
        _currentSessionId = sessionId;
        _isInitialized = true;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error initializing session: $e'),
          backgroundColor: AppTheme.of(context).error,
        ),
      );
    }
  }

  Future<void> _captureFromCamera() async {
    if (kIsWeb) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Camera is not available on web.'),
          backgroundColor: AppTheme.of(context).warning,
        ),
      );
      return;
    }

    final cameraConnection = AppState().cameraConnection;

    // If Bina Camera is connected, show selection dialog
    if (cameraConnection.isCameraConnected()) {
      final selectedSource = await showCameraSelectionDialog(context);

      if (selectedSource == null) {
        return; // User cancelled
      }

      if (selectedSource == CameraSource.binaCamera) {
        await _captureFromBinaCamera();
        return;
      }
      // Otherwise, continue with phone camera below
    }

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

  Future<void> _captureFromBinaCamera() async {
    final cameraConnection = AppState().cameraConnection;

    if (!cameraConnection.isCameraConnected()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Bina Camera is not connected.'),
          backgroundColor: AppTheme.of(context).warning,
        ),
      );
      return;
    }

    // Show the camera preview and wait for capture
    final imagePath = await showBinaCameraPreview(
      context,
      cameraIP: cameraConnection.cameraHost,
      cameraPort: cameraConnection.cameraPort,
    );

    // If user cancelled or capture failed, imagePath will be null
    if (imagePath == null) {
      return;
    }

    // Process the captured image
    await _processImage(imagePath);
  }

  Future<void> _selectFromGallery() async {
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
  }

  Future<void> _processImage(String originalPath) async {
    if (kIsWeb) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Diagnosis is not available on web.'),
          backgroundColor: AppTheme.of(context).warning,
        ),
      );
      return;
    }

    safeSetState(() {
      _isProcessing = true;
    });

    try {
      // Run YOLO inference
      final result = await actions.runYoloInference(originalPath);

      if (result.isWebPlatform) {
        safeSetState(() {
          _isProcessing = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Diagnosis is not available on web.'),
            backgroundColor: AppTheme.of(context).warning,
          ),
        );
        return;
      }

      // Generate image ID
      final imageId = const Uuid().v4();

      // Read image bytes
      final originalBytes = await File(originalPath).readAsBytes();
      final diagnosedBytes = await File(result.imagePath).readAsBytes();

      // Save to database
      if (AppState().UserSession.isLocalSession) {
        await SQLiteManager.instance.createScanImage(
          id: imageId,
          scanSessionId: _currentSessionId,
          image: originalBytes,
          diagnosedImage: diagnosedBytes,
          capturedAt: DateTime.now().millisecondsSinceEpoch ~/ 1000,
          rawResponse: jsonEncode(result.detections),
        );
      } else {
        await ScanImagesTable().insert({
          'id': imageId,
          'scan_session_id': _currentSessionId,
          'image': originalBytes,
          'diagnosed_image': diagnosedBytes,
          'captured_at': supaSerialize<DateTime>(DateTime.now()),
          'raw_response': jsonEncode(result.detections),
        });
      }

      final detectionsJson = jsonEncode(result.detections);

      // Update local state (keep paths for display)
      safeSetState(() {
        _sessionImages.add(ScanImageStruct(
          id: imageId,
          scanSessionId: _currentSessionId,
          imagePath: originalPath,
          diagnosedImagePath: result.imagePath,
          capturedAt: DateTime.now(),
          rawResponse: detectionsJson,
        ));
        _isProcessing = false;
      });

      // Fire async LLM interpretation (non-blocking).
      _generateImageInterpretation(imageId, detectionsJson);
    } catch (e) {
      safeSetState(() {
        _isProcessing = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error processing image: $e'),
          backgroundColor: AppTheme.of(context).error,
        ),
      );
    }
  }

  Future<void> _generateImageInterpretation(
      String imageId, String detectionsJson) async {
    if (!GemmaService.instance.isModelLoaded) return;
    if (_interpretingImages.contains(imageId)) return;

    _interpretingImages.add(imageId);

    try {
      final prompt =
          LlmPrompts.buildImageInterpretationPrompt(detectionsJson);
      final response = await GemmaService.instance.generateResponse(prompt);
      if (response.isNotEmpty && mounted) {
        safeSetState(() {
          _imageInterpretations[imageId] = response;
        });
      }
    } catch (e) {
      debugPrint('LLM interpretation error for $imageId: $e');
    } finally {
      _interpretingImages.remove(imageId);
    }
  }

  void _showImageDetailSheet(ScanImageStruct image) {
    final rawJson = image.rawResponse.isNotEmpty ? image.rawResponse : '[]';
    showModalBottomSheet(
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      enableDrag: true,
      context: context,
      builder: (context) => ImageDetailSheetWidget(
        originalImagePath: image.imagePath,
        diagnosedImagePath: image.diagnosedImagePath,
        detections: jsonDecode(rawJson),
        detectionsJson: rawJson,
        llmInterpretation: _imageInterpretations[image.id],
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
          content: Text('Please capture at least one image before finishing.'),
          backgroundColor: AppTheme.of(context).warning,
        ),
      );
      return;
    }

    final now = DateTime.now();
    final recordId = const Uuid().v4();
    final findings = _aggregateFindings();

    try {
      if (AppState().UserSession.isLocalSession) {
        // Update session status
        await SQLiteManager.instance.updateScanSessionEnd(
          id: _currentSessionId,
          sessionEnd: now.millisecondsSinceEpoch ~/ 1000,
          status: 'completed',
          totalImagesCaptured: _sessionImages.length,
        );

        // Create dental record
        await SQLiteManager.instance.createDentalRecord(
          id: recordId,
          familyMemberId: widget.memberId,
          scanSessionId: _currentSessionId,
          recordDate: now.millisecondsSinceEpoch ~/ 1000,
          findingsSnapshot: jsonEncode(findings),
          overallStatus: (findings['issues_count'] as int) > 0 ? 'attention_needed' : 'healthy',
        );

        // Update last_checked
        await SQLiteManager.instance.updateLastChecked(
          id: widget.memberId,
          lastChecked: now.millisecondsSinceEpoch ~/ 1000,
        );
      } else {
        // Update session status in Supabase
        await ScanSessionsTable().update(
          data: {
            'session_end': supaSerialize<DateTime>(now),
            'status': 'completed',
            'total_images_captured': _sessionImages.length,
          },
          matchingRows: (rows) => rows.eq('id', _currentSessionId!),
        );

        // Create dental record in Supabase
        await DentalRecordsTable().insert({
          'id': recordId,
          'family_member_id': widget.memberId,
          'scan_session_id': _currentSessionId,
          'record_date': supaSerialize<DateTime>(now),
          'findings_snapshot': jsonEncode(findings),
          'overall_status': (findings['issues_count'] as int) > 0 ? 'attention_needed' : 'healthy',
        });

        // Update last_checked in Supabase
        await FamilyMembersTable().update(
          data: {
            'last_checked': supaSerialize<DateTime>(now),
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
        AppState().UserSession.family[familyIndex].lastChecked = now;
      }

      // Navigate to summary
      if (mounted) {
        context.pushReplacementNamed(
          SessionSummaryWidget.routeName,
          extra: <String, dynamic>{
            'sessionId': _currentSessionId,
            'imageCount': _sessionImages.length,
            'memberName': widget.memberName,
            'overallStatus': (findings['issues_count'] as int) > 0 ? 'attention_needed' : 'healthy',
          },
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error finishing session: $e'),
          backgroundColor: AppTheme.of(context).error,
        ),
      );
    }
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
                                          context.safePop();
                                        },
                                      ),
                                      SizedBox(width: 12.0),
                                      Column(
                                        mainAxisSize: MainAxisSize.min,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Photo Session',
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
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 12.0, vertical: 6.0),
                                    decoration: BoxDecoration(
                                      color: AppTheme.of(context).primary
                                          .withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(20.0),
                                    ),
                                    child: Text(
                                      '${_sessionImages.length} images',
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
                                            color:
                                                AppTheme.of(context).primary,
                                            letterSpacing: 0.0,
                                          ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          // Image Grid Area
                          Expanded(
                            child: Container(
                              width: double.infinity,
                              padding: EdgeInsets.all(16.0),
                              child: _sessionImages.isEmpty
                                  ? Center(
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.photo_library_outlined,
                                            color: AppTheme.of(context)
                                                .secondaryText,
                                            size: 72.0,
                                          ),
                                          SizedBox(height: 16.0),
                                          Text(
                                            'No images yet',
                                            style: AppTheme.of(context)
                                                .titleMedium
                                                .override(
                                                  font: GoogleFonts.inter(
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
                                                  color: AppTheme.of(
                                                          context)
                                                      .secondaryText,
                                                  letterSpacing: 0.0,
                                                ),
                                          ),
                                          SizedBox(height: 8.0),
                                          Text(
                                            'Capture dental images using the buttons below',
                                            style: AppTheme.of(context)
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
                                                  letterSpacing: 0.0,
                                                ),
                                            textAlign: TextAlign.center,
                                          ),
                                        ],
                                      ),
                                    )
                                  : SingleChildScrollView(
                                      child: Wrap(
                                        spacing: 12.0,
                                        runSpacing: 12.0,
                                        children: _sessionImages.map((image) {
                                          return InkWell(
                                            onTap: () =>
                                                _showImageDetailSheet(image),
                                            child: Container(
                                              width: 100.0,
                                              height: 100.0,
                                              decoration: BoxDecoration(
                                                color: AppTheme.of(
                                                        context)
                                                    .secondaryBackground,
                                                borderRadius:
                                                    BorderRadius.circular(8.0),
                                                border: Border.all(
                                                  color: AppTheme.of(
                                                          context)
                                                      .alternate,
                                                  width: 2.0,
                                                ),
                                              ),
                                              child: ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(6.0),
                                                child: Stack(
                                                  fit: StackFit.expand,
                                                  children: [
                                                    kIsWeb
                                                        ? Image.network(
                                                            image.diagnosedImagePath,
                                                            fit: BoxFit.cover,
                                                          )
                                                        : Image.file(
                                                            File(image
                                                                .diagnosedImagePath),
                                                            fit: BoxFit.cover,
                                                          ),
                                                    Positioned(
                                                      bottom: 4.0,
                                                      right: 4.0,
                                                      child: Container(
                                                        padding:
                                                            EdgeInsets.symmetric(
                                                                horizontal: 6.0,
                                                                vertical: 2.0),
                                                        decoration:
                                                            BoxDecoration(
                                                          color: Colors.black54,
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      4.0),
                                                        ),
                                                        child: Icon(
                                                          Icons.zoom_in,
                                                          color: Colors.white,
                                                          size: 16.0,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          );
                                        }).toList(),
                                      ),
                                    ),
                            ),
                          ),
                          // Processing indicator
                          if (_isProcessing)
                            Container(
                              width: double.infinity,
                              padding: EdgeInsets.symmetric(vertical: 12.0),
                              color: AppTheme.of(context).primary
                                  .withOpacity(0.1),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SizedBox(
                                    width: 20.0,
                                    height: 20.0,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.0,
                                      color:
                                          AppTheme.of(context).primary,
                                    ),
                                  ),
                                  SizedBox(width: 12.0),
                                  Text(
                                    'Processing image...',
                                    style: AppTheme.of(context)
                                        .bodyMedium
                                        .override(
                                          font: GoogleFonts.inter(
                                            fontWeight:
                                                AppTheme.of(context)
                                                    .bodyMedium
                                                    .fontWeight,
                                            fontStyle:
                                                AppTheme.of(context)
                                                    .bodyMedium
                                                    .fontStyle,
                                          ),
                                          color: AppTheme.of(context)
                                              .primary,
                                          letterSpacing: 0.0,
                                        ),
                                  ),
                                ],
                              ),
                            ),
                          // Capture buttons
                          Container(
                            width: double.infinity,
                            padding: EdgeInsets.all(16.0),
                            decoration: BoxDecoration(
                              color: AppTheme.of(context)
                                  .secondaryBackground,
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Expanded(
                                      child: AppButtonWidget(
                                        onPressed: (_isProcessing || !_isInitialized)
                                            ? null
                                            : _captureFromCamera,
                                        text: 'Camera',
                                        icon: Icon(
                                          Icons.camera_alt,
                                          size: 20.0,
                                        ),
                                        options: AppButtonOptions(
                                          height: 52.0,
                                          padding: EdgeInsetsDirectional.fromSTEB(
                                              16.0, 0.0, 16.0, 0.0),
                                          iconPadding:
                                              EdgeInsetsDirectional.fromSTEB(
                                                  0.0, 0.0, 8.0, 0.0),
                                          color: AppTheme.of(context)
                                              .primary,
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
                                          disabledColor:
                                              AppTheme.of(context)
                                                  .alternate,
                                          disabledTextColor:
                                              AppTheme.of(context)
                                                  .secondaryText,
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: 16.0),
                                    Expanded(
                                      child: AppButtonWidget(
                                        onPressed: (_isProcessing || !_isInitialized)
                                            ? null
                                            : _selectFromGallery,
                                        text: 'Gallery',
                                        icon: Icon(
                                          Icons.photo_library,
                                          size: 20.0,
                                        ),
                                        options: AppButtonOptions(
                                          height: 52.0,
                                          padding: EdgeInsetsDirectional.fromSTEB(
                                              16.0, 0.0, 16.0, 0.0),
                                          iconPadding:
                                              EdgeInsetsDirectional.fromSTEB(
                                                  0.0, 0.0, 8.0, 0.0),
                                          color: AppTheme.of(context)
                                              .secondaryBackground,
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
                                                color: AppTheme.of(context)
                                                    .primaryText,
                                                letterSpacing: 0.0,
                                              ),
                                          elevation: 0.0,
                                          borderSide: BorderSide(
                                            color: AppTheme.of(context)
                                                .alternate,
                                            width: 2.0,
                                          ),
                                          borderRadius: BorderRadius.circular(8.0),
                                          disabledColor:
                                              AppTheme.of(context)
                                                  .alternate,
                                          disabledTextColor:
                                              AppTheme.of(context)
                                                  .secondaryText,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 12.0),
                                AppButtonWidget(
                                  onPressed: (_isProcessing || !_isInitialized)
                                      ? null
                                      : _finishSession,
                                  text: 'Finish Session',
                                  icon: Icon(
                                    Icons.check_circle,
                                    size: 20.0,
                                  ),
                                  options: AppButtonOptions(
                                    width: double.infinity,
                                    height: 52.0,
                                    padding: EdgeInsetsDirectional.fromSTEB(
                                        24.0, 0.0, 24.0, 0.0),
                                    iconPadding: EdgeInsetsDirectional.fromSTEB(
                                        0.0, 0.0, 8.0, 0.0),
                                    color: AppTheme.of(context).success,
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
                                    disabledColor:
                                        AppTheme.of(context).alternate,
                                    disabledTextColor:
                                        AppTheme.of(context)
                                            .secondaryText,
                                  ),
                                ),
                              ],
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
