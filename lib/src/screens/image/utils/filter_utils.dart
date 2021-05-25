import 'package:privacyblur/src/screens/image/helpers/image_classes_helper.dart';

class FilterUtils {
  /// suppose to return new selected-index after resorting array
  int markCrossedAreas(List<FilterPosition> arr, int currentIndex) {
    if (currentIndex < 0 || currentIndex >= arr.length) return -1;
    _markRedraw(arr, currentIndex);

    currentIndex = _speedUpAreasDraw(arr, currentIndex);
    return currentIndex;
  }

  int _speedUpAreasDraw(List<FilterPosition> arr, int currentIndex) {
    var position = currentIndex;
    arr.sort((FilterPosition a, FilterPosition b) {
      if (a.isPixelate == b.isPixelate) {
        return ((a.radiusRatio - b.radiusRatio) * 1000).toInt();
      } else {
        if (a.isPixelate) return -1;
        return 1;
      }
    });
    return arr.indexWhere((element) => identical(element, position));
  }

  bool _checkCross(FilterPosition oneFilter, FilterPosition anotherFilter) {
    var anotherRadius = anotherFilter.getVisibleRadius();

    if (oneFilter.isInnerPoint(anotherFilter.posX - anotherRadius,
        anotherFilter.posY - anotherRadius)) {
      return true;
    }
    if (oneFilter.isInnerPoint(anotherFilter.posX + anotherRadius,
        anotherFilter.posY + anotherRadius)) {
      return true;
    }
    if (oneFilter.isInnerPoint(anotherFilter.posX - anotherRadius,
        anotherFilter.posY + anotherRadius)) {
      return true;
    }
    if (oneFilter.isInnerPoint(anotherFilter.posX + anotherRadius,
        anotherFilter.posY - anotherRadius)) {
      return true;
    }
    return false;
  }

  void _markRedraw(List<FilterPosition> arr, int currentIndex) {
    if (currentIndex >= arr.length || currentIndex < 0) return;
    var currentFilter = arr[currentIndex];
    var x = 0, y = 0;
    for (int i = 0; i < arr.length; i++) {
      if (i == currentIndex) continue;
      var anotherFilter = arr[i];
      if (_checkCross(currentFilter, anotherFilter)) {
        currentFilter.forceRedraw = true;
        continue;
      }
      if (_checkCross(anotherFilter, currentFilter)) {
        currentFilter.forceRedraw = true;
        continue;
      }
    }
  }
}
