import '/app_core/app_theme_type.dart';
import '/app_core/app_util.dart';
import '/app_core/text_scale.dart';
import '/bina_design/bina_design.dart';
import '/services/accessibility_settings_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'accessibility_model.dart';
export 'accessibility_model.dart';

class AccessibilityWidget extends StatefulWidget {
  const AccessibilityWidget({super.key});

  static String routeName = 'Accessibility';
  static String routePath = 'accessibility';

  @override
  State<AccessibilityWidget> createState() => _AccessibilityWidgetState();
}

class _AccessibilityWidgetState extends State<AccessibilityWidget> {
  late AccessibilityModel _model;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => AccessibilityModel());
  }

  @override
  void dispose() {
    _model.maybeDispose();
    super.dispose();
  }

  BinaThemeId _mapToBinaTheme(AppThemeType appTheme) {
    switch (appTheme) {
      case AppThemeType.light:
        return BinaThemeId.light;
      case AppThemeType.dark:
        return BinaThemeId.dark;
      case AppThemeType.warm:
        return BinaThemeId.warm;
      case AppThemeType.cool:
        return BinaThemeId.cool;
      case AppThemeType.deuteranopia:
        return BinaThemeId.deuteranopia;
    }
  }

  AppThemeType _mapToAppTheme(BinaThemeId binaTheme) {
    switch (binaTheme) {
      case BinaThemeId.light:
        return AppThemeType.light;
      case BinaThemeId.dark:
        return AppThemeType.dark;
      case BinaThemeId.warm:
        return AppThemeType.warm;
      case BinaThemeId.cool:
        return AppThemeType.cool;
      case BinaThemeId.deuteranopia:
        return AppThemeType.deuteranopia;
    }
  }

  String _getContrastLabel(double contrastLevel) {
    if (contrastLevel < -0.15) return 'Softer';
    if (contrastLevel > 0.15) return 'Stronger';
    return 'Default';
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AccessibilitySettingsService>(
      builder: (context, settings, _) {
        final currentTheme = _mapToBinaTheme(settings.themeType);
        final currentTextScale = settings.textScale;

        return GestureDetector(
          onTap: () {
            FocusScope.of(context).unfocus();
            FocusManager.instance.primaryFocus?.unfocus();
          },
          child: Scaffold(
            backgroundColor: BinaColors.surfaceAlt,
            body: SingleChildScrollView(
              padding: const EdgeInsets.only(top: 54, bottom: 40),
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
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                        Expanded(
                          child: Center(
                            child: Text(
                              'Accessibility',
                              style: BinaType.titleMd,
                            ),
                          ),
                        ),
                        const SizedBox(width: 44),
                      ],
                    ),
                  ).animate()
                      .fadeIn(duration: 300.ms)
                      .moveY(begin: -10, end: 0, duration: 300.ms),

                  const SizedBox(height: 16),

                  // Appearance Section
                  _SettingsSection(
                    title: 'APPEARANCE',
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Theme label
                        Padding(
                          padding: const EdgeInsets.fromLTRB(14, 14, 14, 10),
                          child: Text(
                            'Theme',
                            style: BinaType.labelMd.copyWith(color: BinaColors.ink2),
                          ),
                        ),
                        // Theme swatches
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 14),
                          child: Row(
                            children: BinaThemeId.values.map((theme) {
                              return Expanded(
                                child: Padding(
                                  padding: EdgeInsets.only(
                                    right: theme != BinaThemeId.deuteranopia ? 8 : 0,
                                  ),
                                  child: _ThemeSwatch(
                                    theme: theme,
                                    isActive: currentTheme == theme,
                                    onTap: () async {
                                      HapticFeedback.selectionClick();
                                      BinaColors.use(theme);
                                      await settings.setThemeType(_mapToAppTheme(theme));
                                    },
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                        const SizedBox(height: 20),
                        // Contrast slider
                        Padding(
                          padding: const EdgeInsets.fromLTRB(14, 0, 14, 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Contrast',
                                    style: BinaType.labelMd.copyWith(color: BinaColors.ink2),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: BinaColors.surfaceSunken,
                                      borderRadius: BorderRadius.circular(999),
                                    ),
                                    child: Text(
                                      _getContrastLabel(settings.contrastLevel),
                                      style: BinaType.labelSm.copyWith(color: BinaColors.ink2),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              SliderTheme(
                                data: SliderThemeData(
                                  activeTrackColor: BinaColors.primary,
                                  inactiveTrackColor: BinaColors.line,
                                  thumbColor: BinaColors.primary,
                                  overlayColor: BinaColors.primary100,
                                  trackHeight: 4,
                                ),
                                child: Slider(
                                  value: settings.contrastLevel + 1.0, // Map 0.0 to 1.0 (center)
                                  min: 0.7,
                                  max: 1.4,
                                  onChanged: (value) async {
                                    HapticFeedback.selectionClick();
                                    await settings.setContrastLevel(value - 1.0);
                                  },
                                ),
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Softer',
                                    style: BinaType.labelSm.copyWith(color: BinaColors.ink3),
                                  ),
                                  Text(
                                    'Stronger',
                                    style: BinaType.labelSm.copyWith(color: BinaColors.ink3),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ).animate()
                      .fadeIn(delay: 100.ms, duration: 400.ms)
                      .moveY(begin: 20, end: 0, delay: 100.ms, duration: 400.ms),

                  // Reading Section
                  _SettingsSection(
                    title: 'READING',
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Text size',
                            style: BinaType.labelMd.copyWith(color: BinaColors.ink2),
                          ),
                          const SizedBox(height: 10),
                          // Text size buttons
                          Row(
                            children: TextScale.values.map((scale) {
                              final letterSizes = {
                                TextScale.small: 11.0,
                                TextScale.medium: 14.0,
                                TextScale.large: 17.0,
                                TextScale.extraLarge: 20.0,
                              };
                              return Expanded(
                                child: Padding(
                                  padding: EdgeInsets.only(
                                    right: scale != TextScale.extraLarge ? 6 : 0,
                                  ),
                                  child: _TextSizeButton(
                                    label: scale.displayName,
                                    letterSize: letterSizes[scale]!,
                                    isActive: currentTextScale == scale,
                                    onTap: () async {
                                      HapticFeedback.selectionClick();
                                      await settings.setTextScale(scale);
                                    },
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                          const SizedBox(height: 14),
                          // Preview text
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: BinaColors.surfaceAlt,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              'Preview · Hello Sarah! Maya\'s scan from this morning needs attention.',
                              style: TextStyle(
                                fontSize: 14 * currentTextScale.scaleFactor,
                                height: 1.5,
                                color: BinaColors.ink2,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ).animate()
                      .fadeIn(delay: 200.ms, duration: 400.ms)
                      .moveY(begin: 20, end: 0, delay: 200.ms, duration: 400.ms),

                  // Guidance Section
                  _SettingsSection(
                    title: 'GUIDANCE',
                    child: _SettingsToggleRow(
                      icon: Icons.help_outline_rounded,
                      iconBgColor: BinaColors.coral100,
                      iconColor: BinaColors.coral700,
                      label: 'Hint mode',
                      subtitle: 'Show small tooltips on key buttons',
                      value: settings.hintsEnabled,
                      onChanged: (value) async {
                        HapticFeedback.selectionClick();
                        await settings.setHintsEnabled(value);
                      },
                    ),
                  ).animate()
                      .fadeIn(delay: 300.ms, duration: 400.ms)
                      .moveY(begin: 20, end: 0, delay: 300.ms, duration: 400.ms),

                  // Motion & Sensory Section
                  _SettingsSection(
                    title: 'MOTION & SENSORY',
                    child: Column(
                      children: [
                        _SettingsToggleRow(
                          icon: Icons.animation_rounded,
                          iconBgColor: BinaColors.aqua100,
                          iconColor: BinaColors.aqua700,
                          label: 'Reduce motion',
                          subtitle: 'Disable transitions and parallax',
                          value: settings.reduceMotion,
                          onChanged: (value) async {
                            HapticFeedback.selectionClick();
                            await settings.setReduceMotion(value);
                          },
                          showBorder: true,
                        ),
                        _SettingsToggleRow(
                          icon: Icons.vibration_rounded,
                          iconBgColor: BinaColors.coral100,
                          iconColor: BinaColors.coral700,
                          label: 'Haptic feedback',
                          value: settings.hapticEnabled,
                          onChanged: (value) async {
                            HapticFeedback.selectionClick();
                            await settings.setHapticEnabled(value);
                          },
                        ),
                      ],
                    ),
                  ).animate()
                      .fadeIn(delay: 400.ms, duration: 400.ms)
                      .moveY(begin: 20, end: 0, delay: 400.ms, duration: 400.ms),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// SETTINGS SECTION
// ═══════════════════════════════════════════════════════════════

class _SettingsSection extends StatelessWidget {
  const _SettingsSection({
    required this.title,
    required this.child,
  });

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 8),
            child: Text(
              title,
              style: BinaType.overline.copyWith(
                color: BinaColors.ink3,
                letterSpacing: 0.8,
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: BinaColors.surface,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: BinaColors.line),
              boxShadow: BinaElevation.sh2,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: child,
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// THEME SWATCH
// ═══════════════════════════════════════════════════════════════

class _ThemeSwatch extends StatelessWidget {
  const _ThemeSwatch({
    required this.theme,
    required this.isActive,
    required this.onTap,
  });

  final BinaThemeId theme;
  final bool isActive;
  final VoidCallback onTap;

  String get _label {
    switch (theme) {
      case BinaThemeId.light:
        return 'Light';
      case BinaThemeId.dark:
        return 'Dark';
      case BinaThemeId.warm:
        return 'Warm';
      case BinaThemeId.cool:
        return 'Cool';
      case BinaThemeId.deuteranopia:
        return 'A11y';
    }
  }

  Gradient get _gradient {
    switch (theme) {
      case BinaThemeId.light:
        return const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFBFAF6), Color(0xFF1F5BFF)],
        );
      case BinaThemeId.dark:
        return const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF0C0F1A), Color(0xFF5B8BFF)],
        );
      case BinaThemeId.warm:
        return const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFFF8E1), Color(0xFFEF8B1A)],
        );
      case BinaThemeId.cool:
        return const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFE3F2FD), Color(0xFF0099B3)],
        );
      case BinaThemeId.deuteranopia:
        return const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFFFFFF), Color(0xFF0077BB)],
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          AspectRatio(
            aspectRatio: 1,
            child: Container(
              decoration: BoxDecoration(
                gradient: _gradient,
                borderRadius: BorderRadius.circular(14),
                boxShadow: isActive
                    ? [
                        BoxShadow(
                          color: BinaColors.primary.withValues(alpha: 0.5),
                          blurRadius: 0,
                          spreadRadius: 3,
                        )
                      ]
                    : BinaElevation.sh1,
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            _label,
            style: BinaType.labelSm.copyWith(
              color: isActive ? BinaColors.primary : BinaColors.ink2,
              fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// TEXT SIZE BUTTON
// ═══════════════════════════════════════════════════════════════

class _TextSizeButton extends StatelessWidget {
  const _TextSizeButton({
    required this.label,
    required this.letterSize,
    required this.isActive,
    required this.onTap,
  });

  final String label;
  final double letterSize;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
        decoration: BoxDecoration(
          color: isActive ? BinaColors.primary : BinaColors.surface,
          border: Border.all(
            color: isActive ? BinaColors.primary : BinaColors.line,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text(
              'A',
              style: TextStyle(
                fontSize: letterSize,
                fontWeight: FontWeight.w600,
                color: isActive ? Colors.white : BinaColors.ink,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: BinaType.labelSm.copyWith(
                color: isActive ? Colors.white : BinaColors.ink,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// SETTINGS TOGGLE ROW
// ═══════════════════════════════════════════════════════════════

class _SettingsToggleRow extends StatelessWidget {
  const _SettingsToggleRow({
    required this.icon,
    required this.iconBgColor,
    required this.iconColor,
    required this.label,
    this.subtitle,
    required this.value,
    required this.onChanged,
    this.showBorder = false,
  });

  final IconData icon;
  final Color iconBgColor;
  final Color iconColor;
  final String label;
  final String? subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;
  final bool showBorder;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        border: showBorder
            ? Border(bottom: BorderSide(color: BinaColors.line))
            : null,
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: iconBgColor,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: BinaType.bodyLg),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle!,
                    style: BinaType.bodySm.copyWith(color: BinaColors.ink3),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 12),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: BinaColors.primary,
            activeTrackColor: BinaColors.primary100,
            inactiveThumbColor: BinaColors.ink3,
            inactiveTrackColor: BinaColors.line,
          ),
        ],
      ),
    );
  }
}
