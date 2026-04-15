import '/app_core/app_theme.dart';
import '/app_core/app_util.dart';
import '/app_core/app_widgets.dart';
import '/app_core/upload_data.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'profile_pic_model.dart';
export 'profile_pic_model.dart';

class ProfilePicWidget extends StatefulWidget {
  const ProfilePicWidget({super.key});

  @override
  State<ProfilePicWidget> createState() => _ProfilePicWidgetState();
}

class _ProfilePicWidgetState extends State<ProfilePicWidget> {
  late ProfilePicModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => ProfilePicModel());

    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.maybeDispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.max,
      children: [
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
                  ],
                ),
              ),
            ),
          ),
        ),
        Align(
          alignment: AlignmentDirectional(0.0, -1.0),
          child: Padding(
            padding: EdgeInsets.all(18.0),
            child: AppButtonWidget(
              onPressed: () async {
                final selectedMedia = await selectMediaWithSourceBottomSheet(
                  context: context,
                  allowPhoto: true,
                );
                if (selectedMedia != null &&
                    selectedMedia.every(
                        (m) => validateFileFormat(m.storagePath, context))) {
                  safeSetState(
                      () => _model.isDataUploading_uploadDataUox = true);
                  var selectedUploadedFiles = <AppUploadedFile>[];

                  try {
                    showUploadMessage(
                      context,
                      'Uploading file...',
                      showLoading: true,
                    );
                    selectedUploadedFiles = selectedMedia
                        .map((m) => AppUploadedFile(
                              name: m.storagePath.split('/').last,
                              bytes: m.bytes,
                              height: m.dimensions?.height,
                              width: m.dimensions?.width,
                              blurHash: m.blurHash,
                              originalFilename: m.originalFilename,
                            ))
                        .toList();
                  } finally {
                    ScaffoldMessenger.of(context).hideCurrentSnackBar();
                    _model.isDataUploading_uploadDataUox = false;
                  }
                  if (selectedUploadedFiles.length == selectedMedia.length) {
                    safeSetState(() {
                      _model.uploadedLocalFile_uploadDataUox =
                          selectedUploadedFiles.first;
                    });
                    showUploadMessage(context, 'Success!');
                  } else {
                    safeSetState(() {});
                    showUploadMessage(context, 'Failed to upload data');
                    return;
                  }
                }
              },
              text: AppLocalizations.of(context).getText(
                'muz1mh5f' /* Change Photo */,
              ),
              options: AppButtonOptions(
                width: 130.0,
                height: 40.0,
                padding: EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 0.0),
                iconPadding: EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 0.0),
                color: AppTheme.of(context).primaryBackground,
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
      ],
    );
  }
}
