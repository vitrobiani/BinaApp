import '/app_core/app_animations.dart';
import '/app_core/app_theme.dart';
import '/app_core/app_util.dart';
import '/app_core/app_widgets.dart';
import '/index.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'auth2_profile_model.dart';
export 'auth2_profile_model.dart';

class Auth2ProfileWidget extends StatefulWidget {
  const Auth2ProfileWidget({super.key});

  static String routeName = 'auth_2_Profile';
  static String routePath = 'auth2Profile';

  @override
  State<Auth2ProfileWidget> createState() => _Auth2ProfileWidgetState();
}

class _Auth2ProfileWidgetState extends State<Auth2ProfileWidget>
    with TickerProviderStateMixin {
  late Auth2ProfileModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  final animationsMap = <String, AnimationInfo>{};

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => Auth2ProfileModel());

    animationsMap.addAll({
      'containerOnPageLoadAnimation': AnimationInfo(
        trigger: AnimationTrigger.onPageLoad,
        effectsBuilder: () => [
          VisibilityEffect(duration: 1.ms),
          FadeEffect(
            curve: Curves.easeInOut,
            delay: 0.0.ms,
            duration: 400.0.ms,
            begin: 0.0,
            end: 1.0,
          ),
          ScaleEffect(
            curve: Curves.easeInOut,
            delay: 0.0.ms,
            duration: 400.0.ms,
            begin: Offset(3.0, 3.0),
            end: Offset(1.0, 1.0),
          ),
        ],
      ),
      'buttonOnPageLoadAnimation': AnimationInfo(
        trigger: AnimationTrigger.onPageLoad,
        effectsBuilder: () => [
          VisibilityEffect(duration: 400.ms),
          FadeEffect(
            curve: Curves.easeInOut,
            delay: 400.0.ms,
            duration: 600.0.ms,
            begin: 0.0,
            end: 1.0,
          ),
          MoveEffect(
            curve: Curves.easeInOut,
            delay: 400.0.ms,
            duration: 600.0.ms,
            begin: Offset(0.0, 60.0),
            end: Offset(0.0, 0.0),
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
        body: Align(
          alignment: AlignmentDirectional(0.0, -1.0),
          child: Container(
            width: double.infinity,
            constraints: BoxConstraints(
              maxWidth: 770.0,
            ),
            decoration: BoxDecoration(
              color: AppTheme.of(context).secondaryBackground,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 180.0,
                  child: Stack(
                    children: [
                      Padding(
                        padding:
                            EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 16.0),
                        child: Container(
                          width: double.infinity,
                          height: 140.0,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                AppTheme.of(context).primary,
                                AppTheme.of(context).error,
                                AppTheme.of(context).tertiary
                              ],
                              stops: [0.0, 0.5, 1.0],
                              begin: AlignmentDirectional(-1.0, -1.0),
                              end: AlignmentDirectional(1.0, 1.0),
                            ),
                          ),
                          child: Container(
                            width: 100.0,
                            height: 200.0,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Color(0x00FFFFFF),
                                  AppTheme.of(context)
                                      .secondaryBackground
                                ],
                                stops: [0.0, 1.0],
                                begin: AlignmentDirectional(0.0, -1.0),
                                end: AlignmentDirectional(0, 1.0),
                              ),
                            ),
                          ),
                        ).animateOnPageLoad(
                            animationsMap['containerOnPageLoadAnimation']!),
                      ),
                      Align(
                        alignment: AlignmentDirectional(-1.0, 1.0),
                        child: Padding(
                          padding: EdgeInsetsDirectional.fromSTEB(
                              24.0, 0.0, 0.0, 0.0),
                          child: Container(
                            width: 90.0,
                            height: 90.0,
                            decoration: BoxDecoration(
                              color: AppTheme.of(context).accent2,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: AppTheme.of(context).secondary,
                                width: 2.0,
                              ),
                            ),
                            child: Padding(
                              padding: EdgeInsets.all(4.0),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(50.0),
                                child: CachedNetworkImage(
                                  fadeInDuration: Duration(milliseconds: 500),
                                  fadeOutDuration: Duration(milliseconds: 500),
                                  imageUrl:
                                      'https://images.unsplash.com/photo-1489980557514-251d61e3eeb6?ixlib=rb-4.0.3&ixid=MnwxMjA3fDB8MHxzZWFyY2h8OTZ8fHByb2ZpbGV8ZW58MHx8MHx8&auto=format&fit=crop&w=900&q=60',
                                  width: 100.0,
                                  height: 100.0,
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
                Padding(
                  padding: EdgeInsetsDirectional.fromSTEB(24.0, 12.0, 0.0, 0.0),
                  child: Text(
                    AppLocalizations.of(context).getText(
                      'mv3aa31t' /*  */,
                    ),
                    style: AppTheme.of(context).displaySmall.override(
                          font: GoogleFonts.readexPro(
                            fontWeight: AppTheme.of(context)
                                .displaySmall
                                .fontWeight,
                            fontStyle: AppTheme.of(context)
                                .displaySmall
                                .fontStyle,
                          ),
                          letterSpacing: 0.0,
                          fontWeight: AppTheme.of(context)
                              .displaySmall
                              .fontWeight,
                          fontStyle: AppTheme.of(context)
                              .displaySmall
                              .fontStyle,
                        ),
                  ),
                ),
                Padding(
                  padding: EdgeInsetsDirectional.fromSTEB(24.0, 4.0, 0.0, 16.0),
                  child: Text(
                    AppLocalizations.of(context).getText(
                      '0ytdwza8' /*  */,
                    ),
                    style: AppTheme.of(context).labelLarge.override(
                          font: GoogleFonts.inter(
                            fontWeight: AppTheme.of(context)
                                .labelLarge
                                .fontWeight,
                            fontStyle: AppTheme.of(context)
                                .labelLarge
                                .fontStyle,
                          ),
                          color: AppTheme.of(context).primary,
                          letterSpacing: 0.0,
                          fontWeight: AppTheme.of(context)
                              .labelLarge
                              .fontWeight,
                          fontStyle:
                              AppTheme.of(context).labelLarge.fontStyle,
                        ),
                  ),
                ),
                Padding(
                  padding: EdgeInsetsDirectional.fromSTEB(24.0, 4.0, 0.0, 0.0),
                  child: Text(
                    AppLocalizations.of(context).getText(
                      'coygd922' /* Your Account */,
                    ),
                    style: AppTheme.of(context).labelMedium.override(
                          font: GoogleFonts.inter(
                            fontWeight: AppTheme.of(context)
                                .labelMedium
                                .fontWeight,
                            fontStyle: AppTheme.of(context)
                                .labelMedium
                                .fontStyle,
                          ),
                          letterSpacing: 0.0,
                          fontWeight: AppTheme.of(context)
                              .labelMedium
                              .fontWeight,
                          fontStyle: AppTheme.of(context)
                              .labelMedium
                              .fontStyle,
                        ),
                  ),
                ),
                Padding(
                  padding:
                      EdgeInsetsDirectional.fromSTEB(16.0, 12.0, 16.0, 0.0),
                  child: InkWell(
                    splashColor: Colors.transparent,
                    focusColor: Colors.transparent,
                    hoverColor: Colors.transparent,
                    highlightColor: Colors.transparent,
                    onTap: () async {
                      context.pushNamed(Auth2EditProfileWidget.routeName);
                    },
                    child: Container(
                      width: double.infinity,
                      height: 60.0,
                      decoration: BoxDecoration(
                        color: AppTheme.of(context).secondaryBackground,
                        boxShadow: [
                          BoxShadow(
                            blurRadius: 3.0,
                            color: Color(0x33000000),
                            offset: Offset(
                              0.0,
                              1.0,
                            ),
                          )
                        ],
                        borderRadius: BorderRadius.circular(8.0),
                        shape: BoxShape.rectangle,
                        border: Border.all(
                          color: AppTheme.of(context).alternate,
                          width: 1.0,
                        ),
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(12.0),
                        child: Row(
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            Icon(
                              Icons.account_circle_outlined,
                              color: AppTheme.of(context).secondaryText,
                              size: 24.0,
                            ),
                            Padding(
                              padding: EdgeInsetsDirectional.fromSTEB(
                                  12.0, 0.0, 0.0, 0.0),
                              child: Text(
                                AppLocalizations.of(context).getText(
                                  '8ctbqg92' /* Edit Profile */,
                                ),
                                style: AppTheme.of(context)
                                    .labelLarge
                                    .override(
                                      font: GoogleFonts.inter(
                                        fontWeight: AppTheme.of(context)
                                            .labelLarge
                                            .fontWeight,
                                        fontStyle: AppTheme.of(context)
                                            .labelLarge
                                            .fontStyle,
                                      ),
                                      letterSpacing: 0.0,
                                      fontWeight: AppTheme.of(context)
                                          .labelLarge
                                          .fontWeight,
                                      fontStyle: AppTheme.of(context)
                                          .labelLarge
                                          .fontStyle,
                                    ),
                              ),
                            ),
                            Expanded(
                              child: Align(
                                alignment: AlignmentDirectional(0.9, 0.0),
                                child: Icon(
                                  Icons.arrow_forward_ios,
                                  color: AppTheme.of(context)
                                      .secondaryText,
                                  size: 18.0,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsetsDirectional.fromSTEB(24.0, 16.0, 0.0, 0.0),
                  child: Text(
                    AppLocalizations.of(context).getText(
                      'ue4tdodf' /* App Settings */,
                    ),
                    style: AppTheme.of(context).labelMedium.override(
                          font: GoogleFonts.inter(
                            fontWeight: AppTheme.of(context)
                                .labelMedium
                                .fontWeight,
                            fontStyle: AppTheme.of(context)
                                .labelMedium
                                .fontStyle,
                          ),
                          letterSpacing: 0.0,
                          fontWeight: AppTheme.of(context)
                              .labelMedium
                              .fontWeight,
                          fontStyle: AppTheme.of(context)
                              .labelMedium
                              .fontStyle,
                        ),
                  ),
                ),
                Padding(
                  padding:
                      EdgeInsetsDirectional.fromSTEB(16.0, 12.0, 16.0, 0.0),
                  child: Container(
                    width: double.infinity,
                    height: 60.0,
                    decoration: BoxDecoration(
                      color: AppTheme.of(context).secondaryBackground,
                      boxShadow: [
                        BoxShadow(
                          blurRadius: 3.0,
                          color: Color(0x33000000),
                          offset: Offset(
                            0.0,
                            1.0,
                          ),
                        )
                      ],
                      borderRadius: BorderRadius.circular(8.0),
                      shape: BoxShape.rectangle,
                      border: Border.all(
                        color: AppTheme.of(context).alternate,
                        width: 1.0,
                      ),
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(12.0),
                      child: Row(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Icon(
                            Icons.help_outline_rounded,
                            color: AppTheme.of(context).secondaryText,
                            size: 24.0,
                          ),
                          Padding(
                            padding: EdgeInsetsDirectional.fromSTEB(
                                12.0, 0.0, 0.0, 0.0),
                            child: Text(
                              AppLocalizations.of(context).getText(
                                'ljm3zuye' /* Support */,
                              ),
                              style: AppTheme.of(context)
                                  .labelLarge
                                  .override(
                                    font: GoogleFonts.inter(
                                      fontWeight: AppTheme.of(context)
                                          .labelLarge
                                          .fontWeight,
                                      fontStyle: AppTheme.of(context)
                                          .labelLarge
                                          .fontStyle,
                                    ),
                                    letterSpacing: 0.0,
                                    fontWeight: AppTheme.of(context)
                                        .labelLarge
                                        .fontWeight,
                                    fontStyle: AppTheme.of(context)
                                        .labelLarge
                                        .fontStyle,
                                  ),
                            ),
                          ),
                          Expanded(
                            child: Align(
                              alignment: AlignmentDirectional(0.9, 0.0),
                              child: Icon(
                                Icons.arrow_forward_ios,
                                color:
                                    AppTheme.of(context).secondaryText,
                                size: 18.0,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding:
                      EdgeInsetsDirectional.fromSTEB(16.0, 12.0, 16.0, 0.0),
                  child: Container(
                    width: double.infinity,
                    height: 60.0,
                    decoration: BoxDecoration(
                      color: AppTheme.of(context).secondaryBackground,
                      boxShadow: [
                        BoxShadow(
                          blurRadius: 3.0,
                          color: Color(0x33000000),
                          offset: Offset(
                            0.0,
                            1.0,
                          ),
                        )
                      ],
                      borderRadius: BorderRadius.circular(8.0),
                      shape: BoxShape.rectangle,
                      border: Border.all(
                        color: AppTheme.of(context).alternate,
                        width: 1.0,
                      ),
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(12.0),
                      child: Row(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Icon(
                            Icons.privacy_tip_rounded,
                            color: AppTheme.of(context).secondaryText,
                            size: 24.0,
                          ),
                          Padding(
                            padding: EdgeInsetsDirectional.fromSTEB(
                                12.0, 0.0, 0.0, 0.0),
                            child: Text(
                              AppLocalizations.of(context).getText(
                                'sl7qwp3g' /* Terms of Service */,
                              ),
                              style: AppTheme.of(context)
                                  .labelLarge
                                  .override(
                                    font: GoogleFonts.inter(
                                      fontWeight: AppTheme.of(context)
                                          .labelLarge
                                          .fontWeight,
                                      fontStyle: AppTheme.of(context)
                                          .labelLarge
                                          .fontStyle,
                                    ),
                                    letterSpacing: 0.0,
                                    fontWeight: AppTheme.of(context)
                                        .labelLarge
                                        .fontWeight,
                                    fontStyle: AppTheme.of(context)
                                        .labelLarge
                                        .fontStyle,
                                  ),
                            ),
                          ),
                          Expanded(
                            child: Align(
                              alignment: AlignmentDirectional(0.9, 0.0),
                              child: Icon(
                                Icons.arrow_forward_ios,
                                color:
                                    AppTheme.of(context).secondaryText,
                                size: 18.0,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Align(
                  alignment: AlignmentDirectional(0.0, 0.0),
                  child: Padding(
                    padding:
                        EdgeInsetsDirectional.fromSTEB(0.0, 16.0, 0.0, 0.0),
                    child: AppButtonWidget(
                      onPressed: () {
                        print('Button pressed ...');
                      },
                      text: AppLocalizations.of(context).getText(
                        'ud37xux6' /* Log Out */,
                      ),
                      options: AppButtonOptions(
                        width: 150.0,
                        height: 44.0,
                        padding:
                            EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 0.0),
                        iconPadding:
                            EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 0.0),
                        color: AppTheme.of(context).primaryBackground,
                        textStyle:
                            AppTheme.of(context).bodyLarge.override(
                                  font: GoogleFonts.inter(
                                    fontWeight: AppTheme.of(context)
                                        .bodyLarge
                                        .fontWeight,
                                    fontStyle: AppTheme.of(context)
                                        .bodyLarge
                                        .fontStyle,
                                  ),
                                  letterSpacing: 0.0,
                                  fontWeight: AppTheme.of(context)
                                      .bodyLarge
                                      .fontWeight,
                                  fontStyle: AppTheme.of(context)
                                      .bodyLarge
                                      .fontStyle,
                                ),
                        elevation: 0.0,
                        borderSide: BorderSide(
                          color: AppTheme.of(context).alternate,
                          width: 1.0,
                        ),
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                    ).animateOnPageLoad(
                        animationsMap['buttonOnPageLoadAnimation']!),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
