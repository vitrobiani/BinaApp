import '/backend/schema/structs/index.dart';
import '/backend/sqlite/sqlite_manager.dart';
import '/backend/supabase/supabase.dart';
import '/app_core/app_animations.dart';
import '/app_core/app_icon_button.dart';
import '/app_core/app_theme.dart';
import '/app_core/app_util.dart';
import '/pages/nav_pages/web_nav/web_nav_widget.dart';
import '/index.dart';
import '/components/diagnose_page/multi_select_action_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'main_d_iagnostics_model.dart';
export 'main_d_iagnostics_model.dart';

class MainDIagnosticsWidget extends StatefulWidget {
  const MainDIagnosticsWidget({super.key});

  static String routeName = 'Main_DIagnostics';
  static String routePath = 'mainDIagnostics';

  @override
  State<MainDIagnosticsWidget> createState() => _MainDIagnosticsWidgetState();
}

class _MainDIagnosticsWidgetState extends State<MainDIagnosticsWidget>
    with TickerProviderStateMixin {
  late MainDIagnosticsModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  final animationsMap = <String, AnimationInfo>{};

  List<FamilyMemberStruct> _familyMembers = [];

  // Key to trigger reload of member sessions tab
  final GlobalKey<_MemberSessionsTabState> _currentTabKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => MainDIagnosticsModel());

    // Set up callback for selection state changes
    _model.onSelectionChanged = () => safeSetState(() {});

    animationsMap.addAll({
      'containerOnPageLoadAnimation': AnimationInfo(
        trigger: AnimationTrigger.onPageLoad,
        effectsBuilder: () => [
          VisibilityEffect(duration: 1.ms),
          FadeEffect(
            curve: Curves.easeInOut,
            delay: 0.0.ms,
            duration: 300.0.ms,
            begin: 0.0,
            end: 1.0,
          ),
          MoveEffect(
            curve: Curves.easeInOut,
            delay: 0.0.ms,
            duration: 300.0.ms,
            begin: Offset(0.0, 20.0),
            end: Offset(0.0, 0.0),
          ),
        ],
      ),
    });

    SchedulerBinding.instance.addPostFrameCallback((_) async {
      await _loadFamilyMembers();
    });
  }

  Future<void> _loadFamilyMembers() async {
    final family = AppState().UserSession.family.toList();
    debugPrint('Loading family members: ${family.length} found');
    for (final member in family) {
      debugPrint('  - Member: ${member.name}, ID: ${member.id}, hasId: ${member.hasId()}');
    }
    debugPrint('isLocalSession: ${AppState().UserSession.isLocalSession}');

    if (family.isNotEmpty) {
      safeSetState(() {
        _familyMembers = family;
        _model.tabBarController = TabController(
          vsync: this,
          length: family.length,
          initialIndex: 0,
        )..addListener(() {
            // Clear selection when switching tabs
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
  }

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
        backgroundColor: AppTheme.of(context).primaryBackground,
        body: Row(
          mainAxisSize: MainAxisSize.max,
          children: [
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
                    color: AppTheme.of(context).primary,
                  ),
                  iconThree: Icon(
                    Icons.camera_alt,
                    color: AppTheme.of(context).secondaryText,
                  ),
                  iconFour: Icon(
                    Icons.account_circle,
                    color: AppTheme.of(context).secondaryText,
                  ),
                  colorBgOne: AppTheme.of(context).secondaryBackground,
                  colorBgTwo: AppTheme.of(context).primaryBackground,
                  colorBgThree: AppTheme.of(context).secondaryBackground,
                  colorBgFour: AppTheme.of(context).secondaryBackground,
                  textOne: AppTheme.of(context).primaryText,
                  textTwo: AppTheme.of(context).secondaryText,
                  textThree: AppTheme.of(context).secondaryText,
                  textFour: AppTheme.of(context).secondaryText,
                  iconFive: Icon(
                    Icons.reduce_capacity,
                    color: AppTheme.of(context).secondaryText,
                  ),
                  colorBgFive: AppTheme.of(context).secondaryBackground,
                  textFive: AppTheme.of(context).secondaryText,
                ),
              ),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (responsiveVisibility(
                          context: context,
                          tablet: false,
                          tabletLandscape: false,
                          desktop: false,
                        ))
                          Container(
                            width: double.infinity,
                            height: 34.0,
                            decoration: BoxDecoration(
                              color: AppTheme.of(context).primaryBackground,
                            ),
                          ),
                        Padding(
                          padding: EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 16.0, 0.0),
                          child: Row(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Padding(
                                padding: EdgeInsetsDirectional.fromSTEB(16.0, 16.0, 0.0, 0.0),
                                child: _model.isMultiSelectMode
                                    ? Row(
                                        children: [
                                          TextButton(
                                            onPressed: () => _model.exitMultiSelectMode(),
                                            child: Text(
                                              'Cancel',
                                              style: AppTheme.of(context).titleMedium.override(
                                                    font: GoogleFonts.readexPro(
                                                      fontWeight: AppTheme.of(context).titleMedium.fontWeight,
                                                      fontStyle: AppTheme.of(context).titleMedium.fontStyle,
                                                    ),
                                                    color: AppTheme.of(context).primary,
                                                    letterSpacing: 0.0,
                                                  ),
                                            ),
                                          ),
                                          SizedBox(width: 12.0),
                                          Text(
                                            '${_model.selectedCount} selected',
                                            style: AppTheme.of(context).titleMedium.override(
                                                  font: GoogleFonts.readexPro(
                                                    fontWeight: AppTheme.of(context).titleMedium.fontWeight,
                                                    fontStyle: AppTheme.of(context).titleMedium.fontStyle,
                                                  ),
                                                  letterSpacing: 0.0,
                                                ),
                                          ),
                                        ],
                                      )
                                    : Text(
                                        AppLocalizations.of(context).getText(
                                          'n99lg1qh' /* Diagnostics */,
                                        ),
                                        style: AppTheme.of(context).displaySmall.override(
                                              font: GoogleFonts.readexPro(
                                                fontWeight: AppTheme.of(context).displaySmall.fontWeight,
                                                fontStyle: AppTheme.of(context).displaySmall.fontStyle,
                                              ),
                                              letterSpacing: 0.0,
                                            ),
                                      ),
                              ),
                              Row(
                                children: [
                                  if (!_model.isMultiSelectMode && _familyMembers.isNotEmpty)
                                    AppIconButton(
                                      borderColor: Colors.transparent,
                                      borderRadius: 30.0,
                                      borderWidth: 1.0,
                                      buttonSize: 44.0,
                                      icon: Icon(
                                        Icons.edit_outlined,
                                        color: AppTheme.of(context).primaryText,
                                        size: 24.0,
                                      ),
                                      onPressed: () => _model.enterMultiSelectMode(),
                                    ),
                                  if (responsiveVisibility(
                                    context: context,
                                    tabletLandscape: true,
                                    desktop: true,
                                  ) && !_model.isMultiSelectMode)
                                    AppIconButton(
                                      borderColor: Colors.transparent,
                                      borderRadius: 30.0,
                                      borderWidth: 1.0,
                                      buttonSize: 60.0,
                                      icon: Icon(
                                        Icons.chat_bubble_outline_rounded,
                                        color: AppTheme.of(context).primaryText,
                                        size: 30.0,
                                      ),
                                      onPressed: () async {
                                        String? familyMemberId;
                                        if (_familyMembers.isNotEmpty && _model.tabBarController != null) {
                                          final selectedIndex = _model.tabBarController!.index;
                                          familyMemberId = _familyMembers[selectedIndex].id;
                                        }

                                        context.pushNamed(
                                          ChatHistoryWidget.routeName,
                                          extra: <String, dynamic>{
                                            'familyMemberId': familyMemberId,
                                          },
                                        );
                                      },
                                    ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Padding(
                            padding: EdgeInsetsDirectional.fromSTEB(4.0, 0.0, 4.0, 0.0),
                            child: _buildContent(),
                          ),
                        ),
                      ],
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

  Widget _buildContent() {
    if (_model.isLoading) {
      return Center(
        child: CircularProgressIndicator(
          color: AppTheme.of(context).primary,
        ),
      );
    }

    if (_familyMembers.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.people_outline,
              color: AppTheme.of(context).secondaryText,
              size: 72.0,
            ),
            SizedBox(height: 16.0),
            Text(
              'No family members found',
              style: AppTheme.of(context).titleMedium.override(
                    font: GoogleFonts.inter(
                      fontWeight: AppTheme.of(context).titleMedium.fontWeight,
                      fontStyle: AppTheme.of(context).titleMedium.fontStyle,
                    ),
                    color: AppTheme.of(context).secondaryText,
                    letterSpacing: 0.0,
                  ),
            ),
            SizedBox(height: 8.0),
            Text(
              'Add family members to see diagnostics history',
              style: AppTheme.of(context).bodySmall.override(
                    font: GoogleFonts.inter(
                      fontWeight: AppTheme.of(context).bodySmall.fontWeight,
                      fontStyle: AppTheme.of(context).bodySmall.fontStyle,
                    ),
                    letterSpacing: 0.0,
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return Stack(
      children: [
        Column(
          children: [
            Align(
              alignment: Alignment(0.0, 0),
              child: TabBar(
                isScrollable: true,
                labelColor: AppTheme.of(context).primaryText,
                unselectedLabelColor: AppTheme.of(context).secondaryText,
                labelStyle: AppTheme.of(context).titleMedium.override(
                      font: GoogleFonts.readexPro(
                        fontWeight: AppTheme.of(context).titleMedium.fontWeight,
                        fontStyle: AppTheme.of(context).titleMedium.fontStyle,
                      ),
                      letterSpacing: 0.0,
                    ),
                unselectedLabelStyle: TextStyle(),
                indicatorColor: AppTheme.of(context).primary,
                indicatorWeight: 3.0,
                tabs: _familyMembers.map((member) {
                  final isAdmin = member.admin;
                  return Tab(
                    text: isAdmin ? '${member.name} (You)' : member.name,
                  );
                }).toList(),
                controller: _model.tabBarController,
              ),
            ),
            Expanded(
              child: TabBarView(
                controller: _model.tabBarController,
                children: _familyMembers.asMap().entries.map((entry) {
                  final index = entry.key;
                  final member = entry.value;
                  final isCurrentTab = _model.tabBarCurrentIndex == index;
                  return _MemberSessionsTab(
                    key: isCurrentTab ? _currentTabKey : null,
                    memberId: member.id,
                    memberName: member.name,
                    animationsMap: animationsMap,
                    model: _model,
                  );
                }).toList(),
              ),
            ),
          ],
        ),
        // Bottom action bar for multi-select mode
        if (_model.isMultiSelectMode)
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: MultiSelectActionBar(
              selectedCount: _model.selectedCount,
              onDelete: () => _showDeleteConfirmation(),
              onSelectAll: () {
                final currentTabState = _currentTabKey.currentState;
                if (currentTabState != null) {
                  final allSessionIds = currentTabState._sessions.map((s) => s.sessionId).toList();
                  _model.selectAllSessions(allSessionIds);
                }
              },
              onDeselectAll: () => _model.deselectAllSessions(),
            ),
          ),
      ],
    );
  }

  Future<void> _showDeleteConfirmation() async {
    final count = _model.selectedCount;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Delete $count ${count == 1 ? 'diagnosis' : 'diagnoses'}?'),
        content: Text('This action cannot be undone. All associated images will also be deleted.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(
              'Delete',
              style: TextStyle(color: AppTheme.of(context).error),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _deleteSelectedSessions();
    }
  }

  Future<void> _deleteSelectedSessions() async {
    final sessionIds = _model.selectedSessionIds.toList();
    if (sessionIds.isEmpty) return;

    try {
      final isLocal = AppState().UserSession.isLocalSession;

      if (isLocal) {
        // Delete from SQLite
        await SQLiteManager.instance.deleteScanSessionsCascade(
          sessionIds: sessionIds,
        );
      } else {
        // Delete from Supabase (cascade: images first, then sessions)
        for (final sessionId in sessionIds) {
          await ScanImagesTable().delete(
            matchingRows: (q) => q.eq('scan_session_id', sessionId),
          );
          await ScanSessionsTable().delete(
            matchingRows: (q) => q.eq('id', sessionId),
          );
        }
      }

      // Exit multi-select mode
      _model.exitMultiSelectMode();

      // Reload current tab
      final currentTabState = _currentTabKey.currentState;
      if (currentTabState != null) {
        await currentTabState._loadSessions();
      }

      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Deleted ${sessionIds.length} ${sessionIds.length == 1 ? 'diagnosis' : 'diagnoses'}'),
            backgroundColor: AppTheme.of(context).success,
          ),
        );
      }
    } catch (e) {
      debugPrint('Error deleting sessions: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error deleting: ${e.toString()}'),
            backgroundColor: AppTheme.of(context).error,
          ),
        );
      }
    }
  }
}

