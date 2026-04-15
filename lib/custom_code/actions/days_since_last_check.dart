import '/backend/schema/structs/index.dart';
import '/backend/schema/enums/enums.dart';
import '/backend/supabase/supabase.dart';
import '/backend/sqlite/sqlite_manager.dart';
import '/actions/actions.dart' as action_blocks;
import '/app_core/app_theme.dart';
import '/app_core/app_util.dart';
import 'index.dart'; // Imports other custom actions
import '/app_core/custom_functions.dart'; // Imports custom functions
import 'package:flutter/material.dart';
// Begin custom action code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

Future<int> daysSinceLastCheck(DateTime? date) async {
  if (date == null) {
    return 0;
  }
  DateTime now = DateTime.now();
  // Normalize both dates to midnight to ignore time components
  // This ensures we are counting calendar days, not 24-hour periods
  DateTime dateMidnight = DateTime(date.year, date.month, date.day);
  DateTime nowMidnight = DateTime(now.year, now.month, now.day);

  return nowMidnight.difference(dateMidnight).inDays;
}
