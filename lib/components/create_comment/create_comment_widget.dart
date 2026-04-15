import '/app_core/app_theme.dart';
import '/app_core/app_util.dart';
import '/app_core/app_widgets.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'create_comment_model.dart';
export 'create_comment_model.dart';

class CreateCommentWidget extends StatefulWidget {
  const CreateCommentWidget({
    super.key,
    required this.title,
  });

  final String? title;

  @override
  State<CreateCommentWidget> createState() => _CreateCommentWidgetState();
}

class _CreateCommentWidgetState extends State<CreateCommentWidget> {
  late CreateCommentModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => CreateCommentModel());

    _model.shortBioTextController ??= TextEditingController();
    _model.shortBioFocusNode ??= FocusNode();

    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.maybeDispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
                    'l2jlnhye' /* Create Note */,
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
                    'd6yfe8tj' /* Find members by searching belo... */,
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
                padding: EdgeInsetsDirectional.fromSTEB(16.0, 12.0, 16.0, 0.0),
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(40.0),
                      child: Image.network(
                        'https://images.unsplash.com/photo-1610737241336-371badac3b66?ixlib=rb-1.2.1&ixid=MnwxMjA3fDB8MHxzZWFyY2h8NDV8fHVzZXJ8ZW58MHx8MHx8&auto=format&fit=crop&w=500&q=60',
                        width: 40.0,
                        height: 40.0,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Padding(
                      padding:
                          EdgeInsetsDirectional.fromSTEB(12.0, 0.0, 0.0, 0.0),
                      child: Text(
                        valueOrDefault<String>(
                          widget.title,
                          'shlomo abutbul',
                        ),
                        style:
                            AppTheme.of(context).titleMedium.override(
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
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsetsDirectional.fromSTEB(16.0, 16.0, 16.0, 0.0),
                child: TextFormField(
                  controller: _model.shortBioTextController,
                  focusNode: _model.shortBioFocusNode,
                  obscureText: false,
                  decoration: InputDecoration(
                    hintText: AppLocalizations.of(context).getText(
                      '9gf6o5ss' /* Enter your note here... */,
                    ),
                    hintStyle: AppTheme.of(context).bodySmall.override(
                          font: GoogleFonts.inter(
                            fontWeight: AppTheme.of(context)
                                .bodySmall
                                .fontWeight,
                            fontStyle: AppTheme.of(context)
                                .bodySmall
                                .fontStyle,
                          ),
                          letterSpacing: 0.0,
                          fontWeight:
                              AppTheme.of(context).bodySmall.fontWeight,
                          fontStyle:
                              AppTheme.of(context).bodySmall.fontStyle,
                        ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: AppTheme.of(context).primaryBackground,
                        width: 2.0,
                      ),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Color(0x00000000),
                        width: 2.0,
                      ),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Color(0x00000000),
                        width: 2.0,
                      ),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    focusedErrorBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Color(0x00000000),
                        width: 2.0,
                      ),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    contentPadding:
                        EdgeInsetsDirectional.fromSTEB(20.0, 32.0, 20.0, 12.0),
                  ),
                  style: AppTheme.of(context).bodyMedium.override(
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
                  textAlign: TextAlign.start,
                  maxLines: 4,
                  keyboardType: TextInputType.multiline,
                  validator: _model.shortBioTextControllerValidator
                      .asValidator(context),
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
                        context.pop();
                      },
                      text: AppLocalizations.of(context).getText(
                        'farrki57' /* Create Note */,
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
