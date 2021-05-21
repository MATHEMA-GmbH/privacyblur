import 'dart:async';
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
  static int _max_width_area = 1000;

  static int get maxWidth => _max_width_area;
  static ImageAppFilter _instance = ImageAppFilter._internal();

  factory ImageAppFilter() => _instance;

  ImageAppMatrix _activeMatrix = MatrixAppPixelate(30);
  final ImageRGB imgChannels = ImageRGB();

  void setFilter(ImageAppMatrix newMatrix) {
    _activeMatrix = newMatrix;
  }

  Future<ImageFilterResult> setImage(img_tools.Image image) async {
    _response_cache.mainImage = image; //Important to set it first before all
    _response_cache.changedPart = null;
    await imgChannels.splitImage(image);
    imgChannels.transactionActive = false;
    return Future.value(_response_cache);
  }

  static void setMaxProcessedWidth(int maxWidth) {
    _max_width_area = maxWidth;
  }

  void _cancelArea(RangeHelper range) {
    int pointIndex = 0;
    for (int y = range.y1; y <= range.y2; y++) {
      for (int x = range.x1; x <= range.x2; x++) {
        if (!range.checkPointInRange(x, y)) continue;
        pointIndex = (y * imgChannels.imageWidth) + x;
        if (!imgChannels.processed[pointIndex]) continue;
        imgChannels.processed[pointIndex] = false;
        imgChannels.tempImgArr[pointIndex] = 0xff000000 | // alfa
            ((imgChannels.sourceRed[pointIndex] << 16) & 0xff0000) | //red
            ((imgChannels.sourceGreen[pointIndex] << 8) & 0xff00) | //green
            ((imgChannels.sourceBlue[pointIndex]) & 0xff); //blue*/
      }
    }
    needRebuild = true;
  }

  bool _allCanceled = true;

  void cancelCurrent() {
    if (!imgChannels.transactionActive) return;
    if (_allCanceled) return;
    _allCanceled = true;
    imgChannels.resetRange();
    _cancelArea(imgChannels.getChangedRange());
  }

  void cancelSquare(int cx1, int cy1, int cx2, int cy2) {
    if (!imgChannels.transactionActive) return;
    if (_allCanceled) return;
    RangeHelper range = RangeHelper.square(
        cx1, cy1, cx2, cy2, imgChannels.imageWidth, imgChannels.imageHeight, 0);
    _cancelArea(range);
  }

  void cancelCircle(int cx1, int cy1, int radius) {
    if (!imgChannels.transactionActive) return;
    if (_allCanceled) return;
    RangeHelper range = RangeHelper.rounded(
        cx1, cy1, radius, imgChannels.imageWidth, imgChannels.imageHeight, 0);
    _cancelArea(range);
  }

  void apply2SquareArea(int centerX, int centerY, double radius) {
    _apply2SquareArea((centerX - radius).toInt(), (centerY - radius).toInt(),
        (centerX + radius).toInt(), (centerY + radius).toInt());
  }

  void _apply2SquareArea(int x1, int y1, int x2, int y2) {
    if (!imgChannels.transactionActive) return;
    RangeHelper range = RangeHelper.square(
        x1,
        y1,
        x2,
        y2,
        imgChannels.imageWidth,
        imgChannels.imageHeight,
        _activeMatrix.emptyBorder());
    _activeMatrix.calculateInRange(range, imgChannels);
    _allCanceled = false;
    imgChannels.collectRange(range);
    needRebuild = true;
  }

  void apply2CircleArea(int centerX, int centerY, double radius) {
    if (!imgChannels.transactionActive) return;
    RangeHelper range = RangeHelper.rounded(
        centerX,
        centerY,
        radius.toInt(),
        imgChannels.imageWidth,
        imgChannels.imageHeight,
        _activeMatrix.emptyBorder());
    _activeMatrix.calculateInRange(range, imgChannels);
    _allCanceled = false;
    imgChannels.collectRange(range);
    needRebuild = true;
  }

  void transactionStart() {
    if (imgChannels.transactionActive) return;
    imgChannels.transactionActive = true;
    _allCanceled = true;
    imgChannels.resetRange();
  }

  void transactionCancel() {
    if (!imgChannels.transactionActive) return;
    cancelCurrent();
    imgChannels.processed.fillRange(0, imgChannels.processed.length, false);
    imgChannels.transactionActive = false;
    _allCanceled = true;
    imgChannels.resetRange();
    _response_cache.changedPart = null;
    needRebuild = false; //we dont need to rebuild image. use background
  }

  void transactionCommit() {
    if (!imgChannels.transactionActive) return;
    int colorValue = 0;
    for (int i = 0; i < imgChannels.sourceRed.length; i++) {
      if (imgChannels.processed[i]) {
        colorValue = imgChannels.tempImgArr[i];
        imgChannels.sourceRed[i] = (colorValue >> 16) & 0xff;
        imgChannels.sourceGreen[i] = (colorValue >> 8) & 0xff;
        imgChannels.sourceBlue[i] = colorValue & 0xff;
      }
    }
    imgChannels.processed.fillRange(0, imgChannels.processed.length, false);
    imgChannels.transactionActive = false;
    _allCanceled = true;
    imgChannels.resetRange();
    needRebuild = true;
  }

  bool needRebuild = true; //to force rebuild in calling getCurrentImageState()
  ImageFilterResult _response_cache = ImageFilterResult.empty();

  Future<ImageFilterResult> getImage() {
    if (!needRebuild) return Future.value(_response_cache);
    Completer<ImageFilterResult> _completer = new Completer();
    if (imgChannels.transactionActive) {
      var range = imgChannels.getChangedRange();
      img_tools.decodeImageFromPixels(
          imgChannels.getChangedData(),
          range.rangeWidth,
          range.rangeHeight,
          img_tools.PixelFormat.rgba8888, (result) {
        _response_cache.posX = range.x1;
        _response_cache.posY = range.y1;
        _response_cache.changedPart = result;
        needRebuild = false;
        _completer.complete(_response_cache);
      });
    } else {
      img_tools.decodeImageFromPixels(
          imgChannels.tempImgArr.buffer.asUint8List(),
          imgChannels.imageWidth,
          imgChannels.imageHeight,
          img_tools.PixelFormat.rgba8888, (result) {
        _response_cache.mainImage = result;
        _response_cache.changedPart = null;
        needRebuild = false;
        _completer.complete(_response_cache);
      });
    }
    return _completer.future;
  }
}