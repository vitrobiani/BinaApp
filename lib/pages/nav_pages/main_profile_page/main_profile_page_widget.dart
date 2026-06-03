import '/auth/supabase_auth/auth_util.dart';
import '/app_core/app_util.dart';
import '/app_core/app_theme_type.dart';
import '/bina_design/bina_design.dart';
import '/pages/nav_pages/web_nav/web_nav_widget.dart';
import '/index.dart';
import '/services/accessibility_settings_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'main_profile_page_model.dart';
export 'main_profile_page_model.dart';

class MainProfilePageWidget extends StatefulWidget {
  const MainProfilePageWidget({super.key});

  static String routeName = 'Main_profilePage';
  static String routePath = 'mainProfilePage';

  @override
  State<MainProfilePageWidget> createState() => _MainProfilePageWidgetState();
}

class _MainProfilePageWidgetState extends State<MainProfilePageWidget>
    with TickerProviderStateMixin {
  late MainProfilePageModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => MainProfilePageModel());
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  void _openAccessibility() {
    context.pushNamed(AccessibilityWidget.routeName);
  }

  void _openHelpSupport() {
    context.pushNamed(HelpSupportWidget.routeName);
  }

  void _openAccountSettings() {
    context.pushNamed(AccountSettingsWidget.routeName);
  }

  void _showSignOutDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: BinaColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(BinaRadius.lg),
        ),
        title: Text(
          AppLocalizations.of(context).getText('profile_sign_out_question'),
          style: BinaType.headlineSm,
        ),
        content: Text(
          AppLocalizations.of(context).getText('profile_sign_out_message'),
          style: BinaType.bodyMd.copyWith(color: BinaColors.ink2),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(
              AppLocalizations.of(context).getText('profile_cancel'),
              style: BinaType.labelLg.copyWith(color: BinaColors.ink2),
            ),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(ctx).pop();
              GoRouter.of(context).prepareAuthEvent();
              await authManager.signOut();
              GoRouter.of(context).clearRedirectLocation();
              context.goNamedAuth(Auth2LoginWidget.routeName, context.mounted);
            },
            child: Text(
              AppLocalizations.of(context).getText('profile_sign_out'),
              style: BinaType.labelLg.copyWith(color: BinaColors.error),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    context.watch<AppState>();

    final user = AppState().UserSession;
    final currentThemeType = AccessibilitySettingsService.instance.themeType;
    final currentBinaTheme = _mapToBinaTheme(currentThemeType);

    final bp = BinaBreakpoints.fromContext(context);
    final isWide = bp != BinaBreakpoint.phone;

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
                child: WebNavWidget(currentTab: BinaNavTab.profile),
              ),
            // Main content
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // Scrollable content
                  Positioned.fill(
                    child: SafeArea(
                      child: SingleChildScrollView(
                        padding: EdgeInsets.only(
                          top: isWide ? 24 : 12,
                          bottom: isWide ? 32 : 120,
                        ),
                        child: isWide
                            ? _buildWideContent(
                                user: user,
                                currentBinaTheme: currentBinaTheme,
                              )
                            : _buildPhoneContent(
                                user: user,
                                currentBinaTheme: currentBinaTheme,
                              ),
                      ),
                    ),
                  ),
                  // Floating bottom nav (phone only)
                  if (!isWide)
                    const BinaFloatingNav(currentTab: BinaNavTab.profile),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPhoneContent({
    required dynamic user,
    required BinaThemeId currentBinaTheme,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
          child: Text(
            AppLocalizations.of(context).getText('profile_title'),
            style: BinaType.displaySm,
          ),
        ).animate()
            .fadeIn(duration: 400.ms)
            .moveY(begin: 20, end: 0, duration: 400.ms),

        // Identity card
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
          child: _IdentityCard(
            name: user.name,
            email: user.email,
            onTap: _openAccountSettings,
          ),
        ).animate()
            .fadeIn(delay: 100.ms, duration: 400.ms)
            .moveY(begin: 20, end: 0, delay: 100.ms, duration: 400.ms),

        // Appearance section
        _ProfileGroup(
          title: AppLocalizations.of(context).getText('profile_appearance'),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      AppLocalizations.of(context).getText('profile_theme'),
                      style: BinaType.labelMd,
                    ),
                    GestureDetector(
                      onTap: _openAccessibility,
                      child: Text(
                        AppLocalizations.of(context).getText('profile_more_options'),
                        style: BinaType.labelSm.copyWith(
                          color: BinaColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _buildThemeSwatches(currentBinaTheme),
              ],
            ),
          ),
        ).animate()
            .fadeIn(delay: 200.ms, duration: 400.ms)
            .moveY(begin: 20, end: 0, delay: 200.ms, duration: 400.ms),

        // Settings section
        _ProfileGroup(
          title: AppLocalizations.of(context).getText('profile_settings'),
          child: Column(
            children: [
              _HubRow(
                icon: Icons.person_outline_rounded,
                label: AppLocalizations.of(context).getText('profile_account'),
                subtitle: AppLocalizations.of(context).getText('profile_account_subtitle'),
                tone: _HubRowTone.blue,
                onTap: _openAccountSettings,
              ),
              _HubRow(
                icon: Icons.accessibility_new_rounded,
                label: AppLocalizations.of(context).getText('profile_accessibility'),
                subtitle: AppLocalizations.of(context).getText('profile_accessibility_subtitle'),
                tone: _HubRowTone.aqua,
                onTap: _openAccessibility,
              ),
              _HubRow(
                icon: Icons.help_outline_rounded,
                label: AppLocalizations.of(context).getText('profile_help_support'),
                subtitle: AppLocalizations.of(context).getText('profile_help_subtitle'),
                tone: _HubRowTone.coral,
                isLast: true,
                onTap: _openHelpSupport,
              ),
            ],
          ),
        ).animate()
            .fadeIn(delay: 300.ms, duration: 400.ms)
            .moveY(begin: 20, end: 0, delay: 300.ms, duration: 400.ms),

        // About section
        _ProfileGroup(
          title: AppLocalizations.of(context).getText('profile_about'),
          child: _HubRow(
            icon: Icons.info_outline_rounded,
            label: AppLocalizations.of(context).getText('profile_about_bina'),
            subtitle: AppLocalizations.of(context).getText('profile_version'),
            tone: _HubRowTone.blue,
            isLast: true,
            onTap: () {
              // TODO: Open about
            },
          ),
        ).animate()
            .fadeIn(delay: 400.ms, duration: 400.ms)
            .moveY(begin: 20, end: 0, delay: 400.ms, duration: 400.ms),

        // Sign out button
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
          child: SizedBox(
            width: double.infinity,
            child: BinaButton(
              label: AppLocalizations.of(context).getText('profile_sign_out'),
              variant: BinaButtonVariant.ghost,
              onPressed: _showSignOutDialog,
            ),
          ),
        ).animate()
            .fadeIn(delay: 500.ms, duration: 400.ms)
            .moveY(begin: 20, end: 0, delay: 500.ms, duration: 400.ms),
      ],
    );
  }

  Widget _buildWideContent({
    required dynamic user,
    required BinaThemeId currentBinaTheme,
  }) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 600),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Text(
                  AppLocalizations.of(context).getText('profile_title'),
                  style: BinaType.displayMd,
                ),
              ),

              // Identity card
              Padding(
                padding: const EdgeInsets.only(top: 24),
                child: _IdentityCard(
                  name: user.name,
                  email: user.email,
                  onTap: _openAccountSettings,
                ),
              ),

              // Appearance section
              _ProfileGroup(
                title: AppLocalizations.of(context).getText('profile_appearance'),
                horizontalPadding: 0,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            AppLocalizations.of(context).getText('profile_theme'),
                            style: BinaType.titleMd,
                          ),
                          GestureDetector(
                            onTap: _openAccessibility,
                            child: Text(
                              AppLocalizations.of(context).getText('profile_more_options'),
                              style: BinaType.labelMd.copyWith(
                                color: BinaColors.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _buildThemeSwatches(currentBinaTheme),
                    ],
                  ),
                ),
              ),

              // Settings section
              _ProfileGroup(
                title: AppLocalizations.of(context).getText('profile_settings'),
                horizontalPadding: 0,
                child: Column(
                  children: [
                    _HubRow(
                      icon: Icons.person_outline_rounded,
                      label: AppLocalizations.of(context).getText('profile_account'),
                      subtitle: AppLocalizations.of(context).getText('profile_account_subtitle'),
                      tone: _HubRowTone.blue,
                      onTap: _openAccountSettings,
                    ),
                    _HubRow(
                      icon: Icons.accessibility_new_rounded,
                      label: AppLocalizations.of(context).getText('profile_accessibility'),
                      subtitle: AppLocalizations.of(context).getText('profile_accessibility_subtitle'),
                      tone: _HubRowTone.aqua,
                      onTap: _openAccessibility,
                    ),
                    _HubRow(
                      icon: Icons.help_outline_rounded,
                      label: AppLocalizations.of(context).getText('profile_help_support'),
                      subtitle: AppLocalizations.of(context).getText('profile_help_subtitle'),
                      tone: _HubRowTone.coral,
                      isLast: true,
                      onTap: _openHelpSupport,
                    ),
                  ],
                ),
              ),

              // About section
              _ProfileGroup(
                title: AppLocalizations.of(context).getText('profile_about'),
                horizontalPadding: 0,
                child: _HubRow(
                  icon: Icons.info_outline_rounded,
                  label: AppLocalizations.of(context).getText('profile_about_bina'),
                  subtitle: AppLocalizations.of(context).getText('profile_version'),
                  tone: _HubRowTone.blue,
                  isLast: true,
                  onTap: () {
                    // TODO: Open about
                  },
                ),
              ),

              // Sign out button
              Padding(
                padding: const EdgeInsets.only(top: 32),
                child: SizedBox(
                  width: double.infinity,
                  child: BinaButton(
                    label: AppLocalizations.of(context).getText('profile_sign_out'),
                    variant: BinaButtonVariant.ghost,
                    onPressed: _showSignOutDialog,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildThemeSwatches(BinaThemeId currentBinaTheme) {
    return Row(
      children: [
        _ThemeSwatch(
          label: AppLocalizations.of(context).getText('theme_light'),
          themeId: BinaThemeId.light,
          isActive: currentBinaTheme == BinaThemeId.light,
          colors: [const Color(0xFFFBFAF6), const Color(0xFF1F5BFF)],
          onTap: () => _setTheme(BinaThemeId.light),
        ),
        const SizedBox(width: 8),
        _ThemeSwatch(
          label: AppLocalizations.of(context).getText('theme_dark'),
          themeId: BinaThemeId.dark,
          isActive: currentBinaTheme == BinaThemeId.dark,
          colors: [const Color(0xFF0C0F1A), const Color(0xFF5B8BFF)],
          onTap: () => _setTheme(BinaThemeId.dark),
        ),
        const SizedBox(width: 8),
        _ThemeSwatch(
          label: AppLocalizations.of(context).getText('theme_warm'),
          themeId: BinaThemeId.warm,
          isActive: currentBinaTheme == BinaThemeId.warm,
          colors: [const Color(0xFFFFF8E1), const Color(0xFFEF8B1A)],
          onTap: () => _setTheme(BinaThemeId.warm),
        ),
        const SizedBox(width: 8),
        _ThemeSwatch(
          label: AppLocalizations.of(context).getText('theme_cool'),
          themeId: BinaThemeId.cool,
          isActive: currentBinaTheme == BinaThemeId.cool,
          colors: [const Color(0xFFE3F2FD), const Color(0xFF0099B3)],
          onTap: () => _setTheme(BinaThemeId.cool),
        ),
        const SizedBox(width: 8),
        _ThemeSwatch(
          label: AppLocalizations.of(context).getText('theme_a11y'),
          themeId: BinaThemeId.deuteranopia,
          isActive: currentBinaTheme == BinaThemeId.deuteranopia,
          colors: [const Color(0xFFFFFFFF), const Color(0xFF0077BB)],
          onTap: () => _setTheme(BinaThemeId.deuteranopia),
        ),
      ],
    );
  }

  BinaThemeId _mapToBinaTheme(AppThemeType appTheme) {
    switch (appTheme) {
      case AppThemeType.light:
        return BinaThemeId.light;
      case AppThemeType.dark:
        return BinaThemeId.dark;
      case AppThemeType.warm:
        return BinaThemeId.warm;
      case AppThemeType.cool:
        return BinaThemeId.cool;
      case AppThemeType.deuteranopia:
        return BinaThemeId.deuteranopia;
    }
  }

  AppThemeType _mapToAppTheme(BinaThemeId binaTheme) {
    switch (binaTheme) {
      case BinaThemeId.light:
        return AppThemeType.light;
      case BinaThemeId.dark:
        return AppThemeType.dark;
      case BinaThemeId.warm:
        return AppThemeType.warm;
      case BinaThemeId.cool:
        return AppThemeType.cool;
      case BinaThemeId.deuteranopia:
        return AppThemeType.deuteranopia;
    }
  }

  void _setTheme(BinaThemeId themeId) {
    setState(() {
      BinaColors.use(themeId);
      AccessibilitySettingsService.instance.setThemeType(_mapToAppTheme(themeId));
    });
  }
}

// ═══════════════════════════════════════════════════════════════
// IDENTITY CARD
// ═══════════════════════════════════════════════════════════════

class _IdentityCard extends StatelessWidget {
  const _IdentityCard({
    required this.name,
    required this.email,
    required this.onTap,
  });

  final String name;
  final String email;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: BinaColors.surface,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: BinaColors.line),
          boxShadow: BinaElevation.sh2,
        ),
        child: Row(
          children: [
            BinaAvatar(
              name: name,
              size: 62,
              tone: BinaAvatarTone.blue,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name.isNotEmpty ? name : AppLocalizations.of(context).getText('profile_user'),
                    style: BinaType.titleLg,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    email.isNotEmpty ? email : AppLocalizations.of(context).getText('profile_no_email'),
                    style: BinaType.bodySm.copyWith(color: BinaColors.ink2),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    AppLocalizations.of(context).getText('profile_view_account'),
                    style: BinaType.labelSm.copyWith(color: BinaColors.primary),
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

// ═══════════════════════════════════════════════════════════════
// PROFILE GROUP
// ═══════════════════════════════════════════════════════════════

class _ProfileGroup extends StatelessWidget {
  const _ProfileGroup({
    required this.title,
    required this.child,
    this.horizontalPadding = 20,
  });

  final String title;
  final Widget child;
  final double horizontalPadding;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(horizontalPadding, 24, horizontalPadding, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 8),
            child: Text(title, style: BinaType.overline),
          ),
          Container(
            decoration: BoxDecoration(
              color: BinaColors.surface,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: BinaColors.line),
              boxShadow: BinaElevation.sh2,
            ),
            clipBehavior: Clip.antiAlias,
            child: child,
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// HUB ROW
// ═══════════════════════════════════════════════════════════════

enum _HubRowTone { blue, coral, aqua }

class _HubRow extends StatelessWidget {
  const _HubRow({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.tone,
    required this.onTap,
    this.isLast = false,
  });

  final IconData icon;
  final String label;
  final String subtitle;
  final _HubRowTone tone;
  final VoidCallback onTap;
  final bool isLast;

  Color get _backgroundColor {
    switch (tone) {
      case _HubRowTone.blue: return BinaColors.primary100;
      case _HubRowTone.coral: return BinaColors.coral100;
      case _HubRowTone.aqua: return BinaColors.aqua.withValues(alpha: 0.2);
    }
  }

  Color get _foregroundColor {
    switch (tone) {
      case _HubRowTone.blue: return BinaColors.primary700;
      case _HubRowTone.coral: return BinaColors.coral700;
      case _HubRowTone.aqua: return BinaColors.primary700;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          border: isLast
              ? null
              : Border(bottom: BorderSide(color: BinaColors.line)),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: _backgroundColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: _foregroundColor,
                size: 20,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: BinaType.titleMd),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
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
// THEME SWATCH
// ═══════════════════════════════════════════════════════════════

class _ThemeSwatch extends StatelessWidget {
  const _ThemeSwatch({
    required this.label,
    required this.themeId,
    required this.isActive,
    required this.colors,
    required this.onTap,
  });

  final String label;
  final BinaThemeId themeId;
  final bool isActive;
  final List<Color> colors;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Column(
          children: [
            AspectRatio(
              aspectRatio: 1,
              child: AnimatedContainer(
                duration: BinaMotion.d2,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: colors,
                  ),
                  borderRadius: BorderRadius.circular(14),
                  border: isActive
                      ? Border.all(color: BinaColors.primary, width: 3)
                      : null,
                  boxShadow: isActive ? BinaElevation.sh2 : BinaElevation.sh1,
                ),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: BinaType.labelSm.copyWith(
                color: isActive ? BinaColors.primary : BinaColors.ink2,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
