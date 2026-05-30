// bina_components.dart
//
// Shared UI components for the Bina design system.
// All components use BinaColors, BinaSpace, BinaRadius, etc. from design tokens.

import 'package:flutter/material.dart';
import 'bina_design_tokens.dart';

// ╔══════════════════════════════════════════════════════════════╗
// ║ BINA BUTTON                                                  ║
// ╚══════════════════════════════════════════════════════════════╝

enum BinaButtonVariant { primary, secondary, ghost, coral, danger, glass, glassOutline }
enum BinaButtonSize { sm, md, lg }

class BinaButton extends StatefulWidget {
  const BinaButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = BinaButtonVariant.primary,
    this.size = BinaButtonSize.md,
    this.icon,
    this.fullWidth = false,
    this.enabled = true,
  });

  final String label;
  final VoidCallback? onPressed;
  final BinaButtonVariant variant;
  final BinaButtonSize size;
  final IconData? icon;
  final bool fullWidth;
  final bool enabled;

  @override
  State<BinaButton> createState() => _BinaButtonState();
}

class _BinaButtonState extends State<BinaButton> {
  bool _isPressed = false;

  double get _height {
    switch (widget.size) {
      case BinaButtonSize.sm: return 36;
      case BinaButtonSize.md: return 48;
      case BinaButtonSize.lg: return 56;
    }
  }

  EdgeInsets get _padding {
    switch (widget.size) {
      case BinaButtonSize.sm: return const EdgeInsets.symmetric(horizontal: 14);
      case BinaButtonSize.md: return const EdgeInsets.symmetric(horizontal: 20);
      case BinaButtonSize.lg: return const EdgeInsets.symmetric(horizontal: 24);
    }
  }

  double get _fontSize {
    switch (widget.size) {
      case BinaButtonSize.sm: return 13;
      case BinaButtonSize.md: return 14;
      case BinaButtonSize.lg: return 15;
    }
  }

  Color get _backgroundColor {
    switch (widget.variant) {
      case BinaButtonVariant.primary:      return BinaColors.primary;
      case BinaButtonVariant.secondary:    return BinaColors.primary100;
      case BinaButtonVariant.ghost:        return Colors.transparent;
      case BinaButtonVariant.coral:        return BinaColors.coral;
      case BinaButtonVariant.danger:       return BinaColors.error;
      case BinaButtonVariant.glass:        return Colors.white.withOpacity(0.96);
      case BinaButtonVariant.glassOutline: return Colors.white.withOpacity(0.16);
    }
  }

  Color get _foregroundColor {
    switch (widget.variant) {
      case BinaButtonVariant.primary:      return Colors.white;
      case BinaButtonVariant.secondary:    return BinaColors.primary700;
      case BinaButtonVariant.ghost:        return BinaColors.primary;
      case BinaButtonVariant.coral:        return Colors.white;
      case BinaButtonVariant.danger:       return Colors.white;
      case BinaButtonVariant.glass:        return BinaColors.primary700;
      case BinaButtonVariant.glassOutline: return Colors.white;
    }
  }

  Border? get _border {
    if (widget.variant == BinaButtonVariant.ghost) {
      return Border.all(color: BinaColors.line, width: 1);
    }
    if (widget.variant == BinaButtonVariant.glassOutline) {
      return Border.all(color: Colors.white.withOpacity(0.5), width: 1);
    }
    return null;
  }

  List<BoxShadow>? get _shadow {
    if (widget.variant == BinaButtonVariant.ghost ||
        widget.variant == BinaButtonVariant.secondary ||
        widget.variant == BinaButtonVariant.glassOutline) {
      return null;
    }
    return BinaElevation.sh2;
  }

