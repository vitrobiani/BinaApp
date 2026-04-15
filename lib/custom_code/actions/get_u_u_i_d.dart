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

import 'package:uuid/uuid.dart';

Future<String> getUUID() async {
  return Uuid().v4();
}
