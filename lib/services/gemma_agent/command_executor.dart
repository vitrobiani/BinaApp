/// Executes data query commands against the database.

import 'package:flutter/foundation.dart';
import '/auth/supabase_auth/auth_util.dart';
import '/backend/supabase/supabase.dart';
import '/backend/sqlite/sqlite_manager.dart';
import '/backend/schema/structs/index.dart';
import '/backend/schema/enums/enums.dart';
import '/app_core/app_util.dart';
import 'command_parser.dart';
import 'member_name_resolver.dart';
import 'response_formatter.dart';

/// Result of executing a command
class CommandResult {
  const CommandResult({
    required this.success,
    required this.data,
    this.formattedData,
    this.errorMessage,
    this.memberContext,
    this.sessionContext,
  });

  final bool success;
  final dynamic data;
  final String? formattedData;
  final String? errorMessage;

  /// Context for follow-up commands
  final FamilyMemberStruct? memberContext;
  final String? sessionContext;

  factory CommandResult.success({
    required dynamic data,
    required String formattedData,
    FamilyMemberStruct? memberContext,
    String? sessionContext,
  }) {
    return CommandResult(
      success: true,
      data: data,
      formattedData: formattedData,
      memberContext: memberContext,
      sessionContext: sessionContext,
    );
  }

  factory CommandResult.failure(String message) {
    return CommandResult(
      success: false,
      data: null,
      errorMessage: message,
    );
  }

  factory CommandResult.memberNotFound(String memberName, List<String> available) {
    return CommandResult(
      success: false,
      data: null,
      errorMessage: 'Could not find family member "$memberName". Available members: ${available.join(', ')}',
    );
  }
}

class CommandExecutor {
  final MemberNameResolver _resolver = MemberNameResolver();

  /// Execute a parsed command
  /// [currentMemberId] is the ID of the family member who is chatting (for "my" commands)
  Future<CommandResult> execute(
    ParsedCommand command, {
    String? currentMemberId,
  }) async {
    try {
      switch (command.name) {
        // ═══════════════════════════════════════════════════════════════
        // SELF (CURRENT MEMBER) COMMANDS
        // ═══════════════════════════════════════════════════════════════
        case 'GET_MY_SCANS':
          if (currentMemberId == null) {
            return CommandResult.failure('No member context - cannot get your scans');
          }
          return await _getMyScans(
            memberId: currentMemberId,
            limit: int.tryParse(command.params['limit'] ?? '5') ?? 5,
          );

        case 'GET_MY_STATS':
          if (currentMemberId == null) {
            return CommandResult.failure('No member context - cannot get your stats');
          }
          return await _getMyStats(memberId: currentMemberId);

        case 'COUNT_MY_SCANS':
          if (currentMemberId == null) {
            return CommandResult.failure('No member context - cannot count your scans');
          }
          return await _countMyScans(memberId: currentMemberId);

        case 'EXPLAIN_MY_LAST_SCAN':
          if (currentMemberId == null) {
            return CommandResult.failure('No member context - cannot explain your scan');
          }
          return await _explainMyLastScan(memberId: currentMemberId);

        case 'SEARCH_MY_DIAGNOSES':
          if (currentMemberId == null) {
            return CommandResult.failure('No member context - cannot search your diagnoses');
          }
          return await _searchMyDiagnoses(
            memberId: currentMemberId,
            keyword: command.params['keyword'] ?? '',
          );

        // ═══════════════════════════════════════════════════════════════
        // FAMILY MEMBER COMMANDS
        // ═══════════════════════════════════════════════════════════════
        case 'GET_FAMILY_MEMBERS':
          return await _getFamilyMembers();

        case 'GET_MEMBER_DETAILS':
          return await _getMemberDetails(command.params['member_name'] ?? '');

        case 'GET_MEMBER_SCANS':
          return await _getMemberScans(
            memberName: command.params['member_name'] ?? '',
            limit: int.tryParse(command.params['limit'] ?? '5') ?? 5,
          );

        case 'GET_SCAN_DETAILS':
          return await _getScanDetails(command.params['session_id'] ?? '');

        case 'SEARCH_DIAGNOSES':
          return await _searchDiagnoses(
            keyword: command.params['keyword'] ?? '',
            memberName: command.params['member_name'],
          );

        case 'GET_FAMILY_STATS':
          return await _getFamilyStats();

        default:
          return CommandResult.failure('Unknown command: ${command.name}');
      }
    } catch (e, stack) {
      debugPrint('Command execution error: $e\n$stack');
      return CommandResult.failure('Error executing command: $e');
    }
  }

