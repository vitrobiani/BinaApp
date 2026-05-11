import '/backend/sqlite/sqlite_manager.dart';
import '/backend/supabase/supabase.dart';
import '/app_core/app_icon_button.dart';
import '/app_core/app_theme.dart';
import '/app_core/app_util.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'session_details_page_model.dart';
export 'session_details_page_model.dart';

class SessionDetailsPageWidget extends StatefulWidget {
  const SessionDetailsPageWidget({
    super.key,
    required this.sessionId,
  });

  final String? sessionId;

  static String routeName = 'SessionDetailsPage';
  static String routePath = 'sessionDetails';

  @override
  State<SessionDetailsPageWidget> createState() =>
      _SessionDetailsPageWidgetState();
}

class _SessionDetailsPageWidgetState extends State<SessionDetailsPageWidget> {
  late SessionDetailsPageModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  bool _isLoading = true;
  List<_ImageData> _images = [];
  String? _error;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => SessionDetailsPageModel());
    _loadImages();
  }

  Future<void> _loadImages() async {
    try {
      final isLocal = AppState().UserSession.isLocalSession;
      List<_ImageData> images = [];

      debugPrint('Loading images for session: ${widget.sessionId}, isLocal: $isLocal');

      if (widget.sessionId == null || widget.sessionId!.isEmpty) {
        debugPrint('Warning: sessionId is null or empty!');
        if (mounted) {
          setState(() {
            _error = 'Invalid session ID';
            _isLoading = false;
          });
        }
        return;
      }

      if (isLocal) {
        // Load from SQLite
        final scanImages = await SQLiteManager.instance.getScanImagesBySessionId(
          sessionId: widget.sessionId,
        );

        debugPrint('SQLite: Found ${scanImages.length} images');

        for (final image in scanImages) {
          images.add(_ImageData(
            id: image.id,
            originalImage: image.image != null ? Uint8List.fromList(image.image!) : null,
            diagnosedImage: image.diagnosedImage != null ? Uint8List.fromList(image.diagnosedImage!) : null,
            rawResponse: image.rawResponse ?? '[]',
            capturedAt: image.capturedAt != null
                ? DateTime.fromMillisecondsSinceEpoch(image.capturedAt! * 1000)
                : null,
          ));
        }
      } else {
        // Load from Supabase
        final scanImages = await ScanImagesTable().queryRows(
          queryFn: (q) => q
              .eq('scan_session_id', widget.sessionId!)
              .order('captured_at'),
        );

        debugPrint('Supabase: Found ${scanImages.length} images');

        for (final image in scanImages) {
          debugPrint('  Supabase Image ${image.id}: diagnosed=${image.diagnosedImage != null ? "${image.diagnosedImage!.length} bytes" : "null"}, original=${image.image != null ? "${image.image!.length} bytes" : "null"}');
          images.add(_ImageData(
            id: image.id,
            originalImage: image.image,
            diagnosedImage: image.diagnosedImage,
            rawResponse: image.rawResponse ?? '[]',
            capturedAt: image.capturedAt,
          ));
        }
      }

      debugPrint('Total images loaded: ${images.length}');
      for (final img in images) {
        debugPrint('  Final image data: diagnosed=${img.diagnosedImage != null ? "${img.diagnosedImage!.length} bytes" : "null"}, original=${img.originalImage != null ? "${img.originalImage!.length} bytes" : "null"}');
      }

      if (mounted) {
        setState(() {
          _images = images;
          _isLoading = false;
        });
      }
    } catch (e, stackTrace) {
      debugPrint('Error loading images: $e');
      debugPrint('Stack trace: $stackTrace');
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  void _showImageDetailSheet(_ImageData image) {
    showModalBottomSheet(
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      enableDrag: true,
      context: context,
      builder: (context) => ImageDetailSheetWidgetWithBytes(
        originalImage: image.originalImage,
        diagnosedImage: image.diagnosedImage,
        detections: jsonDecode(image.rawResponse),
      ),
    );
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      backgroundColor: AppTheme.of(context).primaryBackground,
      appBar: AppBar(
        backgroundColor: AppTheme.of(context).secondaryBackground,
        automaticallyImplyLeading: false,
        leading: AppIconButton(
          borderColor: Colors.transparent,
          borderRadius: 30.0,
          borderWidth: 1.0,
          buttonSize: 60.0,
          icon: Icon(
            Icons.arrow_back_rounded,
            color: AppTheme.of(context).primaryText,
            size: 30.0,
          ),
          onPressed: () async {
            context.pop();
          },
        ),
        title: Text(
          AppLocalizations.of(context).getText('sesd001' /* Session Details */),
          style: AppTheme.of(context).headlineMedium.override(
                font: GoogleFonts.readexPro(
                  fontWeight: AppTheme.of(context).headlineMedium.fontWeight,
                  fontStyle: AppTheme.of(context).headlineMedium.fontStyle,
                ),
                letterSpacing: 0.0,
              ),
        ),
        actions: [],
        centerTitle: false,
        elevation: 2.0,
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return Center(
        child: CircularProgressIndicator(
          color: AppTheme.of(context).primary,
        ),
      );
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              color: AppTheme.of(context).error,
              size: 64.0,
            ),
            SizedBox(height: 16.0),
            Text(
              AppLocalizations.of(context).getText('sesd009' /* Error loading images */),
              style: AppTheme.of(context).titleMedium.override(
                    font: GoogleFonts.inter(
                      fontWeight: AppTheme.of(context).titleMedium.fontWeight,
                      fontStyle: AppTheme.of(context).titleMedium.fontStyle,
                    ),
                    letterSpacing: 0.0,
                  ),
            ),
            SizedBox(height: 8.0),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 32.0),
              child: Text(
                _error!,
                style: AppTheme.of(context).bodySmall.override(
                      font: GoogleFonts.inter(
                        fontWeight: AppTheme.of(context).bodySmall.fontWeight,
                        fontStyle: AppTheme.of(context).bodySmall.fontStyle,
                      ),
                      color: AppTheme.of(context).secondaryText,
                      letterSpacing: 0.0,
                    ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      );
    }

    if (_images.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.photo_library_outlined,
              color: AppTheme.of(context).secondaryText,
              size: 64.0,
            ),
            SizedBox(height: 16.0),
            Text(
              AppLocalizations.of(context).getText('sesd011' /* No images found */),
              style: AppTheme.of(context).titleMedium.override(
                    font: GoogleFonts.inter(
                      fontWeight: AppTheme.of(context).titleMedium.fontWeight,
                      fontStyle: AppTheme.of(context).titleMedium.fontStyle,
                    ),
                    color: AppTheme.of(context).secondaryText,
                    letterSpacing: 0.0,
                  ),
            ),
            SizedBox(height: 8.0),
            Text(
              AppLocalizations.of(context).getText('sesd012' /* This session has no images */),
              style: AppTheme.of(context).bodySmall.override(
                    font: GoogleFonts.inter(
                      fontWeight: AppTheme.of(context).bodySmall.fontWeight,
                      fontStyle: AppTheme.of(context).bodySmall.fontStyle,
                    ),
                    letterSpacing: 0.0,
                  ),
            ),
          ],
        ),
      );
    }

    return GridView.builder(
      padding: EdgeInsets.all(16.0),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 10.0,
        mainAxisSpacing: 10.0,
        childAspectRatio: 1.0,
      ),
      itemCount: _images.length,
      itemBuilder: (context, index) {
        final image = _images[index];
        return InkWell(
          onTap: () => _showImageDetailSheet(image),
          child: Container(
            decoration: BoxDecoration(
              color: AppTheme.of(context).secondaryBackground,
              borderRadius: BorderRadius.circular(8.0),
              border: Border.all(
                color: AppTheme.of(context).alternate,
                width: 2.0,
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(6.0),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  if (image.diagnosedImage != null)
                    Image.memory(
                      image.diagnosedImage!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        debugPrint('Error loading image: $error');
                        return Center(
                          child: Icon(
                            Icons.broken_image,
                            color: AppTheme.of(context).error,
                            size: 30.0,
                          ),
                        );
                      },
                    )
                  else if (image.originalImage != null)
                    Image.memory(
                      image.originalImage!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        debugPrint('Error loading original image: $error');
                        return Center(
                          child: Icon(
                            Icons.broken_image,
                            color: AppTheme.of(context).error,
                            size: 30.0,
                          ),
                        );
                      },
                    )
                  else
                    Center(
                      child: Icon(
                        Icons.image_not_supported,
                        color: AppTheme.of(context).secondaryText,
                        size: 30.0,
                      ),
                    ),
                  Positioned(
                    bottom: 4.0,
                    right: 4.0,
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 6.0, vertical: 2.0),
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(4.0),
                      ),
                      child: Icon(
                        Icons.zoom_in,
                        color: Colors.white,
                        size: 16.0,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

// Data class for image information
class _ImageData {
  final String id;
  final Uint8List? originalImage;
  final Uint8List? diagnosedImage;
  final String rawResponse;
  final DateTime? capturedAt;

  _ImageData({
    required this.id,
    this.originalImage,
    this.diagnosedImage,
    required this.rawResponse,
    this.capturedAt,
  });
}

// New widget that handles bytes instead of file paths
class ImageDetailSheetWidgetWithBytes extends StatelessWidget {
  const ImageDetailSheetWidgetWithBytes({
    super.key,
    this.originalImage,
    this.diagnosedImage,
    this.detections,
  });

  final Uint8List? originalImage;
  final Uint8List? diagnosedImage;
  final List<dynamic>? detections;

  String _formatClassName(String className) {
    final words = className.split('_');
    return words.map((word) {
      if (word.isEmpty) return word;
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }).join(' ');
  }

  @override
  Widget build(BuildContext context) {
    final issueDetections = detections?.where((d) {
          final className = (d as Map<String, dynamic>)['className'] as String;
          return !className.startsWith('tooth_');
        }).toList() ??
        [];
    final teethDetections = detections?.where((d) {
          final className = (d as Map<String, dynamic>)['className'] as String;
          return className.startsWith('tooth_');
        }).toList() ??
        [];

    return Material(
      color: Colors.transparent,
      child: Container(
        height: MediaQuery.of(context).size.height * 0.85,
        decoration: BoxDecoration(
          color: AppTheme.of(context).secondaryBackground,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(16.0),
            topRight: Radius.circular(16.0),
          ),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Drag handle
              Center(
                child: Container(
                  width: 40.0,
                  height: 4.0,
                  margin: EdgeInsets.symmetric(vertical: 12.0),
                  decoration: BoxDecoration(
                    color: AppTheme.of(context).alternate,
                    borderRadius: BorderRadius.circular(2.0),
                  ),
                ),
              ),
              // Original Image Section
              Padding(
                padding: EdgeInsetsDirectional.fromSTEB(16.0, 8.0, 16.0, 0.0),
                child: Text(
                  AppLocalizations.of(context).getText('sesd013' /* Original Image */),
                  style: AppTheme.of(context).titleMedium.override(
                        font: GoogleFonts.inter(
                          fontWeight: AppTheme.of(context).titleMedium.fontWeight,
                          fontStyle: AppTheme.of(context).titleMedium.fontStyle,
                        ),
                        letterSpacing: 0.0,
                      ),
                ),
              ),
              SizedBox(height: 8.0),
              if (originalImage != null)
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0),
                  child: Container(
                    width: double.infinity,
                    constraints: BoxConstraints(maxHeight: 250.0),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12.0),
                      border: Border.all(
                        color: AppTheme.of(context).alternate,
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(11.0),
                      child: Image.memory(
                        originalImage!,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                )
              else
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0),
                  child: Container(
                    width: double.infinity,
                    height: 150.0,
                    decoration: BoxDecoration(
                      color: AppTheme.of(context).alternate,
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    child: Center(
                      child: Text(
                        AppLocalizations.of(context).getText('sesd019' /* Original image not available */),
                        style: AppTheme.of(context).bodyMedium.override(
                              font: GoogleFonts.inter(
                                fontWeight: AppTheme.of(context).bodyMedium.fontWeight,
                                fontStyle: AppTheme.of(context).bodyMedium.fontStyle,
                              ),
                              color: AppTheme.of(context).secondaryText,
                              letterSpacing: 0.0,
                            ),
                      ),
                    ),
                  ),
                ),
              SizedBox(height: 16.0),
              // Diagnosed Image Section
              Padding(
                padding: EdgeInsetsDirectional.fromSTEB(16.0, 0.0, 16.0, 0.0),
                child: Text(
                  AppLocalizations.of(context).getText('sesd014' /* Diagnosed Image */),
                  style: AppTheme.of(context).titleMedium.override(
                        font: GoogleFonts.inter(
                          fontWeight: AppTheme.of(context).titleMedium.fontWeight,
                          fontStyle: AppTheme.of(context).titleMedium.fontStyle,
                        ),
                        letterSpacing: 0.0,
                      ),
                ),
              ),
              SizedBox(height: 8.0),
              if (diagnosedImage != null)
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0),
                  child: Container(
                    width: double.infinity,
                    constraints: BoxConstraints(maxHeight: 250.0),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12.0),
                      border: Border.all(
                        color: AppTheme.of(context).alternate,
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(11.0),
                      child: Image.memory(
                        diagnosedImage!,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                )
              else
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0),
                  child: Container(
                    width: double.infinity,
                    height: 150.0,
                    decoration: BoxDecoration(
                      color: AppTheme.of(context).alternate,
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    child: Center(
                      child: Text(
                        AppLocalizations.of(context).getText('sesd020' /* Diagnosed image not available */),
                        style: AppTheme.of(context).bodyMedium.override(
                              font: GoogleFonts.inter(
                                fontWeight: AppTheme.of(context).bodyMedium.fontWeight,
                                fontStyle: AppTheme.of(context).bodyMedium.fontStyle,
                              ),
                              color: AppTheme.of(context).secondaryText,
                              letterSpacing: 0.0,
                            ),
                      ),
                    ),
                  ),
                ),
              SizedBox(height: 16.0),
              // Detection Summary Section
              Padding(
                padding: EdgeInsetsDirectional.fromSTEB(16.0, 0.0, 16.0, 0.0),
                child: Text(
                  AppLocalizations.of(context).getText('sesd015' /* Detection Summary */),
                  style: AppTheme.of(context).titleMedium.override(
                        font: GoogleFonts.inter(
                          fontWeight: AppTheme.of(context).titleMedium.fontWeight,
                          fontStyle: AppTheme.of(context).titleMedium.fontStyle,
                        ),
                        letterSpacing: 0.0,
                      ),
                ),
              ),
              SizedBox(height: 12.0),
              // Issues Found Section
              if (issueDetections.isNotEmpty)
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppLocalizations.of(context).getText('sesd016' /* Issues Found */),
                        style: AppTheme.of(context).titleSmall.override(
                              font: GoogleFonts.inter(
                                fontWeight: FontWeight.w600,
                                fontStyle: AppTheme.of(context).titleSmall.fontStyle,
                              ),
                              color: AppTheme.of(context).error,
                              letterSpacing: 0.0,
                            ),
                      ),
                      SizedBox(height: 8.0),
                      ...issueDetections.map((d) {
                        final det = d as Map<String, dynamic>;
                        final className = det['className'] as String;
                        final confidence = det['confidence'] as double;
                        final displayName = _formatClassName(className);
                        return Padding(
                          padding: EdgeInsets.only(bottom: 8.0),
                          child: Container(
                            width: double.infinity,
                            padding: EdgeInsets.all(12.0),
                            decoration: BoxDecoration(
                              color: AppTheme.of(context).error.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8.0),
                              border: Border.all(
                                color: AppTheme.of(context).error.withOpacity(0.3),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      Icons.warning_amber_rounded,
                                      color: AppTheme.of(context).error,
                                      size: 20.0,
                                    ),
                                    SizedBox(width: 8.0),
                                    Text(
                                      displayName,
                                      style: AppTheme.of(context).bodyMedium.override(
                                            font: GoogleFonts.inter(
                                              fontWeight: FontWeight.w500,
                                              fontStyle: AppTheme.of(context).bodyMedium.fontStyle,
                                            ),
                                            letterSpacing: 0.0,
                                          ),
                                    ),
                                  ],
                                ),
                                Container(
                                  padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                                  decoration: BoxDecoration(
                                    color: AppTheme.of(context).error,
                                    borderRadius: BorderRadius.circular(12.0),
                                  ),
                                  child: Text(
                                    '${(confidence * 100).toStringAsFixed(0)}%',
                                    style: AppTheme.of(context).bodySmall.override(
                                          font: GoogleFonts.inter(
                                            fontWeight: FontWeight.w600,
                                            fontStyle: AppTheme.of(context).bodySmall.fontStyle,
                                          ),
                                          color: Colors.white,
                                          letterSpacing: 0.0,
                                        ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ],
                  ),
                ),
              // No issues message
              if (issueDetections.isEmpty)
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0),
                  child: Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(12.0),
                    decoration: BoxDecoration(
                      color: AppTheme.of(context).success.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8.0),
                      border: Border.all(
                        color: AppTheme.of(context).success.withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.check_circle,
                          color: AppTheme.of(context).success,
                          size: 20.0,
                        ),
                        SizedBox(width: 8.0),
                        Text(
                          AppLocalizations.of(context).getText('sesd017' /* No issues detected */),
                          style: AppTheme.of(context).bodyMedium.override(
                                font: GoogleFonts.inter(
                                  fontWeight: FontWeight.w500,
                                  fontStyle: AppTheme.of(context).bodyMedium.fontStyle,
                                ),
                                color: AppTheme.of(context).success,
                                letterSpacing: 0.0,
                              ),
                        ),
                      ],
                    ),
                  ),
                ),
              SizedBox(height: 16.0),
              // Teeth Detected Section
              if (teethDetections.isNotEmpty)
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppLocalizations.of(context).getText('sesd018' /* Teeth Detected */),
                        style: AppTheme.of(context).titleSmall.override(
                              font: GoogleFonts.inter(
                                fontWeight: FontWeight.w600,
                                fontStyle: AppTheme.of(context).titleSmall.fontStyle,
                              ),
                              letterSpacing: 0.0,
                            ),
                      ),
                      SizedBox(height: 8.0),
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(12.0),
                        decoration: BoxDecoration(
                          color: AppTheme.of(context).primaryBackground,
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        child: Wrap(
                          spacing: 8.0,
                          runSpacing: 8.0,
                          children: teethDetections.map((d) {
                            final det = d as Map<String, dynamic>;
                            final className = det['className'] as String;
                            final toothNumber = className.replaceFirst('tooth_', '');
                            return Container(
                              padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
                              decoration: BoxDecoration(
                                color: AppTheme.of(context).success,
                                borderRadius: BorderRadius.circular(16.0),
                              ),
                              child: Text(
                                '#$toothNumber',
                                style: AppTheme.of(context).bodySmall.override(
                                      font: GoogleFonts.inter(
                                        fontWeight: FontWeight.w600,
                                        fontStyle: AppTheme.of(context).bodySmall.fontStyle,
                                      ),
                                      color: Colors.white,
                                      letterSpacing: 0.0,
                                    ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ),
                ),
              SizedBox(height: 24.0),
            ],
          ),
        ),
      ),
    );
  }
}
