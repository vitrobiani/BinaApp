import '/backend/schema/enums/enums.dart';
import '/app_core/app_theme.dart';
import '/app_core/app_util.dart';
import '/app_core/app_widgets.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'family_row_detail_model.dart';
export 'family_row_detail_model.dart';

class FamilyRowDetailWidget extends StatefulWidget {
  const FamilyRowDetailWidget({
    super.key,
    required this.name,
    this.score,
    this.profilePic,
    required this.lastChecked,
    required this.gender,
    required this.age,
  });

  final String? name;
  final double? score;
  final AppUploadedFile? profilePic;
  final DateTime? lastChecked;
  final Genders? gender;
  final int? age;

  @override
  State<FamilyRowDetailWidget> createState() => _FamilyRowDetailWidgetState();
}

class _FamilyRowDetailWidgetState extends State<FamilyRowDetailWidget> {
  late FamilyRowDetailModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => FamilyRowDetailModel());

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
      padding: EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 2.0),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: AppTheme.of(context).secondaryBackground,
          boxShadow: [
            BoxShadow(
              blurRadius: 0.0,
              color: AppTheme.of(context).alternate,
              offset: Offset(
                0.0,
                1.0,
              ),
            )
          ],
        ),
        child: Padding(
          padding: EdgeInsets.all(12.0),
          child: Row(
            mainAxisSize: MainAxisSize.max,
            children: [
              Expanded(
                flex: 2,
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Padding(
                          padding: EdgeInsetsDirectional.fromSTEB(
                              0.0, 0.0, 12.0, 0.0),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12.0),
                            child: CachedNetworkImage(
                              fadeInDuration: Duration(milliseconds: 500),
                              fadeOutDuration: Duration(milliseconds: 500),
                              imageUrl:
                                  'https://cdn.pixabay.com/photo/2015/10/05/22/37/blank-profile-picture-973460_1280.png',
                              width: 40.0,
                              height: 40.0,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        Column(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            AutoSizeText(
                              valueOrDefault<String>(
                                widget.name,
                                'omer or gabi',
                              ).maybeHandleOverflow(
                                maxChars: 32,
                                replacement: '…',
                              ),
                              style: AppTheme.of(context)
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
                                    fontSize: 17.0,
                                    letterSpacing: 0.0,
                                    fontWeight: AppTheme.of(context)
                                        .titleMedium
                                        .fontWeight,
                                    fontStyle: AppTheme.of(context)
                                        .titleMedium
                                        .fontStyle,
                                  ),
                            ),
                            Padding(
                              padding: EdgeInsetsDirectional.fromSTEB(
                                  0.0, 2.0, 0.0, 0.0),
                              child: Text(
                                'Last Checked: ${widget.lastChecked?.toString()}',
                                style: AppTheme.of(context)
                                    .bodyMedium
                                    .override(
                                      font: GoogleFonts.inter(
                                        fontWeight: AppTheme.of(context)
                                            .bodyMedium
                                            .fontWeight,
                                        fontStyle: AppTheme.of(context)
                                            .bodyMedium
                                            .fontStyle,
                                      ),
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
                      ],
                    ),
                    Text(
                      widget.score.toString(),
                      style: AppTheme.of(context).bodyMedium.override(
                            font: GoogleFonts.inter(
                              fontWeight: AppTheme.of(context)
                                  .bodyMedium
                                  .fontWeight,
                              fontStyle: AppTheme.of(context)
                                  .bodyMedium
                                  .fontStyle,
                            ),
                            letterSpacing: 0.0,
                            fontWeight: AppTheme.of(context)
                                .bodyMedium
                                .fontWeight,
                            fontStyle: AppTheme.of(context)
                                .bodyMedium
                                .fontStyle,
                          ),
                    ),
                    if (responsiveVisibility(
                      context: context,
                      phone: false,
                      tablet: false,
                    ))
                      AppButtonWidget(
                        onPressed: () {
                          print('Button pressed ...');
                        },
                        text: AppLocalizations.of(context).getText(
                          'yhtoc3s4' /* Diagnostics */,
                        ),
                        options: AppButtonOptions(
                          height: 40.0,
                          padding: EdgeInsetsDirectional.fromSTEB(
                              16.0, 0.0, 16.0, 0.0),
                          iconPadding: EdgeInsetsDirectional.fromSTEB(
                              0.0, 0.0, 0.0, 0.0),
                          color: AppTheme.of(context).secondary,
                          textStyle:
                              AppTheme.of(context).titleSmall.override(
                                    font: GoogleFonts.inter(
                                      fontWeight: AppTheme.of(context)
                                          .titleSmall
                                          .fontWeight,
                                      fontStyle: AppTheme.of(context)
                                          .titleSmall
                                          .fontStyle,
                                    ),
                                    color: Colors.white,
                                    letterSpacing: 0.0,
                                    fontWeight: AppTheme.of(context)
                                        .titleSmall
                                        .fontWeight,
                                    fontStyle: AppTheme.of(context)
                                        .titleSmall
                                        .fontStyle,
                                  ),
                          elevation: 0.0,
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
