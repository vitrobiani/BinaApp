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

// Conditional import - uses stub on web, native implementation on mobile/desktop
import 'yolo_inference_stub.dart'
    if (dart.library.io) 'yolo_inference_native.dart' as yolo_impl;

// Re-export the YoloResult class
export 'yolo_inference_stub.dart' show YoloResult;

// Class labels for the dental detection model (shared)
// const List<String> classLabels = [
//   'tooth_11', 'tooth_12', 'tooth_13', 'tooth_14', 'tooth_15', 'tooth_16', 'tooth_17', 'tooth_18',
//   'tooth_21', 'tooth_22', 'tooth_23', 'tooth_24', 'tooth_25', 'tooth_26', 'tooth_27', 'tooth_28',
//   'tooth_31', 'tooth_32', 'tooth_33', 'tooth_34', 'tooth_35', 'tooth_36', 'tooth_37', 'tooth_38',
//   'tooth_41', 'tooth_42', 'tooth_43', 'tooth_44', 'tooth_45', 'tooth_46', 'tooth_47', 'tooth_48',
//   'caries_shallow', 'caries_deep', 'restoration', 'crown_or_large_restoration',
//   'broken_tooth', 'tooth_discoloration', 'gingivitis', 'gum_recession', 'plaque', 'Ulcer'
// ];


const List<String> classLabels = [
  'caries', 'gingivitis', 'gum_recession', 'plaque', 'Ulcer'
];

const List<String> classLabelsMock = [
  'Cavity'
];
bool isMock = AppState().UserSession.isMock;

/// Runs YOLO inference on the given image
/// Returns a YoloResult with the annotated image path and detections
Future<yolo_impl.YoloResult> runYoloInference(String imagePath) async {
  return yolo_impl.runYoloInferenceImpl(imagePath, classLabels);
}

/// Lightweight inference for real-time preview (skips drawing/saving)
/// Returns only detection coordinates without annotating the image
Future<yolo_impl.YoloResult> runYoloInferenceLite(String imagePath) async {
  debugPrint("[YOLO_INF] Running mock: ");
  debugPrint(isMock.toString());
  return yolo_impl.runYoloInferenceImpl(imagePath, (!isMock) ? classLabelsMock : classLabels, drawDetections: false);
}
