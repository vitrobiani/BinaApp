// bina_floating_nav.dart
//
// Floating pill-shaped bottom navigation bar for Bina.
// Features a raised FAB-style scan button in the center.

import 'package:flutter/material.dart';
import '/index.dart';
import '/app_core/app_util.dart';
import 'bina_design_tokens.dart';

enum BinaNavTab { home, family, scan, chat, profile }

class BinaFloatingNav extends StatelessWidget {
  const BinaFloatingNav({
    super.key,
    required this.currentTab,
    this.onTabChanged,
  });

  final BinaNavTab currentTab;
  final ValueChanged<BinaNavTab>? onTabChanged;

  void _navigateTo(BuildContext context, BinaNavTab tab) {
    if (onTabChanged != null) {
      onTabChanged!(tab);
      return;
    }

    // Default navigation behavior
    final String routeName;
    switch (tab) {
      case BinaNavTab.home:
        routeName = MainHomeWidget.routeName;
      case BinaNavTab.family:
        routeName = FamilyWidget.routeName;
      case BinaNavTab.scan:
        routeName = MainDIagnosticsWidget.routeName;
      case BinaNavTab.chat:
        routeName = ChatHistoryWidget.routeName;
      case BinaNavTab.profile:
        routeName = MainProfilePageWidget.routeName;
    }

    context.pushNamed(
      routeName,
      extra: <String, dynamic>{
        kTransitionInfoKey: const TransitionInfo(
          hasTransition: true,
          transitionType: PageTransitionType.fade,
          duration: Duration(milliseconds: 0),
        ),
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Account for device safe area (e.g., iPhone home indicator)
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    final bottomOffset = bottomPadding > 0 ? bottomPadding + 8 : 22.0;

    return Positioned(
      left: 12,
      right: 12,
      bottom: bottomOffset,
      child: Container(
        height: 70,
        decoration: BoxDecoration(
          color: BinaColors.surface,
          borderRadius: BorderRadius.circular(BinaRadius.xl),
          border: Border.all(color: BinaColors.line, width: 1),
          boxShadow: BinaElevation.sh3,
        ),
        child: Row(
          children: [
            // Home
            Expanded(
              child: _NavItem(
                icon: Icons.home_rounded,
                label: 'Home',
                isActive: currentTab == BinaNavTab.home,
                onTap: () => _navigateTo(context, BinaNavTab.home),
              ),
            ),
            // Family
            Expanded(
              child: _NavItem(
                icon: Icons.groups_rounded,
                label: 'Family',
                isActive: currentTab == BinaNavTab.family,
                onTap: () => _navigateTo(context, BinaNavTab.family),
              ),
            ),
            // Scan FAB (center)
            SizedBox(
              width: 84,
              child: Center(
                child: _ScanFab(
                  onTap: () => _navigateTo(context, BinaNavTab.scan),
                ),
              ),
            ),
            // Chat
            Expanded(
              child: _NavItem(
                icon: Icons.chat_bubble_outline_rounded,
                label: 'Chat',
                isActive: currentTab == BinaNavTab.chat,
                onTap: () => _navigateTo(context, BinaNavTab.chat),
              ),
            ),
            // Profile
            Expanded(
              child: _NavItem(
                icon: Icons.account_circle_outlined,
                label: 'Profile',
                isActive: currentTab == BinaNavTab.profile,
                onTap: () => _navigateTo(context, BinaNavTab.profile),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 22,
            color: isActive ? BinaColors.primary : BinaColors.ink3,
          ),
          const SizedBox(height: 3),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: isActive ? BinaColors.primary : BinaColors.ink3,
            ),
          ),
        ],
      ),
    );
  }
}

class _ScanFab extends StatefulWidget {
  const _ScanFab({required this.onTap});

  final VoidCallback onTap;

  @override
  State<_ScanFab> createState() => _ScanFabState();
}

class _ScanFabState extends State<_ScanFab> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: widget.onTap,
      child: Transform.translate(
        offset: const Offset(0, -18),
        child: AnimatedContainer(
          duration: BinaMotion.d1,
          width: 58,
          height: 58,
          transform: _isPressed
              ? (Matrix4.identity()..scale(0.95))
              : Matrix4.identity(),
          transformAlignment: Alignment.center,
          decoration: BoxDecoration(
            gradient: BinaColors.gradHero,
            shape: BoxShape.circle,
            border: Border.all(color: BinaColors.surface, width: 4),
            boxShadow: BinaElevation.shHero,
          ),
          child: const Icon(
            Icons.camera_alt_rounded,
            color: Colors.white,
            size: 26,
          ),
        ),
      ),
    );
  }
}

/// A scaffold wrapper that includes the floating bottom nav.
/// Use this instead of Scaffold for main navigation screens.
class BinaNavScaffold extends StatelessWidget {
  const BinaNavScaffold({
    super.key,
    required this.currentTab,
    required this.body,
    this.backgroundColor,
    this.onTabChanged,
  });

  final BinaNavTab currentTab;
  final Widget body;
  final Color? backgroundColor;
  final ValueChanged<BinaNavTab>? onTabChanged;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor ?? BinaColors.surfaceAlt,
      body: Stack(
        children: [
          // Main content with bottom padding for nav
          Positioned.fill(
            child: body,
          ),
          // Floating nav
          BinaFloatingNav(
            currentTab: currentTab,
            onTabChanged: onTabChanged,
          ),
        ],
      ),
    );
  }
}
