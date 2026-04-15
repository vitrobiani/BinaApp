import '/app_core/app_animations.dart';
import '/app_core/app_theme.dart';
import '/app_core/app_util.dart';
import '/pages/account_profile_creation/edit_profile_auth_2/edit_profile_auth2_widget.dart';
import '/index.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
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

class _Auth2CreateProfileWidgetState extends State<Auth2CreateProfileWidget>
    with TickerProviderStateMixin {
  late Auth2CreateProfileModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  final animationsMap = <String, AnimationInfo>{};

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => Auth2CreateProfileModel());

    animationsMap.addAll({
      'containerOnPageLoadAnimation': AnimationInfo(
        trigger: AnimationTrigger.onPageLoad,
        effectsBuilder: () => [
          VisibilityEffect(duration: 1.ms),
          FadeEffect(
            curve: Curves.easeInOut,
            delay: 0.0.ms,
            duration: 300.0.ms,
            begin: 0.0,
            end: 1.0,
          ),
          MoveEffect(
            curve: Curves.easeInOut,
            delay: 0.0.ms,
            duration: 300.0.ms,
            begin: Offset(0.0, 140.0),
            end: Offset(0.0, 0.0),
          ),
          ScaleEffect(
            curve: Curves.easeInOut,
            delay: 0.0.ms,
            duration: 300.0.ms,
            begin: Offset(0.9, 0.9),
            end: Offset(1.0, 1.0),
          ),
          TiltEffect(
            curve: Curves.easeInOut,
            delay: 0.0.ms,
            duration: 300.0.ms,
            begin: Offset(-0.349, 0),
            end: Offset(0, 0),
          ),
        ],
      ),
    });

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
        backgroundColor: AppTheme.of(context).secondaryBackground,
        body: Container(
          height: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppTheme.of(context).primary,
                AppTheme.of(context).tertiary
              ],
              stops: [0.0, 1.0],
              begin: AlignmentDirectional(0.87, -1.0),
              end: AlignmentDirectional(-0.87, 1.0),
            ),
          ),
          alignment: AlignmentDirectional(0.0, -1.0),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: EdgeInsetsDirectional.fromSTEB(0.0, 70.0, 0.0, 32.0),
                  child: Container(
                    width: 200.0,
                    height: 70.0,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16.0),
                    ),
                    alignment: AlignmentDirectional(0.0, 0.0),
                    child: Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Padding(
                          padding: EdgeInsetsDirectional.fromSTEB(
                              0.0, 0.0, 12.0, 0.0),
                          child: Icon(
                            Icons.flourescent_rounded,
                            color: AppTheme.of(context).info,
                            size: 50.0,
                          ),
                        ),
                        Text(
                          AppLocalizations.of(context).getText(
                            '7g2ljvog' /* Bina  */,
                          ),
                          style: AppTheme.of(context)
                              .displayMedium
                              .override(
                                font: GoogleFonts.readexPro(
                                  fontWeight: FontWeight.w600,
                                  fontStyle: AppTheme.of(context)
                                      .displayMedium
                                      .fontStyle,
                                ),
                                fontSize: 55.0,
                                letterSpacing: 0.0,
                                fontWeight: FontWeight.w600,
                                fontStyle: AppTheme.of(context)
                                    .displayMedium
                                    .fontStyle,
                              ),
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Container(
                    width: double.infinity,
                    constraints: BoxConstraints(
                      maxWidth: 570.0,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.of(context).secondaryBackground,
                      boxShadow: [
                        BoxShadow(
                          blurRadius: 4.0,
                          color: Color(0x33000000),
                          offset: Offset(
                            0.0,
                            2.0,
                          ),
                        )
                      ],
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    child: Padding(
                      padding:
                          EdgeInsetsDirectional.fromSTEB(0.0, 24.0, 0.0, 24.0),
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
                  ).animateOnPageLoad(
                      animationsMap['containerOnPageLoadAnimation']!),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