// Separate widget for each member's sessions tab
class _MemberSessionsTab extends StatefulWidget {
  const _MemberSessionsTab({
    super.key,
    required this.memberId,
    required this.memberName,
    required this.animationsMap,
    required this.model,
  });

  final String memberId;
  final String memberName;
  final Map<String, AnimationInfo> animationsMap;
  final MainDIagnosticsModel model;

  @override
  State<_MemberSessionsTab> createState() => _MemberSessionsTabState();
}

class _MemberSessionsTabState extends State<_MemberSessionsTab> {
  bool _isLoading = true;
  List<_SessionData> _sessions = [];

  @override
  void initState() {
    super.initState();
    _loadSessions();
  }

  Future<void> _loadSessions() async {
    try {
      final isLocal = AppState().UserSession.isLocalSession;
      List<_SessionData> sessions = [];

      debugPrint('Loading sessions for member: ${widget.memberId}, isLocal: $isLocal');

      if (widget.memberId.isEmpty) {
        debugPrint('Warning: memberId is empty!');
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
        return;
      }

      if (isLocal) {
        // Load from SQLite - query scan_session directly
        final scanSessions = await SQLiteManager.instance.getScanSessionsByMemberId(
          memberId: widget.memberId,
        );

        debugPrint('SQLite: Found ${scanSessions.length} sessions for memberId: ${widget.memberId}');

        // Debug: Log family member info
        if (scanSessions.isEmpty) {
          debugPrint('SQLite DEBUG: No sessions found. Check if memberId matches stored sessions.');
          debugPrint('Looking for memberId: "${widget.memberId}"');
        }

        for (final session in scanSessions) {
          final sessionDate = session.sessionStart != null
              ? DateTime.fromMillisecondsSinceEpoch(session.sessionStart! * 1000)
              : DateTime.now();

          // Get images for this session to determine status and findings
          final images = await SQLiteManager.instance.getScanImagesBySessionId(
            sessionId: session.id,
          );

          debugPrint('Session ${session.id}: Found ${images.length} images');

          // Parse findings from images
          String findings = '';
          int issuesCount = 0;
          String overallStatus = 'healthy';
          Uint8List? thumbnail;

          for (final image in images) {
            if (thumbnail == null && image.diagnosedImage != null) {
              thumbnail = Uint8List.fromList(image.diagnosedImage!);
            }

            if (image.rawResponse != null && image.rawResponse!.isNotEmpty) {
              try {
                final detections = jsonDecode(image.rawResponse!) as List<dynamic>;
                for (final det in detections) {
                  final className = (det as Map<String, dynamic>)['className'] as String;
                  if (!className.startsWith('tooth_')) {
                    issuesCount++;
                    if (findings.isEmpty) {
                      findings = _formatClassName(className);
                    } else if (!findings.contains(_formatClassName(className))) {
                      final currentFindings = findings.split(', ');
                      if (currentFindings.length < 3) {
                        findings = '$findings, ${_formatClassName(className)}';
                      }
                    }
                  }
                }
              } catch (_) {}
            }
          }

          if (issuesCount > 0) {
            overallStatus = issuesCount > 3 ? 'urgent' : 'attention_needed';
          }

          sessions.add(_SessionData(
            sessionId: session.id,
            sessionDate: sessionDate,
            overallStatus: overallStatus,
            findings: findings,
            issuesCount: issuesCount,
            thumbnail: thumbnail,
          ));
        }
      } else {
        // Load from Supabase - query scan_session directly
        debugPrint('Supabase: Querying sessions for family_member_id: ${widget.memberId}');

        final scanSessions = await ScanSessionsTable().queryRows(
          queryFn: (q) => q
              .eq('family_member_id', widget.memberId)
              .order('session_start', ascending: false),
        );

        debugPrint('Supabase: Found ${scanSessions.length} sessions');

        // Debug: also check if there are ANY sessions in the database
        if (scanSessions.isEmpty) {
          final allSessions = await ScanSessionsTable().queryRows(
            queryFn: (q) => q.order('session_start', ascending: false),
            limit: 10,
          );
          debugPrint('Supabase DEBUG: Total sessions in DB (sample): ${allSessions.length}');
          for (final s in allSessions) {
            debugPrint('  Session: ${s.id}, familyMemberId: ${s.familyMemberId}');
          }
        }

        for (final session in scanSessions) {
          final sessionDate = session.sessionStart ?? DateTime.now();

          // Get images for this session
          final images = await ScanImagesTable().queryRows(
            queryFn: (q) => q
                .eq('scan_session_id', session.id)
                .order('captured_at'),
          );

          debugPrint('Session ${session.id}: Found ${images.length} images');

          // Parse findings from images
          String findings = '';
          int issuesCount = 0;
          String overallStatus = 'healthy';
          Uint8List? thumbnail;

          for (final image in images) {
            debugPrint('  Image ${image.id}: diagnosedImage=${image.diagnosedImage != null ? "${image.diagnosedImage!.length} bytes" : "null"}, image=${image.image != null ? "${image.image!.length} bytes" : "null"}');

            if (thumbnail == null && image.diagnosedImage != null) {
              thumbnail = image.diagnosedImage;
              debugPrint('  -> Set thumbnail from diagnosedImage: ${thumbnail!.length} bytes');
            } else if (thumbnail == null && image.image != null) {
              // Fallback to original image if diagnosed not available
              thumbnail = image.image;
              debugPrint('  -> Set thumbnail from original image: ${thumbnail!.length} bytes');
            }

            if (image.rawResponse != null && image.rawResponse!.isNotEmpty) {
              try {
                final detections = jsonDecode(image.rawResponse!) as List<dynamic>;
                for (final det in detections) {
                  final className = (det as Map<String, dynamic>)['className'] as String;
                  if (!className.startsWith('tooth_')) {
                    issuesCount++;
                    if (findings.isEmpty) {
                      findings = _formatClassName(className);
                    } else if (!findings.contains(_formatClassName(className))) {
                      final currentFindings = findings.split(', ');
                      if (currentFindings.length < 3) {
                        findings = '$findings, ${_formatClassName(className)}';
                      }
                    }
                  }
                }
              } catch (_) {}
            }
          }

          if (issuesCount > 0) {
            overallStatus = issuesCount > 3 ? 'urgent' : 'attention_needed';
          }

          sessions.add(_SessionData(
            sessionId: session.id,
            sessionDate: sessionDate,
            overallStatus: overallStatus,
            findings: findings,
            issuesCount: issuesCount,
            thumbnail: thumbnail,
          ));
        }
      }

      debugPrint('Total sessions loaded: ${sessions.length}');

      if (mounted) {
        setState(() {
          _sessions = sessions;
          _isLoading = false;
        });
      }
    } catch (e, stackTrace) {
      debugPrint('Error loading sessions: $e');
      debugPrint('Stack trace: $stackTrace');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  String _formatClassName(String className) {
    final words = className.split('_');
    return words.map((word) {
      if (word.isEmpty) return word;
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }).join(' ');
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Center(
        child: CircularProgressIndicator(
          color: AppTheme.of(context).primary,
        ),
      );
    }

    if (_sessions.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.history,
              color: AppTheme.of(context).secondaryText,
              size: 64.0,
            ),
            SizedBox(height: 16.0),
            Text(
              'No diagnostics history',
              style: AppTheme.of(context).titleMedium.override(
                    font: GoogleFonts.inter(
                      fontWeight: AppTheme.of(context).titleMedium.fontWeight,
                      fontStyle: AppTheme.of(context).titleMedium.fontStyle,
                    ),
                    color: AppTheme.of(context).secondaryText,
                    letterSpacing: 0.0,
                  ),
            ),
            SizedBox(height: 8.0),
            Text(
              'Complete a diagnosis session to see history here',
              style: AppTheme.of(context).bodySmall.override(
                    font: GoogleFonts.inter(
                      fontWeight: AppTheme.of(context).bodySmall.fontWeight,
                      fontStyle: AppTheme.of(context).bodySmall.fontStyle,
                    ),
                    letterSpacing: 0.0,
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    // Add extra bottom padding when in multi-select mode for the action bar
    final bottomPadding = widget.model.isMultiSelectMode ? 80.0 : 24.0;

    return Padding(
      padding: EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, bottomPadding),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: AppTheme.of(context).primaryBackground,
        ),
        child: ListView.builder(
          padding: EdgeInsets.zero,
          itemCount: _sessions.length,
          itemBuilder: (context, index) {
            final session = _sessions[index];
            return _buildSessionCard(session, index);
          },
        ),
      ),
    );
  }

