import 'dart:io';

import 'package:desktop_window/desktop_window.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:menubar/menubar.dart';
import 'package:privacyblur/resources/localization/keys.dart';

enum DESKTOP_LAYOUT_TYPE { small, large, regular }

class DesktopWindowConfig extends DesktopWindow {
  int? currentMenu;

  DesktopWindowConfig();

  /// ## WINDOW CONFIG ##

  static final Map<DESKTOP_LAYOUT_TYPE, Size> _desktopSizes = {
    DESKTOP_LAYOUT_TYPE.small: const Size(375, 667),
    DESKTOP_LAYOUT_TYPE.large: const Size(1920, 1080),
    DESKTOP_LAYOUT_TYPE.regular: const Size(1366, 768)
  };

  setupDesktopScreenBoundaries() async {
    return await Future.wait([
      DesktopWindow.setMinWindowSize(_desktopSizes[DESKTOP_LAYOUT_TYPE.small]!),
      DesktopWindow.setMaxWindowSize(_desktopSizes[DESKTOP_LAYOUT_TYPE.large]!),
    ]);
  }

  static Future setWindowSize(
      {DESKTOP_LAYOUT_TYPE size = DESKTOP_LAYOUT_TYPE.regular,
      Size? customSize}) async {
    Size sizeToSet = _desktopSizes[size]!;
    if (customSize != null) sizeToSet = customSize;
    return DesktopWindow.setWindowSize(sizeToSet);
  }

  static Future toggleFullScreen() async {
    return DesktopWindow.toggleFullScreen();
  }

  /// ## MENU CONFIG ##

  void updateMenu({required UniqueKey key, List<NativeSubmenu>? menus}) {
    if (Platform.isWindows) return;
    currentMenu = key.hashCode;
    setApplicationMenu([_layoutMenu, if (menus != null) ...menus]);
  }

  final NativeSubmenu _layoutMenu =
      NativeSubmenu(label: translate(Keys.Layout_Configs_Layout), children: [
    NativeMenuItem(
      label: translate(Keys.Layout_Configs_Fullscreen),
      onSelected: () => toggleFullScreen(),
      shortcut: LogicalKeySet(LogicalKeyboardKey.f11),
    ),
    NativeMenuItem(
      label: translate(Keys.Layout_Configs_Large),
      onSelected: () => setWindowSize(size: DESKTOP_LAYOUT_TYPE.large),
      shortcut: LogicalKeySet(LogicalKeyboardKey.keyL),
    ),
    NativeMenuItem(
      label: translate(Keys.Layout_Configs_Small),
      onSelected: () => setWindowSize(size: DESKTOP_LAYOUT_TYPE.small),
      shortcut: LogicalKeySet(LogicalKeyboardKey.keyS),
    ),
    const NativeMenuDivider(),
    NativeMenuItem(
      label: translate(Keys.Layout_Configs_Regular),
      onSelected: () => setWindowSize(size: DESKTOP_LAYOUT_TYPE.regular),
      shortcut: LogicalKeySet(LogicalKeyboardKey.keyZ),
    )
  ]);
}
