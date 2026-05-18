import '/app_core/app_util.dart';
import '/backend/schema/structs/index.dart';
import '/bina_design/bina_design.dart';
import '/pages/family/family_member/family_member_widget.dart';
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

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => FamilyModel());

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
      'All ${allFamily.length}',
      'Due now $dueCount',
      'Adults',
      'Kids',
    ];

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: BinaColors.surfaceAlt,
        body: Stack(
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
                  // Header
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Family',
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
            // Floating bottom nav (phone only)
            if (responsiveVisibility(
              context: context,
              tablet: false,
              tabletLandscape: false,
              desktop: false,
            ))
              const BinaFloatingNav(currentTab: BinaNavTab.family),
          ],
        ),
      ),
    );
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
  });

  final FamilyMemberStruct member;
  final VoidCallback onTap;

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

  String get _lastCheckedStr {
    if (!member.hasLastChecked()) return 'Never checked';
    final date = member.lastChecked!;
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inDays == 0) {
      return 'Last checked today';
    } else if (diff.inDays == 1) {
      return 'Last checked yesterday';
    } else if (diff.inDays < 7) {
      return 'Last checked ${diff.inDays} days ago';
    } else {
      return 'Last checked ${DateFormat('d MMM').format(date)}';
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
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: BinaColors.line),
          boxShadow: BinaElevation.sh2,
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
                      Text(
                        member.name,
                        style: BinaType.titleLg,
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
                    _lastCheckedStr,
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
            'No family members yet',
            style: BinaType.titleLg,
          ),
          const SizedBox(height: BinaSpace.s2),
          Text(
            'Add your first family member to start tracking dental health.',
            style: BinaType.bodyMd.copyWith(color: BinaColors.ink2),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: BinaSpace.s5),
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
