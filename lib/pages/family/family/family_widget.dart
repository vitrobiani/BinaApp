import '/backend/schema/enums/enums.dart';
import '/app_core/app_animations.dart';
import '/app_core/app_icon_button.dart';
import '/app_core/app_theme.dart';
import '/app_core/app_util.dart';
import '/app_core/app_widgets.dart';
import '/pages/family/family_member/family_member_widget.dart';
import '/pages/family/family_row_detail/family_row_detail_widget.dart';
import '/actions/actions.dart' as action_blocks;
import '/index.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'family_model.dart';
export 'family_model.dart';

class FamilyWidget extends StatefulWidget {
  const FamilyWidget({super.key});

  static String routeName = 'Family';
  static String routePath = 'family';

  @override
  State<FamilyWidget> createState() => _FamilyWidgetState();
}

class _FamilyWidgetState extends State<FamilyWidget>
    with TickerProviderStateMixin {
  late FamilyModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  final animationsMap = <String, AnimationInfo>{};

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => FamilyModel());

    _model.emailAddressTextController ??= TextEditingController();
    _model.emailAddressFocusNode ??= FocusNode();

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
        body: Stack(
          children: [
            Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 10,
                        child: SingleChildScrollView(
                          primary: false,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
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
                                  child: Row(
                                    mainAxisSize: MainAxisSize.max,
                                    children: [
                                      if (responsiveVisibility(
                                        context: context,
                                        phone: false,
                                        tablet: false,
                                      ))
                                        Padding(
                                          padding:
                                              EdgeInsetsDirectional.fromSTEB(
                                                  0.0, 0.0, 10.0, 0.0),
                                          child: AppIconButton(
                                            borderColor: Colors.transparent,
                                            borderRadius: 30.0,
                                            borderWidth: 1.0,
                                            buttonSize: 60.0,
                                            icon: Icon(
                                              Icons.arrow_back_ios_rounded,
                                              color:
                                                  AppTheme.of(context)
                                                      .primaryText,
                                              size: 35.0,
                                            ),
                                            onPressed: () async {
                                              context.pushNamed(
                                                  MainProfilePageWidget
                                                      .routeName);
                                            },
                                          ),
                                        ),
                                      Expanded(
                                        flex: 7,
                                        child: Padding(
                                          padding:
                                              EdgeInsetsDirectional.fromSTEB(
                                                  16.0, 16.0, 0.0, 16.0),
                                          child: Text(
                                            AppLocalizations.of(context).getText(
                                              '609lph0v' /* My Family */,
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
                                          ).animateOnPageLoad(animationsMap[
                                              'textOnPageLoadAnimation']!),
                                        ),
                                      ),
                                      if (responsiveVisibility(
                                        context: context,
                                        phone: false,
                                        tablet: false,
                                      ))
                                        Expanded(
                                          flex: 4,
                                          child: Padding(
                                            padding:
                                                EdgeInsetsDirectional.fromSTEB(
                                                    0.0, 8.0, 16.0, 8.0),
                                            child: TextFormField(
                                              controller: _model
                                                  .emailAddressTextController,
                                              focusNode:
                                                  _model.emailAddressFocusNode,
                                              obscureText: false,
                                              decoration: InputDecoration(
                                                labelStyle:
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
                                                hintStyle: AppTheme.of(
                                                        context)
                                                    .bodyMedium
                                                    .override(
                                                      font: GoogleFonts
                                                          .lexendDeca(
                                                        fontWeight:
                                                            FontWeight.normal,
                                                        fontStyle:
                                                            AppTheme.of(
                                                                    context)
                                                                .bodyMedium
                                                                .fontStyle,
                                                      ),
                                                      color: Color(0xFF57636C),
                                                      fontSize: 14.0,
                                                      letterSpacing: 0.0,
                                                      fontWeight:
                                                          FontWeight.normal,
                                                      fontStyle:
                                                          AppTheme.of(
                                                                  context)
                                                              .bodyMedium
                                                              .fontStyle,
                                                    ),
                                                enabledBorder:
                                                    OutlineInputBorder(
                                                  borderSide: BorderSide(
                                                    color: AppTheme.of(
                                                            context)
                                                        .lineColor,
                                                    width: 2.0,
                                                  ),
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          40.0),
                                                ),
                                                focusedBorder:
                                                    OutlineInputBorder(
                                                  borderSide: BorderSide(
                                                    color: Color(0x00000000),
                                                    width: 2.0,
                                                  ),
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          40.0),
                                                ),
                                                errorBorder: OutlineInputBorder(
                                                  borderSide: BorderSide(
                                                    color: Color(0x00000000),
                                                    width: 2.0,
                                                  ),
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          40.0),
                                                ),
                                                focusedErrorBorder:
                                                    OutlineInputBorder(
                                                  borderSide: BorderSide(
                                                    color: Color(0x00000000),
                                                    width: 2.0,
                                                  ),
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          40.0),
                                                ),
                                                filled: true,
                                                fillColor:
                                                    AppTheme.of(context)
                                                        .secondaryBackground,
                                                contentPadding:
                                                    EdgeInsetsDirectional
                                                        .fromSTEB(24.0, 12.0,
                                                            20.0, 12.0),
                                                prefixIcon: Icon(
                                                  Icons.search_rounded,
                                                  color: AppTheme.of(
                                                          context)
                                                      .secondaryText,
                                                ),
                                              ),
                                              style:
                                                  AppTheme.of(context)
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
                                              validator: _model
                                                  .emailAddressTextControllerValidator
                                                  .asValidator(context),
                                            ),
                                          ),
                                        ),
                                      if (responsiveVisibility(
                                        context: context,
                                        tabletLandscape: false,
                                        desktop: false,
                                      ))
                                        Padding(
                                          padding:
                                              EdgeInsetsDirectional.fromSTEB(
                                                  0.0, 0.0, 10.0, 0.0),
                                          child: AppIconButton(
                                            borderColor: Colors.transparent,
                                            borderRadius: 30.0,
                                            borderWidth: 1.0,
                                            buttonSize: 60.0,
                                            icon: Icon(
                                              Icons.arrow_forward_ios_rounded,
                                              color:
                                                  AppTheme.of(context)
                                                      .primaryText,
                                              size: 30.0,
                                            ),
                                            onPressed: () async {
                                              context.pushNamed(
                                                  MainProfilePageWidget
                                                      .routeName);
                                            },
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                              Padding(
                                padding: EdgeInsetsDirectional.fromSTEB(
                                    16.0, 12.0, 16.0, 0.0),
                                child: Container(
                                  width: MediaQuery.sizeOf(context).width * 1.0,
                                  decoration: BoxDecoration(
                                    color: AppTheme.of(context)
                                        .secondaryBackground,
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
                                      color: AppTheme.of(context)
                                          .primaryBackground,
                                      width: 1.0,
                                    ),
                                  ),
                                  child: Builder(
                                    builder: (context) {
                                      final fam = AppState()
                                          .UserSession
                                          .family
                                          .toList();

                                      return Column(
                                        mainAxisSize: MainAxisSize.max,
                                        children: List.generate(fam.length,
                                            (famIndex) {
                                          final famItem = fam[famIndex];
                                          return wrapWithModel(
                                            model: _model.familyRowDetailModels
                                                .getModel(
                                              famIndex.toString(),
                                              famIndex,
                                            ),
                                            updateCallback: () =>
                                                safeSetState(() {}),
                                            child: FamilyRowDetailWidget(
                                              key: Key(
                                                'Key9n9_${famIndex.toString()}',
                                              ),
                                              name: famItem.name,
                                              score: famItem.score,
                                              lastChecked: famItem.lastChecked!,
                                              age: 0,
                                              gender: Genders.RND,
                                            ),
                                          );
                                        }),
                                      );
                                    },
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
              ],
            ),
            Align(
              alignment: AlignmentDirectional(1.0, 1.0),
              child: Padding(
                padding: EdgeInsets.all(24.0),
                child: AppButtonWidget(
                  onPressed: () async {
                    await showModalBottomSheet(
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      enableDrag: false,
                      context: context,
                      builder: (context) {
                        return GestureDetector(
                          onTap: () {
                            FocusScope.of(context).unfocus();
                            FocusManager.instance.primaryFocus?.unfocus();
                          },
                          child: Padding(
                            padding: MediaQuery.viewInsetsOf(context),
                            child: FamilyMemberWidget(),
                          ),
                        );
                      },
                    ).then((value) => safeSetState(() {}));
                  },
                  text: AppLocalizations.of(context).getText(
                    'ww48hqky' /* + */,
                  ),
                  options: AppButtonOptions(
                    width: 60.0,
                    height: 60.0,
                    padding:
                        EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 12.0),
                    iconPadding:
                        EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 0.0),
                    color: AppTheme.of(context).secondary,
                    textStyle: AppTheme.of(context).titleSmall.override(
                          font: GoogleFonts.inter(
                            fontWeight: AppTheme.of(context)
                                .titleSmall
                                .fontWeight,
                            fontStyle: AppTheme.of(context)
                                .titleSmall
                                .fontStyle,
                          ),
                          color: Colors.white,
                          fontSize: 70.0,
                          letterSpacing: 0.0,
                          fontWeight: AppTheme.of(context)
                              .titleSmall
                              .fontWeight,
                          fontStyle:
                              AppTheme.of(context).titleSmall.fontStyle,
                        ),
                    elevation: 0.0,
                    borderRadius: BorderRadius.circular(14.0),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
