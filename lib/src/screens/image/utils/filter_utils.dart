import 'package:privacyblur/src/screens/image/helpers/image_classes_helper.dart';

class FilterUtils {
  /// suppose to return new selected-index after resorting array
  static void markCrossedAreas(List<FilterPosition> arr, int currentIndex) {
    if (currentIndex < 0 || currentIndex >= arr.length) return;
    _markRedraw(arr, currentIndex);
  }

  static int changeAreasDrawOrder(List<FilterPosition> arr, int currentIndex) {
    if (currentIndex < 0 || currentIndex >= arr.length) return -1;
    var position = arr[currentIndex];
    arr.sort((FilterPosition a, FilterPosition b) {
      if (a.isPixelate == b.isPixelate) {
        /// more powerful filter is more important, so we draw on the top
        return ((b.granularityRatio - a.granularityRatio) * 100).toInt();
      } else {
        /// we can add some rules about cross areas if filters are different
        if (a.isPixelate) return -1;
        return 1;
      }
    });
    currentIndex = arr.indexWhere((element) => identical(element, position));
    return currentIndex;
  }

  static bool _checkCross(
      FilterPosition oneFilter, FilterPosition anotherFilter) {
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

  static void _markRedraw(List<FilterPosition> arr, int currentIndex) {
    if (currentIndex >= arr.length || currentIndex < 0) return;
    var currentFilter = arr[currentIndex];
    var x = 0, y = 0;
    for (int i = 0; i < arr.length; i++) {
      if (i == currentIndex) continue;
      var anotherFilter = arr[i];
      if (anotherFilter.forceRedraw) continue;
      if (_checkCross(currentFilter, anotherFilter)) {
        anotherFilter.forceRedraw = true;
        continue;
      }
      if (_checkCross(anotherFilter, currentFilter)) {
        anotherFilter.forceRedraw = true;
        continue;
      }
    }
  }
}
