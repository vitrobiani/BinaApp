import '/backend/sqlite/sqlite_manager.dart';
import '/backend/supabase/supabase.dart';
import '/app_core/app_theme.dart';
import '/app_core/app_util.dart';
import '/app_core/app_widgets.dart';
import '/pages/nav_pages/web_nav/web_nav_widget.dart';
import '/services/gemma_service.dart';
import '/services/llm_prompts.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'session_summary_model.dart';
export 'session_summary_model.dart';

class SessionSummaryWidget extends StatefulWidget {
  const SessionSummaryWidget({
    super.key,
    this.sessionId,
    this.imageCount,
    this.memberName,
    this.overallStatus,
  });

  final String? sessionId;
  final int? imageCount;
  final String? memberName;
  final String? overallStatus;

  static String routeName = 'SessionSummary';
  static String routePath = 'sessionSummary';

  @override
  State<SessionSummaryWidget> createState() => _SessionSummaryWidgetState();
}

class _SessionSummaryWidgetState extends State<SessionSummaryWidget> {
  late SessionSummaryModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  String? _llmSummary;
  bool _isGeneratingSummary = false;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => SessionSummaryModel());

    SchedulerBinding.instance.addPostFrameCallback((_) async {
      await _generateLlmSummary();
    });
  }

  Future<void> _generateLlmSummary() async {
    if (!GemmaService.instance.isModelLoaded) return;
    if (widget.sessionId == null) return;

    setState(() {
      _isGeneratingSummary = true;
    });

    try {
      // Load session findings from DB.
      String findingsJson = '{}';

      if (AppState().UserSession.isLocalSession) {
        final images = await SQLiteManager.instance.getScanImagesBySessionId(
          sessionId: widget.sessionId!,
        );
        final allDetections = <Map<String, dynamic>>[];
        for (final image in images) {
          if (image.rawResponse != null && image.rawResponse!.isNotEmpty) {
            try {
              final detections =
                  jsonDecode(image.rawResponse!) as List<dynamic>;
              for (final d in detections) {
                allDetections.add(d as Map<String, dynamic>);
              }
            } catch (_) {}
          }
        }
        findingsJson = jsonEncode(allDetections);
      } else {
        final images = await ScanImagesTable().queryRows(
          queryFn: (q) =>
              q.eq('scan_session_id', widget.sessionId!).order('captured_at'),
        );
        final allDetections = <Map<String, dynamic>>[];
        for (final image in images) {
          if (image.rawResponse != null && image.rawResponse!.isNotEmpty) {
            try {
              final detections =
                  jsonDecode(image.rawResponse!) as List<dynamic>;
              for (final d in detections) {
                allDetections.add(d as Map<String, dynamic>);
              }
            } catch (_) {}
          }
        }
        findingsJson = jsonEncode(allDetections);
      }

      final prompt = LlmPrompts.buildSessionSummaryPrompt(
        findingsJson: findingsJson,
        imageCount: widget.imageCount ?? 0,
        memberName: widget.memberName ?? 'Patient',
        overallStatus: widget.overallStatus ?? 'unknown',
      );

      final response = await GemmaService.instance.generateResponse(prompt);

      if (mounted && response.isNotEmpty) {
        setState(() {
          _llmSummary = response;
          _isGeneratingSummary = false;
        });
      } else if (mounted) {
        setState(() {
          _isGeneratingSummary = false;
        });
      }
    } catch (e) {
      debugPrint('LLM summary error: $e');
      if (mounted) {
        setState(() {
          _isGeneratingSummary = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  Color _getStatusColor(BuildContext context) {
    switch (widget.overallStatus) {
      case 'healthy':
        return AppTheme.of(context).success;
      case 'attention_needed':
        return AppTheme.of(context).warning;
      case 'urgent':
        return AppTheme.of(context).error;
      default:
        return AppTheme.of(context).secondaryText;
    }
  }

  String _getStatusText() {
    switch (widget.overallStatus) {
      case 'healthy':
        return 'Healthy';
      case 'attention_needed':
        return 'Attention Needed';
      case 'urgent':
        return 'Urgent';
      default:
        return 'Unknown';
    }
  }

  IconData _getStatusIcon() {
    switch (widget.overallStatus) {
      case 'healthy':
        return Icons.check_circle;
      case 'attention_needed':
        return Icons.warning;
      case 'urgent':
        return Icons.error;
      default:
        return Icons.help_outline;
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
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'Session Complete',
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
                                ],
                              ),
                            ),
                          ),
                          // Content
                          Expanded(
                            child: Center(
                              child: SingleChildScrollView(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    // Success Icon
                                    Container(
                                      width: 120.0,
                                      height: 120.0,
                                      decoration: BoxDecoration(
                                        color: _getStatusColor(context)
                                            .withOpacity(0.1),
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(
                                        _getStatusIcon(),
                                        color: _getStatusColor(context),
                                        size: 64.0,
                                      ),
                                    ),
                                    SizedBox(height: 24.0),
                                    // Member name
                                    if (widget.memberName != null)
                                      Text(
                                        widget.memberName!,
                                        style: AppTheme.of(context)
                                            .headlineSmall
                                            .override(
                                              font: GoogleFonts.readexPro(
                                                fontWeight:
                                                    AppTheme.of(context)
                                                        .headlineSmall
                                                        .fontWeight,
                                                fontStyle:
                                                    AppTheme.of(context)
                                                        .headlineSmall
                                                        .fontStyle,
                                              ),
                                              letterSpacing: 0.0,
                                            ),
                                      ),
                                    SizedBox(height: 8.0),
                                    // Image count
                                    Text(
                                      '${widget.imageCount ?? 0} images captured',
                                      style: AppTheme.of(context)
                                          .bodyLarge
                                          .override(
                                            font: GoogleFonts.inter(
                                              fontWeight:
                                                  AppTheme.of(context)
                                                      .bodyLarge
                                                      .fontWeight,
                                              fontStyle:
                                                  AppTheme.of(context)
                                                      .bodyLarge
                                                      .fontStyle,
                                            ),
                                            color: AppTheme.of(context)
                                                .secondaryText,
                                            letterSpacing: 0.0,
                                          ),
                                    ),
                                    SizedBox(height: 24.0),
                                    // Status badge
                                    Container(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 20.0, vertical: 10.0),
                                      decoration: BoxDecoration(
                                        color: _getStatusColor(context),
                                        borderRadius:
                                            BorderRadius.circular(24.0),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            _getStatusIcon(),
                                            color: Colors.white,
                                            size: 20.0,
                                          ),
                                          SizedBox(width: 8.0),
                                          Text(
                                            _getStatusText(),
                                            style: AppTheme.of(context)
                                                .titleSmall
                                                .override(
                                                  font: GoogleFonts.inter(
                                                    fontWeight: FontWeight.w600,
                                                    fontStyle:
                                                        AppTheme.of(
                                                                context)
                                                            .titleSmall
                                                            .fontStyle,
                                                  ),
                                                  color: Colors.white,
                                                  letterSpacing: 0.0,
                                                ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    // AI Summary section.
                                    if (_isGeneratingSummary ||
                                        (_llmSummary != null &&
                                            _llmSummary!.isNotEmpty)) ...[
                                      SizedBox(height: 24.0),
                                      Container(
                                        width: double.infinity,
                                        constraints:
                                            BoxConstraints(maxWidth: 500.0),
                                        padding: EdgeInsets.all(16.0),
                                        decoration: BoxDecoration(
                                          color: AppTheme.of(context)
                                              .secondaryBackground,
                                          borderRadius:
                                              BorderRadius.circular(12.0),
                                          boxShadow: [
                                            BoxShadow(
                                              blurRadius: 3.0,
                                              color: Color(0x20000000),
                                              offset: Offset(0.0, 1.0),
                                            ),
                                          ],
                                        ),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                Icon(
                                                  Icons.smart_toy,
                                                  color:
                                                      AppTheme.of(
                                                              context)
                                                          .primary,
                                                  size: 20.0,
                                                ),
                                                SizedBox(width: 8.0),
                                                Text(
                                                  'AI Summary',
                                                  style: AppTheme
                                                          .of(context)
                                                      .titleSmall
                                                      .override(
                                                        font: GoogleFonts
                                                            .inter(
                                                          fontWeight:
                                                              FontWeight
                                                                  .w600,
                                                          fontStyle: AppTheme.of(
                                                                  context)
                                                              .titleSmall
                                                              .fontStyle,
                                                        ),
                                                        letterSpacing:
                                                            0.0,
                                                      ),
                                                ),
                                              ],
                                            ),
                                            SizedBox(height: 8.0),
                                            if (_isGeneratingSummary)
                                              Row(
                                                children: [
                                                  SizedBox(
                                                    width: 16.0,
                                                    height: 16.0,
                                                    child:
                                                        CircularProgressIndicator(
                                                      strokeWidth: 2.0,
                                                      color:
                                                          AppTheme
                                                                  .of(
                                                                      context)
                                                              .primary,
                                                    ),
                                                  ),
                                                  SizedBox(width: 8.0),
                                                  Text(
                                                    'Generating summary...',
                                                    style: AppTheme
                                                            .of(context)
                                                        .bodySmall
                                                        .override(
                                                          font: GoogleFonts
                                                              .inter(
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
                                                          color: AppTheme
                                                                  .of(
                                                                      context)
                                                              .secondaryText,
                                                          letterSpacing:
                                                              0.0,
                                                        ),
                                                  ),
                                                ],
                                              )
                                            else
                                              Text(
                                                _llmSummary!,
                                                style: AppTheme
                                                        .of(context)
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
                                          ],
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ),
                          ),
                          // Bottom buttons
                          Container(
                            width: double.infinity,
                            constraints: BoxConstraints(
                              maxWidth: 570.0,
                            ),
                            padding: EdgeInsets.all(16.0),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                AppButtonWidget(
                                  onPressed: () async {
                                    context.goNamed('Main_DIagnostics');
                                  },
                                  text: 'View Diagnostics History',
                                  icon: Icon(
                                    Icons.history,
                                    size: 20.0,
                                  ),
                                  options: AppButtonOptions(
                                    width: double.infinity,
                                    height: 52.0,
                                    padding: EdgeInsetsDirectional.fromSTEB(
                                        24.0, 0.0, 24.0, 0.0),
                                    iconPadding:
                                        EdgeInsetsDirectional.fromSTEB(
                                            0.0, 0.0, 8.0, 0.0),
                                    color:
                                        AppTheme.of(context).primary,
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
                                SizedBox(height: 12.0),
                                AppButtonWidget(
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
