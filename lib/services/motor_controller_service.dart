import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '/app_state.dart';

/// Motor direction for movement commands.
enum MotorDirection {
  forward,
  backward,
}

/// Motor status returned from the API.
class MotorStatus {
  final bool isEnabled;
  final bool isMoving;
  final int currentPosition;
  final String? error;

  MotorStatus({
    required this.isEnabled,
    required this.isMoving,
    required this.currentPosition,
    this.error,
  });

  factory MotorStatus.fromJson(Map<String, dynamic> json) {
    return MotorStatus(
      isEnabled: json['is_enabled'] ?? json['enabled'] ?? false,
      isMoving: json['is_moving'] ?? json['moving'] ?? false,
      currentPosition: json['current_position'] ?? json['position'] ?? 0,
      error: json['error'],
    );
  }

  factory MotorStatus.error(String message) {
    return MotorStatus(
      isEnabled: false,
      isMoving: false,
      currentPosition: 0,
      error: message,
    );
  }
}

/// API info returned from the root endpoint.
class MotorApiInfo {
  final String name;
  final String version;
  final List<String> endpoints;

  MotorApiInfo({
    required this.name,
    required this.version,
    required this.endpoints,
  });

  factory MotorApiInfo.fromJson(Map<String, dynamic> json) {
    return MotorApiInfo(
      name: json['name'] ?? 'Motor Control API',
      version: json['version'] ?? 'unknown',
      endpoints: (json['endpoints'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
    );
  }
}

/// Result of a motor command.
class MotorCommandResult {
  final bool success;
  final String? message;
  final String? error;

  MotorCommandResult({
    required this.success,
    this.message,
    this.error,
  });

  factory MotorCommandResult.fromJson(Map<String, dynamic> json) {
    return MotorCommandResult(
      success: json['success'] ?? true,
      message: json['message'],
      error: json['error'],
    );
  }

  factory MotorCommandResult.failure(String error) {
    return MotorCommandResult(
      success: false,
      error: error,
    );
  }

  factory MotorCommandResult.ok([String? message]) {
    return MotorCommandResult(
      success: true,
      message: message,
    );
  }
}

/// Service for controlling the Bina motor via REST API.
///
/// The motor controller runs on the same device as the camera,
/// accessible at port 8071.
class MotorControllerService {
  MotorControllerService._();

  static final MotorControllerService _instance = MotorControllerService._();
  static MotorControllerService get instance => _instance;

  static const int defaultPort = 8071;
  static const Duration _timeout = Duration(seconds: 5);

  String? _host;
  int _port = defaultPort;

  /// Configure the motor controller connection.
  void configure({required String host, int port = defaultPort}) {
    _host = host;
    _port = port;
    debugPrint('MotorControllerService: configured for $host:$port');
  }

  /// Configure from the current camera connection in AppState.
  /// Returns true if configured successfully, false if no camera is connected.
  bool configureFromCamera() {
    final cameraConnection = AppState().cameraConnection;
    if (!cameraConnection.isCameraConnected()) {
      debugPrint('MotorControllerService: no camera connected');
      return false;
    }
    configure(host: cameraConnection.cameraHost);
    return true;
  }

  /// Check if the service is configured with a host.
  bool get isConfigured => _host != null && _host!.isNotEmpty;

  /// Get the current host.
  String? get host => _host;

  /// Get the current port.
  int get port => _port;

  String get _baseUrl => 'http://$_host:$_port';

  /// Get API info from the root endpoint.
  Future<MotorApiInfo?> getApiInfo() async {
    if (!isConfigured) {
      debugPrint('MotorControllerService: not configured');
      return null;
    }

    try {
      final response = await http
          .get(Uri.parse(_baseUrl))
          .timeout(_timeout);

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        return MotorApiInfo.fromJson(json);
      } else {
        debugPrint('MotorControllerService: API info failed: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      debugPrint('MotorControllerService: API info error: $e');
      return null;
    }
  }

  /// Get motor status.
  Future<MotorStatus> getStatus() async {
    if (!isConfigured) {
      return MotorStatus.error('Motor controller not configured');
    }

    try {
      final response = await http
          .get(Uri.parse('$_baseUrl/status'))
          .timeout(_timeout);

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        return MotorStatus.fromJson(json);
      } else {
        return MotorStatus.error('HTTP ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('MotorControllerService: status error: $e');
      return MotorStatus.error(e.toString());
    }
  }

  /// Move the motor a specific number of steps.
  Future<MotorCommandResult> move({
    required int steps,
    MotorDirection direction = MotorDirection.forward,
  }) async {
    if (!isConfigured) {
      return MotorCommandResult.failure('Motor controller not configured');
    }

    try {
      final response = await http
          .post(
            Uri.parse('$_baseUrl/move'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'steps': steps,
              'direction': direction == MotorDirection.forward ? 1 : 0,
            }),
          )
          .timeout(_timeout);

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        return MotorCommandResult.fromJson(json);
      } else {
        return MotorCommandResult.failure('HTTP ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('MotorControllerService: move error: $e');
      return MotorCommandResult.failure(e.toString());
    }
  }

  /// Rotate the motor a specific number of revolutions.
  Future<MotorCommandResult> rotate({
    required double revolutions,
    MotorDirection direction = MotorDirection.forward,
  }) async {
    if (!isConfigured) {
      return MotorCommandResult.failure('Motor controller not configured');
    }

    try {
      final response = await http
          .post(
            Uri.parse('$_baseUrl/rotate'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'revolutions': revolutions,
              'direction': direction == MotorDirection.forward ? 1 : 0,
            }),
          )
          .timeout(_timeout);

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        return MotorCommandResult.fromJson(json);
      } else {
        return MotorCommandResult.failure('HTTP ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('MotorControllerService: rotate error: $e');
      return MotorCommandResult.failure(e.toString());
    }
  }

  /// Stop the motor immediately.
  Future<MotorCommandResult> stop() async {
    if (!isConfigured) {
      return MotorCommandResult.failure('Motor controller not configured');
    }

    try {
      final response = await http
          .post(Uri.parse('$_baseUrl/stop'))
          .timeout(_timeout);

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        return MotorCommandResult.fromJson(json);
      } else {
        return MotorCommandResult.failure('HTTP ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('MotorControllerService: stop error: $e');
      return MotorCommandResult.failure(e.toString());
    }
  }

  /// Enable the motor driver.
  Future<MotorCommandResult> enable() async {
    if (!isConfigured) {
      return MotorCommandResult.failure('Motor controller not configured');
    }

    try {
      final response = await http
          .post(Uri.parse('$_baseUrl/enable'))
          .timeout(_timeout);

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        return MotorCommandResult.fromJson(json);
      } else {
        return MotorCommandResult.failure('HTTP ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('MotorControllerService: enable error: $e');
      return MotorCommandResult.failure(e.toString());
    }
  }

  /// Disable the motor driver.
  Future<MotorCommandResult> disable() async {
    if (!isConfigured) {
      return MotorCommandResult.failure('Motor controller not configured');
    }

    try {
      final response = await http
          .post(Uri.parse('$_baseUrl/disable'))
          .timeout(_timeout);

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        return MotorCommandResult.fromJson(json);
      } else {
        return MotorCommandResult.failure('HTTP ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('MotorControllerService: disable error: $e');
      return MotorCommandResult.failure(e.toString());
    }
  }

  /// Blink the LED a specific number of times.
  Future<MotorCommandResult> blinkLed({int count = 1}) async {
    if (!isConfigured) {
      return MotorCommandResult.failure('Motor controller not configured');
    }

    try {
      final response = await http
          .post(
            Uri.parse('$_baseUrl/led'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'count': count}),
          )
          .timeout(_timeout);

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        return MotorCommandResult.fromJson(json);
      } else {
        return MotorCommandResult.failure('HTTP ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('MotorControllerService: LED error: $e');
      return MotorCommandResult.failure(e.toString());
    }
  }

  /// Test connection to the motor controller.
  Future<bool> testConnection() async {
    if (!isConfigured) return false;

    try {
      final response = await http
          .get(Uri.parse('$_baseUrl/status'))
          .timeout(_timeout);

      return response.statusCode == 200;
    } catch (e) {
      debugPrint('MotorControllerService: connection test failed: $e');
      return false;
    }
  }

  /// Clear the configuration.
  void disconnect() {
    _host = null;
    _port = defaultPort;
    debugPrint('MotorControllerService: disconnected');
  }
}
