// Native implementation for mobile/desktop platforms
// Uses TFLite for inference

import 'dart:io';
import 'dart:typed_data';
import 'dart:math';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';

class YoloResult {
  final String imagePath;
  final List<Map<String, dynamic>> detections;
  final bool isWebPlatform;

  YoloResult({
    required this.imagePath,
    required this.detections,
    this.isWebPlatform = false,
  });
}

Future<YoloResult> runYoloInferenceImpl(String imagePath, List<String> classLabels) async {
  Interpreter? interpreter;

  try {
    // Load the model from assets
    interpreter = await Interpreter.fromAsset('assets/yolo11n_float16.tflite');

    // Get input and output shapes
    final inputShape = interpreter.getInputTensor(0).shape;
    final outputShape = interpreter.getOutputTensor(0).shape;

    print('YOLO Input shape: $inputShape');
    print('YOLO Output shape: $outputShape');

    final inputHeight = inputShape[1];
    final inputWidth = inputShape[2];

    // Load and preprocess the image
    final imageFile = File(imagePath);
    final imageBytes = await imageFile.readAsBytes();
    img.Image? originalImage = img.decodeImage(imageBytes);

    if (originalImage == null) {
      print('Failed to decode image');
      return YoloResult(imagePath: imagePath, detections: []);
    }

    final originalWidth = originalImage.width;
    final originalHeight = originalImage.height;
    print('Original image size: ${originalWidth}x${originalHeight}');
    print('Input size: ${inputWidth}x${inputHeight}');

    // Resize image to model input size
    final resizedImage = img.copyResize(
      originalImage,
      width: inputWidth,
      height: inputHeight,
      interpolation: img.Interpolation.linear,
    );

    // Prepare input tensor - normalize to 0-1 and convert to float32
    final inputBuffer = Float32List(1 * inputHeight * inputWidth * 3);
    int pixelIndex = 0;

    for (int y = 0; y < inputHeight; y++) {
      for (int x = 0; x < inputWidth; x++) {
        final pixel = resizedImage.getPixel(x, y);
        inputBuffer[pixelIndex++] = pixel.r / 255.0;
        inputBuffer[pixelIndex++] = pixel.g / 255.0;
        inputBuffer[pixelIndex++] = pixel.b / 255.0;
      }
    }

    final input = inputBuffer.reshape([1, inputHeight, inputWidth, 3]);

    // Prepare output tensor
    final output = List.generate(
      outputShape[0],
      (_) => List.generate(
        outputShape[1],
        (_) => List.filled(outputShape[2], 0.0),
      ),
    );

    // Run inference
    interpreter.run(input, output);

    // Process output
    List<Map<String, dynamic>> detections = [];

    // Detect output format based on shape
    // Format A (with built-in NMS): [1, num_detections, 6] where 6 = [x1, y1, x2, y2, conf, class_id]
    // Format B (raw YOLO): [1, num_features, num_boxes] where features = 4 + num_classes

    final bool isNMSFormat = outputShape[2] <= 6 || outputShape[2] <= classLabels.length + 5;

    print('Output format detected: ${isNMSFormat ? "NMS (post-processed)" : "Raw YOLO"}');
    print('Output shape: [${outputShape[0]}, ${outputShape[1]}, ${outputShape[2]}]');

    if (isNMSFormat) {
      // Format: [1, 300, 6] - Model has built-in NMS
      // Each detection: [x1, y1, x2, y2, confidence, class_id]
      final numDetections = outputShape[1];
      final numFeatures = outputShape[2];

      print('NMS Format - Num detections: $numDetections, Features per detection: $numFeatures');

      // Sample raw output for debugging
      if (numDetections > 0) {
        print('First detection raw: [${output[0][0][0]}, ${output[0][0][1]}, ${output[0][0][2]}, ${output[0][0][3]}, ${output[0][0][4]}, ${output[0][0][5]}]');
      }

      for (int i = 0; i < numDetections; i++) {
        // Access: output[batch][detection_index][feature]
        final confidence = output[0][i][4];

        // Skip low confidence or empty detections
        if (confidence < 0.25) continue;

        final rawX1 = output[0][i][0];
        final rawY1 = output[0][i][1];
        final rawX2 = output[0][i][2];
        final rawY2 = output[0][i][3];
        final classIdRaw = output[0][i][5];
        final classId = classIdRaw.round().clamp(0, classLabels.length - 1);

        // Determine if coordinates are normalized (0-1) or in pixels
        bool isNormalized = rawX1 <= 1.0 && rawY1 <= 1.0 && rawX2 <= 1.0 && rawY2 <= 1.0 &&
                           rawX1 >= 0.0 && rawY1 >= 0.0;

        double x1, y1, x2, y2;

        if (isNormalized) {
          // Normalized coordinates - scale to original image
          x1 = (rawX1 * originalWidth).clamp(0.0, originalWidth.toDouble());
          y1 = (rawY1 * originalHeight).clamp(0.0, originalHeight.toDouble());
          x2 = (rawX2 * originalWidth).clamp(0.0, originalWidth.toDouble());
          y2 = (rawY2 * originalHeight).clamp(0.0, originalHeight.toDouble());
        } else {
          // Pixel coordinates relative to input size - scale to original
          x1 = (rawX1 / inputWidth * originalWidth).clamp(0.0, originalWidth.toDouble());
          y1 = (rawY1 / inputHeight * originalHeight).clamp(0.0, originalHeight.toDouble());
          x2 = (rawX2 / inputWidth * originalWidth).clamp(0.0, originalWidth.toDouble());
          y2 = (rawY2 / inputHeight * originalHeight).clamp(0.0, originalHeight.toDouble());
        }

        // Skip invalid boxes
        if (x2 <= x1 || y2 <= y1) continue;

        print('Detection $i: class=${classLabels[classId]}, conf=${confidence.toStringAsFixed(2)}, '
              'raw=($rawX1, $rawY1, $rawX2, $rawY2), classId=$classIdRaw, '
              'box=(${x1.toStringAsFixed(0)}, ${y1.toStringAsFixed(0)}, ${x2.toStringAsFixed(0)}, ${y2.toStringAsFixed(0)})');

        detections.add({
          'x1': x1,
          'y1': y1,
          'x2': x2,
          'y2': y2,
          'className': classLabels[classId],
          'classIndex': classId,
          'confidence': confidence,
        });
      }

      print('Total detections (NMS already applied by model): ${detections.length}');

    } else {
      // Format: [1, num_features, num_boxes] - Raw YOLO output
      final numBoxes = outputShape[2];
      final numFeatures = outputShape[1];
      final numClasses = classLabels.length;

      print('Raw Format - Num boxes: $numBoxes, Num features: $numFeatures');

      // Sample raw output for debugging
      if (numBoxes > 0) {
        print('Sample raw output [0][0][0]: ${output[0][0][0]}');
        print('Sample raw output [0][1][0]: ${output[0][1][0]}');
        print('Sample raw output [0][2][0]: ${output[0][2][0]}');
        print('Sample raw output [0][3][0]: ${output[0][3][0]}');
      }

      for (int i = 0; i < numBoxes; i++) {
        final xCenter = output[0][0][i];
        final yCenter = output[0][1][i];
        final bboxWidth = output[0][2][i];
        final bboxHeight = output[0][3][i];

        double maxScore = 0;
        int maxClassIdx = 0;

        for (int c = 0; c < numClasses && (4 + c) < numFeatures; c++) {
          final score = output[0][4 + c][i];
          if (score > maxScore) {
            maxScore = score;
            maxClassIdx = c;
          }
        }

        if (maxScore > 0.25) {
          bool isNormalized = xCenter <= 1.0 && yCenter <= 1.0 && bboxWidth <= 1.0 && bboxHeight <= 1.0;

          double x1, y1, x2, y2;

          if (isNormalized) {
            x1 = ((xCenter - bboxWidth / 2) * originalWidth).clamp(0.0, originalWidth.toDouble());
            y1 = ((yCenter - bboxHeight / 2) * originalHeight).clamp(0.0, originalHeight.toDouble());
            x2 = ((xCenter + bboxWidth / 2) * originalWidth).clamp(0.0, originalWidth.toDouble());
            y2 = ((yCenter + bboxHeight / 2) * originalHeight).clamp(0.0, originalHeight.toDouble());
          } else {
            x1 = ((xCenter - bboxWidth / 2) / inputWidth * originalWidth).clamp(0.0, originalWidth.toDouble());
            y1 = ((yCenter - bboxHeight / 2) / inputHeight * originalHeight).clamp(0.0, originalHeight.toDouble());
            x2 = ((xCenter + bboxWidth / 2) / inputWidth * originalWidth).clamp(0.0, originalWidth.toDouble());
            y2 = ((yCenter + bboxHeight / 2) / inputHeight * originalHeight).clamp(0.0, originalHeight.toDouble());
          }

          print('Detection $i: class=${classLabels[maxClassIdx]}, conf=${maxScore.toStringAsFixed(2)}, '
                'raw=(${xCenter.toStringAsFixed(1)}, ${yCenter.toStringAsFixed(1)}, ${bboxWidth.toStringAsFixed(1)}, ${bboxHeight.toStringAsFixed(1)}), '
                'normalized=$isNormalized, '
                'box=(${x1.toStringAsFixed(0)}, ${y1.toStringAsFixed(0)}, ${x2.toStringAsFixed(0)}, ${y2.toStringAsFixed(0)})');

          detections.add({
            'x1': x1,
            'y1': y1,
            'x2': x2,
            'y2': y2,
            'className': classLabels[maxClassIdx],
            'classIndex': maxClassIdx,
            'confidence': maxScore,
          });
        }
      }

      print('Total detections before NMS: ${detections.length}');
      detections = _applyNMS(detections, 0.45);
      print('Total detections after NMS: ${detections.length}');
    }

    // Draw bounding boxes
    final annotatedImagePath = await _drawDetections(originalImage, detections, classLabels);

    print('Annotated image saved to: $annotatedImagePath');

    interpreter.close();

    return YoloResult(imagePath: annotatedImagePath, detections: detections);

  } catch (e, stackTrace) {
    print('Error running YOLO inference: $e');
    print('Stack trace: $stackTrace');
    interpreter?.close();
    return YoloResult(imagePath: imagePath, detections: []);
  }
}

