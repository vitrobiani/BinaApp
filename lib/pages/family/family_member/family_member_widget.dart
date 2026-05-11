import '/backend/schema/enums/enums.dart';
import '/backend/supabase/supabase.dart';
import '/backend/sqlite/sqlite_manager.dart';
import '/app_core/app_drop_down.dart';
import '/app_core/app_theme.dart';
import '/app_core/app_util.dart';
import '/app_core/app_widgets.dart';
import '/app_core/form_field_controller.dart';
import '/actions/actions.dart' as action_blocks;
import '/custom_code/actions/index.dart' as actions;
import '/app_core/custom_functions.dart' as functions;
import '/components/dialogs/loading_dialog.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:provider/provider.dart';
import 'family_member_model.dart';
export 'family_member_model.dart';

class FamilyMemberWidget extends StatefulWidget {
  const FamilyMemberWidget({super.key});

  @override
  State<FamilyMemberWidget> createState() => _FamilyMemberWidgetState();
}

class _FamilyMemberWidgetState extends State<FamilyMemberWidget> {
  late FamilyMemberModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => FamilyMemberModel());

    _model.nameTextController ??= TextEditingController();
    _model.nameFocusNode ??= FocusNode();

    _model.birthdayTextController ??= TextEditingController();
    _model.birthdayFocusNode ??= FocusNode();

    _model.birthdayMask = MaskTextInputFormatter(mask: '##/##/####');
    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.maybeDispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    context.watch<AppState>();

    return Material(
      color: Colors.transparent,
      elevation: 5.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(0.0),
          bottomRight: Radius.circular(0.0),
          topLeft: Radius.circular(16.0),
          topRight: Radius.circular(16.0),
        ),
      ),
      child: Container(
        width: double.infinity,
        height: 370.0,
        decoration: BoxDecoration(
          color: AppTheme.of(context).secondaryBackground,
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(0.0),
            bottomRight: Radius.circular(0.0),
            topLeft: Radius.circular(16.0),
            topRight: Radius.circular(16.0),
          ),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding:
                        EdgeInsetsDirectional.fromSTEB(0.0, 12.0, 0.0, 0.0),
                    child: Container(
                      width: 50.0,
                      height: 4.0,
                      decoration: BoxDecoration(
                        color: AppTheme.of(context).lineColor,
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                  ),
                ],
              ),
              Padding(
                padding: EdgeInsetsDirectional.fromSTEB(16.0, 12.0, 0.0, 0.0),
                child: Text(
                  AppLocalizations.of(context).getText(
                    'e3gk5os7' /* Create Member */,
                  ),
                  style: AppTheme.of(context).headlineSmall.override(
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
                ),
              ),
              Padding(
                padding: EdgeInsetsDirectional.fromSTEB(16.0, 4.0, 0.0, 0.0),
                child: Text(
                  AppLocalizations.of(context).getText(
                    'nwy3vye6' /* Enter member info below */,
                  ),
                  style: AppTheme.of(context).bodySmall.override(
                        font: GoogleFonts.inter(
                          fontWeight:
                              AppTheme.of(context).bodySmall.fontWeight,
                          fontStyle:
                              AppTheme.of(context).bodySmall.fontStyle,
                        ),
                        letterSpacing: 0.0,
                        fontWeight:
                            AppTheme.of(context).bodySmall.fontWeight,
                        fontStyle:
                            AppTheme.of(context).bodySmall.fontStyle,
                      ),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(10.0),
                child: Container(
                  width: double.infinity,
                  child: TextFormField(
                    controller: _model.nameTextController,
                    focusNode: _model.nameFocusNode,
                    autofocus: true,
                    autofillHints: [AutofillHints.email],
                    obscureText: false,
                    decoration: InputDecoration(
                      labelText: AppLocalizations.of(context).getText(
                        '2rkmiqyr' /* name */,
                      ),
                      labelStyle:
                          AppTheme.of(context).labelLarge.override(
                                font: GoogleFonts.inter(
                                  fontWeight: AppTheme.of(context)
                                      .labelLarge
                                      .fontWeight,
                                  fontStyle: AppTheme.of(context)
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
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: AppTheme.of(context).alternate,
                          width: 2.0,
                        ),
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: AppTheme.of(context).primary,
                          width: 2.0,
                        ),
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: AppTheme.of(context).error,
                          width: 2.0,
                        ),
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      focusedErrorBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: AppTheme.of(context).error,
                          width: 2.0,
                        ),
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      filled: true,
                      fillColor: AppTheme.of(context).primaryBackground,
                    ),
                    style: AppTheme.of(context).bodyLarge.override(
                          font: GoogleFonts.inter(
                            fontWeight: AppTheme.of(context)
                                .bodyLarge
                                .fontWeight,
                            fontStyle: AppTheme.of(context)
                                .bodyLarge
                                .fontStyle,
                          ),
                          letterSpacing: 0.0,
                          fontWeight:
                              AppTheme.of(context).bodyLarge.fontWeight,
                          fontStyle:
                              AppTheme.of(context).bodyLarge.fontStyle,
                        ),
                    keyboardType: TextInputType.name,
                    cursorColor: AppTheme.of(context).primary,
                    validator:
                        _model.nameTextControllerValidator.asValidator(context),
                  ),
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Padding(
                      padding:
                          EdgeInsetsDirectional.fromSTEB(10.0, 10.0, 0.0, 10.0),
                      child: Container(
                        width: double.infinity,
                        child: TextFormField(
                          controller: _model.birthdayTextController,
                          focusNode: _model.birthdayFocusNode,
                          autofocus: true,
                          autofillHints: [AutofillHints.birthday],
                          readOnly: true,
                          obscureText: false,
                          decoration: InputDecoration(
                            labelText: AppLocalizations.of(context).getText(
                              '7zhjhvr8' /* Birthday */,
                            ),
                            labelStyle: AppTheme.of(context)
                                .labelLarge
                                .override(
                                  font: GoogleFonts.inter(
                                    fontWeight: AppTheme.of(context)
                                        .labelLarge
                                        .fontWeight,
                                    fontStyle: AppTheme.of(context)
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
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: AppTheme.of(context).alternate,
                                width: 2.0,
                              ),
                              borderRadius: BorderRadius.circular(12.0),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: AppTheme.of(context).primary,
                                width: 2.0,
                              ),
                              borderRadius: BorderRadius.circular(12.0),
                            ),
                            errorBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: AppTheme.of(context).error,
                                width: 2.0,
                              ),
                              borderRadius: BorderRadius.circular(12.0),
                            ),
                            focusedErrorBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: AppTheme.of(context).error,
                                width: 2.0,
                              ),
                              borderRadius: BorderRadius.circular(12.0),
                            ),
                            filled: true,
                            fillColor:
                                AppTheme.of(context).primaryBackground,
                          ),
                          style:
                              AppTheme.of(context).bodyLarge.override(
                                    font: GoogleFonts.inter(
                                      fontWeight: AppTheme.of(context)
                                          .bodyLarge
                                          .fontWeight,
                                      fontStyle: AppTheme.of(context)
                                          .bodyLarge
                                          .fontStyle,
                                    ),
                                    letterSpacing: 0.0,
                                    fontWeight: AppTheme.of(context)
                                        .bodyLarge
                                        .fontWeight,
                                    fontStyle: AppTheme.of(context)
                                        .bodyLarge
                                        .fontStyle,
                                  ),
                          keyboardType: TextInputType.datetime,
                          cursorColor: AppTheme.of(context).primary,
                          enableInteractiveSelection: true,
                          validator: _model.birthdayTextControllerValidator
                              .asValidator(context),
                          inputFormatters: [_model.birthdayMask],
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 5.0, 0.0),
                    child: InkWell(
                      splashColor: Colors.transparent,
                      focusColor: Colors.transparent,
                      hoverColor: Colors.transparent,
                      highlightColor: Colors.transparent,
                      onTap: () async {
                        final _datePickedDate = await showDatePicker(
                          context: context,
                          initialDate: getCurrentTimestamp,
                          firstDate: DateTime(1900),
                          lastDate: getCurrentTimestamp,
                          builder: (context, child) {
                            return wrapInMaterialDatePickerTheme(
                              context,
                              child!,
                              headerBackgroundColor:
                                  AppTheme.of(context).primary,
                              headerForegroundColor:
                                  AppTheme.of(context).info,
                              headerTextStyle: AppTheme.of(context)
                                  .headlineLarge
                                  .override(
                                    font: GoogleFonts.readexPro(
                                      fontWeight: FontWeight.w600,
                                      fontStyle: AppTheme.of(context)
                                          .headlineLarge
                                          .fontStyle,
                                    ),
                                    fontSize: 32.0,
                                    letterSpacing: 0.0,
                                    fontWeight: FontWeight.w600,
                                    fontStyle: AppTheme.of(context)
                                        .headlineLarge
                                        .fontStyle,
                                  ),
                              pickerBackgroundColor:
                                  AppTheme.of(context)
                                      .secondaryBackground,
                              pickerForegroundColor:
                                  AppTheme.of(context).primaryText,
                              selectedDateTimeBackgroundColor:
                                  AppTheme.of(context).primary,
                              selectedDateTimeForegroundColor:
                                  AppTheme.of(context).info,
                              actionButtonForegroundColor:
                                  AppTheme.of(context).primaryText,
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
                            _model.datePicked = getCurrentTimestamp;
                          });
                        }
                        safeSetState(() {
                          _model.birthdayTextController?.text = dateTimeFormat(
                            "d/M/y",
                            _model.datePicked,
                            locale: AppLocalizations.of(context).languageCode,
                          );
                          _model.birthdayMask.updateMask(
                            newValue: TextEditingValue(
                              text: _model.birthdayTextController!.text,
                            ),
                          );
                        });
                      },
                      child: Icon(
                        Icons.date_range,
                        color: AppTheme.of(context).primaryText,
                        size: 30.0,
                      ),
                    ),
                  ),
                ],
              ),
              Padding(
                padding: EdgeInsets.all(10.0),
                child: AppDropDown<String>(
                  controller: _model.genderValueController ??=
                      FormFieldController<String>(null),
                  options: Genders.values.map((e) => e.name).toList(),
                  onChanged: (val) =>
                      safeSetState(() => _model.genderValue = val),
                  width: double.infinity,
                  height: 50.0,
                  textStyle: AppTheme.of(context).bodyMedium.override(
                        font: GoogleFonts.inter(
                          fontWeight: FontWeight.normal,
                          fontStyle:
                              AppTheme.of(context).bodyMedium.fontStyle,
                        ),
                        fontSize: 16.0,
                        letterSpacing: 0.0,
                        fontWeight: FontWeight.normal,
                        fontStyle:
                            AppTheme.of(context).bodyMedium.fontStyle,
                      ),
                  hintText: AppLocalizations.of(context).getText(
                    '7syz836y' /* Gender */,
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
                  margin: EdgeInsetsDirectional.fromSTEB(10.0, 2.0, 8.0, 2.0),
                  hidesUnderline: true,
                  isOverButton: true,
                  isSearchable: false,
                  isMultiSelect: false,
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Padding(
                    padding:
                        EdgeInsetsDirectional.fromSTEB(0.0, 24.0, 0.0, 44.0),
                    child: AppButtonWidget(
                      onPressed: () async {
                        // Show loading indicator
                        LoadingDialog.show(
                          context: context,
                          message: AppLocalizations.of(context).getText('dlg010' /* Creating family member... */),
                        );

                        try {
                          _model.uid = await actions.getUUID();

                          if (AppState().UserSession.isLocalSession) {
                            // Insert into SQLite for local sessions
                            final birthdayTimestamp = functions.stringToUnixTimestamp(
                                _model.birthdayTextController.text);

                            await SQLiteManager.instance.addFamilyMember(
                              familyMemberID: _model.uid,
                              accountID: AppState().UserSession.userID,
                              name: _model.nameTextController.text,
                              birthday: birthdayTimestamp,
                              gender: _model.genderValue,
                              relationship: 'OTHER',
                              lastChecked: 0,
                            );
                          } else {
                            // Insert into Supabase for cloud sessions
                            _model.uInfo = await FamilyMembersTable().insert({
                              'id': _model.uid,
                              'account_id': AppState().UserSession.userID,
                              'name': _model.nameTextController.text,
                              'birthday': supaSerialize<DateTime>(
                                  functions.stringToDateTime(
                                      _model.birthdayTextController.text)),
                              'gender': _model.genderValue,
                              'admin': false,
                            });
                          }

                          // Refresh family list
                          await action_blocks.updateSessionFamily(context);

                          // Hide loading indicator
                          if (context.mounted) {
                            LoadingDialog.hide(context);
                          }

                          // Close the bottom sheet
                          if (context.mounted) {
                            Navigator.pop(context);
                          }
                        } catch (e) {
                          // Hide loading indicator on error
                          if (context.mounted) {
                            LoadingDialog.hide(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('${AppLocalizations.of(context).getText('dlg011' /* Error creating member */)}: $e'),
                                backgroundColor: AppTheme.of(context).error,
                              ),
                            );
                          }
                        }
                      },
                      text: AppLocalizations.of(context).getText(
                        '3syylynq' /* Create Member */,
                      ),
                      options: AppButtonOptions(
                        width: 270.0,
                        height: 50.0,
                        padding:
                            EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 0.0),
                        iconPadding:
                            EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 0.0),
                        color: AppTheme.of(context).primary,
                        textStyle:
                            AppTheme.of(context).titleMedium.override(
                                  font: GoogleFonts.readexPro(
                                    fontWeight: AppTheme.of(context)
                                        .titleMedium
                                        .fontWeight,
                                    fontStyle: AppTheme.of(context)
                                        .titleMedium
                                        .fontStyle,
                                  ),
                                  color: Colors.white,
                                  letterSpacing: 0.0,
                                  fontWeight: AppTheme.of(context)
                                      .titleMedium
                                      .fontWeight,
                                  fontStyle: AppTheme.of(context)
                                      .titleMedium
                                      .fontStyle,
                                ),
                        elevation: 3.0,
                        borderSide: BorderSide(
                          color: Colors.transparent,
                          width: 1.0,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
