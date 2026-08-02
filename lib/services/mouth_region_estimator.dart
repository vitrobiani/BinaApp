import 'dart:math' as math;

import '../app_constants.dart';

class CalibrationPoint {
  final Orientation region;
  final int pitch;
  final int roll;

  const CalibrationPoint({
    required this.region,
    required this.pitch,
    required this.roll,
  });
}

class MouthRegionEstimator {
  static const double ambiguityRatio = 1.5;

  static double _wrapDist(int a, int b) {
    final d = (a - b).abs();
    return math.min(d, 360 - d).toDouble();
  }

  static double _distance(int pitch, int roll, CalibrationPoint p) {
    final dp = _wrapDist(pitch, p.pitch);
    final dr = _wrapDist(roll, p.roll);
    return math.sqrt(dp * dp + dr * dr);
  }

  /// Weighted 2-NN over calibration points with wraparound-aware
  /// pitch/roll distance. Returns `null` if no calibration is available.
  /// Otherwise returns either a single region name (e.g. `"URI"`) or a
  /// slash-joined ambiguous pair sorted alphabetically (e.g. `"ULO/URI"`).
  static String? estimate(
    int pitch,
    int roll,
    List<CalibrationPoint> points,
  ) {
    if (points.isEmpty) return null;
    if (points.length == 1) return points.first.region.name;

    final sorted = [...points]..sort(
        (a, b) =>
            _distance(pitch, roll, a).compareTo(_distance(pitch, roll, b)),
      );

    final r1 = sorted[0].region;
    final r2 = sorted[1].region;
    final d1 = _distance(pitch, roll, sorted[0]);
    final d2 = _distance(pitch, roll, sorted[1]);

    if (r1 == r2) return r1.name;
    // If both nearest points sit exactly on the query, ambiguity is real.
    // Only short-circuit to r1 when r1 is on the query but r2 is not.
    if (d2 == 0) {
      final names = [r1.name, r2.name]..sort();
      return '${names[0]}/${names[1]}';
    }
    if (d1 == 0 || d2 >= ambiguityRatio * d1) return r1.name;

    final names = [r1.name, r2.name]..sort();
    return '${names[0]}/${names[1]}';
  }

  /// Given the set of `estimated_region` strings recorded in a session,
  /// returns the [Orientation] values that were never covered. Ambiguous
  /// entries like `"URI/ULO"` count as covering *both* regions.
  static List<Orientation> uncoveredRegions(Iterable<String> estimated) {
    final covered = <String>{};
    for (final s in estimated) {
      for (final part in s.split('/')) {
        covered.add(part);
      }
    }
    return Orientation.values.where((o) => !covered.contains(o.name)).toList();
  }

  /// Fallback calibration used until a family member records their own.
  /// Derived from the legacy hardcoded orientation map: one representative
  /// (pitch, roll) per region. Regions that share a representative (e.g.
  /// URI and ULO both at pitch=0, roll=-45) will honestly resolve to the
  /// ambiguous `"R1/R2"` output until per-member calibration replaces them.
  static const List<CalibrationPoint> defaultCalibration = [
    CalibrationPoint(region: Orientation.UT, pitch: 0, roll: 0),
    CalibrationPoint(region: Orientation.URI, pitch: 0, roll: -45),
    CalibrationPoint(region: Orientation.ULO, pitch: 0, roll: -45),
    CalibrationPoint(region: Orientation.URO, pitch: 0, roll: 45),
    CalibrationPoint(region: Orientation.ULI, pitch: 0, roll: 45),
    CalibrationPoint(region: Orientation.UFI, pitch: -45, roll: 0),
    CalibrationPoint(region: Orientation.UFO, pitch: 45, roll: 0),
    CalibrationPoint(region: Orientation.DRI, pitch: 0, roll: -135),
    CalibrationPoint(region: Orientation.DLO, pitch: 0, roll: -135),
    CalibrationPoint(region: Orientation.DRO, pitch: 0, roll: 135),
    CalibrationPoint(region: Orientation.DLI, pitch: 0, roll: 135),
    CalibrationPoint(region: Orientation.DT, pitch: 0, roll: 180),
    CalibrationPoint(region: Orientation.DFI, pitch: 45, roll: 180),
    CalibrationPoint(region: Orientation.DFO, pitch: -45, roll: 180),
  ];
}
