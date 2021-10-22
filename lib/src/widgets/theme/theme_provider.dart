import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AppTheme {
  static final bool isIOS = Platform.isIOS; // || true;
  static final bool isCupertino = Platform.isMacOS || isIOS;
  static final bool isDesktop =
      Platform.isMacOS || Platform.isLinux || Platform.isWindows;

  static Color get primaryColor {
    if (isCupertino) return iosTheme.primaryColor;
    return light.primaryColor;
  }

  static Color get buttonColor {
    if (isCupertino) return iosTheme.primaryColor;
    return light.primaryColor;
  }

  static Color scaffoldColor(context) {
    if (isCupertino) {
      if (Theme.of(context).brightness == Brightness.dark) {
        return CupertinoColors.darkBackgroundGray;
      } else {
        return CupertinoColors.systemBackground;
      }
    }
    return Theme.of(context).scaffoldBackgroundColor;
  }

  static Color appBarToolColor(context) {
    if (isCupertino) {
      return fontColor(context);
    }
    return Colors.white;
  }

  static Color fontColor(BuildContext context) {
    return (isCupertino
        ? CupertinoTheme.of(context).textTheme.textStyle.color
        : Theme.of(context).textTheme.headline1!.color)!;
  }

  static Color fontColorAccent(BuildContext context) {
    return (isCupertino
        ? const CupertinoDynamicColor.withBrightness(
            color: CupertinoColors.systemGrey,
            darkColor: CupertinoColors.systemGrey3,
          )
        : Theme.of(context).textTheme.bodyText1!.color)!;
  }

  static Color barColor(BuildContext context) {
    return isCupertino
        ? CupertinoTheme.of(context).barBackgroundColor
        : Theme.of(context).scaffoldBackgroundColor;
  }

  static final CupertinoThemeData iosTheme = CupertinoThemeData(
    primaryColor: light.primaryColor,
    primaryContrastingColor: light.secondaryHeaderColor,
    barBackgroundColor: const CupertinoDynamicColor.withBrightness(
      color: CupertinoColors.systemBackground,
      darkColor: CupertinoColors.black,
    ),
    scaffoldBackgroundColor: const CupertinoDynamicColor.withBrightness(
      color: CupertinoColors.systemBackground,
      darkColor: CupertinoColors.black,
    ),
    textTheme: const CupertinoTextThemeData(
        textStyle: TextStyle(
      color: CupertinoDynamicColor.withBrightness(
        color: CupertinoColors.black,
        darkColor: CupertinoColors.white,
      ),
    )),
  );

  static final ThemeData light = ThemeData(
      brightness: Brightness.light,
      primaryColor: const Color(0xFFC5003E),
      primaryColorDark: const Color(0xFF8D0019),
      primaryColorLight: const Color(0xFFFE4F68),
      secondaryHeaderColor: const Color(0xFFFFFFFF),
      dividerColor: const Color(0xFFBDBDBD),
      primaryTextTheme: const TextTheme(),
      sliderTheme: SliderThemeData.fromPrimaryColors(
        primaryColor: const Color(0xFFC5003E),
        primaryColorDark: const Color(0xFF8D0019),
        primaryColorLight: const Color(0xFFFE4F68),
        valueIndicatorTextStyle: const TextStyle(color: Colors.black),
      ),
      buttonTheme: const ButtonThemeData(
        buttonColor: Color(0xFFC5003E),
        disabledColor: Color(0xFFCCCCCC),
        focusColor: Color(0xFFFE4F68),
        textTheme: ButtonTextTheme.accent,
      ),
      textTheme: const TextTheme(
        headline1: TextStyle(color: Colors.black),
        bodyText2:
            TextStyle(color: Colors.black, fontWeight: FontWeight.normal),
        bodyText1:
            TextStyle(color: Colors.black54, fontWeight: FontWeight.w400),
      ));

  static final ThemeData dark = ThemeData(
    brightness: Brightness.dark,
    primaryColor: const Color(0xFFC5003E),
    primaryColorDark: const Color(0xFF8D0019),
    primaryColorLight: const Color(0xFFFE4F68),
    secondaryHeaderColor: const Color(0xFFFFFFFF),
    dividerColor: const Color(0xFFBDBDBD),
    primaryTextTheme: const TextTheme(),
    sliderTheme: SliderThemeData.fromPrimaryColors(
      primaryColor: const Color(0xFFC5003E),
      primaryColorDark: const Color(0xFF8D0019),
      primaryColorLight: const Color(0xFFFE4F68),
      valueIndicatorTextStyle: const TextStyle(color: Colors.white),
    ),
    buttonTheme: const ButtonThemeData(
      buttonColor: Color(0xFFC5003E),
      disabledColor: Color(0xFFCCCCCC),
      focusColor: Color(0xFFFE4F68),
      textTheme: ButtonTextTheme.accent,
    ),
    textTheme: const TextTheme(
        headline1: TextStyle(color: Colors.white),
        bodyText1:
            TextStyle(color: Colors.white70, fontWeight: FontWeight.w400),
        bodyText2:
            TextStyle(color: Colors.white, fontWeight: FontWeight.normal),
        headline5: TextStyle()),
  );
}
