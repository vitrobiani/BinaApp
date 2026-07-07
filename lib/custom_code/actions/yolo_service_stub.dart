// Stub implementation for web platform
// YoloService is not available on web

import 'dart:typed_data';

class YoloService {
  static final YoloService _instance = YoloService._internal();
  factory YoloService() => _instance;
  YoloService._internal();

  bool get isLoaded => false;

  Future<void> loadModel() async {
    // No-op on web
  }

  Future<List<Map<String, dynamic>>> inferFast(
    Uint8List imageBytes,
    int originalWidth,
    int originalHeight,
    List<String> classLabels,
  ) async {
    // Not supported on web
    return [];
  }

  void dispose() {
    // No-op on web
  }
}
