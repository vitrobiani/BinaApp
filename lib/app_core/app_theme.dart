// ignore_for_file: overridden_fields, annotate_overrides

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '/services/accessibility_settings_service.dart';
import '/app_core/app_theme_type.dart';

const kThemeModeKey = '__theme_mode__';

SharedPreferences? _prefs;

abstract class AppTheme {
  static Future initialize() async =>
      _prefs = await SharedPreferences.getInstance();

  static ThemeMode get themeMode {
    final darkMode = _prefs?.getBool(kThemeModeKey);
    return darkMode == null
        ? ThemeMode.system
        : darkMode
            ? ThemeMode.dark
            : ThemeMode.light;
  }

  static void saveThemeMode(ThemeMode mode) => mode == ThemeMode.system
      ? _prefs?.remove(kThemeModeKey)
      : _prefs?.setBool(kThemeModeKey, mode == ThemeMode.dark);

  static AppTheme of(BuildContext context) {
    // Get theme from AccessibilitySettingsService if initialized
    try {
      final themeType = AccessibilitySettingsService.instance.themeType;
      switch (themeType) {
        case AppThemeType.light:
          return LightModeTheme();
        case AppThemeType.dark:
          return DarkModeTheme();
        case AppThemeType.warm:
          return WarmModeTheme();
        case AppThemeType.cool:
          return CoolModeTheme();
        case AppThemeType.deuteranopia:
          return DeuteranopiaTheme();
      }
    } catch (_) {
      // Fallback to brightness-based theme if service not initialized
      return Theme.of(context).brightness == Brightness.dark
          ? DarkModeTheme()
          : LightModeTheme();
    }
  }

  @Deprecated('Use primary instead')
  Color get primaryColor => primary;
  @Deprecated('Use secondary instead')
  Color get secondaryColor => secondary;
  @Deprecated('Use tertiary instead')
  Color get tertiaryColor => tertiary;

  late Color primary;
  late Color secondary;
  late Color tertiary;
  late Color alternate;
  late Color primaryText;
  late Color secondaryText;
  late Color primaryBackground;
  late Color secondaryBackground;
  late Color accent1;
  late Color accent2;
  late Color accent3;
  late Color accent4;
  late Color success;
  late Color warning;
  late Color error;
  late Color info;

  late Color primaryBtnText;
  late Color lineColor;
  late Color overlay;
  late Color tertiary400;

  @Deprecated('Use displaySmallFamily instead')
  String get title1Family => displaySmallFamily;
  @Deprecated('Use displaySmall instead')
  TextStyle get title1 => typography.displaySmall;
  @Deprecated('Use headlineMediumFamily instead')
  String get title2Family => typography.headlineMediumFamily;
  @Deprecated('Use headlineMedium instead')
  TextStyle get title2 => typography.headlineMedium;
  @Deprecated('Use headlineSmallFamily instead')
  String get title3Family => typography.headlineSmallFamily;
  @Deprecated('Use headlineSmall instead')
  TextStyle get title3 => typography.headlineSmall;
  @Deprecated('Use titleMediumFamily instead')
  String get subtitle1Family => typography.titleMediumFamily;
  @Deprecated('Use titleMedium instead')
  TextStyle get subtitle1 => typography.titleMedium;
  @Deprecated('Use titleSmallFamily instead')
  String get subtitle2Family => typography.titleSmallFamily;
  @Deprecated('Use titleSmall instead')
  TextStyle get subtitle2 => typography.titleSmall;
  @Deprecated('Use bodyMediumFamily instead')
  String get bodyText1Family => typography.bodyMediumFamily;
  @Deprecated('Use bodyMedium instead')
  TextStyle get bodyText1 => typography.bodyMedium;
  @Deprecated('Use bodySmallFamily instead')
  String get bodyText2Family => typography.bodySmallFamily;
  @Deprecated('Use bodySmall instead')
  TextStyle get bodyText2 => typography.bodySmall;

