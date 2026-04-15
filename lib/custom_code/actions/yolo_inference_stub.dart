// Stub implementation for web platform
// TFLite is not supported on web, so we return a placeholder result

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
  print('YOLO inference is not supported on web platform');
  return YoloResult(
    imagePath: imagePath,
    detections: [],
    isWebPlatform: true,
  );
}
