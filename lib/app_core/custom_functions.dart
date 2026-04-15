import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'lat_lng.dart';
import 'place.dart';
import 'uploaded_file.dart';
import '/backend/schema/structs/index.dart';
import '/backend/schema/enums/enums.dart';
import '/backend/supabase/supabase.dart';
import '/backend/sqlite/sqlite_manager.dart';
import '/auth/supabase_auth/auth_util.dart';

/// returns a list of FamilyMembers from query return (assuming 1 user )
List<FamilyMemberStruct> familyList(List<FamilyMembersRow>? queryResult) {
  return [];

  // if (queryResult == null || queryResult.isEmpty) {
  //   return [];
  // }

  // 2. Map each row object to your Data Struct
  // return queryResult.map((row) {
  //   return FamilyMemberStruct(
  //     id: row.id, // Use dot notation, not ['id']
  //     name: row.name,
  //     admin: row.admin ?? false,
  //     score: row.score ?? 0.0,
  //     lastChecked: row
  //         .lastChecked, // Note: FF often converts last_checked to lastChecked
  //   );
  // }).toList();
}

dynamic updateLastChecked(
  List<UsersInfoRow> users,
  int memberIndex,
) {
  print("\n### entered updateLastChecked\n");
  if (users.isEmpty) {
    print("\n### user is empty\n");
    return {};
  }
  var user = users[0];

  var familyData = user.data['family'];

  // 1. Parse Root JSON
  Map<String, dynamic> rootJson;
  if (familyData is String) {
    try {
      rootJson = jsonDecode(familyData);
    } catch (e) {
      rootJson = {};
    }
  } else if (familyData is Map) {
    rootJson = Map<String, dynamic>.from(familyData);
  } else {
    rootJson = {};
  }
  print("\n### after parsing root json\n");

  // 2. Parse Inner Family Object
  Map<String, dynamic> innerFamily;
  if (rootJson['family'] is Map) {
    innerFamily = Map<String, dynamic>.from(rootJson['family']);
  } else {
    innerFamily = {};
  }

  // 3. Determine the key to update based on index
  // Index 0 is "head", Index 1+ is "memberX"
  String targetKey;
  if (memberIndex == 0) {
    targetKey = "head";
  } else {
    targetKey = 'member$memberIndex';
  }

  // 4. Update the specific member if they exist
  if (innerFamily.containsKey(targetKey)) {
    dynamic memberData = innerFamily[targetKey];
    Map<String, dynamic> memberMap;

    if (memberData is Map) {
      memberMap = Map<String, dynamic>.from(memberData);
    } else if (memberData is String) {
      try {
        memberMap = jsonDecode(memberData);
      } catch (e) {
        memberMap = {};
      }
    } else {
      memberMap = {};
    }

    // Set last_checked to now (ISO 8601 string is standard for JSON)
    memberMap["last_checked"] = DateTime.now().toIso8601String();

    // Save back to inner family
    innerFamily[targetKey] = memberMap;
  }

  // 5. Update Root JSON
  rootJson['family'] = innerFamily;

  // Return the full updated JSON structure
  return rootJson;
}

DateTime nullDateTime(String date) {
  return DateTime.parse(date);
}

int stringToUnixTimestamp(String dateString) {
  try {
    // 1. Parse the string into a DateTime object
    DateTime dateTime = DateTime.parse(dateString);

    // 2. Convert to Unix timestamp (seconds)
    // We divide by 1000 because Dart works in milliseconds by default
    return dateTime.millisecondsSinceEpoch ~/ 1000;
  } catch (e) {
    // Handle cases where the string is not a valid date format
    print("Error parsing date: $e");
    return 0;
  }
}

DateTime stringToDateTime(String dateString) {
  try {
    return DateTime.parse(dateString);
  } catch (e) {
    print("Error: Could not parse date. Ensure it is in YYYY-MM-DD format.");
    return DateTime.now(); // Fallback to current time
  }
}
