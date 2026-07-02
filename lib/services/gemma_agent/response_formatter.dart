/// Formats database results into text that Gemma can understand and summarize.

import '/backend/schema/structs/index.dart';
import 'package:intl/intl.dart';

class ResponseFormatter {
  static final _dateFormat = DateFormat('MMM d, yyyy');
  static final _dateTimeFormat = DateFormat('MMM d, yyyy HH:mm');

  /// Format family members list for Gemma
  static String formatFamilyMembers(List<FamilyMemberStruct> members) {
    if (members.isEmpty) {
      return 'No family members found. The user should add family members first.';
    }

    final buffer = StringBuffer();
    buffer.writeln('FAMILY MEMBERS (${members.length} total):');
    buffer.writeln();

    for (final member in members) {
      buffer.writeln('- ${member.name}');
      buffer.writeln('  ID: ${member.id}');
      buffer.writeln('  Health Score: ${member.score.toStringAsFixed(0)}/100');

      if (member.relationship != null) {
        buffer.writeln('  Relationship: ${_formatRelationship(member.relationship!)}');
      }

      if (member.lastChecked != null) {
        buffer.writeln('  Last Checkup: ${_dateFormat.format(member.lastChecked!)}');
      } else {
        buffer.writeln('  Last Checkup: Never scanned');
      }

      if (member.birthday != null) {
        final age = _calculateAge(member.birthday!);
        buffer.writeln('  Age: $age years old');
      }

      buffer.writeln();
    }

    return buffer.toString();
  }

  /// Format single member details for Gemma
  static String formatMemberDetails(FamilyMemberStruct member) {
    final buffer = StringBuffer();
    buffer.writeln('MEMBER DETAILS:');
    buffer.writeln('Name: ${member.name}');
    buffer.writeln('ID: ${member.id}');
    buffer.writeln('Health Score: ${member.score.toStringAsFixed(0)}/100 ${_getScoreEmoji(member.score)}');

    if (member.relationship != null) {
      buffer.writeln('Relationship: ${_formatRelationship(member.relationship!)}');
    }

    if (member.lastChecked != null) {
      buffer.writeln('Last Checkup: ${_dateTimeFormat.format(member.lastChecked!)}');
      buffer.writeln('Days Since Last Scan: ${DateTime.now().difference(member.lastChecked!).inDays}');
    } else {
      buffer.writeln('Last Checkup: Never scanned - should do a checkup!');
    }

    if (member.birthday != null) {
      buffer.writeln('Birthday: ${_dateFormat.format(member.birthday!)}');
      buffer.writeln('Age: ${_calculateAge(member.birthday!)} years old');
    }

    buffer.writeln();
    buffer.writeln('Score Interpretation: ${_interpretScore(member.score)}');

    return buffer.toString();
  }

  /// Format scan sessions for Gemma
  static String formatScanSessions(
    List<ScanSessionStruct> sessions,
    String memberName,
  ) {
    if (sessions.isEmpty) {
      return 'No scans found for $memberName. They should schedule a dental checkup!';
    }

    final buffer = StringBuffer();
    buffer.writeln('SCAN HISTORY FOR $memberName (${sessions.length} scans):');
    buffer.writeln();

    for (int i = 0; i < sessions.length; i++) {
      final session = sessions[i];
      buffer.writeln('${i + 1}. Scan on ${_formatSessionDate(session.sessionStart)}');
      buffer.writeln('   Session ID: ${session.id}');
      buffer.writeln('   Status: ${session.status}');
      buffer.writeln('   Images Captured: ${session.totalImagesCaptured}');

      if (session.notes.isNotEmpty) {
        buffer.writeln('   Notes: ${session.notes}');
      }

      buffer.writeln();
    }

    return buffer.toString();
  }

  /// Format scan details with diagnoses for Gemma
  static String formatScanDetails(
    ScanSessionStruct session,
    List<Map<String, dynamic>> diagnoses,
  ) {
    final buffer = StringBuffer();
    buffer.writeln('SCAN SESSION DETAILS:');
    buffer.writeln('Session ID: ${session.id}');
    buffer.writeln('Date: ${_formatSessionDate(session.sessionStart)}');
    buffer.writeln('Status: ${session.status}');
    buffer.writeln('Total Images: ${session.totalImagesCaptured}');

    if (session.notes.isNotEmpty) {
      buffer.writeln('Notes: ${session.notes}');
    }

    buffer.writeln();

    if (diagnoses.isEmpty) {
      buffer.writeln('FINDINGS: No specific dental issues detected.');
    } else {
      buffer.writeln('FINDINGS:');

      // Group diagnoses by type
      final grouped = <String, int>{};
      for (final d in diagnoses) {
        final label = d['label'] as String? ?? 'Unknown';
        grouped[label] = (grouped[label] ?? 0) + 1;
      }

      for (final entry in grouped.entries) {
        final emoji = _getDiagnosisEmoji(entry.key);
        buffer.writeln('- $emoji ${entry.key}: ${entry.value} instance(s)');
      }
    }

    return buffer.toString();
  }

