import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart' hide Orientation;

import '/app_constants.dart';
import '/app_state.dart';
import '/bina_design/bina_design.dart';
import '/services/gyro_controller_service.dart';

class CalibrationWidget extends StatefulWidget {
  const CalibrationWidget({
    super.key,
    required this.familyMemberId,
    this.familyMemberName,
  });

  static String routeName = 'Calibration';
  static String routePath = 'calibration';

  final String familyMemberId;
  final String? familyMemberName;

  @override
  State<CalibrationWidget> createState() => _CalibrationWidgetState();
}

class _CalibrationWidgetState extends State<CalibrationWidget> {
  static const int _sampleCount = 20;
  static const Duration _sampleInterval = Duration(milliseconds: 100);

  final List<Orientation> _regions = Orientation.values;
  int _currentIndex = 0;
  bool _isSampling = false;
  double _progress = 0;
  final Set<Orientation> _saved = {};

  Orientation get _region => _regions[_currentIndex];
  bool get _isLast => _currentIndex >= _regions.length - 1;

  Future<void> _sampleAndSave() async {
    if (!AppState().cameraConnection.isCameraConnected()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Camera disconnected — reconnect to continue calibrating.'),
        ),
      );
      return;
    }

    setState(() {
      _isSampling = true;
      _progress = 0;
    });

    final pitches = <int>[];
    final rolls = <int>[];
    try {
      for (var i = 0; i < _sampleCount; i++) {
        final o =
            await GyroControllerService.instance.readOrientationInts();
        if (o.pitch != null) pitches.add(o.pitch!);
        if (o.roll != null) rolls.add(o.roll!);
        if (!mounted) return;
        setState(() => _progress = (i + 1) / _sampleCount);
        if (i < _sampleCount - 1) await Future.delayed(_sampleInterval);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gyro read failed: $e')),
        );
      }
    }

    if (!mounted) return;
    setState(() => _isSampling = false);

    if (pitches.isEmpty || rolls.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No gyro readings — is the camera connected?')),
      );
      return;
    }

    final avgPitch = _circularMean(pitches);
    final avgRoll = _circularMean(rolls);
    try {
      await AppState().saveCalibrationPoint(
        familyMemberId: widget.familyMemberId,
        region: _region,
        avgPitch: avgPitch,
        avgRoll: avgRoll,
        sampleCount: math.min(pitches.length, rolls.length),
      );
      _saved.add(_region);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Save failed: $e')),
        );
      }
      return;
    }

    _advance();
  }

  void _skipRegion() {
    if (_isSampling) return;
    _advance();
  }

  Future<void> _skipAll() async {
    if (_isSampling) return;
    await _finish();
  }

  Future<void> _finish() async {
    // Reload so the estimator picks up whatever was calibrated this session.
    await AppState().loadMemberCalibration(widget.familyMemberId);
    if (!mounted) return;
    Navigator.of(context).pop();
  }

  void _advance() {
    if (_isLast) {
      _finish();
      return;
    }
    setState(() {
      _currentIndex += 1;
      _progress = 0;
    });
  }

  /// Circular mean handles wraparound at ±180 correctly. A naive arithmetic
  /// mean over samples straddling the discontinuity (e.g. some at 178, some
  /// at -179) would collapse to ~0, hiding the true orientation.
  static int _circularMean(List<int> degrees) {
    double sumX = 0;
    double sumY = 0;
    for (final d in degrees) {
      final rad = d * math.pi / 180;
      sumX += math.cos(rad);
      sumY += math.sin(rad);
    }
    final meanRad = math.atan2(sumY, sumX);
    return (meanRad * 180 / math.pi).round();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BinaColors.surfaceAlt,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildProgressStrip(),
            Expanded(child: _buildRegionCard()),
            _buildBottomBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 16, 8),
      child: Row(
        children: [
          BinaIconButton(
            icon: Icons.chevron_left_rounded,
            onPressed: _isSampling ? null : _skipAll,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              widget.familyMemberName != null
                  ? 'Calibrate — ${widget.familyMemberName}'
                  : 'Calibrate mouth orientation',
              style: BinaType.titleLg,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Text(
            '${_currentIndex + 1} / ${_regions.length}',
            style: BinaType.bodySm.copyWith(color: BinaColors.ink3),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressStrip() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        children: List.generate(_regions.length, (i) {
          final region = _regions[i];
          final isCurrent = i == _currentIndex;
          final isSaved = _saved.contains(region);
          final color = isCurrent
              ? BinaColors.primary
              : isSaved
                  ? BinaColors.success
                  : BinaColors.line;
          return Expanded(
            child: Container(
              height: 4,
              margin: const EdgeInsets.symmetric(horizontal: 2),
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildRegionCard() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
          decoration: BoxDecoration(
            color: BinaColors.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: BinaColors.line),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _region.name,
                style: BinaType.displayLg.copyWith(
                  color: BinaColors.primary,
                  fontSize: 48,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _region.detailed,
                style: BinaType.titleMd,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              Text(
                'Point the camera at this region of the mouth and hold steady, then tap Sample. We\'ll take $_sampleCount readings over ${(_sampleCount * _sampleInterval.inMilliseconds / 1000).toStringAsFixed(1)} seconds.',
                style: BinaType.bodyMd.copyWith(color: BinaColors.ink2),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 28),
              BinaButton(
                label: _isSampling ? 'Sampling…' : 'Sample',
                icon: _isSampling ? null : Icons.center_focus_strong_rounded,
                onPressed: _isSampling ? null : _sampleAndSave,
                variant: BinaButtonVariant.primary,
                size: BinaButtonSize.lg,
                fullWidth: true,
                enabled: !_isSampling,
              ),
              if (_isSampling) ...[
                const SizedBox(height: 20),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: _progress,
                    minHeight: 6,
                    backgroundColor: BinaColors.surfaceSunken,
                    valueColor: AlwaysStoppedAnimation(BinaColors.primary),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
      child: Row(
        children: [
          Expanded(
            child: BinaButton(
              label: 'Skip region',
              onPressed: _isSampling ? null : _skipRegion,
              variant: BinaButtonVariant.secondary,
              size: BinaButtonSize.md,
              fullWidth: true,
              enabled: !_isSampling,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: BinaButton(
              label: 'Skip all',
              onPressed: _isSampling ? null : _skipAll,
              variant: BinaButtonVariant.ghost,
              size: BinaButtonSize.md,
              fullWidth: true,
              enabled: !_isSampling,
            ),
          ),
        ],
      ),
    );
  }
}
