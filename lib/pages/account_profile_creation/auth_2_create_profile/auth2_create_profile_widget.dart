import '/bina_design/bina_design.dart';
import '/app_core/app_util.dart';
import '/pages/account_profile_creation/edit_profile_auth_2/edit_profile_auth2_widget.dart';
import '/index.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'auth2_create_profile_model.dart';
export 'auth2_create_profile_model.dart';

class Auth2CreateProfileWidget extends StatefulWidget {
  const Auth2CreateProfileWidget({super.key});

  static String routeName = 'auth_2_createProfile';
  static String routePath = 'auth2CreateProfile';

  @override
  State<Auth2CreateProfileWidget> createState() =>
      _Auth2CreateProfileWidgetState();
}

class _Auth2CreateProfileWidgetState extends State<Auth2CreateProfileWidget> {
  late Auth2CreateProfileModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => Auth2CreateProfileModel());
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
                  padding: const EdgeInsets.only(top: 70, bottom: 32),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(
                          Icons.flourescent_rounded,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        AppLocalizations.of(context).getText('7g2ljvog'),
                        style: BinaType.displaySm.copyWith(
                          color: Colors.white,
                          fontSize: 55,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                // Card
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Container(
                    width: double.infinity,
                    constraints: const BoxConstraints(maxWidth: 570),
                    decoration: BoxDecoration(
                      color: BinaColors.surface,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: BinaElevation.sh3,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 24),
                      child: wrapWithModel(
                        model: _model.editProfileAuth2Model,
                        updateCallback: () => safeSetState(() {}),
                        child: EditProfileAuth2Widget(
                          title: 'Create Profile',
                          confirmButtonText: 'Save & Continue',
                          navigateAction: () async {
                            context.pushNamed(Auth2ProfileWidget.routeName);
                          },
                        ),
                      ),
                    ),
                  ),
                ).animate()
                    .fadeIn(duration: 300.ms)
                    .moveY(begin: 140, end: 0, duration: 300.ms)
                    .scale(
                      begin: const Offset(0.9, 0.9),
                      end: const Offset(1, 1),
                      duration: 300.ms,
                    ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
