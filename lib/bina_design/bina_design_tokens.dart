// bina_design_tokens.dart
//
// Design tokens for the REFINED Bina design system.
//
// Usage:
//   import 'package:bina_system/bina_design/bina_design_tokens.dart';
//
//   Container(
//     padding: EdgeInsets.all(BinaSpace.s4),
//     decoration: BoxDecoration(
//       color: BinaColors.surface,
//       borderRadius: BorderRadius.circular(BinaRadius.md),
//       border: Border.all(color: BinaColors.line),
//       boxShadow: BinaElevation.sh2,
//     ),
//     child: Text('Hello', style: BinaType.titleMd),
//   );
//
// To swap to a different theme variant at runtime, just call
// `BinaColors.use(BinaThemeId.warm)` (or .dark / .cool / .deuteranopia)
// before the first build of an affected widget.

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '/services/accessibility_settings_service.dart';

// ╔══════════════════════════════════════════════════════════════╗
// ║ Theme identifier — light / dark / warm / cool / deuteranopia ║
// ╚══════════════════════════════════════════════════════════════╝
enum BinaThemeId { light, dark, warm, cool, deuteranopia }

// ╔══════════════════════════════════════════════════════════════╗
// ║ COLORS                                                       ║
// ╚══════════════════════════════════════════════════════════════╝
class BinaColors {
  BinaColors._();

  static BinaThemeId _id = BinaThemeId.light;
  static BinaThemeId get current => _id;

  /// Switch the active theme. All `BinaColors.<name>` getters below
  /// resolve through this flag.
  static void use(BinaThemeId id) => _id = id;

  // ─── Brand ────────────────────────────────────────────────────
  static Color get primary {
    switch (_id) {
      case BinaThemeId.dark:         return const Color(0xFF5B8BFF);
      case BinaThemeId.warm:         return const Color(0xFFEF8B1A);
      case BinaThemeId.cool:         return const Color(0xFF0099B3);
      case BinaThemeId.deuteranopia: return const Color(0xFF0077BB);
      case BinaThemeId.light:        return const Color(0xFF1F5BFF);
    }
  }

  static Color get primary700 {
    switch (_id) {
      case BinaThemeId.dark:         return const Color(0xFF3A6CF2);
      case BinaThemeId.warm:         return const Color(0xFFC9710C);
      case BinaThemeId.cool:         return const Color(0xFF00768A);
      case BinaThemeId.deuteranopia: return const Color(0xFF005C91);
      case BinaThemeId.light:        return const Color(0xFF1849C9);
    }
  }

  static Color get primary100 {
    switch (_id) {
      case BinaThemeId.dark:         return const Color(0xFF1A2547);
      case BinaThemeId.warm:         return const Color(0xFFFDEBD2);
      case BinaThemeId.cool:         return const Color(0xFFD3EEF3);
      case BinaThemeId.deuteranopia: return const Color(0xFFD3E5F1);
      case BinaThemeId.light:        return const Color(0xFFE5EDFF);
    }
  }

  static Color get aqua {
    switch (_id) {
      case BinaThemeId.warm:         return const Color(0xFFD84315);
      case BinaThemeId.cool:         return const Color(0xFF4DD0E1);
      case BinaThemeId.deuteranopia: return const Color(0xFF33BBEE);
      case BinaThemeId.dark:
      case BinaThemeId.light:        return const Color(0xFF6EC6FF);
    }
  }

  static Color get coral {
    switch (_id) {
      case BinaThemeId.dark:         return const Color(0xFFF0A47F);
      case BinaThemeId.warm:         return const Color(0xFFC96F46);
      case BinaThemeId.cool:         return const Color(0xFF0277BD);
      case BinaThemeId.deuteranopia: return const Color(0xFFEE7733);
      case BinaThemeId.light:        return const Color(0xFFEE8B60);
    }
  }

  static Color get coral100 {
    switch (_id) {
      case BinaThemeId.dark:         return const Color(0xFF3D2A22);
      case BinaThemeId.warm:         return const Color(0xFFFDE8DC);
      case BinaThemeId.cool:         return const Color(0xFFE1F0F8);
      case BinaThemeId.deuteranopia: return const Color(0xFFFDE8DC);
      case BinaThemeId.light:        return const Color(0xFFFDEBE3);
    }
  }

  static Color get coral700 {
    switch (_id) {
      case BinaThemeId.dark:         return const Color(0xFFD87A5A);
      case BinaThemeId.warm:         return const Color(0xFF9A5233);
      case BinaThemeId.cool:         return const Color(0xFF015B8E);
      case BinaThemeId.deuteranopia: return const Color(0xFFC95D20);
      case BinaThemeId.light:        return const Color(0xFFC96F46);
    }
  }

