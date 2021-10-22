import 'dart:typed_data';

import 'image_rgb.dart';
import 'matrix__interface.dart';
import 'range_checker.dart';

class MatrixAppPixelate extends ImageAppMatrix {
  final int _size;
  final int matrixEmptyBorder = 0;

  MatrixAppPixelate(size) : _size = (size <= 0 ? 1 : size);

  int _calculateArea(int colorStartIndex, List<int> arr, int width) {
    int result = 0;
    int divider = _size * _size;
    for (int m = 0; m < _size; m++) {
      for (int k = 0; k < _size; k++) {
        result += arr[colorStartIndex + k];
      }
      colorStartIndex += width;
    }
    return result ~/ divider;
  }

  @override
  void calculateInRange(RangeHelper range, ImageRGB channels) {
    if (range.rangeWidth <= _size || range.rangeHeight <= _size) return;
    int startIndex = (range.y1 * channels.imageWidth) + range.x1;
    int lineStep = range.x2 - range.x1;
    int endIndex = (((range.y2) * channels.imageWidth) + (range.x2));
    int limitIndex = (channels.imageHeight - 1 - _size) * channels.imageWidth -
        (channels.imageWidth - _size);
    if (endIndex >= limitIndex) endIndex = limitIndex;
    int pointIndex = startIndex;
    int lineStartRange = pointIndex;
    int arrRunIndex = 0;
    int writeValue = 0;
    List<bool> globProcessed = channels.processed;
    Uint32List globTempImgArr = channels.tempImgArr;
    while (pointIndex < endIndex) {
      writeValue = 0xff000000;
      writeValue = writeValue |
          ((_calculateArea(
                      pointIndex, channels.sourceRed, channels.imageWidth) <<
                  16) &
              0xff0000);
      writeValue = writeValue |
          ((_calculateArea(
                      pointIndex, channels.sourceGreen, channels.imageWidth) <<
                  8) &
              0xff00);
      writeValue = writeValue |
          (_calculateArea(
                  pointIndex, channels.sourceBlue, channels.imageWidth) &
              0xff);

      int my1 = (pointIndex ~/ channels.imageWidth);
      int my2 = my1 + _size;
      if (my2 >= range.y2) my2 = range.y2;
      int mx1 = (pointIndex % channels.imageWidth);
      int mx2 = mx1 + _size;
      if (mx2 >= range.x2) mx2 = range.x2;

      for (int y = my1; y <= my2; y++) {
        for (int x = mx1; x <= mx2; x++) {
          arrRunIndex = (y * channels.imageWidth) + x;
          if ((!range.checkPointInRange(x, y)) || globProcessed[arrRunIndex]) {
            continue;
          }
          globTempImgArr[arrRunIndex] = writeValue;
          globProcessed[arrRunIndex] = true;
        }
      }
      pointIndex = pointIndex + _size;
      if (pointIndex >= (lineStartRange + lineStep)) {
        lineStartRange = lineStartRange + (channels.imageWidth * _size);
        pointIndex = lineStartRange;
      }
    }
  }

  @override
  int emptyBorder() {
    return matrixEmptyBorder;
  }
}