  // ═══════════════════════════════════════════════════════════════
  // COMMAND IMPLEMENTATIONS
  // ═══════════════════════════════════════════════════════════════

  Future<CommandResult> _getFamilyMembers() async {
    final members = await _loadFamilyMembers();

    return CommandResult.success(
      data: members,
      formattedData: ResponseFormatter.formatFamilyMembers(members),
    );
  }

  Future<CommandResult> _getMemberDetails(String memberName) async {
    if (memberName.isEmpty) {
      return CommandResult.failure('Member name is required');
    }

    final members = await _loadFamilyMembers();
    final member = _resolver.resolve(memberName, members);

    if (member == null) {
      return CommandResult.memberNotFound(
        memberName,
        members.map((m) => m.name).toList(),
      );
    }

    return CommandResult.success(
      data: member,
      formattedData: ResponseFormatter.formatMemberDetails(member),
      memberContext: member,
    );
  }

  Future<CommandResult> _getMemberScans({
    required String memberName,
    int limit = 5,
  }) async {
    if (memberName.isEmpty) {
      return CommandResult.failure('Member name is required');
    }

    final members = await _loadFamilyMembers();
    final member = _resolver.resolve(memberName, members);

    if (member == null) {
      return CommandResult.memberNotFound(
        memberName,
        members.map((m) => m.name).toList(),
      );
    }

    final sessions = await _loadMemberScans(member.id, limit);

    return CommandResult.success(
      data: sessions,
      formattedData: ResponseFormatter.formatScanSessions(sessions, member.name),
      memberContext: member,
      sessionContext: sessions.isNotEmpty ? sessions.first.id : null,
    );
  }

  Future<CommandResult> _getScanDetails(String sessionId) async {
    if (sessionId.isEmpty) {
      return CommandResult.failure('Session ID is required');
    }

    final isLocal = AppState().UserSession.isLocalSession;
    ScanSessionStruct? session;
    List<Map<String, dynamic>> diagnoses = [];

    try {
      if (isLocal) {
        // Get all sessions for the user and find the one with matching ID
        final accountId = AppState().UserSession.userID;
        final memberRows = await SQLiteManager.instance.getFamilyMembersByAccountId(
          accountId: accountId,
        );

        for (final memberRow in memberRows) {
          final sessionRows = await SQLiteManager.instance.getScanSessionsByMemberId(
            memberId: memberRow.id,
          );

          final matchingSession = sessionRows.where((s) => s.id == sessionId).firstOrNull;
          if (matchingSession != null) {
            session = ScanSessionStruct(
              id: matchingSession.id,
              familyMemberId: matchingSession.familyMemberId,
              sessionStart: matchingSession.sessionStart != null
                  ? DateTime.fromMillisecondsSinceEpoch(matchingSession.sessionStart!)
                  : null,
              sessionEnd: matchingSession.sessionEnd != null
                  ? DateTime.fromMillisecondsSinceEpoch(matchingSession.sessionEnd!)
                  : null,
              status: ScanSessionStatus.values.deserialize(matchingSession.status),
              notes: matchingSession.notes,
              totalImagesCaptured: matchingSession.totalImagesCaptured,
            );
            break;
          }
        }

        if (session == null) {
          return CommandResult.failure('Session not found');
        }

        // Load images and extract diagnoses
        final images = await SQLiteManager.instance.getScanImagesBySessionId(
          sessionId: sessionId,
        );

        for (final image in images) {
          if (image.rawResponse != null && image.rawResponse!.isNotEmpty) {
            try {
              final detections = jsonDecode(image.rawResponse!) as List;
              diagnoses.addAll(detections.cast<Map<String, dynamic>>());
            } catch (_) {}
          }
        }
      } else {
        final sessions = await ScanSessionsTable().queryRows(
          queryFn: (q) => q.eq('id', sessionId),
        );

        if (sessions.isEmpty) {
          return CommandResult.failure('Session not found');
        }

        session = ScanSessionStruct(
          id: sessions.first.id,
          familyMemberId: sessions.first.familyMemberId,
          sessionStart: sessions.first.sessionStart,
          sessionEnd: sessions.first.sessionEnd,
          status: ScanSessionStatus.values.deserialize(sessions.first.status),
          notes: sessions.first.notes,
          totalImagesCaptured: sessions.first.totalImagesCaptured,
        );

        // Load images and extract diagnoses
        final images = await ScanImagesTable().queryRows(
          queryFn: (q) => q.eq('scan_session_id', sessionId),
        );

        for (final image in images) {
          if (image.rawResponse != null && image.rawResponse!.isNotEmpty) {
            try {
              final detections = jsonDecode(image.rawResponse!) as List;
              diagnoses.addAll(detections.cast<Map<String, dynamic>>());
            } catch (_) {}
          }
        }
      }

      return CommandResult.success(
        data: {'session': session, 'diagnoses': diagnoses},
        formattedData: ResponseFormatter.formatScanDetails(session, diagnoses),
        sessionContext: sessionId,
      );
    } catch (e) {
      return CommandResult.failure('Could not load scan details: $e');
    }
  }

