import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as img_tools;

import 'package:privacyblur/src/utils/image_filter/helpers/range_checker.dart';

import 'helpers/filter_result.dart';
import 'helpers/image_rgb.dart';
import 'helpers/matrix__interface.dart';
import 'helpers/matrix_pixelate.dart';

/// Class can filter image. Change color mode. Use layout effects like OR, XOR
/// It also possible to filter only one channel (RGB), or display the only some of them
///
///possibility of Class:
/// 	- preview of changes before commiting
/// 	- reseting changes in some special area (erase tool)

class ImageAppFilter {
  ImageAppFilter._internal();

  // important for Blur filter speed optimization.
  // can be exception if area width/height is bigger than this value
  // look setMaxProcessedWidth(...) to change this value in runtime
  static int _maxWidthArea = 1000;

  static int get maxWidth => _maxWidthArea;
  static final ImageAppFilter _instance = ImageAppFilter._internal();

  factory ImageAppFilter() => _instance;

  ImageAppMatrix _activeMatrix = MatrixAppPixelate(30);
  final ImageRGB _imgChannels = ImageRGB();

  void setFilter(ImageAppMatrix newMatrix) {
    _activeMatrix = newMatrix;
  }

  Future<ImageFilterResult> setImage(img_tools.Image image) async {
    transactionCancel();
    await _imgChannels.splitImage(image);
    needRebuild = true;

    /// here ALFA channel will be removed from PNG or GIF images
    /// For JPEG its not relevant
    _responseCache = await getImage();
    transactionStart();
    return Future.value(_responseCache);
  }

  static void setMaxProcessedWidth(int maxWidth) {
    _maxWidthArea = maxWidth;
  }

  void _cancelArea(RangeHelper range) {
    int pointIndex = 0;
    for (int y = range.y1; y <= range.y2; y++) {
      for (int x = range.x1; x <= range.x2; x++) {
        if (!range.checkPointInRange(x, y)) continue;
        pointIndex = (y * _imgChannels.imageWidth) + x;
        if (!_imgChannels.processed[pointIndex]) continue;
        _imgChannels.processed[pointIndex] = false;
        _imgChannels.tempImgArr[pointIndex] = 0xff000000 | // alfa
            ((_imgChannels.sourceRed[pointIndex] << 16) & 0xff0000) | //red
            ((_imgChannels.sourceGreen[pointIndex] << 8) & 0xff00) | //green
            ((_imgChannels.sourceBlue[pointIndex]) & 0xff); //blue*/
      }
    }
    _imgChannels.resetSmallCacheAfterCancel();
    needRebuild = true;
  }

  bool _allCanceled = true;

  void cancelAll() {
    if (!_imgChannels.transactionActive) return;
    if (_allCanceled) return;
    _allCanceled = true;
    _imgChannels.resetRange();
    _cancelArea(_imgChannels.getChangedRange());
  }

  void cancelArea(int centerX, int centerY, int radius, isCircle) {
    if (!_imgChannels.transactionActive) return;
    if (_allCanceled) return;
    RangeHelper range = RangeHelper(centerX, centerY, radius, isCircle,
        _imgChannels.imageWidth, _imgChannels.imageHeight, 0);
    _cancelArea(range);
  }

  void apply2Area(int centerX, int centerY, int radius, bool isCircle) {
    if (!_imgChannels.transactionActive) return;
    RangeHelper range = RangeHelper(centerX, centerY, radius, isCircle,
        _imgChannels.imageWidth, _imgChannels.imageHeight, 0);
    _activeMatrix.calculateInRange(range, _imgChannels);
    _allCanceled = false;
    _imgChannels.collectRange(range);
    needRebuild = true;
  }

  void transactionStart() {
    if (_imgChannels.transactionActive) return;
    _imgChannels.transactionActive = true;
    _allCanceled = true;
    _imgChannels.resetRange();
  }

  void transactionCancel() {
    if (!_imgChannels.transactionActive) return;
    cancelAll();
    _imgChannels.processed.fillRange(0, _imgChannels.processed.length, false);
    _imgChannels.transactionActive = false;
    _allCanceled = true;
    _imgChannels.resetRange();
    _responseCache.changedPart = null;
    needRebuild = false; //we dont need to rebuild image. use background
  }

