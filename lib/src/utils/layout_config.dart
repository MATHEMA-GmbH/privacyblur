import 'dart:math';

import 'package:desktop_window/desktop_window.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:menubar/menubar.dart';
import 'package:privacyblur/resources/localization/keys.dart';

import 'desktop_config.dart';

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

  static DesktopWindowConfig get desktop => DesktopWindowConfig();

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
}
