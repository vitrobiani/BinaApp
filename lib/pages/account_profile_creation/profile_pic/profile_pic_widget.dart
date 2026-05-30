import '/bina_design/bina_design.dart';
import '/app_core/app_util.dart';
import '/app_core/upload_data.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
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
          alignment: Alignment.topCenter,
          child: Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: BinaColors.primary100,
                shape: BoxShape.circle,
                border: Border.all(color: BinaColors.primary, width: 2),
              ),
              child: Padding(
                padding: const EdgeInsets.all(4),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(60),
                  child: CachedNetworkImage(
                    fadeInDuration: const Duration(milliseconds: 200),
                    fadeOutDuration: const Duration(milliseconds: 200),
                    imageUrl:
                        'https://images.unsplash.com/photo-1499887142886-791eca5918cd?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w0NTYyMDF8MHwxfHNlYXJjaHwxN3x8dXNlcnxlbnwwfHx8fDE2OTc4MjQ2MjZ8MA&ixlib=rb-4.0.3&q=80&w=400',
                    width: 300,
                    height: 200,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(18),
          child: BinaButton(
            label: AppLocalizations.of(context).getText('muz1mh5f'),
            variant: BinaButtonVariant.secondary,
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
          ),
        ),
      ],
    );
  }
}