  String get displayLargeFamily => typography.displayLargeFamily;
  bool get displayLargeIsCustom => typography.displayLargeIsCustom;
  TextStyle get displayLarge => typography.displayLarge;
  String get displayMediumFamily => typography.displayMediumFamily;
  bool get displayMediumIsCustom => typography.displayMediumIsCustom;
  TextStyle get displayMedium => typography.displayMedium;
  String get displaySmallFamily => typography.displaySmallFamily;
  bool get displaySmallIsCustom => typography.displaySmallIsCustom;
  TextStyle get displaySmall => typography.displaySmall;
  String get headlineLargeFamily => typography.headlineLargeFamily;
  bool get headlineLargeIsCustom => typography.headlineLargeIsCustom;
  TextStyle get headlineLarge => typography.headlineLarge;
  String get headlineMediumFamily => typography.headlineMediumFamily;
  bool get headlineMediumIsCustom => typography.headlineMediumIsCustom;
  TextStyle get headlineMedium => typography.headlineMedium;
  String get headlineSmallFamily => typography.headlineSmallFamily;
  bool get headlineSmallIsCustom => typography.headlineSmallIsCustom;
  TextStyle get headlineSmall => typography.headlineSmall;
  String get titleLargeFamily => typography.titleLargeFamily;
  bool get titleLargeIsCustom => typography.titleLargeIsCustom;
  TextStyle get titleLarge => typography.titleLarge;
  String get titleMediumFamily => typography.titleMediumFamily;
  bool get titleMediumIsCustom => typography.titleMediumIsCustom;
  TextStyle get titleMedium => typography.titleMedium;
  String get titleSmallFamily => typography.titleSmallFamily;
  bool get titleSmallIsCustom => typography.titleSmallIsCustom;
  TextStyle get titleSmall => typography.titleSmall;
  String get labelLargeFamily => typography.labelLargeFamily;
  bool get labelLargeIsCustom => typography.labelLargeIsCustom;
  TextStyle get labelLarge => typography.labelLarge;
  String get labelMediumFamily => typography.labelMediumFamily;
  bool get labelMediumIsCustom => typography.labelMediumIsCustom;
  TextStyle get labelMedium => typography.labelMedium;
  String get labelSmallFamily => typography.labelSmallFamily;
  bool get labelSmallIsCustom => typography.labelSmallIsCustom;
  TextStyle get labelSmall => typography.labelSmall;
  String get bodyLargeFamily => typography.bodyLargeFamily;
  bool get bodyLargeIsCustom => typography.bodyLargeIsCustom;
  TextStyle get bodyLarge => typography.bodyLarge;
  String get bodyMediumFamily => typography.bodyMediumFamily;
  bool get bodyMediumIsCustom => typography.bodyMediumIsCustom;
  TextStyle get bodyMedium => typography.bodyMedium;
  String get bodySmallFamily => typography.bodySmallFamily;
  bool get bodySmallIsCustom => typography.bodySmallIsCustom;
  TextStyle get bodySmall => typography.bodySmall;

  Typography get typography => ThemeTypography(this);
}

class LightModeTheme extends AppTheme {
  @Deprecated('Use primary instead')
  Color get primaryColor => primary;
  @Deprecated('Use secondary instead')
  Color get secondaryColor => secondary;
  @Deprecated('Use tertiary instead')
  Color get tertiaryColor => tertiary;

  late Color primary = const Color(0xFF105DFB);
  late Color secondary = const Color(0xFF8AC7FF);
  late Color tertiary = const Color(0xFFEE8B60);
  late Color alternate = const Color(0xFFE0E3E7);
  late Color primaryText = const Color(0xFF12151C);
  late Color secondaryText = const Color(0xFF5A5C60);
  late Color primaryBackground = const Color(0xFFF6F6F6);
  late Color secondaryBackground = const Color(0xFFFFFFFF);
  late Color accent1 = const Color(0x4C105DFB);
  late Color accent2 = const Color(0x4C8AC7FF);
  late Color accent3 = const Color(0x4CEE8B60);
  late Color accent4 = const Color(0xB3FFFFFF);
  late Color success = const Color(0xFF02CA79);
  late Color warning = const Color(0xFFC96F46);
  late Color error = const Color(0xFFE65454);
  late Color info = const Color(0xFFFFFFFF);

  late Color primaryBtnText = const Color(0xFF26F87D);
  late Color lineColor = const Color(0xFF2386A2);
  late Color overlay = const Color(0xFF91054C);
  late Color tertiary400 = const Color(0xFF8C1C83);
}