  Future<CommandResult> _searchDiagnoses({
    required String keyword,
    String? memberName,
  }) async {
    if (keyword.isEmpty) {
      return CommandResult.failure('Search keyword is required');
    }

    final members = await _loadFamilyMembers();
    FamilyMemberStruct? targetMember;

    if (memberName != null && memberName.isNotEmpty) {
      targetMember = _resolver.resolve(memberName, members);
      if (targetMember == null) {
        return CommandResult.memberNotFound(
          memberName,
          members.map((m) => m.name).toList(),
        );
      }
    }

    final results = <Map<String, dynamic>>[];
    final normalizedKeyword = keyword.toLowerCase();

    // Search through all members (or just target member)
    final membersToSearch = targetMember != null ? [targetMember] : members;

    for (final member in membersToSearch) {
      final sessions = await _loadMemberScans(member.id, 10);

      for (final session in sessions) {
        final diagnoses = await _loadSessionDiagnoses(session.id);

        final matchingDiagnoses = diagnoses.where((d) {
          final label = (d['label'] as String? ?? '').toLowerCase();
          return label.contains(normalizedKeyword);
        }).toList();

        if (matchingDiagnoses.isNotEmpty) {
          results.add({
            'member_name': member.name,
            'member_id': member.id,
            'session_id': session.id,
            'date': session.sessionStart,
            'count': matchingDiagnoses.length,
            'diagnoses': matchingDiagnoses,
          });
        }
      }
    }

    return CommandResult.success(
      data: results,
      formattedData: ResponseFormatter.formatDiagnosisSearch(keyword, results),
    );
  }

