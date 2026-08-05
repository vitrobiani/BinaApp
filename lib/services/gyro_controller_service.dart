import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '/app_state.dart';

/// Accelerometer reading (LIS3DH, ±2g range).
class GyroAccel {
  final double x;
  final double y;
  final double z;
  final String unit;
  final String? error;

  GyroAccel({
    required this.x,
    required this.y,
    required this.z,
    this.unit = 'g',
    this.error,
  });

  factory GyroAccel.fromJson(Map<String, dynamic> json) {
    if (json['error'] != null) {
      return GyroAccel.errored(json['error'].toString());
    }
    return GyroAccel(
      x: (json['x'] as num?)?.toDouble() ?? 0.0,
      y: (json['y'] as num?)?.toDouble() ?? 0.0,
      z: (json['z'] as num?)?.toDouble() ?? 0.0,
      unit: json['unit']?.toString() ?? 'g',
    );
  }

  factory GyroAccel.errored(String message) {
    return GyroAccel(x: 0, y: 0, z: 0, error: message);
  }

  bool get hasError => error != null;
}

/// Orientation derived from accelerometer (pitch/roll in degrees).
class GyroOrientation {
  final double pitch;
  final double roll;
  final String unit;
  final String? error;

  GyroOrientation({
    required this.pitch,
    required this.roll,
    this.unit = 'degrees',
    this.error,
  });

  factory GyroOrientation.fromJson(Map<String, dynamic> json) {
    if (json['error'] != null) {
      return GyroOrientation.errored(json['error'].toString());
    }
    return GyroOrientation(
      pitch: (json['pitch'] as num?)?.toDouble() ?? 0.0,
      roll: (json['roll'] as num?)?.toDouble() ?? 0.0,
      unit: json['unit']?.toString() ?? 'degrees',
    );
  }

  factory GyroOrientation.errored(String message) {
    return GyroOrientation(pitch: 0, roll: 0, error: message);
  }

  bool get hasError => error != null;
}

/// Sensor hardware status (from /gyro/status).
class GyroSensorStatus {
  final bool initialized;
  final String? deviceId;
  final String? expectedId;
  final String? sensorType;
  final String? accelRange;
  final String? i2cAddress;
  final String? error;

  GyroSensorStatus({
    required this.initialized,
    this.deviceId,
    this.expectedId,
    this.sensorType,
    this.accelRange,
    this.i2cAddress,
    this.error,
  });

  factory GyroSensorStatus.fromJson(Map<String, dynamic> json) {
    return GyroSensorStatus(
      initialized: json['initialized'] == true,
      deviceId: json['device_id']?.toString(),
      expectedId: json['expected_id']?.toString(),
      sensorType: json['sensor_type']?.toString(),
      accelRange: json['accel_range']?.toString(),
      i2cAddress: json['i2c_address']?.toString(),
      error: json['error']?.toString(),
    );
  }

  factory GyroSensorStatus.errored(String message) {
    return GyroSensorStatus(initialized: false, error: message);
  }

  bool get hasError => error != null;
}

/// Full IMU reading from /gyro (accelerometer + placeholders for gyro/mag).
class GyroReading {
  final GyroAccel? accelerometer;
  final Map<String, dynamic>? gyroscope;
  final Map<String, dynamic>? magnetometer;
  final double? timestamp;
  final String? error;

  GyroReading({
    this.accelerometer,
    this.gyroscope,
    this.magnetometer,
    this.timestamp,
    this.error,
  });

  factory GyroReading.fromJson(Map<String, dynamic> json) {
    if (json['error'] != null &&
        json['accelerometer'] == null &&
        json['gyroscope'] == null) {
      return GyroReading.errored(json['error'].toString());
    }
    final accelJson = json['accelerometer'];
    return GyroReading(
      accelerometer: accelJson is Map<String, dynamic>
          ? GyroAccel.fromJson(accelJson)
          : null,
      gyroscope: json['gyroscope'] is Map<String, dynamic>
          ? json['gyroscope'] as Map<String, dynamic>
          : null,
      magnetometer: json['magnetometer'] is Map<String, dynamic>
          ? json['magnetometer'] as Map<String, dynamic>
          : null,
      timestamp: (json['timestamp'] as num?)?.toDouble(),
    );
  }

  factory GyroReading.errored(String message) {
    return GyroReading(error: message);
  }

  bool get hasError => error != null;
}

/// Read-only service for the Bina IMU sensor (LIS3DH) via REST API.
///
/// Shares the control-api host/port with [MotorControllerService] (default
/// port 8071). All endpoints are GET; the sensor is read-only.
class GyroControllerService {
  GyroControllerService._();

  static final GyroControllerService _instance = GyroControllerService._();
  static GyroControllerService get instance => _instance;

  static const int defaultPort = 8071;
  static const Duration _timeout = Duration(seconds: 5);

  String? _host;
  int _port = defaultPort;