  @override
  Widget build(BuildContext context) {
    final isEnabled = widget.enabled && widget.onPressed != null;

    return GestureDetector(
      onTapDown: isEnabled ? (_) => setState(() => _isPressed = true) : null,
      onTapUp: isEnabled ? (_) => setState(() => _isPressed = false) : null,
      onTapCancel: isEnabled ? () => setState(() => _isPressed = false) : null,
      onTap: isEnabled ? widget.onPressed : null,
      child: AnimatedContainer(
        duration: BinaMotion.d1,
        height: _height,
        padding: _padding,
        transform: _isPressed
            ? (Matrix4.identity()..translate(0.0, 1.0)..scale(0.99))
            : Matrix4.identity(),
        transformAlignment: Alignment.center,
        decoration: BoxDecoration(
          color: isEnabled ? _backgroundColor : _backgroundColor.withOpacity(0.45),
          borderRadius: BorderRadius.circular(BinaRadius.pill),
          border: _border,
          boxShadow: _isPressed ? BinaElevation.sh1 : _shadow,
        ),
        child: Row(
          mainAxisSize: widget.fullWidth ? MainAxisSize.max : MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (widget.icon != null) ...[
              Icon(widget.icon, size: _fontSize + 4, color: _foregroundColor),
              const SizedBox(width: 8),
            ],
            Text(
              widget.label,
              style: TextStyle(
                fontSize: _fontSize,
                fontWeight: FontWeight.w500,
                color: isEnabled ? _foregroundColor : _foregroundColor.withOpacity(0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ╔══════════════════════════════════════════════════════════════╗
// ║ BINA ICON BUTTON                                             ║
// ╚══════════════════════════════════════════════════════════════╝

class BinaIconButton extends StatefulWidget {
  const BinaIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.size = 44,
    this.backgroundColor,
    this.iconColor,
    this.showBorder = true,
    this.badge,
  });

  final IconData icon;
  final VoidCallback? onPressed;
  final double size;
  final Color? backgroundColor;
  final Color? iconColor;
  final bool showBorder;
  final Widget? badge;

  @override
  State<BinaIconButton> createState() => _BinaIconButtonState();
}

class _BinaIconButtonState extends State<BinaIconButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: widget.onPressed,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          AnimatedContainer(
            duration: BinaMotion.d1,
            width: widget.size,
            height: widget.size,
            transform: _isPressed
                ? (Matrix4.identity()..scale(0.95))
                : Matrix4.identity(),
            transformAlignment: Alignment.center,
            decoration: BoxDecoration(
              color: widget.backgroundColor ?? BinaColors.surface,
              shape: BoxShape.circle,
              border: widget.showBorder
                  ? Border.all(color: BinaColors.line, width: 1)
                  : null,
              boxShadow: BinaElevation.sh1,
            ),
            child: Icon(
              widget.icon,
              size: widget.size * 0.45,
              color: widget.iconColor ?? BinaColors.ink2,
            ),
          ),
          if (widget.badge != null)
            Positioned(
              top: 6,
              right: 6,
              child: widget.badge!,
            ),
        ],
      ),
    );
  }
}

// ╔══════════════════════════════════════════════════════════════╗
// ║ BINA AVATAR                                                  ║
// ╚══════════════════════════════════════════════════════════════╝

enum BinaAvatarTone { blue, coral, aqua, ink }

class BinaAvatar extends StatelessWidget {
  const BinaAvatar({
    super.key,
    required this.name,
    this.size = 44,
    this.tone = BinaAvatarTone.blue,
    this.imageUrl,
  });

  final String name;
  final double size;
  final BinaAvatarTone tone;
  final String? imageUrl;

  Color get _backgroundColor {
    switch (tone) {
      case BinaAvatarTone.blue:  return BinaColors.primary100;
      case BinaAvatarTone.coral: return BinaColors.coral100;
      case BinaAvatarTone.aqua:  return BinaColors.aqua.withOpacity(0.2);
      case BinaAvatarTone.ink:   return BinaColors.ink;
    }
  }

  Color get _foregroundColor {
    switch (tone) {
      case BinaAvatarTone.blue:  return BinaColors.primary700;
      case BinaAvatarTone.coral: return BinaColors.coral700;
      case BinaAvatarTone.aqua:  return BinaColors.primary700;
      case BinaAvatarTone.ink:   return Colors.white;
    }
  }

  String get _initials {
    final parts = name.trim().split(' ');
    if (parts.isEmpty) return '';
    if (parts.length == 1) {
      return parts[0].substring(0, parts[0].length.clamp(0, 2)).toUpperCase();
    }
    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    if (imageUrl != null && imageUrl!.isNotEmpty) {
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          image: DecorationImage(
            image: NetworkImage(imageUrl!),
            fit: BoxFit.cover,
          ),
        ),
      );
    }

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: _backgroundColor,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          _initials,
          style: TextStyle(
            color: _foregroundColor,
            fontWeight: FontWeight.w600,
            fontSize: size * 0.36,
          ),
        ),
      ),
    );
  }
}

// ╔══════════════════════════════════════════════════════════════╗
// ║ DIAGNOSIS CHIP                                               ║
// ╚══════════════════════════════════════════════════════════════╝

enum DxChipKind { good, plaque, cavity, mixed, due }

class DxChip extends StatelessWidget {
  const DxChip({
    super.key,
    required this.kind,
    this.size = DxChipSize.md,
  });

  final DxChipKind kind;
  final DxChipSize size;

