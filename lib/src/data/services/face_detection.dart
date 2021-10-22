import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/services.dart';

class Face {
  final int x;
  final int y;
  final int radius;

  Face(this.x, this.y, this.radius);
}

typedef Faces = List<Face>;

abstract class FaceDetectionService {
  Future<Faces> detectFaces(
      Uint8List nv21ImageData, int width, int height) async {
    return Future.value(Faces.empty());
  }
}

class FaceDetection extends FaceDetectionService {
  static const _platform =
      MethodChannel('de.mathema.privacyblur/face_detection');

  FaceDetection._privateConstructor();

  static final FaceDetection _instance = FaceDetection._privateConstructor();

  factory FaceDetection() {
    return _instance;
  }

  @override
  Future<Faces> detectFaces(
      Uint8List nv21ImageData, int width, int height) async {
    try {
      final Faces list = List.empty(growable: true);
      Int32List result = await _platform.invokeMethod('detectFaces',
          {'nv21': nv21ImageData, 'width': width, 'height': height});
      for (int i = 0; i < result.length; i += 4) {
        int x1 = result[i];
        int y1 = result[i + 1];
        int x2 = result[i + 2];
        int y2 = result[i + 3];
        list.add(Face((x1 + x2) ~/ 2, (y1 + y2) ~/ 2,
            max((x1 - x2).abs(), (y1 - y2).abs()) ~/ 2));
      }
      return Future.value(list);
    } catch (err) {
      return Future.value([]);
    }
  }
}
