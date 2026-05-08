import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

class MjpegCaptureService {
  MjpegCaptureService._();

  static final MjpegCaptureService _instance = MjpegCaptureService._();
  static MjpegCaptureService get instance => _instance;

  static const int _connectionTimeout = 5;
  static const int _receiveTimeout = 10;

  Future<String?> captureFrame({
    required String cameraIP,
    int port = 8070,
  }) async {
    if (kIsWeb) {
      debugPrint('MjpegCaptureService: web platform not supported');
      return null;
    }

    final snapshotUrl = 'http://$cameraIP:$port/snapshot.jpg';
    debugPrint('MjpegCaptureService: capturing from $snapshotUrl');

    try {
      final response = await http.get(
        Uri.parse(snapshotUrl),
      ).timeout(
        const Duration(seconds: _connectionTimeout + _receiveTimeout),
      );

      if (response.statusCode == 200) {
        final bytes = response.bodyBytes;
        return await _saveImage(bytes);
      } else {
        debugPrint('MjpegCaptureService: HTTP ${response.statusCode}');
        return null;
      }
    } catch (e) {
      debugPrint('MjpegCaptureService: snapshot error: $e');
      // Fallback: try to parse a frame from the MJPEG stream
      return await _captureFromStream(cameraIP, port);
    }
  }

  Future<String?> _captureFromStream(String cameraIP, int port) async {
    final streamUrl = 'http://$cameraIP:$port/stream.mjpg';
    debugPrint('MjpegCaptureService: fallback - parsing stream from $streamUrl');

    try {
      final client = HttpClient();
      client.connectionTimeout = const Duration(seconds: _connectionTimeout);

      final request = await client.getUrl(Uri.parse(streamUrl));
      final response = await request.close();

      if (response.statusCode != 200) {
        debugPrint('MjpegCaptureService: stream HTTP ${response.statusCode}');
        client.close();
        return null;
      }

      // MJPEG frames are separated by boundaries and contain JPEG data
      // Look for JPEG markers: 0xFF 0xD8 (start) and 0xFF 0xD9 (end)
      final bytes = <int>[];
      bool foundStart = false;
      int prevByte = 0;

      await for (final chunk in response) {
        for (final byte in chunk) {
          if (!foundStart) {
            // Look for JPEG start marker: 0xFF 0xD8
            if (prevByte == 0xFF && byte == 0xD8) {
              foundStart = true;
              bytes.add(0xFF);
              bytes.add(0xD8);
            }
            prevByte = byte;
          } else {
            bytes.add(byte);
            // Look for JPEG end marker: 0xFF 0xD9
            if (prevByte == 0xFF && byte == 0xD9) {
              // Found complete JPEG
              client.close();
              return await _saveImage(Uint8List.fromList(bytes));
            }
            prevByte = byte;
          }

          // Safety limit: 10MB max
          if (bytes.length > 10 * 1024 * 1024) {
            debugPrint('MjpegCaptureService: frame too large, aborting');
            client.close();
            return null;
          }
        }
      }

      client.close();
      debugPrint('MjpegCaptureService: no complete frame found');
      return null;
    } catch (e) {
      debugPrint('MjpegCaptureService: stream error: $e');
      return null;
    }
  }

  Future<String?> _saveImage(Uint8List bytes) async {
    try {
      final tempDir = await getTemporaryDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final file = File('${tempDir.path}/bina_capture_$timestamp.jpg');
      await file.writeAsBytes(bytes);
      debugPrint('MjpegCaptureService: saved to ${file.path}');
      return file.path;
    } catch (e) {
      debugPrint('MjpegCaptureService: save error: $e');
      return null;
    }
  }

  Future<bool> testConnection({
    required String cameraIP,
    int port = 8070,
  }) async {
    if (kIsWeb) return false;

    final snapshotUrl = 'http://$cameraIP:$port/snapshot.jpg';

    try {
      final response = await http.head(
        Uri.parse(snapshotUrl),
      ).timeout(
        const Duration(seconds: _connectionTimeout),
      );

      return response.statusCode == 200;
    } catch (e) {
      // Try the stream URL
      final streamUrl = 'http://$cameraIP:$port/stream.mjpg';
      try {
        final response = await http.head(
          Uri.parse(streamUrl),
        ).timeout(
          const Duration(seconds: _connectionTimeout),
        );

        return response.statusCode == 200;
      } catch (e) {
        return false;
      }
    }
  }

  String getStreamUrl({
    required String cameraIP,
    int port = 8070,
  }) {
    return 'http://$cameraIP:$port/stream.mjpg';
  }

  String getSnapshotUrl({
    required String cameraIP,
    int port = 8070,
  }) {
    return 'http://$cameraIP:$port/snapshot.jpg';
  }
}
