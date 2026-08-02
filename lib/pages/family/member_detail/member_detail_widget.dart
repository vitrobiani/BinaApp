import '/app_core/app_util.dart';
import '/backend/schema/structs/index.dart';
import '/backend/sqlite/sqlite_manager.dart';
import '/backend/supabase/supabase.dart';
import '/bina_design/bina_design.dart';
import '/index.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_animate/flutter_animate.dart';

class MemberDetailWidget extends StatefulWidget {
  const MemberDetailWidget({
    super.key,
    required this.member,
  });

  static String routeName = 'MemberDetail';
  static String routePath = 'memberDetail';

  final FamilyMemberStruct member;

  @override
  State<MemberDetailWidget> createState() => _MemberDetailWidgetState();
}

class _MemberDetailWidgetState extends State<MemberDetailWidget> {
  List<_SessionData> _sessions = [];
  bool _isLoading = true;

  int? get _age {
    if (!widget.member.hasBirthday()) return null;
    return DateTime.now().difference(widget.member.birthday!).inDays ~/ 365;
  }

  DxChipKind get _diagnosisKind {
    if (!widget.member.hasLastChecked()) return DxChipKind.due;
    if (widget.member.score >= 80) return DxChipKind.good;
    if (widget.member.score >= 50) return DxChipKind.plaque;
    return DxChipKind.cavity;
  }

  BinaAvatarTone get _avatarTone {
    final hash = widget.member.name.hashCode;
    final tones = BinaAvatarTone.values;
    return tones[hash.abs() % (tones.length - 1)];
  }

