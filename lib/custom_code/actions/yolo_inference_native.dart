// Native implementation for mobile/desktop platforms
// Uses TFLite for inference with GPU acceleration

import 'dart:io';
import 'dart:typed_data';
import 'dart:math';
import 'package:flutter/foundation.dart';
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

/// Singleton service for YOLO inference - loads model once and reuses it
class YoloService {
  static final YoloService _instance = YoloService._internal();
  factory YoloService() => _instance;
  YoloService._internal();

  Interpreter? _interpreter;
  List<int>? _inputShape;
  List<int>? _outputShape;
  bool _isLoading = false;

  final double minConfScore = 0.15;

  bool get isLoaded => _interpreter != null;

  /// Initialize the model (call once at app start or before first use)
  Future<void> loadModel() async {
    if (_interpreter != null || _isLoading) return;
    _isLoading = true;

    try {
      final options = InterpreterOptions();
      options.threads = 4; // Use multiple CPU threads

      // Try GPU delegate on Android
      if (Platform.isAndroid) {
        try {
          final gpuDelegate = GpuDelegateV2();
          options.addDelegate(gpuDelegate);
          debugPrint('>>> YOLO: GPU delegate added');
        } catch (e) {
          debugPrint('>>> YOLO: GPU delegate failed: $e, using CPU only');
        }
      }

      _interpreter = await Interpreter.fromAsset(
        // 'assets/best_model.tflite',
        'assets/cavity_detector_no_nms.tflite',
        // 'assets/best_float32.tflite',
        options: options,
      );

      _inputShape = _interpreter!.getInputTensor(0).shape;
      _outputShape = _interpreter!.getOutputTensor(0).shape;

      debugPrint('>>> YOLO: Model loaded successfully');
      debugPrint('>>> YOLO: Input shape: $_inputShape');
      debugPrint('>>> YOLO: Output shape: $_outputShape');
    } catch (e) {
      debugPrint('>>> YOLO: Failed to load model: $e');
      _interpreter = null;
    } finally {
      _isLoading = false;
    }
  }

  /// Fast inference for real-time - returns only detections, no image processing
  Future<List<Map<String, dynamic>>> inferFast(
    Uint8List imageBytes,
    int originalWidth,
    int originalHeight,
    List<String> classLabels,
  ) async {
    if (_interpreter == null) {
      await loadModel();
      if (_interpreter == null) return [];
    }

    final sw = Stopwatch()..start();

    try {
      final inputHeight = _inputShape![1];
      final inputWidth = _inputShape![2];

      // Decode image
      img.Image? image = img.decodeImage(imageBytes);
      if (image == null) return [];
      final decodeTime = sw.elapsedMilliseconds;

      // Resize
      final resizedImage = img.copyResize(
        image,
        width: inputWidth,
        height: inputHeight,
        interpolation: img.Interpolation.nearest,
      );
      final resizeTime = sw.elapsedMilliseconds;

      // Prepare input tensor - OPTIMIZED: multiply instead of divide
      final inputBuffer = Float32List(1 * inputHeight * inputWidth * 3);
      const double scale = 1.0 / 255.0;
      int bufIdx = 0;

      for (final pixel in resizedImage) {
        inputBuffer[bufIdx++] = pixel.r * scale;
        inputBuffer[bufIdx++] = pixel.g * scale;
        inputBuffer[bufIdx++] = pixel.b * scale;
      }

      final input = inputBuffer.reshape([1, inputHeight, inputWidth, 3]);
      final prepareTime = sw.elapsedMilliseconds;

      // Prepare output tensor
      final output = List.generate(
        _outputShape![0],
        (_) => List.generate(
          _outputShape![1],
          (_) => List.filled(_outputShape![2], 0.0),
        ),
      );

      // Run inference
      _interpreter!.run(input, output);
      final inferTime = sw.elapsedMilliseconds;

      debugPrint('>>> INFER DETAIL: decode=${decodeTime}ms, resize=${resizeTime - decodeTime}ms, prep=${prepareTime - resizeTime}ms, model=${inferTime - prepareTime}ms');

      // Parse detections
      return _parseDetections(
        output,
        originalWidth,
        originalHeight,
        inputWidth,
        inputHeight,
        classLabels,
      );
    } catch (e) {
      debugPrint('>>> YOLO inference error: $e');
      return [];
    }
  }

