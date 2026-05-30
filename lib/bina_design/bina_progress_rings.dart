// bina_progress_rings.dart
//
// Circular progress rings with percentage display in center.
// Matches the Claude design's hero progress indicator.

import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'bina_design_tokens.dart';

class BinaProgressRings extends StatelessWidget {
  const BinaProgressRings({
    super.key,
    required this.percentage,
    this.size = 132,
    this.showLabel = true,
  });

  /// Progress percentage (0-100)
  final double percentage;

  /// Overall size of the rings
  final double size;

  /// Whether to show the percentage label in the center
  final bool showLabel;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // SVG-like rings using CustomPaint
          CustomPaint(
            size: Size(size, size),
            painter: _RingsPainter(
              percentage: percentage,
              outerRadius: size * 0.42, // ~56 for 132px
              innerRadius: size * 0.29, // ~38 for 132px
              strokeWidth: size * 0.083, // ~11 for 132px
            ),
          ),
          // Center label
          if (showLabel)
            Text(
              '${percentage.round()}%',
              style: BinaType.headlineLg.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                letterSpacing: -0.5,
              ),
            ),
        ],
      ),
    );
  }
}

class _RingsPainter extends CustomPainter {
  _RingsPainter({
    required this.percentage,
    required this.outerRadius,
    required this.innerRadius,
    required this.strokeWidth,
  });

  final double percentage;
  final double outerRadius;
  final double innerRadius;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    // Background track colors
    final trackPaint = Paint()
      ..color = Colors.white.withOpacity(0.22)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    // Outer ring fill
    final outerFillPaint = Paint()
      ..color = Colors.white.withOpacity(0.95)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    // Inner ring fill (slightly dimmer)
    final innerFillPaint = Paint()
      ..color = Colors.white.withOpacity(0.55)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    // Calculate sweep angles
    final outerSweep = (percentage / 100) * 2 * math.pi;
    final innerPercentage = (percentage - 10).clamp(0, 100);
    final innerSweep = (innerPercentage / 100) * 2 * math.pi;

    // Start angle at top (-90 degrees = -π/2)
    const startAngle = -math.pi / 2;

    // Draw outer ring
    // Background track
    canvas.drawCircle(center, outerRadius, trackPaint);
    // Fill arc
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: outerRadius),
      startAngle,
      outerSweep,
      false,
      outerFillPaint,
    );

    // Draw inner ring
    // Background track
    canvas.drawCircle(center, innerRadius, trackPaint);
    // Fill arc
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: innerRadius),
      startAngle,
      innerSweep,
      false,
      innerFillPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _RingsPainter oldDelegate) {
    return percentage != oldDelegate.percentage ||
        outerRadius != oldDelegate.outerRadius ||
        innerRadius != oldDelegate.innerRadius;
  }
}

// Animated version of progress rings
class BinaAnimatedProgressRings extends StatefulWidget {
  const BinaAnimatedProgressRings({
    super.key,
    required this.percentage,
    this.size = 132,
    this.showLabel = true,
    this.duration = const Duration(milliseconds: 800),
    this.curve = Curves.easeOutCubic,
  });

  final double percentage;
  final double size;
  final bool showLabel;
  final Duration duration;
  final Curve curve;

  @override
  State<BinaAnimatedProgressRings> createState() => _BinaAnimatedProgressRingsState();
}

class _BinaAnimatedProgressRingsState extends State<BinaAnimatedProgressRings>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  double _previousPercentage = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );
    _animation = Tween<double>(
      begin: 0,
      end: widget.percentage,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: widget.curve,
    ));
    _controller.forward();
  }

  @override
  void didUpdateWidget(BinaAnimatedProgressRings oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.percentage != widget.percentage) {
      _previousPercentage = _animation.value;
      _animation = Tween<double>(
        begin: _previousPercentage,
        end: widget.percentage,
      ).animate(CurvedAnimation(
        parent: _controller,
        curve: widget.curve,
      ));
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return BinaProgressRings(
          percentage: _animation.value,
          size: widget.size,
          showLabel: widget.showLabel,
        );
      },
    );
  }
}