  Widget _buildSessionCard(_SessionData session, int index) {
    final model = widget.model;
    final isMultiSelectMode = model.isMultiSelectMode;
    final isSelected = model.isSessionSelected(session.sessionId);

    // Determine status display
    String statusTitle;
    IconData statusIcon;
    Color statusColor;

    if (session.overallStatus == 'healthy') {
      statusTitle = 'No problems found';
      statusIcon = Icons.check_circle;
      statusColor = AppTheme.of(context).success;
    } else if (session.overallStatus == 'urgent') {
      statusTitle = 'Major problem found!';
      statusIcon = Icons.error_rounded;
      statusColor = AppTheme.of(context).error;
    } else if (session.overallStatus == 'attention_needed') {
      statusTitle = 'Problem found!';
      statusIcon = Icons.error_rounded;
      statusColor = AppTheme.of(context).warning;
    } else {
      statusTitle = 'Check completed';
      statusIcon = Icons.check_circle_outline;
      statusColor = AppTheme.of(context).secondaryText;
    }

    return Padding(
      padding: EdgeInsetsDirectional.fromSTEB(16.0, 8.0, 16.0, 0.0),
      child: GestureDetector(
        onLongPress: () {
          if (!isMultiSelectMode) {
            model.enterMultiSelectMode();
            model.toggleSessionSelection(session.sessionId);
          }
        },
        child: InkWell(
          splashColor: Colors.transparent,
          focusColor: Colors.transparent,
          hoverColor: Colors.transparent,
          highlightColor: Colors.transparent,
          onTap: () async {
            if (isMultiSelectMode) {
              // Toggle selection in multi-select mode
              model.toggleSessionSelection(session.sessionId);
            } else {
              // Navigate to details in normal mode
              context.pushNamed(
                SessionDetailsPageWidget.routeName,
                extra: <String, dynamic>{
                  'sessionId': session.sessionId,
                },
              );
            }
          },
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: isSelected
                  ? AppTheme.of(context).primary.withValues(alpha: 0.1)
                  : AppTheme.of(context).secondaryBackground,
              boxShadow: [
                BoxShadow(
                  blurRadius: 3.0,
                  color: Color(0x20000000),
                  offset: Offset(0.0, 1.0),
                )
              ],
              borderRadius: BorderRadius.circular(12.0),
              border: isSelected
                  ? Border.all(
                      color: AppTheme.of(context).primary,
                      width: 2.0,
                    )
                  : null,
            ),
            child: Padding(
              padding: EdgeInsetsDirectional.fromSTEB(8.0, 8.0, 12.0, 8.0),
              child: Row(
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Checkbox for multi-select mode
                  if (isMultiSelectMode)
                    Padding(
                      padding: EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 8.0, 0.0),
                      child: Checkbox(
                        value: isSelected,
                        onChanged: (value) {
                          model.toggleSessionSelection(session.sessionId);
                        },
                        activeColor: AppTheme.of(context).primary,
                        checkColor: Colors.white,
                      ),
                    ),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8.0),
                    child: session.thumbnail != null
                        ? Image.memory(
                            session.thumbnail!,
                            width: 70.0,
                            height: 70.0,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              debugPrint('Error loading thumbnail: $error');
                              return Container(
                                width: 70.0,
                                height: 70.0,
                                color: AppTheme.of(context).error.withValues(alpha: 0.2),
                                child: Icon(
                                  Icons.broken_image,
                                  color: AppTheme.of(context).error,
                                  size: 30.0,
                                ),
                              );
                            },
                          )
                        : Container(
                            width: 70.0,
                            height: 70.0,
                            color: AppTheme.of(context).alternate,
                            child: Icon(
                              Icons.photo_camera,
                              color: AppTheme.of(context).secondaryText,
                              size: 30.0,
                            ),
                          ),
                  ),
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: EdgeInsetsDirectional.fromSTEB(16.0, 0.0, 0.0, 0.0),
                          child: Text(
                            statusTitle,
                            style: AppTheme.of(context).titleMedium.override(
                                  font: GoogleFonts.readexPro(
                                    fontWeight: AppTheme.of(context).titleMedium.fontWeight,
                                    fontStyle: AppTheme.of(context).titleMedium.fontStyle,
                                  ),
                                  color: AppTheme.of(context).primaryText,
                                  letterSpacing: 0.0,
                                ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsetsDirectional.fromSTEB(16.0, 2.0, 0.0, 0.0),
                          child: Text(
                            dateTimeFormat('d/M/y', session.sessionDate),
                            style: AppTheme.of(context).bodySmall.override(
                                  font: GoogleFonts.inter(
                                    fontWeight: AppTheme.of(context).bodySmall.fontWeight,
                                    fontStyle: AppTheme.of(context).bodySmall.fontStyle,
                                  ),
                                  letterSpacing: 0.0,
                                ),
                          ),
                        ),
                        if (session.findings.isNotEmpty)
                          Padding(
                            padding: EdgeInsetsDirectional.fromSTEB(16.0, 2.0, 0.0, 0.0),
                            child: Text(
                              session.findings,
                              style: AppTheme.of(context).bodySmall.override(
                                    font: GoogleFonts.inter(
                                      fontWeight: AppTheme.of(context).bodySmall.fontWeight,
                                      fontStyle: AppTheme.of(context).bodySmall.fontStyle,
                                    ),
                                    color: AppTheme.of(context).secondaryText,
                                    letterSpacing: 0.0,
                                  ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  Icon(
                    statusIcon,
                    color: statusColor,
                    size: 24.0,
                  ),
                ],
              ),
            ),
          ),
        ),
      ).animateOnPageLoad(widget.animationsMap['containerOnPageLoadAnimation']!),
    );
  }
}

// Data class for session information
class _SessionData {
  final String sessionId;
  final DateTime sessionDate;
  final String overallStatus;
  final String findings;
  final int issuesCount;
  final Uint8List? thumbnail;

  _SessionData({
    required this.sessionId,
    required this.sessionDate,
    required this.overallStatus,
    required this.findings,
    required this.issuesCount,
    this.thumbnail,
  });
}
