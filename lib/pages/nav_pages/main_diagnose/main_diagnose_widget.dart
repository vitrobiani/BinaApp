import 'package:bina_system/components/tooltip_wrapper/tooltip_wrapper_widget.dart';

import '/components/diagnose_page/diagnose_card/diagnose_card_widget.dart';
import '/app_core/app_animations.dart';
import '/app_core/app_icon_button.dart';
import '/app_core/app_theme.dart';
import '/app_core/app_util.dart';
import '/pages/nav_pages/web_nav/web_nav_widget.dart';
import '/app_core/custom_functions.dart' as functions;
import '/actions/actions.dart' as action_blocks;
import '/index.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'main_diagnose_model.dart';
import 'package:bina_system/pages/other_pages/camera_connection/camera_connection_widget.dart';
export 'main_diagnose_model.dart';

class MainDiagnoseWidget extends StatefulWidget {
  const MainDiagnoseWidget({super.key});

  static String routeName = 'Main_Diagnose';
  static String routePath = 'mainDiagnose';

  @override
  State<MainDiagnoseWidget> createState() => _MainDiagnoseWidgetState();
}

class _MainDiagnoseWidgetState extends State<MainDiagnoseWidget>
    with TickerProviderStateMixin {
  late MainDiagnoseModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  final animationsMap = <String, AnimationInfo>{};

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => MainDiagnoseModel());

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
    });
    setupAnimations(
      animationsMap.values.where((anim) =>
          anim.trigger == AnimationTrigger.onActionTrigger ||
          !anim.applyInitialState),
      this,
    );

    // Refresh family data on page load
    SchedulerBinding.instance.addPostFrameCallback((_) async {
      await action_blocks.updateSessionFamily(context);
      safeSetState(() {});
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
        backgroundColor: AppTheme.of(context).primaryBackground,
        body: Column(
          mainAxisSize: MainAxisSize.max,
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
                          color: AppTheme.of(context).primary,
                        ),
                        iconFour: Icon(
                          Icons.account_circle,
                          color: AppTheme.of(context).secondaryText,
                        ),
                        colorBgOne:
                            AppTheme.of(context).secondaryBackground,
                        colorBgTwo:
                            AppTheme.of(context).secondaryBackground,
                        colorBgThree:
                            AppTheme.of(context).primaryBackground,
                        colorBgFour:
                            AppTheme.of(context).secondaryBackground,
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
                    child: Padding(
                      padding:
                          EdgeInsetsDirectional.fromSTEB(4.0, 0.0, 0.0, 0.0),
                      child: Container(
                        width: 300.0,
                        decoration: BoxDecoration(
                          color: AppTheme.of(context).primaryBackground,
                        ),
                        child: SingleChildScrollView(
                          child: Column(
                            mainAxisSize: MainAxisSize.max,
                            crossAxisAlignment: CrossAxisAlignment.start,
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
                                        .primaryBackground,
                                  ),
                                ),
                              Padding(
                                padding: EdgeInsetsDirectional.fromSTEB(
                                    12.0, 1.0, 0.0, 0.0),
                                child: Container(
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    color: AppTheme.of(context)
                                        .primaryBackground,
                                  ),
                                  alignment: AlignmentDirectional(-1.0, 0.0),
                                  child: Padding(
                                    padding: EdgeInsetsDirectional.fromSTEB(
                                        0.0, 0.0, 16.0, 0.0),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.max,
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Padding(
                                          padding: EdgeInsetsDirectional.fromSTEB(
                                              4.0, 16.0, 0.0, 0.0),
                                          child: Text(
                                            AppLocalizations.of(context).getText(
                                              'smh1o93d' /* Diagnose */,
                                            ),
                                            textAlign: TextAlign.start,
                                            style: AppTheme.of(context)
                                                .displaySmall
                                                .override(
                                                  font: GoogleFonts.readexPro(
                                                    fontWeight:
                                                        AppTheme.of(
                                                                context)
                                                            .displaySmall
                                                            .fontWeight,
                                                    fontStyle:
                                                        AppTheme.of(
                                                                context)
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
                                        TooltipWrapper(message: "External Bina Camera Connection",
                                            child: AppIconButton(
                                          borderColor: Colors.transparent,
                                          borderRadius: 30.0,
                                          borderWidth: 1.0,
                                          buttonSize: 60.0,
                                          icon: Icon(
                                            Icons.wifi,
                                            color: AppTheme.of(context)
                                                .primaryText,
                                            size: 30.0,
                                          ),
                                          showLoadingIndicator: true,
                                          onPressed: () async {
                                            context.pushNamed(
                                                CameraConnectionWidget.routeName);
                                          },
                                        )),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: EdgeInsetsDirectional.fromSTEB(
                                    16.0, 4.0, 0.0, 10.0),
                                child: Text(
                                  AppLocalizations.of(context).getText(
                                    'dlt46loo' /* Choose a member: */,
                                  ),
                                  style: AppTheme.of(context)
                                      .titleSmall
                                      .override(
                                        font: GoogleFonts.inter(
                                          fontWeight: AppTheme.of(context)
                                              .titleSmall
                                              .fontWeight,
                                          fontStyle: AppTheme.of(context)
                                              .titleSmall
                                              .fontStyle,
                                        ),
                                        color: AppTheme.of(context)
                                            .primaryText,
                                        letterSpacing: 0.0,
                                        fontWeight: AppTheme.of(context)
                                            .titleSmall
                                            .fontWeight,
                                        fontStyle: AppTheme.of(context)
                                            .titleSmall
                                            .fontStyle,
                                      ),
                                ),
                              ),
                              Builder(
                                builder: (context) {
                                  final familyMembers =
                                      AppState().UserSession.family.toList();

                                  return Column(
                                    mainAxisSize: MainAxisSize.max,
                                    children: List.generate(familyMembers.length,
                                        (familyMembersIndex) {
                                      final familyMembersItem =
                                          familyMembers[familyMembersIndex];
                                      return InkWell(
                                        splashColor: Colors.transparent,
                                        focusColor: Colors.transparent,
                                        hoverColor: Colors.transparent,
                                        highlightColor: Colors.transparent,
                                        onTap: () async {
                                          // Navigate to photo session page with family member info
                                          context.pushNamed(
                                            PhotoSessionWidget.routeName,
                                            extra: <String, dynamic>{
                                              'memberId': familyMembersItem.id,
                                              'memberName': familyMembersItem.name,
                                            },
                                          );
                                        },
                                        child: wrapWithModel(
                                          model:
                                              _model.diagnoseCardModels.getModel(
                                            familyMembersItem.id,
                                            familyMembersIndex,
                                          ),
                                          updateCallback: () =>
                                              safeSetState(() {}),
                                          child: DiagnoseCardWidget(
                                            key: Key(
                                              'Key0um_${familyMembersItem.id}',
                                            ),
                                            name: familyMembersItem.name,
                                            isHead: familyMembersItem.admin,
                                            lastChecked: familyMembersItem
                                                        .lastChecked
                                                        ?.secondsSinceEpoch !=
                                                    null
                                                ? familyMembersItem.lastChecked
                                                : functions.nullDateTime(
                                                    AppConstants.NULLDT),
                                            wasNeverChecked: familyMembersItem
                                                    .lastChecked
                                                    ?.secondsSinceEpoch !=
                                                null,
                                          ),
                                        ),
                                      );
                                    }),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
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