abstract class Typography {
  String get displayLargeFamily;
  bool get displayLargeIsCustom;
  TextStyle get displayLarge;
  String get displayMediumFamily;
  bool get displayMediumIsCustom;
  TextStyle get displayMedium;
  String get displaySmallFamily;
  bool get displaySmallIsCustom;
  TextStyle get displaySmall;
  String get headlineLargeFamily;
  bool get headlineLargeIsCustom;
  TextStyle get headlineLarge;
  String get headlineMediumFamily;
  bool get headlineMediumIsCustom;
  TextStyle get headlineMedium;
  String get headlineSmallFamily;
  bool get headlineSmallIsCustom;
  TextStyle get headlineSmall;
  String get titleLargeFamily;
  bool get titleLargeIsCustom;
  TextStyle get titleLarge;
  String get titleMediumFamily;
  bool get titleMediumIsCustom;
  TextStyle get titleMedium;
  String get titleSmallFamily;
  bool get titleSmallIsCustom;
  TextStyle get titleSmall;
  String get labelLargeFamily;
  bool get labelLargeIsCustom;
  TextStyle get labelLarge;
  String get labelMediumFamily;
  bool get labelMediumIsCustom;
  TextStyle get labelMedium;
  String get labelSmallFamily;
  bool get labelSmallIsCustom;
  TextStyle get labelSmall;
  String get bodyLargeFamily;
  bool get bodyLargeIsCustom;
  TextStyle get bodyLarge;
  String get bodyMediumFamily;
  bool get bodyMediumIsCustom;
  TextStyle get bodyMedium;
  String get bodySmallFamily;
  bool get bodySmallIsCustom;
  TextStyle get bodySmall;
}

class ThemeTypography extends Typography {
  ThemeTypography(this.theme);

  final AppTheme theme;

  /// Get the current text scale factor from AccessibilitySettingsService
  /// Returns 1.0 if service not initialized (safe fallback)
  double get _scaleFactor {
    try {
      return AccessibilitySettingsService.instance.textScale.scaleFactor;
    } catch (_) {
      return 1.0; // Fallback if service not initialized
    }
  }

  /// Apply text scale to a base font size
  double _scaled(double baseSize) => baseSize * _scaleFactor;

  String get displayLargeFamily => 'Readex Pro';
  bool get displayLargeIsCustom => false;
  TextStyle get displayLarge => GoogleFonts.readexPro(
        color: theme.primaryText,
        fontWeight: FontWeight.normal,
        fontSize: _scaled(60.0),
      );
  String get displayMediumFamily => 'Readex Pro';
  bool get displayMediumIsCustom => false;
  TextStyle get displayMedium => GoogleFonts.readexPro(
        color: theme.primaryText,
        fontWeight: FontWeight.normal,
        fontSize: _scaled(45.0),
      );
  String get displaySmallFamily => 'Readex Pro';
  bool get displaySmallIsCustom => false;
  TextStyle get displaySmall => GoogleFonts.readexPro(
        color: theme.primaryText,
        fontWeight: FontWeight.w600,
        fontSize: _scaled(32.0),
      );
  String get headlineLargeFamily => 'Readex Pro';
  bool get headlineLargeIsCustom => false;
  TextStyle get headlineLarge => GoogleFonts.readexPro(
        color: theme.primaryText,
        fontWeight: FontWeight.normal,
        fontSize: _scaled(32.0),
      );
  String get headlineMediumFamily => 'Readex Pro';
  bool get headlineMediumIsCustom => false;
  TextStyle get headlineMedium => GoogleFonts.readexPro(
        color: theme.primaryText,
        fontWeight: FontWeight.w500,
        fontSize: _scaled(22.0),
      );
  String get headlineSmallFamily => 'Readex Pro';
  bool get headlineSmallIsCustom => false;
  TextStyle get headlineSmall => GoogleFonts.readexPro(
        color: theme.primaryText,
        fontWeight: FontWeight.w500,
        fontSize: _scaled(20.0),
      );
  String get titleLargeFamily => 'Readex Pro';
  bool get titleLargeIsCustom => false;
  TextStyle get titleLarge => GoogleFonts.readexPro(
        color: theme.primaryText,
        fontWeight: FontWeight.w500,
        fontSize: _scaled(22.0),
      );
  String get titleMediumFamily => 'Readex Pro';
  bool get titleMediumIsCustom => false;
  TextStyle get titleMedium => GoogleFonts.readexPro(
        color: theme.info,
        fontWeight: FontWeight.w500,
        fontSize: _scaled(18.0),
      );
  String get titleSmallFamily => 'Inter';
  bool get titleSmallIsCustom => false;
  TextStyle get titleSmall => GoogleFonts.inter(
        color: theme.info,
        fontWeight: FontWeight.w500,
        fontSize: _scaled(16.0),
      );
  String get labelLargeFamily => 'Inter';
  bool get labelLargeIsCustom => false;
  TextStyle get labelLarge => GoogleFonts.inter(
        color: theme.secondaryText,
        fontWeight: FontWeight.w500,
        fontSize: _scaled(16.0),
      );
  String get labelMediumFamily => 'Inter';
  bool get labelMediumIsCustom => false;
  TextStyle get labelMedium => GoogleFonts.inter(
        color: theme.secondaryText,
        fontWeight: FontWeight.w500,
        fontSize: _scaled(14.0),
      );
  String get labelSmallFamily => 'Inter';
  bool get labelSmallIsCustom => false;
  TextStyle get labelSmall => GoogleFonts.inter(
        color: theme.secondaryText,
        fontWeight: FontWeight.w500,
        fontSize: _scaled(12.0),
      );
  String get bodyLargeFamily => 'Inter';
  bool get bodyLargeIsCustom => false;
  TextStyle get bodyLarge => GoogleFonts.inter(
        color: theme.primaryText,
        fontSize: _scaled(16.0),
      );
  String get bodyMediumFamily => 'Inter';
  bool get bodyMediumIsCustom => false;
  TextStyle get bodyMedium => GoogleFonts.inter(
        color: theme.primaryText,
        fontWeight: FontWeight.normal,
        fontSize: _scaled(14.0),
      );
  String get bodySmallFamily => 'Inter';
  bool get bodySmallIsCustom => false;
  TextStyle get bodySmall => GoogleFonts.inter(
        color: theme.primaryText,
        fontWeight: FontWeight.normal,
        fontSize: _scaled(12.0),
      );
}

