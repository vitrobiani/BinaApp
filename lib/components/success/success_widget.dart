import '/app_core/app_animations.dart';
import '/app_core/app_theme.dart';
import '/app_core/app_util.dart';
import '/app_core/app_widgets.dart';
import 'dart:ui';
import '/index.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'success_model.dart';
export 'success_model.dart';

class SuccessWidget extends StatefulWidget {
  const SuccessWidget({super.key});

  @override
  State<SuccessWidget> createState() => _SuccessWidgetState();
}

class _SuccessWidgetState extends State<SuccessWidget>
    with TickerProviderStateMixin {
  late SuccessModel _model;

  final animationsMap = <String, AnimationInfo>{};

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => SuccessModel());

    animationsMap.addAll({
      'textOnPageLoadAnimation1': AnimationInfo(
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
            begin: Offset(0.0, 40.0),
            end: Offset(0.0, 0.0),
          ),
        ],
      ),
      'textOnPageLoadAnimation2': AnimationInfo(
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
            begin: Offset(0.0, 50.0),
            end: Offset(0.0, 0.0),
          ),
        ],
      ),
      'imageOnPageLoadAnimation': AnimationInfo(
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
            begin: Offset(0.0, 50.0),
            end: Offset(0.0, 0.0),
          ),
          ScaleEffect(
            curve: Curves.easeInOut,
            delay: 0.0.ms,
            duration: 600.0.ms,
            begin: Offset(0.8, 1.0),
            end: Offset(1.0, 1.0),
          ),
        ],
      ),
      'buttonOnPageLoadAnimation': AnimationInfo(
        trigger: AnimationTrigger.onPageLoad,
        effectsBuilder: () => [
          VisibilityEffect(duration: 800.ms),
          FadeEffect(
            curve: Curves.bounceOut,
            delay: 800.0.ms,
            duration: 600.0.ms,
            begin: 0.0,
            end: 1.0,
          ),
          ScaleEffect(
            curve: Curves.bounceOut,
            delay: 800.0.ms,
            duration: 600.0.ms,
            begin: Offset(0.8, 1.0),
            end: Offset(1.0, 1.0),
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
    _model.maybeDispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: 4.0,
          sigmaY: 6.0,
        ),
        child: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            color: Color(0x4D000000),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: EdgeInsetsDirectional.fromSTEB(16.0, 0.0, 16.0, 0.0),
                child: Container(
                  width: double.infinity,
                  constraints: BoxConstraints(
                    maxWidth: 530.0,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.of(context).primaryBackground,
                    boxShadow: [
                      BoxShadow(
                        blurRadius: 4.0,
                        color: Color(0x19000000),
                        offset: Offset(
                          0.0,
                          2.0,
                        ),
                      )
                    ],
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          AppLocalizations.of(context).getText(
                            '00flvi93' /* Operation success! */,
                          ),
                          style: AppTheme.of(context)
                              .headlineMedium
                              .override(
                                font: GoogleFonts.readexPro(
                                  fontWeight: AppTheme.of(context)
                                      .headlineMedium
                                      .fontWeight,
                                  fontStyle: AppTheme.of(context)
                                      .headlineMedium
                                      .fontStyle,
                                ),
                                letterSpacing: 0.0,
                                fontWeight: AppTheme.of(context)
                                    .headlineMedium
                                    .fontWeight,
                                fontStyle: AppTheme.of(context)
                                    .headlineMedium
                                    .fontStyle,
                              ),
                        ).animateOnPageLoad(
                            animationsMap['textOnPageLoadAnimation1']!),
                        Padding(
                          padding: EdgeInsetsDirectional.fromSTEB(
                              0.0, 8.0, 0.0, 0.0),
                          child: Text(
                            AppLocalizations.of(context).getText(
                              'fmzceh74' /* New diagnosis will be generate... */,
                            ),
                            style:
                                AppTheme.of(context).bodySmall.override(
                                      font: GoogleFonts.inter(
                                        fontWeight: AppTheme.of(context)
                                            .bodySmall
                                            .fontWeight,
                                        fontStyle: AppTheme.of(context)
                                            .bodySmall
                                            .fontStyle,
                                      ),
                                      letterSpacing: 0.0,
                                      fontWeight: AppTheme.of(context)
                                          .bodySmall
                                          .fontWeight,
                                      fontStyle: AppTheme.of(context)
                                          .bodySmall
                                          .fontStyle,
                                    ),
                          ).animateOnPageLoad(
                              animationsMap['textOnPageLoadAnimation2']!),
                        ),
                        Padding(
                          padding: EdgeInsetsDirectional.fromSTEB(
                              0.0, 16.0, 0.0, 16.0),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8.0),
                            child: Image.asset(
                              'assets/images/congrats@2x.png',
                              width: 300.0,
                              height: 200.0,
                              fit: BoxFit.cover,
                            ),
                          ).animateOnPageLoad(
                              animationsMap['imageOnPageLoadAnimation']!),
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            Expanded(
                              child: Padding(
                                padding: EdgeInsetsDirectional.fromSTEB(
                                    0.0, 16.0, 0.0, 0.0),
                                child: AppButtonWidget(
                                  onPressed: () async {
                                    context.pushNamed(
                                      MainHomeWidget.routeName,
                                      extra: <String, dynamic>{
                                        kTransitionInfoKey: TransitionInfo(
                                          hasTransition: true,
                                          transitionType:
                                              PageTransitionType.leftToRight,
                                          duration: Duration(milliseconds: 250),
                                        ),
                                      },
                                    );

                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          'New diagnostic added!',
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
                                                color:
                                                    AppTheme.of(context)
                                                        .primaryText,
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
                                        ),
                                        duration: Duration(milliseconds: 4000),
                                        backgroundColor:
                                            AppTheme.of(context)
                                                .secondary,
                                      ),
                                    );
                                  },
                                  text: AppLocalizations.of(context).getText(
                                    'g8q2u55w' /* Continue */,
                                  ),
                                  options: AppButtonOptions(
                                    width: 160.0,
                                    height: 50.0,
                                    padding: EdgeInsetsDirectional.fromSTEB(
                                        0.0, 0.0, 0.0, 0.0),
                                    iconPadding: EdgeInsetsDirectional.fromSTEB(
                                        0.0, 0.0, 0.0, 0.0),
                                    color: AppTheme.of(context)
                                        .primaryBackground,
                                    textStyle: AppTheme.of(context)
                                        .titleMedium
                                        .override(
                                          font: GoogleFonts.readexPro(
                                            fontWeight:
                                                AppTheme.of(context)
                                                    .titleMedium
                                                    .fontWeight,
                                            fontStyle:
                                                AppTheme.of(context)
                                                    .titleMedium
                                                    .fontStyle,
                                          ),
                                          color: AppTheme.of(context)
                                              .primaryText,
                                          letterSpacing: 0.0,
                                          fontWeight:
                                              AppTheme.of(context)
                                                  .titleMedium
                                                  .fontWeight,
                                          fontStyle:
                                              AppTheme.of(context)
                                                  .titleMedium
                                                  .fontStyle,
                                        ),
                                    elevation: 2.0,
                                    borderSide: BorderSide(
                                      color: AppTheme.of(context)
                                          .primaryText,
                                      width: 2.0,
                                    ),
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                ).animateOnPageLoad(animationsMap[
                                    'buttonOnPageLoadAnimation']!),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