  Future<CommandResult> _getFamilyStats() async {
    final members = await _loadFamilyMembers();

    return CommandResult.success(
      data: members,
      formattedData: ResponseFormatter.formatFamilyStats(members),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // SELF (CURRENT MEMBER) COMMAND IMPLEMENTATIONS
  // ═══════════════════════════════════════════════════════════════

  Future<CommandResult> _getMyScans({
    required String memberId,
    int limit = 5,
  }) async {
    final sessions = await _loadMemberScans(memberId, limit);
    final members = await _loadFamilyMembers();
    final member = members.where((m) => m.id == memberId).firstOrNull;
    final memberName = member?.name ?? 'You';

    return CommandResult.success(
      data: sessions,
      formattedData: ResponseFormatter.formatScanSessions(sessions, memberName),
    );
  }

  Future<CommandResult> _getMyStats({required String memberId}) async {
    final members = await _loadFamilyMembers();
    final member = members.where((m) => m.id == memberId).firstOrNull;

    if (member == null) {
      return CommandResult.failure('Could not find your member record');
    }

    // Get scan count and last scan info
    final allScans = await _loadMemberScans(memberId, 100);
    final totalScans = allScans.length;
    final lastScan = allScans.isNotEmpty ? allScans.first : null;

    // Get diagnoses from recent scans
    final recentDiagnoses = <Map<String, dynamic>>[];
    for (final scan in allScans.take(5)) {
      final diagnoses = await _loadSessionDiagnoses(scan.id);
      recentDiagnoses.addAll(diagnoses);
    }

    // Count diagnosis types
    final diagnosisCounts = <String, int>{};
    for (final d in recentDiagnoses) {
      final label = (d['label'] as String? ?? 'unknown').toLowerCase();
      diagnosisCounts[label] = (diagnosisCounts[label] ?? 0) + 1;
    }

    final buffer = StringBuffer();
    buffer.writeln('📊 YOUR DENTAL STATS (${member.name})');
    buffer.writeln('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    buffer.writeln('Total scans: $totalScans');
    if (lastScan != null && lastScan.sessionStart != null) {
      final daysSince = DateTime.now().difference(lastScan.sessionStart!).inDays;
      buffer.writeln('Last scan: ${daysSince == 0 ? "Today" : "$daysSince days ago"}');
    }
    if (member.score > 0) {
      buffer.writeln('Dental health score: ${member.score.toStringAsFixed(0)}/100');
    }
    if (diagnosisCounts.isNotEmpty) {
      buffer.writeln('\nRecent findings (last 5 scans):');
      for (final entry in diagnosisCounts.entries) {
        buffer.writeln('  • ${entry.key}: ${entry.value} detected');
      }
    }

    return CommandResult.success(
      data: {'member': member, 'scans': totalScans, 'diagnoses': diagnosisCounts},
      formattedData: buffer.toString(),
      memberContext: member,
    );
  }

  Future<CommandResult> _countMyScans({required String memberId}) async {
    final sessions = await _loadMemberScans(memberId, 1000); // Get all
    final count = sessions.length;

    return CommandResult.success(
      data: count,
      formattedData: 'You have $count scan${count == 1 ? '' : 's'} on record.',
    );
  }

  Future<CommandResult> _explainMyLastScan({required String memberId}) async {
    final sessions = await _loadMemberScans(memberId, 1);

    if (sessions.isEmpty) {
      return CommandResult.success(
        data: null,
        formattedData: 'You don\'t have any scans yet. Would you like to do one?',
      );
    }

    final lastScan = sessions.first;
    final diagnoses = await _loadSessionDiagnoses(lastScan.id);

    final buffer = StringBuffer();
    buffer.writeln('🔍 YOUR LAST SCAN');
    buffer.writeln('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

    if (lastScan.sessionStart != null) {
      final daysSince = DateTime.now().difference(lastScan.sessionStart!).inDays;
      buffer.writeln('Date: ${daysSince == 0 ? "Today" : "$daysSince days ago"}');
    }

    if (lastScan.hasTotalImagesCaptured()) {
      buffer.writeln('Images captured: ${lastScan.totalImagesCaptured}');
    }

    if (diagnoses.isEmpty) {
      buffer.writeln('\nNo issues detected! Your teeth look healthy. 🦷✨');
    } else {
      buffer.writeln('\nFindings:');
      // Group by label
      final grouped = <String, List<Map<String, dynamic>>>{};
      for (final d in diagnoses) {
        final label = d['label'] as String? ?? 'unknown';
        grouped.putIfAbsent(label, () => []).add(d);
      }

      for (final entry in grouped.entries) {
        final confidence = entry.value.isNotEmpty
            ? (entry.value.first['confidence'] as num? ?? 0) * 100
            : 0;
        buffer.writeln('  • ${entry.key}: ${entry.value.length} detected (${confidence.toStringAsFixed(0)}% confidence)');

        // Add explanation for common findings
        switch (entry.key.toLowerCase()) {
          case 'cavity':
            buffer.writeln('    → Tooth decay that may need filling. See a dentist soon.');
            break;
          case 'plaque':
            buffer.writeln('    → Bacterial buildup. Improve brushing and flossing.');
            break;
          case 'tartar':
            buffer.writeln('    → Hardened plaque. Professional cleaning recommended.');
            break;
          case 'healthy':
            buffer.writeln('    → Looking good! Keep up the good work.');
            break;
        }
      }
    }

    if (lastScan.hasNotes() && lastScan.notes.isNotEmpty) {
      buffer.writeln('\nNotes: ${lastScan.notes}');
    }

    return CommandResult.success(
      data: {'session': lastScan, 'diagnoses': diagnoses},
      formattedData: buffer.toString(),
      sessionContext: lastScan.id,
    );
  }

  Future<CommandResult> _searchMyDiagnoses({
    required String memberId,
    required String keyword,
  }) async {
    if (keyword.isEmpty) {
      return CommandResult.failure('Please specify what to search for (e.g., cavity, plaque)');
    }

    final sessions = await _loadMemberScans(memberId, 50);
    final results = <Map<String, dynamic>>[];
    final normalizedKeyword = keyword.toLowerCase();

    for (final session in sessions) {
      final diagnoses = await _loadSessionDiagnoses(session.id);
      final matching = diagnoses.where((d) {
        final label = (d['label'] as String? ?? '').toLowerCase();
        return label.contains(normalizedKeyword);
      }).toList();

      if (matching.isNotEmpty) {
        results.add({
          'session_id': session.id,
          'date': session.sessionStart,
          'count': matching.length,
          'diagnoses': matching,
        });
      }
    }

    final buffer = StringBuffer();
    buffer.writeln('🔎 SEARCH RESULTS FOR "$keyword"');
    buffer.writeln('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

    if (results.isEmpty) {
      buffer.writeln('No "$keyword" found in your scan history. That\'s good news! 🎉');
    } else {
      final totalCount = results.fold<int>(0, (sum, r) => sum + (r['count'] as int));
      buffer.writeln('Found $totalCount "$keyword" across ${results.length} scan${results.length == 1 ? '' : 's'}:\n');

      for (final r in results.take(5)) {
        final date = r['date'] as DateTime?;
        final dateStr = date != null
            ? '${date.day}/${date.month}/${date.year}'
            : 'Unknown date';
        buffer.writeln('• $dateStr: ${r['count']} detected');
      }

      if (results.length > 5) {
        buffer.writeln('\n... and ${results.length - 5} more scans');
      }
    }

    return CommandResult.success(
      data: results,
      formattedData: buffer.toString(),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // DATA LOADING HELPERS
  // ═══════════════════════════════════════════════════════════════

  Future<List<FamilyMemberStruct>> _loadFamilyMembers() async {
    // Use cached family members from AppState if available
    final cachedMembers = AppState().UserSession.family;
    if (cachedMembers.isNotEmpty) {
      return cachedMembers;
    }

    final isLocal = AppState().UserSession.isLocalSession;

    if (isLocal) {
      final accountId = AppState().UserSession.userID;
      final rows = await SQLiteManager.instance.getFamilyMembersByAccountId(
        accountId: accountId,
      );

      return rows.map((r) => FamilyMemberStruct(
        id: r.id,
        name: r.name ?? '',
        score: 0, // Score not stored in SQLite
        lastChecked: r.lastChecked != null
            ? DateTime.fromMillisecondsSinceEpoch(r.lastChecked!)
            : null,
        birthday: r.birthday != null
            ? DateTime.fromMillisecondsSinceEpoch(r.birthday!)
            : null,
        admin: r.relationship == 'ME',
      )).toList();
    } else {
      final rows = await FamilyMembersTable().queryRows(
        queryFn: (q) => q.eq('account_id', currentUserUid).order('name'),
      );

      return rows.map((r) => FamilyMemberStruct(
        id: r.id,
        name: r.name ?? '',
        score: r.score?.toDouble() ?? 0,
        lastChecked: r.lastChecked,
        birthday: r.birthday,
        admin: r.admin ?? false,
      )).toList();
    }
  }

  Future<List<ScanSessionStruct>> _loadMemberScans(String memberId, int limit) async {
    final isLocal = AppState().UserSession.isLocalSession;

    if (isLocal) {
      final rows = await SQLiteManager.instance.getScanSessionsByMemberId(
        memberId: memberId,
      );

      return rows
          .take(limit)
          .map((r) => ScanSessionStruct(
            id: r.id,
            familyMemberId: r.familyMemberId,
            sessionStart: r.sessionStart != null
                ? DateTime.fromMillisecondsSinceEpoch(r.sessionStart!)
                : null,
            sessionEnd: r.sessionEnd != null
                ? DateTime.fromMillisecondsSinceEpoch(r.sessionEnd!)
                : null,
            status: ScanSessionStatus.values.deserialize(r.status),
            notes: r.notes,
            totalImagesCaptured: r.totalImagesCaptured,
          ))
          .toList();
    } else {
      final rows = await ScanSessionsTable().queryRows(
        queryFn: (q) => q
            .eq('family_member_id', memberId)
            .order('session_start', ascending: false)
            .limit(limit),
      );

      return rows.map((r) => ScanSessionStruct(
        id: r.id,
        familyMemberId: r.familyMemberId,
        sessionStart: r.sessionStart,
        sessionEnd: r.sessionEnd,
        status: ScanSessionStatus.values.deserialize(r.status),
        notes: r.notes,
        totalImagesCaptured: r.totalImagesCaptured,
      )).toList();
    }
  }

  Future<List<Map<String, dynamic>>> _loadSessionDiagnoses(String sessionId) async {
    final isLocal = AppState().UserSession.isLocalSession;
    final diagnoses = <Map<String, dynamic>>[];

    if (isLocal) {
      final images = await SQLiteManager.instance.getScanImagesBySessionId(
        sessionId: sessionId,
      );

      for (final image in images) {
        if (image.rawResponse != null && image.rawResponse!.isNotEmpty) {
          try {
            final detections = jsonDecode(image.rawResponse!) as List;
            diagnoses.addAll(detections.cast<Map<String, dynamic>>());
          } catch (_) {}
        }
      }
    } else {
      final images = await ScanImagesTable().queryRows(
        queryFn: (q) => q.eq('scan_session_id', sessionId),
      );

      for (final image in images) {
        if (image.rawResponse != null && image.rawResponse!.isNotEmpty) {
          try {
            final detections = jsonDecode(image.rawResponse!) as List;
            diagnoses.addAll(detections.cast<Map<String, dynamic>>());
          } catch (_) {}
        }
      }
    }

    return diagnoses;
  }
}