  void transactionCommit() {
    if (!_imgChannels.transactionActive) return;
    int colorValue = 0;
    for (int i = 0; i < _imgChannels.sourceRed.length; i++) {
      if (_imgChannels.processed[i]) {
        colorValue = _imgChannels.tempImgArr[i];
        _imgChannels.sourceRed[i] = (colorValue >> 16) & 0xff;
        _imgChannels.sourceGreen[i] = (colorValue >> 8) & 0xff;
        _imgChannels.sourceBlue[i] = colorValue & 0xff;
      }
    }
    _imgChannels.processed.fillRange(0, _imgChannels.processed.length, false);
    _imgChannels.transactionActive = false;
    _allCanceled = true;
    _imgChannels.resetRange();
    needRebuild = true;
  }

  bool needRebuild = true; //to force rebuild in calling getCurrentImageState()
  ImageFilterResult _responseCache = ImageFilterResult.empty();

  Uint8List yuv = Uint8List(0);

  Uint8List getImageNV21() {
    final int width = imageWidth();
    final int height = imageHeight();
    final int frameSize = width * height;
    int yIndex = 0;
    int uvIndex = frameSize;
    final int newSize = ((width * height * 7) ~/ 4);
    if (yuv.length != newSize) {
      yuv = Uint8List(newSize);
    }
    var argb = getImageARGB32();
    int a, R, G, B, Y, U, V;
    int index = 0;
    for (int j = 0; j < height; j++) {
      for (int i = 0; i < width; i++) {
        //a = (argb[index] & 0xff000000) >> 24; // a is not used obviously
        R = (argb[index] & 0xff0000) >> 16;
        G = (argb[index] & 0xff00) >> 8;
        B = (argb[index] & 0xff) >> 0;

        // well known RGB to YUV algorithm
        Y = ((66 * R + 129 * G + 25 * B + 128) >> 8) + 16;
        U = ((-38 * R - 74 * G + 112 * B + 128) >> 8) + 128;
        V = ((112 * R - 94 * G - 18 * B + 128) >> 8) + 128;

        // NV21 has a plane of Y and interleaved planes of VU each sampled by a factor of 2
        //    meaning for every 4 Y pixels there are 1 V and 1 U.  Note the sampling is every other
        //    pixel AND every other scanline.
        yuv[yIndex++] = ((Y < 0) ? 0 : ((Y > 255) ? 255 : Y));
        if ((j % 2 == 0) && (index % 2 == 0)) {
          yuv[uvIndex++] = ((V < 0) ? 0 : ((V > 255) ? 255 : V));
          yuv[uvIndex++] = ((U < 0) ? 0 : ((U > 255) ? 255 : U));
        }

        index++;
      }
    }
    return yuv;
  }

  Uint8List getImageARGB8() {
    return _imgChannels.tempImgArr.buffer.asUint8List();
  }

  Uint32List getImageARGB32() {
    return _imgChannels.tempImgArr;
  }

  int imageWidth() {
    return _imgChannels.imageWidth;
  }

  int imageHeight() {
    return _imgChannels.imageHeight;
  }

  Future<ImageFilterResult> getImage() {
    if (!needRebuild) return Future.value(_responseCache);
    Completer<ImageFilterResult> _completer = Completer();
    if (_imgChannels.transactionActive) {
      var range = _imgChannels.getChangedRange();
      img_tools.decodeImageFromPixels(
          _imgChannels.getChangedData(),
          range.rangeWidth,
          range.rangeHeight,
          img_tools.PixelFormat.rgba8888, (result) {
        _responseCache.posX = range.x1;
        _responseCache.posY = range.y1;
        _responseCache.changedPart = result;
        needRebuild = false;
        _completer.complete(_responseCache);
      });
    } else {
      img_tools.decodeImageFromPixels(
          _imgChannels.tempImgArr.buffer.asUint8List(),
          _imgChannels.imageWidth,
          _imgChannels.imageHeight,
          img_tools.PixelFormat.rgba8888, (result) {
        _responseCache.mainImage = result;
        _responseCache.changedPart = null;
        needRebuild = false;
        _completer.complete(_responseCache);
      });
    }
    return _completer.future;
  }
}