  Color get _backgroundColor {
    switch (kind) {
      case DxChipKind.good:   return BinaColors.dxGood100;
      case DxChipKind.plaque: return BinaColors.dxPlaque100;
      case DxChipKind.cavity: return BinaColors.dxCavity100;
      case DxChipKind.mixed:  return BinaColors.dxMixed100;
      case DxChipKind.due:    return BinaColors.surfaceSunken;
    }
  }

  Color get _foregroundColor {
    switch (kind) {
      case DxChipKind.good:   return const Color(0xFF0E6B48);
      case DxChipKind.plaque: return const Color(0xFF7A5A17);
      case DxChipKind.cavity: return const Color(0xFF8A2727);
      case DxChipKind.mixed:  return const Color(0xFF6A2150);
      case DxChipKind.due:    return BinaColors.ink2;
    }
  }

  Color get _dotColor {
    switch (kind) {
      case DxChipKind.good:   return BinaColors.dxGood;
      case DxChipKind.plaque: return BinaColors.dxPlaque;
      case DxChipKind.cavity: return BinaColors.dxCavity;
      case DxChipKind.mixed:  return BinaColors.dxMixed;
      case DxChipKind.due:    return BinaColors.ink3;
    }
  }

  String get _label {
    switch (kind) {
      case DxChipKind.good:   return 'Good';
      case DxChipKind.plaque: return 'Plaque';
      case DxChipKind.cavity: return 'Cavity';
      case DxChipKind.mixed:  return 'Plaque + Cavity';
      case DxChipKind.due:    return 'Scan due';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isSmall = size == DxChipSize.sm;
    final fontSize = isSmall ? 11.0 : 12.0;
    final verticalPadding = isSmall ? 3.0 : 5.0;
    final horizontalPadding = isSmall ? 8.0 : 11.0;
    final dotSize = 7.0;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: horizontalPadding,
        vertical: verticalPadding,
      ),
      decoration: BoxDecoration(
        color: _backgroundColor,
        borderRadius: BorderRadius.circular(BinaRadius.pill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: dotSize,
            height: dotSize,
            decoration: BoxDecoration(
              color: _dotColor,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            _label,
            style: TextStyle(
              color: _foregroundColor,
              fontSize: fontSize,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

enum DxChipSize { sm, md }

// ╔══════════════════════════════════════════════════════════════╗
// ║ BINA CARD                                                    ║
// ╚══════════════════════════════════════════════════════════════╝

class BinaCard extends StatelessWidget {
  const BinaCard({
    super.key,
    required this.child,
    this.padding,
    this.radius,
    this.onTap,
    this.showBorder = true,
    this.showShadow = true,
  });

  final Widget child;
  final EdgeInsets? padding;
  final double? radius;
  final VoidCallback? onTap;
  final bool showBorder;
  final bool showShadow;

  @override
  Widget build(BuildContext context) {
    final card = Container(
      padding: padding ?? const EdgeInsets.all(BinaSpace.s4),
      decoration: BoxDecoration(
        color: BinaColors.surface,
        borderRadius: BorderRadius.circular(radius ?? BinaRadius.md),
        border: showBorder ? Border.all(color: BinaColors.line, width: 1) : null,
        boxShadow: showShadow ? BinaElevation.sh2 : null,
      ),
      child: child,
    );

    if (onTap != null) {
      return GestureDetector(
        onTap: onTap,
        child: card,
      );
    }

    return card;
  }
}

// ╔══════════════════════════════════════════════════════════════╗
// ║ BINA SECTION HEADER                                          ║
// ╚══════════════════════════════════════════════════════════════╝

class BinaSectionHeader extends StatelessWidget {
  const BinaSectionHeader({
    super.key,
    required this.title,
    this.action,
    this.onActionTap,
  });

  final String title;
  final String? action;
  final VoidCallback? onActionTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: BinaSpace.s3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.baseline,
        textBaseline: TextBaseline.alphabetic,
        children: [
          Text(title, style: BinaType.headlineSm),
          if (action != null)
            GestureDetector(
              onTap: onActionTap,
              child: Text(
                action!,
                style: BinaType.labelMd.copyWith(color: BinaColors.primary),
              ),
            ),
        ],
      ),
    );
  }
}

// ╔══════════════════════════════════════════════════════════════╗
// ║ BINA FILTER CHIP                                             ║
// ╚══════════════════════════════════════════════════════════════╝

class BinaFilterChip extends StatelessWidget {
  const BinaFilterChip({
    super.key,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: BinaMotion.d2,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? BinaColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(BinaRadius.pill),
          border: Border.all(
            color: isSelected ? BinaColors.primary : BinaColors.line,
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: BinaType.labelMd.copyWith(
            color: isSelected ? Colors.white : BinaColors.ink2,
          ),
        ),
      ),
    );
  }
}

// ╔══════════════════════════════════════════════════════════════╗
// ║ BINA COUNTER BADGE                                           ║
// ╚══════════════════════════════════════════════════════════════╝

class BinaCounterBadge extends StatelessWidget {
  const BinaCounterBadge({
    super.key,
    required this.count,
    this.color,
  });

  final int count;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final bgColor = color ?? BinaColors.primary;
    final size = count > 9 ? 20.0 : 18.0;

    return Container(
      constraints: BoxConstraints(minWidth: size, minHeight: size),
      padding: const EdgeInsets.symmetric(horizontal: 5),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(BinaRadius.pill),
      ),
      child: Center(
        child: Text(
          count > 99 ? '99+' : '$count',
          style: TextStyle(
            color: Colors.white,
            fontSize: 10,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

// ╔══════════════════════════════════════════════════════════════╗
// ║ BINA DOT BADGE                                               ║
// ╚══════════════════════════════════════════════════════════════╝

class BinaDotBadge extends StatelessWidget {
  const BinaDotBadge({
    super.key,
    this.color,
    this.size = 8,
    this.showBorder = true,
  });

  final Color? color;
  final double size;
  final bool showBorder;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color ?? BinaColors.coral,
        shape: BoxShape.circle,
        border: showBorder
            ? Border.all(color: Colors.white, width: 2)
            : null,
      ),
    );
  }
}

// ╔══════════════════════════════════════════════════════════════╗
// ║ PROGRESS RINGS                                               ║
// ╚══════════════════════════════════════════════════════════════╝

class ProgressRings extends StatelessWidget {
  const ProgressRings({
    super.key,
    required this.percentage,
    this.size = 132,
    this.showLabel = true,
  });

  final double percentage;
  final double size;
  final bool showLabel;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: Size(size, size),
            painter: _RingsPainter(percentage: percentage),
          ),
          if (showLabel)
            Text(
              '${percentage.round()}%',
              style: BinaType.headlineLg.copyWith(
                color: Colors.white,
                letterSpacing: -0.01 * 28,
              ),
            ),
        ],
      ),
    );
  }
}

