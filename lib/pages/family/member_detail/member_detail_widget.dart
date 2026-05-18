import '/app_core/app_util.dart';
import '/backend/schema/structs/index.dart';
import '/bina_design/bina_design.dart';
import '/index.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class MemberDetailWidget extends StatelessWidget {
  const MemberDetailWidget({
    super.key,
    required this.member,
  });

  static String routeName = 'MemberDetail';
  static String routePath = 'memberDetail';

  final FamilyMemberStruct member;

  int? get _age {
    if (!member.hasBirthday()) return null;
    return DateTime.now().difference(member.birthday!).inDays ~/ 365;
  }

  DxChipKind get _diagnosisKind {
    if (!member.hasLastChecked()) return DxChipKind.due;
    if (member.score >= 80) return DxChipKind.good;
    if (member.score >= 50) return DxChipKind.plaque;
    return DxChipKind.cavity;
  }

  BinaAvatarTone get _avatarTone {
    final hash = member.name.hashCode;
    final tones = BinaAvatarTone.values;
    return tones[hash.abs() % (tones.length - 1)];
  }

  String get _lastCheckedStr {
    if (!member.hasLastChecked()) return 'never checked';
    final date = member.lastChecked!;
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inDays == 0) {
      return 'last checked today';
    } else if (diff.inDays == 1) {
      return 'last checked yesterday';
    } else if (diff.inDays < 7) {
      return 'last checked ${diff.inDays} days ago';
    } else {
      return 'last checked ${DateFormat('d MMM').format(date)}';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BinaColors.surfaceAlt,
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(top: 54, bottom: 120),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with back button
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  BinaIconButton(
                    icon: Icons.chevron_left_rounded,
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  BinaIconButton(
                    icon: Icons.settings_outlined,
                    onPressed: () {
                      // TODO: Member settings
                    },
                  ),
                ],
              ),
            ).animate()
                .fadeIn(duration: 300.ms)
                .moveY(begin: -10, end: 0, duration: 300.ms),

            // Hero card
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
              child: _HeroCard(
                member: member,
                age: _age,
                diagnosisKind: _diagnosisKind,
                avatarTone: _avatarTone,
                lastCheckedStr: _lastCheckedStr,
                onScan: () {
                  context.pushNamed(
                    PhotoSessionWidget.routeName,
                    pathParameters: {
                      'memberId': member.id,
                      'memberName': member.name,
                    },
                  );
                },
                onBook: () {
                  // TODO: Book appointment
                },
              ),
            ).animate()
                .fadeIn(delay: 100.ms, duration: 400.ms)
                .moveY(begin: 20, end: 0, delay: 100.ms, duration: 400.ms),

            // Stats section
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: Row(
                children: [
                  Expanded(
                    child: _StatCard(
                      label: 'Clean',
                      value: 4, // TODO: Get from actual data
                      tone: DxChipKind.good,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _StatCard(
                      label: 'Plaque',
                      value: 2,
                      tone: DxChipKind.plaque,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _StatCard(
                      label: 'Cavity',
                      value: _diagnosisKind == DxChipKind.cavity ? 1 : 0,
                      tone: DxChipKind.cavity,
                    ),
                  ),
                ],
              ),
            ).animate()
                .fadeIn(delay: 200.ms, duration: 400.ms)
                .moveY(begin: 20, end: 0, delay: 200.ms, duration: 400.ms),

            // History section
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
              child: Column(
                children: [
                  BinaSectionHeader(
                    title: 'History',
                    action: 'Export',
                    onActionTap: () {
                      // TODO: Export history
                    },
                  ),
                  const SizedBox(height: 12),
                  _HistoryList(memberId: member.id),
                ],
              ),
            ).animate()
                .fadeIn(delay: 300.ms, duration: 400.ms)
                .moveY(begin: 20, end: 0, delay: 300.ms, duration: 400.ms),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// HERO CARD
// ═══════════════════════════════════════════════════════════════

class _HeroCard extends StatelessWidget {
  const _HeroCard({
    required this.member,
    required this.age,
    required this.diagnosisKind,
    required this.avatarTone,
    required this.lastCheckedStr,
    required this.onScan,
    required this.onBook,
  });

