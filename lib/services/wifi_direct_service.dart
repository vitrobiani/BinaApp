import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';

class WifiP2pDevice {
  final String deviceName;
  final String deviceAddress;
  final String status;
  final bool isGroupOwner;

  WifiP2pDevice({
    required this.deviceName,
    required this.deviceAddress,
    required this.status,
    required this.isGroupOwner,
  });

  factory WifiP2pDevice.fromMap(Map<dynamic, dynamic> map) {
    return WifiP2pDevice(
      deviceName: map['deviceName'] as String? ?? 'Unknown',
      deviceAddress: map['deviceAddress'] as String? ?? '',
      status: map['status'] as String? ?? 'unknown',
      isGroupOwner: map['isGroupOwner'] as bool? ?? false,
    );
  }

  bool get isAvailable => status == 'available';
  bool get isConnected => status == 'connected';
  bool get isInvited => status == 'invited';
}

enum WifiDirectConnectionState {
  disconnected,
  connecting,
  connected,
  error,
}

class WifiDirectConnectionInfo {
  final bool isGroupOwner;
  final String? groupOwnerAddress;
  final String? deviceAddress;

  WifiDirectConnectionInfo({
    required this.isGroupOwner,
    this.groupOwnerAddress,
    this.deviceAddress,
  });

  factory WifiDirectConnectionInfo.fromMap(Map<dynamic, dynamic> map) {
    return WifiDirectConnectionInfo(
      isGroupOwner: map['isGroupOwner'] as bool? ?? false,
      groupOwnerAddress: map['groupOwnerAddress'] as String?,
      deviceAddress: map['deviceAddress'] as String?,
    );
  }
}

class WifiDirectService {
  WifiDirectService._();

  static final WifiDirectService _instance = WifiDirectService._();
  static WifiDirectService get instance => _instance;

  static const _methodChannel = MethodChannel('com.bina.system/wifi_direct');
  static const _deviceEventChannel = EventChannel('com.bina.system/wifi_direct/devices');
  static const _connectionEventChannel = EventChannel('com.bina.system/wifi_direct/connection');

  final _devicesController = StreamController<List<WifiP2pDevice>>.broadcast();
  final _connectionStateController = StreamController<WifiDirectConnectionState>.broadcast();
  final _connectionInfoController = StreamController<WifiDirectConnectionInfo?>.broadcast();

  Stream<List<WifiP2pDevice>> get devicesStream => _devicesController.stream;
  Stream<WifiDirectConnectionState> get connectionStateStream => _connectionStateController.stream;
  Stream<WifiDirectConnectionInfo?> get connectionInfoStream => _connectionInfoController.stream;

  List<WifiP2pDevice> _currentDevices = [];
  List<WifiP2pDevice> get currentDevices => _currentDevices;

  WifiDirectConnectionState _connectionState = WifiDirectConnectionState.disconnected;
  WifiDirectConnectionState get connectionState => _connectionState;

  WifiDirectConnectionInfo? _connectionInfo;
  WifiDirectConnectionInfo? get connectionInfo => _connectionInfo;

  bool _initialized = false;
  bool _isDiscovering = false;
  bool get isDiscovering => _isDiscovering;

  StreamSubscription? _deviceSubscription;
  StreamSubscription? _connectionSubscription;

  Future<void> init() async {
    if (_initialized) return;

    _deviceSubscription = _deviceEventChannel
        .receiveBroadcastStream()
        .listen(_handleDeviceEvent);

    _connectionSubscription = _connectionEventChannel
        .receiveBroadcastStream()
        .listen(_handleConnectionEvent);

    _initialized = true;
    debugPrint('WifiDirectService: initialized');
  }

  void _handleDeviceEvent(dynamic event) {
    if (event is List) {
      _currentDevices = event
          .map((e) => WifiP2pDevice.fromMap(e as Map<dynamic, dynamic>))
          .toList();
      _devicesController.add(_currentDevices);
      debugPrint('WifiDirectService: found ${_currentDevices.length} devices');
    }
  }

  void _handleConnectionEvent(dynamic event) {
    if (event is Map) {
      final type = event['type'] as String?;

      switch (type) {
        case 'connected':
          _connectionState = WifiDirectConnectionState.connected;
          _connectionInfo = WifiDirectConnectionInfo.fromMap(event);
          _connectionStateController.add(_connectionState);
          _connectionInfoController.add(_connectionInfo);
          debugPrint('WifiDirectService: connected to ${_connectionInfo?.groupOwnerAddress}');
          break;

        case 'disconnected':
          _connectionState = WifiDirectConnectionState.disconnected;
          _connectionInfo = null;
          _connectionStateController.add(_connectionState);
          _connectionInfoController.add(null);
          debugPrint('WifiDirectService: disconnected');
          break;

        case 'wifi_state':
          final enabled = event['enabled'] as bool? ?? false;
          debugPrint('WifiDirectService: WiFi P2P enabled=$enabled');
          break;
      }
    }
  }

