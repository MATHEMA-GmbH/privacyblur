import UIKit
import Flutter
import Foundation
import MLKitFaceDetection
import MLKitVision

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)

    let HEAP_SIZE_CHANNEL = "de.mathema.privacyblur/memory";
    let FACE_DETECTION_CHANNEL = "de.mathema.privacyblur/face_detection";

    let controller : FlutterViewController = window?.rootViewController as! FlutterViewController
    let heapSizeChannel = FlutterMethodChannel(name: HEAP_SIZE_CHANNEL, binaryMessenger: controller.binaryMessenger)
    let faceDetectionChannel = FlutterMethodChannel(name: FACE_DETECTION_CHANNEL, binaryMessenger: controller.binaryMessenger)

    heapSizeChannel.setMethodCallHandler({
      [weak self] (call: FlutterMethodCall, result: FlutterResult) -> Void in
      guard call.method == "getHeapSize" else {
        result(FlutterMethodNotImplemented)
        return
      }
      self?.getHeapSize(result: result)
    })

    faceDetectionChannel.setMethodCallHandler({
      [weak self] (call: FlutterMethodCall, result: @escaping FlutterResult) -> Void in
      guard call.method == "detectFaces" else {
        result(FlutterMethodNotImplemented)
        return
      }
      do {
        try self?.detectFaces(call: call, result: result)
      } catch {
        result(FlutterError(code: "UNAVAILABLE", message: "Unexpected error.", details: nil))
        return
      }
    })

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  private func detectFaces(call: FlutterMethodCall, result: @escaping FlutterResult) {
    if let args = call.arguments as? Dictionary<String, Any>,
       let srcImage : FlutterStandardTypedData = args["nv21"] as? FlutterStandardTypedData,
       let width = args["width"] as? NSNumber,
       let height = args["height"] as? NSNumber {
        
        let image : UIImage = imageFromARGB32Bitmap(argb: srcImage.data, width: Int(width), height: Int(height))!

        let options = FaceDetectorOptions()
         options.performanceMode = .fast
         options.landmarkMode = .none
         options.classificationMode = .none
        let visionImage = VisionImage(image: image)
        visionImage.orientation = image.imageOrientation
        let faceDetector = FaceDetector.faceDetector(options: options)

        weak var weakSelf = self
        faceDetector.process(visionImage) { faces, error in
          guard let strongSelf = weakSelf, let faces = faces else {
              return
          }
            var arr: Array<UInt32> = Array.init(repeating: 0, count: Int(faces.count) * 4)
            var arrIndex: Int = 0

        for face in faces {
            arr[arrIndex] = UInt32(face.frame.minX)
            arrIndex += 1
            arr[arrIndex] = UInt32(face.frame.minY)
            arrIndex += 1
            arr[arrIndex] = UInt32(face.frame.maxX)
            arrIndex += 1
            arr[arrIndex] = UInt32(face.frame.maxY)
            arrIndex += 1
        }
          result(FlutterStandardTypedData(int32: arr.withUnsafeBufferPointer {Data(buffer: $0)}))
          return
        }
    } else {
      result(FlutterError.init(code: "BAD ARGS", message: nil, details: nil))
    }
  }

  func imageFromARGB32Bitmap(argb: Data, width: Int, height: Int) -> UIImage? {
      let bitsPerComponent: UInt = 8
      let bitsPerPixel: UInt = 32
      let rgbColorSpace = CGColorSpaceCreateDeviceRGB()
    let bitmapInfo:CGBitmapInfo = CGBitmapInfo.init(rawValue: CGImageAlphaInfo.premultipliedFirst.rawValue)

    var nsData = argb as NSData
    let rawPtr = nsData.bytes
    let providerRef = CGDataProvider.init(data: NSData(bytes: rawPtr, length: 4 * Int(width) * Int(height) ))
      let providerRefthing: CGDataProvider = providerRef!
    let cgImage = CGImage.init( width: width, height: height, bitsPerComponent: Int(bitsPerComponent), bitsPerPixel: Int(bitsPerPixel), bytesPerRow: width * 4, space: rgbColorSpace, bitmapInfo: bitmapInfo, provider: providerRef!, decode: nil, shouldInterpolate: false, intent: .defaultIntent)
   
      let cgiimagething: CGImage = cgImage!
      return UIImage(cgImage: cgImage!)
  }

  private func getHeapSize(result: FlutterResult) {
    let TASK_VM_INFO_COUNT = MemoryLayout<task_vm_info_data_t>.size / MemoryLayout<natural_t>.size

    var vmInfo = task_vm_info_data_t()
    var vmInfoSize = mach_msg_type_number_t(TASK_VM_INFO_COUNT)

    let kern: kern_return_t = withUnsafeMutablePointer(to: &vmInfo) {
            $0.withMemoryRebound(to: integer_t.self, capacity: 1) {
                task_info(mach_task_self_,
                          task_flavor_t(TASK_VM_INFO),
                          $0,
                          &vmInfoSize)
                }
            }

    if kern == KERN_SUCCESS {
        let usedSize = Int(vmInfo.internal + vmInfo.compressed)
        result(usedSize)
    } else {
        let errorString = String(cString: mach_error_string(kern), encoding: .ascii) ?? "unknown error"
        result("Error with task_info():" + errorString)
    }
  }
}