  // ─── Ink / text ───────────────────────────────────────────────
  static Color get ink {
    switch (_id) {
      case BinaThemeId.dark:         return const Color(0xFFF4F5FA);
      case BinaThemeId.warm:         return const Color(0xFF3E2723);
      case BinaThemeId.cool:         return const Color(0xFF0D3A5E);
      case BinaThemeId.deuteranopia: return const Color(0xFF1A1A1A);
      case BinaThemeId.light:        return const Color(0xFF0C1530);
    }
  }

  static Color get ink2 {
    switch (_id) {
      case BinaThemeId.dark:         return const Color(0xFFB7BCCD);
      case BinaThemeId.warm:         return const Color(0xFF6B4D3E);
      case BinaThemeId.cool:         return const Color(0xFF37576E);
      case BinaThemeId.deuteranopia: return const Color(0xFF4D4D4D);
      case BinaThemeId.light:        return const Color(0xFF4A516A);
    }
  }

  static Color get ink3 {
    switch (_id) {
      case BinaThemeId.dark:         return const Color(0xFF7E859C);
      case BinaThemeId.warm:         return const Color(0xFF9C7E6E);
      case BinaThemeId.cool:         return const Color(0xFF6A8398);
      case BinaThemeId.deuteranopia: return const Color(0xFF7A7A7A);
      case BinaThemeId.light:        return const Color(0xFF7E859C);
    }
  }

  // ─── Surfaces ─────────────────────────────────────────────────
  static Color get surface {
    switch (_id) {
      case BinaThemeId.dark:         return const Color(0xFF161A28);
      case BinaThemeId.warm:         return const Color(0xFFFFFBF5);
      case BinaThemeId.cool:         return const Color(0xFFF9FDFF);
      case BinaThemeId.deuteranopia: return const Color(0xFFFFFFFF);
      case BinaThemeId.light:        return const Color(0xFFFFFFFF);
    }
  }

  static Color get surfaceAlt {
    switch (_id) {
      case BinaThemeId.dark:         return const Color(0xFF0C0F1A);
      case BinaThemeId.warm:         return const Color(0xFFFFF5E1);
      case BinaThemeId.cool:         return const Color(0xFFE3F2FD);
      case BinaThemeId.deuteranopia: return const Color(0xFFFAFAFA);
      case BinaThemeId.light:        return const Color(0xFFFBFAF6);
    }
  }

  static Color get surfaceSunken {
    switch (_id) {
      case BinaThemeId.dark:         return const Color(0xFF0A0D18);
      case BinaThemeId.warm:         return const Color(0xFFF6E9CF);
      case BinaThemeId.cool:         return const Color(0xFFD2E6F1);
      case BinaThemeId.deuteranopia: return const Color(0xFFF1F1F1);
      case BinaThemeId.light:        return const Color(0xFFF1EEE7);
    }
  }

  static Color get line {
    switch (_id) {
      case BinaThemeId.dark:         return const Color(0xFF232A3D);
      case BinaThemeId.warm:         return const Color(0xFFECE1CD);
      case BinaThemeId.cool:         return const Color(0xFFD4E2EB);
      case BinaThemeId.deuteranopia: return const Color(0xFFE0E0E0);
      case BinaThemeId.light:        return const Color(0xFFE6E8F0);
    }
  }

  static Color get lineStrong {
    switch (_id) {
      case BinaThemeId.dark:         return const Color(0xFF38405A);
      case BinaThemeId.warm:         return const Color(0xFFD4C4AB);
      case BinaThemeId.cool:         return const Color(0xFFAABFCE);
      case BinaThemeId.deuteranopia: return const Color(0xFFB8B8B8);
      case BinaThemeId.light:        return const Color(0xFFC9CDD9);
    }
  }

  // ─── Semantic ─────────────────────────────────────────────────
  static const Color success = Color(0xFF1AA971);
  static const Color warning = Color(0xFFE08A3A);
  static const Color error   = Color(0xFFD94545);
  static const Color info    = Color(0xFF2F8ED8);

  static Color get success100 => _id == BinaThemeId.dark
      ? const Color(0xFF0F2D24)
      : const Color(0xFFD4F5E5);

  static Color get error100 => _id == BinaThemeId.dark
      ? const Color(0xFF3D1F1F)
      : const Color(0xFFFDE8E8);

  // ─── Diagnosis (domain-specific) ──────────────────────────────
  /// "Good" / clean scan
  static Color get dxGood => _id == BinaThemeId.deuteranopia
      ? const Color(0xFF009988)
      : const Color(0xFF1AA971);