List<Map<String, dynamic>> _applyNMS(List<Map<String, dynamic>> detections, double iouThreshold) {
  if (detections.isEmpty) return detections;

  detections.sort((a, b) => (b['confidence'] as double).compareTo(a['confidence'] as double));

  List<Map<String, dynamic>> result = [];
  List<bool> suppressed = List.filled(detections.length, false);

  for (int i = 0; i < detections.length; i++) {
    if (suppressed[i]) continue;
    result.add(detections[i]);

    for (int j = i + 1; j < detections.length; j++) {
      if (suppressed[j]) continue;
      final iou = _calculateIoU(detections[i], detections[j]);
      if (iou > iouThreshold) {
        suppressed[j] = true;
      }
    }
  }

  return result;
}

double _calculateIoU(Map<String, dynamic> box1, Map<String, dynamic> box2) {
  final x1 = max(box1['x1'] as double, box2['x1'] as double);
  final y1 = max(box1['y1'] as double, box2['y1'] as double);
  final x2 = min(box1['x2'] as double, box2['x2'] as double);
  final y2 = min(box1['y2'] as double, box2['y2'] as double);

  final intersectionWidth = max(0.0, x2 - x1);
  final intersectionHeight = max(0.0, y2 - y1);
  final intersectionArea = intersectionWidth * intersectionHeight;

  final area1 = (box1['x2'] - box1['x1']) * (box1['y2'] - box1['y1']);
  final area2 = (box2['x2'] - box2['x1']) * (box2['y2'] - box2['y1']);

  final unionArea = area1 + area2 - intersectionArea;

  return unionArea > 0 ? intersectionArea / unionArea : 0;
}

