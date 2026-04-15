import '/auth/supabase_auth/auth_util.dart';
import '/components/accessability/accessability_widget.dart';
import '/app_core/app_animations.dart';
import '/app_core/app_icon_button.dart';
import '/app_core/app_theme.dart';
import '/app_core/app_util.dart';
import '/app_core/app_widgets.dart';
import '/pages/nav_pages/web_nav/web_nav_widget.dart';
import '/index.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
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
  var hasContainerTriggered1 = false;
  var hasContainerTriggered2 = false;
  final animationsMap = <String, AnimationInfo>{};

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => MainProfilePageModel());

    animationsMap.addAll({
      'textOnPageLoadAnimation': AnimationInfo(
        trigger: AnimationTrigger.onPageLoad,
        effectsBuilder: () => [
          VisibilityEffect(duration: 1.ms),
          FadeEffect(
            curve: Curves.easeInOut,
            delay: 0.0.ms,
            duration: 600.0.ms,
            begin: 0.0,
            end: 1.0,
          ),
          MoveEffect(
            curve: Curves.easeInOut,
            delay: 0.0.ms,
            duration: 600.0.ms,
            begin: Offset(0.0, 20.0),
            end: Offset(0.0, 0.0),
          ),
        ],
      ),
      'containerOnActionTriggerAnimation1': AnimationInfo(
        trigger: AnimationTrigger.onActionTrigger,
        applyInitialState: false,
        effectsBuilder: () => [
          MoveEffect(
            curve: Curves.easeInOut,
            delay: 0.0.ms,
            duration: 350.0.ms,
            begin: Offset(40.0, 0.0),
            end: Offset(0.0, 0.0),
          ),
        ],
      ),
      'containerOnActionTriggerAnimation2': AnimationInfo(
        trigger: AnimationTrigger.onActionTrigger,
        applyInitialState: false,
        effectsBuilder: () => [
          MoveEffect(
            curve: Curves.easeInOut,
            delay: 0.0.ms,
            duration: 350.0.ms,
            begin: Offset(-40.0, 0.0),
            end: Offset(0.0, 0.0),
          ),
        ],
      ),
    });
    setupAnimations(
      animationsMap.values.where((anim) =>
          anim.trigger == AnimationTrigger.onActionTrigger ||
          !anim.applyInitialState),
      this,
    );

    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    context.watch<AppState>();

    return Scaffold(
      key: scaffoldKey,
      backgroundColor: AppTheme.of(context).primaryBackground,
      body: Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Row(
              mainAxisSize: MainAxisSize.max,
              children: [
                if (responsiveVisibility(
                  context: context,
                  phone: false,
                  tablet: false,
                ))
                  wrapWithModel(
                    model: _model.webNavModel,
                    updateCallback: () => safeSetState(() {}),
                    child: WebNavWidget(
                      iconOne: Icon(
                        Icons.home_rounded,
                        color: AppTheme.of(context).secondaryText,
                      ),
                      iconTwo: Icon(
                        Icons.remove_red_eye,
                        color: AppTheme.of(context).secondaryText,
                      ),
                      iconThree: Icon(
                        Icons.camera_alt,
                        color: AppTheme.of(context).secondaryText,
                      ),
                      iconFour: Icon(
                        Icons.account_circle,
                        color: AppTheme.of(context).primary,
                      ),
                      colorBgOne:
                          AppTheme.of(context).secondaryBackground,
                      colorBgTwo:
                          AppTheme.of(context).secondaryBackground,
                      colorBgThree:
                          AppTheme.of(context).secondaryBackground,
                      colorBgFour:
                          AppTheme.of(context).primaryBackground,
                      textOne: AppTheme.of(context).primaryText,
                      textTwo: AppTheme.of(context).secondaryText,
                      textThree: AppTheme.of(context).secondaryText,
                      textFour: AppTheme.of(context).secondaryText,
                      iconFive: Icon(
                        Icons.reduce_capacity,
                        color: AppTheme.of(context).secondaryText,
                      ),
                      colorBgFive:
                          AppTheme.of(context).secondaryBackground,
                      textFive: AppTheme.of(context).secondaryText,
                    ),
                  ),
                Expanded(
                  child: Container(
                    width: 100.0,
                    decoration: BoxDecoration(
                      color: AppTheme.of(context).primaryBackground,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        if (responsiveVisibility(
                          context: context,
                          tablet: false,
                          tabletLandscape: false,
                          desktop: false,
                        ))
                          Container(
                            width: double.infinity,
                            height: 34.0,
                            decoration: BoxDecoration(
                              color: AppTheme.of(context)
                                  .secondaryBackground,
                            ),
                          ),
                        Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: AppTheme.of(context)
                                .secondaryBackground,
                          ),
                          alignment: AlignmentDirectional(-1.0, 0.0),
                          child: Padding(
                            padding: EdgeInsetsDirectional.fromSTEB(
                                0.0, 0.0, 16.0, 0.0),
                            child: Row(
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Padding(
                                  padding: EdgeInsetsDirectional.fromSTEB(
                                      16.0, 16.0, 0.0, 16.0),
                                  child: Text(
                                    AppLocalizations.of(context).getText(
                                      'qrxn5crt' /* My Profile */,
                                    ),
                                    textAlign: TextAlign.start,
                                    style: AppTheme.of(context)
                                        .displaySmall
                                        .override(
                                          font: GoogleFonts.readexPro(
                                            fontWeight:
                                                AppTheme.of(context)
                                                    .displaySmall
                                                    .fontWeight,
                                            fontStyle:
                                                AppTheme.of(context)
                                                    .displaySmall
                                                    .fontStyle,
                                          ),
                                          letterSpacing: 0.0,
                                          fontWeight:
                                              AppTheme.of(context)
                                                  .displaySmall
                                                  .fontWeight,
                                          fontStyle:
                                              AppTheme.of(context)
                                                  .displaySmall
                                                  .fontStyle,
                                        ),
                                  ).animateOnPageLoad(animationsMap[
                                      'textOnPageLoadAnimation']!),
                                ),
                                if (responsiveVisibility(
                                  context: context,
                                  tabletLandscape: false,
                                  desktop: false,
                                ))
                                  AppIconButton(
                                    borderRadius: 30.0,
                                    borderWidth: 1.0,
                                    buttonSize: 60.0,
                                    icon: Icon(
                                      Icons.power_settings_new,
                                      color: AppTheme.of(context)
                                          .primaryText,
                                      size: 30.0,
                                    ),
                                    onPressed: () {
                                      print('IconButton pressed ...');
                                    },
                                  ),
                              ],
                            ),
                          ),
                        ),
                        Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: AppTheme.of(context)
                                .secondaryBackground,
                            boxShadow: [
                              BoxShadow(
                                blurRadius: 1.0,
                                color: AppTheme.of(context)
                                    .primaryBackground,
                                offset: Offset(
                                  0.0,
                                  0.0,
                                ),
                              )
                            ],
                          ),
                          child: Padding(
                            padding: EdgeInsetsDirectional.fromSTEB(
                                24.0, 12.0, 24.0, 12.0),
                            child: Row(
                              mainAxisSize: MainAxisSize.max,
                              children: [
                                Card(
                                  clipBehavior: Clip.antiAliasWithSaveLayer,
                                  color: AppTheme.of(context)
                                      .secondaryBackground,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(50.0),
                                  ),
                                  child: Padding(
                                    padding: EdgeInsets.all(2.0),
                                    child: Container(
                                      width: 76.0,
                                      height: 76.0,
                                      clipBehavior: Clip.antiAlias,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                      ),
                                      child: CachedNetworkImage(
                                        fadeInDuration:
                                            Duration(milliseconds: 500),
                                        fadeOutDuration:
                                            Duration(milliseconds: 500),
                                        imageUrl:
                                            'https://cdn.pixabay.com/photo/2015/10/05/22/37/blank-profile-picture-973460_1280.png',
                                      ),
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsetsDirectional.fromSTEB(
                                      16.0, 0.0, 0.0, 0.0),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.max,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Padding(
                                        padding: EdgeInsetsDirectional.fromSTEB(
                                            0.0, 8.0, 0.0, 0.0),
                                        child: Text(
                                          AppState().UserSession.name,
                                          style: AppTheme.of(context)
                                              .headlineSmall
                                              .override(
                                                font: GoogleFonts.readexPro(
                                                  fontWeight:
                                                      AppTheme.of(
                                                              context)
                                                          .headlineSmall
                                                          .fontWeight,
                                                  fontStyle:
                                                      AppTheme.of(
                                                              context)
                                                          .headlineSmall
                                                          .fontStyle,
                                                ),
                                                letterSpacing: 0.0,
                                                fontWeight:
                                                    AppTheme.of(context)
                                                        .headlineSmall
                                                        .fontWeight,
                                                fontStyle:
                                                    AppTheme.of(context)
                                                        .headlineSmall
                                                        .fontStyle,
                                              ),
                                        ),
                                      ),
                                      Padding(
                                        padding: EdgeInsetsDirectional.fromSTEB(
                                            0.0, 8.0, 0.0, 0.0),
                                        child: Text(
                                          AppState().UserSession.email,
                                          style: AppTheme.of(context)
                                              .bodySmall
                                              .override(
                                                font: GoogleFonts.outfit(
                                                  fontWeight: FontWeight.normal,
                                                  fontStyle:
                                                      AppTheme.of(
                                                              context)
                                                          .bodySmall
                                                          .fontStyle,
                                                ),
                                                color:
                                                    AppTheme.of(context)
                                                        .primary,
                                                fontSize: 14.0,
                                                letterSpacing: 0.0,
                                                fontWeight: FontWeight.normal,
                                                fontStyle:
                                                    AppTheme.of(context)
                                                        .bodySmall
                                                        .fontStyle,
                                              ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsetsDirectional.fromSTEB(
                              0.0, 1.0, 0.0, 0.0),
                          child: Column(
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              if (Theme.of(context).brightness ==
                                  Brightness.light)
                                InkWell(
                                  splashColor: Colors.transparent,
                                  focusColor: Colors.transparent,
                                  hoverColor: Colors.transparent,
                                  highlightColor: Colors.transparent,
                                  onTap: () async {
                                    setDarkModeSetting(context, ThemeMode.dark);
                                    if (animationsMap[
                                            'containerOnActionTriggerAnimation2'] !=
                                        null) {
                                      safeSetState(
                                          () => hasContainerTriggered2 = true);
                                      SchedulerBinding.instance
                                          .addPostFrameCallback((_) async =>
                                              await animationsMap[
                                                      'containerOnActionTriggerAnimation2']!
                                                  .controller
                                                  .forward(from: 0.0));
                                    }
                                  },
                                  child: Container(
                                    width:
                                        MediaQuery.sizeOf(context).width * 1.0,
                                    decoration: BoxDecoration(
                                      color: AppTheme.of(context)
                                          .secondaryBackground,
                                      boxShadow: [
                                        BoxShadow(
                                          blurRadius: 1.0,
                                          color: AppTheme.of(context)
                                              .primaryBackground,
                                          offset: Offset(
                                            0.0,
                                            0.0,
                                          ),
                                        )
                                      ],
                                    ),
                                    child: Padding(
                                      padding: EdgeInsetsDirectional.fromSTEB(
                                          24.0, 12.0, 24.0, 12.0),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.max,
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            AppLocalizations.of(context).getText(
                                              'v1hh7jlp' /* Switch to Dark Mode */,
                                            ),
                                            style: AppTheme.of(context)
                                                .bodyMedium
                                                .override(
                                                  font: GoogleFonts.inter(
                                                    fontWeight:
                                                        AppTheme.of(
                                                                context)
                                                            .bodyMedium
                                                            .fontWeight,
                                                    fontStyle:
                                                        AppTheme.of(
                                                                context)
                                                            .bodyMedium
                                                            .fontStyle,
                                                  ),
                                                  letterSpacing: 0.0,
                                                  fontWeight:
                                                      AppTheme.of(
                                                              context)
                                                          .bodyMedium
                                                          .fontWeight,
                                                  fontStyle:
                                                      AppTheme.of(
                                                              context)
                                                          .bodyMedium
                                                          .fontStyle,
                                                ),
                                          ),
                                          Container(
                                            width: 80.0,
                                            height: 40.0,
                                            decoration: BoxDecoration(
                                              color:
                                                  AppTheme.of(context)
                                                      .primaryBackground,
                                              borderRadius:
                                                  BorderRadius.circular(20.0),
                                            ),
                                            child: Stack(
                                              alignment: AlignmentDirectional(
                                                  0.0, 0.0),
                                              children: [
                                                Align(
                                                  alignment:
                                                      AlignmentDirectional(
                                                          0.95, 0.0),
                                                  child: Padding(
                                                    padding:
                                                        EdgeInsetsDirectional
                                                            .fromSTEB(0.0, 0.0,
                                                                8.0, 0.0),
                                                    child: Icon(
                                                      Icons.nights_stay,
                                                      color:
                                                          AppTheme.of(
                                                                  context)
                                                              .secondaryText,
                                                      size: 20.0,
                                                    ),
                                                  ),
                                                ),
                                                Align(
                                                  alignment:
                                                      AlignmentDirectional(
                                                          -0.85, 0.0),
                                                  child: Container(
                                                    width: 36.0,
                                                    height: 36.0,
                                                    decoration: BoxDecoration(
                                                      color: AppTheme
                                                              .of(context)
                                                          .secondaryBackground,
                                                      boxShadow: [
                                                        BoxShadow(
                                                          blurRadius: 4.0,
                                                          color:
                                                              Color(0x430B0D0F),
                                                          offset: Offset(
                                                            0.0,
                                                            2.0,
                                                          ),
                                                        )
                                                      ],
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              30.0),
                                                      shape: BoxShape.rectangle,
                                                    ),
                                                  ).animateOnActionTrigger(
                                                      animationsMap[
                                                          'containerOnActionTriggerAnimation1']!,
                                                      hasBeenTriggered:
                                                          hasContainerTriggered1),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              if (Theme.of(context).brightness ==
                                  Brightness.dark)
                                InkWell(
                                  splashColor: Colors.transparent,
                                  focusColor: Colors.transparent,
                                  hoverColor: Colors.transparent,
                                  highlightColor: Colors.transparent,
                                  onTap: () async {
                                    setDarkModeSetting(
                                        context, ThemeMode.light);
                                    if (animationsMap[
                                            'containerOnActionTriggerAnimation1'] !=
                                        null) {
                                      safeSetState(
                                          () => hasContainerTriggered1 = true);
                                      SchedulerBinding.instance
                                          .addPostFrameCallback((_) async =>
                                              await animationsMap[
                                                      'containerOnActionTriggerAnimation1']!
                                                  .controller
                                                  .forward(from: 0.0));
                                    }
                                  },
                                  child: Container(
                                    width:
                                        MediaQuery.sizeOf(context).width * 1.0,
                                    decoration: BoxDecoration(
                                      color: AppTheme.of(context)
                                          .secondaryBackground,
                                      boxShadow: [
                                        BoxShadow(
                                          blurRadius: 1.0,
                                          color: AppTheme.of(context)
                                              .primaryBackground,
                                          offset: Offset(
                                            0.0,
                                            0.0,
                                          ),
                                        )
                                      ],
                                    ),
                                    child: Padding(
                                      padding: EdgeInsetsDirectional.fromSTEB(
                                          24.0, 12.0, 24.0, 12.0),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.max,
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            AppLocalizations.of(context).getText(
                                              'sh7q15l6' /* Switch to Light Mode */,
                                            ),
                                            style: AppTheme.of(context)
                                                .bodyMedium
                                                .override(
                                                  font: GoogleFonts.inter(
                                                    fontWeight:
                                                        AppTheme.of(
                                                                context)
                                                            .bodyMedium
                                                            .fontWeight,
                                                    fontStyle:
                                                        AppTheme.of(
                                                                context)
                                                            .bodyMedium
                                                            .fontStyle,
                                                  ),
                                                  letterSpacing: 0.0,
                                                  fontWeight:
                                                      AppTheme.of(
                                                              context)
                                                          .bodyMedium
                                                          .fontWeight,
                                                  fontStyle:
                                                      AppTheme.of(
                                                              context)
                                                          .bodyMedium
                                                          .fontStyle,
                                                ),
                                          ),
                                          Container(
                                            width: 80.0,
                                            height: 40.0,
                                            decoration: BoxDecoration(
                                              color:
                                                  AppTheme.of(context)
                                                      .primaryBackground,
                                              borderRadius:
                                                  BorderRadius.circular(20.0),
                                            ),
                                            child: Stack(
                                              alignment: AlignmentDirectional(
                                                  0.0, 0.0),
                                              children: [
                                                Align(
                                                  alignment:
                                                      AlignmentDirectional(
                                                          -0.9, 0.0),
                                                  child: Padding(
                                                    padding:
                                                        EdgeInsetsDirectional
                                                            .fromSTEB(8.0, 2.0,
                                                                0.0, 0.0),
                                                    child: Icon(
                                                      Icons.wb_sunny_rounded,
                                                      color:
                                                          AppTheme.of(
                                                                  context)
                                                              .secondaryText,
                                                      size: 24.0,
                                                    ),
                                                  ),
                                                ),
                                                Align(
                                                  alignment:
                                                      AlignmentDirectional(
                                                          0.9, 0.0),
                                                  child: Container(
                                                    width: 36.0,
                                                    height: 36.0,
                                                    decoration: BoxDecoration(
                                                      color: AppTheme
                                                              .of(context)
                                                          .secondaryBackground,
                                                      boxShadow: [
                                                        BoxShadow(
                                                          blurRadius: 4.0,
                                                          color:
                                                              Color(0x430B0D0F),
                                                          offset: Offset(
                                                            0.0,
                                                            2.0,
                                                          ),
                                                        )
                                                      ],
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              30.0),
                                                      shape: BoxShape.rectangle,
                                                    ),
                                                  ).animateOnActionTrigger(
                                                      animationsMap[
                                                          'containerOnActionTriggerAnimation2']!,
                                                      hasBeenTriggered:
                                                          hasContainerTriggered2),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                        Column(
                          mainAxisSize: MainAxisSize.max,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: EdgeInsetsDirectional.fromSTEB(
                                  24.0, 12.0, 0.0, 12.0),
                              child: Text(
                                AppLocalizations.of(context).getText(
                                  'fyxsf6vn' /* Account Settings */,
                                ),
                                style: AppTheme.of(context)
                                    .bodyMedium
                                    .override(
                                      font: GoogleFonts.inter(
                                        fontWeight: AppTheme.of(context)
                                            .bodyMedium
                                            .fontWeight,
                                        fontStyle: AppTheme.of(context)
                                            .bodyMedium
                                            .fontStyle,
                                      ),
                                      letterSpacing: 0.0,
                                      fontWeight: AppTheme.of(context)
                                          .bodyMedium
                                          .fontWeight,
                                      fontStyle: AppTheme.of(context)
                                          .bodyMedium
                                          .fontStyle,
                                    ),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsetsDirectional.fromSTEB(
                                  20.0, 0.0, 20.0, 0.0),
                              child: InkWell(
                                splashColor: Colors.transparent,
                                focusColor: Colors.transparent,
                                hoverColor: Colors.transparent,
                                highlightColor: Colors.transparent,
                                onTap: () async {
                                  context.pushNamed(FamilyWidget.routeName);
                                },
                                child: Container(
                                  width: double.infinity,
                                  height: 60.0,
                                  decoration: BoxDecoration(
                                    color: AppTheme.of(context)
                                        .secondaryBackground,
                                    boxShadow: [
                                      BoxShadow(
                                        blurRadius: 3.0,
                                        color: Color(0x3416202A),
                                        offset: Offset(
                                          0.0,
                                          1.0,
                                        ),
                                      )
                                    ],
                                    borderRadius: BorderRadius.circular(12.0),
                                    shape: BoxShape.rectangle,
                                  ),
                                  child: Padding(
                                    padding: EdgeInsets.all(8.0),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.max,
                                      children: [
                                        Padding(
                                          padding:
                                              EdgeInsetsDirectional.fromSTEB(
                                                  12.0, 0.0, 0.0, 0.0),
                                          child: Text(
                                            AppLocalizations.of(context).getText(
                                              'h43llaan' /* Manage Family */,
                                            ),
                                            style: AppTheme.of(context)
                                                .bodySmall
                                                .override(
                                                  font: GoogleFonts.outfit(
                                                    fontWeight:
                                                        FontWeight.normal,
                                                    fontStyle:
                                                        AppTheme.of(
                                                                context)
                                                            .bodySmall
                                                            .fontStyle,
                                                  ),
                                                  color: AppTheme.of(
                                                          context)
                                                      .secondaryText,
                                                  fontSize: 14.0,
                                                  letterSpacing: 0.0,
                                                  fontWeight: FontWeight.normal,
                                                  fontStyle:
                                                      AppTheme.of(
                                                              context)
                                                          .bodySmall
                                                          .fontStyle,
                                                ),
                                          ),
                                        ),
                                        Expanded(
                                          child: Align(
                                            alignment:
                                                AlignmentDirectional(0.9, 0.0),
                                            child: Icon(
                                              Icons.arrow_forward_ios,
                                              color:
                                                  AppTheme.of(context)
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
                              padding: EdgeInsetsDirectional.fromSTEB(
                                  20.0, 12.0, 20.0, 0.0),
                              child: InkWell(
                                splashColor: Colors.transparent,
                                focusColor: Colors.transparent,
                                hoverColor: Colors.transparent,
                                highlightColor: Colors.transparent,
                                onTap: () async {
                                  await showModalBottomSheet(
                                    isScrollControlled: true,
                                    backgroundColor: Colors.transparent,
                                    enableDrag: false,
                                    context: context,
                                    builder: (context) {
                                      return Padding(
                                        padding:
                                            MediaQuery.viewInsetsOf(context),
                                        child: AccessabilityWidget(),
                                      );
                                    },
                                  ).then((value) => safeSetState(() {}));
                                },
                                child: Container(
                                  width: double.infinity,
                                  height: 60.0,
                                  decoration: BoxDecoration(
                                    color: AppTheme.of(context)
                                        .secondaryBackground,
                                    boxShadow: [
                                      BoxShadow(
                                        blurRadius: 3.0,
                                        color: Color(0x3416202A),
                                        offset: Offset(
                                          0.0,
                                          1.0,
                                        ),
                                      )
                                    ],
                                    borderRadius: BorderRadius.circular(12.0),
                                    shape: BoxShape.rectangle,
                                  ),
                                  child: Padding(
                                    padding: EdgeInsets.all(8.0),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.max,
                                      children: [
                                        Padding(
                                          padding:
                                              EdgeInsetsDirectional.fromSTEB(
                                                  12.0, 0.0, 0.0, 0.0),
                                          child: Text(
                                            AppLocalizations.of(context).getText(
                                              'b1lw0hfu' /* Prefrences and Accessability */,
                                            ),
                                            style: AppTheme.of(context)
                                                .bodySmall
                                                .override(
                                                  font: GoogleFonts.inter(
                                                    fontWeight:
                                                        AppTheme.of(
                                                                context)
                                                            .bodySmall
                                                            .fontWeight,
                                                    fontStyle:
                                                        AppTheme.of(
                                                                context)
                                                            .bodySmall
                                                            .fontStyle,
                                                  ),
                                                  letterSpacing: 0.0,
                                                  fontWeight:
                                                      AppTheme.of(
                                                              context)
                                                          .bodySmall
                                                          .fontWeight,
                                                  fontStyle:
                                                      AppTheme.of(
                                                              context)
                                                          .bodySmall
                                                          .fontStyle,
                                                ),
                                          ),
                                        ),
                                        Expanded(
                                          child: Align(
                                            alignment:
                                                AlignmentDirectional(0.9, 0.0),
                                            child: Icon(
                                              Icons.arrow_forward_ios,
                                              color:
                                                  AppTheme.of(context)
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
                              padding: EdgeInsetsDirectional.fromSTEB(
                                  0.0, 20.0, 0.0, 20.0),
                              child: Row(
                                mainAxisSize: MainAxisSize.max,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  AppButtonWidget(
                                    onPressed: () async {
                                      GoRouter.of(context).prepareAuthEvent();
                                      await authManager.signOut();
                                      GoRouter.of(context)
                                          .clearRedirectLocation();

                                      context.goNamedAuth(
                                          Auth2LoginWidget.routeName,
                                          context.mounted);
                                    },
                                    text: AppLocalizations.of(context).getText(
                                      'abqf147c' /* Log Out */,
                                    ),
                                    options: AppButtonOptions(
                                      width: 90.0,
                                      height: 40.0,
                                      padding: EdgeInsetsDirectional.fromSTEB(
                                          0.0, 0.0, 0.0, 0.0),
                                      iconPadding:
                                          EdgeInsetsDirectional.fromSTEB(
                                              0.0, 0.0, 0.0, 0.0),
                                      color: AppTheme.of(context)
                                          .secondaryBackground,
                                      textStyle: AppTheme.of(context)
                                          .bodyMedium
                                          .override(
                                            font: GoogleFonts.inter(
                                              fontWeight:
                                                  AppTheme.of(context)
                                                      .bodyMedium
                                                      .fontWeight,
                                              fontStyle:
                                                  AppTheme.of(context)
                                                      .bodyMedium
                                                      .fontStyle,
                                            ),
                                            letterSpacing: 0.0,
                                            fontWeight:
                                                AppTheme.of(context)
                                                    .bodyMedium
                                                    .fontWeight,
                                            fontStyle:
                                                AppTheme.of(context)
                                                    .bodyMedium
                                                    .fontStyle,
                                          ),
                                      elevation: 1.0,
                                      borderSide: BorderSide(
                                        color: Colors.transparent,
                                        width: 1.0,
                                      ),
                                      borderRadius: BorderRadius.circular(40.0),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
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