  final FamilyMemberStruct member;
  final int? age;
  final DxChipKind diagnosisKind;
  final BinaAvatarTone avatarTone;
  final String lastCheckedStr;
  final VoidCallback onScan;
  final VoidCallback onBook;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: BinaColors.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: BinaColors.line),
        boxShadow: BinaElevation.sh3,
      ),
      child: Column(
        children: [
          BinaAvatar(
            name: member.name,
            size: 84,
            tone: avatarTone,
            imageUrl: member.profilePic.isNotEmpty ? member.profilePic : null,
          ),
          const SizedBox(height: 10),
          Text(
            member.name,
            style: BinaType.headlineMd,
          ),
          const SizedBox(height: 4),
          Text(
            '${age != null ? '$age years · ' : ''}$lastCheckedStr',
            style: BinaType.bodySm.copyWith(color: BinaColors.ink2),
          ),
          const SizedBox(height: 8),
          DxChip(kind: diagnosisKind),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: BinaButton(
                  label: 'Scan now',
                  variant: BinaButtonVariant.primary,
                  icon: Icons.camera_alt_rounded,
                  onPressed: onScan,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: BinaButton(
                  label: 'Book',
                  variant: BinaButtonVariant.secondary,
                  icon: Icons.calendar_today_rounded,
                  onPressed: onBook,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// STAT CARD
// ═══════════════════════════════════════════════════════════════

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.label,
    required this.value,
    required this.tone,
  });

  final String label;
  final int value;
  final DxChipKind tone;

  Color get _dotColor {
    switch (tone) {
      case DxChipKind.good:
        return BinaColors.success;
      case DxChipKind.plaque:
        return BinaColors.warning;
      case DxChipKind.cavity:
        return BinaColors.error;
      case DxChipKind.due:
      case DxChipKind.mixed:
        return BinaColors.ink3;
    }
  }

  Color get _backgroundColor {
    switch (tone) {
      case DxChipKind.good:
        return BinaColors.success100;
      case DxChipKind.plaque:
        return const Color(0xFFFCF0D8);
      case DxChipKind.cavity:
        return BinaColors.error100;
      case DxChipKind.due:
      case DxChipKind.mixed:
        return BinaColors.surfaceSunken;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: BinaColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: BinaColors.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: _backgroundColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: _dotColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: BinaType.labelMd.copyWith(color: BinaColors.ink2),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            '$value',
            style: BinaType.displaySm.copyWith(fontSize: 26),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// HISTORY LIST
// ═══════════════════════════════════════════════════════════════

class _HistoryList extends StatelessWidget {
  const _HistoryList({required this.memberId});

  final String memberId;

  @override
  Widget build(BuildContext context) {
    // TODO: Load actual history from database
    final demoHistory = [
      {'date': '12 May · 11:24', 'region': 'Upper left incisor', 'kind': DxChipKind.good},
      {'date': '6 May · 08:11', 'region': 'Lower front', 'kind': DxChipKind.plaque},
      {'date': '29 Apr · 20:02', 'region': 'Upper molar', 'kind': DxChipKind.good},
    ];

    if (demoHistory.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: BinaColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: BinaColors.line),
        ),
        child: Center(
          child: Text(
            'No scan history yet',
            style: BinaType.bodyMd.copyWith(color: BinaColors.ink2),
          ),
        ),
      );
    }

    return Column(
      children: demoHistory.asMap().entries.map((entry) {
        final index = entry.key;
        final item = entry.value;
        return Padding(
          padding: EdgeInsets.only(bottom: index < demoHistory.length - 1 ? 10 : 0),
          child: _HistoryRow(
            date: item['date'] as String,
            region: item['region'] as String,
            kind: item['kind'] as DxChipKind,
          ),
        );
      }).toList(),
    );
  }
}

class _HistoryRow extends StatelessWidget {
  const _HistoryRow({
    required this.date,
    required this.region,
    required this.kind,
  });

  final String date;
  final String region;
  final DxChipKind kind;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: BinaColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: BinaColors.line),
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF1A1A22), Color(0xFF2C2C38)],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.emoji_emotions_outlined,
              color: Colors.white.withValues(alpha: 0.55),
              size: 28,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(region, style: BinaType.titleMd),
                const SizedBox(height: 2),
                Text(
                  date,
                  style: BinaType.bodySm.copyWith(color: BinaColors.ink3),
                ),
              ],
            ),
          ),
          DxChip(kind: kind, size: DxChipSize.sm),
        ],
      ),
    );
  }
}
