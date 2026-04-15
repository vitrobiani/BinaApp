import '/app_core/app_theme.dart';
import '/app_core/app_util.dart';
import '/app_core/app_widgets.dart';
import '/app_state.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mjpeg_stream/mjpeg_stream.dart';
// import 'package:flutter_mjpeg/flutter_mjpeg.dart';

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

  @override
  void dispose() {
    _ipController.dispose();
    super.dispose();
  }

  Future<void> _showConnectDialog() async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: AppTheme.of(context).secondaryBackground,
          title: Text(
            'Enter Camera IP Address',
            style: AppTheme.of(context).headlineSmall,
          ),
          content: TextField(
            controller: _ipController,
            decoration: InputDecoration(
              hintText: 'e.g., 192.168.1.100:8070',
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
                'Cancel',
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
                padding: EdgeInsetsDirectional.fromSTEB(16.0, 0.0, 16.0, 0.0),
              ),
              child: Text(
                'Connect',
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

  void _disconnect() {
    AppState().updateCameraConnectionStruct((conn) {
      conn.isConnected = false;
      conn.cameraIP = '';
    });
    _ipController.clear();
    safeSetState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final cameraConnection = AppState().cameraConnection;
    final isConnected = cameraConnection.isConnected ?? false;
    final ipAddress = cameraConnection.cameraIP ?? '';

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: AppTheme.of(context).secondaryBackground,
        body: SafeArea(
          top: true,
          child: Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Stream preview container
              Padding(
                padding: EdgeInsets.all(10.0),
                child: Container(
                  width: 300.0,
                  height: 300.0,
                  decoration: BoxDecoration(
                    color: AppTheme.of(context).primaryBackground,
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8.0),
                    child: isConnected && ipAddress.isNotEmpty
                        ? MJPEGStreamScreen(
                            streamUrl: 'http://$ipAddress/stream.mjpg',
                            fit: BoxFit.contain,
                            showLiveIcon: true,
                          )
                        : Center(
                            child: Icon(
                              Icons.videocam_off,
                              size: 64.0,
                              color: AppTheme.of(context).secondaryText,
                            ),
                          ),
                  ),
                ),
              ),
              // Connection status
              Padding(
                padding: EdgeInsets.all(8.0),
                child: Text(
                  isConnected ? 'Connected to: $ipAddress' : 'Not Connected',
                  style: AppTheme.of(context).bodyMedium.override(
                        font: GoogleFonts.inter(),
                        color: isConnected
                            ? AppTheme.of(context).success
                            : AppTheme.of(context).secondaryText,
                        letterSpacing: 0.0,
                      ),
                ),
              ),
              // Connect/Disconnect button
              Align(
                alignment: AlignmentDirectional(0.0, 0.0),
                child: Padding(
                  padding: EdgeInsets.all(10.0),
                  child: AppButtonWidget(
                    onPressed: isConnected ? _disconnect : _showConnectDialog,
                    showLoadingIndicator: false,
                    text: isConnected ? 'Disconnect' : 'Connect',
                    options: AppButtonOptions(
                      height: 40.0,
                      padding:
                          EdgeInsetsDirectional.fromSTEB(16.0, 0.0, 16.0, 0.0),
                      color: isConnected
                          ? AppTheme.of(context).error
                          : AppTheme.of(context).primary,
                      textStyle:
                          AppTheme.of(context).titleSmall.override(
                                font: GoogleFonts.inter(),
                                color: Colors.white,
                                letterSpacing: 0.0,
                              ),
                      elevation: 0.0,
                      borderRadius: BorderRadius.circular(8.0),
                    ),
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