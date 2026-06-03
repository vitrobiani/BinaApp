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

  String _getContrastLabel(BuildContext context, double contrastLevel) {
    if (contrastLevel < -0.15) return AppLocalizations.of(context).getText('a11y_softer');
    if (contrastLevel > 0.15) return AppLocalizations.of(context).getText('a11y_stronger');
    return AppLocalizations.of(context).getText('a11y_default');
  }

  static const List<_LanguageOption> _languages = [
    _LanguageOption(code: 'en', name: 'English', nativeName: 'English', flag: '🇺🇸'),
    _LanguageOption(code: 'he', name: 'Hebrew', nativeName: 'עברית', flag: '🇮🇱'),
    _LanguageOption(code: 'id', name: 'Indonesian', nativeName: 'Bahasa Indonesia', flag: '🇮🇩'),
    _LanguageOption(code: 'ms', name: 'Malay', nativeName: 'Bahasa Melayu', flag: '🇲🇾'),
  ];

  String _getCurrentLanguageName() {
    final storedLocale = AppLocalizations.getStoredLocale();
    final languageCode = storedLocale?.languageCode ?? 'en';
    final language = _languages.firstWhere(
      (l) => l.code == languageCode,
      orElse: () => _languages.first,
    );
    return language.name;
  }

  void _showLanguageSelector(BuildContext parentContext) {
    final storedLocale = AppLocalizations.getStoredLocale();
    final currentCode = storedLocale?.languageCode ?? 'en';

    showModalBottomSheet(
      context: parentContext,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (sheetContext) => SafeArea(
        child: Container(
          decoration: BoxDecoration(
            color: BinaColors.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle
              Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: BinaColors.line,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              // Title
              Text(AppLocalizations.of(parentContext).getText('a11y_select_language'), style: BinaType.titleLg),
              const SizedBox(height: 16),
              // Language options
              ..._languages.map((language) {
                final isSelected = language.code == currentCode;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: GestureDetector(
                    onTap: () async {
                      HapticFeedback.selectionClick();
                      await AppLocalizations.storeLocale(language.code);
                      if (mounted) {
                        // Use parentContext to access MyApp, not sheetContext
                        setAppLanguage(parentContext, language.code);
                        Navigator.pop(sheetContext);
                        safeSetState(() {});
                      }
                    },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: isSelected ? BinaColors.primary100 : BinaColors.surfaceSunken,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isSelected ? BinaColors.primary : BinaColors.line,
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Text(language.flag, style: const TextStyle(fontSize: 24)),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                language.name,
                                style: BinaType.bodyLg.copyWith(
                                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                                  color: isSelected ? BinaColors.primary : BinaColors.ink,
                                ),
                              ),
                              Text(
                                language.nativeName,
                                style: BinaType.bodySm.copyWith(color: BinaColors.ink3),
                              ),
                            ],
                          ),
                        ),
                        if (isSelected)
                          Icon(Icons.check_circle_rounded, color: BinaColors.primary, size: 24),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ],
          ),
        ),
      ),
    );
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
            body: SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(top: 12, bottom: 40),
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
                              AppLocalizations.of(context).getText('a11y_title'),
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
                    title: AppLocalizations.of(context).getText('a11y_appearance'),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Theme label
                        Padding(
                          padding: const EdgeInsets.fromLTRB(14, 14, 14, 10),
                          child: Text(
                            AppLocalizations.of(context).getText('profile_theme'),
                            style: BinaType.labelMd.copyWith(color: BinaColors.ink2),
                          ),
                        ),
                        // Theme swatches - smaller with uniform spacing
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 14),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: BinaThemeId.values.map((theme) {
                              return _ThemeSwatch(
                                theme: theme,
                                isActive: currentTheme == theme,
                                onTap: () async {
                                  HapticFeedback.selectionClick();
                                  BinaColors.use(theme);
                                  await settings.setThemeType(_mapToAppTheme(theme));
                                },
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
                                    AppLocalizations.of(context).getText('a11y_contrast'),
                                    style: BinaType.labelMd.copyWith(color: BinaColors.ink2),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: BinaColors.surfaceSunken,
                                      borderRadius: BorderRadius.circular(999),
                                    ),
                                    child: Text(
                                      _getContrastLabel(context, settings.contrastLevel),
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
                                    final contrastLevel = value - 1.0;
                                    await settings.setContrastLevel(contrastLevel);
                                    BinaColors.setContrastLevel(contrastLevel);
                                  },
                                ),
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    AppLocalizations.of(context).getText('a11y_softer'),
                                    style: BinaType.labelSm.copyWith(color: BinaColors.ink3),
                                  ),
                                  Text(
                                    AppLocalizations.of(context).getText('a11y_stronger'),
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

                  // Language Section
                  _SettingsSection(
                    title: AppLocalizations.of(context).getText('a11y_language'),
                    child: _SettingsNavRow(
                      icon: Icons.language_rounded,
                      iconBgColor: BinaColors.primary100,
                      iconColor: BinaColors.primary700,
                      label: AppLocalizations.of(context).getText('a11y_app_language'),
                      subtitle: _getCurrentLanguageName(),
                      onTap: () {
                        HapticFeedback.selectionClick();
                        _showLanguageSelector(context);
                      },
                    ),
                  ).animate()
                      .fadeIn(delay: 150.ms, duration: 400.ms)
                      .moveY(begin: 20, end: 0, delay: 150.ms, duration: 400.ms),

                  // Reading Section
                  _SettingsSection(
                    title: AppLocalizations.of(context).getText('a11y_reading'),
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            AppLocalizations.of(context).getText('a11y_text_size'),
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
                              AppLocalizations.of(context).getText('a11y_preview'),
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
                    title: AppLocalizations.of(context).getText('a11y_guidance'),
                    child: _SettingsToggleRow(
                      icon: Icons.help_outline_rounded,
                      iconBgColor: BinaColors.coral100,
                      iconColor: BinaColors.coral700,
                      label: AppLocalizations.of(context).getText('a11y_hint_mode'),
                      subtitle: AppLocalizations.of(context).getText('a11y_hint_subtitle'),
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
                    title: AppLocalizations.of(context).getText('a11y_motion'),
                    child: Column(
                      children: [
                        _SettingsToggleRow(
                          icon: Icons.animation_rounded,
                          iconBgColor: BinaColors.aqua100,
                          iconColor: BinaColors.aqua700,
                          label: AppLocalizations.of(context).getText('a11y_reduce_motion'),
                          subtitle: AppLocalizations.of(context).getText('a11y_reduce_motion_subtitle'),
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
                          label: AppLocalizations.of(context).getText('a11y_haptic'),
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
          ),
        );
      },
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// LANGUAGE OPTION
// ═══════════════════════════════════════════════════════════════

class _LanguageOption {
  const _LanguageOption({
    required this.code,
    required this.name,
    required this.nativeName,
    required this.flag,
  });

  final String code;
  final String name;
  final String nativeName;
  final String flag;
}

// ═══════════════════════════════════════════════════════════════
// SETTINGS NAV ROW
// ═══════════════════════════════════════════════════════════════

class _SettingsNavRow extends StatelessWidget {
  const _SettingsNavRow({
    required this.icon,
    required this.iconBgColor,
    required this.iconColor,
    required this.label,
    this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final Color iconBgColor;
  final Color iconColor;
  final String label;
  final String? subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
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
            Icon(Icons.chevron_right_rounded, color: BinaColors.ink3, size: 24),
          ],
        ),
      ),
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

  String _getLabel(BuildContext context) {
    switch (theme) {
      case BinaThemeId.light:
        return AppLocalizations.of(context).getText('a11y_theme_light');
      case BinaThemeId.dark:
        return AppLocalizations.of(context).getText('a11y_theme_dark');
      case BinaThemeId.warm:
        return AppLocalizations.of(context).getText('a11y_theme_warm');
      case BinaThemeId.cool:
        return AppLocalizations.of(context).getText('a11y_theme_cool');
      case BinaThemeId.deuteranopia:
        return AppLocalizations.of(context).getText('a11y_theme_a11y');
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
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              gradient: _gradient,
              borderRadius: BorderRadius.circular(14),
              boxShadow: isActive
                  ? [
                      BoxShadow(
                        color: BinaColors.primary.withValues(alpha: 0.5),
                        blurRadius: 0,
                        spreadRadius: 2,
                      )
                    ]
                  : BinaElevation.sh1,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            _getLabel(context),
            style: BinaType.labelSm.copyWith(
              color: isActive ? BinaColors.primary : BinaColors.ink2,
              fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
              fontSize: 11,
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
