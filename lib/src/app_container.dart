import 'dart:io';

import 'package:flutter_translate/flutter_translate.dart';

import 'app.dart';
import 'di.dart';
import 'router.dart';
import 'constants.dart';
import 'utils/layout_config.dart';
import 'widgets/theme/theme_provider.dart';

class AppContainer {
  LocalizationDelegate? _localizationDelegate;
  LocalizedApp? _app;

  late DependencyInjection _di;
  late ScreenNavigator _navigator;
  late AppRouter _router;

  static final AppContainer _singleton = AppContainer._internal();

  factory AppContainer() {
    return _singleton;
  }

  AppContainer._internal() {
    _di = DependencyInjection();
    _navigator = ScreenNavigator();
    _router = AppRouter.fromMainScreen(_navigator, _di);
  }

  Future<LocalizedApp> get app async {
    await _createLocalizedAppConfig();
    _createLocalizedApp();
    return _app!;
  }

  Future _createLocalizedAppConfig() async {
    if (_localizationDelegate != null) return;
    _localizationDelegate = await LocalizationDelegate.create(
        basePath: LOCALIZATION_RESOURCES_PATH + "/",
        fallbackLocale: DEFAULT_LOCALE,
        supportedLocales: ['en_US', 'de']);
    if(AppTheme.isDesktop) _setupDesktopConfigs();
    return;
  }

  void _createLocalizedApp() {
    if (_app != null) return;
    _app = LocalizedApp(_localizationDelegate!, PixelMonsterApp(_router));
  }

  void _setupDesktopConfigs() {
    LayoutConfig.setupDesktopScreenBoundaries();
    if(Platform.isWindows) return;
    LayoutConfig.updateMenuBar();
  }
}
