import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '/app_core/app_util.dart';
import '/app_core/app_theme_type.dart';
import '/bina_design/bina_design.dart';
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
    context.watch<AccessibilitySettingsService>();
    final settings = AccessibilitySettingsService.instance;
    final currentTheme = settings.themeType;
    final contrastLevel = settings.contrastLevel;

    return Scaffold(
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
                border: Border(
                  bottom: BorderSide(color: BinaColors.line),
                ),
              ),
              child: Row(
                children: [
                  BinaIconButton(
                    icon: Icons.chevron_left_rounded,
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Color & Theme',
                    style: BinaType.titleLg,
                  ),
                ],
              ),
            ),
            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Description
                    Text(
                      'Choose a color theme that works best for you. Higher contrast can improve readability.',
                      style: BinaType.bodyMd.copyWith(color: BinaColors.ink2),
                    ),
                    const SizedBox(height: 24),

                    // Theme section
                    Text('Theme', style: BinaType.titleMd),
                    const SizedBox(height: 12),
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
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
                            setDarkModeSetting(context, theme.themeMode);
                            safeSetState(() {});
                          },
                        );
                      },
                    ),

                    const SizedBox(height: 24),

                    // Contrast section
                    Text('Contrast', style: BinaType.titleMd),
                    const SizedBox(height: 8),
                    Text(
                      'Adjust the contrast level for better visibility',
                      style: BinaType.bodySm.copyWith(color: BinaColors.ink2),
                    ),
                    const SizedBox(height: 12),
                    BinaCard(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Normal',
                                style: BinaType.labelSm.copyWith(color: BinaColors.ink3),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: BinaColors.primary100,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  '${(contrastLevel * 100).toInt()}%',
                                  style: BinaType.labelMd.copyWith(color: BinaColors.primary),
                                ),
                              ),
                              Text(
                                'High',
                                style: BinaType.labelSm.copyWith(color: BinaColors.ink3),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          SliderTheme(
                            data: SliderTheme.of(context).copyWith(
                              activeTrackColor: BinaColors.primary,
                              inactiveTrackColor: BinaColors.line,
                              thumbColor: BinaColors.primary,
                              overlayColor: BinaColors.primary.withValues(alpha: 0.2),
                              trackHeight: 6,
                              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10),
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

                    const SizedBox(height: 24),

                    // Preview section
                    Text('Preview', style: BinaType.titleMd),
                    const SizedBox(height: 12),
                    _PreviewCard(contrastLevel: contrastLevel),

                    const SizedBox(height: 24),

                    // Info note
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: BinaColors.primary100,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.info_outline_rounded,
                            color: BinaColors.primary,
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Theme changes are applied immediately. Some screens may need to be refreshed.',
                              style: BinaType.bodySm.copyWith(color: BinaColors.primary),
                            ),
                          ),
                        ],
                      ),
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
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: BinaMotion.d2,
        decoration: BoxDecoration(
          color: BinaColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? BinaColors.primary : BinaColors.line,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected ? BinaElevation.sh2 : BinaElevation.sh1,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Color preview strip
            Container(
              height: 36,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(13)),
                gradient: LinearGradient(
                  colors: theme.previewColors,
                  stops: const [0.0, 0.5, 1.0],
                ),
              ),
              child: isSelected
                  ? Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.9),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.check_rounded,
                              size: 12,
                              color: theme.previewColors[2],
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Active',
                              style: BinaType.labelSm.copyWith(
                                color: theme.previewColors[2],
                                fontSize: 10,
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
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      children: [
                        Icon(
                          theme.icon,
                          size: 16,
                          color: BinaColors.ink,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            theme.displayName,
                            style: BinaType.labelMd,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      theme.description,
                      style: BinaType.labelSm.copyWith(color: BinaColors.ink3),
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

class _PreviewCard extends StatelessWidget {
  const _PreviewCard({required this.contrastLevel});

  final double contrastLevel;

  @override
  Widget build(BuildContext context) {
    final borderWidth = 1.0 + (contrastLevel * 1.5);

    return BinaCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Sample Card', style: BinaType.titleMd),
          const SizedBox(height: 8),
          Text(
            'This is how your content will look with the current theme and contrast settings.',
            style: BinaType.bodyMd,
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: BinaColors.primary,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: Text(
                      'Primary',
                      style: BinaType.labelMd.copyWith(color: Colors.white),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: BinaColors.surface,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: BinaColors.line,
                      width: borderWidth,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      'Secondary',
                      style: BinaType.labelMd,
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
