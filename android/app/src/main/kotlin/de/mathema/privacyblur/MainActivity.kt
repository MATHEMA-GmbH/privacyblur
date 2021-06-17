package de.mathema.privacyblur

import androidx.annotation.NonNull
import com.google.mlkit.vision.common.InputImage
import com.google.mlkit.vision.face.FaceDetection
import com.google.mlkit.vision.face.FaceDetectorOptions
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL = "de.mathema.privacyblur/memory"
    private val FACEDETECTION = "de.mathema.privacyblur/face_detection"

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            CHANNEL
        ).setMethodCallHandler { call, result ->
            if (call.method == "getHeapSize") {
                result.success(Runtime.getRuntime().maxMemory())
            } else {
                result.notImplemented()
            }
        }

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            FACEDETECTION
        ).setMethodCallHandler { call, result ->
            if (call.method == "detectFaces") {
                try {
                    val srcImageNV21: ByteArray = call.argument<ByteArray>("nv21")!!
                    val width: Int = call.argument<Int>("width")!!
                    val height: Int = call.argument<Int>("height")!!
                    // Real-time contour detection
                    val realTimeOpts = FaceDetectorOptions.Builder()
                        .setPerformanceMode(FaceDetectorOptions.PERFORMANCE_MODE_FAST)
                        .setContourMode(FaceDetectorOptions.CONTOUR_MODE_NONE)
                        .setClassificationMode(FaceDetectorOptions.CLASSIFICATION_MODE_NONE)
                        .setLandmarkMode(FaceDetectorOptions.LANDMARK_MODE_NONE)
                        .build()
                    var processedImage = InputImage.fromByteArray(
                        srcImageNV21,
                        width,
                        height,
                        0,
                        InputImage.IMAGE_FORMAT_NV21
                    )
                    val detector = FaceDetection.getClient(realTimeOpts)
                    val detectionProcess = detector.process(processedImage)
                        .addOnSuccessListener { faces ->
                            val arr: IntArray = IntArray(faces.size * 4)
                            var arrIndex: Int = 0
                            for (i in 0 until faces.size) {
                                val face = faces[i];
                                arr[arrIndex++] = face.boundingBox.left //x1
                                arr[arrIndex++] = face.boundingBox.top //y1
                                arr[arrIndex++] = face.boundingBox.right //x2
                                arr[arrIndex++] = face.boundingBox.bottom //y2
                            }
                            result.success(arr)
                        }
                        .addOnFailureListener { e ->
                            result.error(e.stackTrace.toString(), e.localizedMessage, e)
                        }
                        .addOnCanceledListener {
                            result.error("canceled", "canceled", "canceled")
                        }
                } catch (e: Exception) {
                    result.error(e.stackTrace.toString(), e.localizedMessage, e)
                }
            } else {
                result.notImplemented()
            }
        }

    }
}
