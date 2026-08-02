import '/app_core/app_util.dart';
import '/backend/schema/structs/index.dart';
import '/backend/sqlite/sqlite_manager.dart';
import '/backend/supabase/supabase.dart';
import '/bina_design/bina_design.dart';
import '/pages/family/family_member/family_member_widget.dart';
import '/pages/nav_pages/web_nav/web_nav_widget.dart';
import '/actions/actions.dart' as action_blocks;
import '/index.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'family_model.dart';
export 'family_model.dart';

class FamilyWidget extends StatefulWidget {
  const FamilyWidget({super.key});

  static String routeName = 'Family';
  static String routePath = 'family';

  @override
  State<FamilyWidget> createState() => _FamilyWidgetState();
}

class _FamilyWidgetState extends State<FamilyWidget>
    with TickerProviderStateMixin {
  late FamilyModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  // Filter state
  int _selectedFilterIndex = 0;

  // Selected member for desktop master-detail
  String? _selectedMemberId;

  // History data for selected member
  List<_SessionData> _sessions = [];
  bool _isLoadingSessions = false;
  int _lastScansVersion = 0;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => FamilyModel());
    _lastScansVersion = AppState().scansVersion;
    AppState().addListener(_onAppStateChanged);

    // Refresh family data on page load
    SchedulerBinding.instance.addPostFrameCallback((_) async {
      await action_blocks.updateSessionFamily(context);
      safeSetState(() {});

      // Auto-select first member on desktop
      final family = AppState().UserSession.family;
      if (family.isNotEmpty) {
        _selectMember(family.first.id);
      }
    });
  }

  @override
  void dispose() {
    AppState().removeListener(_onAppStateChanged);
    _model.dispose();
    super.dispose();
  }

  void _onAppStateChanged() {
    final v = AppState().scansVersion;
    if (v != _lastScansVersion) {
      _lastScansVersion = v;
      if (_selectedMemberId != null) {
        _loadSessions(_selectedMemberId!);
      }
    }
  }

  void _selectMember(String memberId) {
    if (_selectedMemberId != memberId) {
      setState(() {
        _selectedMemberId = memberId;
      });
      _loadSessions(memberId);
    }
  }

  void _openDocuments(FamilyMemberStruct member) {
    context.pushNamed(
      MemberDocumentsWidget.routeName,
      extra: <String, dynamic>{
        'familyMemberId': member.id,
        'familyMemberName': member.name,
      },
    );
  }

  void _openCalibration(FamilyMemberStruct member) {
    if (!AppState().cameraConnection.isCameraConnected()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
              'Connect to the Bina camera before calibrating — the gyro reads over Wi-Fi.'),
          backgroundColor: BinaColors.warning,
          action: SnackBarAction(
            label: 'Connect',
            textColor: BinaColors.surface,
            onPressed: () =>
                context.pushNamed(CameraConnectionWidget.routeName),
          ),
        ),
      );
      return;
    }
    context.pushNamed(
      CalibrationWidget.routeName,
      extra: <String, dynamic>{
        'familyMemberId': member.id,
        'familyMemberName': member.name,
      },
    );
  }

  Future<void> _loadSessions(String memberId) async {
    setState(() {
      _isLoadingSessions = true;
      _sessions = [];
    });

    try {
      final sessions = <_SessionData>[];

      if (AppState().UserSession.isLocalSession) {
        final rows = await SQLiteManager.instance.getScanSessionsByMemberId(
          memberId: memberId,
        );

        for (final row in rows) {
          final images = await SQLiteManager.instance.getScanImagesBySessionId(
            sessionId: row.id,
          );

          int issuesCount = 0;
          int teethCount = 0;

          for (final img in images) {
            if (img.rawResponse != null && img.rawResponse!.isNotEmpty) {
              try {
                final detections = jsonDecode(img.rawResponse!) as List<dynamic>;
                for (final d in detections) {
                  final className = d['className'] as String? ?? '';
                  if (className.startsWith('tooth_')) {
                    teethCount++;
                  } else {
                    issuesCount++;
                  }
                }
              } catch (_) {}
            }
          }

          sessions.add(_SessionData(
            id: row.id,
            date: row.sessionStart != null
                ? DateTime.fromMillisecondsSinceEpoch(row.sessionStart! * 1000)
                : DateTime.now(),
            imageCount: row.totalImagesCaptured,
            issuesCount: issuesCount,
            teethCount: teethCount,
            status: row.status,
            notes: row.notes ?? '',
          ));
        }
      } else {
        final rows = await ScanSessionsTable().queryRows(
          queryFn: (q) => q
              .eq('family_member_id', memberId)
              .order('session_start', ascending: false),
        );

        for (final row in rows) {
          final images = await ScanImagesTable().queryRows(
            queryFn: (q) => q.eq('scan_session_id', row.id),
          );

          int issuesCount = 0;
          int teethCount = 0;

          for (final img in images) {
            if (img.rawResponse != null && img.rawResponse!.isNotEmpty) {
              try {
                final detections = jsonDecode(img.rawResponse!) as List<dynamic>;
                for (final d in detections) {
                  final className = d['className'] as String? ?? '';
                  if (className.startsWith('tooth_')) {
                    teethCount++;
                  } else {
                    issuesCount++;
                  }
                }
              } catch (_) {}
            }
          }

          sessions.add(_SessionData(
            id: row.id,
            date: row.sessionStart ?? DateTime.now(),
            imageCount: row.totalImagesCaptured,
            issuesCount: issuesCount,
            teethCount: teethCount,
            status: row.status,
            notes: row.notes ?? '',
          ));
        }
      }

      sessions.sort((a, b) => b.date.compareTo(a.date));

      if (mounted) {
        setState(() {
          _sessions = sessions;
          _isLoadingSessions = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading sessions: $e');
      if (mounted) {
        setState(() {
          _isLoadingSessions = false;
        });
      }
    }
  }

  int get _cleanCount => _sessions.where((s) => s.issuesCount == 0 && s.status == 'completed').length;
  int get _plaqueCount => _sessions.where((s) => s.issuesCount > 0 && s.issuesCount < 3).length;
  int get _cavityCount => _sessions.where((s) => s.issuesCount >= 3).length;

  List<FamilyMemberStruct> _getFilteredFamily(List<FamilyMemberStruct> family) {
    switch (_selectedFilterIndex) {
      case 1: // Due now
        return family.where((m) => !m.hasLastChecked()).toList();
      case 2: // Adults (18+)
        return family.where((m) {
          if (!m.hasBirthday()) return true;
          final age = DateTime.now().difference(m.birthday!).inDays ~/ 365;
          return age >= 18;
        }).toList();
      case 3: // Kids (<18)
        return family.where((m) {
          if (!m.hasBirthday()) return false;
          final age = DateTime.now().difference(m.birthday!).inDays ~/ 365;
          return age < 18;
        }).toList();
      default: // All
        return family;
    }
  }

  void _showAddMemberSheet() async {
    await showModalBottomSheet(
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      enableDrag: true,
      context: context,
      builder: (context) {
        return GestureDetector(
          onTap: () {
            FocusScope.of(context).unfocus();
            FocusManager.instance.primaryFocus?.unfocus();
          },
          child: Padding(
            padding: MediaQuery.viewInsetsOf(context),
            child: const FamilyMemberWidget(),
          ),
        );
      },
    ).then((value) => safeSetState(() {}));
  }

  @override
  Widget build(BuildContext context) {
    context.watch<AppState>();

    final session = AppState().UserSession;
    final allFamily = session.family;
    final filteredFamily = _getFilteredFamily(allFamily);
    final dueCount = allFamily.where((m) => !m.hasLastChecked()).length;

    final filters = [
      '${AppLocalizations.of(context).getText('family_all')} ${allFamily.length}',
      '${AppLocalizations.of(context).getText('family_due_now')} $dueCount',
      AppLocalizations.of(context).getText('family_adults'),
      AppLocalizations.of(context).getText('family_kids'),
    ];

    final bp = BinaBreakpoints.fromContext(context);
    final isWide = bp != BinaBreakpoint.phone;

    // Get selected member for detail panel
    final selectedMember = _selectedMemberId != null
        ? allFamily.where((m) => m.id == _selectedMemberId).firstOrNull
        : null;

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
            if (isWide)
              wrapWithModel(
                model: _model.webNavModel,
                updateCallback: () => safeSetState(() {}),
                child: WebNavWidget(currentTab: BinaNavTab.family),
              ),
            // Main content
            Expanded(
              child: isWide
                  ? _buildWideLayout(
                      context: context,
                      filters: filters,
                      filteredFamily: filteredFamily,
                      selectedMember: selectedMember,
                    )
                  : _buildPhoneLayout(
                      context: context,
                      filters: filters,
                      filteredFamily: filteredFamily,
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPhoneLayout({
    required BuildContext context,
    required List<String> filters,
    required List<FamilyMemberStruct> filteredFamily,
  }) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Positioned.fill(
          child: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(
                top: 12,
                bottom: 120,
              ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        AppLocalizations.of(context).getText('family_title'),
                        style: BinaType.displaySm,
                      ).animate()
                          .fadeIn(duration: 600.ms)
                          .moveY(begin: 20, end: 0, duration: 600.ms),
                      _AddButton(onTap: _showAddMemberSheet),
                    ],
                  ),
                ),

                // Filter chips
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: SizedBox(
                    height: 40,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: filters.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 8),
                      itemBuilder: (context, index) {
                        return BinaFilterChip(
                          label: filters[index],
                          isSelected: _selectedFilterIndex == index,
                          onTap: () {
                            setState(() {
                              _selectedFilterIndex = index;
                            });
                          },
                        );
                      },
                    ),
                  ),
                ).animate()
                    .fadeIn(delay: 200.ms, duration: 400.ms)
                    .moveY(begin: 20, end: 0, delay: 200.ms, duration: 400.ms),

                // Family list
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                  child: filteredFamily.isEmpty
                      ? _EmptyState(
                          onAddMember: _showAddMemberSheet,
                        )
                      : Column(
                          children: filteredFamily
                              .asMap()
                              .entries
                              .map((entry) {
                            final index = entry.key;
                            final member = entry.value;
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: _FamilyMemberRow(
                                member: member,
                                onTap: () {
                                  context.pushNamed(
                                    MemberDetailWidget.routeName,
                                    extra: <String, dynamic>{
                                      'member': member,
                                    },
                                  );
                                },
                              ),
                            ).animate()
                                .fadeIn(
                                  delay: Duration(milliseconds: 300 + (index * 100)),
                                  duration: 400.ms,
                                )
                                .moveY(
                                  begin: 30,
                                  end: 0,
                                  delay: Duration(milliseconds: 300 + (index * 100)),
                                  duration: 400.ms,
                                );
                          }).toList(),
                        ),
                ),
                ],
              ),
            ),
          ),
        ),
        // Floating bottom nav (phone only)
        const BinaFloatingNav(currentTab: BinaNavTab.family),
      ],
    );
  }

  Widget _buildWideLayout({
    required BuildContext context,
    required List<String> filters,
    required List<FamilyMemberStruct> filteredFamily,
    required FamilyMemberStruct? selectedMember,
  }) {
    return Row(
      children: [
        // Master panel - family list
        SizedBox(
          width: 380,
          child: Container(
            decoration: BoxDecoration(
              color: BinaColors.surface,
              border: Border(
                right: BorderSide(color: BinaColors.line),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        AppLocalizations.of(context).getText('family_title'),
                        style: BinaType.displaySm,
                      ),
                      _AddButton(onTap: _showAddMemberSheet),
                    ],
                  ),
                ),

                // Filter chips
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: SizedBox(
                    height: 40,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: filters.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 8),
                      itemBuilder: (context, index) {
                        return BinaFilterChip(
                          label: filters[index],
                          isSelected: _selectedFilterIndex == index,
                          onTap: () {
                            setState(() {
                              _selectedFilterIndex = index;
                            });
                          },
                        );
                      },
                    ),
                  ),
                ),

                // Family list
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
                    child: filteredFamily.isEmpty
                        ? _EmptyState(onAddMember: _showAddMemberSheet)
                        : Column(
                            children: filteredFamily.map((member) {
                              final isSelected = member.id == _selectedMemberId;
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 10),
                                child: _FamilyMemberRow(
                                  member: member,
                                  isSelected: isSelected,
                                  onTap: () => _selectMember(member.id),
                                ),
                              );
                            }).toList(),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),

        // Detail panel
        Expanded(
          child: selectedMember != null
              ? _MemberDetailPanel(
                  key: ValueKey(selectedMember.id),
                  member: selectedMember,
                  sessions: _sessions,
                  isLoading: _isLoadingSessions,
                  cleanCount: _cleanCount,
                  plaqueCount: _plaqueCount,
                  cavityCount: _cavityCount,
                  onScan: () {
                    context.pushNamed(
                      MainDIagnosticsWidget.routeName,
                      extra: <String, dynamic>{
                        'preselectedMemberId': selectedMember.id,
                        'preselectedMemberName': selectedMember.name,
                      },
                    );
                  },
                  onSessionTap: (session) {
                    context.pushNamed(
                      SessionSummaryWidget.routeName,
                      extra: <String, dynamic>{
                        'sessionId': session.id,
                        'imageCount': session.imageCount,
                        'memberName': selectedMember.name,
                        'overallStatus': session.issuesCount == 0 ? 'healthy' : 'attention_needed',
                        'gemmaAnalysis': session.notes,
                      },
                    );
                  },
                  onCalibrate: () => _openCalibration(selectedMember),
                  onManageDocuments: () => _openDocuments(selectedMember),
                )
              : _NoSelectionPanel(),
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// SESSION DATA
// ═══════════════════════════════════════════════════════════════

class _SessionData {
  final String id;
  final DateTime date;
  final int imageCount;
  final int issuesCount;
  final int teethCount;
  final String status;
  final String notes;

  _SessionData({
    required this.id,
    required this.date,
    required this.imageCount,
    required this.issuesCount,
    required this.teethCount,
    required this.status,
    required this.notes,
  });

  DxChipKind get kind {
    if (status != 'completed') return DxChipKind.due;
    if (issuesCount == 0) return DxChipKind.good;
    if (issuesCount < 3) return DxChipKind.plaque;
    return DxChipKind.cavity;
  }
}

// ═══════════════════════════════════════════════════════════════
// ADD BUTTON
// ═══════════════════════════════════════════════════════════════

class _AddButton extends StatefulWidget {
  const _AddButton({required this.onTap});

  final VoidCallback onTap;

  @override
  State<_AddButton> createState() => _AddButtonState();
}

class _AddButtonState extends State<_AddButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: widget.onTap,
      child: AnimatedContainer(
        duration: BinaMotion.d1,
        width: 44,
        height: 44,
        transform: _isPressed
            ? (Matrix4.identity()..scale(0.95, 0.95))
            : Matrix4.identity(),
        transformAlignment: Alignment.center,
        decoration: BoxDecoration(
          color: BinaColors.primary,
          shape: BoxShape.circle,
          boxShadow: BinaElevation.sh2,
        ),
        child: const Icon(
          Icons.add,
          color: Colors.white,
          size: 22,
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// FAMILY MEMBER ROW
// ═══════════════════════════════════════════════════════════════

class _FamilyMemberRow extends StatelessWidget {
  const _FamilyMemberRow({
    required this.member,
    required this.onTap,
    this.isSelected = false,
  });

  final FamilyMemberStruct member;
  final VoidCallback onTap;
  final bool isSelected;

  int? get _age {
    if (!member.hasBirthday()) return null;
    return DateTime.now().difference(member.birthday!).inDays ~/ 365;
  }

  DxChipKind get _diagnosisKind {
    if (!member.hasLastChecked()) return DxChipKind.due;
    if (member.score >= 80) return DxChipKind.good;
    if (member.score >= 50) return DxChipKind.plaque;
    return DxChipKind.cavity;
  }

  BinaAvatarTone get _avatarTone {
    final hash = member.name.hashCode;
    final tones = BinaAvatarTone.values;
    return tones[hash.abs() % (tones.length - 1)];
  }

  String _lastCheckedStr(BuildContext context) {
    if (!member.hasLastChecked()) return AppLocalizations.of(context).getText('family_never_checked');
    final date = member.lastChecked!;
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inDays == 0) {
      return AppLocalizations.of(context).getText('family_last_checked_today');
    } else if (diff.inDays == 1) {
      return AppLocalizations.of(context).getText('family_last_checked_yesterday');
    } else if (diff.inDays < 7) {
      return '${AppLocalizations.of(context).getText('home_last_checked')} ${diff.inDays} ${AppLocalizations.of(context).getText('home_history')}';
    } else {
      return '${AppLocalizations.of(context).getText('home_last_checked')} ${DateFormat('d MMM').format(date)}';
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isSelected ? BinaColors.primary100 : BinaColors.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isSelected ? BinaColors.primary : BinaColors.line,
          ),
          boxShadow: isSelected ? [] : BinaElevation.sh2,
        ),
        child: Row(
          children: [
            // Avatar
            BinaAvatar(
              name: member.name,
              size: 52,
              tone: _avatarTone,
              imageUrl: member.profilePic.isNotEmpty ? member.profilePic : null,
            ),
            const SizedBox(width: 14),
            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Name and age
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          member.name,
                          style: BinaType.titleLg,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (_age != null) ...[
                        Text(
                          ' · $_age yrs',
                          style: BinaType.bodySm.copyWith(color: BinaColors.ink3),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 2),
                  // Last checked
                  Text(
                    _lastCheckedStr(context),
                    style: BinaType.bodySm,
                  ),
                  const SizedBox(height: 8),
                  // Diagnosis chip
                  DxChip(kind: _diagnosisKind, size: DxChipSize.sm),
                ],
              ),
            ),
            // Chevron
            Icon(
              Icons.chevron_right_rounded,
              color: BinaColors.ink3,
              size: 24,
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// EMPTY STATE
// ═══════════════════════════════════════════════════════════════

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onAddMember});

  final VoidCallback onAddMember;

  @override
  Widget build(BuildContext context) {
    return BinaCard(
      padding: const EdgeInsets.all(BinaSpace.s6),
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: BinaColors.primary100,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.groups_rounded,
              color: BinaColors.primary,
              size: 32,
            ),
          ),
          const SizedBox(height: BinaSpace.s4),
          Text(
            AppLocalizations.of(context).getText('family_no_members'),
            style: BinaType.titleLg,
          ),
          const SizedBox(height: BinaSpace.s2),
          Text(
            AppLocalizations.of(context).getText('family_add_first'),
            style: BinaType.bodyMd.copyWith(color: BinaColors.ink2),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: BinaSpace.s5),
          BinaButton(
            label: AppLocalizations.of(context).getText('home_add_member'),
            icon: Icons.add,
            onPressed: onAddMember,
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// NO SELECTION PANEL
// ═══════════════════════════════════════════════════════════════

class _NoSelectionPanel extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: BinaColors.surfaceAlt,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: BinaColors.surfaceSunken,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.person_outline_rounded,
                size: 40,
                color: BinaColors.ink3,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              AppLocalizations.of(context).getText('family_select_member'),
              style: BinaType.titleLg,
            ),
            const SizedBox(height: 4),
            Text(
              AppLocalizations.of(context).getText('family_choose_from_list'),
              style: BinaType.bodyMd.copyWith(color: BinaColors.ink2),
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// MEMBER DETAIL PANEL
// ═══════════════════════════════════════════════════════════════

class _MemberDetailPanel extends StatelessWidget {
  const _MemberDetailPanel({
    super.key,
    required this.member,
    required this.sessions,
    required this.isLoading,
    required this.cleanCount,
    required this.plaqueCount,
    required this.cavityCount,
    required this.onScan,
    required this.onSessionTap,
    required this.onCalibrate,
    required this.onManageDocuments,
  });

  final FamilyMemberStruct member;
  final List<_SessionData> sessions;
  final bool isLoading;
  final int cleanCount;
  final int plaqueCount;
  final int cavityCount;
  final VoidCallback onScan;
  final void Function(_SessionData session) onSessionTap;
  final VoidCallback onCalibrate;
  final VoidCallback onManageDocuments;

  Future<void> _showMenu(BuildContext anchor) async {
    final box = anchor.findRenderObject() as RenderBox?;
    final overlay =
        Overlay.of(anchor).context.findRenderObject() as RenderBox?;
    if (box == null || overlay == null) return;
    final position = RelativeRect.fromRect(
      Rect.fromPoints(
        box.localToGlobal(Offset.zero, ancestor: overlay),
        box.localToGlobal(box.size.bottomRight(Offset.zero), ancestor: overlay),
      ),
      Offset.zero & overlay.size,
    );
    final choice = await showMenu<String>(
      context: anchor,
      position: position,
      items: const [
        PopupMenuItem(
          value: 'calibrate',
          child: Row(
            children: [
              Icon(Icons.explore_outlined, size: 20),
              SizedBox(width: 12),
              Text('Calibrate orientation'),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'documents',
          child: Row(
            children: [
              Icon(Icons.folder_shared_outlined, size: 20),
              SizedBox(width: 12),
              Text('Manage documents'),
            ],
          ),
        ),
      ],
    );
    if (choice == 'calibrate') onCalibrate();
    if (choice == 'documents') onManageDocuments();
  }

  int? get _age {
    if (!member.hasBirthday()) return null;
    return DateTime.now().difference(member.birthday!).inDays ~/ 365;
  }

  DxChipKind get _diagnosisKind {
    if (!member.hasLastChecked()) return DxChipKind.due;
    if (member.score >= 80) return DxChipKind.good;
    if (member.score >= 50) return DxChipKind.plaque;
    return DxChipKind.cavity;
  }

  BinaAvatarTone get _avatarTone {
    final hash = member.name.hashCode;
    final tones = BinaAvatarTone.values;
    return tones[hash.abs() % (tones.length - 1)];
  }

  String _lastCheckedStr(BuildContext context) {
    if (!member.hasLastChecked()) return AppLocalizations.of(context).getText('home_never_checked');
    final date = member.lastChecked!;
    return '${AppLocalizations.of(context).getText('home_last_checked')} ${DateFormat('d MMM').format(date)}';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: BinaColors.surfaceAlt,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 500),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Align(
                  alignment: AlignmentDirectional.centerEnd,
                  child: Builder(
                    builder: (btnContext) => BinaIconButton(
                      icon: Icons.more_vert_rounded,
                      onPressed: () => _showMenu(btnContext),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                // Hero section
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: BinaColors.surface,
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(color: BinaColors.line),
                    boxShadow: BinaElevation.sh2,
                  ),
                  child: Column(
                    children: [
                      // Avatar
                      BinaAvatar(
                        name: member.name,
                        size: 100,
                        tone: _avatarTone,
                        imageUrl: member.profilePic.isNotEmpty ? member.profilePic : null,
                      ),
                      const SizedBox(height: 14),
                      // Name
                      Text(
                        member.name,
                        style: BinaType.headlineMd,
                      ),
                      const SizedBox(height: 4),
                      // Subtitle
                      Text(
                        '${_age != null ? '$_age years · ' : ''}${_lastCheckedStr(context)}',
                        style: BinaType.bodyMd.copyWith(color: BinaColors.ink2),
                      ),
                      const SizedBox(height: 12),
                      // Status chip and action buttons
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          DxChip(kind: _diagnosisKind),
                          const SizedBox(width: 12),
                          BinaButton(
                            label: AppLocalizations.of(context).getText('family_scan_now'),
                            variant: BinaButtonVariant.primary,
                            size: BinaButtonSize.sm,
                            icon: Icons.camera_alt_rounded,
                            onPressed: onScan,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Stats row
                Row(
                  children: [
                    Expanded(
                      child: _StatCard(
                        label: AppLocalizations.of(context).getText('family_clean'),
                        value: cleanCount,
                        tone: DxChipKind.good,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _StatCard(
                        label: AppLocalizations.of(context).getText('family_plaque'),
                        value: plaqueCount,
                        tone: DxChipKind.plaque,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _StatCard(
                        label: AppLocalizations.of(context).getText('family_cavity'),
                        value: cavityCount,
                        tone: DxChipKind.cavity,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // History section
                Column(
                  children: [
                    BinaSectionHeader(
                      title: AppLocalizations.of(context).getText('family_history'),
                      action: AppLocalizations.of(context).getText('family_export'),
                      onActionTap: () {
                        // TODO: Export history
                      },
                    ),
                    const SizedBox(height: 12),
                    _HistoryList(
                      sessions: sessions,
                      isLoading: isLoading,
                      onSessionTap: onSessionTap,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// STAT CARD
// ═══════════════════════════════════════════════════════════════

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.label,
    required this.value,
    required this.tone,
  });

  final String label;
  final int value;
  final DxChipKind tone;

  Color get _dotColor {
    switch (tone) {
      case DxChipKind.good:
        return BinaColors.success;
      case DxChipKind.plaque:
        return BinaColors.warning;
      case DxChipKind.cavity:
        return BinaColors.error;
      case DxChipKind.due:
      case DxChipKind.mixed:
        return BinaColors.ink3;
    }
  }

  Color get _backgroundColor {
    switch (tone) {
      case DxChipKind.good:
        return BinaColors.success100;
      case DxChipKind.plaque:
        return const Color(0xFFFCF0D8);
      case DxChipKind.cavity:
        return BinaColors.error100;
      case DxChipKind.due:
      case DxChipKind.mixed:
        return BinaColors.surfaceSunken;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: BinaColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: BinaColors.line),
        boxShadow: BinaElevation.sh1,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: _backgroundColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: _dotColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: BinaType.labelMd.copyWith(color: BinaColors.ink2),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '$value',
            style: BinaType.displaySm.copyWith(fontSize: 28),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// HISTORY LIST
// ═══════════════════════════════════════════════════════════════

class _HistoryList extends StatelessWidget {
  const _HistoryList({
    required this.sessions,
    required this.isLoading,
    required this.onSessionTap,
  });

  final List<_SessionData> sessions;
  final bool isLoading;
  final void Function(_SessionData session) onSessionTap;

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: BinaColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: BinaColors.line),
        ),
        child: Center(
          child: SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: BinaColors.primary,
            ),
          ),
        ),
      );
    }

    if (sessions.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: BinaColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: BinaColors.line),
        ),
        child: Center(
          child: Column(
            children: [
              Icon(
                Icons.history_rounded,
                color: BinaColors.ink3,
                size: 40,
              ),
              const SizedBox(height: 12),
              Text(
                AppLocalizations.of(context).getText('family_no_history'),
                style: BinaType.titleMd,
              ),
              const SizedBox(height: 4),
              Text(
                AppLocalizations.of(context).getText('family_start_scan'),
                style: BinaType.bodySm.copyWith(color: BinaColors.ink2),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      children: sessions.asMap().entries.map((entry) {
        final index = entry.key;
        final session = entry.value;
        return Padding(
          padding: EdgeInsets.only(bottom: index < sessions.length - 1 ? 10 : 0),
          child: _HistoryRow(
            session: session,
            onTap: () => onSessionTap(session),
          ),
        );
      }).toList(),
    );
  }
}

class _HistoryRow extends StatelessWidget {
  const _HistoryRow({
    required this.session,
    required this.onTap,
  });

  final _SessionData session;
  final VoidCallback onTap;

  String get _dateStr {
    final date = session.date;
    final time = DateFormat('HH:mm').format(date);
    final day = DateFormat('d MMM').format(date);
    return '$day · $time';
  }

  String get _summaryStr {
    if (session.status != 'completed') return 'Session incomplete';
    if (session.issuesCount == 0) return 'No issues detected';
    return '${session.issuesCount} issue${session.issuesCount > 1 ? 's' : ''} found';
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
        ),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF1A1A22), Color(0xFF2C2C38)],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '${session.imageCount}',
                    style: BinaType.titleMd.copyWith(color: Colors.white),
                  ),
                  Text(
                    'photos',
                    style: BinaType.labelSm.copyWith(
                      color: Colors.white.withValues(alpha: 0.6),
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(_summaryStr, style: BinaType.titleMd),
                  const SizedBox(height: 2),
                  Text(
                    _dateStr,
                    style: BinaType.bodySm.copyWith(color: BinaColors.ink3),
                  ),
                ],
              ),
            ),
            DxChip(kind: session.kind, size: DxChipSize.sm),
          ],
        ),
      ),
    );
  }
}