class DarkModeTheme extends AppTheme {
  @Deprecated('Use primary instead')
  Color get primaryColor => primary;
  @Deprecated('Use secondary instead')
  Color get secondaryColor => secondary;
  @Deprecated('Use tertiary instead')
  Color get tertiaryColor => tertiary;

  late Color primary = const Color(0xFF105DFB);
  late Color secondary = const Color(0xFF0070A8);
  late Color tertiary = const Color(0xFFEE8B60);
  late Color alternate = const Color(0xFF212836);
  late Color primaryText = const Color(0xFFFFFFFF);
  late Color secondaryText = const Color(0xFFC8C8C8);
  late Color primaryBackground = const Color(0xFF12151C);
  late Color secondaryBackground = const Color(0xFF151820);
  late Color accent1 = const Color(0x4C105DFB);
  late Color accent2 = const Color(0x4C8AC7FF);
  late Color accent3 = const Color(0x4CEE8B60);
  late Color accent4 = const Color(0xB314181B);
  late Color success = const Color(0xFF02CA79);
  late Color warning = const Color(0xFFC96F46);
  late Color error = const Color(0xFFE65454);
  late Color info = const Color(0xFFFFFFFF);

  late Color primaryBtnText = const Color(0xFF26F87D);
  late Color lineColor = const Color(0xFF8F6F37);
  late Color overlay = const Color(0xFF91054C);
  late Color tertiary400 = const Color(0xFF8C1C83);
}

/// Warm theme - cozy amber/cream tones
class WarmModeTheme extends AppTheme {
  @Deprecated('Use primary instead')
  Color get primaryColor => primary;
  @Deprecated('Use secondary instead')
  Color get secondaryColor => secondary;
  @Deprecated('Use tertiary instead')
  Color get tertiaryColor => tertiary;

  late Color primary = const Color(0xFFFF8F00);       // Amber
  late Color secondary = const Color(0xFFFFB74D);     // Light amber
  late Color tertiary = const Color(0xFFD84315);      // Deep orange
  late Color alternate = const Color(0xFFE8DED0);     // Warm beige
  late Color primaryText = const Color(0xFF3E2723);   // Brown
  late Color secondaryText = const Color(0xFF5D4037); // Medium brown
  late Color primaryBackground = const Color(0xFFFFF8E1); // Cream
  late Color secondaryBackground = const Color(0xFFFFFBF5); // Light cream
  late Color accent1 = const Color(0x4CFF8F00);
  late Color accent2 = const Color(0x4CFFB74D);
  late Color accent3 = const Color(0x4CD84315);
  late Color accent4 = const Color(0xB3FFFBF5);
  late Color success = const Color(0xFF43A047);       // Green
  late Color warning = const Color(0xFFEF6C00);       // Orange
  late Color error = const Color(0xFFD32F2F);         // Red
  late Color info = const Color(0xFFFFFFFF);

  late Color primaryBtnText = const Color(0xFFFFFFFF);
  late Color lineColor = const Color(0xFFBCAAA4);     // Warm gray
  late Color overlay = const Color(0xFF6D4C41);
  late Color tertiary400 = const Color(0xFFFF7043);
}

/// Cool theme - calm blue/teal tones
class CoolModeTheme extends AppTheme {
  @Deprecated('Use primary instead')
  Color get primaryColor => primary;
  @Deprecated('Use secondary instead')
  Color get secondaryColor => secondary;
  @Deprecated('Use tertiary instead')
  Color get tertiaryColor => tertiary;

