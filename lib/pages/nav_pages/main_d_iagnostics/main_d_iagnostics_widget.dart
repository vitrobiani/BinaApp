import '/backend/schema/structs/index.dart';
import '/app_core/app_util.dart';
import '/bina_design/bina_design.dart';
import '/pages/nav_pages/web_nav/web_nav_widget.dart';
import '/index.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_animate/flutter_animate.dart';
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

  List<FamilyMemberStruct> _familyMembers = [];

  // Track which view we're showing
  bool _showingTargetSelector = true;
  FamilyMemberStruct? _selectedMember;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => MainDIagnosticsModel());
    _model.onSelectionChanged = () => safeSetState(() {});

    SchedulerBinding.instance.addPostFrameCallback((_) async {
      await _loadFamilyMembers();
    });
  }

  Future<void> _loadFamilyMembers() async {
    final family = AppState().UserSession.family.toList();
    if (family.isNotEmpty) {
      safeSetState(() {
        _familyMembers = family;
        _model.tabBarController = TabController(
          vsync: this,
          length: family.length,
          initialIndex: 0,
        )..addListener(() {
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

  void _selectMember(FamilyMemberStruct member) {
    safeSetState(() {
      _selectedMember = member;
      _showingTargetSelector = false;
      // Update tab to match selected member
      final index = _familyMembers.indexWhere((m) => m.id == member.id);
      if (index >= 0 && _model.tabBarController != null) {
        _model.tabBarController!.animateTo(index);
      }
    });
  }

  void _goBackToSelector() {
    safeSetState(() {
      _showingTargetSelector = true;
      _selectedMember = null;
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
                children: [
                  // Content based on state
                  if (_showingTargetSelector)
                    _ScanTargetSelector(
                      familyMembers: _familyMembers,
                      isLoading: _model.isLoading,
                      onSelectMember: _selectMember,
                      onCancel: () => context.pop(),
                    )
                  else
                    _ScanSessionView(
                      member: _selectedMember,
                      familyMembers: _familyMembers,
                      model: _model,
                      onBack: _goBackToSelector,
                      onReload: () => safeSetState(() {}),
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
// SCAN TARGET SELECTOR
// ═══════════════════════════════════════════════════════════════

class _ScanTargetSelector extends StatelessWidget {
  const _ScanTargetSelector({
    required this.familyMembers,
    required this.isLoading,
    required this.onSelectMember,
    required this.onCancel,
  });

  final List<FamilyMemberStruct> familyMembers;
  final bool isLoading;
  final void Function(FamilyMemberStruct) onSelectMember;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    final user = AppState().UserSession;

    return SingleChildScrollView(
      padding: const EdgeInsets.only(
        top: 54,
        bottom: 120,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: Row(
              children: [
                BinaIconButton(
                  icon: Icons.chevron_left_rounded,
                  onPressed: onCancel,
                ),
                const Spacer(),
                Text(
                  'Step 1 of 2',
                  style: BinaType.labelMd,
                ),
                const Spacer(),
                const SizedBox(width: 44),
              ],
            ),
          ).animate()
              .fadeIn(duration: 400.ms)
              .moveY(begin: 10, end: 0, duration: 400.ms),

          // Title
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Who are you scanning?',
                  style: BinaType.displaySm,
                ),
                const SizedBox(height: 8),
                Text(
                  'Pick the family member this scan belongs to. The result will be saved to their history.',
                  style: BinaType.bodyLg.copyWith(color: BinaColors.ink2),
                ),
              ],
            ),
          ).animate()
              .fadeIn(delay: 100.ms, duration: 400.ms)
              .moveY(begin: 20, end: 0, delay: 100.ms, duration: 400.ms),

          // "Scan myself" hero card
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
            child: _SelfScanCard(
              userName: user.name,
              onTap: () {
                // Create a self member struct
                final selfMember = FamilyMemberStruct(
                  id: user.userID,
                  name: user.name,
                  admin: true,
                );
                onSelectMember(selfMember);
              },
            ),
          ).animate()
              .fadeIn(delay: 200.ms, duration: 400.ms)
              .moveY(begin: 20, end: 0, delay: 200.ms, duration: 400.ms),

          // Family members list
          if (isLoading)
            const Padding(
              padding: EdgeInsets.all(40),
              child: Center(child: CircularProgressIndicator()),
            )
          else if (familyMembers.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 8),
              child: Text(
                'FAMILY MEMBERS',
                style: BinaType.overline,
              ),
            ).animate()
                .fadeIn(delay: 300.ms, duration: 400.ms),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: familyMembers.asMap().entries.map((entry) {
                  final index = entry.key;
                  final member = entry.value;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _MemberSelectCard(
                      member: member,
                      onTap: () => onSelectMember(member),
                    ),
                  ).animate()
                      .fadeIn(
                        delay: Duration(milliseconds: 350 + (index * 80)),
                        duration: 400.ms,
                      )
                      .moveY(
                        begin: 20,
                        end: 0,
                        delay: Duration(milliseconds: 350 + (index * 80)),
                        duration: 400.ms,
                      );
                }).toList(),
              ),
            ),
          ] else
            Padding(
              padding: const EdgeInsets.all(40),
              child: Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.groups_outlined,
                      size: 48,
                      color: BinaColors.ink3,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'No family members yet',
                      style: BinaType.titleMd.copyWith(color: BinaColors.ink2),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Add members in the Family screen',
                      style: BinaType.bodySm,
                    ),
                  ],
                ),
              ),
            ).animate()
                .fadeIn(delay: 300.ms, duration: 400.ms),
        ],
      ),
    );
  }
}

