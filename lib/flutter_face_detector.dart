import 'dart:typed_data';

import 'flutter_face_detector_platform_interface.dart';

class FlutterFaceDetector {
  Future<String?> getPlatformVersion() {
    return FlutterFaceDetectorPlatform.instance.getPlatformVersion();
  }

  Future<Map<String, dynamic>> faceDetectionFromImage(Uint8List imageData) {
    return FlutterFaceDetectorPlatform.instance
        .faceDetectionFromImage(imageData);
  }
}
