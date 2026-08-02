import 'package:flutter_test/flutter_test.dart';

import 'package:bina_system/app_constants.dart';
import 'package:bina_system/services/mouth_region_estimator.dart';

void main() {
  group('MouthRegionEstimator.estimate', () {
    test('empty calibration returns null', () {
      expect(MouthRegionEstimator.estimate(0, 0, const []), isNull);
    });

    test('single calibration point returns that region regardless of query',
        () {
      const points = [
        CalibrationPoint(region: Orientation.UT, pitch: 0, roll: 0),
      ];
      expect(MouthRegionEstimator.estimate(0, 0, points), 'UT');
      expect(MouthRegionEstimator.estimate(90, 90, points), 'UT');
    });

    test('exact hit returns single winner even if another region is close', () {
      const points = [
        CalibrationPoint(region: Orientation.UT, pitch: 0, roll: 0),
        CalibrationPoint(region: Orientation.UFO, pitch: 1, roll: 0),
      ];
      expect(MouthRegionEstimator.estimate(0, 0, points), 'UT');
    });

    test('clear winner beyond 1.5x ratio returns single region', () {
      const points = [
        CalibrationPoint(region: Orientation.UT, pitch: 0, roll: 0),
        CalibrationPoint(region: Orientation.UFO, pitch: 45, roll: 0),
      ];
      // Query near UT: d1 ~= 2, d2 ~= 43. 43 >= 1.5 * 2 → UT.
      expect(MouthRegionEstimator.estimate(2, 0, points), 'UT');
    });

    test('near-tie inside 1.5x ratio returns sorted slash pair', () {
      const points = [
        CalibrationPoint(region: Orientation.URI, pitch: 0, roll: -45),
        CalibrationPoint(region: Orientation.ULO, pitch: 0, roll: -45),
      ];
      expect(MouthRegionEstimator.estimate(0, -45, points), 'ULO/URI');
    });

    test('multiple calibration points for same region resolve to that region',
        () {
      const points = [
        CalibrationPoint(region: Orientation.UT, pitch: 0, roll: 0),
        CalibrationPoint(region: Orientation.UT, pitch: 3, roll: 3),
        CalibrationPoint(region: Orientation.UFO, pitch: 45, roll: 0),
      ];
      expect(MouthRegionEstimator.estimate(1, 1, points), 'UT');
    });

    test('wraparound: query at 170 is closer to -170 than to 0', () {
      const points = [
        CalibrationPoint(region: Orientation.DT, pitch: -170, roll: 0),
        CalibrationPoint(region: Orientation.UT, pitch: 0, roll: 0),
      ];
      expect(MouthRegionEstimator.estimate(170, 0, points), 'DT');
    });

    test('wraparound on roll axis', () {
      const points = [
        CalibrationPoint(region: Orientation.DT, pitch: 0, roll: 175),
        CalibrationPoint(region: Orientation.UT, pitch: 0, roll: 0),
      ];
      // Query roll = -175: dr to DT = 10 (via 360-350), dr to UT = 175.
      expect(MouthRegionEstimator.estimate(0, -175, points), 'DT');
    });

    test('slash pair is stable regardless of input order', () {
      const a = CalibrationPoint(region: Orientation.URI, pitch: 0, roll: -45);
      const b = CalibrationPoint(region: Orientation.ULO, pitch: 0, roll: -45);
      expect(MouthRegionEstimator.estimate(0, -45, [a, b]), 'ULO/URI');
      expect(MouthRegionEstimator.estimate(0, -45, [b, a]), 'ULO/URI');
    });
  });

  group('MouthRegionEstimator.defaultCalibration', () {
    test('covers every Orientation region exactly once or twice (ambiguous)',
        () {
      final present = MouthRegionEstimator.defaultCalibration
          .map((p) => p.region)
          .toSet();
      expect(present, Orientation.values.toSet());
    });

    test('resolves cleanly at (0, 0) to UT', () {
      expect(
        MouthRegionEstimator.estimate(
          0,
          0,
          MouthRegionEstimator.defaultCalibration,
        ),
        'UT',
      );
    });

    test('honestly reports URI/ULO ambiguity at (0, -45)', () {
      expect(
        MouthRegionEstimator.estimate(
          0,
          -45,
          MouthRegionEstimator.defaultCalibration,
        ),
        'ULO/URI',
      );
    });
  });

  group('MouthRegionEstimator.uncoveredRegions', () {
    test('empty input returns all 14 regions', () {
      final uncovered = MouthRegionEstimator.uncoveredRegions(const []);
      expect(uncovered.length, Orientation.values.length);
    });

    test('single unambiguous covers exactly that region', () {
      final uncovered = MouthRegionEstimator.uncoveredRegions(['UT']);
      expect(uncovered, isNot(contains(Orientation.UT)));
      expect(uncovered.length, Orientation.values.length - 1);
    });

    test('ambiguous "R1/R2" covers both regions', () {
      final uncovered = MouthRegionEstimator.uncoveredRegions(['URI/ULO']);
      expect(uncovered, isNot(contains(Orientation.URI)));
      expect(uncovered, isNot(contains(Orientation.ULO)));
      expect(uncovered.length, Orientation.values.length - 2);
    });

    test('all regions covered returns empty', () {
      final all = Orientation.values.map((o) => o.name).toList();
      expect(MouthRegionEstimator.uncoveredRegions(all), isEmpty);
    });

    test('duplicates are deduplicated', () {
      final uncovered =
          MouthRegionEstimator.uncoveredRegions(['UT', 'UT', 'UFO', 'UT']);
      expect(uncovered, isNot(contains(Orientation.UT)));
      expect(uncovered, isNot(contains(Orientation.UFO)));
      expect(uncovered.length, Orientation.values.length - 2);
    });
  });
}
