import Flutter
import UIKit
//import os

public class FlutterFaceDetectorPlugin: NSObject, FlutterPlugin {

  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(
      name: "flutter_face_detector", binaryMessenger: registrar.messenger())
    let instance = FlutterFaceDetectorPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "getPlatformVersion":
      result(InferenceConfigurationManager.sharedInstance.modelPath ?? "")

    case "faceDetectionFromImage":
      // 取得 imageData
      guard let args = call.arguments as? [String: Any],
        let imageData = args["image"] as? FlutterStandardTypedData
      else {
        result(FlutterError(code: "NO_IMAGE", message: "No image data found", details: nil))
        return
      }

      guard let uiImage = UIImage(data: imageData.data) else {
        result(FlutterError(code: "INVALID_IMAGE", message: "Unable to decode image", details: nil))
        return
      }

      // 初始化偵測服務
      guard
        let service = FaceDetectorService.stillImageDetectorService(
          modelPath: InferenceConfigurationManager.sharedInstance.modelPath,
          minDetectionConfidence: InferenceConfigurationManager.sharedInstance
            .minDetectionConfidence,
          minSuppressionThreshold: InferenceConfigurationManager.sharedInstance
            .minSuppressionThreshold,
          delegate: InferenceConfigurationManager.sharedInstance.delegate
        )
      else {
        result(
          FlutterError(
            code: "INIT_FAILED", message: "Failed to initialize FaceDetectorService", details: nil))
        return
      }

      // 執行臉部偵測
      guard let resultBundle = service.detect(image: uiImage) else {
        result(
          FlutterError(code: "DETECTION_FAILED", message: "No face detection result", details: nil))
        return
      }

      // ✅ 取得最高信心值
      var maxConfidence: Float = 0.0
      if let firstResult = resultBundle.faceDetectorResults.first, 
        let result = firstResult {
        let detections = result.detections
        for detection in detections {
          if let score = detection.categories.first?.score, score > maxConfidence {
            maxConfidence = score
          }
        }
      }
            
      // ✅ 格式化輸出
      let inferenceTimeString = String(format: "%.2fms", resultBundle.inferenceTime)
      let confidenceString = String(format: "%.2f", maxConfidence * 100) + "%"  // 轉成百分比

      // ✅ 同時回傳兩個資訊
      result([
        "inferenceTime": inferenceTimeString,
        "confidence": confidenceString,
      ])

    default:
      result(FlutterMethodNotImplemented)
    }
  }
}
