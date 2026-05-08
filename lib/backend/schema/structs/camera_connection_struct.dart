import '/backend/schema/util/schema_util.dart';
import 'index.dart';
import '/app_core/app_util.dart';

class CameraConnectionStruct extends BaseStruct {
  bool isConnected = false;
  String? cameraIP;
  String? cameraName;
  String? cameraMacAddress;
  String connectionType; // 'wifi_direct', 'manual', 'hotspot'

  CameraConnectionStruct({
    this.isConnected = false,
    this.cameraIP,
    this.cameraName,
    this.cameraMacAddress,
    this.connectionType = 'manual',
  });

  Map<String, dynamic> toMap() {
    return {
      'isConnected': isConnected,
      'cameraIP': cameraIP,
      'cameraName': cameraName,
      'cameraMacAddress': cameraMacAddress,
      'connectionType': connectionType,
    };
  }

  static CameraConnectionStruct fromMap(Map<String, dynamic> map) {
    return CameraConnectionStruct(
      isConnected: map['isConnected'] ?? false,
      cameraIP: map['cameraIP'],
      cameraName: map['cameraName'],
      cameraMacAddress: map['cameraMacAddress'],
      connectionType: map['connectionType'] ?? 'manual',
    );
  }

  bool hasCameraIP() => cameraIP != null && cameraIP!.isNotEmpty;
  bool isCameraConnected() => isConnected && hasCameraIP();
  bool isBinaCameraConnected() => isConnected && cameraName == 'Bina-Camera';
  bool isWifiDirectConnection() => connectionType == 'wifi_direct';

  String get streamUrl {
    final ip = cameraIP ?? '192.168.1.2';
    final cleanIP = ip.contains(':') ? ip.split(':').first : ip;
    final port = ip.contains(':') ? ip.split(':').last : '8070';
    return 'http://$cleanIP:$port/stream.mjpg';
  }

  String get snapshotUrl {
    final ip = cameraIP ?? '192.168.1.2';
    final cleanIP = ip.contains(':') ? ip.split(':').first : ip;
    final port = ip.contains(':') ? ip.split(':').last : '8070';
    return 'http://$cleanIP:$port/snapshot.jpg';
  }

  int get cameraPort {
    final ip = cameraIP ?? '192.168.1.2:8070';
    return ip.contains(':') ? int.tryParse(ip.split(':').last) ?? 8070 : 8070;
  }

  String get cameraHost {
    final ip = cameraIP ?? '192.168.1.2';
    return ip.contains(':') ? ip.split(':').first : ip;
  }

  @override
  Map<String, dynamic> toSerializableMap() => {
        'isConnected': serializeParam(
          isConnected,
          ParamType.bool,
        ),
        'cameraIP': serializeParam(
          cameraIP,
          ParamType.String,
        ),
        'cameraName': serializeParam(
          cameraName,
          ParamType.String,
        ),
        'cameraMacAddress': serializeParam(
          cameraMacAddress,
          ParamType.String,
        ),
        'connectionType': serializeParam(
          connectionType,
          ParamType.String,
        ),
      }.withoutNulls;

  static CameraConnectionStruct fromSerializableMap(Map<String, dynamic> data) =>
      CameraConnectionStruct(
        isConnected: deserializeParam(
          data['isConnected'],
          ParamType.bool,
          false,
        ) ?? false,
        cameraIP: deserializeParam(
          data['cameraIP'],
          ParamType.String,
          false,
        ),
        cameraName: deserializeParam(
          data['cameraName'],
          ParamType.String,
          false,
        ),
        cameraMacAddress: deserializeParam(
          data['cameraMacAddress'],
          ParamType.String,
          false,
        ),
        connectionType: deserializeParam(
          data['connectionType'],
          ParamType.String,
          false,
        ) ?? 'manual',
      );

}