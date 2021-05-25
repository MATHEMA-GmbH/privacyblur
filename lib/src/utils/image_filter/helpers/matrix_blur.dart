import 'package:privacyblur/src/utils/image_filter/helpers/range_checker.dart';

import '../image_filters.dart';
import 'image_rgb.dart';
import 'matrix__interface.dart';

/// -------------- WARNING! ------------------------
/// -------------- ACHTUNG! ------------------------
/// will work properly only for square and circle filtered areas
/// with center inside image - NOT OUTSIDE
/// -------------- WARNING! ------------------------
/// -------------- ACHTUNG! ------------------------
class MatrixAppBlur extends ImageAppMatrix {
  final int _size;
  late int _matrix_empty_border;
  late int _stepBack;
  late int divider;

  MatrixAppBlur(size) : _size = (size <= 0 ? 1 : size) {
    _matrix_empty_border = 0; //(_size ~/ 2);
    _stepBack = _size ~/ 2;
    divider = _size * _size;
    if (ImageAppFilter.maxWidth > prevRowR.length) {
      prevRowR = List.filled(ImageAppFilter.maxWidth, 0, growable: false);
      prevRowG = List.filled(ImageAppFilter.maxWidth, 0, growable: false);
      prevRowB = List.filled(ImageAppFilter.maxWidth, 0, growable: false);
      prevRowIndexR =
          List.filled(ImageAppFilter.maxWidth, -10, growable: false);
      prevRowIndexG =
          List.filled(ImageAppFilter.maxWidth, -10, growable: false);
      prevRowIndexB =
          List.filled(ImageAppFilter.maxWidth, -10, growable: false);
    }
  }

  //todo reset values
  final List<int> cachedColorResult = List.filled(3, 0, growable: false);
  final List<int> cachedColorIndex = List.filled(3, -10, growable: false);

  static var prevRowR =
      List.filled(ImageAppFilter.maxWidth, 0, growable: false);
  static var prevRowG =
      List.filled(ImageAppFilter.maxWidth, 0, growable: false);
  static var prevRowB =
      List.filled(ImageAppFilter.maxWidth, 0, growable: false);
  static var prevRowIndexR =
      List.filled(ImageAppFilter.maxWidth, -10, growable: false);
  static var prevRowIndexG =
      List.filled(ImageAppFilter.maxWidth, -10, growable: false);
  static var prevRowIndexB =
      List.filled(ImageAppFilter.maxWidth, -10, growable: false);

  int _calculateArea(int colorStartIndex, List<int> arr, int width, int ch,
      int indexHelper, int rowIndexHelper) {
    int result = 0;
    int diff = 0;
    var prevRowIndex =
        (ch == 0) ? prevRowIndexB : (ch == 1 ? prevRowIndexG : prevRowIndexR);
    var prevRow = (ch == 0) ? prevRowB : (ch == 1 ? prevRowG : prevRowR);
    //check prev value form line

    /// get prev value in line
    if (rowIndexHelper - prevRowIndex[indexHelper] == 1) {
      // Caching Row --- works faster then Caching Column
      // take info from first item in array with indexHelper index
      // check prev row value
      /// cached values in prev row - add very much performance
      if (colorStartIndex < width) {
        result = prevRow[indexHelper];
      } else {
        int addIndex = colorStartIndex + (width * (_size - 1));
        if (addIndex + _size > arr.length) {
          result = prevRow[indexHelper];
        } else {
          int removeIndex = colorStartIndex - width;
          for (int m = 0; m < _size; m++) {
            diff += arr[addIndex] - arr[removeIndex];
            removeIndex++;
            addIndex++;
          }
          result = prevRow[indexHelper] + diff;
        }
      }
    } else if (indexHelper - cachedColorIndex[ch] == 1) {
      // Caching Column --- Works slowly then Caching Row
      // cache value in line by first item
      /// this will add speed on very big matrix filter sizes more than 100
      if (colorStartIndex < 0) {
        colorStartIndex =
            colorStartIndex - ((colorStartIndex ~/ width) - 1) * width;
      }
      colorStartIndex--;
      int stepIndex = colorStartIndex + _size;
      for (int m = 0; m < _size; m++) {
        diff += arr[stepIndex] - arr[colorStartIndex];
        colorStartIndex += width;
        stepIndex += width;
      }
      result = cachedColorResult[ch] + diff;
    } else {
      /// extremely slow work, but its necessary once
      if (colorStartIndex < 0) {
        colorStartIndex =
            colorStartIndex - ((colorStartIndex ~/ width) - 1) * width;
      }
      result = 0;
      for (int m = 0; m < _size; m++) {
        for (int k = 0; k < _size; k++) {
          result += arr[colorStartIndex + k];
        }
        colorStartIndex += width;
      }
    }
    cachedColorIndex[ch] = indexHelper;
    cachedColorResult[ch] = result;
    prevRow[indexHelper] = result;
    prevRowIndex[indexHelper] = rowIndexHelper;
    return result ~/ divider;
  }

  @override
  void calculateInRange(RangeHelper range, ImageRGB channels) {
    if (range.rangeWidth <= _size || range.rangeHeight <= _size) return;
    int pointIndex = 0;
    int pointWriteIndex = 0;
    int writeValue = 0xff000000;

    int indexhelper = 0;
    int rowHelper = -1;
    prevRowIndexR.fillRange(0, prevRowIndexR.length, -10);
    prevRowIndexG.fillRange(0, prevRowIndexG.length, -10);
    prevRowIndexB.fillRange(0, prevRowIndexB.length, -10);
    cachedColorIndex.fillRange(0, 3, -10);
    for (int y = range.y1; y <= range.y2; y++) {
      rowHelper++;
      cachedColorIndex.fillRange(0, 3, -10);
      indexhelper = -1;
      for (int x = range.x1; x <= range.x2; x++) {
        indexhelper++;
        pointWriteIndex = ((y) * channels.imageWidth) + (x);
        if(channels.processed[pointWriteIndex]) continue;
        if (!range.checkPointInRange(x, y)) continue;
        pointIndex = ((y - _stepBack) * channels.imageWidth) + (x - _stepBack);
        writeValue = 0xff000000;
        writeValue = writeValue |
            ((_calculateArea(pointIndex, channels.sourceRed,
                        channels.imageWidth, 0, indexhelper, rowHelper) <<
                    16) &
                0xff0000);
        writeValue = writeValue |
            ((_calculateArea(pointIndex, channels.sourceGreen,
                        channels.imageWidth, 1, indexhelper, rowHelper) <<
                    8) &
                0xff00);
        writeValue = writeValue |
            (_calculateArea(pointIndex, channels.sourceBlue,
                    channels.imageWidth, 2, indexhelper, rowHelper) &
                0xff);

        channels.tempImgArr[pointWriteIndex] = writeValue;
        channels.processed[pointWriteIndex] = true;
      }
    }
  }

  @override
  int emptyBorder() {
    return _matrix_empty_border;
  }
}
