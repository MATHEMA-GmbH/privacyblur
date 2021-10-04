import 'dart:math';

import 'package:desktop_window/desktop_window.dart';
import 'package:flutter/widgets.dart';

enum DESKTOP_LAYOUT_TYPES { SMALL, LARGE, REGULAR }

Map<DESKTOP_LAYOUT_TYPES, Size> desktopSizes = {
  DESKTOP_LAYOUT_TYPES.SMALL: Size(375, 667),
  DESKTOP_LAYOUT_TYPES.LARGE: Size(1920, 1080),
  DESKTOP_LAYOUT_TYPES.REGULAR: Size(1366, 768)
};

class LayoutConfig {
  final double minScale = 0.8;
  final double maxScale = 1.2;

  final int baseWidth = 375;
  final int baseHeight = 667;

  late double viewScaleRatio;

  late MediaQueryData _mediaQueryData;
  late double screenWidth;
  late double screenHeight;
  double? blockSizeHorizontal;
  double? blockSizeVertical;

  late double _safeAreaHorizontal;
  late double _safeAreaVertical;
  double? safeBlockHorizontal;
  double? safeBlockVertical;
  late bool landscapeMode;
  late bool isTablet;
  late bool isNeedSafeArea;

  LayoutConfig(BuildContext context) {
    _mediaQueryData = MediaQuery.of(context);

    screenWidth = _mediaQueryData.size.width;
    screenHeight = _mediaQueryData.size.height;
    landscapeMode = screenWidth > screenHeight;
    isTablet = min(screenWidth, screenHeight) >= 600;
    isNeedSafeArea = _mediaQueryData.viewPadding.bottom > 0;

    blockSizeHorizontal = screenWidth / 100;
    blockSizeVertical = screenHeight / 100;

    _safeAreaHorizontal =
        _mediaQueryData.padding.left + _mediaQueryData.padding.right;
    _safeAreaVertical =
        _mediaQueryData.padding.top + _mediaQueryData.padding.bottom;
    safeBlockHorizontal = (screenWidth - _safeAreaHorizontal) / 100;
    safeBlockVertical = (screenHeight - _safeAreaVertical) / 100;

    var scaleWidth = screenWidth / baseWidth;
    var scaleHeight = screenHeight / baseHeight;

    viewScaleRatio = min(scaleWidth, scaleHeight);
    if (viewScaleRatio < minScale) {
      viewScaleRatio = minScale;
    }
    if (viewScaleRatio > maxScale) {
      viewScaleRatio = maxScale;
    }
  }

  double getScaledSize(double size) {
    return size * viewScaleRatio;
  }

  static setupDesktopScreenBoundaries() async{
    return await Future.wait([
      DesktopWindow.setMinWindowSize(desktopSizes[DESKTOP_LAYOUT_TYPES.SMALL]!),
      DesktopWindow.setMaxWindowSize(desktopSizes[DESKTOP_LAYOUT_TYPES.LARGE]!),
    ]);
  }

  /// for Screenshot purposes
  static Future setWindowSize(
      {DESKTOP_LAYOUT_TYPES size = DESKTOP_LAYOUT_TYPES.REGULAR, Size? customSize}) async {
    Size sizeToSet = desktopSizes[size]!;
    if(customSize != null) sizeToSet = customSize;
    return DesktopWindow.setWindowSize(sizeToSet);
  }

  // TODO: later implementation of desktop navigation tabs
  static Future toggleFullScreen() async {
    return await DesktopWindow.toggleFullScreen();
  }
}
