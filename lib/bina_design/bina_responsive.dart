// bina_responsive.dart
//
// Responsive utilities for the Bina design system.
// Provides breakpoints and layout helpers for adaptive UI.
//
// Breakpoints (based on container width):
//   phone   : < 720   → bottom nav, single column
//   tablet  : 720–1099 → icon side-rail, roomy centered column, 2-up where it fits
//   desktop : ≥ 1100  → labelled side-rail, master–detail + multi-column dashboard

import 'package:flutter/material.dart';
import 'bina_design_tokens.dart';

// ╔══════════════════════════════════════════════════════════════╗
// ║ BREAKPOINTS                                                   ║
// ╚══════════════════════════════════════════════════════════════╝

enum BinaBreakpoint { phone, tablet, desktop }

class BinaBreakpoints {
  BinaBreakpoints._();

  /// Phone breakpoint: < 720px
  static const double phone = 720;

  /// Tablet breakpoint: 720–1099px
  static const double tablet = 1100;

  /// Get current breakpoint from width
  static BinaBreakpoint of(double width) {
    if (width < phone) return BinaBreakpoint.phone;
    if (width < tablet) return BinaBreakpoint.tablet;
    return BinaBreakpoint.desktop;
  }

  /// Get breakpoint from BuildContext
  static BinaBreakpoint fromContext(BuildContext context) {
    return of(MediaQuery.of(context).size.width);
  }
}

// ╔══════════════════════════════════════════════════════════════╗
// ║ LAYOUT CONSTANTS                                              ║
// ╚══════════════════════════════════════════════════════════════╝

class BinaLayout {
  BinaLayout._();

  /// Maximum content width on wide screens
  static const double maxContentWidth = 1200;

  /// Side rail width (desktop with labels)
  static const double sideRailWidth = 236;

  /// Side rail width (tablet, icons only)
  static const double sideRailCompactWidth = 80;

  /// Bottom nav height
  static const double bottomNavHeight = 80;

  /// Page padding for different breakpoints
  static double pagePadding(BinaBreakpoint bp) {
    switch (bp) {
      case BinaBreakpoint.phone:
        return BinaSpace.s4; // 16px
      case BinaBreakpoint.tablet:
        return BinaSpace.s6; // 24px
      case BinaBreakpoint.desktop:
        return BinaSpace.s7; // 32px
    }
  }

  /// Page padding from context
  static double pagePaddingFromContext(BuildContext context) {
    return pagePadding(BinaBreakpoints.fromContext(context));
  }

  /// Get side rail width based on breakpoint
  static double sideRailWidthFor(BinaBreakpoint bp) {
    switch (bp) {
      case BinaBreakpoint.phone:
        return 0; // No side rail on phone
      case BinaBreakpoint.tablet:
        return sideRailCompactWidth;
      case BinaBreakpoint.desktop:
        return sideRailWidth;
    }
  }
}

// ╔══════════════════════════════════════════════════════════════╗
// ║ RESPONSIVE BUILDER WIDGET                                     ║
// ╚══════════════════════════════════════════════════════════════╝

/// A widget that builds different layouts based on screen size.
///
/// Example:
/// ```dart
/// BinaResponsive(
///   phone: (context) => PhoneLayout(),
///   tablet: (context) => TabletLayout(),
///   desktop: (context) => DesktopLayout(),
/// )
/// ```
class BinaResponsive extends StatelessWidget {
  const BinaResponsive({
    super.key,
    required this.phone,
    this.tablet,
    this.desktop,
  });

  /// Builder for phone layout (< 720px)
  final Widget Function(BuildContext context) phone;

  /// Builder for tablet layout (720–1099px). Falls back to phone if not provided.
  final Widget Function(BuildContext context)? tablet;

  /// Builder for desktop layout (≥ 1100px). Falls back to tablet, then phone if not provided.
  final Widget Function(BuildContext context)? desktop;

  @override
  Widget build(BuildContext context) {
    final bp = BinaBreakpoints.fromContext(context);

    switch (bp) {
      case BinaBreakpoint.desktop:
        return (desktop ?? tablet ?? phone)(context);
      case BinaBreakpoint.tablet:
        return (tablet ?? phone)(context);
      case BinaBreakpoint.phone:
        return phone(context);
    }
  }
}

