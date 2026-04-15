import '/auth/supabase_auth/auth_util.dart';
import '/backend/schema/enums/enums.dart';
import '/backend/schema/structs/index.dart';
import '/backend/sqlite/sqlite_manager.dart';
import '/backend/supabase/supabase.dart';
import '/app_state.dart';
import '/app_core/app_animations.dart';
import '/app_core/app_drop_down.dart';
import '/app_core/app_theme.dart';
import '/app_core/app_util.dart';
import '/app_core/app_widgets.dart';
import '/app_core/form_field_controller.dart';
import '/custom_code/actions/index.dart' as actions;
import '/app_core/custom_functions.dart' as functions;
import '/index.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'auth2_create_model.dart';
export 'auth2_create_model.dart';

class Auth2CreateWidget extends StatefulWidget {
  const Auth2CreateWidget({super.key});

  static String routeName = 'auth_2_Create';
  static String routePath = 'auth2Create';

  @override
  State<Auth2CreateWidget> createState() => _Auth2CreateWidgetState();
}

class _Auth2CreateWidgetState extends State<Auth2CreateWidget>
    with TickerProviderStateMixin {
  late Auth2CreateModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  final animationsMap = <String, AnimationInfo>{};

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => Auth2CreateModel());

    _model.switchValue = true;
    _model.nameTextController ??= TextEditingController();
    _model.nameFocusNode ??= FocusNode();

    _model.emailAddressTextController ??= TextEditingController();
    _model.emailAddressFocusNode ??= FocusNode();

    _model.passwordTextController ??= TextEditingController();
    _model.passwordFocusNode ??= FocusNode();

    _model.ageTextController ??= TextEditingController();
    _model.ageFocusNode ??= FocusNode();
    _model.ageFocusNode!.addListener(() => safeSetState(() {}));
    _model.ageMask = MaskTextInputFormatter(mask: '##/##/####');
    animationsMap.addAll({
      'containerOnPageLoadAnimation': AnimationInfo(
        trigger: AnimationTrigger.onPageLoad,
        effectsBuilder: () => [
          VisibilityEffect(duration: 1.ms),
          FadeEffect(
            curve: Curves.easeInOut,
            delay: 0.0.ms,
            duration: 300.0.ms,
            begin: 0.0,
            end: 1.0,
          ),
          MoveEffect(
            curve: Curves.easeInOut,
            delay: 0.0.ms,
            duration: 300.0.ms,
            begin: Offset(0.0, -140.0),
            end: Offset(0.0, 0.0),
          ),
          ScaleEffect(
            curve: Curves.easeInOut,
            delay: 0.0.ms,
            duration: 300.0.ms,
            begin: Offset(0.9, 0.9),
            end: Offset(1.0, 1.0),
          ),
          TiltEffect(
            curve: Curves.easeInOut,
            delay: 0.0.ms,
            duration: 300.0.ms,
            begin: Offset(0.349, 0),
            end: Offset(0, 0),
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
        body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppTheme.of(context).alternate,
                AppTheme.of(context).primaryBackground
              ],
              stops: [0.0, 1.0],
              begin: AlignmentDirectional(0.87, -1.0),
              end: AlignmentDirectional(-0.87, 1.0),
            ),
          ),
          alignment: AlignmentDirectional(0.0, -1.0),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: EdgeInsetsDirectional.fromSTEB(0.0, 70.0, 0.0, 32.0),
                  child: Container(
                    width: 300.0,
                    height: 70.0,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16.0),
                    ),
                    alignment: AlignmentDirectional(0.0, 0.0),
                    child: Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Padding(
                          padding: EdgeInsetsDirectional.fromSTEB(
                              0.0, 0.0, 12.0, 0.0),
                          child: Icon(
                            Icons.flourescent_rounded,
                            color: AppTheme.of(context).info,
                            size: 50.0,
                          ),
                        ),
                        Text(
                          AppLocalizations.of(context).getText(
                            '7x498wvw' /* Bina  */,
                          ),
                          style: AppTheme.of(context)
                              .displayMedium
                              .override(
                                font: GoogleFonts.readexPro(
                                  fontWeight: FontWeight.w600,
                                  fontStyle: AppTheme.of(context)
                                      .displayMedium
                                      .fontStyle,
                                ),
                                fontSize: 55.0,
                                letterSpacing: 0.0,
                                fontWeight: FontWeight.w600,
                                fontStyle: AppTheme.of(context)
                                    .displayMedium
                                    .fontStyle,
                              ),
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Material(
                    color: Colors.transparent,
                    elevation: 100.0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    child: Container(
                      width: double.infinity,
                      constraints: BoxConstraints(
                        maxWidth: 650.0,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.of(context).secondaryBackground,
                        boxShadow: [
                          BoxShadow(
                            blurRadius: 4.0,
                            color: Color(0x33000000),
                            offset: Offset(
                              0.0,
                              2.0,
                            ),
                          )
                        ],
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      child: Align(
                        alignment: AlignmentDirectional(0.0, 0.0),
                        child: Padding(
                          padding: EdgeInsets.all(32.0),
                          child: Column(
                            mainAxisSize: MainAxisSize.max,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                AppLocalizations.of(context).getText(
                                  'pwekpcwd' /* Get Started */,
                                ),
                                textAlign: TextAlign.center,
                                style: AppTheme.of(context)
                                    .displaySmall
                                    .override(
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
                              Padding(
                                padding: EdgeInsetsDirectional.fromSTEB(
                                    0.0, 8.0, 0.0, 24.0),
                                child: Text(
                                  AppLocalizations.of(context).getText(
                                    'gu5o6pdk' /* Create an account by using the... */,
                                  ),
                                  textAlign: TextAlign.start,
                                  style: AppTheme.of(context)
                                      .labelLarge
                                      .override(
                                        font: GoogleFonts.inter(
                                          fontWeight:
                                              AppTheme.of(context)
                                                  .labelLarge
                                                  .fontWeight,
                                          fontStyle:
                                              AppTheme.of(context)
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
                              if (!isWeb)
                                Container(
                                  width: double.infinity,
                                  height: 50.0,
                                  decoration: BoxDecoration(
                                    color: AppTheme.of(context)
                                        .secondaryBackground,
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.max,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Switch.adaptive(
                                        value: _model.switchValue!,
                                        onChanged: (newValue) async {
                                          safeSetState(() =>
                                              _model.switchValue = newValue);
                                        },
                                        activeColor:
                                            AppTheme.of(context)
                                                .alternate,
                                        activeTrackColor:
                                            AppTheme.of(context)
                                                .success,
                                        inactiveTrackColor:
                                            AppTheme.of(context)
                                                .alternate,
                                        inactiveThumbColor:
                                            AppTheme.of(context)
                                                .secondaryBackground,
                                      ),
                                      Text(
                                        _model.switchValue! ? 'Cloud' : 'Local',
                                        style: AppTheme.of(context)
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
                                      ),
                                    ],
                                  ),
                                ),
                              Padding(
                                padding: EdgeInsetsDirectional.fromSTEB(
                                    0.0, 0.0, 0.0, 16.0),
                                child: Container(
                                  width: double.infinity,
                                  child: TextFormField(
                                    controller: _model.nameTextController,
                                    focusNode: _model.nameFocusNode,
                                    autofocus: true,
                                    autofillHints: [AutofillHints.email],
                                    obscureText: false,
                                    decoration: InputDecoration(
                                      labelText:
                                          AppLocalizations.of(context).getText(
                                        'c71pv0m4' /* name */,
                                      ),
                                      labelStyle: AppTheme.of(context)
                                          .labelLarge
                                          .override(
                                            font: GoogleFonts.inter(
                                              fontWeight:
                                                  AppTheme.of(context)
                                                      .labelLarge
                                                      .fontWeight,
                                              fontStyle:
                                                  AppTheme.of(context)
                                                      .labelLarge
                                                      .fontStyle,
                                            ),
                                            letterSpacing: 0.0,
                                            fontWeight:
                                                AppTheme.of(context)
                                                    .labelLarge
                                                    .fontWeight,
                                            fontStyle:
                                                AppTheme.of(context)
                                                    .labelLarge
                                                    .fontStyle,
                                          ),
                                      enabledBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                          color: AppTheme.of(context)
                                              .alternate,
                                          width: 2.0,
                                        ),
                                        borderRadius:
                                            BorderRadius.circular(12.0),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                          color: AppTheme.of(context)
                                              .primary,
                                          width: 2.0,
                                        ),
                                        borderRadius:
                                            BorderRadius.circular(12.0),
                                      ),
                                      errorBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                          color: AppTheme.of(context)
                                              .error,
                                          width: 2.0,
                                        ),
                                        borderRadius:
                                            BorderRadius.circular(12.0),
                                      ),
                                      focusedErrorBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                          color: AppTheme.of(context)
                                              .error,
                                          width: 2.0,
                                        ),
                                        borderRadius:
                                            BorderRadius.circular(12.0),
                                      ),
                                      filled: true,
                                      fillColor: AppTheme.of(context)
                                          .primaryBackground,
                                    ),
                                    style: AppTheme.of(context)
                                        .bodyLarge
                                        .override(
                                          font: GoogleFonts.inter(
                                            fontWeight:
                                                AppTheme.of(context)
                                                    .bodyLarge
                                                    .fontWeight,
                                            fontStyle:
                                                AppTheme.of(context)
                                                    .bodyLarge
                                                    .fontStyle,
                                          ),
                                          letterSpacing: 0.0,
                                          fontWeight:
                                              AppTheme.of(context)
                                                  .bodyLarge
                                                  .fontWeight,
                                          fontStyle:
                                              AppTheme.of(context)
                                                  .bodyLarge
                                                  .fontStyle,
                                        ),
                                    keyboardType: TextInputType.name,
                                    cursorColor:
                                        AppTheme.of(context).primary,
                                    validator: _model
                                        .nameTextControllerValidator
                                        .asValidator(context),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: EdgeInsetsDirectional.fromSTEB(
                                    0.0, 0.0, 0.0, 16.0),
                                child: Container(
                                  width: double.infinity,
                                  child: TextFormField(
                                    controller:
                                        _model.emailAddressTextController,
                                    focusNode: _model.emailAddressFocusNode,
                                    autofocus: true,
                                    autofillHints: [AutofillHints.email],
                                    obscureText: false,
                                    decoration: InputDecoration(
                                      labelText:
                                          AppLocalizations.of(context).getText(
                                        'x8m48y2p' /* Email */,
                                      ),
                                      labelStyle: AppTheme.of(context)
                                          .labelLarge
                                          .override(
                                            font: GoogleFonts.inter(
                                              fontWeight:
                                                  AppTheme.of(context)
                                                      .labelLarge
                                                      .fontWeight,
                                              fontStyle:
                                                  AppTheme.of(context)
                                                      .labelLarge
                                                      .fontStyle,
                                            ),
                                            letterSpacing: 0.0,
                                            fontWeight:
                                                AppTheme.of(context)
                                                    .labelLarge
                                                    .fontWeight,
                                            fontStyle:
                                                AppTheme.of(context)
                                                    .labelLarge
                                                    .fontStyle,
                                          ),
                                      enabledBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                          color: AppTheme.of(context)
                                              .alternate,
                                          width: 2.0,
                                        ),
                                        borderRadius:
                                            BorderRadius.circular(12.0),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                          color: AppTheme.of(context)
                                              .primary,
                                          width: 2.0,
                                        ),
                                        borderRadius:
                                            BorderRadius.circular(12.0),
                                      ),
                                      errorBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                          color: AppTheme.of(context)
                                              .error,
                                          width: 2.0,
                                        ),
                                        borderRadius:
                                            BorderRadius.circular(12.0),
                                      ),
                                      focusedErrorBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                          color: AppTheme.of(context)
                                              .error,
                                          width: 2.0,
                                        ),
                                        borderRadius:
                                            BorderRadius.circular(12.0),
                                      ),
                                      filled: true,
                                      fillColor: AppTheme.of(context)
                                          .primaryBackground,
                                    ),
                                    style: AppTheme.of(context)
                                        .bodyLarge
                                        .override(
                                          font: GoogleFonts.inter(
                                            fontWeight:
                                                AppTheme.of(context)
                                                    .bodyLarge
                                                    .fontWeight,
                                            fontStyle:
                                                AppTheme.of(context)
                                                    .bodyLarge
                                                    .fontStyle,
                                          ),
                                          letterSpacing: 0.0,
                                          fontWeight:
                                              AppTheme.of(context)
                                                  .bodyLarge
                                                  .fontWeight,
                                          fontStyle:
                                              AppTheme.of(context)
                                                  .bodyLarge
                                                  .fontStyle,
                                        ),
                                    keyboardType: TextInputType.emailAddress,
                                    cursorColor:
                                        AppTheme.of(context).primary,
                                    validator: _model
                                        .emailAddressTextControllerValidator
                                        .asValidator(context),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: EdgeInsetsDirectional.fromSTEB(
                                    0.0, 0.0, 0.0, 16.0),
                                child: Container(
                                  width: double.infinity,
                                  child: TextFormField(
                                    controller: _model.passwordTextController,
                                    focusNode: _model.passwordFocusNode,
                                    autofocus: true,
                                    autofillHints: [AutofillHints.password],
                                    obscureText: !_model.passwordVisibility,
                                    decoration: InputDecoration(
                                      labelText:
                                          AppLocalizations.of(context).getText(
                                        'd69sdrms' /* Password */,
                                      ),
                                      labelStyle: AppTheme.of(context)
                                          .labelLarge
                                          .override(
                                            font: GoogleFonts.inter(
                                              fontWeight:
                                                  AppTheme.of(context)
                                                      .labelLarge
                                                      .fontWeight,
                                              fontStyle:
                                                  AppTheme.of(context)
                                                      .labelLarge
                                                      .fontStyle,
                                            ),
                                            letterSpacing: 0.0,
                                            fontWeight:
                                                AppTheme.of(context)
                                                    .labelLarge
                                                    .fontWeight,
                                            fontStyle:
                                                AppTheme.of(context)
                                                    .labelLarge
                                                    .fontStyle,
                                          ),
                                      enabledBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                          color: AppTheme.of(context)
                                              .alternate,
                                          width: 2.0,
                                        ),
                                        borderRadius:
                                            BorderRadius.circular(12.0),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                          color: AppTheme.of(context)
                                              .primary,
                                          width: 2.0,
                                        ),
                                        borderRadius:
                                            BorderRadius.circular(12.0),
                                      ),
                                      errorBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                          color: AppTheme.of(context)
                                              .error,
                                          width: 2.0,
                                        ),
                                        borderRadius:
                                            BorderRadius.circular(12.0),
                                      ),
                                      focusedErrorBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                          color: AppTheme.of(context)
                                              .error,
                                          width: 2.0,
                                        ),
                                        borderRadius:
                                            BorderRadius.circular(12.0),
                                      ),
                                      filled: true,
                                      fillColor: AppTheme.of(context)
                                          .primaryBackground,
                                      suffixIcon: InkWell(
                                        onTap: () async {
                                          safeSetState(() =>
                                              _model.passwordVisibility =
                                                  !_model.passwordVisibility);
                                        },
                                        focusNode:
                                            FocusNode(skipTraversal: true),
                                        child: Icon(
                                          _model.passwordVisibility
                                              ? Icons.visibility_outlined
                                              : Icons.visibility_off_outlined,
                                          color: AppTheme.of(context)
                                              .secondaryText,
                                          size: 24.0,
                                        ),
                                      ),
                                    ),
                                    style: AppTheme.of(context)
                                        .bodyLarge
                                        .override(
                                          font: GoogleFonts.inter(
                                            fontWeight:
                                                AppTheme.of(context)
                                                    .bodyLarge
                                                    .fontWeight,
                                            fontStyle:
                                                AppTheme.of(context)
                                                    .bodyLarge
                                                    .fontStyle,
                                          ),
                                          letterSpacing: 0.0,
                                          fontWeight:
                                              AppTheme.of(context)
                                                  .bodyLarge
                                                  .fontWeight,
                                          fontStyle:
                                              AppTheme.of(context)
                                                  .bodyLarge
                                                  .fontStyle,
                                        ),
                                    cursorColor:
                                        AppTheme.of(context).primary,
                                    validator: _model
                                        .passwordTextControllerValidator
                                        .asValidator(context),
                                  ),
                                ),
                              ),
                              Row(
                                mainAxisSize: MainAxisSize.max,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Flexible(
                                    child: Padding(
                                      padding: EdgeInsetsDirectional.fromSTEB(
                                          0.0, 0.0, 0.0, 22.0),
                                      child: Container(
                                        width: double.infinity,
                                        child: TextFormField(
                                          controller: _model.ageTextController,
                                          focusNode: _model.ageFocusNode,
                                          autofocus: true,
                                          autofillHints: [
                                            AutofillHints.birthday
                                          ],
                                          readOnly: true,
                                          obscureText: false,
                                          decoration: InputDecoration(
                                            isDense: false,
                                            labelText:
                                                AppLocalizations.of(context)
                                                    .getText(
                                              'llees51u' /* birthday */,
                                            ),
                                            labelStyle:
                                                AppTheme.of(context)
                                                    .labelLarge
                                                    .override(
                                                      font: GoogleFonts.inter(
                                                        fontWeight:
                                                            AppTheme.of(
                                                                    context)
                                                                .labelLarge
                                                                .fontWeight,
                                                        fontStyle:
                                                            AppTheme.of(
                                                                    context)
                                                                .labelLarge
                                                                .fontStyle,
                                                      ),
                                                      letterSpacing: 0.0,
                                                      fontWeight:
                                                          AppTheme.of(
                                                                  context)
                                                              .labelLarge
                                                              .fontWeight,
                                                      fontStyle:
                                                          AppTheme.of(
                                                                  context)
                                                              .labelLarge
                                                              .fontStyle,
                                                    ),
                                            enabledBorder: OutlineInputBorder(
                                              borderSide: BorderSide(
                                                color:
                                                    AppTheme.of(context)
                                                        .alternate,
                                                width: 2.0,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(12.0),
                                            ),
                                            focusedBorder: OutlineInputBorder(
                                              borderSide: BorderSide(
                                                color:
                                                    AppTheme.of(context)
                                                        .primary,
                                                width: 2.0,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(12.0),
                                            ),
                                            errorBorder: OutlineInputBorder(
                                              borderSide: BorderSide(
                                                color:
                                                    AppTheme.of(context)
                                                        .error,
                                                width: 2.0,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(12.0),
                                            ),
                                            focusedErrorBorder:
                                                OutlineInputBorder(
                                              borderSide: BorderSide(
                                                color:
                                                    AppTheme.of(context)
                                                        .error,
                                                width: 2.0,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(12.0),
                                            ),
                                            filled: true,
                                            fillColor:
                                                AppTheme.of(context)
                                                    .primaryBackground,
                                          ),
                                          style: AppTheme.of(context)
                                              .bodyLarge
                                              .override(
                                                font: GoogleFonts.inter(
                                                  fontWeight:
                                                      AppTheme.of(
                                                              context)
                                                          .bodyLarge
                                                          .fontWeight,
                                                  fontStyle:
                                                      AppTheme.of(
                                                              context)
                                                          .bodyLarge
                                                          .fontStyle,
                                                ),
                                                letterSpacing: 0.0,
                                                fontWeight:
                                                    AppTheme.of(context)
                                                        .bodyLarge
                                                        .fontWeight,
                                                fontStyle:
                                                    AppTheme.of(context)
                                                        .bodyLarge
                                                        .fontStyle,
                                              ),
                                          maxLines: null,
                                          keyboardType: TextInputType.datetime,
                                          cursorColor:
                                              AppTheme.of(context)
                                                  .primary,
                                          validator: _model
                                              .ageTextControllerValidator
                                              .asValidator(context),
                                          inputFormatters: [_model.ageMask],
                                        ),
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: EdgeInsetsDirectional.fromSTEB(
                                        0.0, 0.0, 5.0, 22.0),
                                    child: InkWell(
                                      splashColor: Colors.transparent,
                                      focusColor: Colors.transparent,
                                      hoverColor: Colors.transparent,
                                      highlightColor: Colors.transparent,
                                      onTap: () async {
                                        final _datePickedDate =
                                            await showDatePicker(
                                          context: context,
                                          initialDate: getCurrentTimestamp,
                                          firstDate: DateTime(1900),
                                          lastDate: getCurrentTimestamp,
                                          builder: (context, child) {
                                            return wrapInMaterialDatePickerTheme(
                                              context,
                                              child!,
                                              headerBackgroundColor:
                                                  AppTheme.of(context)
                                                      .primary,
                                              headerForegroundColor:
                                                  AppTheme.of(context)
                                                      .info,
                                              headerTextStyle: AppTheme
                                                      .of(context)
                                                  .headlineLarge
                                                  .override(
                                                    font: GoogleFonts.readexPro(
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      fontStyle:
                                                          AppTheme.of(
                                                                  context)
                                                              .headlineLarge
                                                              .fontStyle,
                                                    ),
                                                    fontSize: 32.0,
                                                    letterSpacing: 0.0,
                                                    fontWeight: FontWeight.w600,
                                                    fontStyle:
                                                        AppTheme.of(
                                                                context)
                                                            .headlineLarge
                                                            .fontStyle,
                                                  ),
                                              pickerBackgroundColor:
                                                  AppTheme.of(context)
                                                      .secondaryBackground,
                                              pickerForegroundColor:
                                                  AppTheme.of(context)
                                                      .primaryText,
                                              selectedDateTimeBackgroundColor:
                                                  AppTheme.of(context)
                                                      .primary,
                                              selectedDateTimeForegroundColor:
                                                  AppTheme.of(context)
                                                      .info,
                                              actionButtonForegroundColor:
                                                  AppTheme.of(context)
                                                      .primaryText,
                                              iconSize: 24.0,
                                            );
                                          },
                                        );

                                        if (_datePickedDate != null) {
                                          safeSetState(() {
                                            _model.datePicked = DateTime(
                                              _datePickedDate.year,
                                              _datePickedDate.month,
                                              _datePickedDate.day,
                                            );
                                          });
                                        } else if (_model.datePicked != null) {
                                          safeSetState(() {
                                            _model.datePicked =
                                                getCurrentTimestamp;
                                          });
                                        }
                                        safeSetState(() {
                                          _model.ageTextController?.text =
                                              dateTimeFormat(
                                            "d/M/y",
                                            _model.datePicked,
                                            locale: AppLocalizations.of(context)
                                                .languageCode,
                                          );
                                          _model.ageMask.updateMask(
                                            newValue: TextEditingValue(
                                              text: _model
                                                  .ageTextController!.text,
                                            ),
                                          );
                                        });
                                      },
                                      child: Icon(
                                        Icons.date_range,
                                        color: AppTheme.of(context)
                                            .primaryText,
                                        size: 24.0,
                                      ),
                                    ),
                                  ),
                                  Flexible(
                                    child: Padding(
                                      padding: EdgeInsetsDirectional.fromSTEB(
                                          5.0, 0.0, 0.0, 22.0),
                                      child: AppDropDown<String>(
                                        controller: _model
                                                .genderValueController ??=
                                            FormFieldController<String>(null),
                                        options: Genders.values
                                            .map((e) => e.name)
                                            .toList(),
                                        onChanged: (val) => safeSetState(
                                            () => _model.genderValue = val),
                                        width:
                                            MediaQuery.sizeOf(context).width *
                                                0.35,
                                        height: 50.0,
                                        textStyle: AppTheme.of(context)
                                            .bodyMedium
                                            .override(
                                              font: GoogleFonts.inter(
                                                fontWeight: FontWeight.normal,
                                                fontStyle:
                                                    AppTheme.of(context)
                                                        .bodyMedium
                                                        .fontStyle,
                                              ),
                                              fontSize: 16.0,
                                              letterSpacing: 0.0,
                                              fontWeight: FontWeight.normal,
                                              fontStyle:
                                                  AppTheme.of(context)
                                                      .bodyMedium
                                                      .fontStyle,
                                            ),
                                        hintText:
                                            AppLocalizations.of(context).getText(
                                          'i1jbvk65' /* Gender */,
                                        ),
                                        icon: Icon(
                                          Icons.keyboard_arrow_down_rounded,
                                          color: AppTheme.of(context)
                                              .secondaryText,
                                          size: 24.0,
                                        ),
                                        fillColor: AppTheme.of(context)
                                            .primaryBackground,
                                        elevation: 2.0,
                                        borderColor:
                                            AppTheme.of(context)
                                                .alternate,
                                        borderWidth: 2.0,
                                        borderRadius: 8.0,
                                        margin: EdgeInsetsDirectional.fromSTEB(
                                            10.0, 2.0, 8.0, 2.0),
                                        hidesUnderline: true,
                                        isOverButton: true,
                                        isSearchable: false,
                                        isMultiSelect: false,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              Padding(
                                padding: EdgeInsetsDirectional.fromSTEB(
                                    0.0, 0.0, 0.0, 16.0),
                                child: AppButtonWidget(
                                  onPressed: () async {
                                    if (_model.switchValue!) {
                                      GoRouter.of(context).prepareAuthEvent();

                                      final user = await authManager
                                          .createAccountWithEmail(
                                        context,
                                        _model.emailAddressTextController.text,
                                        _model.passwordTextController.text,
                                      );
                                      if (user == null) {
                                        return;
                                      }

                                      await UsersInfoTable().update(
                                        data: {
                                          'name':
                                              _model.nameTextController.text,
                                        },
                                        matchingRows: (rows) => rows.eqOrNull(
                                          'id',
                                          currentUserUid,
                                        ),
                                      );
                                      await FamilyMembersTable().update(
                                        data: {
                                          'name':
                                              _model.nameTextController.text,
                                          'birthday': supaSerialize<DateTime>(
                                              functions.stringToDateTime(_model
                                                  .ageTextController.text)),
                                          'gender': _model.genderValue,
                                          'relationship': 'ME',
                                          'admin': true,
                                        },
                                        matchingRows: (rows) => rows.eqOrNull(
                                          'account_id',
                                          currentUserUid,
                                        ),
                                      );

                                      context.pushNamedAuth(
                                          MainHomeWidget.routeName,
                                          context.mounted);
                                    } else {
                                      // Local SQLite signup
                                      _model.userID = await actions.getUUID();
                                      _model.familyMemberID =
                                          await actions.getUUID();
                                      _model.hashedPW =
                                          await actions.hashPassword(
                                        _model.passwordTextController.text,
                                      );

                                      final birthdayTimestamp =
                                          functions.stringToUnixTimestamp(
                                              _model.ageTextController.text);

                                      await SQLiteManager.instance
                                          .registerNewUser(
                                        id: _model.userID!,
                                        email: _model
                                            .emailAddressTextController.text,
                                        phoneNumber: '',
                                        createdAt: getCurrentTimestamp
                                            .secondsSinceEpoch,
                                        passwordHash: _model.hashedPW!,
                                        familyMemberID: _model.familyMemberID!,
                                        name: _model.nameTextController.text,
                                        birthday: birthdayTimestamp,
                                        gender: _model.genderValue!,
                                        relationship: 'ME',
                                        lastChecked: 0,
                                        lastActive: 0,
                                      );

                                      // Create the initial family member struct
                                      final familyMember = FamilyMemberStruct(
                                        id: _model.familyMemberID!,
                                        name: _model.nameTextController.text,
                                        birthday: birthdayTimestamp != null
                                            ? DateTime.fromMillisecondsSinceEpoch(
                                                birthdayTimestamp * 1000)
                                            : null,
                                        relationship: Relationships.ME,
                                        admin: true,
                                      );

                                      // Populate the UserSession
                                      AppState().UserSession = UserSessionStruct(
                                        userID: _model.userID!,
                                        email: _model.emailAddressTextController.text,
                                        name: _model.nameTextController.text,
                                        sessionId: _model.userID!,
                                        family: [familyMember],
                                        familyAmount: 1,
                                        sumChecked: 0,
                                        isLocalSession: true,
                                      );

                                      context.goNamedAuth(
                                          MainHomeWidget.routeName,
                                          context.mounted);
                                    }

                                    safeSetState(() {});
                                  },
                                  text: AppLocalizations.of(context).getText(
                                    'z4fzwb7k' /* Create Account */,
                                  ),
                                  options: AppButtonOptions(
                                    width: double.infinity,
                                    height: 44.0,
                                    padding: EdgeInsetsDirectional.fromSTEB(
                                        0.0, 0.0, 0.0, 0.0),
                                    iconPadding: EdgeInsetsDirectional.fromSTEB(
                                        0.0, 0.0, 0.0, 0.0),
                                    color: AppTheme.of(context).primary,
                                    textStyle: AppTheme.of(context)
                                        .titleSmall
                                        .override(
                                          font: GoogleFonts.inter(
                                            fontWeight:
                                                AppTheme.of(context)
                                                    .titleSmall
                                                    .fontWeight,
                                            fontStyle:
                                                AppTheme.of(context)
                                                    .titleSmall
                                                    .fontStyle,
                                          ),
                                          color: Colors.white,
                                          letterSpacing: 0.0,
                                          fontWeight:
                                              AppTheme.of(context)
                                                  .titleSmall
                                                  .fontWeight,
                                          fontStyle:
                                              AppTheme.of(context)
                                                  .titleSmall
                                                  .fontStyle,
                                        ),
                                    elevation: 3.0,
                                    borderSide: BorderSide(
                                      color: Colors.transparent,
                                      width: 1.0,
                                    ),
                                    borderRadius: BorderRadius.circular(12.0),
                                  ),
                                ),
                              ),

                              // You will have to add an action on this rich text to go to your login page.
                              Align(
                                alignment: AlignmentDirectional(0.0, 0.0),
                                child: Padding(
                                  padding: EdgeInsetsDirectional.fromSTEB(
                                      0.0, 12.0, 0.0, 12.0),
                                  child: InkWell(
                                    splashColor: Colors.transparent,
                                    focusColor: Colors.transparent,
                                    hoverColor: Colors.transparent,
                                    highlightColor: Colors.transparent,
                                    onTap: () async {
                                      context.pushNamed(
                                        Auth2LoginWidget.routeName,
                                        extra: <String, dynamic>{
                                          kTransitionInfoKey: TransitionInfo(
                                            hasTransition: true,
                                            transitionType:
                                                PageTransitionType.fade,
                                            duration:
                                                Duration(milliseconds: 200),
                                          ),
                                        },
                                      );
                                    },
                                    child: RichText(
                                      textScaler:
                                          MediaQuery.of(context).textScaler,
                                      text: TextSpan(
                                        children: [
                                          TextSpan(
                                            text: AppLocalizations.of(context)
                                                .getText(
                                              'wi5b68oy' /* Already have an account?  */,
                                            ),
                                            style: TextStyle(),
                                          ),
                                          TextSpan(
                                            text: AppLocalizations.of(context)
                                                .getText(
                                              'meimul7j' /* Sign in here */,
                                            ),
                                            style: AppTheme.of(context)
                                                .bodyMedium
                                                .override(
                                                  font: GoogleFonts.inter(
                                                    fontWeight: FontWeight.w600,
                                                    fontStyle:
                                                        AppTheme.of(
                                                                context)
                                                            .bodyMedium
                                                            .fontStyle,
                                                  ),
                                                  color: AppTheme.of(
                                                          context)
                                                      .primary,
                                                  letterSpacing: 0.0,
                                                  fontWeight: FontWeight.w600,
                                                  fontStyle:
                                                      AppTheme.of(
                                                              context)
                                                          .bodyMedium
                                                          .fontStyle,
                                                ),
                                          )
                                        ],
                                        style: AppTheme.of(context)
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
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ).animateOnPageLoad(
                      animationsMap['containerOnPageLoadAnimation']!),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
