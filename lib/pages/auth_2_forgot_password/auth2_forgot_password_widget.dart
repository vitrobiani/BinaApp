import '/app_core/app_util.dart';
import '/bina_design/bina_design.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'auth2_forgot_password_model.dart';
export 'auth2_forgot_password_model.dart';

class Auth2ForgotPasswordWidget extends StatefulWidget {
  const Auth2ForgotPasswordWidget({super.key});

  static String routeName = 'auth_2_ForgotPassword';
  static String routePath = 'auth2ForgotPassword';

  @override
  State<Auth2ForgotPasswordWidget> createState() =>
      _Auth2ForgotPasswordWidgetState();
}

class _Auth2ForgotPasswordWidgetState extends State<Auth2ForgotPasswordWidget> {
  late Auth2ForgotPasswordModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => Auth2ForgotPasswordModel());

    _model.emailAddressTextController ??= TextEditingController();
    _model.emailAddressFocusNode ??= FocusNode();

    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
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
        backgroundColor: BinaColors.surface,
        body: Container(
          height: double.infinity,
          decoration: BoxDecoration(
            gradient: BinaColors.gradHero,
          ),
          alignment: Alignment.topCenter,
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo
                Padding(
                  padding: const EdgeInsets.only(top: 80, bottom: 32),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(
                          Icons.flourescent_rounded,
                          color: Colors.white,
                          size: 32,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Bina',
                        style: BinaType.displaySm.copyWith(
                          color: Colors.white,
                          fontSize: 48,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
                // Card
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Container(
                    width: double.infinity,
                    constraints: const BoxConstraints(maxWidth: 500),
                    decoration: BoxDecoration(
                      color: BinaColors.surface,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: BinaElevation.sh3,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(28),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Back button
                          BinaIconButton(
                            icon: Icons.arrow_back_rounded,
                            onPressed: () => context.safePop(),
                          ),
                          const SizedBox(height: 16),
                          // Title
                          Text(
                            'Forgot Password',
                            style: BinaType.displaySm,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Please fill out your email below and we will send you a link to reset your password.',
                            style: BinaType.bodyMd.copyWith(color: BinaColors.ink2),
                          ),
                          const SizedBox(height: 28),
                          // Email field
                          Text(
                            'Email',
                            style: BinaType.labelMd.copyWith(color: BinaColors.ink2),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            decoration: BoxDecoration(
                              color: BinaColors.surfaceSunken,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: BinaColors.line),
                            ),
                            child: TextFormField(
                              controller: _model.emailAddressTextController,
                              focusNode: _model.emailAddressFocusNode,
                              autofocus: true,
                              autofillHints: const [AutofillHints.email],
                              style: BinaType.bodyLg,
                              decoration: InputDecoration(
                                hintText: 'Enter your email',
                                hintStyle: BinaType.bodyLg.copyWith(color: BinaColors.ink3),
                                prefixIcon: Icon(Icons.email_outlined, color: BinaColors.ink2),
                                border: InputBorder.none,
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 14,
                                ),
                              ),
                              keyboardType: TextInputType.emailAddress,
                              validator: _model.emailAddressTextControllerValidator
                                  .asValidator(context),
                            ),
                          ),
                          const SizedBox(height: 24),
                          // Submit button
                          SizedBox(
                            width: double.infinity,
                            child: BinaButton(
                              label: 'Send Reset Link',
                              icon: Icons.send_rounded,
                              variant: BinaButtonVariant.primary,
                              onPressed: () {
                                // TODO: Implement password reset
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: const Text('Password reset link sent!'),
                                    backgroundColor: BinaColors.success,
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ).animate()
                    .fadeIn(duration: 400.ms)
                    .moveY(begin: 40, end: 0, duration: 400.ms)
                    .scale(
                      begin: const Offset(0.95, 0.95),
                      end: const Offset(1, 1),
                      duration: 400.ms,
                    ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
