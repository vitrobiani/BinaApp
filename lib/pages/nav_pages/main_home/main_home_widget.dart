import '/app_core/app_util.dart';
import '/backend/schema/structs/index.dart';
import '/bina_design/bina_design.dart';
import '/pages/nav_pages/web_nav/web_nav_widget.dart';
import '/pages/family/family_member/family_member_widget.dart';
import '/actions/actions.dart' as action_blocks;
import '/index.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'main_home_model.dart';
export 'main_home_model.dart';

class MainHomeWidget extends StatefulWidget {
  const MainHomeWidget({super.key});

  static String routeName = 'Main_Home';
  static String routePath = 'mainHome';

  @override
  State<MainHomeWidget> createState() => _MainHomeWidgetState();
}

class _MainHomeWidgetState extends State<MainHomeWidget>
    with TickerProviderStateMixin {
  late MainHomeModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => MainHomeModel());

    // On page load action.
    SchedulerBinding.instance.addPostFrameCallback((_) async {
      await action_blocks.updateSessionFamily(context);
    });
  }

  @override
  void dispose() {
    _model.maybeDispose();
    super.dispose();
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
    final family = session.family;
    final familyAmount = session.familyAmount;
    final sumChecked = session.sumChecked;
    final percentage = familyAmount > 0 ? (sumChecked / familyAmount) * 100 : 0.0;
    final unchecked = familyAmount - sumChecked;

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
            // Web nav for larger screens (tablet)
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
                children: [
                  // Scrollable content
                  SingleChildScrollView(
                    padding: const EdgeInsets.only(
                      top: 54,
                      bottom: 120, // Space for floating nav
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Greeting header
                        _GreetingHeader(userName: session.name)
                            .animate()
                            .fadeIn(duration: 600.ms)
                            .moveY(begin: 20, end: 0, duration: 600.ms),

                        // Hero progress card
                        Padding(
                          padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                          child: _HeroProgressCard(
                            percentage: percentage,
                            uncheckedCount: unchecked,
                            onViewFamily: () {
                              context.pushNamed(FamilyWidget.routeName);
                            },
                          ),
                        ).animate()
                            .fadeIn(delay: 200.ms, duration: 400.ms)
                            .moveY(begin: 30, end: 0, delay: 200.ms, duration: 400.ms),

                        // Family ribbon
                        Padding(
                          padding: const EdgeInsets.only(top: 24),
                          child: _FamilyRibbon(
                            family: family,
                            onMemberTap: (member) {
                              // Navigate to family screen - member detail is embedded there
                              context.pushNamed(FamilyWidget.routeName);
                            },
                            onAddMember: _showAddMemberSheet,
                            onSeeAll: () {
                              context.pushNamed(FamilyWidget.routeName);
                            },
                          ),
                        ).animate()
                            .fadeIn(delay: 400.ms, duration: 400.ms)
                            .moveY(begin: 30, end: 0, delay: 400.ms, duration: 400.ms),

                        // Recent scans
                        Padding(
                          padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                          child: _RecentScansSection(
                            family: family,
                            onHistoryTap: () {
                              context.pushNamed(MainDiagnoseWidget.routeName);
                            },
                          ),
                        ).animate()
                            .fadeIn(delay: 600.ms, duration: 400.ms)
                            .moveY(begin: 30, end: 0, delay: 600.ms, duration: 400.ms),

                        // Bina tip card
                        Padding(
                          padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                          child: const _BinaTipCard(),
                        ).animate()
                            .fadeIn(delay: 800.ms, duration: 400.ms)
                            .moveY(begin: 30, end: 0, delay: 800.ms, duration: 400.ms),
                      ],
                    ),
                  ),
                  // Floating bottom nav (phone only)
                  if (responsiveVisibility(
                    context: context,
                    tablet: false,
                    tabletLandscape: false,
                    desktop: false,
                  ))
                    const BinaFloatingNav(currentTab: BinaNavTab.home),
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
// GREETING HEADER
// ═══════════════════════════════════════════════════════════════

class _GreetingHeader extends StatelessWidget {
  const _GreetingHeader({required this.userName});

  final String userName;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final dateStr = DateFormat('EEEE · MMM d').format(now);

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  dateStr,
                  style: BinaType.overline,
                ),
                const SizedBox(height: 4),
                Text(
                  'Hello ${userName.isNotEmpty ? userName : 'there'}',
                  style: BinaType.displaySm,
                ),
              ],
            ),
          ),
          BinaIconButton(
            icon: Icons.notifications_outlined,
            onPressed: () {
              // TODO: Show notifications
            },
            badge: const BinaDotBadge(),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// HERO PROGRESS CARD
// ═══════════════════════════════════════════════════════════════

class _HeroProgressCard extends StatelessWidget {
  const _HeroProgressCard({
    required this.percentage,
    required this.uncheckedCount,
    required this.onViewFamily,
  });

  final double percentage;
  final int uncheckedCount;
  final VoidCallback onViewFamily;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: BinaColors.gradHero,
        borderRadius: BorderRadius.circular(24),
        boxShadow: BinaElevation.shHero,
      ),
      child: Stack(
        children: [
          // Decorative circle
          Positioned(
            top: -80,
            right: -40,
            child: Container(
              width: 240,
              height: 240,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.12),
              ),
            ),
          ),
          // Content
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'THIS WEEK',
                        style: BinaType.overline.copyWith(
                          color: Colors.white.withValues(alpha: 0.78),
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${percentage.round()}% checked',
                        style: BinaType.displaySm.copyWith(
                          color: Colors.white,
                          letterSpacing: -0.32,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '$uncheckedCount ${uncheckedCount == 1 ? 'member' : 'members'} undiagnosed',
                        style: BinaType.bodyMd.copyWith(
                          color: Colors.white.withValues(alpha: 0.9),
                        ),
                      ),
                      const SizedBox(height: 14),
                      BinaButton(
                        label: 'View family',
                        variant: BinaButtonVariant.glass,
                        size: BinaButtonSize.sm,
                        icon: Icons.arrow_forward,
                        onPressed: onViewFamily,
                      ),
                    ],
                  ),
                ),
                ProgressRings(
                  percentage: percentage,
                  size: 132,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// FAMILY RIBBON
// ═══════════════════════════════════════════════════════════════

class _FamilyRibbon extends StatelessWidget {
  const _FamilyRibbon({
    required this.family,
    required this.onMemberTap,
    required this.onAddMember,
    required this.onSeeAll,
  });

  final List<FamilyMemberStruct> family;
  final void Function(FamilyMemberStruct) onMemberTap;
  final VoidCallback onAddMember;
  final VoidCallback onSeeAll;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: BinaSectionHeader(
            title: 'Your family',
            action: 'See all',
            onActionTap: onSeeAll,
          ),
        ),
        SizedBox(
          height: 160,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: family.length + 1, // +1 for add button
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              if (index == family.length) {
                return _AddMemberCard(onTap: onAddMember);
              }
              return _MiniMemberCard(
                member: family[index],
                onTap: () => onMemberTap(family[index]),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _MiniMemberCard extends StatelessWidget {
  const _MiniMemberCard({
    required this.member,
    required this.onTap,
  });

  final FamilyMemberStruct member;
  final VoidCallback onTap;

  DxChipKind get _diagnosisKind {
    if (member.lastChecked == null) return DxChipKind.due;
    // For now, use score to determine status
    // In production, this would come from actual diagnosis data
    if (member.score >= 80) return DxChipKind.good;
    if (member.score >= 50) return DxChipKind.plaque;
    return DxChipKind.cavity;
  }

  BinaAvatarTone get _avatarTone {
    // Alternate tones based on position or some property
    final hash = member.name.hashCode;
    final tones = BinaAvatarTone.values;
    return tones[hash.abs() % (tones.length - 1)]; // Exclude 'ink'
  }

  @override
  Widget build(BuildContext context) {
    final lastCheckedStr = member.lastChecked != null
        ? DateFormat('d MMM').format(member.lastChecked!)
        : 'never checked';

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 130,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: BinaColors.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: BinaColors.line),
          boxShadow: BinaElevation.sh1,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            BinaAvatar(
              name: member.name,
              size: 40,
              tone: _avatarTone,
              imageUrl: member.profilePic.isNotEmpty ? member.profilePic : null,
            ),
            const SizedBox(height: 10),
            Text(
              member.name,
              style: BinaType.titleMd,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 1),
            Text(
              lastCheckedStr,
              style: BinaType.bodySm.copyWith(color: BinaColors.ink3),
            ),
            const Spacer(),
            DxChip(kind: _diagnosisKind, size: DxChipSize.sm),
          ],
        ),
      ),
    );
  }
}