class _SelfScanCard extends StatefulWidget {
  const _SelfScanCard({
    required this.userName,
    required this.onTap,
  });

  final String userName;
  final VoidCallback onTap;

  @override
  State<_SelfScanCard> createState() => _SelfScanCardState();
}

class _SelfScanCardState extends State<_SelfScanCard> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final initials = widget.userName.isNotEmpty
        ? widget.userName.substring(0, widget.userName.length.clamp(0, 2)).toUpperCase()
        : 'ME';

    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: widget.onTap,
      child: AnimatedContainer(
        duration: BinaMotion.d1,
        transform: _isPressed
            ? (Matrix4.identity()..scale(0.98, 0.98))
            : Matrix4.identity(),
        transformAlignment: Alignment.center,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: BinaColors.gradHero,
          borderRadius: BorderRadius.circular(18),
          boxShadow: BinaElevation.shHero,
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  initials,
                  style: BinaType.titleMd.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Scan myself',
                    style: BinaType.titleLg.copyWith(color: Colors.white),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    widget.userName.isNotEmpty ? widget.userName : 'Your account',
                    style: BinaType.bodySm.copyWith(
                      color: Colors.white.withValues(alpha: 0.85),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: Colors.white.withValues(alpha: 0.8),
              size: 24,
            ),
          ],
        ),
      ),
    );
  }
}

class _MemberSelectCard extends StatelessWidget {
  const _MemberSelectCard({
    required this.member,
    required this.onTap,
  });

  final FamilyMemberStruct member;
  final VoidCallback onTap;

  int? get _age {
    if (!member.hasBirthday()) return null;
    return DateTime.now().difference(member.birthday!).inDays ~/ 365;
  }

  String get _lastCheckedStr {
    if (!member.hasLastChecked()) return 'never checked';
    final date = member.lastChecked!;
    final diff = DateTime.now().difference(date);
    if (diff.inDays == 0) return 'checked today';
    if (diff.inDays == 1) return 'checked yesterday';
    if (diff.inDays < 7) return 'checked ${diff.inDays} days ago';
    return 'last checked ${DateFormat('d MMM').format(date)}';
  }

