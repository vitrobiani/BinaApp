import 'package:bina_system/backend/schema/enums/enums.dart';
import 'package:bina_system/backend/schema/structs/index.dart';
import 'package:bina_system/services/gemma_agent/response_formatter.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('formatFamilyMembers', () {
    test('empty list → helpful empty-state message', () {
      final s = ResponseFormatter.formatFamilyMembers(const []);
      expect(s, contains('No family members found'));
    });

    test('renders name, id, and score for every member', () {
      final members = [
        FamilyMemberStruct(id: 'fm-1', name: 'Alice', score: 85),
        FamilyMemberStruct(id: 'fm-2', name: 'Bob', score: 42),
      ];
      final s = ResponseFormatter.formatFamilyMembers(members);
      expect(s, contains('Alice'));
      expect(s, contains('fm-1'));
      expect(s, contains('85/100'));
      expect(s, contains('Bob'));
      expect(s, contains('42/100'));
      expect(s, contains('(2 total)'));
    });

    test('nullable lastChecked renders "Never scanned"', () {
      final members = [FamilyMemberStruct(id: 'fm-1', name: 'Alice')];
      final s = ResponseFormatter.formatFamilyMembers(members);
      expect(s, contains('Never scanned'));
    });

    test('lastChecked date is formatted per locale-independent template', () {
      final members = [
        FamilyMemberStruct(
          id: 'fm-1',
          name: 'Alice',
          lastChecked: DateTime(2026, 3, 15),
        ),
      ];
      final s = ResponseFormatter.formatFamilyMembers(members);
      expect(s, contains('Mar 15, 2026'));
    });
  });

  group('formatMemberDetails', () {
    test('includes score interpretation for each band', () {
      final cases = <double, String>{
        90: 'Excellent',
        70: 'Good',
        50: 'Fair',
        30: 'Needs Attention',
      };
      cases.forEach((score, expected) {
        final s = ResponseFormatter.formatMemberDetails(
          FamilyMemberStruct(id: 'fm-1', name: 'Alice', score: score),
        );
        expect(s, contains(expected), reason: 'score $score');
      });
    });

    test('renders age from birthday', () {
      final birthday =
          DateTime(DateTime.now().year - 30, 1, 1);
      final s = ResponseFormatter.formatMemberDetails(
        FamilyMemberStruct(id: 'fm-1', name: 'Alice', birthday: birthday),
      );
      expect(s, contains('30 years old'));
    });

    test('relationship is title-cased', () {
      final s = ResponseFormatter.formatMemberDetails(
        FamilyMemberStruct(
          id: 'fm-1',
          name: 'Alice',
          relationship: Relationships.ME,
        ),
      );
      expect(s, contains('ME'));
    });
  });

  group('formatScanSessions', () {
    test('empty → suggests scheduling', () {
      final s = ResponseFormatter.formatScanSessions(const [], 'Alice');
      expect(s, contains('No scans found for Alice'));
    });

    test('renders header with member name and count', () {
      final s = ResponseFormatter.formatScanSessions(
        [
          ScanSessionStruct(
            id: 'ss-1',
            familyMemberId: 'fm-1',
            sessionStart: DateTime(2026, 3, 15, 10),
            status: ScanSessionStatus.completed,
            totalImagesCaptured: 12,
          ),
        ],
        'Alice',
      );
      expect(s, contains('SCAN HISTORY FOR Alice (1 scans)'));
      expect(s, contains('Session ID: ss-1'));
      expect(s, contains('Images Captured: 12'));
    });
  });

  group('formatScanDetails', () {
    test('no diagnoses → "No specific dental issues detected"', () {
      final session = ScanSessionStruct(
        id: 'ss-1',
        familyMemberId: 'fm-1',
        sessionStart: DateTime(2026, 3, 15, 10),
        status: ScanSessionStatus.completed,
        totalImagesCaptured: 5,
      );
      final s = ResponseFormatter.formatScanDetails(session, const []);
      expect(s, contains('No specific dental issues detected'));
    });

    test('groups repeated diagnosis labels with a count', () {
      final session = ScanSessionStruct(
        id: 'ss-1',
        familyMemberId: 'fm-1',
        sessionStart: DateTime(2026, 3, 15, 10),
        status: ScanSessionStatus.completed,
        totalImagesCaptured: 5,
      );
      final diagnoses = [
        {'label': 'Cavity'},
        {'label': 'Cavity'},
        {'label': 'Plaque'},
      ];
      final s = ResponseFormatter.formatScanDetails(session, diagnoses);
      expect(s, contains('Cavity: 2 instance(s)'));
      expect(s, contains('Plaque: 1 instance(s)'));
    });
  });

  group('formatDiagnosisSearch', () {
    test('empty results → good-news message', () {
      final s = ResponseFormatter.formatDiagnosisSearch('cavity', const []);
      expect(s, contains('No "cavity" findings'));
    });

    test('renders per-result member name + count', () {
      final s = ResponseFormatter.formatDiagnosisSearch('cavity', [
        {
          'member_name': 'Alice',
          'session_id': 'ss-1',
          'count': 2,
          'date': DateTime(2026, 3, 15),
        },
      ]);
      expect(s, contains('Alice: 2 cavity finding(s)'));
      expect(s, contains('ss-1'));
      expect(s, contains('Mar 15, 2026'));
    });
  });

  group('formatFamilyStats', () {
    test('empty → "No family members to analyze"', () {
      expect(
        ResponseFormatter.formatFamilyStats(const []),
        contains('No family members to analyze'),
      );
    });

    test('computes average score across members', () {
      final members = [
        FamilyMemberStruct(id: '1', name: 'A', score: 80),
        FamilyMemberStruct(id: '2', name: 'B', score: 60),
        FamilyMemberStruct(id: '3', name: 'C', score: 40),
      ];
      final s = ResponseFormatter.formatFamilyStats(members);
      expect(s, contains('Average Health Score: 60/100'));
    });

    test('groups members by score band', () {
      final members = [
        FamilyMemberStruct(id: '1', name: 'Excel', score: 95),
        FamilyMemberStruct(id: '2', name: 'Good', score: 65),
        FamilyMemberStruct(id: '3', name: 'Fair', score: 45),
        FamilyMemberStruct(id: '4', name: 'Bad', score: 20),
      ];
      final s = ResponseFormatter.formatFamilyStats(members);
      expect(s, contains('Excellent (80+): Excel'));
      expect(s, contains('Good (60-79): Good'));
      expect(s, contains('Fair (40-59): Fair'));
      expect(s, contains('Needs Attention (<40): Bad'));
    });

    test('members never scanned or > 30 days ago appear in checkup list', () {
      final long_ago =
          DateTime.now().subtract(const Duration(days: 60));
      final members = [
        FamilyMemberStruct(id: '1', name: 'NeverScanned', score: 80),
        FamilyMemberStruct(
          id: '2',
          name: 'ScannedLongAgo',
          score: 70,
          lastChecked: long_ago,
        ),
        FamilyMemberStruct(
          id: '3',
          name: 'RecentlyScanned',
          score: 70,
          lastChecked: DateTime.now(),
        ),
      ];
      final s = ResponseFormatter.formatFamilyStats(members);
      expect(s, contains('NeverScanned: Never scanned'));
      expect(s, contains('ScannedLongAgo'));
      expect(s, isNot(contains('RecentlyScanned: ')));
    });
  });

  group('purity', () {
    test('formatters do not throw on default-constructed structs', () {
      // Defensive smoke: minimal or empty struct instances must render.
      final members = [FamilyMemberStruct()];
      expect(() => ResponseFormatter.formatFamilyMembers(members),
          returnsNormally);
      expect(() => ResponseFormatter.formatMemberDetails(FamilyMemberStruct()),
          returnsNormally);
      expect(
        () => ResponseFormatter.formatScanSessions(
          [ScanSessionStruct()],
          'X',
        ),
        returnsNormally,
      );
    });
  });
}