/// A widget that provides breakpoint info to its children via InheritedWidget.
class BinaResponsiveScope extends StatelessWidget {
  const BinaResponsiveScope({
    super.key,
    required this.child,
  });

  final Widget child;

  static BinaBreakpoint of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<_BinaResponsiveScopeData>();
    return scope?.breakpoint ?? BinaBreakpoints.fromContext(context);
  }

  @override
  Widget build(BuildContext context) {
    return _BinaResponsiveScopeData(
      breakpoint: BinaBreakpoints.fromContext(context),
      child: child,
    );
  }
}

class _BinaResponsiveScopeData extends InheritedWidget {
  const _BinaResponsiveScopeData({
    required this.breakpoint,
    required super.child,
  });

  final BinaBreakpoint breakpoint;

  @override
  bool updateShouldNotify(_BinaResponsiveScopeData oldWidget) {
    return breakpoint != oldWidget.breakpoint;
  }
}

// ╔══════════════════════════════════════════════════════════════╗
// ║ RESPONSIVE EXTENSIONS                                         ║
// ╚══════════════════════════════════════════════════════════════╝

extension BinaResponsiveContext on BuildContext {
  /// Get the current breakpoint
  BinaBreakpoint get breakpoint => BinaBreakpoints.fromContext(this);

  /// Check if current layout is phone
  bool get isPhone => breakpoint == BinaBreakpoint.phone;

  /// Check if current layout is tablet
  bool get isTablet => breakpoint == BinaBreakpoint.tablet;

  /// Check if current layout is desktop
  bool get isDesktop => breakpoint == BinaBreakpoint.desktop;

  /// Check if current layout is wide (tablet or desktop)
  bool get isWide => breakpoint != BinaBreakpoint.phone;

  /// Get appropriate page padding
  double get pagePadding => BinaLayout.pagePaddingFromContext(this);
}

// ╔══════════════════════════════════════════════════════════════╗
// ║ WIDE PAGE WRAPPER                                             ║
// ╚══════════════════════════════════════════════════════════════╝

/// A wrapper widget that constrains content width and adds appropriate padding.
/// Used for consistent page layouts on wide screens.
class BinaWidePage extends StatelessWidget {
  const BinaWidePage({
    super.key,
    required this.child,
    this.maxWidth = BinaLayout.maxContentWidth,
    this.padding,
  });

  final Widget child;
  final double maxWidth;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final bp = BinaBreakpoints.fromContext(context);
    final defaultPadding = BinaLayout.pagePadding(bp);

    return Padding(
      padding: padding ?? EdgeInsets.all(defaultPadding),
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxWidth),
          child: child,
        ),
      ),
    );
  }
}

// ╔══════════════════════════════════════════════════════════════╗
// ║ SECTION CARD FOR WIDE LAYOUTS                                 ║
// ╚══════════════════════════════════════════════════════════════╝

/// A card widget styled for wide screen sections.
class BinaSectionCard extends StatelessWidget {
  const BinaSectionCard({
    super.key,
    required this.child,
    this.padding,
    this.borderRadius,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final BorderRadius? borderRadius;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: BinaColors.surface,
        borderRadius: borderRadius ?? BorderRadius.circular(BinaRadius.lg),
        border: Border.all(color: BinaColors.line),
        boxShadow: BinaElevation.sh2,
      ),
      padding: padding ?? EdgeInsets.all(BinaSpace.s5),
      child: child,
    );
  }
}

// ╔══════════════════════════════════════════════════════════════╗
// ║ MASTER-DETAIL LAYOUT                                          ║
// ╚══════════════════════════════════════════════════════════════╝

/// A two-pane master-detail layout for tablet/desktop screens.
class BinaMasterDetail extends StatelessWidget {
  const BinaMasterDetail({
    super.key,
    required this.master,
    required this.detail,
    this.masterWidth,
  });

  final Widget master;
  final Widget detail;
  final double? masterWidth;

  @override
  Widget build(BuildContext context) {
    final bp = BinaBreakpoints.fromContext(context);
    final listWidth = masterWidth ?? (bp == BinaBreakpoint.desktop ? 380 : 312);

    return Row(
      children: [
        SizedBox(
          width: listWidth,
          child: Container(
            decoration: BoxDecoration(
              border: Border(
                right: BorderSide(color: BinaColors.line),
              ),
            ),
            child: master,
          ),
        ),
        Expanded(child: detail),
      ],
    );
  }
}