class _RingsPainter extends CustomPainter {
  _RingsPainter({required this.percentage});

  final double percentage;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final r1 = size.width / 2 - 5.5; // Outer ring
    final r2 = r1 - 18; // Inner ring

    final strokeWidth = 11.0;

    // Background tracks
    final trackPaint = Paint()
      ..color = Colors.white.withOpacity(0.22)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    canvas.drawCircle(center, r1, trackPaint);
    canvas.drawCircle(center, r2, trackPaint);

    // Progress arcs
    final outerPaint = Paint()
      ..color = Colors.white.withOpacity(0.95)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final innerPaint = Paint()
      ..color = Colors.white.withOpacity(0.55)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    // Start from top (-90 degrees)
    const startAngle = -3.14159 / 2;
    final outerSweep = 2 * 3.14159 * (percentage / 100);
    final innerSweep = 2 * 3.14159 * ((percentage - 10).clamp(0, 100) / 100);

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: r1),
      startAngle,
      outerSweep,
      false,
      outerPaint,
    );

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: r2),
      startAngle,
      innerSweep,
      false,
      innerPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _RingsPainter oldDelegate) {
    return oldDelegate.percentage != percentage;
  }
}

// ╔══════════════════════════════════════════════════════════════╗
// ║ BINA LIST ROW                                                ║
// ╚══════════════════════════════════════════════════════════════╝

class BinaListRow extends StatelessWidget {
  const BinaListRow({
    super.key,
    required this.title,
    this.subtitle,
    this.leading,
    this.trailing,
    this.onTap,
    this.showChevron = true,
  });

  final String title;
  final String? subtitle;
  final Widget? leading;
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool showChevron;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: BinaSpace.s3,
          horizontal: BinaSpace.s4,
        ),
        child: Row(
          children: [
            if (leading != null) ...[
              leading!,
              const SizedBox(width: BinaSpace.s3),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: BinaType.titleMd),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(subtitle!, style: BinaType.bodySm),
                  ],
                ],
              ),
            ),
            if (trailing != null) trailing!,
            if (showChevron && onTap != null) ...[
              const SizedBox(width: BinaSpace.s2),
              Icon(
                Icons.chevron_right_rounded,
                color: BinaColors.ink3,
                size: 20,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