  /// Format diagnosis search results for Gemma
  static String formatDiagnosisSearch(
    String keyword,
    List<Map<String, dynamic>> results,
  ) {
    if (results.isEmpty) {
      return 'No "$keyword" findings in any recent scans. Good news!';
    }

    final buffer = StringBuffer();
    buffer.writeln('SEARCH RESULTS FOR "$keyword":');
    buffer.writeln('Found ${results.length} instance(s):');
    buffer.writeln();

    for (final result in results) {
      final memberName = result['member_name'] as String? ?? 'Unknown';
      final date = result['date'] as DateTime?;
      final sessionId = result['session_id'] as String? ?? '';
      final count = result['count'] as int? ?? 1;

      buffer.writeln('- $memberName: $count $keyword finding(s)');
      if (date != null) {
        buffer.writeln('  Date: ${_dateFormat.format(date)}');
      }
      buffer.writeln('  Session ID: $sessionId');
      buffer.writeln();
    }

    return buffer.toString();
  }

  /// Format family statistics for Gemma
  static String formatFamilyStats(List<FamilyMemberStruct> members) {
    if (members.isEmpty) {
      return 'No family members to analyze.';
    }

    final buffer = StringBuffer();
    buffer.writeln('FAMILY DENTAL HEALTH OVERVIEW:');
    buffer.writeln();

    // Calculate averages
    final scoresSum = members.fold<double>(0, (sum, m) => sum + m.score);
    final avgScore = scoresSum / members.length;

    buffer.writeln('Total Family Members: ${members.length}');
    buffer.writeln('Average Health Score: ${avgScore.toStringAsFixed(0)}/100');
    buffer.writeln();

    // Members by score category
    final excellent = members.where((m) => m.score >= 80).toList();
    final good = members.where((m) => m.score >= 60 && m.score < 80).toList();
    final fair = members.where((m) => m.score >= 40 && m.score < 60).toList();
    final needsAttention = members.where((m) => m.score < 40).toList();

    buffer.writeln('Score Breakdown:');
    if (excellent.isNotEmpty) {
      buffer.writeln('- Excellent (80+): ${excellent.map((m) => m.name).join(', ')}');
    }
    if (good.isNotEmpty) {
      buffer.writeln('- Good (60-79): ${good.map((m) => m.name).join(', ')}');
    }
    if (fair.isNotEmpty) {
      buffer.writeln('- Fair (40-59): ${fair.map((m) => m.name).join(', ')}');
    }
    if (needsAttention.isNotEmpty) {
      buffer.writeln('- Needs Attention (<40): ${needsAttention.map((m) => m.name).join(', ')}');
    }

    buffer.writeln();

    // Members needing checkup
    final needsCheckup = members.where((m) {
      if (m.lastChecked == null) return true;
      return DateTime.now().difference(m.lastChecked!).inDays > 30;
    }).toList();

    if (needsCheckup.isNotEmpty) {
      buffer.writeln('Members Due for Checkup:');
      for (final m in needsCheckup) {
        if (m.lastChecked == null) {
          buffer.writeln('- ${m.name}: Never scanned');
        } else {
          final days = DateTime.now().difference(m.lastChecked!).inDays;
          buffer.writeln('- ${m.name}: $days days ago');
        }
      }
    } else {
      buffer.writeln('All family members have been checked recently!');
    }

    return buffer.toString();
  }

  // ═══════════════════════════════════════════════════════════════
  // HELPER METHODS
  // ═══════════════════════════════════════════════════════════════

  static String _formatRelationship(dynamic relationship) {
    final name = relationship.toString().split('.').last;
    return name[0].toUpperCase() + name.substring(1);
  }

  static int _calculateAge(DateTime birthday) {
    final now = DateTime.now();
    int age = now.year - birthday.year;
    if (now.month < birthday.month ||
        (now.month == birthday.month && now.day < birthday.day)) {
      age--;
    }
    return age;
  }

  static String _formatSessionDate(DateTime? date) {
    if (date == null) return 'Unknown date';
    return _dateTimeFormat.format(date);
  }

  static String _getScoreEmoji(double score) {
    if (score >= 80) return '(Excellent)';
    if (score >= 60) return '(Good)';
    if (score >= 40) return '(Fair)';
    return '(Needs Attention)';
  }

  static String _interpretScore(double score) {
    if (score >= 80) {
      return 'Excellent dental health! Keep up the good work.';
    }
    if (score >= 60) {
      return 'Good dental health with some minor areas to watch.';
    }
    if (score >= 40) {
      return 'Fair dental health. A dentist visit is recommended.';
    }
    return 'Dental health needs attention. Please see a dentist soon.';
  }

  static String _getDiagnosisEmoji(String diagnosis) {
    final lower = diagnosis.toLowerCase();
    if (lower.contains('cavity') || lower.contains('caries')) return '🦷';
    if (lower.contains('plaque')) return '🔵';
    if (lower.contains('tartar')) return '🟡';
    if (lower.contains('healthy') || lower.contains('good')) return '✅';
    if (lower.contains('gingivitis') || lower.contains('gum')) return '🔴';
    return '•';
  }
}
