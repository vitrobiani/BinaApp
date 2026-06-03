import 'dart:async';
import 'package:bina_system/services/motor_controller_service.dart';

import '/app_core/app_util.dart';
import '/bina_design/bina_design.dart';
import '/services/wifi_direct_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mjpeg_stream/mjpeg_stream.dart';

class CameraConnectionWidget extends StatefulWidget {
  const CameraConnectionWidget({super.key});

  static String routeName = 'CameraConnection';
  static String routePath = 'cameraConnection';

  @override
  State<CameraConnectionWidget> createState() => _CameraConnectionWidgetState();
}

class _CameraConnectionWidgetState extends State<CameraConnectionWidget> {
  final scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController _ipController = TextEditingController();

  final WifiDirectService _wifiDirectService = WifiDirectService.instance;

  List<WifiP2pDevice> _discoveredDevices = [];
  WifiDirectConnectionState _connectionState = WifiDirectConnectionState.disconnected;
  bool _isScanning = false;
  bool _wifiDirectSupported = false;
  String? _errorMessage;

  StreamSubscription? _devicesSubscription;
  StreamSubscription? _connectionSubscription;

  @override
  void initState() {
    super.initState();
    _initWifiDirect();
  }

  Future<void> _initWifiDirect() async {
    if (kIsWeb) {
      setState(() => _wifiDirectSupported = false);
      return;
    }

    await _wifiDirectService.init();

    _devicesSubscription = _wifiDirectService.devicesStream.listen((devices) {
      if (mounted) setState(() => _discoveredDevices = devices);
    });

    _connectionSubscription = _wifiDirectService.connectionStateStream.listen((state) {
      if (mounted) {
        setState(() => _connectionState = state);
        if (state == WifiDirectConnectionState.connected) _onWifiDirectConnected();
      }
    });

    final supported = await _wifiDirectService.isSupported();
    if (mounted) setState(() => _wifiDirectSupported = supported);
  }

  void _onWifiDirectConnected() {
    final info = _wifiDirectService.connectionInfo;
    if (info != null && info.groupOwnerAddress != null) {
      AppState().updateCameraConnectionStruct((conn) {
        conn.isConnected = true;
        conn.cameraIP = '${info.groupOwnerAddress}:8070';
        conn.cameraName = 'Bina-Camera';
        conn.connectionType = 'wifi_direct';
      });
      // Configure motor controller with same host
      MotorControllerService.instance.configureFromCamera();
      safeSetState(() {});
    }
  }

  @override
  void dispose() {
    _ipController.dispose();
    _devicesSubscription?.cancel();
    _connectionSubscription?.cancel();
    super.dispose();
  }

  Future<void> _startScan() async {
    setState(() {
      _isScanning = true;
      _errorMessage = null;
      _discoveredDevices = [];
    });

    final success = await _wifiDirectService.startDiscovery();

    if (!success && mounted) {
      setState(() {
        _isScanning = false;
        _errorMessage = 'Failed to start discovery. Please try again.';
      });
    } else {
      Future.delayed(const Duration(seconds: 10), () {
        if (mounted && _isScanning) _stopScan();
      });
    }
  }

  Future<void> _stopScan() async {
    await _wifiDirectService.stopDiscovery();
    if (mounted) setState(() => _isScanning = false);
  }

  Future<void> _connectToDevice(WifiP2pDevice device) async {
    setState(() => _errorMessage = null);

    final isBinaCamera = device.deviceName.toLowerCase().contains('bina');
    final success = isBinaCamera
        ? await _wifiDirectService.connectToBinaCamera(device.deviceAddress)
        : await _wifiDirectService.connect(device.deviceAddress);

    if (!success && mounted) {
      setState(() => _errorMessage = 'Failed to connect to ${device.deviceName}');
    }
  }

  Future<void> _disconnect() async {
    await _wifiDirectService.disconnect();

    AppState().updateCameraConnectionStruct((conn) {
      conn.isConnected = false;
      conn.cameraIP = '';
      conn.cameraName = null;
      conn.cameraMacAddress = null;
      conn.connectionType = 'manual';
    });

    _ipController.clear();
    safeSetState(() {});
  }