  static Color get dxGood100 => _id == BinaThemeId.dark
      ? const Color(0xFF0F2D24)
      : const Color(0xFFD4F5E5);

  /// "Plaque"
  static Color get dxPlaque => _id == BinaThemeId.deuteranopia
      ? const Color(0xFFEECC66)
      : const Color(0xFFE0A23A);

  static Color get dxPlaque100 => _id == BinaThemeId.dark
      ? const Color(0xFF2D2510)
      : const Color(0xFFFCF0D8);

  /// "Cavity"
  static Color get dxCavity => _id == BinaThemeId.deuteranopia
      ? const Color(0xFFCC3311)
      : const Color(0xFFD94545);

  static Color get dxCavity100 => _id == BinaThemeId.dark
      ? const Color(0xFF3D1F1F)
      : const Color(0xFFFDE8E8);

  /// "Plaque + Cavity"
  static Color get dxMixed => _id == BinaThemeId.deuteranopia
      ? const Color(0xFFAA3377)
      : const Color(0xFFB8538A);

  static Color get dxMixed100 => _id == BinaThemeId.dark
      ? const Color(0xFF2D1525)
      : const Color(0xFFF8E1EE);

  // ─── Gradients (use as `LinearGradient`) ──────────────────────
  static LinearGradient get gradHero => LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primary, aqua],
  );

  static LinearGradient get gradHeroSoft => LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primary100, aqua.withOpacity(0.3)],
  );
}

// ╔══════════════════════════════════════════════════════════════╗
// ║ SPACING — base-4 scale                                       ║
// ╚══════════════════════════════════════════════════════════════╝
class BinaSpace {
  BinaSpace._();
  static const double s1  = 4;
  static const double s2  = 8;
  static const double s3  = 12;
  static const double s4  = 16;   // default card padding
  static const double s5  = 20;
  static const double s6  = 24;
  static const double s7  = 32;   // section gap
  static const double s8  = 40;
  static const double s9  = 56;
  static const double s10 = 72;
}

// ╔══════════════════════════════════════════════════════════════╗
// ║ RADIUS                                                       ║
// ╚══════════════════════════════════════════════════════════════╝
class BinaRadius {
  BinaRadius._();
  static const double xs   = 6;
  static const double sm   = 10;
  static const double md   = 14;  // default — cards, buttons
  static const double lg   = 20;  // hero cards
  static const double xl   = 28;  // bottom-sheets, nav bar
  static const double pill = 999;
}

// ╔══════════════════════════════════════════════════════════════╗
// ║ ELEVATION                                                    ║
// ╚══════════════════════════════════════════════════════════════╝
class BinaElevation {
  BinaElevation._();

  static const _inkShadow = Color(0x0F0F193C); // rgba(15,25,60,0.06)
  static const _inkShadowSoft = Color(0x0A0F193C); // rgba(15,25,60,0.04)
  static const _inkShadowStrong = Color(0x140F193C); // rgba(15,25,60,0.08)
  static const _inkShadowHeavy = Color(0x1F0F193C); // rgba(15,25,60,0.12)

  /// Subtle — resting chips
  static const List<BoxShadow> sh1 = [
    BoxShadow(color: _inkShadow, blurRadius: 2, offset: Offset(0, 1)),
  ];

  /// Default card
  static const List<BoxShadow> sh2 = [
    BoxShadow(color: _inkShadow, blurRadius: 6, offset: Offset(0, 2)),
    BoxShadow(color: _inkShadowSoft, blurRadius: 2, offset: Offset(0, 1)),
  ];

  /// Hover · raised
  static const List<BoxShadow> sh3 = [
    BoxShadow(color: _inkShadowStrong, blurRadius: 18, offset: Offset(0, 6)),
    BoxShadow(color: _inkShadowSoft, blurRadius: 4, offset: Offset(0, 2)),
  ];

  /// Modal · sheet
  static const List<BoxShadow> sh4 = [
    BoxShadow(color: _inkShadowHeavy, blurRadius: 36, offset: Offset(0, 16)),
    BoxShadow(color: Color(0x0D0F193C), blurRadius: 10, offset: Offset(0, 4)),
  ];

  /// Colored glow — hero surfaces. Uses the active primary.
  static List<BoxShadow> get shHero => [
    BoxShadow(
      color: BinaColors.primary.withOpacity(0.45),
      blurRadius: 60,
      offset: const Offset(0, 24),
      spreadRadius: -10,
    ),
  ];
}

