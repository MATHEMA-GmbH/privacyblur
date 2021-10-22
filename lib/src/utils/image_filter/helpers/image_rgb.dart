import 'dart:typed_data';
import 'dart:ui' as img_tools;

import 'range_checker.dart';

class ImageRGB {
  ImageRGB._internal();

  static final _instance = ImageRGB._internal();
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

  var maxX = 0;
  var maxY = 0;
  var minX = 5000;
  var minY = 5000;

  void resetRange() {
    maxX = 0;
    maxY = 0;
    minX = imageWidth - 1;
    minY = imageHeight - 1;
    resetSmallCacheAfterCancel();
  }

  Uint32List _changedArea = Uint32List(0);
  bool _copyAgain = true;

  /// particular image will be reseted.
  /// it necessary only after canceling filter result
  void resetSmallCacheAfterCancel() {
    _copyAgain = true;
  }

  void collectRange(RangeHelper range) {
    if (range.x1 > maxX) maxX = range.x1;
    if (range.x1 < minX) minX = range.x1;
    if (range.y1 > maxY) maxY = range.y1;
    if (range.y1 < minY) minY = range.y1;
    if (range.x2 > maxX) maxX = range.x2;
    if (range.x2 < minX) minX = range.x2;
    if (range.y2 > maxY) maxY = range.y2;
    if (range.y2 < minY) minY = range.y2;
    _rangeCache = null;
    resetSmallCacheAfterCancel();
  }

  RangeHelper? _rangeCache;

  RangeHelper getChangedRange() {
    _rangeCache ??=
        RangeHelper.square(minX, minY, maxX, maxY, imageWidth, imageHeight, 0);
    return _rangeCache!;
  }

  Uint8List getChangedData() {
    if (!_copyAgain) return _changedArea.buffer.asUint8List();
    _copyAgain = false;
    _rangeCache = getChangedRange();
    var size = _rangeCache!.rangeWidth * _rangeCache!.rangeHeight;
    if (size != _changedArea.length) {
      _changedArea = Uint32List(size);
    }
    int startOffset = 0;
    int endOffset;
    int counter = -1;
    for (int y = _rangeCache!.y1; y < _rangeCache!.y2; y++) {
      startOffset = y * imageWidth + _rangeCache!.x1;
      endOffset = startOffset + _rangeCache!.rangeWidth;
      for (int index = startOffset; index < endOffset; index++) {
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