  Future<void> _showManualConnectDialog() async {
    return showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: BinaColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Enter Camera IP', style: BinaType.headlineSm),
        content: Container(
          decoration: BoxDecoration(
            color: BinaColors.surfaceSunken,
            borderRadius: BorderRadius.circular(12),
          ),
          child: TextField(
            controller: _ipController,
            style: BinaType.bodyLg,
            decoration: InputDecoration(
              hintText: 'e.g., 192.168.1.2:8070',
              hintStyle: BinaType.bodyMd.copyWith(color: BinaColors.ink3),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.all(14),
            ),
            keyboardType: TextInputType.url,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text('Cancel', style: BinaType.labelLg.copyWith(color: BinaColors.ink2)),
          ),
          TextButton(
            onPressed: () {
              if (_ipController.text.isNotEmpty) {
                AppState().updateCameraConnectionStruct((conn) {
                  conn.isConnected = true;
                  conn.cameraIP = _ipController.text.trim();
                  conn.cameraName = 'Manual Camera';
                  conn.connectionType = 'manual';
                });
                safeSetState(() {});
                Navigator.of(ctx).pop();
              }
            },
            child: Text('Connect', style: BinaType.labelLg.copyWith(color: BinaColors.primary)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cameraConnection = AppState().cameraConnection;
    final isConnected = cameraConnection.isConnected;

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: BinaColors.surfaceAlt,
        body: SafeArea(
          child: Column(
            children: [
              // Header
              Container(
                padding: const EdgeInsets.fromLTRB(8, 8, 16, 8),
                decoration: BoxDecoration(
                  color: BinaColors.surface,
                  border: Border(bottom: BorderSide(color: BinaColors.line)),
                ),
                child: Row(
                  children: [
                    BinaIconButton(
                      icon: Icons.chevron_left_rounded,
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    const SizedBox(width: 8),
                    Text('Camera Connection', style: BinaType.titleLg),
                  ],
                ),
              ),
              // Content
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Preview
                      Container(
                        width: double.infinity,
                        height: 220,
                        decoration: BoxDecoration(
                          color: BinaColors.surface,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: BinaColors.line),
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: isConnected && cameraConnection.hasCameraIP()
                            ? MJPEGStreamScreen(
                                streamUrl: cameraConnection.streamUrl,
                                fit: BoxFit.contain,
                                showLiveIcon: true,
                              )
                            : Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.videocam_off_rounded, size: 56, color: BinaColors.ink3),
                                    const SizedBox(height: 12),
                                    Text(
                                      'No camera connected',
                                      style: BinaType.bodyMd.copyWith(color: BinaColors.ink2),
                                    ),
                                  ],
                                ),
                              ),
                      ),
                      const SizedBox(height: 16),

                      // Connection status
                      BinaCard(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: isConnected ? BinaColors.success100 : BinaColors.surfaceSunken,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                isConnected ? Icons.check_circle_rounded : Icons.wifi_off_rounded,
                                color: isConnected ? BinaColors.success : BinaColors.ink3,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    isConnected ? 'Connected' : 'Not Connected',
                                    style: BinaType.titleMd.copyWith(
                                      color: isConnected ? BinaColors.success : BinaColors.ink,
                                    ),
                                  ),
                                  if (isConnected)
                                    Text(
                                      '${cameraConnection.cameraName ?? "Camera"} - ${cameraConnection.cameraHost}',
                                      style: BinaType.bodySm.copyWith(color: BinaColors.ink3),
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Error message
                      if (_errorMessage != null) ...[
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: BinaColors.error100,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.error_outline_rounded, color: BinaColors.error, size: 20),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  _errorMessage!,
                                  style: BinaType.bodySm.copyWith(color: BinaColors.error),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],

                      // Disconnect button
                      if (isConnected) ...[
                        const SizedBox(height: 20),
                        SizedBox(
                          width: double.infinity,
                          child: BinaButton(
                            label: 'Disconnect',
                            icon: Icons.link_off_rounded,
                            variant: BinaButtonVariant.secondary,
                            onPressed: _disconnect,
                          ),
                        ),
                      ],

                      // WiFi Direct section
                      if (!isConnected && _wifiDirectSupported) ...[
                        const SizedBox(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Nearby Devices', style: BinaType.titleMd),
                            if (_isScanning)
                              Row(
                                children: [
                                  SizedBox(
                                    width: 14,
                                    height: 14,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: BinaColors.primary,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Scanning...',
                                    style: BinaType.labelSm.copyWith(color: BinaColors.primary),
                                  ),
                                ],
                              ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        if (_discoveredDevices.isNotEmpty)
                          ..._discoveredDevices.map((device) => _DeviceCard(
                                device: device,
                                isConnecting: _connectionState == WifiDirectConnectionState.connecting,
                                onConnect: () => _connectToDevice(device),
                              ))
                        else if (!_isScanning)
                          BinaCard(
                            padding: const EdgeInsets.all(24),
                            child: Center(
                              child: Column(
                                children: [
                                  Icon(Icons.wifi_find_rounded, size: 40, color: BinaColors.ink3),
                                  const SizedBox(height: 12),
                                  Text('No devices found', style: BinaType.titleSm),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Tap "Scan" to search for cameras',
                                    style: BinaType.bodySm.copyWith(color: BinaColors.ink2),
                                  ),
                                ],
                              ),
                            ),
                          ),

                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: BinaButton(
                            label: _isScanning ? 'Stop Scan' : 'Scan for Devices',
                            icon: _isScanning ? Icons.stop_rounded : Icons.wifi_find_rounded,
                            variant: _isScanning ? BinaButtonVariant.secondary : BinaButtonVariant.primary,
                            onPressed: _isScanning ? _stopScan : _startScan,
                          ),
                        ),

                        const SizedBox(height: 20),
                        Row(
                          children: [
                            Expanded(child: Divider(color: BinaColors.line)),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              child: Text('OR', style: BinaType.labelSm.copyWith(color: BinaColors.ink3)),
                            ),
                            Expanded(child: Divider(color: BinaColors.line)),
                          ],
                        ),
                      ],

                      // Manual connect
                      if (!isConnected) ...[
                        const SizedBox(height: 20),
                        SizedBox(
                          width: double.infinity,
                          child: BinaButton(
                            label: 'Enter IP Manually',
                            icon: Icons.edit_rounded,
                            variant: BinaButtonVariant.ghost,
                            onPressed: _showManualConnectDialog,
                          ),
                        ),
                      ],

                      // WiFi Direct not supported
                      if (!isConnected && !_wifiDirectSupported && !kIsWeb) ...[
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: BinaColors.warning.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.info_outline_rounded, color: BinaColors.warning),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'WiFi Direct is not available on this device. Use manual IP connection.',
                                  style: BinaType.bodySm,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DeviceCard extends StatelessWidget {
  const _DeviceCard({
    required this.device,
    required this.isConnecting,
    required this.onConnect,
  });

  final WifiP2pDevice device;
  final bool isConnecting;
  final VoidCallback onConnect;

  @override
  Widget build(BuildContext context) {
    final isBinaCamera = device.deviceName.toLowerCase().contains('bina');

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: BinaCard(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: isBinaCamera ? BinaColors.primary100 : BinaColors.surfaceSunken,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                isBinaCamera ? Icons.camera_alt_rounded : Icons.wifi_rounded,
                color: isBinaCamera ? BinaColors.primary : BinaColors.ink2,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    device.deviceName,
                    style: BinaType.titleSm.copyWith(
                      fontWeight: isBinaCamera ? FontWeight.w600 : FontWeight.w500,
                    ),
                  ),
                  Text(
                    device.status.toUpperCase(),
                    style: BinaType.labelSm.copyWith(
                      color: device.isAvailable ? BinaColors.success : BinaColors.ink3,
                    ),
                  ),
                ],
              ),
            ),
            if (device.isAvailable)
              BinaButton(
                label: 'Connect',
                variant: BinaButtonVariant.primary,
                enabled: !isConnecting,
                onPressed: onConnect,
              ),
          ],
        ),
      ),
    );
  }
}
