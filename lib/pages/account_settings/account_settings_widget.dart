import '/auth/supabase_auth/auth_util.dart';
import '/app_core/app_util.dart';
import '/bina_design/bina_design.dart';
import '/index.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'account_settings_model.dart';

export 'account_settings_model.dart';

class AccountSettingsWidget extends StatefulWidget {
  const AccountSettingsWidget({super.key});

  static String routeName = 'AccountSettings';
  static String routePath = 'accountSettings';

  @override
  State<AccountSettingsWidget> createState() => _AccountSettingsWidgetState();
}

class _AccountSettingsWidgetState extends State<AccountSettingsWidget> {
  late AccountSettingsModel _model;
  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => AccountSettingsModel());

    _model.nameTextController ??= TextEditingController();
    _model.nameFocusNode ??= FocusNode();

    _model.emailTextController ??= TextEditingController();
    _model.emailFocusNode ??= FocusNode();

    _model.currentPasswordTextController ??= TextEditingController();
    _model.currentPasswordFocusNode ??= FocusNode();

    _model.newPasswordTextController ??= TextEditingController();
    _model.newPasswordFocusNode ??= FocusNode();

    _model.confirmPasswordTextController ??= TextEditingController();
    _model.confirmPasswordFocusNode ??= FocusNode();

    // Pre-fill with current user data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = AppState().UserSession;
      _model.nameTextController?.text = user.name;
      _model.emailTextController?.text = user.email;
      safeSetState(() {});
    });
  }

  @override
  void dispose() {
    _model.maybeDispose();
    super.dispose();
  }

  Future<void> _updateProfile() async {
    if (_model.nameTextController?.text.isEmpty ?? true) {
      _showErrorSnackbar(AppLocalizations.of(context).getText('account_name_required'));
      return;
    }

    setState(() => _model.isUpdatingProfile = true);

    try {
      // Update user profile in local storage
      AppState().update(() {
        AppState().updateUserSessionStruct((session) {
          session.name = _model.nameTextController!.text.trim();
        });
      });

      if (mounted) {
        _showSuccessSnackbar(AppLocalizations.of(context).getText('account_profile_updated'));
      }
    } catch (e) {
      if (mounted) {
        _showErrorSnackbar(AppLocalizations.of(context).getText('account_update_error'));
      }
    } finally {
      if (mounted) {
        setState(() => _model.isUpdatingProfile = false);
      }
    }
  }

  Future<void> _changePassword() async {
    final currentPassword = _model.currentPasswordTextController?.text ?? '';
    final newPassword = _model.newPasswordTextController?.text ?? '';
    final confirmPassword = _model.confirmPasswordTextController?.text ?? '';

    if (currentPassword.isEmpty) {
      _showErrorSnackbar(AppLocalizations.of(context).getText('account_current_password_required'));
      return;
    }

    if (newPassword.isEmpty) {
      _showErrorSnackbar(AppLocalizations.of(context).getText('account_new_password_required'));
      return;
    }

    if (newPassword.length < 6) {
      _showErrorSnackbar(AppLocalizations.of(context).getText('account_password_min_length'));
      return;
    }

    if (newPassword != confirmPassword) {
      _showErrorSnackbar(AppLocalizations.of(context).getText('account_passwords_dont_match'));
      return;
    }

    setState(() => _model.isChangingPassword = true);

    try {
      await authManager.updatePassword(
        newPassword: newPassword,
        context: context,
      );

      // Clear password fields
      _model.currentPasswordTextController?.clear();
      _model.newPasswordTextController?.clear();
      _model.confirmPasswordTextController?.clear();

      if (mounted) {
        _showSuccessSnackbar(AppLocalizations.of(context).getText('account_password_changed'));
      }
    } catch (e) {
      if (mounted) {
        _showErrorSnackbar(AppLocalizations.of(context).getText('account_password_change_error'));
      }
    } finally {
      if (mounted) {
        setState(() => _model.isChangingPassword = false);
      }
    }
  }

  void _showDeleteAccountDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: BinaColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(BinaRadius.lg),
        ),
        title: Text(
          AppLocalizations.of(context).getText('account_delete_title'),
          style: BinaType.headlineSm,
        ),
        content: Text(
          AppLocalizations.of(context).getText('account_delete_warning'),
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
            onPressed: () {
              Navigator.of(ctx).pop();
              _deleteAccount();
            },
            child: Text(
              AppLocalizations.of(context).getText('account_delete_confirm'),
              style: BinaType.labelLg.copyWith(color: BinaColors.error),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteAccount() async {
    setState(() => _model.isDeletingAccount = true);

    try {
      await authManager.deleteUser(context);

      if (mounted) {
        GoRouter.of(context).prepareAuthEvent();
        await authManager.signOut();
        GoRouter.of(context).clearRedirectLocation();
        context.goNamedAuth(Auth2LoginWidget.routeName, context.mounted);
      }
    } catch (e) {
      if (mounted) {
        _showErrorSnackbar(AppLocalizations.of(context).getText('account_delete_error'));
        setState(() => _model.isDeletingAccount = false);
      }
    }
  }

  void _showSuccessSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: BinaColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: BinaColors.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
        body: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.only(
              top: isWide ? 24 : 12,
              bottom: isWide ? 40 : 40,
            ),
            child: isWide
                ? _buildWideContent()
                : _buildPhoneContent(),
          ),
        ),
      ),
    );
  }

  Widget _buildPhoneContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
          child: Row(
            children: [
              BinaIconButton(
                icon: Icons.chevron_left_rounded,
                onPressed: () => Navigator.of(context).pop(),
              ),
              Expanded(
                child: Center(
                  child: Text(
                    AppLocalizations.of(context).getText('account_title'),
                    style: BinaType.titleMd,
                  ),
                ),
              ),
              const SizedBox(width: 44),
            ],
          ),
        ).animate()
            .fadeIn(duration: 300.ms)
            .moveY(begin: -10, end: 0, duration: 300.ms),

        const SizedBox(height: 16),

        // Profile Section
        _SettingsSection(
          title: AppLocalizations.of(context).getText('account_profile_info'),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              children: [
                _buildTextField(
                  controller: _model.nameTextController!,
                  focusNode: _model.nameFocusNode!,
                  label: AppLocalizations.of(context).getText('account_name'),
                  hint: AppLocalizations.of(context).getText('account_name_hint'),
                  icon: Icons.person_outline_rounded,
                ),
                const SizedBox(height: 12),
                _buildTextField(
                  controller: _model.emailTextController!,
                  focusNode: _model.emailFocusNode!,
                  label: AppLocalizations.of(context).getText('account_email'),
                  hint: AppLocalizations.of(context).getText('account_email_hint'),
                  icon: Icons.email_outlined,
                  enabled: false, // Email can't be changed
                ),
                const SizedBox(height: 16),
                BinaButton(
                  label: _model.isUpdatingProfile
                      ? AppLocalizations.of(context).getText('account_saving')
                      : AppLocalizations.of(context).getText('account_save_changes'),
                  variant: BinaButtonVariant.primary,
                  fullWidth: true,
                  onPressed: _model.isUpdatingProfile ? null : _updateProfile,
                ),
              ],
            ),
          ),
        ).animate()
            .fadeIn(delay: 100.ms, duration: 400.ms)
            .moveY(begin: 20, end: 0, delay: 100.ms, duration: 400.ms),

        // Password Section
        _SettingsSection(
          title: AppLocalizations.of(context).getText('account_change_password'),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              children: [
                _buildPasswordField(
                  controller: _model.currentPasswordTextController!,
                  focusNode: _model.currentPasswordFocusNode!,
                  label: AppLocalizations.of(context).getText('account_current_password'),
                  isVisible: _model.currentPasswordVisibility,
                  onToggleVisibility: () => setState(() =>
                      _model.currentPasswordVisibility = !_model.currentPasswordVisibility),
                ),
                const SizedBox(height: 12),
                _buildPasswordField(
                  controller: _model.newPasswordTextController!,
                  focusNode: _model.newPasswordFocusNode!,
                  label: AppLocalizations.of(context).getText('account_new_password'),
                  isVisible: _model.newPasswordVisibility,
                  onToggleVisibility: () => setState(() =>
                      _model.newPasswordVisibility = !_model.newPasswordVisibility),
                ),
                const SizedBox(height: 12),
                _buildPasswordField(
                  controller: _model.confirmPasswordTextController!,
                  focusNode: _model.confirmPasswordFocusNode!,
                  label: AppLocalizations.of(context).getText('account_confirm_password'),
                  isVisible: _model.confirmPasswordVisibility,
                  onToggleVisibility: () => setState(() =>
                      _model.confirmPasswordVisibility = !_model.confirmPasswordVisibility),
                ),
                const SizedBox(height: 16),
                BinaButton(
                  label: _model.isChangingPassword
                      ? AppLocalizations.of(context).getText('account_changing')
                      : AppLocalizations.of(context).getText('account_update_password'),
                  variant: BinaButtonVariant.secondary,
                  fullWidth: true,
                  onPressed: _model.isChangingPassword ? null : _changePassword,
                ),
              ],
            ),
          ),
        ).animate()
            .fadeIn(delay: 200.ms, duration: 400.ms)
            .moveY(begin: 20, end: 0, delay: 200.ms, duration: 400.ms),

        // Danger Zone
        _SettingsSection(
          title: AppLocalizations.of(context).getText('account_danger_zone'),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppLocalizations.of(context).getText('account_delete_description'),
                  style: BinaType.bodySm.copyWith(color: BinaColors.ink2),
                ),
                const SizedBox(height: 12),
                BinaButton(
                  label: _model.isDeletingAccount
                      ? AppLocalizations.of(context).getText('account_deleting')
                      : AppLocalizations.of(context).getText('account_delete_account'),
                  variant: BinaButtonVariant.ghost,
                  fullWidth: true,
                  onPressed: _model.isDeletingAccount ? null : _showDeleteAccountDialog,
                ),
              ],
            ),
          ),
        ).animate()
            .fadeIn(delay: 300.ms, duration: 400.ms)
            .moveY(begin: 20, end: 0, delay: 300.ms, duration: 400.ms),
      ],
    );
  }

  Widget _buildWideContent() {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 600),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    BinaIconButton(
                      icon: Icons.chevron_left_rounded,
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      AppLocalizations.of(context).getText('account_title'),
                      style: BinaType.displaySm,
                    ),
                  ],
                ),
              ),

              // Profile Section
              _SettingsSection(
                title: AppLocalizations.of(context).getText('account_profile_info'),
                horizontalPadding: 0,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: _buildTextField(
                              controller: _model.nameTextController!,
                              focusNode: _model.nameFocusNode!,
                              label: AppLocalizations.of(context).getText('account_name'),
                              hint: AppLocalizations.of(context).getText('account_name_hint'),
                              icon: Icons.person_outline_rounded,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildTextField(
                              controller: _model.emailTextController!,
                              focusNode: _model.emailFocusNode!,
                              label: AppLocalizations.of(context).getText('account_email'),
                              hint: AppLocalizations.of(context).getText('account_email_hint'),
                              icon: Icons.email_outlined,
                              enabled: false,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Align(
                        alignment: Alignment.centerRight,
                        child: SizedBox(
                          width: 200,
                          child: BinaButton(
                            label: _model.isUpdatingProfile
                                ? AppLocalizations.of(context).getText('account_saving')
                                : AppLocalizations.of(context).getText('account_save_changes'),
                            variant: BinaButtonVariant.primary,
                            onPressed: _model.isUpdatingProfile ? null : _updateProfile,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Password Section
              _SettingsSection(
                title: AppLocalizations.of(context).getText('account_change_password'),
                horizontalPadding: 0,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      _buildPasswordField(
                        controller: _model.currentPasswordTextController!,
                        focusNode: _model.currentPasswordFocusNode!,
                        label: AppLocalizations.of(context).getText('account_current_password'),
                        isVisible: _model.currentPasswordVisibility,
                        onToggleVisibility: () => setState(() =>
                            _model.currentPasswordVisibility = !_model.currentPasswordVisibility),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: _buildPasswordField(
                              controller: _model.newPasswordTextController!,
                              focusNode: _model.newPasswordFocusNode!,
                              label: AppLocalizations.of(context).getText('account_new_password'),
                              isVisible: _model.newPasswordVisibility,
                              onToggleVisibility: () => setState(() =>
                                  _model.newPasswordVisibility = !_model.newPasswordVisibility),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildPasswordField(
                              controller: _model.confirmPasswordTextController!,
                              focusNode: _model.confirmPasswordFocusNode!,
                              label: AppLocalizations.of(context).getText('account_confirm_password'),
                              isVisible: _model.confirmPasswordVisibility,
                              onToggleVisibility: () => setState(() =>
                                  _model.confirmPasswordVisibility = !_model.confirmPasswordVisibility),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Align(
                        alignment: Alignment.centerRight,
                        child: SizedBox(
                          width: 200,
                          child: BinaButton(
                            label: _model.isChangingPassword
                                ? AppLocalizations.of(context).getText('account_changing')
                                : AppLocalizations.of(context).getText('account_update_password'),
                            variant: BinaButtonVariant.secondary,
                            onPressed: _model.isChangingPassword ? null : _changePassword,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Danger Zone
              _SettingsSection(
                title: AppLocalizations.of(context).getText('account_danger_zone'),
                horizontalPadding: 0,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          AppLocalizations.of(context).getText('account_delete_description'),
                          style: BinaType.bodyMd.copyWith(color: BinaColors.ink2),
                        ),
                      ),
                      const SizedBox(width: 24),
                      SizedBox(
                        width: 180,
                        child: BinaButton(
                          label: _model.isDeletingAccount
                              ? AppLocalizations.of(context).getText('account_deleting')
                              : AppLocalizations.of(context).getText('account_delete_account'),
                          variant: BinaButtonVariant.ghost,
                          onPressed: _model.isDeletingAccount ? null : _showDeleteAccountDialog,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required FocusNode focusNode,
    required String label,
    required String hint,
    required IconData icon,
    bool enabled = true,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: enabled ? BinaColors.surfaceSunken : BinaColors.surfaceSunken.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: BinaColors.line, width: 1.5),
      ),
      child: TextFormField(
        controller: controller,
        focusNode: focusNode,
        enabled: enabled,
        style: BinaType.bodyMd.copyWith(
          color: enabled ? BinaColors.ink : BinaColors.ink3,
        ),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: BinaType.labelMd.copyWith(color: BinaColors.ink2),
          hintText: hint,
          hintStyle: BinaType.bodyMd.copyWith(color: BinaColors.ink3),
          prefixIcon: Icon(icon, color: BinaColors.ink3, size: 20),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
        cursorColor: BinaColors.primary,
      ),
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required FocusNode focusNode,
    required String label,
    required bool isVisible,
    required VoidCallback onToggleVisibility,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: BinaColors.surfaceSunken,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: BinaColors.line, width: 1.5),
      ),
      child: TextFormField(
        controller: controller,
        focusNode: focusNode,
        obscureText: !isVisible,
        style: BinaType.bodyMd,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: BinaType.labelMd.copyWith(color: BinaColors.ink2),
          prefixIcon: Icon(Icons.lock_outline_rounded, color: BinaColors.ink3, size: 20),
          suffixIcon: IconButton(
            icon: Icon(
              isVisible ? Icons.visibility_off_outlined : Icons.visibility_outlined,
              color: BinaColors.ink3,
              size: 20,
            ),
            onPressed: onToggleVisibility,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
        cursorColor: BinaColors.primary,
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// SETTINGS SECTION
// ═══════════════════════════════════════════════════════════════

class _SettingsSection extends StatelessWidget {
  const _SettingsSection({
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
      padding: EdgeInsets.fromLTRB(horizontalPadding, 20, horizontalPadding, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 8),
            child: Text(
              title,
              style: BinaType.overline.copyWith(
                color: BinaColors.ink3,
                letterSpacing: 0.8,
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: BinaColors.surface,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: BinaColors.line),
              boxShadow: BinaElevation.sh2,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: child,
            ),
          ),
        ],
      ),
    );
  }
}
