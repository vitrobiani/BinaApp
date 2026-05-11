import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '/app_core/app_theme.dart';
import '/app_core/app_util.dart';
import '/app_core/text_scale.dart';
import '/services/accessibility_settings_service.dart';
import 'text_settings_model.dart';

export 'text_settings_model.dart';

class TextSettingsWidget extends StatefulWidget {
  const TextSettingsWidget({super.key});

  static String routeName = 'TextSettings';
  static String routePath = 'textSettings';

  @override
  State<TextSettingsWidget> createState() => _TextSettingsWidgetState();
}

class _TextSettingsWidgetState extends State<TextSettingsWidget> {
  late TextSettingsModel _model;
  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => TextSettingsModel());
  }

  @override
  void dispose() {
    _model.maybeDispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Listen to accessibility settings changes
    context.watch<AccessibilitySettingsService>();
    final currentScale = AccessibilitySettingsService.instance.textScale;

    return Scaffold(
      key: scaffoldKey,
      backgroundColor: AppTheme.of(context).primaryBackground,
      appBar: AppBar(
        backgroundColor: AppTheme.of(context).secondaryBackground,
        automaticallyImplyLeading: true,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_rounded,
            color: AppTheme.of(context).primaryText,
            size: 24.0,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          AppLocalizations.of(context).getText('txts001' /* Text Size */),
          style: AppTheme.of(context).headlineSmall,
        ),
        centerTitle: false,
        elevation: 0.0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header description
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  AppLocalizations.of(context).getText('txts002' /* Choose your preferred text size... */),
                  style: AppTheme.of(context).bodyMedium.override(
                        font: GoogleFonts.inter(),
                        color: AppTheme.of(context).secondaryText,
                      ),
                ),
              ),

              // Text scale options
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  children: TextScale.values.map((scale) {
                    final isSelected = scale == currentScale;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12.0),
                      child: InkWell(
                        onTap: () async {
                          await AccessibilitySettingsService.instance
                              .setTextScale(scale);
                          // Force rebuild to show new text sizes
                          safeSetState(() {});
                        },
                        borderRadius: BorderRadius.circular(12.0),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16.0),
                          decoration: BoxDecoration(
                            color: AppTheme.of(context).secondaryBackground,
                            borderRadius: BorderRadius.circular(12.0),
                            border: Border.all(
                              color: isSelected
                                  ? AppTheme.of(context).primary
                                  : AppTheme.of(context).alternate,
                              width: isSelected ? 2.0 : 1.0,
                            ),
                            boxShadow: isSelected
                                ? [
                                    BoxShadow(
                                      color: AppTheme.of(context)
                                          .primary
                                          .withValues(alpha: 0.2),
                                      blurRadius: 8.0,
                                      offset: const Offset(0, 2),
                                    ),
                                  ]
                                : null,
                          ),
                          child: Row(
                            children: [
                              // Radio indicator
                              Container(
                                width: 24.0,
                                height: 24.0,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: isSelected
                                        ? AppTheme.of(context).primary
                                        : AppTheme.of(context).secondaryText,
                                    width: 2.0,
                                  ),
                                ),
                                child: isSelected
                                    ? Center(
                                        child: Container(
                                          width: 12.0,
                                          height: 12.0,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color:
                                                AppTheme.of(context).primary,
                                          ),
                                        ),
                                      )
                                    : null,
                              ),
                              const SizedBox(width: 16.0),
                              // Scale name and preview
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      scale.displayName,
                                      style: AppTheme.of(context)
                                          .titleMedium
                                          .override(
                                            font: GoogleFonts.inter(),
                                            color: AppTheme.of(context)
                                                .primaryText,
                                            fontWeight: FontWeight.w600,
                                          ),
                                    ),
                                    const SizedBox(height: 4.0),
                                    Text(
                                      'Scale: ${(scale.scaleFactor * 100).toInt()}%',
                                      style: AppTheme.of(context)
                                          .bodySmall
                                          .override(
                                            font: GoogleFonts.inter(),
                                            color: AppTheme.of(context)
                                                .secondaryText,
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                              // Preview text at this scale
                              Text(
                                'Aa',
                                style: GoogleFonts.inter(
                                  fontSize: 14.0 * scale.scaleFactor,
                                  fontWeight: FontWeight.w500,
                                  color: AppTheme.of(context).primaryText,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),

              // Preview section
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppLocalizations.of(context).getText('txts003' /* Preview */),
                      style: AppTheme.of(context).titleSmall.override(
                            font: GoogleFonts.inter(),
                            color: AppTheme.of(context).secondaryText,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    const SizedBox(height: 12.0),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16.0),
                      decoration: BoxDecoration(
                        color: AppTheme.of(context).secondaryBackground,
                        borderRadius: BorderRadius.circular(12.0),
                        border: Border.all(
                          color: AppTheme.of(context).alternate,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            AppLocalizations.of(context).getText('txts004' /* This is how text will appear... */),
                            style: AppTheme.of(context).bodyMedium,
                          ),
                        ],
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