  Future<bool> isSupported() async {
    if (kIsWeb) return false;

    try {
      final result = await _methodChannel.invokeMethod<bool>('isSupported');
      return result ?? false;
    } catch (e) {
      debugPrint('WifiDirectService: isSupported error: $e');
      return false;
    }
  }

  Future<bool> hasPermissions() async {
    if (kIsWeb) return false;

    try {
      final result = await _methodChannel.invokeMethod<bool>('hasPermissions');
      return result ?? false;
    } catch (e) {
      debugPrint('WifiDirectService: hasPermissions error: $e');
      return false;
    }
  }

  Future<bool> requestPermissions() async {
    if (kIsWeb) return false;

    final permissions = <Permission>[
      Permission.locationWhenInUse,
      Permission.nearbyWifiDevices,
    ];

    final statuses = await permissions.request();

    final locationGranted = statuses[Permission.locationWhenInUse]?.isGranted ?? false;
    final nearbyGranted = statuses[Permission.nearbyWifiDevices]?.isGranted ?? true; // Optional on older Android

    debugPrint('WifiDirectService: permissions - location=$locationGranted, nearby=$nearbyGranted');
    return locationGranted;
  }

  Future<bool> startDiscovery() async {
    if (kIsWeb) return false;

    try {
      await init();

      final hasPerms = await hasPermissions();
      if (!hasPerms) {
        final granted = await requestPermissions();
        if (!granted) {
          debugPrint('WifiDirectService: permissions not granted');
          return false;
        }
      }

      final result = await _methodChannel.invokeMethod<bool>('startDiscovery');
      _isDiscovering = result ?? false;
      debugPrint('WifiDirectService: discovery started=$_isDiscovering');
      return _isDiscovering;
    } catch (e) {
      debugPrint('WifiDirectService: startDiscovery error: $e');
      _isDiscovering = false;
      return false;
    }
  }

  Future<bool> stopDiscovery() async {
    if (kIsWeb) return true;

    try {
      await _methodChannel.invokeMethod<bool>('stopDiscovery');
      _isDiscovering = false;
      return true;
    } catch (e) {
      debugPrint('WifiDirectService: stopDiscovery error: $e');
      return false;
    }
  }

  Future<bool> connect(String deviceAddress, {String? pin}) async {
    if (kIsWeb) return false;

    try {
      _connectionState = WifiDirectConnectionState.connecting;
      _connectionStateController.add(_connectionState);

      final result = await _methodChannel.invokeMethod<bool>('connect', {
        'deviceAddress': deviceAddress,
        'pin': pin,
      });

      if (result != true) {
        _connectionState = WifiDirectConnectionState.error;
        _connectionStateController.add(_connectionState);
      }

      return result ?? false;
    } catch (e) {
      debugPrint('WifiDirectService: connect error: $e');
      _connectionState = WifiDirectConnectionState.error;
      _connectionStateController.add(_connectionState);
      return false;
    }
  }

  Future<bool> connectToBinaCamera(String deviceAddress) async {
    return connect(deviceAddress, pin: '12345678');
  }

  Future<bool> disconnect() async {
    if (kIsWeb) return true;

    try {
      await _methodChannel.invokeMethod<bool>('disconnect');
      _connectionState = WifiDirectConnectionState.disconnected;
      _connectionInfo = null;
      _connectionStateController.add(_connectionState);
      _connectionInfoController.add(null);
      return true;
    } catch (e) {
      debugPrint('WifiDirectService: disconnect error: $e');
      return false;
    }
  }

  Future<Map<String, dynamic>?> getConnectionInfo() async {
    if (kIsWeb) return null;

    try {
      final result = await _methodChannel.invokeMethod<Map<dynamic, dynamic>>('getConnectionInfo');
      return result?.cast<String, dynamic>();
    } catch (e) {
      debugPrint('WifiDirectService: getConnectionInfo error: $e');
      return null;
    }
  }

  void dispose() {
    _deviceSubscription?.cancel();
    _connectionSubscription?.cancel();
    _devicesController.close();
    _connectionStateController.close();
    _connectionInfoController.close();
  }
}
