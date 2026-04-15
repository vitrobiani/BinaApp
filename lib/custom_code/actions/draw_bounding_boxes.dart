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

import 'dart:io';
import 'dart:typed_data';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';

Future<String> drawBoundingBoxes(
  String imagePath,
  List<dynamic> detections,
) async {
  // Load original image
  final imageFile = File(imagePath);
  final imageBytes = await imageFile.readAsBytes();
  img.Image? image = img.decodeImage(imageBytes);

  if (image == null) return imagePath;

  // Draw each detection
  for (final det in detections) {
    final detection = det as Map<String, dynamic>;
    final x1 = (detection['x1'] as double).toInt();
    final y1 = (detection['y1'] as double).toInt();
    final x2 = (detection['x2'] as double).toInt();
    final y2 = (detection['y2'] as double).toInt();
    final className = detection['className'] as String;
    final confidence = detection['confidence'] as double;

    // Draw rectangle (green color)
    final color = img.ColorRgb8(0, 255, 0);

    // Draw box edges
    img.drawRect(image,
        x1: x1, y1: y1, x2: x2, y2: y2, color: color, thickness: 3);

    // Draw label background
    final label = '$className ${(confidence * 100).toStringAsFixed(0)}%';
    img.fillRect(image,
        x1: x1, y1: y1 - 20, x2: x1 + label.length * 10, y2: y1, color: color);

    // Draw label text
    img.drawString(image, label,
        font: img.arial14,
        x: x1 + 2,
        y: y1 - 18,
        color: img.ColorRgb8(0, 0, 0));
  }

  // Save to temp file
  final tempDir = await getTemporaryDirectory();
  final outputPath =
      '${tempDir.path}/detection_result_${DateTime.now().millisecondsSinceEpoch}.jpg';
  final outputFile = File(outputPath);
  await outputFile.writeAsBytes(img.encodeJpg(image));

  return outputPath;
}
