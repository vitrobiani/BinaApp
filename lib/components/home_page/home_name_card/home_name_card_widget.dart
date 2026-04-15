import '/app_core/app_animations.dart';
import '/app_core/app_theme.dart';
import '/app_core/app_util.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'home_name_card_model.dart';
export 'home_name_card_model.dart';

class HomeNameCardWidget extends StatefulWidget {
  const HomeNameCardWidget({
    super.key,
    required this.name,
    required this.lastChecked,
  });

  final String? name;
  final String? lastChecked;

  @override
  State<HomeNameCardWidget> createState() => _HomeNameCardWidgetState();
}

class _HomeNameCardWidgetState extends State<HomeNameCardWidget>
    with TickerProviderStateMixin {
  late HomeNameCardModel _model;

  final animationsMap = <String, AnimationInfo>{};

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => HomeNameCardModel());

    animationsMap.addAll({
      'containerOnPageLoadAnimation1': AnimationInfo(
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
            begin: Offset(100.0, 0.0),
            end: Offset(0.0, 0.0),
          ),
        ],
      ),
      'containerOnPageLoadAnimation2': AnimationInfo(
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
          ScaleEffect(
            curve: Curves.easeInOut,
            delay: 0.0.ms,
            duration: 600.0.ms,
            begin: Offset(0.8, 1.0),
            end: Offset(1.0, 1.0),
          ),
        ],
      ),
      'textOnPageLoadAnimation1': AnimationInfo(
        trigger: AnimationTrigger.onPageLoad,
        effectsBuilder: () => [
          VisibilityEffect(duration: 180.ms),
          FadeEffect(
            curve: Curves.easeInOut,
            delay: 180.0.ms,
            duration: 600.0.ms,
            begin: 0.0,
            end: 1.0,
          ),
          MoveEffect(
            curve: Curves.easeInOut,
            delay: 180.0.ms,
            duration: 600.0.ms,
            begin: Offset(20.0, 0.0),
            end: Offset(0.0, 0.0),
          ),
        ],
      ),
      'textOnPageLoadAnimation2': AnimationInfo(
        trigger: AnimationTrigger.onPageLoad,
        effectsBuilder: () => [
          VisibilityEffect(duration: 200.ms),
          FadeEffect(
            curve: Curves.easeInOut,
            delay: 200.0.ms,
            duration: 600.0.ms,
            begin: 0.0,
            end: 1.0,
          ),
          MoveEffect(
            curve: Curves.easeInOut,
            delay: 200.0.ms,
            duration: 600.0.ms,
            begin: Offset(40.0, 0.0),
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
      padding: EdgeInsetsDirectional.fromSTEB(16.0, 0.0, 0.0, 12.0),
      child: Container(
        height: 120.0,
        decoration: BoxDecoration(
          color: AppTheme.of(context).secondaryBackground,
          boxShadow: [
            BoxShadow(
              blurRadius: 4.0,
              color: Color(0x1F000000),
              offset: Offset(
                0.0,
                2.0,
              ),
            )
          ],
          borderRadius: BorderRadius.circular(8.0),
          border: Border.all(
            color: AppTheme.of(context).primaryBackground,
            width: 1.0,
          ),
        ),
        child: Padding(
          padding: EdgeInsetsDirectional.fromSTEB(12.0, 0.0, 12.0, 0.0),
          child: Row(
            mainAxisSize: MainAxisSize.max,
            children: [
              Container(
                width: 60.0,
                height: 60.0,
                decoration: BoxDecoration(
                  color: AppTheme.of(context).primaryBackground,
                  shape: BoxShape.circle,
                ),
                alignment: AlignmentDirectional(0.0, 0.0),
                child: Card(
                  clipBehavior: Clip.antiAliasWithSaveLayer,
                  color: Color(0xFF77DD77),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(40.0),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(12.0),
                    child: Icon(
                      Icons.person,
                      color: AppTheme.of(context).primaryText,
                      size: 24.0,
                    ),
                  ),
                ),
              ).animateOnPageLoad(
                  animationsMap['containerOnPageLoadAnimation2']!),
              Padding(
                padding: EdgeInsets.all(12.0),
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      valueOrDefault<String>(
                        widget.name,
                        'def',
                      ),
                      style: AppTheme.of(context).bodySmall.override(
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
                        animationsMap['textOnPageLoadAnimation1']!),
                    Padding(
                      padding:
                          EdgeInsetsDirectional.fromSTEB(0.0, 8.0, 0.0, 0.0),
                      child: Text(
                        'Checked: ${widget.lastChecked != null && widget.lastChecked != '' ? widget.lastChecked : 'never checked'}',
                        style:
                            AppTheme.of(context).displaySmall.override(
                                  font: GoogleFonts.readexPro(
                                    fontWeight: AppTheme.of(context)
                                        .displaySmall
                                        .fontWeight,
                                    fontStyle: AppTheme.of(context)
                                        .displaySmall
                                        .fontStyle,
                                  ),
                                  fontSize: 21.0,
                                  letterSpacing: 0.0,
                                  fontWeight: AppTheme.of(context)
                                      .displaySmall
                                      .fontWeight,
                                  fontStyle: AppTheme.of(context)
                                      .displaySmall
                                      .fontStyle,
                                ),
                      ).animateOnPageLoad(
                          animationsMap['textOnPageLoadAnimation2']!),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ).animateOnPageLoad(animationsMap['containerOnPageLoadAnimation1']!),
    );
  }
}