// ╔══════════════════════════════════════════════════════════════╗
// ║ TYPOGRAPHY                                                   ║
// ╚══════════════════════════════════════════════════════════════╝
/// Refined Bina type scale.
///
/// Display weights use Readex Pro (same as the original app).
/// Body weights use Inter. Both are pulled via google_fonts —
/// already a dependency.
class BinaType {
  BinaType._();

  /// Get the current text scale factor from AccessibilitySettingsService
  static double get _scaleFactor {
    try {
      return AccessibilitySettingsService.instance.textScale.scaleFactor;
    } catch (_) {
      return 1.0;
    }
  }

  static double _scaled(double baseSize) => baseSize * _scaleFactor;

  // Display — Readex Pro 600
  static TextStyle get displayLg => GoogleFonts.readexPro(
    fontSize: _scaled(56), fontWeight: FontWeight.w600, height: 1.05,
    letterSpacing: -0.01 * 56, color: BinaColors.ink,
  );
  static TextStyle get displayMd => GoogleFonts.readexPro(
    fontSize: _scaled(44), fontWeight: FontWeight.w600, height: 1.08,
    letterSpacing: -0.01 * 44, color: BinaColors.ink,
  );
  static TextStyle get displaySm => GoogleFonts.readexPro(
    fontSize: _scaled(32), fontWeight: FontWeight.w600, height: 1.15,
    letterSpacing: -0.01 * 32, color: BinaColors.ink,
  );

  // Headline — Readex Pro 500
  static TextStyle get headlineLg => GoogleFonts.readexPro(
    fontSize: _scaled(28), fontWeight: FontWeight.w500, height: 1.2, color: BinaColors.ink,
  );
  static TextStyle get headlineMd => GoogleFonts.readexPro(
    fontSize: _scaled(22), fontWeight: FontWeight.w500, height: 1.25, color: BinaColors.ink,
  );
  static TextStyle get headlineSm => GoogleFonts.readexPro(
    fontSize: _scaled(20), fontWeight: FontWeight.w500, height: 1.3, color: BinaColors.ink,
  );

  // Title — Readex (lg) / Inter (md, sm)
  static TextStyle get titleLg => GoogleFonts.readexPro(
    fontSize: _scaled(18), fontWeight: FontWeight.w500, height: 1.3, color: BinaColors.ink,
  );
  static TextStyle get titleMd => GoogleFonts.inter(
    fontSize: _scaled(16), fontWeight: FontWeight.w500, height: 1.4, color: BinaColors.ink,
  );
  static TextStyle get titleSm => GoogleFonts.inter(
    fontSize: _scaled(14), fontWeight: FontWeight.w500, height: 1.4, color: BinaColors.ink,
  );

  // Body — Inter 400
  static TextStyle get bodyLg => GoogleFonts.inter(
    fontSize: _scaled(16), fontWeight: FontWeight.w400, height: 1.55, color: BinaColors.ink,
  );
  static TextStyle get bodyMd => GoogleFonts.inter(
    fontSize: _scaled(14), fontWeight: FontWeight.w400, height: 1.55, color: BinaColors.ink,
  );
  static TextStyle get bodySm => GoogleFonts.inter(
    fontSize: _scaled(12), fontWeight: FontWeight.w400, height: 1.45, color: BinaColors.ink2,
  );

  // Label — Inter 500
  static TextStyle get labelLg => GoogleFonts.inter(
    fontSize: _scaled(14), fontWeight: FontWeight.w500, height: 1.2, color: BinaColors.ink2,
  );
  static TextStyle get labelMd => GoogleFonts.inter(
    fontSize: _scaled(12), fontWeight: FontWeight.w500, height: 1.2, color: BinaColors.ink2,
  );
  static TextStyle get labelSm => GoogleFonts.inter(
    fontSize: _scaled(11), fontWeight: FontWeight.w500, height: 1.2, color: BinaColors.ink2,
  );

  // Overline — Inter 600 + tracking
  static TextStyle get overline => GoogleFonts.inter(
    fontSize: _scaled(11), fontWeight: FontWeight.w600, height: 1.3,
    letterSpacing: 0.08 * 11, color: BinaColors.ink3,
  );
}

// ╔══════════════════════════════════════════════════════════════╗
// ║ MOTION                                                       ║
// ╚══════════════════════════════════════════════════════════════╝
class BinaMotion {
  BinaMotion._();

  static const Duration d1 = Duration(milliseconds: 120);
  static const Duration d2 = Duration(milliseconds: 200);
  static const Duration d3 = Duration(milliseconds: 320);
  static const Duration d4 = Duration(milliseconds: 480);

  static const Curve easeOut    = Cubic(0.2, 0.7, 0.2, 1.0);
  static const Curve easeInOut  = Cubic(0.65, 0.0, 0.35, 1.0);
}
