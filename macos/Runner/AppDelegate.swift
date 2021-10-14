import Cocoa
import Foundation
import FlutterMacOS
import Vision
import AppKit
import CoreGraphics

@NSApplicationMain
class AppDelegate: FlutterAppDelegate {
    private var HEAP_SIZE_CHANNEL: String = "de.mathema.privacyblur/memory";
    // private var FACE_DETECTION_CHANNEL: String = "de.mathema.privacyblur/face_detection";
    
    override func applicationDidFinishLaunching(_ notification: Notification) {
        let controller : FlutterViewController = mainFlutterWindow?.contentViewController as! FlutterViewController
        let heapSizeChannel = FlutterMethodChannel.init(name: HEAP_SIZE_CHANNEL, binaryMessenger:  controller.engine.binaryMessenger)
        // let faceDetectionChannel = FlutterMethodChannel.init(name: FACE_DETECTION_CHANNEL, binaryMessenger:  controller.engine.binaryMessenger)
        
        heapSizeChannel.setMethodCallHandler({
            [weak self] (call: FlutterMethodCall, result: @escaping FlutterResult) -> Void in
            guard call.method == "getHeapSize" else {
                result(FlutterMethodNotImplemented)
                return
            }
            self?.getHeapSize(result: result)
        })

        /*
         faceDetectionChannel.setMethodCallHandler({
            [weak self] (call: FlutterMethodCall, result: @escaping FlutterResult) -> Void in
            guard call.method == "detectFaces" else {
                result(FlutterMethodNotImplemented)
                return
            }
            self?.detectFaces(call: call, result: result)
        })
        */
    }
    
    override func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {

        return true
    }
    
    private func getHeapSize(result: @escaping FlutterResult) {
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
    
    /*
    private func detectFaces(call: FlutterMethodCall, result: @escaping FlutterResult) {
        if let args = call.arguments as? Dictionary<String, Any>,
        let srcImage : FlutterStandardTypedData = args["nv21"] as? FlutterStandardTypedData,
        let width = args["width"] as? NSNumber,
        let height = args["height"] as? NSNumber {
            guard let image = getCGImage(argb: srcImage.data, width: Int.init(truncating: width), height: Int.init(truncating: height)) else {
                return
            }
            
            let imageBoundaries = CGRect(x: 0, y: 0, width: image.width, height: image.height)

            let sequenceHandler = VNImageRequestHandler(cgImage:image, orientation: CGImagePropertyOrientation.leftMirrored)
            
            let rectangleDetectionRequest: VNDetectRectanglesRequest = {
                let rectDetectRequest = VNDetectRectanglesRequest{ request, error in
                    self.detectedFaces(request: request, error: error, result: result, boundaries: imageBoundaries)
                }
                rectDetectRequest.maximumObservations = 8 // Vision currently supports up to 16.
                rectDetectRequest.minimumConfidence = 0.6 // Be confident.
                rectDetectRequest.minimumAspectRatio = 0.3 // height / width
                return rectDetectRequest
            }()

            do {
                try sequenceHandler.perform([rectangleDetectionRequest])
            } catch {
                print(error.localizedDescription)
            }
            
        } else {
          result(FlutterError.init(code: "BAD ARGS", message: nil, details: nil))
        }
    }

    private func detectedFaces(request: VNRequest, error: Error?, result: @escaping FlutterResult, boundaries: CGRect) {
        guard
            let observations = request.results as? [VNFaceObservation]
        else {
            return
        }
        handleDetection(result, observations: observations, boundaries: boundaries)
    }
    
    private func handleDetection(_ result: @escaping FlutterResult, observations: [VNFaceObservation], boundaries: CGRect) {
        var arr: Array<UInt32> = Array.init(repeating: 0, count: Int(observations.count) * 4)
        var arrIndex: Int = 0
        
        for face in observations {
            let boundingBox = convert(origin: boundaries, target: face.boundingBox)
            arr[arrIndex] = UInt32(boundingBox.minX)
            arrIndex += 1
            arr[arrIndex] = UInt32(boundingBox.minY)
            arrIndex += 1
            arr[arrIndex] = UInt32(boundingBox.maxX)
            arrIndex += 1
            arr[arrIndex] = UInt32(boundingBox.maxY)
            arrIndex += 1
        }

        result(FlutterStandardTypedData(int32: arr.withUnsafeBufferPointer {Data(buffer: $0)}))
    }

    private func getCGImage(argb: Data, width: Int, height: Int) -> CGImage? {
        let bitsPerComponent: UInt = 8
        let bitsPerPixel: UInt = 32
        let rgbColorSpace = CGColorSpaceCreateDeviceRGB()
        let bitmapInfo:CGBitmapInfo = CGBitmapInfo.init(rawValue: CGImageAlphaInfo.premultipliedFirst.rawValue)

        let nsData = argb as NSData
        let rawPtr = nsData.bytes
        let providerRef = CGDataProvider.init(data: NSData(bytes: rawPtr, length: 4 * Int(width) * Int(height) ))
        let cgImage = CGImage.init(width: width, height: height, bitsPerComponent: Int(bitsPerComponent), bitsPerPixel: Int(bitsPerPixel), bytesPerRow: width * 4, space: rgbColorSpace, bitmapInfo: bitmapInfo, provider: providerRef!, decode: nil, shouldInterpolate: false, intent: .defaultIntent)

        return cgImage;
    }
    
    func convert(origin: CGRect, target: CGRect) -> CGRect {
        let tf = CGAffineTransform.init(scaleX: 1, y: -1).translatedBy(x: 0, y: -origin.size.height)
        let ts = CGAffineTransform.identity.scaledBy(x: origin.size.width, y: origin.size.height)
        let converted_rect = target.applying(ts).applying(tf)
        
        return converted_rect
    }
     */
}