  String _lastCheckedStr(BuildContext context) {
    if (!widget.member.hasLastChecked()) return AppLocalizations.of(context).getText('member_never_checked');
    final date = widget.member.lastChecked!;
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inDays == 0) {
      return AppLocalizations.of(context).getText('member_last_checked_today');
    } else if (diff.inDays == 1) {
      return AppLocalizations.of(context).getText('member_last_checked_yesterday');
    } else if (diff.inDays < 7) {
      return '${AppLocalizations.of(context).getText('member_last_checked_date')} ${diff.inDays} ${AppLocalizations.of(context).getText('family_days_ago')}';
    } else {
      return '${AppLocalizations.of(context).getText('member_last_checked_date')} ${DateFormat('d MMM').format(date)}';
    }
  }

  @override
  void initState() {
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback((_) async {
      await _loadSessions();
    });
  }

  Future<void> _loadSessions() async {
    try {
      final sessions = <_SessionData>[];

      if (AppState().UserSession.isLocalSession) {
        final rows = await SQLiteManager.instance.getScanSessionsByMemberId(
          memberId: widget.member.id,
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
          String notes = row.notes ?? '';

          sessions.add(_SessionData(
            id: row.id,
            date: row.sessionStart != null
                ? DateTime.fromMillisecondsSinceEpoch(row.sessionStart! * 1000)
                : DateTime.now(),
            imageCount: row.totalImagesCaptured,
            issuesCount: issuesCount,
            teethCount: teethCount,
            status: row.status,
            notes: notes,
          ));
        }
      } else {
        final rows = await ScanSessionsTable().queryRows(
          queryFn: (q) => q
              .eq('family_member_id', widget.member.id)
              .order('session_start', ascending: false),
        );

        for (final row in rows) {
          // Load images for this session
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

      // Sort by date descending
      sessions.sort((a, b) => b.date.compareTo(a.date));

      if (mounted) {
        setState(() {
          _sessions = sessions;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading sessions: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // Calculate stats from sessions
  int get _cleanCount => _sessions.where((s) => s.issuesCount == 0 && s.status == 'completed').length;
  int get _plaqueCount => _sessions.where((s) => s.issuesCount > 0 && s.issuesCount < 3).length;
  int get _cavityCount => _sessions.where((s) => s.issuesCount >= 3).length;

  Future<void> _showMemberMenu(BuildContext anchor) async {
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
    if (!mounted) return;
    if (choice == 'calibrate') {
      _openCalibration();
    } else if (choice == 'documents') {
      _openDocuments();
    }
  }

  void _openDocuments() {
    context.pushNamed(
      MemberDocumentsWidget.routeName,
      extra: <String, dynamic>{
        'familyMemberId': widget.member.id,
        'familyMemberName': widget.member.name,
      },
    );
  }

  void _openCalibration() {
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
        'familyMemberId': widget.member.id,
        'familyMemberName': widget.member.name,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BinaColors.surfaceAlt,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(
            top: 12,
            bottom: 120,
          ),
          child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with back button
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  BinaIconButton(
                    icon: Icons.chevron_left_rounded,
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  Builder(
                    builder: (btnContext) => BinaIconButton(
                      icon: Icons.more_vert_rounded,
                      onPressed: () => _showMemberMenu(btnContext),
                    ),
                  ),
                ],
              ),
            ).animate()
                .fadeIn(duration: 300.ms)
                .moveY(begin: -10, end: 0, duration: 300.ms),

            // Hero card
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
              child: _HeroCard(
                member: widget.member,
                age: _age,
                diagnosisKind: _diagnosisKind,
                avatarTone: _avatarTone,
                lastCheckedStr: _lastCheckedStr(context),
                onScan: () {
                  context.pushNamed(
                    MainDIagnosticsWidget.routeName,
                    extra: <String, dynamic>{
                      'preselectedMemberId': widget.member.id,
                      'preselectedMemberName': widget.member.name,
                    },
                  );
                },
              ),
            ).animate()
                .fadeIn(delay: 100.ms, duration: 400.ms)
                .moveY(begin: 20, end: 0, delay: 100.ms, duration: 400.ms),

            // Stats section
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: Row(
                children: [
                  Expanded(
                    child: _StatCard(
                      label: AppLocalizations.of(context).getText('member_clean'),
                      value: _cleanCount,
                      tone: DxChipKind.good,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _StatCard(
                      label: AppLocalizations.of(context).getText('member_plaque'),
                      value: _plaqueCount,
                      tone: DxChipKind.plaque,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _StatCard(
                      label: AppLocalizations.of(context).getText('member_cavity'),
                      value: _cavityCount,
                      tone: DxChipKind.cavity,
                    ),
                  ),
                ],
              ),
            ).animate()
                .fadeIn(delay: 200.ms, duration: 400.ms)
                .moveY(begin: 20, end: 0, delay: 200.ms, duration: 400.ms),

            // History section
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
              child: Column(
                children: [
                  BinaSectionHeader(
                    title: AppLocalizations.of(context).getText('member_history'),
                    action: AppLocalizations.of(context).getText('member_export'),
                    onActionTap: () {
                      // TODO: Export history
                    },
                  ),
                  const SizedBox(height: 12),
                  _HistoryList(
                    sessions: _sessions,
                    isLoading: _isLoading,
                    memberName: widget.member.name,
                  ),
                ],
              ),
            ).animate()
                .fadeIn(delay: 300.ms, duration: 400.ms)
                .moveY(begin: 20, end: 0, delay: 300.ms, duration: 400.ms),
            ],
          ),
        ),
      ),
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
// HERO CARD
// ═══════════════════════════════════════════════════════════════

class _HeroCard extends StatelessWidget {
  const _HeroCard({
    required this.member,
    required this.age,
    required this.diagnosisKind,
    required this.avatarTone,
    required this.lastCheckedStr,
    required this.onScan,
  });

  final FamilyMemberStruct member;
  final int? age;
  final DxChipKind diagnosisKind;
  final BinaAvatarTone avatarTone;
  final String lastCheckedStr;
  final VoidCallback onScan;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: BinaColors.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: BinaColors.line),
        boxShadow: BinaElevation.sh3,
      ),
      child: Column(
        children: [
          BinaAvatar(
            name: member.name,
            size: 84,
            tone: avatarTone,
            imageUrl: member.profilePic.isNotEmpty ? member.profilePic : null,
          ),
          const SizedBox(height: 10),
          Text(
            member.name,
            style: BinaType.headlineMd,
          ),
          const SizedBox(height: 4),
          Text(
            '${age != null ? '$age ${AppLocalizations.of(context).getText('member_years')} · ' : ''}$lastCheckedStr',
            style: BinaType.bodySm.copyWith(color: BinaColors.ink2),
          ),
          const SizedBox(height: 8),
          DxChip(kind: diagnosisKind),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            child: BinaButton(
              label: AppLocalizations.of(context).getText('member_scan_now'),
              variant: BinaButtonVariant.primary,
              icon: Icons.camera_alt_rounded,
              onPressed: onScan,
            ),
          ),
        ],
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
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: BinaColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: BinaColors.line),
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
          const SizedBox(height: 6),
          Text(
            '$value',
            style: BinaType.displaySm.copyWith(fontSize: 26),
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
    required this.memberName,
  });

  final List<_SessionData> sessions;
  final bool isLoading;
  final String memberName;

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
                AppLocalizations.of(context).getText('member_no_history'),
                style: BinaType.titleMd,
              ),
              const SizedBox(height: 4),
              Text(
                AppLocalizations.of(context).getText('member_start_scan'),
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
            memberName: memberName,
            onTap: () {
              context.pushNamed(
                SessionSummaryWidget.routeName,
                extra: <String, dynamic>{
                  'sessionId': session.id,
                  'imageCount': session.imageCount,
                  'memberName': memberName,
                  'overallStatus': session.issuesCount == 0 ? 'healthy' : 'attention_needed',
                },
              );
            },
          ),
        );
      }).toList(),
    );
  }
}

class _HistoryRow extends StatelessWidget {
  const _HistoryRow({
    required this.session,
    required this.memberName,
    required this.onTap,
  });

  final _SessionData session;
  final String memberName;
  final VoidCallback onTap;

  String get _dateStr {
    final date = session.date;
    final time = DateFormat('HH:mm').format(date);
    final day = DateFormat('d MMM').format(date);
    return '$day · $time';
  }

  String _getSummaryStr(BuildContext context) {
    if (session.status != 'completed') return AppLocalizations.of(context).getText('member_session_incomplete');
    if (session.issuesCount == 0) return AppLocalizations.of(context).getText('member_no_issues');
    return '${session.issuesCount} ${session.issuesCount > 1 ? AppLocalizations.of(context).getText('member_issues_found') : AppLocalizations.of(context).getText('member_issue_found')}';
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
                    AppLocalizations.of(context).getText('member_photos'),
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
                  Text(_getSummaryStr(context), style: BinaType.titleMd),
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
