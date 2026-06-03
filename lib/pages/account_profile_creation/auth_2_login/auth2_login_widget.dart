import '/auth/supabase_auth/auth_util.dart';
import '/backend/sqlite/sqlite_manager.dart';
import '/backend/schema/structs/index.dart';
import '/backend/schema/enums/enums.dart';
import '/app_core/app_util.dart';
import '/bina_design/bina_design.dart';
import '/custom_code/actions/index.dart' as actions;
import '/index.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'auth2_login_model.dart';
export 'auth2_login_model.dart';

class Auth2LoginWidget extends StatefulWidget {
  const Auth2LoginWidget({super.key});

  static String routeName = 'auth_2_Login';
  static String routePath = 'auth2Login';

  @override
  State<Auth2LoginWidget> createState() => _Auth2LoginWidgetState();
}

class _Auth2LoginWidgetState extends State<Auth2LoginWidget> {
  late Auth2LoginModel _model;
  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => Auth2LoginModel());

    _model.switchValue = true;
    _model.emailAddressTextController ??= TextEditingController();
    _model.emailAddressFocusNode ??= FocusNode();

    _model.passwordTextController ??= TextEditingController();
    _model.passwordFocusNode ??= FocusNode();

    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  Future<void> _handleSignIn() async {
    Function() navigate = () {};

    if (_model.switchValue!) {
      // Cloud login via Supabase
      GoRouter.of(context).prepareAuthEvent();

      final user = await authManager.signInWithEmail(
        context,
        _model.emailAddressTextController.text,
        _model.passwordTextController.text,
      );
      if (user == null) return;

      navigate = () => context.goNamedAuth(
        MainHomeWidget.routeName,
        context.mounted,
      );
    } else {
      // Local SQLite login
      _model.hashedPW = await actions.hashPassword(
        _model.passwordTextController.text,
      );
      _model.res = await SQLiteManager.instance.loginByEmail(
        email: _model.emailAddressTextController.text,
        passwordHash: _model.hashedPW!,
      );

      if (_model.res != null && _model.res!.isNotEmpty) {
        final user = _model.res!.first;

        // Fetch family members for this user
        _model.familyMembers = await SQLiteManager.instance
            .getFamilyMembersByAccountId(accountId: user.id);

        // Find the main user (relationship = ME) to get name
        final mainMember = _model.familyMembers?.firstWhere(
          (m) => m.relationship == 'ME',
          orElse: () => _model.familyMembers!.first,
        );

        // Convert SQLite family members to FamilyMemberStruct
        final familyList = _model.familyMembers
            ?.map((m) => FamilyMemberStruct(
                  id: m.id,
                  name: m.name,
                  birthday: m.birthday != null
                      ? DateTime.fromMillisecondsSinceEpoch(m.birthday! * 1000)
                      : null,
                  lastChecked: m.lastChecked != null
                      ? DateTime.fromMillisecondsSinceEpoch(m.lastChecked! * 1000)
                      : null,
                  relationship: deserializeEnum<Relationships>(m.relationship),
                  admin: m.relationship == 'ME',
                ))
            .toList() ?? [];

        // Populate the UserSession
        AppState().UserSession = UserSessionStruct(
          userID: user.id,
          email: user.email,
          name: mainMember?.name ?? '',
          sessionId: user.id,
          family: familyList,
          familyAmount: familyList.length,
          sumChecked: 0,
          isLocalSession: true,
        );

        navigate = () => context.goNamedAuth(
          MainHomeWidget.routeName,
          context.mounted,
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Invalid email or password'),
            backgroundColor: BinaColors.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    }

    navigate();
    safeSetState(() {});
  }

  @override
  Widget build(BuildContext context) {
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
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 60),

                  // Logo
                  Center(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.flourescent_rounded,
                          color: BinaColors.primary,
                          size: 44,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          'Bina',
                          style: BinaType.displayMd,
                        ),
                      ],
                    ),
                  ).animate()
                      .fadeIn(duration: 400.ms)
                      .scale(begin: const Offset(0.9, 0.9), duration: 400.ms),

                  const SizedBox(height: 48),

                  // Welcome text
                  Text(
                    'Welcome back',
                    style: BinaType.displaySm,
                  ).animate()
                      .fadeIn(delay: 100.ms, duration: 400.ms)
                      .moveY(begin: 20, end: 0, delay: 100.ms, duration: 400.ms),

                  const SizedBox(height: 6),

                  Text(
                    'Sign in to continue to your account.',
                    style: BinaType.bodyLg.copyWith(color: BinaColors.ink2),
                  ).animate()
                      .fadeIn(delay: 150.ms, duration: 400.ms)
                      .moveY(begin: 20, end: 0, delay: 150.ms, duration: 400.ms),

                  const SizedBox(height: 32),

                  // Storage mode switch (only on mobile)
                  if (!isWeb)
                    Container(
                      decoration: BoxDecoration(
                        color: BinaColors.surface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: BinaColors.line),
                        boxShadow: BinaElevation.sh1,
                      ),
                      padding: const EdgeInsets.all(14),
                      child: Row(
                        children: [
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: _model.switchValue!
                                  ? BinaColors.primary100
                                  : BinaColors.surfaceSunken,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(
                              _model.switchValue!
                                  ? Icons.cloud_outlined
                                  : Icons.smartphone_rounded,
                              color: _model.switchValue!
                                  ? BinaColors.primary700
                                  : BinaColors.ink2,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _model.switchValue! ? 'Cloud' : 'Local',
                                  style: BinaType.titleSm,
                                ),
                                Text(
                                  _model.switchValue!
                                      ? 'Sync across devices'
                                      : 'Data stays on device',
                                  style: BinaType.bodySm.copyWith(color: BinaColors.ink3),
                                ),
                              ],
                            ),
                          ),
                          Switch(
                            value: _model.switchValue!,
                            onChanged: (value) => safeSetState(() => _model.switchValue = value),
                            activeThumbColor: BinaColors.primary,
                            activeTrackColor: BinaColors.primary100,
                            inactiveThumbColor: BinaColors.ink3,
                            inactiveTrackColor: BinaColors.line,
                          ),
                        ],
                      ),
                    ).animate()
                        .fadeIn(delay: 200.ms, duration: 400.ms)
                        .moveY(begin: 20, end: 0, delay: 200.ms, duration: 400.ms),

                  if (!isWeb) const SizedBox(height: 24),

                  // Email field
                  _AuthField(
                    label: 'Email',
                    controller: _model.emailAddressTextController!,
                    focusNode: _model.emailAddressFocusNode!,
                    keyboardType: TextInputType.emailAddress,
                    autofillHints: const [AutofillHints.email],
                    placeholder: 'your@email.com',
                  ).animate()
                      .fadeIn(delay: 250.ms, duration: 400.ms)
                      .moveY(begin: 20, end: 0, delay: 250.ms, duration: 400.ms),

                  const SizedBox(height: 16),

                  // Password field
                  _AuthField(
                    label: 'Password',
                    controller: _model.passwordTextController!,
                    focusNode: _model.passwordFocusNode!,
                    obscureText: !_model.passwordVisibility,
                    autofillHints: const [AutofillHints.password],
                    placeholder: 'Enter your password',
                    suffixIcon: IconButton(
                      icon: Icon(
                        _model.passwordVisibility
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                        color: BinaColors.ink3,
                        size: 22,
                      ),
                      onPressed: () => safeSetState(
                        () => _model.passwordVisibility = !_model.passwordVisibility,
                      ),
                    ),
                  ).animate()
                      .fadeIn(delay: 300.ms, duration: 400.ms)
                      .moveY(begin: 20, end: 0, delay: 300.ms, duration: 400.ms),

                  const SizedBox(height: 24),

                  // Sign in button
                  BinaButton(
                    label: 'Sign in',
                    variant: BinaButtonVariant.primary,
                    fullWidth: true,
                    icon: Icons.arrow_forward_rounded,
                    onPressed: _handleSignIn,
                  ).animate()
                      .fadeIn(delay: 350.ms, duration: 400.ms)
                      .moveY(begin: 20, end: 0, delay: 350.ms, duration: 400.ms),

                  const SizedBox(height: 16),

                  // Forgot password
                  Center(
                    child: TextButton(
                      onPressed: () => context.pushNamed(Auth2ForgotPasswordWidget.routeName),
                      child: Text(
                        'Forgot password?',
                        style: BinaType.labelLg.copyWith(color: BinaColors.ink2),
                      ),
                    ),
                  ).animate()
                      .fadeIn(delay: 400.ms, duration: 400.ms),

                  const SizedBox(height: 32),

                  // Create account link
                  Center(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          "Don't have an account? ",
                          style: BinaType.bodyMd.copyWith(color: BinaColors.ink2),
                        ),
                        GestureDetector(
                          onTap: () => context.pushNamed(
                            Auth2CreateWidget.routeName,
                            extra: <String, dynamic>{
                              kTransitionInfoKey: const TransitionInfo(
                                hasTransition: true,
                                transitionType: PageTransitionType.fade,
                                duration: Duration(milliseconds: 200),
                              ),
                            },
                          ),
                          child: Text(
                            'Sign up',
                            style: BinaType.bodyMd.copyWith(
                              color: BinaColors.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ).animate()
                      .fadeIn(delay: 450.ms, duration: 400.ms),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// AUTH FIELD
// ═══════════════════════════════════════════════════════════════

class _AuthField extends StatelessWidget {
  const _AuthField({
    required this.label,
    required this.controller,
    required this.focusNode,
    this.obscureText = false,
    this.keyboardType,
    this.autofillHints,
    this.placeholder,
    this.suffixIcon,
  });

  final String label;
  final TextEditingController controller;
  final FocusNode focusNode;
  final bool obscureText;
  final TextInputType? keyboardType;
  final Iterable<String>? autofillHints;
  final String? placeholder;
  final Widget? suffixIcon;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            label,
            style: BinaType.labelMd.copyWith(color: BinaColors.ink2),
          ),
        ),
        TextFormField(
          controller: controller,
          focusNode: focusNode,
          obscureText: obscureText,
          keyboardType: keyboardType,
          autofillHints: autofillHints,
          style: BinaType.bodyLg,
          decoration: InputDecoration(
            hintText: placeholder,
            hintStyle: BinaType.bodyLg.copyWith(color: BinaColors.ink3),
            filled: true,
            fillColor: BinaColors.surface,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: BinaColors.lineStrong),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: BinaColors.lineStrong),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: BinaColors.primary, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: BinaColors.error, width: 2),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: BinaColors.error, width: 2),
            ),
            suffixIcon: suffixIcon,
          ),
          cursorColor: BinaColors.primary,
        ),
      ],
    );
  }
}
