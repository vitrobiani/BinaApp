import '/app_core/app_animations.dart';
import '/app_core/app_icon_button.dart';
import '/app_core/app_theme.dart';
import '/app_core/app_util.dart';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'accessability_model.dart';
export 'accessability_model.dart';

class AccessabilityWidget extends StatefulWidget {
  const AccessabilityWidget({super.key});

  @override
  State<AccessabilityWidget> createState() => _AccessabilityWidgetState();
}

class _AccessabilityWidgetState extends State<AccessabilityWidget>
    with TickerProviderStateMixin {
  late AccessabilityModel _model;

  final animationsMap = <String, AnimationInfo>{};

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => AccessabilityModel());

    animationsMap.addAll({
      'containerOnPageLoadAnimation1': AnimationInfo(
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
        ],
      ),
      'containerOnPageLoadAnimation2': AnimationInfo(
        trigger: AnimationTrigger.onPageLoad,
        effectsBuilder: () => [
          VisibilityEffect(duration: 200.ms),
          MoveEffect(
            curve: Curves.easeInOut,
            delay: 200.0.ms,
            duration: 400.0.ms,
            begin: Offset(0.0, 100.0),
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
    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: 5.0,
          sigmaY: 4.0,
        ),
        child: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            color: AppTheme.of(context).primary,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              if (responsiveVisibility(
                context: context,
                phone: false,
              ))
                Container(
                  width: 100.0,
                  height: 100.0,
                  decoration: BoxDecoration(),
                ),
              Padding(
                padding: EdgeInsetsDirectional.fromSTEB(0.0, 24.0, 0.0, 0.0),
                child: Container(
                  width: double.infinity,
                  constraints: BoxConstraints(
                    maxWidth: 530.0,
                  ),
                  decoration: BoxDecoration(),
                  child: Padding(
                    padding: EdgeInsets.all(12.0),
                    child: Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        AppIconButton(
                          borderColor: Colors.transparent,
                          borderRadius: 30.0,
                          borderWidth: 1.0,
                          buttonSize: 44.0,
                          fillColor: AppTheme.of(context).primary,
                          icon: Icon(
                            Icons.close_rounded,
                            color:
                                AppTheme.of(context).primaryBackground,
                            size: 24.0,
                          ),
                          onPressed: () async {
                            Navigator.pop(context);
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(12.0),
                child: Container(
                  width: double.infinity,
                  constraints: BoxConstraints(
                    maxWidth: 530.0,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.of(context).secondaryBackground,
                    boxShadow: [
                      BoxShadow(
                        blurRadius: 12.0,
                        color: Color(0x1E000000),
                        offset: Offset(
                          0.0,
                          5.0,
                        ),
                      )
                    ],
                    borderRadius: BorderRadius.circular(16.0),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding:
                            EdgeInsetsDirectional.fromSTEB(0.0, 8.0, 0.0, 4.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.max,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: EdgeInsetsDirectional.fromSTEB(
                                  24.0, 12.0, 0.0, 12.0),
                              child: Text(
                                AppLocalizations.of(context).getText(
                                  'pw6kvl1f' /* Prefrences and Accessabiliry */,
                                ),
                                style: AppTheme.of(context)
                                    .bodyMedium
                                    .override(
                                      font: GoogleFonts.inter(
                                        fontWeight: FontWeight.bold,
                                        fontStyle: AppTheme.of(context)
                                            .bodyMedium
                                            .fontStyle,
                                      ),
                                      fontSize: 12.0,
                                      letterSpacing: 0.0,
                                      fontWeight: FontWeight.bold,
                                      fontStyle: AppTheme.of(context)
                                          .bodyMedium
                                          .fontStyle,
                                    ),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsetsDirectional.fromSTEB(
                                  0.0, 0.0, 0.0, 1.0),
                              child: Container(
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  color: AppTheme.of(context)
                                      .secondaryBackground,
                                  boxShadow: [
                                    BoxShadow(
                                      blurRadius: 0.0,
                                      color: AppTheme.of(context)
                                          .lineColor,
                                      offset: Offset(
                                        0.0,
                                        1.0,
                                      ),
                                    )
                                  ],
                                  borderRadius: BorderRadius.circular(0.0),
                                  shape: BoxShape.rectangle,
                                ),
                                child: Padding(
                                  padding: EdgeInsetsDirectional.fromSTEB(
                                      24.0, 12.0, 16.0, 12.0),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.max,
                                    children: [
                                      Icon(
                                        Icons.text_fields,
                                        color: AppTheme.of(context)
                                            .secondaryText,
                                        size: 24.0,
                                      ),
                                      Expanded(
                                        child: Padding(
                                          padding:
                                              EdgeInsetsDirectional.fromSTEB(
                                                  12.0, 0.0, 0.0, 0.0),
                                          child: Text(
                                            AppLocalizations.of(context).getText(
                                              'gckukxjv' /* Text Settings */,
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
                                      ),
                                      Icon(
                                        Icons.arrow_forward_ios,
                                        color: AppTheme.of(context)
                                            .secondaryText,
                                        size: 18.0,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            ListView(
                              padding: EdgeInsets.zero,
                              shrinkWrap: true,
                              scrollDirection: Axis.vertical,
                              children: [
                                Padding(
                                  padding: EdgeInsetsDirectional.fromSTEB(
                                      0.0, 0.0, 0.0, 1.0),
                                  child: Container(
                                    width: double.infinity,
                                    decoration: BoxDecoration(
                                      color: AppTheme.of(context)
                                          .secondaryBackground,
                                      boxShadow: [
                                        BoxShadow(
                                          blurRadius: 0.0,
                                          color: AppTheme.of(context)
                                              .lineColor,
                                          offset: Offset(
                                            0.0,
                                            1.0,
                                          ),
                                        )
                                      ],
                                      borderRadius: BorderRadius.circular(0.0),
                                      shape: BoxShape.rectangle,
                                    ),
                                    child: Padding(
                                      padding: EdgeInsetsDirectional.fromSTEB(
                                          24.0, 12.0, 16.0, 12.0),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.max,
                                        children: [
                                          Icon(
                                            Icons.palette,
                                            color: AppTheme.of(context)
                                                .secondaryText,
                                            size: 24.0,
                                          ),
                                          Expanded(
                                            child: Padding(
                                              padding: EdgeInsetsDirectional
                                                  .fromSTEB(
                                                      12.0, 0.0, 0.0, 0.0),
                                              child: Text(
                                                AppLocalizations.of(context)
                                                    .getText(
                                                  'zsq8vj02' /* Color and Theme */,
                                                ),
                                                style:
                                                    AppTheme.of(context)
                                                        .bodySmall
                                                        .override(
                                                          font:
                                                              GoogleFonts.inter(
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
                                          ),
                                          Icon(
                                            Icons.arrow_forward_ios,
                                            color: AppTheme.of(context)
                                                .secondaryText,
                                            size: 18.0,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsetsDirectional.fromSTEB(
                                      0.0, 0.0, 0.0, 1.0),
                                  child: Container(
                                    width: double.infinity,
                                    decoration: BoxDecoration(
                                      color: AppTheme.of(context)
                                          .secondaryBackground,
                                      boxShadow: [
                                        BoxShadow(
                                          blurRadius: 0.0,
                                          color: AppTheme.of(context)
                                              .lineColor,
                                          offset: Offset(
                                            0.0,
                                            1.0,
                                          ),
                                        )
                                      ],
                                      borderRadius: BorderRadius.circular(0.0),
                                      shape: BoxShape.rectangle,
                                    ),
                                    child: Padding(
                                      padding: EdgeInsetsDirectional.fromSTEB(
                                          24.0, 12.0, 16.0, 12.0),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.max,
                                        children: [
                                          Icon(
                                            Icons.language_sharp,
                                            color: AppTheme.of(context)
                                                .secondaryText,
                                            size: 24.0,
                                          ),
                                          Expanded(
                                            child: Padding(
                                              padding: EdgeInsetsDirectional
                                                  .fromSTEB(
                                                      12.0, 0.0, 0.0, 0.0),
                                              child: Text(
                                                AppLocalizations.of(context)
                                                    .getText(
                                                  'iqxwv326' /* Language and Region */,
                                                ),
                                                style:
                                                    AppTheme.of(context)
                                                        .bodySmall
                                                        .override(
                                                          font:
                                                              GoogleFonts.inter(
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
                                          ),
                                          Icon(
                                            Icons.arrow_forward_ios,
                                            color: AppTheme.of(context)
                                                .secondaryText,
                                            size: 18.0,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsetsDirectional.fromSTEB(
                                      0.0, 0.0, 0.0, 1.0),
                                  child: Container(
                                    width: double.infinity,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(0.0),
                                      shape: BoxShape.rectangle,
                                    ),
                                    child: Padding(
                                      padding: EdgeInsetsDirectional.fromSTEB(
                                          24.0, 12.0, 16.0, 12.0),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.max,
                                        children: [
                                          Icon(
                                            Icons.question_mark_sharp,
                                            color: AppTheme.of(context)
                                                .secondaryText,
                                            size: 24.0,
                                          ),
                                          Expanded(
                                            child: Padding(
                                              padding: EdgeInsetsDirectional
                                                  .fromSTEB(
                                                      12.0, 0.0, 0.0, 0.0),
                                              child: Text(
                                                AppLocalizations.of(context)
                                                    .getText(
                                                  's60yfg0g' /* Help and Support */,
                                                ),
                                                style:
                                                    AppTheme.of(context)
                                                        .bodySmall
                                                        .override(
                                                          font:
                                                              GoogleFonts.inter(
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
                                          ),
                                          Icon(
                                            Icons.arrow_forward_ios,
                                            color: AppTheme.of(context)
                                                .secondaryText,
                                            size: 18.0,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ).animateOnPageLoad(
                    animationsMap['containerOnPageLoadAnimation2']!),
              ),
            ],
          ),
        ).animateOnPageLoad(animationsMap['containerOnPageLoadAnimation1']!),
      ),
    );
  }
}
