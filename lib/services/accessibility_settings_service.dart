import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '/app_core/text_scale.dart';
import '/app_core/app_theme_type.dart';

/// Service for managing accessibility settings
///
/// This is a singleton service that persists settings to device storage.
/// It uses ChangeNotifier for reactive UI updates.
///
/// ## Usage
/// ```dart
/// // Initialize at app startup
/// await AccessibilitySettingsService.instance.init();
///
/// // Listen for changes
/// context.watch<AccessibilitySettingsService>();
///
/// // Access settings
/// final textScale = AccessibilitySettingsService.instance.textScale;
///
/// // Update settings
/// AccessibilitySettingsService.instance.setTextScale(TextScale.large);
/// ```
///
/// ## Future Supabase Sync
/// To add cloud sync, implement syncToCloud() and syncFromCloud() methods.
class AccessibilitySettingsService extends ChangeNotifier {
  AccessibilitySettingsService._();

  static final AccessibilitySettingsService _instance = AccessibilitySettingsService._();
  static AccessibilitySettingsService get instance => _instance;

  // Storage keys
  static const String _keyTextScale = 'accessibility_text_scale';
  static const String _keyTheme = 'accessibility_theme';
  static const String _keyContrast = 'accessibility_contrast';
  static const String _keyHintsEnabled = 'accessibility_hints_enabled';
  static const String _keyAutoAdjustEnabled = 'accessibility_auto_adjust';
  static const String _keyHasAppliedAutoAdjust = 'accessibility_has_applied_auto_adjust';
  static const String _keyReduceMotion = 'accessibility_reduce_motion';
  static const String _keyHapticEnabled = 'accessibility_haptic_enabled';

  // Settings with defaults
  TextScale _textScale = TextScale.medium;
  AppThemeType _themeType = AppThemeType.light;
  double _contrastLevel = 0.0; // 0.0 = normal, 1.0 = maximum contrast
  bool _hintsEnabled = true; // Tooltips on long-press
  bool _autoAdjustEnabled = true; // Age-based auto adjustments
  bool _hasAppliedAutoAdjust = false; // Track if we've already applied auto-adjust
  bool _reduceMotion = false; // Disable animations and transitions
  bool _hapticEnabled = true; // Vibration feedback

  bool _isInitialized = false;

  // Getters
  TextScale get textScale => _textScale;
  AppThemeType get themeType => _themeType;
  double get contrastLevel => _contrastLevel;
  bool get hintsEnabled => _hintsEnabled;
  bool get autoAdjustEnabled => _autoAdjustEnabled;
  bool get reduceMotion => _reduceMotion;
  bool get hapticEnabled => _hapticEnabled;
  bool get isInitialized => _isInitialized;

  /// Initialize the service and load saved settings
  /// Call this once at app startup before the UI renders
  Future<void> init() async {
    if (_isInitialized) return;

    try {
      final prefs = await SharedPreferences.getInstance();

      _textScale = TextScale.fromString(prefs.getString(_keyTextScale));
      _themeType = AppThemeType.fromString(prefs.getString(_keyTheme));
      _contrastLevel = prefs.getDouble(_keyContrast) ?? 0.0;
      _hintsEnabled = prefs.getBool(_keyHintsEnabled) ?? true;
      _autoAdjustEnabled = prefs.getBool(_keyAutoAdjustEnabled) ?? true;
      _hasAppliedAutoAdjust = prefs.getBool(_keyHasAppliedAutoAdjust) ?? false;
      _reduceMotion = prefs.getBool(_keyReduceMotion) ?? false;
      _hapticEnabled = prefs.getBool(_keyHapticEnabled) ?? true;

      _isInitialized = true;
      debugPrint('AccessibilitySettingsService: initialized');
      debugPrint('  textScale: ${_textScale.name}');
      debugPrint('  theme: ${_themeType.id}');
      debugPrint('  contrast: $_contrastLevel');
      debugPrint('  hints: $_hintsEnabled');
      debugPrint('  autoAdjust: $_autoAdjustEnabled');
      debugPrint('  reduceMotion: $_reduceMotion');
      debugPrint('  hapticEnabled: $_hapticEnabled');
    } catch (e) {
      debugPrint('AccessibilitySettingsService init error: $e');
      _isInitialized = true; // Continue with defaults
    }
  }

