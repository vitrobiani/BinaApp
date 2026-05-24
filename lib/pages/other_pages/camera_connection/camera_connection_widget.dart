import 'dart:async';
import 'package:bina_system/services/motor_controller_service.dart';

import '/app_core/app_theme.dart';
import '/app_core/app_util.dart';
import '/app_core/app_widgets.dart';
import '/app_state.dart';
import '/services/wifi_direct_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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
      setState(() {
        _wifiDirectSupported = false;
      });
      return;
    }

    await _wifiDirectService.init();

    _devicesSubscription = _wifiDirectService.devicesStream.listen((devices) {
      if (mounted) {
        setState(() {
          _discoveredDevices = devices;
        });
      }
    });

    _connectionSubscription = _wifiDirectService.connectionStateStream.listen((state) {
      if (mounted) {
        setState(() {
          _connectionState = state;
        });

        if (state == WifiDirectConnectionState.connected) {
          _onWifiDirectConnected();
        }
      }
    });

    final supported = await _wifiDirectService.isSupported();
    if (mounted) {
      setState(() {
        _wifiDirectSupported = supported;
      });
    }
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
        _errorMessage = AppLocalizations.of(context).getText('camc023' /* Failed to start discovery... */);
      });
    } else {
      // Keep scanning for a few seconds then stop
      Future.delayed(const Duration(seconds: 10), () {
        if (mounted && _isScanning) {
          _stopScan();
        }
      });
    }
  }

  Future<void> _stopScan() async {
    await _wifiDirectService.stopDiscovery();
    if (mounted) {
      setState(() {
        _isScanning = false;
      });
    }
  }

  Future<void> _connectToDevice(WifiP2pDevice device) async {
    setState(() {
      _errorMessage = null;
    });

    final isBinaCamera = device.deviceName.toLowerCase().contains('bina');
    bool success;

    if (isBinaCamera) {
      success = await _wifiDirectService.connectToBinaCamera(device.deviceAddress);
    } else {
      success = await _wifiDirectService.connect(device.deviceAddress);
    }

    if (!success && mounted) {
      setState(() {
        _errorMessage = '${AppLocalizations.of(context).getText('camc024' /* Failed to connect to */)} ${device.deviceName}';
      });
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
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: AppTheme.of(context).secondaryBackground,
          title: Text(
            AppLocalizations.of(context).getText('camc022' /* Enter Camera IP Address */),
            style: AppTheme.of(context).headlineSmall,
          ),
          content: TextField(
            controller: _ipController,
            decoration: InputDecoration(
              hintText: 'e.g., 192.168.1.2:8070',
              hintStyle: AppTheme.of(context).bodyMedium,
              filled: true,
              fillColor: AppTheme.of(context).primaryBackground,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
            ),
            style: AppTheme.of(context).bodyMedium,
            keyboardType: TextInputType.url,
          ),
          actions: <Widget>[
            TextButton(
              child: Text(
                AppLocalizations.of(context).getText('camc026' /* Cancel */),
                style: AppTheme.of(context).bodyMedium,
              ),
              onPressed: () => Navigator.of(context).pop(),
            ),
            ElevatedButton(
              onPressed: () {
                if (_ipController.text.isNotEmpty) {
                  AppState().updateCameraConnectionStruct((conn) {
                    conn.isConnected = true;
                    conn.cameraIP = _ipController.text.trim();
                    conn.cameraName = 'Manual Camera';
                    conn.connectionType = 'manual';
                  });
                  safeSetState(() {});
                  Navigator.of(context).pop();
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.of(context).primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                padding: const EdgeInsetsDirectional.fromSTEB(16.0, 0.0, 16.0, 0.0),
              ),
              child: Text(
                AppLocalizations.of(context).getText('camc006' /* Connect */),
                style: AppTheme.of(context).titleSmall.override(
                      font: GoogleFonts.inter(),
                      color: Colors.white,
                      letterSpacing: 0.0,
                    ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDeviceListTile(WifiP2pDevice device) {
    final isBinaCamera = device.deviceName.toLowerCase().contains('bina');
    final isConnecting = _connectionState == WifiDirectConnectionState.connecting;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
      decoration: BoxDecoration(
        color: AppTheme.of(context).primaryBackground,
        borderRadius: BorderRadius.circular(12.0),
        border: isBinaCamera
            ? Border.all(color: AppTheme.of(context).primary, width: 2.0)
            : null,
      ),
      child: ListTile(
        leading: Icon(
          isBinaCamera ? Icons.camera_alt : Icons.wifi,
          color: isBinaCamera
              ? AppTheme.of(context).primary
              : AppTheme.of(context).secondaryText,
          size: 28.0,
        ),
        title: Text(
          device.deviceName,
          style: AppTheme.of(context).bodyLarge.override(
                font: GoogleFonts.inter(),
                fontWeight: isBinaCamera ? FontWeight.bold : FontWeight.normal,
                letterSpacing: 0.0,
              ),
        ),
        subtitle: Text(
          device.status.toUpperCase(),
          style: AppTheme.of(context).bodySmall.override(
                font: GoogleFonts.inter(),
                color: device.isAvailable
                    ? AppTheme.of(context).success
                    : AppTheme.of(context).secondaryText,
                letterSpacing: 0.0,
              ),
        ),
        trailing: device.isAvailable
            ? ElevatedButton(
                onPressed: isConnecting ? null : () => _connectToDevice(device),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.of(context).primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                child: isConnecting
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Text(AppLocalizations.of(context).getText('camc006' /* Connect */)),
              )
            : null,
      ),
    );
  }

  Widget _buildConnectionStatus() {
    final cameraConnection = AppState().cameraConnection;
    final isConnected = cameraConnection.isConnected;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: isConnected
            ? AppTheme.of(context).success.withOpacity(0.1)
            : AppTheme.of(context).primaryBackground,
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(
          color: isConnected
              ? AppTheme.of(context).success
              : AppTheme.of(context).alternate,
        ),
      ),
      child: Row(
        children: [
          Icon(
            isConnected ? Icons.check_circle : Icons.info_outline,
            color: isConnected
                ? AppTheme.of(context).success
                : AppTheme.of(context).secondaryText,
          ),
          const SizedBox(width: 12.0),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isConnected
                      ? AppLocalizations.of(context).getText('camc008' /* Connected */)
                      : AppLocalizations.of(context).getText('camc012' /* Not Connected */),
                  style: AppTheme.of(context).titleSmall.override(
                        font: GoogleFonts.inter(),
                        color: isConnected
                            ? AppTheme.of(context).success
                            : AppTheme.of(context).primaryText,
                        letterSpacing: 0.0,
                      ),
                ),
                if (isConnected) ...[
                  const SizedBox(height: 4.0),
                  Text(
                    '${cameraConnection.cameraName ?? "Camera"} - ${cameraConnection.cameraHost}',
                    style: AppTheme.of(context).bodySmall.override(
                          font: GoogleFonts.inter(),
                          color: AppTheme.of(context).secondaryText,
                          letterSpacing: 0.0,
                        ),
                  ),
                ],
              ],
            ),
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
      onTap: () {
        FocusScope.of(context).unfocus();
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: AppTheme.of(context).secondaryBackground,
        appBar: AppBar(
          backgroundColor: AppTheme.of(context).secondaryBackground,
          elevation: 0,
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back,
              color: AppTheme.of(context).primaryText,
            ),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: Text(
            AppLocalizations.of(context).getText('camc001' /* Camera Connection */),
            style: AppTheme.of(context).headlineSmall,
          ),
          centerTitle: true,
        ),
        body: SafeArea(
          top: true,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.max,
              children: [
                // Stream preview container
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Container(
                    width: double.infinity,
                    height: 250.0,
                    decoration: BoxDecoration(
                      color: AppTheme.of(context).primaryBackground,
                      borderRadius: BorderRadius.circular(16.0),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16.0),
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
                                  Icon(
                                    Icons.videocam_off,
                                    size: 64.0,
                                    color: AppTheme.of(context).secondaryText,
                                  ),
                                  const SizedBox(height: 8.0),
                                  Text(
                                    AppLocalizations.of(context).getText('camc013' /* No camera connected */),
                                    style: AppTheme.of(context).bodyMedium.override(
                                          font: GoogleFonts.inter(),
                                          color: AppTheme.of(context).secondaryText,
                                          letterSpacing: 0.0,
                                        ),
                                  ),
                                ],
                              ),
                            ),
                    ),
                  ),
                ),

                // Connection status
                _buildConnectionStatus(),

                // Error message
                if (_errorMessage != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    child: Container(
                      padding: const EdgeInsets.all(12.0),
                      decoration: BoxDecoration(
                        color: AppTheme.of(context).error.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.error_outline,
                            color: AppTheme.of(context).error,
                            size: 20.0,
                          ),
                          const SizedBox(width: 8.0),
                          Expanded(
                            child: Text(
                              _errorMessage!,
                              style: AppTheme.of(context).bodySmall.override(
                                    font: GoogleFonts.inter(),
                                    color: AppTheme.of(context).error,
                                    letterSpacing: 0.0,
                                  ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                // Disconnect button when connected
                if (isConnected)
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: AppButtonWidget(
                      onPressed: _disconnect,
                      showLoadingIndicator: false,
                      text: AppLocalizations.of(context).getText('camc007' /* Disconnect */),
                      options: AppButtonOptions(
                        width: double.infinity,
                        height: 48.0,
                        color: AppTheme.of(context).error,
                        textStyle: AppTheme.of(context).titleSmall.override(
                              font: GoogleFonts.inter(),
                              color: Colors.white,
                              letterSpacing: 0.0,
                            ),
                        elevation: 0.0,
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                    ),
                  ),
                if (isConnected)
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: AppButtonWidget(
                      onPressed: () => MotorControllerService.instance.rotate(revolutions: 51),
                      showLoadingIndicator: false,
                      text: "Motor move",
                      options: AppButtonOptions(
                        width: double.infinity,
                        height: 48.0,
                        color: AppTheme.of(context).primary,
                        textStyle: AppTheme.of(context).titleSmall.override(
                          font: GoogleFonts.inter(),
                          color: Colors.white,
                          letterSpacing: 0.0,
                        ),
                        elevation: 0.0,
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                    ),
                  ),

                // WiFi Direct section (only when not connected)
                if (!isConnected && _wifiDirectSupported) ...[
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          AppLocalizations.of(context).getText('camc014' /* Nearby Devices */),
                          style: AppTheme.of(context).titleMedium.override(
                                font: GoogleFonts.inter(),
                                letterSpacing: 0.0,
                              ),
                        ),
                        if (_isScanning)
                          Row(
                            children: [
                              SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: AppTheme.of(context).primary,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                AppLocalizations.of(context).getText('camc015' /* Scanning... */),
                                style: AppTheme.of(context).bodySmall.override(
                                      font: GoogleFonts.inter(),
                                      color: AppTheme.of(context).primary,
                                      letterSpacing: 0.0,
                                    ),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),

                  // Device list
                  if (_discoveredDevices.isNotEmpty)
                    ...(_discoveredDevices.map(_buildDeviceListTile).toList())
                  else if (!_isScanning)
                    Padding(
                      padding: const EdgeInsets.all(32.0),
                      child: Column(
                        children: [
                          Icon(
                            Icons.wifi_find,
                            size: 48.0,
                            color: AppTheme.of(context).secondaryText,
                          ),
                          const SizedBox(height: 8.0),
                          Text(
                            AppLocalizations.of(context).getText('camc016' /* No devices found */),
                            style: AppTheme.of(context).bodyMedium.override(
                                  font: GoogleFonts.inter(),
                                  color: AppTheme.of(context).secondaryText,
                                  letterSpacing: 0.0,
                                ),
                          ),
                          const SizedBox(height: 4.0),
                          Text(
                            AppLocalizations.of(context).getText('camc017' /* Tap "Scan" to search... */),
                            style: AppTheme.of(context).bodySmall.override(
                                  font: GoogleFonts.inter(),
                                  color: AppTheme.of(context).secondaryText,
                                  letterSpacing: 0.0,
                                ),
                          ),
                        ],
                      ),
                    ),

                  // Scan button
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: AppButtonWidget(
                      onPressed: _isScanning ? _stopScan : _startScan,
                      showLoadingIndicator: false,
                      text: _isScanning
                          ? AppLocalizations.of(context).getText('camc019' /* Stop Scan */)
                          : AppLocalizations.of(context).getText('camc018' /* Scan for Devices */),
                      icon: Icon(
                        _isScanning ? Icons.stop : Icons.wifi_find,
                        color: Colors.white,
                        size: 20.0,
                      ),
                      options: AppButtonOptions(
                        width: double.infinity,
                        height: 48.0,
                        color: _isScanning
                            ? AppTheme.of(context).secondaryText
                            : AppTheme.of(context).primary,
                        textStyle: AppTheme.of(context).titleSmall.override(
                              font: GoogleFonts.inter(),
                              color: Colors.white,
                              letterSpacing: 0.0,
                            ),
                        elevation: 0.0,
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                    ),
                  ),

                  // Divider
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Row(
                      children: [
                        Expanded(child: Divider(color: AppTheme.of(context).alternate)),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: Text(
                            AppLocalizations.of(context).getText('camc020' /* OR */),
                            style: AppTheme.of(context).bodySmall.override(
                                  font: GoogleFonts.inter(),
                                  color: AppTheme.of(context).secondaryText,
                                  letterSpacing: 0.0,
                                ),
                          ),
                        ),
                        Expanded(child: Divider(color: AppTheme.of(context).alternate)),
                      ],
                    ),
                  ),
                ],

                // Manual connect button
                if (!isConnected)
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: AppButtonWidget(
                      onPressed: _showManualConnectDialog,
                      showLoadingIndicator: false,
                      text: AppLocalizations.of(context).getText('camc021' /* Enter IP Manually */),
                      icon: Icon(
                        Icons.edit,
                        color: AppTheme.of(context).primaryText,
                        size: 20.0,
                      ),
                      options: AppButtonOptions(
                        width: double.infinity,
                        height: 48.0,
                        color: AppTheme.of(context).primaryBackground,
                        textStyle: AppTheme.of(context).titleSmall.override(
                              font: GoogleFonts.inter(),
                              color: AppTheme.of(context).primaryText,
                              letterSpacing: 0.0,
                            ),
                        elevation: 0.0,
                        borderSide: BorderSide(
                          color: AppTheme.of(context).alternate,
                          width: 1.0,
                        ),
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                    ),
                  ),

                // WiFi Direct not supported message
                if (!isConnected && !_wifiDirectSupported && !kIsWeb)
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Container(
                      padding: const EdgeInsets.all(16.0),
                      decoration: BoxDecoration(
                        color: AppTheme.of(context).warning.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: AppTheme.of(context).warning,
                          ),
                          const SizedBox(width: 12.0),
                          Expanded(
                            child: Text(
                              AppLocalizations.of(context).getText('camc025' /* WiFi Direct is not available... */),
                              style: AppTheme.of(context).bodySmall.override(
                                    font: GoogleFonts.inter(),
                                    color: AppTheme.of(context).primaryText,
                                    letterSpacing: 0.0,
                                  ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                const SizedBox(height: 32.0),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
