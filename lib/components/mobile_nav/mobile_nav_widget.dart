import '/app_core/app_theme.dart';
import '/app_core/app_util.dart';
import '/index.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'mobile_nav_model.dart';
export 'mobile_nav_model.dart';

class MobileNavWidget extends StatefulWidget {
  const MobileNavWidget({
    super.key,
    this.iconOne,
    this.iconTwo,
    this.iconThree,
    this.iconFour,
    this.iconFive,
  });

  final Widget? iconOne;
  final Widget? iconTwo;
  final Widget? iconThree;
  final Widget? iconFour;
  final Widget? iconFive;

  @override
  State<MobileNavWidget> createState() => _MobileNavWidgetState();
}

class _MobileNavWidgetState extends State<MobileNavWidget> {
  late MobileNavModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => MobileNavModel());

    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.maybeDispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 110.0,
      decoration: BoxDecoration(
        color: AppTheme.of(context).secondaryBackground,
        boxShadow: [
          BoxShadow(
            blurRadius: 3.0,
            color: Color(0x33000000),
            offset: Offset(
              0.0,
              -1.0,
            ),
          )
        ],
      ),
      child: Padding(
        padding: EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 34.0),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: InkWell(
                splashColor: Colors.transparent,
                focusColor: Colors.transparent,
                hoverColor: Colors.transparent,
                highlightColor: Colors.transparent,
                onTap: () async {
                  context.pushNamed(
                    MainHomeWidget.routeName,
                    extra: <String, dynamic>{
                      kTransitionInfoKey: TransitionInfo(
                        hasTransition: true,
                        transitionType: PageTransitionType.fade,
                        duration: Duration(milliseconds: 0),
                      ),
                    },
                  );
                },
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    widget.iconOne!,
                    Padding(
                      padding:
                          EdgeInsetsDirectional.fromSTEB(0.0, 8.0, 0.0, 0.0),
                      child: Text(
                        AppLocalizations.of(context).getText(
                          'sy0pxvma' /* Dashboard */,
                        ),
                        style: AppTheme.of(context).bodyMedium.override(
                              font: GoogleFonts.inter(
                                fontWeight: AppTheme.of(context)
                                    .bodyMedium
                                    .fontWeight,
                                fontStyle: AppTheme.of(context)
                                    .bodyMedium
                                    .fontStyle,
                              ),
                              fontSize: 11.0,
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
                  ],
                ),
              ),
            ),
            Expanded(
              child: InkWell(
                splashColor: Colors.transparent,
                focusColor: Colors.transparent,
                hoverColor: Colors.transparent,
                highlightColor: Colors.transparent,
                onTap: () async {
                  context.pushNamed(
                    FamilyWidget.routeName,
                    extra: <String, dynamic>{
                      kTransitionInfoKey: TransitionInfo(
                        hasTransition: true,
                        transitionType: PageTransitionType.fade,
                        duration: Duration(milliseconds: 0),
                      ),
                    },
                  );
                },
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    widget.iconFive!,
                    Padding(
                      padding:
                          EdgeInsetsDirectional.fromSTEB(0.0, 8.0, 0.0, 0.0),
                      child: Text(
                        AppLocalizations.of(context).getText(
                          't5c3aiuy' /* My Team */,
                        ),
                        style: AppTheme.of(context).bodyMedium.override(
                              font: GoogleFonts.inter(
                                fontWeight: AppTheme.of(context)
                                    .bodyMedium
                                    .fontWeight,
                                fontStyle: AppTheme.of(context)
                                    .bodyMedium
                                    .fontStyle,
                              ),
                              fontSize: 11.0,
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
                  ],
                ),
              ),
            ),
            Expanded(
              child: InkWell(
                splashColor: Colors.transparent,
                focusColor: Colors.transparent,
                hoverColor: Colors.transparent,
                highlightColor: Colors.transparent,
                onTap: () async {
                  context.pushNamed(
                    MainDIagnosticsWidget.routeName,
                    extra: <String, dynamic>{
                      kTransitionInfoKey: TransitionInfo(
                        hasTransition: true,
                        transitionType: PageTransitionType.fade,
                        duration: Duration(milliseconds: 0),
                      ),
                    },
                  );
                },
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    widget.iconTwo!,
                    Padding(
                      padding:
                          EdgeInsetsDirectional.fromSTEB(0.0, 8.0, 0.0, 0.0),
                      child: Text(
                        AppLocalizations.of(context).getText(
                          'nkz3c58a' /* Customers */,
                        ),
                        style: AppTheme.of(context).bodyMedium.override(
                              font: GoogleFonts.inter(
                                fontWeight: AppTheme.of(context)
                                    .bodyMedium
                                    .fontWeight,
                                fontStyle: AppTheme.of(context)
                                    .bodyMedium
                                    .fontStyle,
                              ),
                              fontSize: 11.0,
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
                  ],
                ),
              ),
            ),
            Expanded(
              child: InkWell(
                splashColor: Colors.transparent,
                focusColor: Colors.transparent,
                hoverColor: Colors.transparent,
                highlightColor: Colors.transparent,
                onTap: () async {
                  context.pushNamed(
                    MainDiagnoseWidget.routeName,
                    extra: <String, dynamic>{
                      kTransitionInfoKey: TransitionInfo(
                        hasTransition: true,
                        transitionType: PageTransitionType.fade,
                        duration: Duration(milliseconds: 0),
                      ),
                    },
                  );
                },
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    widget.iconThree!,
                    Padding(
                      padding:
                          EdgeInsetsDirectional.fromSTEB(0.0, 8.0, 0.0, 0.0),
                      child: Text(
                        AppLocalizations.of(context).getText(
                          '1mkyyjwj' /* Contracts */,
                        ),
                        style: AppTheme.of(context).bodyMedium.override(
                              font: GoogleFonts.inter(
                                fontWeight: AppTheme.of(context)
                                    .bodyMedium
                                    .fontWeight,
                                fontStyle: AppTheme.of(context)
                                    .bodyMedium
                                    .fontStyle,
                              ),
                              fontSize: 11.0,
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
                  ],
                ),
              ),
            ),
            Expanded(
              child: InkWell(
                splashColor: Colors.transparent,
                focusColor: Colors.transparent,
                hoverColor: Colors.transparent,
                highlightColor: Colors.transparent,
                onTap: () async {
                  context.pushNamed(
                    MainProfilePageWidget.routeName,
                    extra: <String, dynamic>{
                      kTransitionInfoKey: TransitionInfo(
                        hasTransition: true,
                        transitionType: PageTransitionType.fade,
                        duration: Duration(milliseconds: 0),
                      ),
                    },
                  );
                },
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    widget.iconFour!,
                    Padding(
                      padding:
                          EdgeInsetsDirectional.fromSTEB(0.0, 8.0, 0.0, 0.0),
                      child: Text(
                        AppLocalizations.of(context).getText(
                          'eg79coc6' /* Profile */,
                        ),
                        style: AppTheme.of(context).bodyMedium.override(
                              font: GoogleFonts.inter(
                                fontWeight: AppTheme.of(context)
                                    .bodyMedium
                                    .fontWeight,
                                fontStyle: AppTheme.of(context)
                                    .bodyMedium
                                    .fontStyle,
                              ),
                              fontSize: 11.0,
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
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
