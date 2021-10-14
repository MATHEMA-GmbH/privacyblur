import 'constants.dart';

class FilterPosition {
  /// static filter storage. to keep last created value in memory
  static double _sGranularityRatio = ImgConst.startGranularityRatio;
  static double _sRadiusRatio = ImgConst.startRadiusRatio;
  static bool _sIsRounded = true;
  static bool _sIsPixelate = true;

  final int maxRadius;

  FilterPosition(this.maxRadius);

  double _granularity = _sGranularityRatio;
  double _radius = _sRadiusRatio;
  bool _rounded = _sIsRounded;
  bool _pixelate = _sIsPixelate;

  int posX = ImgConst.undefinedPosValue;
  int posY = ImgConst.undefinedPosValue;

  set granularityRatio(double value) {
    _granularity = value;
    _sGranularityRatio = value;
  }

  double get granularityRatio => _granularity;

  set radiusRatio(double value) {
    _radius = value;
    _sRadiusRatio = value;
  }

  double get radiusRatio => _radius;

  set isRounded(bool value) {
    _rounded = value;
    _sIsRounded = value;
  }

  bool get isRounded => _rounded;

  set isPixelate(bool value) {
    _pixelate = value;
    _sIsPixelate = value;
  }

  bool get isPixelate => _pixelate;

  bool canceled = true;
  bool forceRedraw = true;

  int getVisibleRadius() => (maxRadius * radiusRatio).toInt();

  bool isInnerPoint(int x, int y) {
    var radius = (maxRadius * radiusRatio).toInt();
    return (x <= posX + radius &&
        x >= posX - radius &&
        y <= posY + radius &&
        y >= posY - radius);
  }
}
