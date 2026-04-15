import '/app_core/app_animations.dart';
import '/app_core/app_theme.dart';
import '/app_core/app_util.dart';
import '/custom_code/actions/index.dart' as actions;
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'diagnose_card_model.dart';
export 'diagnose_card_model.dart';

class DiagnoseCardWidget extends StatefulWidget {
  const DiagnoseCardWidget({
    super.key,
    this.lastChecked,
    required this.name,
    required this.isHead,
    required this.wasNeverChecked,
  });

  final DateTime? lastChecked;
  final String? name;
  final bool? isHead;
  final bool? wasNeverChecked;

  @override
  State<DiagnoseCardWidget> createState() => _DiagnoseCardWidgetState();
}

class _DiagnoseCardWidgetState extends State<DiagnoseCardWidget>
    with TickerProviderStateMixin {
  late DiagnoseCardModel _model;

  final animationsMap = <String, AnimationInfo>{};

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => DiagnoseCardModel());

    // On component load action.
    SchedulerBinding.instance.addPostFrameCallback((_) async {
      if (widget.lastChecked != null) {
        _model.daysSince = await actions.daysSinceLastCheck(
          widget.lastChecked,
        );
        _model.didCheckPastWeek = _model.daysSince! < 7;
        safeSetState(() {});
      }
    });

    animationsMap.addAll({
      'containerOnPageLoadAnimation': AnimationInfo(
        trigger: AnimationTrigger.onPageLoad,
        effectsBuilder: () => [
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
            begin: Offset(0.0, 30.0),
            end: Offset(0.0, 0.0),
          ),
        ],
      ),
      'textOnPageLoadAnimation1': AnimationInfo(
        trigger: AnimationTrigger.onPageLoad,
        effectsBuilder: () => [
          VisibilityEffect(duration: 400.ms),
          FadeEffect(
            curve: Curves.bounceOut,
            delay: 400.0.ms,
            duration: 300.0.ms,
            begin: 0.0,
            end: 1.0,
          ),
          MoveEffect(
            curve: Curves.bounceOut,
            delay: 400.0.ms,
            duration: 300.0.ms,
            begin: Offset(0.0, 10.0),
            end: Offset(0.0, 0.0),
          ),
        ],
      ),
      'textOnPageLoadAnimation2': AnimationInfo(
        trigger: AnimationTrigger.onPageLoad,
        effectsBuilder: () => [
          VisibilityEffect(duration: 400.ms),
          FadeEffect(
            curve: Curves.bounceOut,
            delay: 400.0.ms,
            duration: 300.0.ms,
            begin: 0.0,
            end: 1.0,
          ),
          MoveEffect(
            curve: Curves.bounceOut,
            delay: 400.0.ms,
            duration: 300.0.ms,
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

    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.maybeDispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsetsDirectional.fromSTEB(16.0, 0.0, 16.0, 12.0),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: AppTheme.of(context).secondaryBackground,
          boxShadow: [
            BoxShadow(
              blurRadius: 4.0,
              color: Color(0x2C000000),
              offset: Offset(
                0.0,
                2.0,
              ),
            )
          ],
          borderRadius: BorderRadius.circular(12.0),
          border: Border.all(
            color: AppTheme.of(context).secondaryText,
            width: 1.0,
          ),
        ),
        child: Padding(
          padding: EdgeInsetsDirectional.fromSTEB(12.0, 8.0, 12.0, 12.0),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsetsDirectional.fromSTEB(0.0, 4.0, 0.0, 0.0),
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Padding(
                      padding:
                          EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 12.0, 0.0),
                      child: Card(
                        clipBehavior: Clip.antiAliasWithSaveLayer,
                        color: AppTheme.of(context).primaryBackground,
                        elevation: 0.0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(2.0),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12.0),
                            child: Image.network(
                              'https://cdn.pixabay.com/photo/2015/10/05/22/37/blank-profile-picture-973460_1280.png',
                              width: 60.0,
                              height: 60.0,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.max,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            Builder(
                              builder: (context) {
                                if (_model.didCheckPastWeek ?? false) {
                                  return Icon(
                                    Icons.check_circle,
                                    color: AppTheme.of(context).success,
                                    size: 24.0,
                                  );
                                } else {
                                  return Icon(
                                    Icons.error,
                                    color: AppTheme.of(context).warning,
                                    size: 24.0,
                                  );
                                }
                              },
                            ),
                            Text(
                              '${widget.name}${widget.isHead! ? '(You)' : ' '}',
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
                                animationsMap['textOnPageLoadAnimation1']!),
                          ],
                        ),
                        Padding(
                          padding: EdgeInsetsDirectional.fromSTEB(
                              0.0, 4.0, 0.0, 0.0),
                          child: Text(
                            'Last diagnosis: ${!widget.wasNeverChecked! ? 'Never' : dateTimeFormat(
                                "d/M/y",
                                widget.lastChecked,
                                locale:
                                    AppLocalizations.of(context).languageCode,
                              )}',
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
                                      color: (_model.didCheckPastWeek ?? false)
                                          ? AppTheme.of(context).success
                                          : AppTheme.of(context).error,
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
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ).animateOnPageLoad(animationsMap['containerOnPageLoadAnimation']!),
    );
  }
}
