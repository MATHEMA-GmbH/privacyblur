import 'package:privacyblur/src/screens/image/helpers/image_classes_helper.dart';

class FilterUtils {
  void _speedUpAreasDraw(List<FilterPosition> arr) {
    arr.sort((FilterPosition a, FilterPosition b) {
      if (a.isPixelate == b.isPixelate) {
        return ((a.radiusRatio - b.radiusRatio) * 1000).toInt();
      } else {
        if (a.isPixelate) return -1;
        return 1;
      }
    });
  }

  bool checkCross(FilterPosition oneFilter,FilterPosition anotherFilter){
    var anotherRadius=anotherFilter.getVisibleRadius();

    if(oneFilter.isInnerPoint(anotherFilter.posX-anotherRadius, anotherFilter.posY-anotherRadius)){
      return true;
    }
    if(oneFilter.isInnerPoint(anotherFilter.posX+anotherRadius, anotherFilter.posY+anotherRadius)){
      return true;
    }
    if(oneFilter.isInnerPoint(anotherFilter.posX-anotherRadius, anotherFilter.posY+anotherRadius)){
      return true;
    }
    if(oneFilter.isInnerPoint(anotherFilter.posX+anotherRadius, anotherFilter.posY-anotherRadius)){
      return true;
    }
    return false;
  }

  void _markRedraw(List<FilterPosition> arr, int currentIndex) {
    if(currentIndex>=arr.length||currentIndex<0) return;
    var currentFilter = arr[currentIndex];
    var x=0,y=0;
    for (int i = 0; i < arr.length; i++) {
      if (i == currentIndex) continue;
      var anotherFilter=arr[i];
      if(checkCross(currentFilter,anotherFilter)){
        currentFilter.forceRedraw=true;
        continue;
      }
      if(checkCross(anotherFilter,currentFilter)){
        currentFilter.forceRedraw=true;
        continue;
      }
    }
  }
}