  late Color primary = const Color(0xFF00ACC1);       // Cyan
  late Color secondary = const Color(0xFF4DD0E1);     // Light cyan
  late Color tertiary = const Color(0xFF0277BD);      // Blue
  late Color alternate = const Color(0xFFD6E6ED);     // Cool gray-blue
  late Color primaryText = const Color(0xFF0D47A1);   // Dark blue
  late Color secondaryText = const Color(0xFF37474F); // Blue-gray
  late Color primaryBackground = const Color(0xFFE3F2FD); // Light blue
  late Color secondaryBackground = const Color(0xFFF5FAFF); // Very light blue
  late Color accent1 = const Color(0x4C00ACC1);
  late Color accent2 = const Color(0x4C4DD0E1);
  late Color accent3 = const Color(0x4C0277BD);
  late Color accent4 = const Color(0xB3F5FAFF);
  late Color success = const Color(0xFF00897B);       // Teal
  late Color warning = const Color(0xFFFFA726);       // Orange
  late Color error = const Color(0xFFE53935);         // Red
  late Color info = const Color(0xFFFFFFFF);

  late Color primaryBtnText = const Color(0xFFFFFFFF);
  late Color lineColor = const Color(0xFF90A4AE);     // Blue-gray
  late Color overlay = const Color(0xFF455A64);
  late Color tertiary400 = const Color(0xFF29B6F6);
}

/// Deuteranopia theme - optimized for red-green color blindness
/// Uses blue/yellow/orange palette that's distinguishable for most colorblind users
class DeuteranopiaTheme extends AppTheme {
  @Deprecated('Use primary instead')
  Color get primaryColor => primary;
  @Deprecated('Use secondary instead')
  Color get secondaryColor => secondary;
  @Deprecated('Use tertiary instead')
  Color get tertiaryColor => tertiary;

  late Color primary = const Color(0xFF0077BB);       // Blue (safe)
  late Color secondary = const Color(0xFF33BBEE);     // Light blue (safe)
  late Color tertiary = const Color(0xFFEE7733);      // Orange (safe)
  late Color alternate = const Color(0xFFE0E0E0);     // Neutral gray
  late Color primaryText = const Color(0xFF1A1A1A);   // Near black
  late Color secondaryText = const Color(0xFF555555); // Dark gray
  late Color primaryBackground = const Color(0xFFFAFAFA); // Off-white
  late Color secondaryBackground = const Color(0xFFFFFFFF); // White
  late Color accent1 = const Color(0x4C0077BB);
  late Color accent2 = const Color(0x4C33BBEE);
  late Color accent3 = const Color(0x4CEE7733);
  late Color accent4 = const Color(0xB3FFFFFF);
  late Color success = const Color(0xFF009988);       // Teal (distinguishable from red)
  late Color warning = const Color(0xFFEECC66);       // Yellow (safe)
  late Color error = const Color(0xFFCC3311);         // Orange-red (more visible)
  late Color info = const Color(0xFFFFFFFF);

  late Color primaryBtnText = const Color(0xFFFFFFFF);
  late Color lineColor = const Color(0xFF0077BB);     // Blue for visibility
  late Color overlay = const Color(0xFF004488);
  late Color tertiary400 = const Color(0xFFEE7733);
}

extension TextStyleHelper on TextStyle {
  TextStyle override({
    TextStyle? font,
    String? fontFamily,
    Color? color,
    double? fontSize,
    FontWeight? fontWeight,
    double? letterSpacing,
    FontStyle? fontStyle,
    bool useGoogleFonts = false,
    TextDecoration? decoration,
    double? lineHeight,
    List<Shadow>? shadows,
    String? package,
  }) {
    if (useGoogleFonts && fontFamily != null) {
      font = GoogleFonts.getFont(fontFamily,
          fontWeight: fontWeight ?? this.fontWeight,
          fontStyle: fontStyle ?? this.fontStyle);
    }

    return font != null
        ? font.copyWith(
            color: color ?? this.color,
            fontSize: fontSize ?? this.fontSize,
            letterSpacing: letterSpacing ?? this.letterSpacing,
            fontWeight: fontWeight ?? this.fontWeight,
            fontStyle: fontStyle ?? this.fontStyle,
            decoration: decoration,
            height: lineHeight,
            shadows: shadows,
          )
        : copyWith(
            fontFamily: fontFamily,
            package: package,
            color: color,
            fontSize: fontSize,
            letterSpacing: letterSpacing,
            fontWeight: fontWeight,
            fontStyle: fontStyle,
            decoration: decoration,
            height: lineHeight,
            shadows: shadows,
          );
  }
}