  http.Client _client = http.Client();

  /// Test-only seam. Lets unit tests inject a `MockClient` from
  /// `package:http/testing.dart` without touching the singleton reset dance.
  @visibleForTesting
  set httpClient(http.Client client) => _client = client;

  void configure({required String host, int port = defaultPort}) {
    _host = host;
    _port = port;
    debugPrint('GyroControllerService: configured for $host:$port');
  }

  /// Configure from the current camera connection in AppState.
  /// Returns true if configured successfully, false if no camera is connected.
  bool configureFromCamera() {
    final cameraConnection = AppState().cameraConnection;
    if (!cameraConnection.isCameraConnected()) {
      debugPrint('GyroControllerService: no camera connected');
      return false;
    }
    configure(host: cameraConnection.cameraHost);
    return true;
  }

  bool get isConfigured => _host != null && _host!.isNotEmpty;
  String? get host => _host;
  int get port => _port;

  String get _baseUrl => 'http://$_host:$_port';

  Future<Map<String, dynamic>?> _getJson(String path) async {
    if (!isConfigured) {
      debugPrint('[Gyro] _getJson($path) skipped — not configured');
      return null;
    }
    final url = '$_baseUrl$path';
    try {
      final response = await _client.get(Uri.parse(url)).timeout(_timeout);
      debugPrint('[Gyro] $url → HTTP ${response.statusCode}, body: ${response.body}');
      if (response.statusCode == 200 || response.statusCode == 500) {
        // The backend returns 500 with a JSON error body when the sensor
        // is unavailable — still parse it so callers see the error field.
        return jsonDecode(response.body) as Map<String, dynamic>;
      }
      return {'error': 'HTTP ${response.statusCode}'};
    } catch (e) {
      debugPrint('[Gyro] $url threw: $e');
      return {'error': e.toString()};
    }
  }

  /// Full IMU dump: `/gyro`.
  Future<GyroReading> read() async {
    final json = await _getJson('/gyro');
    if (json == null) return GyroReading.errored('Gyro controller not configured');
    return GyroReading.fromJson(json);
  }

  /// Accelerometer reading in g: `/gyro/accel`.
  Future<GyroAccel> readAccel() async {
    final json = await _getJson('/gyro/accel');
    if (json == null) return GyroAccel.errored('Gyro controller not configured');
    return GyroAccel.fromJson(json);
  }

  /// Derived pitch/roll in degrees: `/gyro/orientation`.
  Future<GyroOrientation> readOrientation() async {
    final json = await _getJson('/gyro/orientation');
    if (json == null) {
      return GyroOrientation.errored('Gyro controller not configured');
    }
    return GyroOrientation.fromJson(json);
  }

  /// Sensor hardware status: `/gyro/status`.
  Future<GyroSensorStatus> getStatus() async {
    final json = await _getJson('/gyro/status');
    if (json == null) {
      return GyroSensorStatus.errored('Gyro controller not configured');
    }
    return GyroSensorStatus.fromJson(json);
  }

  /// Read orientation and return integer (pitch, roll) tuple clamped to
  /// [-180, 180]. Returns `(null, null)` if the sensor is not configured,
  /// unreachable, or reports an error — capture flows should treat this as
  /// "orientation unknown" and continue.
  ///
  /// Self-heals: if the service isn't configured yet but a camera connection
  /// exists in [AppState], we lazy-configure before reading. Every failure
  /// path is logged so the console shows exactly why we returned nulls.
  Future<({int? pitch, int? roll})> readOrientationInts() async {
    debugPrint('[Gyro] readOrientationInts() called. isConfigured=$isConfigured host=$_host port=$_port');

    if (!isConfigured) {
      final ok = configureFromCamera();
      debugPrint('[Gyro] auto-configureFromCamera returned $ok (host now: $_host)');
      if (!ok) {
        debugPrint('[Gyro] ❌ no camera connection in AppState — returning (null, null)');
        return (pitch: null, roll: null);
      }
    }

    debugPrint('[Gyro] GET $_baseUrl/gyro/orientation');
    final o = await readOrientation();
    if (o.hasError) {
      debugPrint('[Gyro] ❌ orientation unavailable: ${o.error} — returning (null, null)');
      return (pitch: null, roll: null);
    }

    final result = (
      pitch: o.pitch.round().clamp(-180, 180),
      roll: o.roll.round().clamp(-180, 180),
    );
    debugPrint('[Gyro] ✅ raw pitch=${o.pitch} roll=${o.roll} → clamped ${result.pitch}, ${result.roll}');
    return result;
  }

  /// Verify the sensor is reachable and initialized.
  Future<bool> testConnection() async {
    if (!isConfigured) return false;
    final status = await getStatus();
    return status.initialized;
  }

  void disconnect() {
    _host = null;
    _port = defaultPort;
    debugPrint('GyroControllerService: disconnected');
  }
}