class _AddMemberCard extends StatelessWidget {
  const _AddMemberCard({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 130,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: BinaColors.lineStrong,
            width: 2,
            strokeAlign: BorderSide.strokeAlignInside,
          ),
        ),
        child: CustomPaint(
          painter: _DashedBorderPainter(
            color: BinaColors.lineStrong,
            radius: 18,
            dashWidth: 8,
            dashSpace: 4,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.add,
                size: 22,
                color: BinaColors.primary,
              ),
              const SizedBox(height: 8),
              Text(
                'Add member',
                style: BinaType.labelMd.copyWith(color: BinaColors.primary),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DashedBorderPainter extends CustomPainter {
  _DashedBorderPainter({
    required this.color,
    required this.radius,
    required this.dashWidth,
    required this.dashSpace,
  });

  final Color color;
  final double radius;
  final double dashWidth;
  final double dashSpace;

  @override
  void paint(Canvas canvas, Size size) {
    // Draw dashed border using path
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final path = Path()
      ..addRRect(RRect.fromRectAndRadius(
        Rect.fromLTWH(1, 1, size.width - 2, size.height - 2),
        Radius.circular(radius),
      ));

    // Create dashed path
    final dashPath = Path();
    for (final metric in path.computeMetrics()) {
      double distance = 0;
      while (distance < metric.length) {
        final next = distance + dashWidth;
        dashPath.addPath(
          metric.extractPath(distance, next.clamp(0, metric.length)),
          Offset.zero,
        );
        distance = next + dashSpace;
      }
    }

    canvas.drawPath(dashPath, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ═══════════════════════════════════════════════════════════════
// RECENT SCANS SECTION
// ═══════════════════════════════════════════════════════════════

class _RecentScansSection extends StatelessWidget {
  const _RecentScansSection({
    required this.family,
    required this.onHistoryTap,
  });

  final List<FamilyMemberStruct> family;
  final VoidCallback onHistoryTap;

  @override
  Widget build(BuildContext context) {
    // Get recent scans from family members who have been checked
    final recentMembers = family
        .where((m) => m.hasLastChecked())
        .toList()
      ..sort((a, b) {
        final aDate = a.lastChecked;
        final bDate = b.lastChecked;
        if (aDate == null || bDate == null) return 0;
        return bDate.compareTo(aDate);
      });

    return Column(
      children: [
        BinaSectionHeader(
          title: 'Recent scans',
          action: 'History',
          onActionTap: onHistoryTap,
        ),
        if (recentMembers.isEmpty)
          BinaCard(
            child: Padding(
              padding: const EdgeInsets.all(BinaSpace.s4),
              child: Text(
                'No scans yet. Start by scanning a family member.',
                style: BinaType.bodyMd.copyWith(color: BinaColors.ink2),
                textAlign: TextAlign.center,
              ),
            ),
          )
        else
          ...recentMembers.take(3).map((member) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _ScanRow(member: member),
              )),
      ],
    );
  }
}

class _ScanRow extends StatelessWidget {
  const _ScanRow({required this.member});

  final FamilyMemberStruct member;

  DxChipKind get _diagnosisKind {
    if (member.score >= 80) return DxChipKind.good;
    if (member.score >= 50) return DxChipKind.plaque;
    return DxChipKind.cavity;
  }

  BinaAvatarTone get _avatarTone {
    final hash = member.name.hashCode;
    final tones = BinaAvatarTone.values;
    return tones[hash.abs() % (tones.length - 1)];
  }

  @override
  Widget build(BuildContext context) {
    final dateStr = member.lastChecked != null
        ? DateFormat('d MMM · HH:mm').format(member.lastChecked!)
        : '';

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: BinaColors.surface,
        borderRadius: BorderRadius.circular(BinaRadius.md),
        border: Border.all(color: BinaColors.line),
      ),
      child: Row(
        children: [
          BinaAvatar(
            name: member.name,
            size: 40,
            tone: _avatarTone,
            imageUrl: member.profilePic.isNotEmpty ? member.profilePic : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                  text: TextSpan(
                    style: BinaType.titleMd,
                    children: [
                      TextSpan(text: member.name),
                      TextSpan(
                        text: ' · Dental check',
                        style: BinaType.titleMd.copyWith(
                          color: BinaColors.ink2,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 1),
                Text(
                  dateStr,
                  style: BinaType.bodySm.copyWith(color: BinaColors.ink3),
                ),
              ],
            ),
          ),
          DxChip(kind: _diagnosisKind, size: DxChipSize.sm),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// BINA TIP CARD
// ═══════════════════════════════════════════════════════════════

class _BinaTipCard extends StatelessWidget {
  const _BinaTipCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: BinaColors.gradHeroSoft,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: BinaColors.surface,
              borderRadius: BorderRadius.circular(12),
              boxShadow: BinaElevation.sh1,
            ),
            child: Icon(
              Icons.auto_awesome,
              size: 22,
              color: BinaColors.primary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Bina tip', style: BinaType.titleMd),
                const SizedBox(height: 2),
                Text(
                  'Regular dental checks help catch issues early. Try scanning your family weekly for best results.',
                  style: BinaType.bodySm,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
