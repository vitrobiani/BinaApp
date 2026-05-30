import '/bina_design/bina_design.dart';
import '/app_core/app_util.dart';
import '/index.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'auth2_profile_model.dart';
export 'auth2_profile_model.dart';

class Auth2ProfileWidget extends StatefulWidget {
  const Auth2ProfileWidget({super.key});

  static String routeName = 'auth_2_Profile';
  static String routePath = 'auth2Profile';

  @override
  State<Auth2ProfileWidget> createState() => _Auth2ProfileWidgetState();
}

class _Auth2ProfileWidgetState extends State<Auth2ProfileWidget> {
  late Auth2ProfileModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => Auth2ProfileModel());
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
        body: Center(
          child: Container(
            width: double.infinity,
            constraints: const BoxConstraints(maxWidth: 770),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header with avatar
                  SizedBox(
                    height: 180,
                    child: Stack(
                      children: [
                        // Gradient background
                        Container(
                          width: double.infinity,
                          height: 140,
                          margin: const EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(
                            gradient: BinaColors.gradHero,
                          ),
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.transparent,
                                  BinaColors.surface,
                                ],
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                              ),
                            ),
                          ),
                        ).animate()
                            .fadeIn(duration: 400.ms)
                            .scale(
                              begin: const Offset(3, 3),
                              end: const Offset(1, 1),
                              duration: 400.ms,
                            ),
                        // Avatar
                        Align(
                          alignment: Alignment.bottomLeft,
                          child: Padding(
                            padding: const EdgeInsets.only(left: 24),
                            child: Container(
                              width: 90,
                              height: 90,
                              decoration: BoxDecoration(
                                color: BinaColors.primary100,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: BinaColors.primary,
                                  width: 2,
                                ),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(4),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(50),
                                  child: CachedNetworkImage(
                                    fadeInDuration: const Duration(milliseconds: 500),
                                    fadeOutDuration: const Duration(milliseconds: 500),
                                    imageUrl:
                                        'https://images.unsplash.com/photo-1489980557514-251d61e3eeb6?ixlib=rb-4.0.3&ixid=MnwxMjA3fDB8MHxzZWFyY2h8OTZ8fHByb2ZpbGV8ZW58MHx8MHx8&auto=format&fit=crop&w=900&q=60',
                                    width: 100,
                                    height: 100,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Name
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 12, 0, 0),
                    child: Text(
                      AppLocalizations.of(context).getText('mv3aa31t'),
                      style: BinaType.displaySm,
                    ),
                  ),
                  // Email
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 4, 0, 16),
                    child: Text(
                      AppLocalizations.of(context).getText('0ytdwza8'),
                      style: BinaType.labelLg.copyWith(color: BinaColors.primary),
                    ),
                  ),
                  // Section: Your Account
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 4, 0, 0),
                    child: Text(
                      AppLocalizations.of(context).getText('coygd922'),
                      style: BinaType.labelMd.copyWith(color: BinaColors.ink2),
                    ),
                  ),
                  // Edit Profile row
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                    child: _SettingsRow(
                      icon: Icons.account_circle_outlined,
                      label: AppLocalizations.of(context).getText('8ctbqg92'),
                      onTap: () => context.pushNamed(Auth2EditProfileWidget.routeName),
                    ),
                  ),
                  // Section: App Settings
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 16, 0, 0),
                    child: Text(
                      AppLocalizations.of(context).getText('ue4tdodf'),
                      style: BinaType.labelMd.copyWith(color: BinaColors.ink2),
                    ),
                  ),
                  // Support row
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                    child: _SettingsRow(
                      icon: Icons.help_outline_rounded,
                      label: AppLocalizations.of(context).getText('ljm3zuye'),
                      onTap: () {},
                    ),
                  ),
                  // Terms row
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                    child: _SettingsRow(
                      icon: Icons.privacy_tip_rounded,
                      label: AppLocalizations.of(context).getText('sl7qwp3g'),
                      onTap: () {},
                    ),
                  ),
                  // Logout button
                  Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: Center(
                      child: BinaButton(
                        label: AppLocalizations.of(context).getText('ud37xux6'),
                        variant: BinaButtonVariant.secondary,
                        onPressed: () {
                          // Logout action
                        },
                      ),
                    ),
                  ).animate()
                      .fadeIn(delay: 400.ms, duration: 600.ms)
                      .moveY(begin: 60, end: 0, delay: 400.ms, duration: 600.ms),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SettingsRow extends StatelessWidget {
  const _SettingsRow({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 60,
        decoration: BoxDecoration(
          color: BinaColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: BinaColors.line),
          boxShadow: BinaElevation.sh1,
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Icon(icon, color: BinaColors.ink2, size: 24),
              const SizedBox(width: 12),
              Expanded(
                child: Text(label, style: BinaType.labelLg),
              ),
              Icon(Icons.arrow_forward_ios, color: BinaColors.ink3, size: 18),
            ],
          ),
        ),
      ),
    );
  }
}
