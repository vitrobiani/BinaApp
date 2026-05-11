import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '/app_core/app_theme.dart';
import '/app_core/app_util.dart';
import '/app_core/app_theme_type.dart';
import '/services/accessibility_settings_service.dart';
import 'theme_settings_model.dart';

export 'theme_settings_model.dart';

class ThemeSettingsWidget extends StatefulWidget {
  const ThemeSettingsWidget({super.key});

  static String routeName = 'ThemeSettings';
  static String routePath = 'themeSettings';

  @override
  State<ThemeSettingsWidget> createState() => _ThemeSettingsWidgetState();
}

class _ThemeSettingsWidgetState extends State<ThemeSettingsWidget> {
  late ThemeSettingsModel _model;
  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => ThemeSettingsModel());
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
    final settings = AccessibilitySettingsService.instance;
    final currentTheme = settings.themeType;
    final contrastLevel = settings.contrastLevel;

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
          AppLocalizations.of(context).getText('zsq8vj02' /* Color and Theme */),
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
                  AppLocalizations.of(context).getText('thms002' /* Choose a color theme... */),
                  style: AppTheme.of(context).bodyMedium.override(
                        font: GoogleFonts.inter(),
                        color: AppTheme.of(context).secondaryText,
                      ),
                ),
              ),

              // Theme selection header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                  AppLocalizations.of(context).getText('thms001' /* Theme */),
                  style: AppTheme.of(context).titleSmall.override(
                        font: GoogleFonts.inter(),
                        color: AppTheme.of(context).primaryText,
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ),
              const SizedBox(height: 12.0),

              // Theme grid
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12.0,
                    mainAxisSpacing: 12.0,
                    childAspectRatio: 1.4,
                  ),
                  itemCount: AppThemeType.values.length,
                  itemBuilder: (context, index) {
                    final theme = AppThemeType.values[index];
                    final isSelected = theme == currentTheme;

                    return _ThemeCard(
                      theme: theme,
                      isSelected: isSelected,
                      onTap: () async {
                        await settings.setThemeType(theme);
                        // Update the app's theme mode
                        setDarkModeSetting(context, theme.themeMode);
                        safeSetState(() {});
                      },
                    );
                  },
                ),
              ),

              const SizedBox(height: 24.0),

              // Contrast slider section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                  AppLocalizations.of(context).getText('thms003' /* Contrast */),
                  style: AppTheme.of(context).titleSmall.override(
                        font: GoogleFonts.inter(),
                        color: AppTheme.of(context).primaryText,
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ),
              const SizedBox(height: 8.0),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                  AppLocalizations.of(context).getText('thms004' /* Adjust contrast level... */),
                  style: AppTheme.of(context).bodySmall.override(
                        font: GoogleFonts.inter(),
                        color: AppTheme.of(context).secondaryText,
                      ),
                ),
              ),
              const SizedBox(height: 12.0),

              // Contrast slider
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Container(
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
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Normal',
                            style: AppTheme.of(context).bodySmall.override(
                                  font: GoogleFonts.inter(),
                                  color: AppTheme.of(context).secondaryText,
                                ),
                          ),
                          Text(
                            '${(contrastLevel * 100).toInt()}%',
                            style: AppTheme.of(context).bodyMedium.override(
                                  font: GoogleFonts.inter(),
                                  color: AppTheme.of(context).primary,
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                          Text(
                            'High',
                            style: AppTheme.of(context).bodySmall.override(
                                  font: GoogleFonts.inter(),
                                  color: AppTheme.of(context).secondaryText,
                                ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8.0),
                      SliderTheme(
                        data: SliderTheme.of(context).copyWith(
                          activeTrackColor: AppTheme.of(context).primary,
                          inactiveTrackColor: AppTheme.of(context).alternate,
                          thumbColor: AppTheme.of(context).primary,
                          overlayColor: AppTheme.of(context).primary.withValues(alpha: 0.2),
                        ),
                        child: Slider(
                          value: contrastLevel,
                          min: 0.0,
                          max: 1.0,
                          divisions: 10,
                          onChanged: (value) async {
                            await settings.setContrastLevel(value);
                            safeSetState(() {});
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24.0),

              // Preview section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                  AppLocalizations.of(context).getText('thms005' /* Preview */),
                  style: AppTheme.of(context).titleSmall.override(
                        font: GoogleFonts.inter(),
                        color: AppTheme.of(context).primaryText,
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ),
              const SizedBox(height: 12.0),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: _PreviewCard(contrastLevel: contrastLevel),
              ),

              const SizedBox(height: 24.0),

              // Info note
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12.0),
                  decoration: BoxDecoration(
                    color: AppTheme.of(context).accent1.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: AppTheme.of(context).primary,
                        size: 20.0,
                      ),
                      const SizedBox(width: 12.0),
                      Expanded(
                        child: Text(
                          'Theme changes are applied immediately. Some screens may need to be refreshed to show the new theme.',
                          style: AppTheme.of(context).bodySmall.override(
                                font: GoogleFonts.inter(),
                                color: AppTheme.of(context).primaryText,
                              ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Card widget for displaying a theme option
class _ThemeCard extends StatelessWidget {
  const _ThemeCard({
    required this.theme,
    required this.isSelected,
    required this.onTap,
  });

  final AppThemeType theme;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12.0),
      child: Container(
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
                    color: AppTheme.of(context).primary.withValues(alpha: 0.2),
                    blurRadius: 8.0,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Color preview strip
            Container(
              height: 40.0,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(11.0),
                ),
                gradient: LinearGradient(
                  colors: theme.previewColors,
                  stops: const [0.0, 0.5, 1.0],
                ),
              ),
              child: isSelected
                  ? Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8.0,
                          vertical: 4.0,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.9),
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.check,
                              size: 14.0,
                              color: theme.previewColors[2],
                            ),
                            const SizedBox(width: 4.0),
                            Text(
                              'Active',
                              style: GoogleFonts.inter(
                                fontSize: 10.0,
                                fontWeight: FontWeight.w600,
                                color: theme.previewColors[2],
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  : null,
            ),
            // Theme info
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      children: [
                        Icon(
                          theme.icon,
                          size: 16.0,
                          color: AppTheme.of(context).primaryText,
                        ),
                        const SizedBox(width: 6.0),
                        Expanded(
                          child: Text(
                            theme.displayName,
                            style: AppTheme.of(context).bodyMedium.override(
                                  font: GoogleFonts.inter(),
                                  fontWeight: FontWeight.w600,
                                ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2.0),
                    Text(
                      theme.description,
                      style: AppTheme.of(context).labelSmall.override(
                            font: GoogleFonts.inter(),
                            color: AppTheme.of(context).secondaryText,
                          ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Preview card showing sample UI elements with current contrast
class _PreviewCard extends StatelessWidget {
  const _PreviewCard({required this.contrastLevel});

  final double contrastLevel;

  @override
  Widget build(BuildContext context) {
    // Calculate adjusted border width based on contrast
    final borderWidth = 1.0 + (contrastLevel * 2.0);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: AppTheme.of(context).secondaryBackground,
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(
          color: AppTheme.of(context).alternate,
          width: borderWidth,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Sample Card',
            style: AppTheme.of(context).titleMedium.override(
                  font: GoogleFonts.inter(),
                  color: AppTheme.of(context).primaryText,
                ),
          ),
          const SizedBox(height: 8.0),
          Text(
            'This is how your content will look with the current theme and contrast settings.',
            style: AppTheme.of(context).bodyMedium,
          ),
          const SizedBox(height: 12.0),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 10.0,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.of(context).primary,
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: Text(
                    'Primary Button',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                      fontSize: 12.0,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12.0),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 10.0,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.of(context).secondaryBackground,
                    borderRadius: BorderRadius.circular(8.0),
                    border: Border.all(
                      color: AppTheme.of(context).alternate,
                      width: borderWidth,
                    ),
                  ),
                  child: Text(
                    'Secondary',
                    textAlign: TextAlign.center,
                    style: AppTheme.of(context).bodySmall.override(
                          font: GoogleFonts.inter(),
                          fontWeight: FontWeight.w500,
                        ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
