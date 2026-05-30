import '/backend/schema/structs/index.dart';
import '/app_core/app_util.dart';
import '/bina_design/bina_design.dart';
import '/pages/nav_pages/web_nav/web_nav_widget.dart';
import '/actions/actions.dart' as action_blocks;
import '/index.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'main_diagnose_model.dart';
export 'main_diagnose_model.dart';

class MainDiagnoseWidget extends StatefulWidget {
  const MainDiagnoseWidget({super.key});

  static String routeName = 'Main_Diagnose';
  static String routePath = 'mainDiagnose';

  @override
  State<MainDiagnoseWidget> createState() => _MainDiagnoseWidgetState();
}

class _MainDiagnoseWidgetState extends State<MainDiagnoseWidget>
    with TickerProviderStateMixin {
  late MainDiagnoseModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => MainDiagnoseModel());

    // Refresh family data on page load
    SchedulerBinding.instance.addPostFrameCallback((_) async {
      await action_blocks.updateSessionFamily(context);
      safeSetState(() {});
    });
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    context.watch<AppState>();

    final familyMembers = AppState().UserSession.family.toList();

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
                  Positioned.fill(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.only(
                        top: MediaQuery.of(context).padding.top + 12,
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
                                  'Diagnose',
                                  style: BinaType.displaySm,
                                ),
                                BinaIconButton(
                                  icon: Icons.wifi_rounded,
                                  onPressed: () {
                                    context.pushNamed(CameraConnectionWidget.routeName);
                                  },
                                ),
                              ],
                            ),
                          ).animate()
                              .fadeIn(duration: 400.ms)
                              .moveY(begin: 20, end: 0, duration: 400.ms),

                          // Quick action card
                          Padding(
                            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                            child: _QuickScanCard(
                              onTap: () {
                                context.pushNamed(MainDIagnosticsWidget.routeName);
                              },
                            ),
                          ).animate()
                              .fadeIn(delay: 100.ms, duration: 400.ms)
                              .moveY(begin: 20, end: 0, delay: 100.ms, duration: 400.ms),

                          // Family members section
                          Padding(
                            padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                            child: BinaSectionHeader(
                              title: 'Family Members',
                              action: 'See all',
                              onActionTap: () => context.pushNamed('Family'),
                            ),
                          ).animate()
                              .fadeIn(delay: 200.ms, duration: 400.ms),

                          // Family list
                          if (familyMembers.isEmpty)
                            Padding(
                              padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                              child: _EmptyFamilyCard(
                                onAddMember: () => context.pushNamed('Family'),
                              ),
                            ).animate()
                                .fadeIn(delay: 300.ms, duration: 400.ms)
                          else
                            Padding(
                              padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                              child: Column(
                                children: familyMembers.asMap().entries.map((entry) {
                                  final index = entry.key;
                                  final member = entry.value;
                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 12),
                                    child: _FamilyMemberCard(
                                      member: member,
                                      onTap: () {
                                        context.pushNamed(
                                          PhotoSessionWidget.routeName,
                                          extra: <String, dynamic>{
                                            'memberId': member.id,
                                            'memberName': member.name,
                                          },
                                        );
                                      },
                                    ),
                                  ).animate()
                                      .fadeIn(
                                        delay: Duration(milliseconds: 300 + (index * 80)),
                                        duration: 400.ms,
                                      )
                                      .moveY(
                                        begin: 20,
                                        end: 0,
                                        delay: Duration(milliseconds: 300 + (index * 80)),
                                        duration: 400.ms,
                                      );
                                }).toList(),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                  // Floating bottom nav (phone only)
                  if (responsiveVisibility(
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
// QUICK SCAN CARD
// ═══════════════════════════════════════════════════════════════

class _QuickScanCard extends StatefulWidget {
  const _QuickScanCard({required this.onTap});

  final VoidCallback onTap;

  @override
  State<_QuickScanCard> createState() => _QuickScanCardState();
}

class _QuickScanCardState extends State<_QuickScanCard> {
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
        transform: _isPressed
            ? (Matrix4.identity()..setEntry(0, 0, 0.98)..setEntry(1, 1, 0.98))
            : Matrix4.identity(),
        transformAlignment: Alignment.center,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: BinaColors.gradHero,
          borderRadius: BorderRadius.circular(20),
          boxShadow: BinaElevation.shHero,
        ),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(
                Icons.camera_alt_rounded,
                color: Colors.white,
                size: 28,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Quick Scan',
                    style: BinaType.titleLg.copyWith(color: Colors.white),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Start a new dental scan session',
                    style: BinaType.bodySm.copyWith(
                      color: Colors.white.withValues(alpha: 0.8),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_rounded,
              color: Colors.white.withValues(alpha: 0.8),
              size: 24,
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// FAMILY MEMBER CARD
// ═══════════════════════════════════════════════════════════════

class _FamilyMemberCard extends StatelessWidget {
  const _FamilyMemberCard({
    required this.member,
    required this.onTap,
  });

  final FamilyMemberStruct member;
  final VoidCallback onTap;

  BinaAvatarTone get _avatarTone {
    final hash = member.name.hashCode;
    final tones = BinaAvatarTone.values;
    return tones[hash.abs() % (tones.length - 1)];
  }

  DxChipKind get _statusKind {
    if (!member.hasLastChecked()) return DxChipKind.due;
    if (member.score >= 80) return DxChipKind.good;
    if (member.score >= 50) return DxChipKind.plaque;
    return DxChipKind.cavity;
  }

  String get _lastCheckedStr {
    if (!member.hasLastChecked()) return 'Never checked';
    final date = member.lastChecked!;
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inDays == 0) {
      return 'Checked today';
    } else if (diff.inDays == 1) {
      return 'Checked yesterday';
    } else if (diff.inDays < 7) {
      return 'Checked ${diff.inDays} days ago';
    } else {
      return 'Checked ${DateFormat('d MMM').format(date)}';
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: BinaColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: BinaColors.line),
          boxShadow: BinaElevation.sh1,
        ),
        child: Row(
          children: [
            BinaAvatar(
              name: member.name,
              size: 48,
              tone: _avatarTone,
              imageUrl: member.profilePic.isNotEmpty ? member.profilePic : null,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        member.name,
                        style: BinaType.titleMd,
                      ),
                      if (member.admin) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: BinaColors.primary100,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            'Admin',
                            style: BinaType.labelSm.copyWith(
                              color: BinaColors.primary,
                              fontSize: 10,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _lastCheckedStr,
                    style: BinaType.bodySm.copyWith(color: BinaColors.ink3),
                  ),
                ],
              ),
            ),
            DxChip(kind: _statusKind, size: DxChipSize.sm),
            const SizedBox(width: 8),
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
// EMPTY FAMILY CARD
// ═══════════════════════════════════════════════════════════════

class _EmptyFamilyCard extends StatelessWidget {
  const _EmptyFamilyCard({required this.onAddMember});

  final VoidCallback onAddMember;

  @override
  Widget build(BuildContext context) {
    return BinaCard(
      padding: const EdgeInsets.all(BinaSpace.s6),
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: BinaColors.primary100,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.groups_rounded,
              color: BinaColors.primary,
              size: 28,
            ),
          ),
          const SizedBox(height: BinaSpace.s4),
          Text(
            'No family members',
            style: BinaType.titleMd,
          ),
          const SizedBox(height: BinaSpace.s2),
          Text(
            'Add family members to start scanning',
            style: BinaType.bodySm.copyWith(color: BinaColors.ink2),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: BinaSpace.s4),
          BinaButton(
            label: 'Add member',
            icon: Icons.add,
            onPressed: onAddMember,
          ),
        ],
      ),
    );
  }
}
