import '/auth/supabase_auth/auth_util.dart';
import '/backend/schema/structs/index.dart';
import '/backend/schema/enums/enums.dart';
import '/backend/supabase/supabase.dart';
import '/backend/sqlite/sqlite_manager.dart';
import '/app_core/app_util.dart';
import '/actions/actions.dart' as action_blocks;
import '/custom_code/actions/index.dart' as actions;
import '/services/accessibility_settings_service.dart';
import 'package:flutter/material.dart';

Future<int?> calculateFamilyLastChecked(BuildContext context) async {
  int? daysSinceChecked;

  AppState().updateUserSessionStruct(
    (e) => e..sumChecked = AppConstants.ZERO,
  );
  for (int loop1Index = 0;
      loop1Index < AppState().UserSession.family.length;
      loop1Index++) {
    final currentLoop1Item = AppState().UserSession.family[loop1Index];
    daysSinceChecked = await actions.daysSinceLastCheck(
      currentLoop1Item.lastChecked,
    );
    if ((currentLoop1Item.lastChecked != null) && (daysSinceChecked < 7)) {
      AppState().updateUserSessionStruct(
        (e) => e..incrementSumChecked(1),
      );
    }
  }
  return AppState().UserSession.sumChecked;
}

Future updateSessionFamily(BuildContext context) async {
  final List<FamilyMemberStruct> familyList = [];

  if (AppState().UserSession.isLocalSession) {
    // Query family members from SQLite for local sessions
    final sqliteMembers = await SQLiteManager.instance.getFamilyMembersByAccountId(
      accountId: AppState().UserSession.userID,
    );

    // Build the family list from SQLite data
    for (final row in sqliteMembers) {
      familyList.add(FamilyMemberStruct(
        id: row.id,
        name: row.name,
        admin: row.relationship == 'ME',
        birthday: row.birthday != null
            ? DateTime.fromMillisecondsSinceEpoch(row.birthday! * 1000)
            : null,
        lastChecked: row.lastChecked != null && row.lastChecked != 0
            ? DateTime.fromMillisecondsSinceEpoch(row.lastChecked! * 1000)
            : null,
        relationship: deserializeEnum<Relationships>(row.relationship),
      ));
    }

    // Find the main user (relationship = ME) to get name
    final mainMember = familyList.firstWhere(
      (m) => m.relationship == Relationships.ME,
      orElse: () => familyList.isNotEmpty ? familyList.first : FamilyMemberStruct(),
    );

    // Update the UserSession with fresh data (keeping isLocalSession true)
    AppState().updateUserSessionStruct(
      (e) => e
        ..name = mainMember.name
        ..family = familyList
        ..familyAmount = familyList.length,
    );
  } else {
    // Query family members from Supabase for cloud sessions
    final retFamilyMembers = await FamilyMembersTable().queryRows(
      queryFn: (q) => q.eqOrNull(
        'account_id',
        currentUserUid,
      ),
    );

    // Build the new family list from Supabase data
    for (final row in retFamilyMembers) {
      familyList.add(FamilyMemberStruct(
        id: row.id,
        name: row.name,
        admin: row.admin,
        score: row.score,
        birthday: row.birthday,
        lastChecked: row.lastChecked,
      ));
    }

    // Update the UserSession with fresh data
    AppState().updateUserSessionStruct(
      (e) => e
        ..userID = currentUserUid
        ..name = retFamilyMembers.firstOrNull?.name
        ..email = currentUserEmail
        ..sessionId = currentJwtToken
        ..family = familyList
        ..familyAmount = familyList.length,
    );
  }

  AppState().update(() {});

  await action_blocks.calculateFamilyLastChecked(context);

  // Apply age-based accessibility auto-adjustments for admin user
  final adminMember = familyList.firstWhere(
    (m) => m.admin == true,
    orElse: () => FamilyMemberStruct(),
  );

  if (adminMember.birthday != null) {
    final now = DateTime.now();
    final age = now.year - adminMember.birthday!.year -
        (now.month < adminMember.birthday!.month ||
         (now.month == adminMember.birthday!.month && now.day < adminMember.birthday!.day) ? 1 : 0);

    await AccessibilitySettingsService.instance.applyAutoAdjustmentsForAge(age);
  }
}