Future<String> _drawDetections(img.Image image, List<Map<String, dynamic>> detections, List<String> classLabels) async {
  print('Drawing ${detections.length} detections on image ${image.width}x${image.height}');

  final Map<String, img.Color> categoryColors = {
    'tooth': img.ColorRgb8(0, 255, 0),
    'caries': img.ColorRgb8(255, 0, 0),
    'restoration': img.ColorRgb8(0, 0, 255),
    'crown': img.ColorRgb8(0, 0, 255),
    'broken': img.ColorRgb8(255, 165, 0),
    'discoloration': img.ColorRgb8(255, 255, 0),
    'gingivitis': img.ColorRgb8(255, 0, 255),
    'gum': img.ColorRgb8(255, 0, 255),
    'plaque': img.ColorRgb8(255, 128, 0),
    'ulcer': img.ColorRgb8(128, 0, 128),
  };

  img.Color getColorForClass(String className) {
    if (className.startsWith('tooth_')) return categoryColors['tooth']!;
    if (className.contains('caries')) return categoryColors['caries']!;
    if (className.contains('restoration')) return categoryColors['restoration']!;
    if (className.contains('crown')) return categoryColors['crown']!;
    if (className.contains('broken')) return categoryColors['broken']!;
    if (className.contains('discoloration')) return categoryColors['discoloration']!;
    if (className.contains('gingivitis')) return categoryColors['gingivitis']!;
    if (className.contains('gum')) return categoryColors['gum']!;
    if (className.contains('plaque')) return categoryColors['plaque']!;
    if (className.toLowerCase().contains('ulcer')) return categoryColors['ulcer']!;
    return img.ColorRgb8(0, 255, 0);
  }

  for (final det in detections) {
    final x1 = (det['x1'] as double).toInt().clamp(0, image.width - 1);
    final y1 = (det['y1'] as double).toInt().clamp(0, image.height - 1);
    final x2 = (det['x2'] as double).toInt().clamp(0, image.width - 1);
    final y2 = (det['y2'] as double).toInt().clamp(0, image.height - 1);
    final className = det['className'] as String;
    final confidence = det['confidence'] as double;

    print('Drawing box: ($x1, $y1) to ($x2, $y2) for $className');

    if (x2 <= x1 || y2 <= y1) {
      print('Skipping invalid box');
      continue;
    }

    final color = getColorForClass(className);

    img.drawRect(image, x1: x1, y1: y1, x2: x2, y2: y2, color: color, thickness: 4);

    final label = '$className ${(confidence * 100).toStringAsFixed(0)}%';
    final labelWidth = label.length * 8;
    final labelHeight = 18;

    final bgY1 = (y1 - labelHeight).clamp(0, image.height - 1);
    final bgY2 = y1.clamp(0, image.height - 1);
    final bgX2 = (x1 + labelWidth).clamp(0, image.width - 1);

    if (bgY2 > bgY1 && bgX2 > x1) {
      img.fillRect(image, x1: x1, y1: bgY1, x2: bgX2, y2: bgY2, color: color);
      img.drawString(image, label, font: img.arial14, x: x1 + 2, y: bgY1 + 2,
          color: img.ColorRgb8(255, 255, 255));
    }
  }

  final tempDir = await getTemporaryDirectory();
  final outputPath = '${tempDir.path}/diagnosis_result_${DateTime.now().millisecondsSinceEpoch}.jpg';
  final outputFile = File(outputPath);
  final encodedImage = img.encodeJpg(image, quality: 95);
  await outputFile.writeAsBytes(encodedImage);

  print('Saved annotated image: $outputPath (${encodedImage.length} bytes)');

  return outputPath;
}
