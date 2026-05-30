import '/app_core/app_util.dart';
import '/app_core/upload_data.dart';
import '/bina_design/bina_design.dart';
import 'package:flutter/material.dart';
import 'diagnosis_cavity_model.dart';
export 'diagnosis_cavity_model.dart';

class DiagnosisCavityWidget extends StatefulWidget {
  const DiagnosisCavityWidget({super.key});

  static String routeName = 'DiagnosisCavity';
  static String routePath = 'diagnosisCavity';

  @override
  State<DiagnosisCavityWidget> createState() => _DiagnosisCavityWidgetState();
}

class _DiagnosisCavityWidgetState extends State<DiagnosisCavityWidget> {
  late DiagnosisCavityModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => DiagnosisCavityModel());

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
        backgroundColor: BinaColors.surface,
        appBar: AppBar(
          backgroundColor: BinaColors.surface,
          automaticallyImplyLeading: false,
          title: Text(
            'Cavity Detection',
            style: BinaType.headlineMd,
          ),
          leading: Padding(
            padding: const EdgeInsets.only(left: BinaSpace.s3),
            child: BinaIconButton(
              icon: Icons.arrow_back_rounded,
              onPressed: () {
                context.safePop();
              },
            ),
          ),
          centerTitle: false,
          elevation: 0.0,
        ),
        body: SafeArea(
          top: true,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(BinaSpace.s4),
            child: Column(
              mainAxisSize: MainAxisSize.max,
              children: [
                // Upload image section
                BinaCard(
                  padding: const EdgeInsets.all(BinaSpace.s2),
                  child: SizedBox(
                    width: 300.0,
                    height: 300.0,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(BinaRadius.sm),
                      child: _model.uploadedLocalFile_uploadDataS7k.bytes != null &&
                              _model.uploadedLocalFile_uploadDataS7k.bytes!.isNotEmpty
                          ? Image.memory(
                              _model.uploadedLocalFile_uploadDataS7k.bytes!,
                              width: 200.0,
                              height: 200.0,
                              fit: BoxFit.cover,
                            )
                          : Container(
                              color: BinaColors.surfaceSunken,
                              child: Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.image_outlined,
                                      size: 48,
                                      color: BinaColors.ink3,
                                    ),
                                    const SizedBox(height: BinaSpace.s2),
                                    Text(
                                      'Upload an image',
                                      style: BinaType.bodySm,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                    ),
                  ),
                ),

                const SizedBox(height: BinaSpace.s4),

                // Upload button
                BinaButton(
                  label: AppLocalizations.of(context).getText(
                    '5ck7mnyd' /* Upload */,
                  ),
                  icon: Icons.upload_rounded,
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
                          () => _model.isDataUploading_uploadDataS7k = true);
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
                        _model.isDataUploading_uploadDataS7k = false;
                      }
                      if (selectedUploadedFiles.length == selectedMedia.length) {
                        safeSetState(() {
                          _model.uploadedLocalFile_uploadDataS7k =
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

                const SizedBox(height: BinaSpace.s3),

                // Detect button
                BinaButton(
                  label: AppLocalizations.of(context).getText(
                    'w0eizveb' /* Detect */,
                  ),
                  icon: Icons.search_rounded,
                  onPressed: () {
                    print('Button pressed ...');
                  },
                ),

                const SizedBox(height: BinaSpace.s6),

                // Result image section
                BinaCard(
                  padding: const EdgeInsets.all(BinaSpace.s2),
                  child: SizedBox(
                    width: 300.0,
                    height: 300.0,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(BinaRadius.sm),
                      child: Container(
                        color: BinaColors.surfaceSunken,
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.analytics_outlined,
                                size: 48,
                                color: BinaColors.ink3,
                              ),
                              const SizedBox(height: BinaSpace.s2),
                              Text(
                                'Detection result',
                                style: BinaType.bodySm,
                              ),
                            ],
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
    );
  }
}
