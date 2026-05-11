/// Text scale options for accessibility
///
/// Each scale has a multiplier that affects all text sizes proportionally.
/// To add a new scale, simply add a new enum value with the desired factor.
enum TextScale {
  small(0.85, 'Small'),
  medium(1.0, 'Medium'),
  large(1.15, 'Large'),
  extraLarge(1.3, 'Extra Large');

  const TextScale(this.scaleFactor, this.displayName);

  /// The multiplier applied to all text sizes
  final double scaleFactor;

  /// Human-readable name for UI display
  final String displayName;

  /// Get TextScale from string name (for persistence)
  static TextScale fromString(String? name) {
    if (name == null) return TextScale.medium;
    return TextScale.values.firstWhere(
      (scale) => scale.name == name,
      orElse: () => TextScale.medium,
    );
  }

  /// Suggested scale based on user age
  /// Users 65+ benefit from larger text
  static TextScale suggestedForAge(int? age) {
    if (age == null) return TextScale.medium;
    if (age >= 75) return TextScale.extraLarge;
    if (age >= 65) return TextScale.large;
    return TextScale.medium;
  }
}
