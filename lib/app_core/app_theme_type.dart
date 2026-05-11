import 'package:flutter/material.dart';

/// Available theme types for the app
///
/// To add a new theme:
/// 1. Add a new enum value here
/// 2. Add the corresponding theme data in ThemeRegistry
enum AppThemeType {
  light(
    id: 'light',
    displayName: 'Light',
    description: 'Clean and bright',
    icon: Icons.light_mode,
    previewColors: [Color(0xFFFFFFFF), Color(0xFF1A1A1A), Color(0xFF6200EE)],
  ),
  dark(
    id: 'dark',
    displayName: 'Dark',
    description: 'Easy on the eyes',
    icon: Icons.dark_mode,
    previewColors: [Color(0xFF121212), Color(0xFFFFFFFF), Color(0xFFBB86FC)],
  ),
  warm(
    id: 'warm',
    displayName: 'Warm',
    description: 'Cozy amber tones',
    icon: Icons.wb_sunny,
    previewColors: [Color(0xFFFFF8E1), Color(0xFF5D4037), Color(0xFFFF8F00)],
  ),
  cool(
    id: 'cool',
    displayName: 'Cool',
    description: 'Calm blue tones',
    icon: Icons.ac_unit,
    previewColors: [Color(0xFFE3F2FD), Color(0xFF0D47A1), Color(0xFF00ACC1)],
  ),
  deuteranopia(
    id: 'deuteranopia',
    displayName: 'Color Blind',
    description: 'Optimized for red-green color blindness',
    icon: Icons.visibility,
    previewColors: [Color(0xFFFAFAFA), Color(0xFF1A1A1A), Color(0xFF0077BB)],
  );

  const AppThemeType({
    required this.id,
    required this.displayName,
    required this.description,
    required this.icon,
    required this.previewColors,
  });

  /// Unique identifier for persistence
  final String id;

  /// Human-readable name for UI
  final String displayName;

  /// Short description of the theme
  final String description;

  /// Icon to represent the theme
  final IconData icon;

  /// Preview colors: [background, text, accent]
  final List<Color> previewColors;

  /// Get AppThemeType from string id (for persistence)
  static AppThemeType fromString(String? id) {
    if (id == null) return AppThemeType.light;
    return AppThemeType.values.firstWhere(
      (theme) => theme.id == id,
      orElse: () => AppThemeType.light,
    );
  }

  /// Whether this is a dark theme (for system UI adjustments)
  bool get isDark => this == AppThemeType.dark;

  /// Get the Flutter ThemeMode equivalent
  ThemeMode get themeMode => isDark ? ThemeMode.dark : ThemeMode.light;
}
