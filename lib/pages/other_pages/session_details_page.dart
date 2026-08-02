import '/backend/sqlite/sqlite_manager.dart';
import '/backend/supabase/supabase.dart';
import '/bina_design/bina_design.dart';
import '/app_core/app_util.dart';
import 'package:flutter/material.dart';
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
            pitch: image.pitch,
            roll: image.roll,
            estimatedRegion: image.estimatedRegion,
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
            pitch: image.pitch,
            roll: image.roll,
            estimatedRegion: image.estimatedRegion,
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
      builder: (context) => _ImageDetailSheet(
        originalImage: image.originalImage,
        diagnosedImage: image.diagnosedImage,
        detections: jsonDecode(image.rawResponse),
        pitch: image.pitch,
        roll: image.roll,
        estimatedRegion: image.estimatedRegion,
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
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: BinaColors.surfaceAlt,
        body: SafeArea(
          child: Column(
            children: [
              // Header
              Container(
                padding: const EdgeInsets.fromLTRB(8, 8, 16, 8),
                decoration: BoxDecoration(
                  color: BinaColors.surface,
                  border: Border(bottom: BorderSide(color: BinaColors.line)),
                ),
                child: Row(
                  children: [
                    BinaIconButton(
                      icon: Icons.chevron_left_rounded,
                      onPressed: () => context.pop(),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      AppLocalizations.of(context).getText('sesd001'),
                      style: BinaType.titleLg,
                    ),
                  ],
                ),
              ),
              // Content
              Expanded(child: _buildBody()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return Center(
        child: CircularProgressIndicator(color: BinaColors.primary),
      );
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: BinaColors.error100,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(Icons.error_outline_rounded, color: BinaColors.error, size: 36),
              ),
              const SizedBox(height: 20),
              Text(
                AppLocalizations.of(context).getText('sesd009'),
                style: BinaType.titleMd,
              ),
              const SizedBox(height: 8),
              Text(
                _error!,
                style: BinaType.bodySm.copyWith(color: BinaColors.ink2),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    if (_images.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: BinaColors.surfaceSunken,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(Icons.photo_library_outlined, color: BinaColors.ink3, size: 36),
            ),
            const SizedBox(height: 20),
            Text(
              AppLocalizations.of(context).getText('sesd011'),
              style: BinaType.titleMd.copyWith(color: BinaColors.ink2),
            ),
            const SizedBox(height: 8),
            Text(
              AppLocalizations.of(context).getText('sesd012'),
              style: BinaType.bodySm.copyWith(color: BinaColors.ink3),
            ),
          ],
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 1,
      ),
      itemCount: _images.length,
      itemBuilder: (context, index) {
        final image = _images[index];
        return GestureDetector(
          onTap: () => _showImageDetailSheet(image),
          child: Container(
            decoration: BoxDecoration(
              color: BinaColors.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: BinaColors.line),
            ),
            clipBehavior: Clip.antiAlias,
            child: Stack(
              fit: StackFit.expand,
              children: [
                if (image.diagnosedImage != null)
                  Image.memory(
                    image.diagnosedImage!,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Center(
                      child: Icon(Icons.broken_image_rounded, color: BinaColors.error, size: 28),
                    ),
                  )
                else if (image.originalImage != null)
                  Image.memory(
                    image.originalImage!,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Center(
                      child: Icon(Icons.broken_image_rounded, color: BinaColors.error, size: 28),
                    ),
                  )
                else
                  Center(
                    child: Icon(Icons.image_not_supported_rounded, color: BinaColors.ink3, size: 28),
                  ),
                Positioned(
                  bottom: 6,
                  right: 6,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: BinaColors.ink.withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Icon(Icons.zoom_in_rounded, color: Colors.white, size: 14),
                  ),
                ),
              ],
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
  final int? pitch;
  final int? roll;
  final String? estimatedRegion;

  _ImageData({
    required this.id,
    this.originalImage,
    this.diagnosedImage,
    required this.rawResponse,
    this.capturedAt,
    this.pitch,
    this.roll,
    this.estimatedRegion,
  });
}

// Image detail bottom sheet
class _ImageDetailSheet extends StatefulWidget {
  const _ImageDetailSheet({
    this.originalImage,
    this.diagnosedImage,
    this.detections,
    this.pitch,
    this.roll,
    this.estimatedRegion,
  });

  final Uint8List? originalImage;
  final Uint8List? diagnosedImage;
  final List<dynamic>? detections;
  final int? pitch;
  final int? roll;
  final String? estimatedRegion;

  @override
  State<_ImageDetailSheet> createState() => _ImageDetailSheetState();
}

class _ImageDetailSheetState extends State<_ImageDetailSheet> {
  bool _showAnnotated = true;

  String _formatClassName(String className) {
    final words = className.split('_');
    return words.map((word) {
      if (word.isEmpty) return word;
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }).join(' ');
  }

  @override
  Widget build(BuildContext context) {
    final issueDetections = widget.detections?.where((d) {
          final className = (d as Map<String, dynamic>)['className'] as String;
          return !className.startsWith('tooth_');
        }).toList() ??
        [];
    final teethDetections = widget.detections?.where((d) {
          final className = (d as Map<String, dynamic>)['className'] as String;
          return className.startsWith('tooth_');
        }).toList() ??
        [];

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: BoxDecoration(
        color: BinaColors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Drag handle
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: BinaColors.line,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          // Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Image toggle
                  Row(
                    children: [
                      Text('Image Preview', style: BinaType.titleMd),
                      const Spacer(),
                      if (widget.diagnosedImage != null && widget.originalImage != null)
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: BinaColors.surfaceSunken,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            children: [
                              _ToggleChip(
                                label: 'Annotated',
                                isSelected: _showAnnotated,
                                onTap: () => setState(() => _showAnnotated = true),
                              ),
                              _ToggleChip(
                                label: 'Original',
                                isSelected: !_showAnnotated,
                                onTap: () => setState(() => _showAnnotated = false),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Image
                  Container(
                    width: double.infinity,
                    constraints: const BoxConstraints(maxHeight: 280),
                    decoration: BoxDecoration(
                      color: BinaColors.surfaceSunken,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: BinaColors.line),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: _buildImagePreview(),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    (widget.pitch != null && widget.roll != null)
                        ? 'Orientation · pitch ${widget.pitch}° · roll ${widget.roll}°'
                            '${widget.estimatedRegion != null ? ' · region ${widget.estimatedRegion}' : ''}'
                        : 'Orientation · unavailable',
                    style: BinaType.bodySm.copyWith(color: BinaColors.ink3),
                  ),
                  const SizedBox(height: 24),
                  // Detection Summary
                  Text(
                    AppLocalizations.of(context).getText('sesd015'),
                    style: BinaType.titleMd,
                  ),
                  const SizedBox(height: 12),
                  // Issues section
                  if (issueDetections.isNotEmpty) ...[
                    Text(
                      AppLocalizations.of(context).getText('sesd016'),
                      style: BinaType.labelLg.copyWith(color: BinaColors.error),
                    ),
                    const SizedBox(height: 8),
                    ...issueDetections.map((d) {
                      final det = d as Map<String, dynamic>;
                      final className = det['className'] as String;
                      final confidence = det['confidence'] as double;
                      final displayName = _formatClassName(className);
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: BinaColors.error100,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.warning_amber_rounded, color: BinaColors.error, size: 20),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(displayName, style: BinaType.bodyMd),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: BinaColors.error,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  '${(confidence * 100).toStringAsFixed(0)}%',
                                  style: BinaType.labelSm.copyWith(color: Colors.white),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                  ] else
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: BinaColors.success100,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.check_circle_rounded, color: BinaColors.success, size: 20),
                          const SizedBox(width: 10),
                          Text(
                            AppLocalizations.of(context).getText('sesd017'),
                            style: BinaType.bodyMd.copyWith(color: BinaColors.success),
                          ),
                        ],
                      ),
                    ),
                  // Teeth section
                  if (teethDetections.isNotEmpty) ...[
                    const SizedBox(height: 20),
                    Text(
                      AppLocalizations.of(context).getText('sesd018'),
                      style: BinaType.labelLg,
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: BinaColors.surfaceSunken,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: teethDetections.map((d) {
                          final det = d as Map<String, dynamic>;
                          final className = det['className'] as String;
                          final toothNumber = className.replaceFirst('tooth_', '');
                          return Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: BinaColors.success,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              '#$toothNumber',
                              style: BinaType.labelSm.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImagePreview() {
    final imageToShow = _showAnnotated ? widget.diagnosedImage : widget.originalImage;
    final fallbackImage = _showAnnotated ? widget.originalImage : widget.diagnosedImage;
    final displayImage = imageToShow ?? fallbackImage;

    if (displayImage != null) {
      return Image.memory(
        displayImage,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.broken_image_rounded, color: BinaColors.ink3, size: 40),
              const SizedBox(height: 8),
              Text('Failed to load image', style: BinaType.bodySm.copyWith(color: BinaColors.ink3)),
            ],
          ),
        ),
      );
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.image_not_supported_rounded, color: BinaColors.ink3, size: 40),
          const SizedBox(height: 8),
          Text('Image not available', style: BinaType.bodySm.copyWith(color: BinaColors.ink3)),
        ],
      ),
    );
  }
}

class _ToggleChip extends StatelessWidget {
  const _ToggleChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: BinaMotion.d1,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? BinaColors.surface : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          boxShadow: isSelected ? BinaElevation.sh1 : null,
        ),
        child: Text(
          label,
          style: BinaType.labelSm.copyWith(
            color: isSelected ? BinaColors.ink : BinaColors.ink3,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

// Legacy export for backwards compatibility
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

  @override
  Widget build(BuildContext context) {
    return _ImageDetailSheet(
      originalImage: originalImage,
      diagnosedImage: diagnosedImage,
      detections: detections,
    );
  }
}