  BinaAvatarTone get _avatarTone {
    final hash = member.name.hashCode;
    final tones = BinaAvatarTone.values;
    return tones[hash.abs() % (tones.length - 1)];
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
          boxShadow: BinaElevation.sh1,
        ),
        child: Row(
          children: [
            BinaAvatar(
              name: member.name,
              size: 44,
              tone: _avatarTone,
              imageUrl: member.profilePic.isNotEmpty ? member.profilePic : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    member.name,
                    style: BinaType.titleMd,
                  ),
                  const SizedBox(height: 1),
                  Text(
                    '${_age != null ? '$_age yrs · ' : ''}$_lastCheckedStr',
                    style: BinaType.bodySm.copyWith(color: BinaColors.ink3),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: BinaColors.ink3,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// SCAN SESSION VIEW (shows after selecting a member)
// ═══════════════════════════════════════════════════════════════

class _ScanSessionView extends StatelessWidget {
  const _ScanSessionView({
    required this.member,
    required this.familyMembers,
    required this.model,
    required this.onBack,
    required this.onReload,
  });

  final FamilyMemberStruct? member;
  final List<FamilyMemberStruct> familyMembers;
  final MainDIagnosticsModel model;
  final VoidCallback onBack;
  final VoidCallback onReload;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(
        top: 54,
        bottom: 120,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: Row(
              children: [
                BinaIconButton(
                  icon: Icons.chevron_left_rounded,
                  onPressed: onBack,
                ),
                const Spacer(),
                Column(
                  children: [
                    Text(
                      'Scan session',
                      style: BinaType.titleMd,
                    ),
                    Text(
                      member?.name ?? 'Unknown',
                      style: BinaType.bodySm.copyWith(color: BinaColors.ink2),
                    ),
                  ],
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: BinaColors.primary100,
                    borderRadius: BorderRadius.circular(BinaRadius.pill),
                  ),
                  child: Text(
                    '0 photos',
                    style: BinaType.labelMd.copyWith(
                      color: BinaColors.primary700,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Summary stats card
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: BinaColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: BinaColors.line),
                boxShadow: BinaElevation.sh1,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: _StatColumn(label: 'PHOTOS', value: '0', tone: 'primary'),
                  ),
                  Container(width: 1, height: 36, color: BinaColors.line),
                  Expanded(
                    child: _StatColumn(label: 'TEETH', value: '0', tone: 'ink'),
                  ),
                  Container(width: 1, height: 36, color: BinaColors.line),
                  Expanded(
                    child: _StatColumn(label: 'ISSUES', value: '0', tone: 'good'),
                  ),
                ],
              ),
            ),
          ),

          // Camera connection button
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
            child: GestureDetector(
              onTap: () {
                context.pushNamed(CameraConnectionWidget.routeName);
              },
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: BinaColors.surface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: BinaColors.lineStrong,
                    style: BorderStyle.solid,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: BinaColors.surfaceSunken,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        Icons.camera_alt_rounded,
                        color: BinaColors.ink2,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Connect a camera',
                            style: BinaType.titleSm,
                          ),
                          Text(
                            'Phone camera or Bina dental cam',
                            style: BinaType.bodySm.copyWith(color: BinaColors.ink3),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.chevron_right_rounded,
                      color: BinaColors.ink3,
                      size: 18,
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Empty state for photos
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Captured photos', style: BinaType.headlineSm),
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 20),
                  decoration: BoxDecoration(
                    color: BinaColors.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: BinaColors.lineStrong,
                      style: BorderStyle.solid,
                    ),
                  ),
                  child: Column(
                    children: [
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: BinaColors.primary100,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Icon(
                          Icons.camera_alt_rounded,
                          color: BinaColors.primary,
                          size: 28,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'No photos yet',
                        style: BinaType.titleMd,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Capture dental images of the lower and upper rows. We\'ll diagnose each one and you can review before saving.',
                        style: BinaType.bodySm.copyWith(color: BinaColors.ink3),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Capture buttons
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: BinaButton(
                        label: 'Camera',
                        icon: Icons.camera_alt_rounded,
                        onPressed: () {
                          context.pushNamed(CameraConnectionWidget.routeName);
                        },
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: BinaButton(
                        label: 'Gallery',
                        variant: BinaButtonVariant.ghost,
                        icon: Icons.photo_library_rounded,
                        onPressed: () {
                          // TODO: Open gallery picker
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: BinaButton(
                    label: 'Finish session',
                    variant: BinaButtonVariant.ghost,
                    icon: Icons.check_rounded,
                    fullWidth: true,
                    enabled: false, // Disabled until photos are captured
                    onPressed: null,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatColumn extends StatelessWidget {
  const _StatColumn({
    required this.label,
    required this.value,
    required this.tone,
  });

  final String label;
  final String value;
  final String tone;

  Color get _valueColor {
    switch (tone) {
      case 'primary': return BinaColors.primary;
      case 'good': return BinaColors.dxGood;
      case 'cavity': return BinaColors.dxCavity;
      default: return BinaColors.ink;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: BinaType.headlineMd.copyWith(
            color: _valueColor,
            letterSpacing: -0.01 * 22,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: BinaType.labelSm.copyWith(
            color: BinaColors.ink3,
            letterSpacing: 0.08 * 11,
          ),
        ),
      ],
    );
  }
}
