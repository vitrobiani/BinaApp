// bina_sidebar.dart
//
// Desktop/tablet sidebar navigation matching the Claude design.
// Features: Logo, nav items, gradient "Scan now" button, help, theme dots.

import 'package:flutter/material.dart';
import 'bina_design_tokens.dart';

enum BinaSidebarTab { none, home, family, scan, chat, profile }

class BinaSidebar extends StatelessWidget {
  const BinaSidebar({
    super.key,
    this.currentTab = BinaSidebarTab.home,
    this.onTabChanged,
    this.onHelpTap,
  });

  final BinaSidebarTab currentTab;
  final void Function(BinaSidebarTab)? onTabChanged;
  final VoidCallback? onHelpTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 236,
      height: double.infinity,
      decoration: BoxDecoration(
        color: BinaColors.surface,
        border: Border(
          right: BorderSide(color: BinaColors.line),
        ),
      ),
      child: SafeArea(
        right: false,
        bottom: false,
        child: Column(
          children: [
            const SizedBox(height: 12),
          // Logo
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    gradient: BinaColors.gradHero,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Center(
                    child: _ToothIcon(size: 24, color: Colors.white),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Bina',
                  style: BinaType.displaySm.copyWith(
                    fontSize: 28,
                    fontWeight: FontWeight.w600,
                    letterSpacing: -0.5,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          // Nav items
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Column(
              children: [
                _NavItem(
                  icon: Icons.home_outlined,
                  activeIcon: Icons.home_rounded,
                  label: 'Home',
                  isSelected: currentTab == BinaSidebarTab.home,
                  onTap: () => onTabChanged?.call(BinaSidebarTab.home),
                ),
                const SizedBox(height: 4),
                _NavItem(
                  icon: Icons.people_outline_rounded,
                  activeIcon: Icons.people_rounded,
                  label: 'Family',
                  isSelected: currentTab == BinaSidebarTab.family,
                  onTap: () => onTabChanged?.call(BinaSidebarTab.family),
                ),
                const SizedBox(height: 12),
                // Scan button - gradient pill
                _ScanButton(
                  isSelected: currentTab == BinaSidebarTab.scan,
                  onTap: () => onTabChanged?.call(BinaSidebarTab.scan),
                ),
                const SizedBox(height: 12),
                _NavItem(
                  icon: Icons.chat_bubble_outline_rounded,
                  activeIcon: Icons.chat_bubble_rounded,
                  label: 'Chat',
                  isSelected: currentTab == BinaSidebarTab.chat,
                  onTap: () => onTabChanged?.call(BinaSidebarTab.chat),
                ),
                const SizedBox(height: 4),
                _NavItem(
                  icon: Icons.person_outline_rounded,
                  activeIcon: Icons.person_rounded,
                  label: 'Profile',
                  isSelected: currentTab == BinaSidebarTab.profile,
                  onTap: () => onTabChanged?.call(BinaSidebarTab.profile),
                ),
              ],
            ),
          ),
          const Spacer(),
          // Help
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: _NavItem(
              icon: Icons.help_outline_rounded,
              activeIcon: Icons.help_rounded,
              label: 'Help',
              isSelected: false,
              onTap: onHelpTap,
            ),
          ),
          const SizedBox(height: 16),
          // Theme dots
          Padding(
            padding: const EdgeInsets.only(left: 20, bottom: 20),
            child: Align(
              alignment: Alignment.centerLeft,
              child: _ThemeDots(),
            ),
          ),
          ],
        ),
      ),
    );
  }
}

class _NavItem extends StatefulWidget {
  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.isSelected,
    this.onTap,
  });

  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool isSelected;
  final VoidCallback? onTap;

  @override
  State<_NavItem> createState() => _NavItemState();
}

class _NavItemState extends State<_NavItem> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: BinaMotion.d1,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: widget.isSelected
                ? BinaColors.primary100
                : _isHovered
                    ? BinaColors.surfaceSunken
                    : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(
                widget.isSelected ? widget.activeIcon : widget.icon,
                size: 22,
                color: widget.isSelected ? BinaColors.primary : BinaColors.ink2,
              ),
              const SizedBox(width: 12),
              Text(
                widget.label,
                style: BinaType.labelLg.copyWith(
                  color: widget.isSelected ? BinaColors.primary : BinaColors.ink,
                  fontWeight: widget.isSelected ? FontWeight.w600 : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ScanButton extends StatefulWidget {
  const _ScanButton({
    required this.isSelected,
    this.onTap,
  });

  final bool isSelected;
  final VoidCallback? onTap;

  @override
  State<_ScanButton> createState() => _ScanButtonState();
}

class _ScanButtonState extends State<_ScanButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: widget.onTap,
      child: AnimatedContainer(
        duration: BinaMotion.d1,
        transform: _isPressed
            ? (Matrix4.identity()..translate(0.0, 1.0)..scale(0.98))
            : Matrix4.identity(),
        transformAlignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          gradient: BinaColors.gradHero,
          borderRadius: BorderRadius.circular(14),
          boxShadow: BinaElevation.shHero,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.camera_alt_rounded, size: 22, color: Colors.white),
            const SizedBox(width: 10),
            Text(
              'Scan now',
              style: BinaType.labelLg.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ThemeDots extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _ThemeDot(gradient: BinaColors.gradHero),
        const SizedBox(width: 6),
        _ThemeDot(color: const Color(0xFF161A28)),
        const SizedBox(width: 6),
        _ThemeDot(gradient: const LinearGradient(
          colors: [Color(0xFFef8b1a), Color(0xFFf5b774)],
        )),
        const SizedBox(width: 6),
        _ThemeDot(gradient: const LinearGradient(
          colors: [Color(0xFF0099b3), Color(0xFF4dd0e1)],
        )),
        const SizedBox(width: 6),
        _ThemeDot(gradient: const LinearGradient(
          colors: [Color(0xFF0077bb), Color(0xFF33bbee)],
        )),
      ],
    );
  }
}

class _ThemeDot extends StatelessWidget {
  const _ThemeDot({this.color, this.gradient});

  final Color? color;
  final Gradient? gradient;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 20,
      height: 20,
      decoration: BoxDecoration(
        color: color,
        gradient: gradient,
        shape: BoxShape.circle,
        border: Border.all(color: BinaColors.line, width: 1),
      ),
    );
  }
}

// Custom tooth icon widget
class _ToothIcon extends StatelessWidget {
  const _ToothIcon({this.size = 24, this.color});

  final double size;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    // Using a camera icon with tooth symbolism (as per design)
    return Icon(
      Icons.camera_alt_rounded,
      size: size,
      color: color ?? BinaColors.ink,
    );
  }
}

// Export the tooth icon for use elsewhere
class BinaToothIcon extends StatelessWidget {
  const BinaToothIcon({super.key, this.size = 24, this.color});

  final double size;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return _ToothIcon(size: size, color: color);
  }
}
