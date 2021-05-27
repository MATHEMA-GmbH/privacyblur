import 'dart:typed_data';
import 'dart:ui' as img_tools;

import 'range_checker.dart';

class ImageRGB {
  ImageRGB._internal();

  static var _instance = ImageRGB._internal();
  int size = 0;

  Future<void> splitImage(img_tools.Image _image) async {
    _instance.imageWidth = _image.width;
    _instance.imageHeight = _image.height;
    Uint32List data =
        (await _image.toByteData(format: img_tools.ImageByteFormat.rawRgba))!
            .buffer
            .asUint32List();
    _instance.size = data.length;
    if (_instance.sourceRed.length != _instance.size) {
      _instance.sourceRed = Uint8List(_instance.size);
      _instance.sourceGreen = Uint8List(_instance.size);
      _instance.sourceBlue = Uint8List(_instance.size);
      _instance.tempImgArr = Uint32List(_instance.size);
      _instance.processed = List.filled(_instance.size, false, growable: false);
    }
    int pixel = 0;
    for (int index = 0; index < data.length; index++) {
      pixel = data[index];
      _instance.tempImgArr[index] = pixel;
      _instance.sourceRed[index] = (pixel >> 16) & 0xff;
      _instance.sourceGreen[index] = (pixel >> 8) & 0xff;
      _instance.sourceBlue[index] = pixel & 0xff;
      _instance.processed[index] = false;
    }
    return Future.value();
  }

  var maxx = 0;
  var maxy = 0;
  var minx = 5000;
  var miny = 5000;

  void resetRange() {
    maxx = 0;
    maxy = 0;
    minx = imageWidth - 1;
    miny = imageHeight - 1;
    _copyAgain = true;
  }

  Uint32List _changedArea = Uint32List(0);
  bool _copyAgain = true;

  void collectRange(RangeHelper range) {
    if (range.x1 > maxx) maxx = range.x1;
    if (range.x1 < minx) minx = range.x1;
    if (range.y1 > maxy) maxy = range.y1;
    if (range.y1 < miny) miny = range.y1;
    if (range.x2 > maxx) maxx = range.x2;
    if (range.x2 < minx) minx = range.x2;
    if (range.y2 > maxy) maxy = range.y2;
    if (range.y2 < miny) miny = range.y2;
    _copyAgain = true;
    _range_cache = null;
  }

  RangeHelper? _range_cache;

  RangeHelper getChangedRange() {
    if (_range_cache == null) {
      _range_cache = RangeHelper.square(
          minx, miny, maxx, maxy, imageWidth, imageHeight, 0);
    }
    return _range_cache!;
  }

  Uint8List getChangedData() {
    if (!_copyAgain) return _changedArea.buffer.asUint8List();
    _copyAgain = false;
    _range_cache = getChangedRange();
    var size = _range_cache!.rangeWidth * _range_cache!.rangeHeight;
    if (size != _changedArea.length) {
      _changedArea = Uint32List(size);
    }
    int startoffset = 0;
    int endoffset;
    int counter = -1;
    for (int y = _range_cache!.y1; y < _range_cache!.y2; y++) {
      startoffset = y * imageWidth + _range_cache!.x1;
      endoffset = startoffset + _range_cache!.rangeWidth;
      for (int index = startoffset; index < endoffset; index++) {
        counter++;
        _changedArea[counter] = tempImgArr[index];
      }
    }
    return _changedArea.buffer.asUint8List();
  }

  factory ImageRGB() => _instance;

  int imageWidth = 0;
  int imageHeight = 0;
  Uint8List sourceRed = Uint8List(0);
  Uint8List sourceGreen = Uint8List(0);
  Uint8List sourceBlue = Uint8List(0);
  Uint32List tempImgArr = Uint32List(0);
  late List<bool> processed = List.filled(0, false, growable: false);
  bool transactionActive = false;
}
