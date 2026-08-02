import '/backend/sqlite/sqlite_manager.dart';
import '/backend/supabase/supabase.dart';
import '/app_core/app_util.dart';
import '/bina_design/bina_design.dart';
import '/pages/nav_pages/web_nav/web_nav_widget.dart';
import '/services/gemma_service.dart';
import '/services/llm_prompts.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'session_summary_model.dart';
export 'session_summary_model.dart';

class SessionSummaryWidget extends StatefulWidget {
  const SessionSummaryWidget({
    super.key,
    this.sessionId,
    this.imageCount,
    this.memberName,
    this.overallStatus,
    // this.gemmaAnalysis,
  });

  final String? sessionId;
  final int? imageCount;
  final String? memberName;
  final String? overallStatus;
  // final String? gemmaAnalysis;

  static String routeName = 'SessionSummary';
  static String routePath = 'sessionSummary';

  @override
  State<SessionSummaryWidget> createState() => _SessionSummaryWidgetState();
}

class _SessionSummaryWidgetState extends State<SessionSummaryWidget> {
  late SessionSummaryModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  String? _llmSummary;
  bool _isGeneratingSummary = false;
  bool _isLoadingImages = true;
  List<_SessionImage> _images = [];
  int _totalIssues = 0;
  int _totalTeeth = 0;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => SessionSummaryModel());

    SchedulerBinding.instance.addPostFrameCallback((_) async {
      await _loadSessionImages();
      await _generateLlmSummary();
    });
  }

  Future<void> _loadSessionImages() async {
    if (widget.sessionId == null) {
      setState(() => _isLoadingImages = false);
      return;
    }

    try {
      final images = <_SessionImage>[];
      int totalIssues = 0;
      int totalTeeth = 0;

      if (AppState().UserSession.isLocalSession) {
        final rows = await SQLiteManager.instance.getScanImagesBySessionId(
          sessionId: widget.sessionId!,
        );

        for (final row in rows) {
          final detections = <Map<String, dynamic>>[];
          if (row.rawResponse != null && row.rawResponse!.isNotEmpty) {
            try {
              final parsed = jsonDecode(row.rawResponse!) as List<dynamic>;
              for (final d in parsed) {
                detections.add(d as Map<String, dynamic>);
              }
            } catch (_) {}
          }

          final issues = detections.where((d) =>
            !(d['className'] as String? ?? '').startsWith('tooth_')).length;
          final teeth = detections.where((d) =>
            (d['className'] as String? ?? '').startsWith('tooth_')).length;

          totalIssues += issues;
          totalTeeth += teeth;

          images.add(_SessionImage(
            id: row.id,
            imageBytes: row.diagnosedImage != null
                ? Uint8List.fromList(row.diagnosedImage!)
                : null,
            originalBytes: row.image != null
                ? Uint8List.fromList(row.image!)
                : null,
            detections: detections,
            capturedAt: row.capturedAt != null
                ? DateTime.fromMillisecondsSinceEpoch(row.capturedAt! * 1000)
                : DateTime.now(),
            issuesCount: issues,
            teethCount: teeth,
          ));
        }
      } else {
        final rows = await ScanImagesTable().queryRows(
          queryFn: (q) => q
              .eq('scan_session_id', widget.sessionId!)
              .order('captured_at'),
        );

        for (final row in rows) {
          final detections = <Map<String, dynamic>>[];
          if (row.rawResponse != null && row.rawResponse!.isNotEmpty) {
            try {
              final parsed = jsonDecode(row.rawResponse!) as List<dynamic>;
              for (final d in parsed) {
                detections.add(d as Map<String, dynamic>);
              }
            } catch (_) {}
          }

          final issues = detections.where((d) =>
            !(d['className'] as String? ?? '').startsWith('tooth_')).length;
          final teeth = detections.where((d) =>
            (d['className'] as String? ?? '').startsWith('tooth_')).length;

          totalIssues += issues;
          totalTeeth += teeth;

          // Supabase stores images as Uint8List
          images.add(_SessionImage(
            id: row.id,
            imageBytes: row.diagnosedImage,
            originalBytes: row.image,
            detections: detections,
            capturedAt: row.capturedAt ?? DateTime.now(),
            issuesCount: issues,
            teethCount: teeth,
          ));
        }
      }

      if (mounted) {
        setState(() {
          _images = images;
          _totalIssues = totalIssues;
          _totalTeeth = totalTeeth;
          _isLoadingImages = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading session images: $e');
      if (mounted) {
        setState(() => _isLoadingImages = false);
      }
    }
  }

  Future<void> _generateLlmSummary() async {
    // debugPrint("widget.gemmaAnalysis:");
    // debugPrint(widget.gemmaAnalysis);
    if (!GemmaService.instance.isModelLoaded) return;
    if (widget.sessionId == null) return;
    // if (widget.gemmaAnalysis!.isNotEmpty) {
    //   _llmSummary = widget.gemmaAnalysis;
    //   debugPrint(_llmSummary);
    //   return;
    // }

    setState(() {
      _isGeneratingSummary = true;
    });

    try {
      // Build findings from loaded images
      final allDetections = <Map<String, dynamic>>[];
      for (final image in _images) {
        allDetections.addAll(image.detections);
      }
      final findingsJson = jsonEncode(allDetections);

      final prompt = LlmPrompts.buildSessionSummaryPrompt(
        findingsJson: findingsJson,
        imageCount: widget.imageCount ?? _images.length,
        memberName: widget.memberName ?? 'Patient',
        overallStatus: widget.overallStatus ?? 'unknown',
      );

      final response = await GemmaService.instance.generateResponse(prompt);

      if (mounted && response.isNotEmpty) {
        setState(() {
          _llmSummary = response;
          _isGeneratingSummary = false;
        });

        // Save summary to database
        await _saveSummaryToDatabase(response);
      } else if (mounted) {
        setState(() {
          _isGeneratingSummary = false;
        });
      }
    } catch (e) {
      debugPrint('LLM summary error: $e');
      if (mounted) {
        setState(() {
          _isGeneratingSummary = false;
        });
      }
    }
  }

  Future<void> _saveSummaryToDatabase(String summary) async {
    if (widget.sessionId == null) return;

    try {
      if (AppState().UserSession.isLocalSession) {
        await SQLiteManager.instance.updateScanSessionNotes(
          id: widget.sessionId,
          notes: summary,
        );
      } else {
        await ScanSessionsTable().update(
          data: {'notes': summary},
          matchingRows: (rows) => rows.eq('id', widget.sessionId!),
        );
      }
      debugPrint('AI summary saved to database');
    } catch (e) {
      debugPrint('Error saving summary: $e');
    }
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  DxChipKind get _statusKind {
    if (_totalIssues == 0) return DxChipKind.good;
    if (_totalIssues < 3) return DxChipKind.plaque;
    return DxChipKind.cavity;
  }

  void _showImageDetail(_SessionImage image) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _ImageDetailSheet(
        image: image,
        memberName: widget.memberName ?? 'Unknown',
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    context.watch<AppState>();

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: BinaColors.surfaceAlt,
        body: Row(
          children: [
            // Web navigation sidebar
            if (responsiveVisibility(
              context: context,
              phone: false,
              tablet: false,
            ))
              wrapWithModel(
                model: _model.webNavModel,
                updateCallback: () => safeSetState(() {}),
                child: const WebNavWidget(),
              ),
            // Main content
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Positioned.fill(
                    child: SafeArea(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.only(
                          top: 12,
                          bottom: 120,
                        ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Header
                          Padding(
                            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                            child: Row(
                              children: [
                                BinaIconButton(
                                  icon: Icons.chevron_left_rounded,
                                  onPressed: () => context.goNamed('Main_Home'),
                                ),
                                const Spacer(),
                                Text(
                                  AppLocalizations.of(context).getText('summary_title'),
                                  style: BinaType.titleLg,
                                ),
                                const Spacer(),
                                const SizedBox(width: 44),
                              ],
                            ),
                          ).animate()
                              .fadeIn(duration: 300.ms),

                          // Status card
                          Padding(
                            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                            child: BinaCard(
                              padding: const EdgeInsets.all(20),
                              child: Column(
                                children: [
                                  Row(
                                    children: [
                                      BinaAvatar(
                                        name: widget.memberName ?? '?',
                                        size: 52,
                                      ),
                                      const SizedBox(width: 14),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              widget.memberName ?? 'Unknown',
                                              style: BinaType.titleLg,
                                            ),
                                            const SizedBox(height: 2),
                                            Text(
                                              DateFormat('EEEE, d MMMM yyyy').format(DateTime.now()),
                                              style: BinaType.bodySm.copyWith(color: BinaColors.ink2),
                                            ),
                                          ],
                                        ),
                                      ),
                                      DxChip(kind: _statusKind),
                                    ],
                                  ),
                                  const SizedBox(height: 16),
                                  Container(
                                    height: 1,
                                    color: BinaColors.line,
                                  ),
                                  const SizedBox(height: 16),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                                    children: [
                                      _StatColumn(
                                        icon: Icons.photo_library_rounded,
                                        label: AppLocalizations.of(context).getText('summary_photos'),
                                        value: '${_images.length}',
                                        color: BinaColors.primary,
                                      ),
                                      _StatColumn(
                                        icon: Icons.check_circle_rounded,
                                        label: AppLocalizations.of(context).getText('summary_teeth'),
                                        value: '$_totalTeeth',
                                        color: BinaColors.dxGood,
                                      ),
                                      _StatColumn(
                                        icon: Icons.warning_amber_rounded,
                                        label: AppLocalizations.of(context).getText('summary_issues'),
                                        value: '$_totalIssues',
                                        color: _totalIssues > 0 ? BinaColors.dxCavity : BinaColors.ink3,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ).animate()
                              .fadeIn(delay: 100.ms, duration: 400.ms)
                              .moveY(begin: 20, end: 0, delay: 100.ms, duration: 400.ms),

                          // Images section
                          Padding(
                            padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                BinaSectionHeader(
                                  title: AppLocalizations.of(context).getText('summary_captured_images'),
                                  action: null,
                                ),
                                const SizedBox(height: 12),
                                if (_isLoadingImages)
                                  Container(
                                    height: 200,
                                    decoration: BoxDecoration(
                                      color: BinaColors.surface,
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(color: BinaColors.line),
                                    ),
                                    child: Center(
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          SizedBox(
                                            width: 32,
                                            height: 32,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 3,
                                              color: BinaColors.primary,
                                            ),
                                          ),
                                          const SizedBox(height: 12),
                                          Text(
                                            AppLocalizations.of(context).getText('summary_loading_images'),
                                            style: BinaType.bodySm.copyWith(color: BinaColors.ink2),
                                          ),
                                        ],
                                      ),
                                    ),
                                  )
                                else if (_images.isEmpty)
                                  Container(
                                    height: 150,
                                    decoration: BoxDecoration(
                                      color: BinaColors.surface,
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(color: BinaColors.line),
                                    ),
                                    child: Center(
                                      child: Text(
                                        AppLocalizations.of(context).getText('summary_no_images'),
                                        style: BinaType.bodyMd.copyWith(color: BinaColors.ink2),
                                      ),
                                    ),
                                  )
                                else
                                  GridView.builder(
                                    shrinkWrap: true,
                                    physics: const NeverScrollableScrollPhysics(),
                                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 2,
                                      crossAxisSpacing: 12,
                                      mainAxisSpacing: 12,
                                      childAspectRatio: 1,
                                    ),
                                    itemCount: _images.length,
                                    itemBuilder: (context, index) {
                                      final image = _images[index];
                                      return _ImageTile(
                                        image: image,
                                        onTap: () => _showImageDetail(image),
                                      );
                                    },
                                  ),
                              ],
                            ),
                          ).animate()
                              .fadeIn(delay: 200.ms, duration: 400.ms)
                              .moveY(begin: 20, end: 0, delay: 200.ms, duration: 400.ms),

                          // AI Summary section
                          Padding(
                            padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                BinaSectionHeader(
                                  title: AppLocalizations.of(context).getText('summary_ai_analysis'),
                                  action: null,
                                ),
                                const SizedBox(height: 12),
                                BinaCard(
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.all(8),
                                            decoration: BoxDecoration(
                                              color: BinaColors.primary100,
                                              borderRadius: BorderRadius.circular(10),
                                            ),
                                            child: Icon(
                                              Icons.auto_awesome_rounded,
                                              color: BinaColors.primary,
                                              size: 20,
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  AppLocalizations.of(context).getText('summary_gemma_analysis'),
                                                  style: BinaType.titleMd,
                                                ),
                                                Text(
                                                  AppLocalizations.of(context).getText('summary_ai_assessment'),
                                                  style: BinaType.labelSm.copyWith(color: BinaColors.ink3),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 16),
                                      Container(
                                        height: 1,
                                        color: BinaColors.line,
                                      ),
                                      const SizedBox(height: 16),
                                      if (_isGeneratingSummary)
                                        Row(
                                          children: [
                                            SizedBox(
                                              width: 18,
                                              height: 18,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                                color: BinaColors.primary,
                                              ),
                                            ),
                                            const SizedBox(width: 12),
                                            Expanded(
                                              child: Text(
                                                AppLocalizations.of(context).getText('summary_analyzing'),
                                                style: BinaType.bodyMd.copyWith(color: BinaColors.ink2),
                                              ),
                                            ),
                                          ],
                                        )
                                      else if (_llmSummary != null && _llmSummary!.isNotEmpty)
                                        Text(
                                          _llmSummary!,
                                          style: BinaType.bodyMd,
                                        )
                                      else if (!GemmaService.instance.isModelLoaded)
                                        Container(
                                          padding: const EdgeInsets.all(12),
                                          decoration: BoxDecoration(
                                            color: BinaColors.surfaceSunken,
                                            borderRadius: BorderRadius.circular(10),
                                          ),
                                          child: Row(
                                            children: [
                                              Icon(
                                                Icons.info_outline_rounded,
                                                color: BinaColors.ink2,
                                                size: 20,
                                              ),
                                              const SizedBox(width: 10),
                                              Expanded(
                                                child: Text(
                                                  AppLocalizations.of(context).getText('summary_model_not_loaded'),
                                                  style: BinaType.bodySm.copyWith(color: BinaColors.ink2),
                                                ),
                                              ),
                                            ],
                                          ),
                                        )
                                      else
                                        Text(
                                          AppLocalizations.of(context).getText('summary_no_analysis'),
                                          style: BinaType.bodyMd.copyWith(color: BinaColors.ink2),
                                        ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ).animate()
                              .fadeIn(delay: 300.ms, duration: 400.ms)
                              .moveY(begin: 20, end: 0, delay: 300.ms, duration: 400.ms),

                          // Action buttons
                          Padding(
                            padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                            child: Column(
                              children: [
                                SizedBox(
                                  width: double.infinity,
                                  child: BinaButton(
                                    label: AppLocalizations.of(context).getText('summary_view_history'),
                                    icon: Icons.history_rounded,
                                    variant: BinaButtonVariant.primary,
                                    onPressed: () => context.goNamed('Family'),
                                  ),
                                ),
                                const SizedBox(height: 12),
                                SizedBox(
                                  width: double.infinity,
                                  child: BinaButton(
                                    label: AppLocalizations.of(context).getText('summary_done'),
                                    icon: Icons.check_rounded,
                                    variant: BinaButtonVariant.ghost,
                                    onPressed: () => context.goNamed('Main_Home'),
                                  ),
                                ),
                              ],
                            ),
                          ).animate()
                              .fadeIn(delay: 400.ms, duration: 400.ms),
                          ],
                        ),
                      ),
                    ),
                  ),
                  // Floating bottom nav (phone only)
                  if (responsiveVisibility(
                    context: context,
                    tablet: false,
                    tabletLandscape: false,
                    desktop: false,
                  ))
                    const BinaFloatingNav(currentTab: BinaNavTab.scan),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// SESSION IMAGE DATA
// ═══════════════════════════════════════════════════════════════

class _SessionImage {
  final String id;
  final Uint8List? imageBytes;
  final Uint8List? originalBytes;
  final List<Map<String, dynamic>> detections;
  final DateTime capturedAt;
  final int issuesCount;
  final int teethCount;

  _SessionImage({
    required this.id,
    required this.imageBytes,
    required this.originalBytes,
    required this.detections,
    required this.capturedAt,
    required this.issuesCount,
    required this.teethCount,
  });

  DxChipKind get kind {
    if (issuesCount == 0) return DxChipKind.good;
    if (issuesCount < 2) return DxChipKind.plaque;
    return DxChipKind.cavity;
  }
}

// ═══════════════════════════════════════════════════════════════
// STAT COLUMN
// ═══════════════════════════════════════════════════════════════

class _StatColumn extends StatelessWidget {
  const _StatColumn({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 6),
        Text(value, style: BinaType.headlineSm),
        const SizedBox(height: 2),
        Text(
          label,
          style: BinaType.labelSm.copyWith(color: BinaColors.ink3),
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// IMAGE TILE
// ═══════════════════════════════════════════════════════════════

class _ImageTile extends StatelessWidget {
  const _ImageTile({
    required this.image,
    required this.onTap,
  });

  final _SessionImage image;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: BinaColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: BinaColors.line),
          boxShadow: BinaElevation.sh1,
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Image
            if (image.imageBytes != null)
              Image.memory(
                image.imageBytes!,
                fit: BoxFit.cover,
              )
            else
              Container(
                color: BinaColors.surfaceSunken,
                child: Icon(
                  Icons.image_rounded,
                  color: BinaColors.ink3,
                  size: 40,
                ),
              ),
            // Gradient overlay
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                height: 60,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.7),
                    ],
                  ),
                ),
              ),
            ),
            // Info overlay
            Positioned(
              bottom: 8,
              left: 8,
              right: 8,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        image.issuesCount > 0
                            ? Icons.warning_amber_rounded
                            : Icons.check_circle_rounded,
                        color: image.issuesCount > 0
                            ? BinaColors.dxCavity
                            : BinaColors.dxGood,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        image.issuesCount > 0
                            ? '${image.issuesCount} ${image.issuesCount > 1 ? AppLocalizations.of(context).getText('summary_issues_plural') : AppLocalizations.of(context).getText('summary_issue')}'
                            : AppLocalizations.of(context).getText('summary_clean'),
                        style: BinaType.labelSm.copyWith(color: Colors.white),
                      ),
                    ],
                  ),
                  Text(
                    DateFormat('HH:mm').format(image.capturedAt),
                    style: BinaType.labelSm.copyWith(
                      color: Colors.white.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
            ),
            // Issue badge
            if (image.issuesCount > 0)
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: BinaColors.dxCavity,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${image.issuesCount}',
                    style: BinaType.labelSm.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// IMAGE DETAIL SHEET
// ═══════════════════════════════════════════════════════════════

class _ImageDetailSheet extends StatefulWidget {
  const _ImageDetailSheet({
    required this.image,
    required this.memberName,
  });

  final _SessionImage image;
  final String memberName;

  @override
  State<_ImageDetailSheet> createState() => _ImageDetailSheetState();
}

class _ImageDetailSheetState extends State<_ImageDetailSheet> {
  bool _showAnnotated = true;

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Container(
      height: screenHeight * 0.85,
      decoration: BoxDecoration(
        color: BinaColors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Handle
          Padding(
            padding: const EdgeInsets.only(top: 12, bottom: 8),
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: BinaColors.ink3.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppLocalizations.of(context).getText('summary_image_detail'),
                      style: BinaType.titleLg,
                    ),
                    Text(
                      DateFormat('d MMM yyyy, HH:mm').format(widget.image.capturedAt),
                      style: BinaType.bodySm.copyWith(color: BinaColors.ink2),
                    ),
                  ],
                ),
                DxChip(kind: widget.image.kind),
              ],
            ),
          ),
          // Image view
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(16),
                ),
                clipBehavior: Clip.antiAlias,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    if (_showAnnotated && widget.image.imageBytes != null)
                      Image.memory(
                        widget.image.imageBytes!,
                        fit: BoxFit.contain,
                      )
                    else if (!_showAnnotated && widget.image.originalBytes != null)
                      Image.memory(
                        widget.image.originalBytes!,
                        fit: BoxFit.contain,
                      )
                    else
                      Center(
                        child: Icon(
                          Icons.image_rounded,
                          color: BinaColors.ink3,
                          size: 64,
                        ),
                      ),
                    // Toggle button
                    if (widget.image.originalBytes != null && widget.image.imageBytes != null)
                      Positioned(
                        bottom: 12,
                        right: 12,
                        child: GestureDetector(
                          onTap: () => setState(() => _showAnnotated = !_showAnnotated),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.7),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  _showAnnotated ? Icons.visibility_rounded : Icons.visibility_off_rounded,
                                  color: Colors.white,
                                  size: 16,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  _showAnnotated ? AppLocalizations.of(context).getText('summary_annotated') : AppLocalizations.of(context).getText('summary_original'),
                                  style: BinaType.labelSm.copyWith(color: Colors.white),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
          // Detections list
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppLocalizations.of(context).getText('summary_detections'),
                  style: BinaType.titleMd,
                ),
                const SizedBox(height: 12),
                if (widget.image.detections.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: BinaColors.dxGood100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.check_circle_rounded,
                          color: BinaColors.dxGood,
                          size: 20,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          AppLocalizations.of(context).getText('summary_no_issues_image'),
                          style: BinaType.bodyMd.copyWith(color: BinaColors.dxGood),
                        ),
                      ],
                    ),
                  )
                else
                  SizedBox(
                    height: 100,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: widget.image.detections.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 10),
                      itemBuilder: (context, index) {
                        final detection = widget.image.detections[index];
                        final className = detection['className'] as String? ?? 'Unknown';
                        final confidence = detection['confidence'] as double? ?? 0.0;
                        final isTooth = className.startsWith('tooth_');

                        return Container(
                          width: 140,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: isTooth ? BinaColors.surfaceSunken : BinaColors.dxCavity100,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isTooth
                                  ? BinaColors.line
                                  : BinaColors.dxCavity.withValues(alpha: 0.3),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                isTooth ? Icons.check_circle_rounded : Icons.warning_amber_rounded,
                                color: isTooth ? BinaColors.ink2 : BinaColors.dxCavity,
                                size: 20,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                _formatClassName(className),
                                style: BinaType.titleSm,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                '${(confidence * 100).toStringAsFixed(0)}% ${AppLocalizations.of(context).getText('summary_confident')}',
                                style: BinaType.labelSm.copyWith(color: BinaColors.ink3),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatClassName(String className) {
    // Convert snake_case to Title Case
    return className
        .split('_')
        .map((word) => word.isNotEmpty
            ? '${word[0].toUpperCase()}${word.substring(1)}'
            : word)
        .join(' ');
  }
}
