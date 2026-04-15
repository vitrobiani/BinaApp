import '/app_core/app_drop_down.dart';
import '/app_core/app_theme.dart';
import '/app_core/app_util.dart';
import '/app_core/app_widgets.dart';
import '/app_core/form_field_controller.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'edit_profile_auth2_model.dart';
export 'edit_profile_auth2_model.dart';

class EditProfileAuth2Widget extends StatefulWidget {
  const EditProfileAuth2Widget({
    super.key,
    String? title,
    String? confirmButtonText,
    required this.navigateAction,
  })  : this.title = title ?? 'Edit Profile',
        this.confirmButtonText = confirmButtonText ?? 'Save Changes';

  final String title;
  final String confirmButtonText;
  final Future Function()? navigateAction;

  @override
  State<EditProfileAuth2Widget> createState() => _EditProfileAuth2WidgetState();
}

class _EditProfileAuth2WidgetState extends State<EditProfileAuth2Widget> {
  late EditProfileAuth2Model _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => EditProfileAuth2Model());

    _model.yourNameTextController ??= TextEditingController();
    _model.yourNameFocusNode ??= FocusNode();

    _model.myBioTextController ??= TextEditingController();
    _model.myBioFocusNode ??= FocusNode();

    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {
          _model.myBioTextController?.text =
              AppLocalizations.of(context).getText(
            'xkqq8b0e' /* [bio] */,
          );
        }));
  }

  @override
  void dispose() {
    _model.maybeDispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _model.formKey,
      autovalidateMode: AutovalidateMode.disabled,
      child: Column(
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsetsDirectional.fromSTEB(24.0, 0.0, 0.0, 0.0),
            child: Text(
              widget.title,
              style: AppTheme.of(context).displaySmall.override(
                    font: GoogleFonts.readexPro(
                      fontWeight:
                          AppTheme.of(context).displaySmall.fontWeight,
                      fontStyle:
                          AppTheme.of(context).displaySmall.fontStyle,
                    ),
                    letterSpacing: 0.0,
                    fontWeight:
                        AppTheme.of(context).displaySmall.fontWeight,
                    fontStyle:
                        AppTheme.of(context).displaySmall.fontStyle,
                  ),
            ),
          ),
          Padding(
            padding: EdgeInsetsDirectional.fromSTEB(24.0, 8.0, 0.0, 0.0),
            child: Text(
              AppLocalizations.of(context).getText(
                'cfnr4q80' /* Adjust the content below to up... */,
              ),
              style: AppTheme.of(context).labelLarge.override(
                    font: GoogleFonts.inter(
                      fontWeight:
                          AppTheme.of(context).labelLarge.fontWeight,
                      fontStyle:
                          AppTheme.of(context).labelLarge.fontStyle,
                    ),
                    letterSpacing: 0.0,
                    fontWeight:
                        AppTheme.of(context).labelLarge.fontWeight,
                    fontStyle:
                        AppTheme.of(context).labelLarge.fontStyle,
                  ),
            ),
          ),
          Align(
            alignment: AlignmentDirectional(0.0, -1.0),
            child: Padding(
              padding: EdgeInsetsDirectional.fromSTEB(0.0, 12.0, 0.0, 0.0),
              child: Container(
                width: 100.0,
                height: 100.0,
                decoration: BoxDecoration(
                  color: AppTheme.of(context).accent2,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppTheme.of(context).secondary,
                    width: 2.0,
                  ),
                ),
                child: Align(
                  alignment: AlignmentDirectional(0.0, 0.0),
                  child: Stack(
                    children: [
                      Padding(
                        padding: EdgeInsets.all(4.0),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(60.0),
                          child: CachedNetworkImage(
                            fadeInDuration: Duration(milliseconds: 200),
                            fadeOutDuration: Duration(milliseconds: 200),
                            imageUrl:
                                'https://images.unsplash.com/photo-1499887142886-791eca5918cd?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w0NTYyMDF8MHwxfHNlYXJjaHwxN3x8dXNlcnxlbnwwfHx8fDE2OTc4MjQ2MjZ8MA&ixlib=rb-4.0.3&q=80&w=400',
                            width: 300.0,
                            height: 200.0,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(4.0),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(60.0),
                          child: CachedNetworkImage(
                            fadeInDuration: Duration(milliseconds: 200),
                            fadeOutDuration: Duration(milliseconds: 200),
                            imageUrl:
                                'https://images.unsplash.com/photo-1499887142886-791eca5918cd?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w0NTYyMDF8MHwxfHNlYXJjaHwxN3x8dXNlcnxlbnwwfHx8fDE2OTc4MjQ2MjZ8MA&ixlib=rb-4.0.3&q=80&w=400',
                            width: 300.0,
                            height: 200.0,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Align(
            alignment: AlignmentDirectional(0.0, -1.0),
            child: Padding(
              padding: EdgeInsetsDirectional.fromSTEB(0.0, 12.0, 0.0, 32.0),
              child: AppButtonWidget(
                onPressed: () {
                  print('Button pressed ...');
                },
                text: AppLocalizations.of(context).getText(
                  'u42j5t5x' /* Change Photo */,
                ),
                options: AppButtonOptions(
                  width: 130.0,
                  height: 40.0,
                  padding: EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 0.0),
                  iconPadding:
                      EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 0.0),
                  color: AppTheme.of(context).primaryBackground,
                  textStyle: AppTheme.of(context).bodyMedium.override(
                        font: GoogleFonts.inter(
                          fontWeight: AppTheme.of(context)
                              .bodyMedium
                              .fontWeight,
                          fontStyle:
                              AppTheme.of(context).bodyMedium.fontStyle,
                        ),
                        letterSpacing: 0.0,
                        fontWeight:
                            AppTheme.of(context).bodyMedium.fontWeight,
                        fontStyle:
                            AppTheme.of(context).bodyMedium.fontStyle,
                      ),
                  elevation: 1.0,
                  borderSide: BorderSide(
                    color: AppTheme.of(context).alternate,
                    width: 1.0,
                  ),
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsetsDirectional.fromSTEB(20.0, 0.0, 20.0, 12.0),
            child: TextFormField(
              controller: _model.yourNameTextController,
              focusNode: _model.yourNameFocusNode,
              autofillHints: [AutofillHints.name],
              textCapitalization: TextCapitalization.words,
              obscureText: false,
              decoration: InputDecoration(
                labelText: AppLocalizations.of(context).getText(
                  'hrubvu4m' /* Full Name */,
                ),
                labelStyle: AppTheme.of(context).labelMedium.override(
                      font: GoogleFonts.inter(
                        fontWeight:
                            AppTheme.of(context).labelMedium.fontWeight,
                        fontStyle:
                            AppTheme.of(context).labelMedium.fontStyle,
                      ),
                      letterSpacing: 0.0,
                      fontWeight:
                          AppTheme.of(context).labelMedium.fontWeight,
                      fontStyle:
                          AppTheme.of(context).labelMedium.fontStyle,
                    ),
                hintText: AppLocalizations.of(context).getText(
                  'wdugkxi2' /* Your full name... */,
                ),
                hintStyle: AppTheme.of(context).labelMedium.override(
                      font: GoogleFonts.inter(
                        fontWeight:
                            AppTheme.of(context).labelMedium.fontWeight,
                        fontStyle:
                            AppTheme.of(context).labelMedium.fontStyle,
                      ),
                      letterSpacing: 0.0,
                      fontWeight:
                          AppTheme.of(context).labelMedium.fontWeight,
                      fontStyle:
                          AppTheme.of(context).labelMedium.fontStyle,
                    ),
                errorStyle: AppTheme.of(context).bodyMedium.override(
                      font: GoogleFonts.inter(
                        fontWeight:
                            AppTheme.of(context).bodyMedium.fontWeight,
                        fontStyle:
                            AppTheme.of(context).bodyMedium.fontStyle,
                      ),
                      color: AppTheme.of(context).error,
                      letterSpacing: 0.0,
                      fontWeight:
                          AppTheme.of(context).bodyMedium.fontWeight,
                      fontStyle:
                          AppTheme.of(context).bodyMedium.fontStyle,
                    ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: AppTheme.of(context).alternate,
                    width: 2.0,
                  ),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: AppTheme.of(context).primary,
                    width: 2.0,
                  ),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                errorBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: AppTheme.of(context).error,
                    width: 2.0,
                  ),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: AppTheme.of(context).error,
                    width: 2.0,
                  ),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                filled: true,
                fillColor: AppTheme.of(context).primaryBackground,
                contentPadding:
                    EdgeInsetsDirectional.fromSTEB(16.0, 12.0, 0.0, 12.0),
              ),
              style: AppTheme.of(context).bodyMedium.override(
                    font: GoogleFonts.inter(
                      fontWeight:
                          AppTheme.of(context).bodyMedium.fontWeight,
                      fontStyle:
                          AppTheme.of(context).bodyMedium.fontStyle,
                    ),
                    letterSpacing: 0.0,
                    fontWeight:
                        AppTheme.of(context).bodyMedium.fontWeight,
                    fontStyle:
                        AppTheme.of(context).bodyMedium.fontStyle,
                  ),
              cursorColor: AppTheme.of(context).primary,
              validator:
                  _model.yourNameTextControllerValidator.asValidator(context),
              inputFormatters: [
                if (!isAndroid && !isiOS)
                  TextInputFormatter.withFunction((oldValue, newValue) {
                    return TextEditingValue(
                      selection: newValue.selection,
                      text: newValue.text
                          .toCapitalization(TextCapitalization.words),
                    );
                  }),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsetsDirectional.fromSTEB(20.0, 0.0, 20.0, 12.0),
            child: AppDropDown<String>(
              controller: _model.dropDownValueController ??=
                  FormFieldController<String>(null),
              options: [
                AppLocalizations.of(context).getText(
                  'bh82b223' /* Owner/Founder */,
                ),
                AppLocalizations.of(context).getText(
                  'phu34612' /* Director */,
                ),
                AppLocalizations.of(context).getText(
                  '3u84r61z' /* Manager */,
                ),
                AppLocalizations.of(context).getText(
                  'rrippote' /* Mid-Manager */,
                ),
                AppLocalizations.of(context).getText(
                  'pj1vpx8r' /* Employee */,
                )
              ],
              onChanged: (val) =>
                  safeSetState(() => _model.dropDownValue = val),
              width: double.infinity,
              height: 44.0,
              textStyle: AppTheme.of(context).bodyMedium.override(
                    font: GoogleFonts.inter(
                      fontWeight:
                          AppTheme.of(context).bodyMedium.fontWeight,
                      fontStyle:
                          AppTheme.of(context).bodyMedium.fontStyle,
                    ),
                    letterSpacing: 0.0,
                    fontWeight:
                        AppTheme.of(context).bodyMedium.fontWeight,
                    fontStyle:
                        AppTheme.of(context).bodyMedium.fontStyle,
                  ),
              hintText: AppLocalizations.of(context).getText(
                'mzpep7jk' /* Your Role */,
              ),
              icon: Icon(
                Icons.keyboard_arrow_down_rounded,
                color: AppTheme.of(context).secondaryText,
                size: 24.0,
              ),
              fillColor: AppTheme.of(context).primaryBackground,
              elevation: 2.0,
              borderColor: AppTheme.of(context).alternate,
              borderWidth: 2.0,
              borderRadius: 8.0,
              margin: EdgeInsetsDirectional.fromSTEB(16.0, 4.0, 16.0, 4.0),
              hidesUnderline: true,
              isSearchable: false,
              isMultiSelect: false,
            ),
          ),
          Padding(
            padding: EdgeInsetsDirectional.fromSTEB(20.0, 0.0, 20.0, 12.0),
            child: TextFormField(
              controller: _model.myBioTextController,
              focusNode: _model.myBioFocusNode,
              textCapitalization: TextCapitalization.sentences,
              obscureText: false,
              decoration: InputDecoration(
                labelText: AppLocalizations.of(context).getText(
                  'evezo4gx' /* Short Description */,
                ),
                labelStyle: AppTheme.of(context).labelMedium.override(
                      font: GoogleFonts.inter(
                        fontWeight:
                            AppTheme.of(context).labelMedium.fontWeight,
                        fontStyle:
                            AppTheme.of(context).labelMedium.fontStyle,
                      ),
                      letterSpacing: 0.0,
                      fontWeight:
                          AppTheme.of(context).labelMedium.fontWeight,
                      fontStyle:
                          AppTheme.of(context).labelMedium.fontStyle,
                    ),
                hintText: AppLocalizations.of(context).getText(
                  '15ubbgyg' /* A little about you... */,
                ),
                hintStyle: AppTheme.of(context).labelMedium.override(
                      font: GoogleFonts.inter(
                        fontWeight:
                            AppTheme.of(context).labelMedium.fontWeight,
                        fontStyle:
                            AppTheme.of(context).labelMedium.fontStyle,
                      ),
                      letterSpacing: 0.0,
                      fontWeight:
                          AppTheme.of(context).labelMedium.fontWeight,
                      fontStyle:
                          AppTheme.of(context).labelMedium.fontStyle,
                    ),
                errorStyle: AppTheme.of(context).bodyMedium.override(
                      font: GoogleFonts.inter(
                        fontWeight:
                            AppTheme.of(context).bodyMedium.fontWeight,
                        fontStyle:
                            AppTheme.of(context).bodyMedium.fontStyle,
                      ),
                      color: AppTheme.of(context).error,
                      letterSpacing: 0.0,
                      fontWeight:
                          AppTheme.of(context).bodyMedium.fontWeight,
                      fontStyle:
                          AppTheme.of(context).bodyMedium.fontStyle,
                    ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: AppTheme.of(context).alternate,
                    width: 2.0,
                  ),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: AppTheme.of(context).primary,
                    width: 2.0,
                  ),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                errorBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: AppTheme.of(context).error,
                    width: 2.0,
                  ),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: AppTheme.of(context).error,
                    width: 2.0,
                  ),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                filled: true,
                fillColor: AppTheme.of(context).primaryBackground,
                contentPadding:
                    EdgeInsetsDirectional.fromSTEB(16.0, 12.0, 0.0, 12.0),
              ),
              style: AppTheme.of(context).bodyMedium.override(
                    font: GoogleFonts.inter(
                      fontWeight:
                          AppTheme.of(context).bodyMedium.fontWeight,
                      fontStyle:
                          AppTheme.of(context).bodyMedium.fontStyle,
                    ),
                    letterSpacing: 0.0,
                    fontWeight:
                        AppTheme.of(context).bodyMedium.fontWeight,
                    fontStyle:
                        AppTheme.of(context).bodyMedium.fontStyle,
                  ),
              textAlign: TextAlign.start,
              maxLines: 3,
              cursorColor: AppTheme.of(context).primary,
              validator:
                  _model.myBioTextControllerValidator.asValidator(context),
              inputFormatters: [
                if (!isAndroid && !isiOS)
                  TextInputFormatter.withFunction((oldValue, newValue) {
                    return TextEditingValue(
                      selection: newValue.selection,
                      text: newValue.text
                          .toCapitalization(TextCapitalization.sentences),
                    );
                  }),
              ],
            ),
          ),
          Align(
            alignment: AlignmentDirectional(0.0, 0.0),
            child: Padding(
              padding: EdgeInsetsDirectional.fromSTEB(20.0, 24.0, 20.0, 0.0),
              child: AppButtonWidget(
                onPressed: () {
                  print('Button-Login pressed ...');
                },
                text: widget.confirmButtonText,
                options: AppButtonOptions(
                  width: double.infinity,
                  height: 44.0,
                  padding: EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 0.0),
                  iconPadding:
                      EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 0.0),
                  color: AppTheme.of(context).primary,
                  textStyle: AppTheme.of(context).titleSmall.override(
                        font: GoogleFonts.inter(
                          fontWeight: AppTheme.of(context)
                              .titleSmall
                              .fontWeight,
                          fontStyle:
                              AppTheme.of(context).titleSmall.fontStyle,
                        ),
                        letterSpacing: 0.0,
                        fontWeight:
                            AppTheme.of(context).titleSmall.fontWeight,
                        fontStyle:
                            AppTheme.of(context).titleSmall.fontStyle,
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
          ),
        ],
      ),
    );
  }
}