  List<Map<String, dynamic>> _parseDetections(
    List<List<List<double>>> output,
    int originalWidth,
    int originalHeight,
    int inputWidth,
    int inputHeight,
    List<String> classLabels,
  ) {
    List<Map<String, dynamic>> detections = [];

    final bool isNMSFormat = _outputShape![2] <= 6 || _outputShape![2] <= classLabels.length + 5;

    if (isNMSFormat) {
      final numDetections = _outputShape![1];

      for (int i = 0; i < numDetections; i++) {
        final confidence = output[0][i][4];
        if (confidence < minConfScore) continue;

        final rawX1 = output[0][i][0];
        final rawY1 = output[0][i][1];
        final rawX2 = output[0][i][2];
        final rawY2 = output[0][i][3];
        final classIdRaw = output[0][i][5];
        final classId = classIdRaw.round().clamp(0, classLabels.length - 1);

        bool isNormalized = rawX1 <= 1.0 && rawY1 <= 1.0 && rawX2 <= 1.0 && rawY2 <= 1.0 &&
                           rawX1 >= 0.0 && rawY1 >= 0.0;

        double x1, y1, x2, y2;

        if (isNormalized) {
          x1 = (rawX1 * originalWidth).clamp(0.0, originalWidth.toDouble());
          y1 = (rawY1 * originalHeight).clamp(0.0, originalHeight.toDouble());
          x2 = (rawX2 * originalWidth).clamp(0.0, originalWidth.toDouble());
          y2 = (rawY2 * originalHeight).clamp(0.0, originalHeight.toDouble());
        } else {
          x1 = (rawX1 / inputWidth * originalWidth).clamp(0.0, originalWidth.toDouble());
          y1 = (rawY1 / inputHeight * originalHeight).clamp(0.0, originalHeight.toDouble());
          x2 = (rawX2 / inputWidth * originalWidth).clamp(0.0, originalWidth.toDouble());
          y2 = (rawY2 / inputHeight * originalHeight).clamp(0.0, originalHeight.toDouble());
        }

        if (x2 <= x1 || y2 <= y1) continue;

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
    } else {
      // Raw YOLO format
      final numBoxes = _outputShape![2];
      final numFeatures = _outputShape![1];
      final numClasses = classLabels.length;

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

        if (maxScore > minConfScore) {
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

      detections = _applyNMS(detections, 0.45);
    }

    return detections;
  }

  void dispose() {
    _interpreter?.close();
    _interpreter = null;
  }
}

// Keep the original function for backward compatibility
Future<YoloResult> runYoloInferenceImpl(String imagePath, List<String> classLabels, {bool drawDetections = true}) async {
  final service = YoloService();

  try {
    // Load image
    final imageFile = File(imagePath);
    final imageBytes = await imageFile.readAsBytes();
    img.Image? originalImage = img.decodeImage(imageBytes);

    if (originalImage == null) {
      print('Failed to decode image');
      return YoloResult(imagePath: imagePath, detections: []);
    }

    final originalWidth = originalImage.width;
    final originalHeight = originalImage.height;

    if (drawDetections) {
      print('Original image size: ${originalWidth}x${originalHeight}');
    }

    // Run inference
    final detections = await service.inferFast(
      imageBytes,
      originalWidth,
      originalHeight,
      classLabels,
    );

    if (drawDetections) {
      print('Total detections: ${detections.length}');
      for (int i = 0; i < detections.length; i++) {
        final det = detections[i];
        print('Detection $i: class=${det['className']}, conf=${(det['confidence'] as double).toStringAsFixed(2)}');
      }
    }

    // Only draw bounding boxes if requested
    if (drawDetections) {
      final annotatedImagePath = await _drawDetections(originalImage, detections, classLabels);
      return YoloResult(imagePath: annotatedImagePath, detections: detections);
    }

    return YoloResult(imagePath: imagePath, detections: detections);

  } catch (e, stackTrace) {
    print('Error running YOLO inference: $e');
    print('Stack trace: $stackTrace');
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
    'cavity': img.ColorRgb8(255, 0, 0),
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
    final lowerName = className.toLowerCase();
    if (lowerName.startsWith('tooth_')) return categoryColors['tooth']!;
    if (lowerName.contains('caries') || lowerName.contains('cavity')) return categoryColors['cavity']!;
    if (lowerName.contains('restoration')) return categoryColors['restoration']!;
    if (lowerName.contains('crown')) return categoryColors['crown']!;
    if (lowerName.contains('broken')) return categoryColors['broken']!;
    if (lowerName.contains('discoloration')) return categoryColors['discoloration']!;
    if (lowerName.contains('gingivitis')) return categoryColors['gingivitis']!;
    if (lowerName.contains('gum')) return categoryColors['gum']!;
    if (lowerName.contains('plaque')) return categoryColors['plaque']!;
    if (lowerName.contains('ulcer')) return categoryColors['ulcer']!;
    return img.ColorRgb8(255, 0, 0); // Default red for cavity detection
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
  final encodedImage = img.encodeJpg(image, quality: 90);
  await outputFile.writeAsBytes(encodedImage);

  return outputPath;
}
