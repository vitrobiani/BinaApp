import 'dart:io';

import '/backend/supabase/supabase.dart';
import '/backend/sqlite/sqlite_manager.dart';
import '/app_core/app_animations.dart';
import '/app_core/app_icon_button.dart';
import '/app_core/app_theme.dart';
import '/app_core/app_util.dart';
import '/app_core/app_widgets.dart';
import '/custom_code/actions/index.dart' as actions;
import '/pages/nav_pages/web_nav/web_nav_widget.dart';
import '/index.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
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

class _CameraWidgetState extends State<CameraWidget>
    with TickerProviderStateMixin {
  late CameraModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  final animationsMap = <String, AnimationInfo>{};

  String? _selectedImagePath;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => CameraModel());

    animationsMap.addAll({
      'containerOnPageLoadAnimation': AnimationInfo(
        trigger: AnimationTrigger.onPageLoad,
        effectsBuilder: () => [
          FadeEffect(
            curve: Curves.easeInOut,
            delay: 0.0.ms,
            duration: 600.0.ms,
            begin: 0.0,
            end: 1.0,
          ),
          MoveEffect(
            curve: Curves.easeInOut,
            delay: 0.0.ms,
            duration: 600.0.ms,
            begin: Offset(0.0, 50.0),
            end: Offset(0.0, 0.0),
          ),
        ],
      ),
      'buttonOnPageLoadAnimation': AnimationInfo(
        trigger: AnimationTrigger.onPageLoad,
        effectsBuilder: () => [
          FadeEffect(
            curve: Curves.easeInOut,
            delay: 300.0.ms,
            duration: 600.0.ms,
            begin: 0.0,
            end: 1.0,
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
          content: Text('Diagnosis is not available on web. Please use the mobile app.'),
          backgroundColor: AppTheme.of(context).warning,
          duration: Duration(seconds: 4),
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
            content: Text('Diagnosis is not available on web. Please use the mobile app.'),
            backgroundColor: AppTheme.of(context).warning,
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
                                  Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Diagnosis',
                                        style: AppTheme.of(context)
                                            .headlineMedium
                                            .override(
                                              font: GoogleFonts.readexPro(
                                                fontWeight:
                                                    AppTheme.of(context)
                                                        .headlineMedium
                                                        .fontWeight,
                                                fontStyle:
                                                    AppTheme.of(context)
                                                        .headlineMedium
                                                        .fontStyle,
                                              ),
                                              letterSpacing: 0.0,
                                            ),
                                      ),
                                      if (widget.memberName != null)
                                        Text(
                                          'Patient: ${widget.memberName}',
                                          style: AppTheme.of(context)
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
                                  AppIconButton(
                                    borderColor:
                                        AppTheme.of(context).alternate,
                                    borderRadius: 12.0,
                                    borderWidth: 1.0,
                                    buttonSize: 40.0,
                                    fillColor: AppTheme.of(context)
                                        .secondaryBackground,
                                    icon: Icon(
                                      Icons.close_rounded,
                                      color: AppTheme.of(context)
                                          .primaryText,
                                      size: 24.0,
                                    ),
                                    onPressed: () async {
                                      context.safePop();
                                    },
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
                                  Padding(
                                    padding: EdgeInsetsDirectional.fromSTEB(
                                        16.0, 16.0, 16.0, 0.0),
                                    child: Container(
                                      width: double.infinity,
                                      constraints: BoxConstraints(
                                        maxWidth: 570.0,
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
                                          children: [
                                            // Image preview area
                                            InkWell(
                                              onTap: _isProcessing
                                                  ? null
                                                  : _pickImage,
                                              child: Container(
                                                width: double.infinity,
                                                height: 300.0,
                                                decoration: BoxDecoration(
                                                  color: AppTheme.of(
                                                          context)
                                                      .primaryBackground,
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          8.0),
                                                  border: Border.all(
                                                    color: AppTheme.of(
                                                            context)
                                                        .alternate,
                                                    width: 2.0,
                                                  ),
                                                ),
                                                child: _selectedImagePath !=
                                                        null
                                                    ? ClipRRect(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(6.0),
                                                        child: kIsWeb
                                                            ? Image.network(
                                                                _selectedImagePath!,
                                                                width:
                                                                    double.infinity,
                                                                height:
                                                                    double.infinity,
                                                                fit: BoxFit.contain,
                                                              )
                                                            : Image.file(
                                                                File(
                                                                    _selectedImagePath!),
                                                                width:
                                                                    double.infinity,
                                                                height:
                                                                    double.infinity,
                                                                fit: BoxFit.contain,
                                                              ),
                                                      )
                                                    : Column(
                                                        mainAxisSize:
                                                            MainAxisSize.max,
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                        children: [
                                                          Icon(
                                                            Icons
                                                                .add_photo_alternate_outlined,
                                                            color: AppTheme
                                                                    .of(context)
                                                                .secondaryText,
                                                            size: 72.0,
                                                          ),
                                                          SizedBox(height: 12.0),
                                                          Text(
                                                            'Tap to upload photo',
                                                            style: AppTheme
                                                                    .of(context)
                                                                .bodyLarge
                                                                .override(
                                                                  font:
                                                                      GoogleFonts
                                                                          .inter(
                                                                    fontWeight:
                                                                        AppTheme.of(context)
                                                                            .bodyLarge
                                                                            .fontWeight,
                                                                    fontStyle:
                                                                        AppTheme.of(context)
                                                                            .bodyLarge
                                                                            .fontStyle,
                                                                  ),
                                                                  color: AppTheme.of(
                                                                          context)
                                                                      .secondaryText,
                                                                  letterSpacing:
                                                                      0.0,
                                                                ),
                                                          ),
                                                          SizedBox(height: 4.0),
                                                          Text(
                                                            'Select a dental image for diagnosis',
                                                            style: AppTheme
                                                                    .of(context)
                                                                .labelSmall
                                                                .override(
                                                                  font:
                                                                      GoogleFonts
                                                                          .inter(
                                                                    fontWeight:
                                                                        AppTheme.of(context)
                                                                            .labelSmall
                                                                            .fontWeight,
                                                                    fontStyle:
                                                                        AppTheme.of(context)
                                                                            .labelSmall
                                                                            .fontStyle,
                                                                  ),
                                                                  letterSpacing:
                                                                      0.0,
                                                                ),
                                                          ),
                                                        ],
                                                      ),
                                              ),
                                            ).animateOnPageLoad(animationsMap[
                                                'containerOnPageLoadAnimation']!),
                                            SizedBox(height: 16.0),
                                            // Upload button
                                            AppButtonWidget(
                                              onPressed: _isProcessing
                                                  ? null
                                                  : _pickImage,
                                              text: _selectedImagePath == null
                                                  ? 'Upload Photo'
                                                  : 'Change Photo',
                                              icon: Icon(
                                                Icons.upload_file,
                                                size: 20.0,
                                              ),
                                              options: AppButtonOptions(
                                                width: double.infinity,
                                                height: 48.0,
                                                padding: EdgeInsetsDirectional
                                                    .fromSTEB(
                                                        24.0, 0.0, 24.0, 0.0),
                                                iconPadding:
                                                    EdgeInsetsDirectional
                                                        .fromSTEB(
                                                            0.0, 0.0, 8.0, 0.0),
                                                color:
                                                    AppTheme.of(context)
                                                        .secondaryBackground,
                                                textStyle:
                                                    AppTheme.of(context)
                                                        .titleSmall
                                                        .override(
                                                          font:
                                                              GoogleFonts.inter(
                                                            fontWeight:
                                                                AppTheme.of(
                                                                        context)
                                                                    .titleSmall
                                                                    .fontWeight,
                                                            fontStyle:
                                                                AppTheme.of(
                                                                        context)
                                                                    .titleSmall
                                                                    .fontStyle,
                                                          ),
                                                          color: AppTheme
                                                                  .of(context)
                                                              .primaryText,
                                                          letterSpacing: 0.0,
                                                        ),
                                                elevation: 0.0,
                                                borderSide: BorderSide(
                                                  color: AppTheme.of(
                                                          context)
                                                      .alternate,
                                                  width: 2.0,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(8.0),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
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
                                onPressed: (_selectedImagePath == null ||
                                        _isProcessing)
                                    ? null
                                    : _runDiagnosis,
                                text: _isProcessing
                                    ? 'Processing...'
                                    : 'Run Diagnosis',
                                icon: _isProcessing
                                    ? null
                                    : Icon(
                                        Icons.medical_services,
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
                                  disabledColor:
                                      AppTheme.of(context).alternate,
                                  disabledTextColor:
                                      AppTheme.of(context)
                                          .secondaryText,
                                ),
                                showLoadingIndicator: _isProcessing,
                              ).animateOnPageLoad(
                                  animationsMap['buttonOnPageLoadAnimation']!),
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
