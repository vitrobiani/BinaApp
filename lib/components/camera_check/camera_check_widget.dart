import '/app_core/app_animations.dart';
import '/app_core/app_theme.dart';
import '/app_core/app_util.dart';
import '/app_core/app_widgets.dart';
import '/app_core/instant_timer.dart';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'camera_check_model.dart';
export 'camera_check_model.dart';

class CameraCheckWidget extends StatefulWidget {
  const CameraCheckWidget({super.key});

  @override
  State<CameraCheckWidget> createState() => _CameraCheckWidgetState();
}

class _CameraCheckWidgetState extends State<CameraCheckWidget>
    with TickerProviderStateMixin {
  late CameraCheckModel _model;

  final animationsMap = <String, AnimationInfo>{};

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => CameraCheckModel());

    // On component load action.
    SchedulerBinding.instance.addPostFrameCallback((_) async {
      _model.counter = 0;
      safeSetState(() {});
      _model.instantTimer = InstantTimer.periodic(
        duration: Duration(milliseconds: 100),
        callback: (timer) async {
          _model.counter = _model.counter! + 1;
          safeSetState(() {});
        },
        startImmediately: true,
      );
    });

    animationsMap.addAll({
      'progressBarOnPageLoadAnimation': AnimationInfo(
        trigger: AnimationTrigger.onPageLoad,
        effectsBuilder: () => [
          VisibilityEffect(duration: 900.ms),
          FadeEffect(
            curve: Curves.easeInOut,
            delay: 900.0.ms,
            duration: 400.0.ms,
            begin: 0.0,
            end: 1.0,
          ),
          ScaleEffect(
            curve: Curves.easeInOut,
            delay: 900.0.ms,
            duration: 400.0.ms,
            begin: Offset(0.8, 1.0),
            end: Offset(1.0, 1.0),
          ),
        ],
      ),
      'iconOnPageLoadAnimation': AnimationInfo(
        trigger: AnimationTrigger.onPageLoad,
        effectsBuilder: () => [
          FadeEffect(
            curve: Curves.easeInOut,
            delay: 950.0.ms,
            duration: 200.0.ms,
            begin: 0.0,
            end: 1.0,
          ),
        ],
      ),
      'textOnPageLoadAnimation': AnimationInfo(
        trigger: AnimationTrigger.onPageLoad,
        effectsBuilder: () => [
          VisibilityEffect(duration: 1.ms),
          FadeEffect(
            curve: Curves.easeInOut,
            delay: 0.0.ms,
            duration: 200.0.ms,
            begin: 0.0,
            end: 1.0,
          ),
          MoveEffect(
            curve: Curves.easeInOut,
            delay: 0.0.ms,
            duration: 200.0.ms,
            begin: Offset(0.0, 40.0),
            end: Offset(0.0, 0.0),
          ),
        ],
      ),
      'buttonOnPageLoadAnimation': AnimationInfo(
        trigger: AnimationTrigger.onPageLoad,
        effectsBuilder: () => [
          VisibilityEffect(duration: 800.ms),
          FadeEffect(
            curve: Curves.bounceOut,
            delay: 0.0.ms,
            duration: 600.0.ms,
            begin: 0.0,
            end: 1.0,
          ),
          ScaleEffect(
            curve: Curves.bounceOut,
            delay: 0.0.ms,
            duration: 600.0.ms,
            begin: Offset(0.8, 1.0),
            end: Offset(1.0, 1.0),
          ),
        ],
      ),
    });

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
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Stack(
                          alignment: AlignmentDirectional(0.0, 0.0),
                          children: [
                            Align(
                              alignment: AlignmentDirectional(0.0, 0.0),
                              child: CircularPercentIndicator(
                                percent: 1.0,
                                radius: 70.0,
                                lineWidth: 12.0,
                                animation: true,
                                animateFromLastPercent: true,
                                progressColor: Color(0x9AFFFFFF),
                                backgroundColor: Color(0x4CFFFFFF),
                              ).animateOnPageLoad(animationsMap[
                                  'progressBarOnPageLoadAnimation']!),
                            ),
                            Align(
                              alignment: AlignmentDirectional(0.0, 0.0),
                              child: Icon(
                                Icons.check_rounded,
                                color: AppTheme.of(context).success,
                                size: 75.0,
                              ).animateOnPageLoad(
                                  animationsMap['iconOnPageLoadAnimation']!),
                            ),
                          ],
                        ),
                        if (_model.counter! < 100)
                          Align(
                            alignment: AlignmentDirectional(0.0, 0.0),
                            child: Padding(
                              padding: EdgeInsetsDirectional.fromSTEB(
                                  0.0, 10.0, 0.0, 0.0),
                              child: Text(
                                AppLocalizations.of(context).getText(
                                  'kred63vb' /* Device status: Connected! */,
                                ),
                                style: AppTheme.of(context)
                                    .headlineSmall
                                    .override(
                                      font: GoogleFonts.readexPro(
                                        fontWeight: AppTheme.of(context)
                                            .headlineSmall
                                            .fontWeight,
                                        fontStyle: AppTheme.of(context)
                                            .headlineSmall
                                            .fontStyle,
                                      ),
                                      letterSpacing: 0.0,
                                      fontWeight: AppTheme.of(context)
                                          .headlineSmall
                                          .fontWeight,
                                      fontStyle: AppTheme.of(context)
                                          .headlineSmall
                                          .fontStyle,
                                    ),
                              ).animateOnPageLoad(
                                  animationsMap['textOnPageLoadAnimation']!),
                            ),
                          ),
                        if (_model.counter! > 100)
                          Padding(
                            padding: EdgeInsetsDirectional.fromSTEB(
                                0.0, 16.0, 0.0, 0.0),
                            child: AppButtonWidget(
                              onPressed: () async {
                                context.safePop();
                              },
                              text: AppLocalizations.of(context).getText(
                                'e408bhw6' /* OK */,
                              ),
                              options: AppButtonOptions(
                                width: double.infinity,
                                height: 50.0,
                                padding: EdgeInsetsDirectional.fromSTEB(
                                    0.0, 0.0, 0.0, 0.0),
                                iconPadding: EdgeInsetsDirectional.fromSTEB(
                                    0.0, 0.0, 0.0, 0.0),
                                color: AppTheme.of(context).success,
                                textStyle: AppTheme.of(context)
                                    .titleMedium
                                    .override(
                                      font: GoogleFonts.readexPro(
                                        fontWeight: AppTheme.of(context)
                                            .titleMedium
                                            .fontWeight,
                                        fontStyle: AppTheme.of(context)
                                            .titleMedium
                                            .fontStyle,
                                      ),
                                      letterSpacing: 0.0,
                                      fontWeight: AppTheme.of(context)
                                          .titleMedium
                                          .fontWeight,
                                      fontStyle: AppTheme.of(context)
                                          .titleMedium
                                          .fontStyle,
                                    ),
                                elevation: 2.0,
                                borderSide: BorderSide(
                                  color: AppTheme.of(context).secondary,
                                  width: 2.0,
                                ),
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                            ).animateOnPageLoad(
                                animationsMap['buttonOnPageLoadAnimation']!),
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
