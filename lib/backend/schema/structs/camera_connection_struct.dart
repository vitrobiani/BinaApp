import '/backend/schema/util/schema_util.dart';
import 'index.dart';
import '/app_core/app_util.dart';

class CameraConnectionStruct extends BaseStruct {
  bool isConnected = false;
  String? cameraIP;

  CameraConnectionStruct({
    this.isConnected = false,
    this.cameraIP,
  });

  Map<String, dynamic> toMap() {
    return {
      'isConnected': isConnected,
      'cameraIP': cameraIP,
    };
  }

  static CameraConnectionStruct fromMap(Map<String, dynamic> map) {
    return CameraConnectionStruct(
      isConnected: map['isConnected'] ?? false,
      cameraIP: map['cameraIP'],
    );
  }

  bool hasCameraIP() => cameraIP != null && cameraIP!.isNotEmpty;
  bool isCameraConnected() => isConnected && hasCameraIP();

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
        ));

}