  /// Apply auto-adjustments based on user age
  /// Only applies once per device (unless reset)
  ///
  /// [userAge] - The age of the admin/head family member
  Future<void> applyAutoAdjustmentsForAge(int? userAge) async {
    if (!_autoAdjustEnabled) return;
    if (_hasAppliedAutoAdjust) return;
    if (userAge == null) return;

    debugPrint('AccessibilitySettingsService: applying auto-adjustments for age $userAge');

    // Apply suggested text scale based on age
    final suggestedScale = TextScale.suggestedForAge(userAge);
    if (suggestedScale != TextScale.medium) {
      await setTextScale(suggestedScale);
      debugPrint('  Auto-set text scale to: ${suggestedScale.displayName}');
    }

    // Apply higher contrast for older users
    if (userAge >= 65) {
      await setContrastLevel(0.3); // Moderate contrast boost
      debugPrint('  Auto-set contrast level to: 0.3');
    }

    // Mark as applied
    _hasAppliedAutoAdjust = true;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyHasAppliedAutoAdjust, true);
  }

  /// Reset auto-adjust flag (useful for testing or if user wants to re-apply)
  Future<void> resetAutoAdjust() async {
    _hasAppliedAutoAdjust = false;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyHasAppliedAutoAdjust, false);
  }

  // ============================================================
  // Setters (with persistence and notification)
  // ============================================================

  Future<void> setTextScale(TextScale scale) async {
    if (_textScale == scale) return;

    _textScale = scale;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyTextScale, scale.name);
    debugPrint('AccessibilitySettingsService: textScale set to ${scale.name}');
  }

  Future<void> setThemeType(AppThemeType theme) async {
    if (_themeType == theme) return;

    _themeType = theme;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyTheme, theme.id);
    debugPrint('AccessibilitySettingsService: theme set to ${theme.id}');
  }

  Future<void> setContrastLevel(double level) async {
    // Clamp to valid range
    level = level.clamp(0.0, 1.0);
    if (_contrastLevel == level) return;

    _contrastLevel = level;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_keyContrast, level);
    debugPrint('AccessibilitySettingsService: contrast set to $level');
  }

  Future<void> setHintsEnabled(bool enabled) async {
    if (_hintsEnabled == enabled) return;

    _hintsEnabled = enabled;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyHintsEnabled, enabled);
    debugPrint('AccessibilitySettingsService: hints ${enabled ? 'enabled' : 'disabled'}');
  }

  Future<void> setAutoAdjustEnabled(bool enabled) async {
    if (_autoAdjustEnabled == enabled) return;

    _autoAdjustEnabled = enabled;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyAutoAdjustEnabled, enabled);
    debugPrint('AccessibilitySettingsService: autoAdjust ${enabled ? 'enabled' : 'disabled'}');
  }

  Future<void> setReduceMotion(bool enabled) async {
    if (_reduceMotion == enabled) return;

    _reduceMotion = enabled;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyReduceMotion, enabled);
    debugPrint('AccessibilitySettingsService: reduceMotion ${enabled ? 'enabled' : 'disabled'}');
  }

  Future<void> setHapticEnabled(bool enabled) async {
    if (_hapticEnabled == enabled) return;

    _hapticEnabled = enabled;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyHapticEnabled, enabled);
    debugPrint('AccessibilitySettingsService: haptic ${enabled ? 'enabled' : 'disabled'}');
  }

  // ============================================================
  // Convenience methods
  // ============================================================

  /// Get the actual font size multiplied by the text scale factor
  double scaledFontSize(double baseSize) {
    return baseSize * _textScale.scaleFactor;
  }

  /// Get border width adjusted by contrast level
  /// Base width at contrast 0.0, up to 3x at contrast 1.0
  double scaledBorderWidth(double baseWidth) {
    return baseWidth * (1.0 + (_contrastLevel * 2.0));
  }

  /// Get whether we should use enhanced contrast colors
  bool get useHighContrast => _contrastLevel >= 0.5;

  /// Reset all settings to defaults
  Future<void> resetToDefaults() async {
    _textScale = TextScale.medium;
    _themeType = AppThemeType.light;
    _contrastLevel = 0.0;
    _hintsEnabled = true;
    _autoAdjustEnabled = true;
    _hasAppliedAutoAdjust = false;
    _reduceMotion = false;
    _hapticEnabled = true;

    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyTextScale);
    await prefs.remove(_keyTheme);
    await prefs.remove(_keyContrast);
    await prefs.remove(_keyHintsEnabled);
    await prefs.remove(_keyAutoAdjustEnabled);
    await prefs.remove(_keyHasAppliedAutoAdjust);
    await prefs.remove(_keyReduceMotion);
    await prefs.remove(_keyHapticEnabled);

    debugPrint('AccessibilitySettingsService: reset to defaults');
  }

  // ============================================================
  // Future: Cloud Sync Methods
  // ============================================================

  /// Sync settings to cloud (future implementation)
  /// Example: await syncToCloud(userId);
  // Future<void> syncToCloud(String userId) async {
  //   await supabase.from('user_preferences').upsert({
  //     'user_id': userId,
  //     'text_scale': _textScale.name,
  //     'theme': _themeType.id,
  //     'contrast': _contrastLevel,
  //     'hints_enabled': _hintsEnabled,
  //     'auto_adjust_enabled': _autoAdjustEnabled,
  //   });
  // }

  /// Sync settings from cloud (future implementation)
  /// Example: await syncFromCloud(userId);
  // Future<void> syncFromCloud(String userId) async {
  //   final data = await supabase.from('user_preferences')
  //     .select()
  //     .eq('user_id', userId)
  //     .single();
  //
  //   _textScale = TextScale.fromString(data['text_scale']);
  //   _themeType = AppThemeType.fromString(data['theme']);
  //   _contrastLevel = data['contrast'] ?? 0.0;
  //   _hintsEnabled = data['hints_enabled'] ?? true;
  //   _autoAdjustEnabled = data['auto_adjust_enabled'] ?? true;
  //
  //   notifyListeners();
  // }
}
