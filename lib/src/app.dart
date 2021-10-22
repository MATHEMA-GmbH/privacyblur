import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:privacyblur/resources/localization/keys.dart';
import 'package:privacyblur/src/router.dart';

import 'widgets/adaptive_widgets_builder.dart';

class PixelMonsterApp extends StatelessWidget {
  final AppRouter _router;

  const PixelMonsterApp(this._router, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var localizationDelegate = LocalizedApp.of(context).delegate;
    return LocalizationProvider(
      state: LocalizationProvider.of(context).state,
      child: AppBuilder.build(
        title: translate(Keys.App_Name),
        onGenerateRoute: _router.generateRoutes,
        onGenerateInitialRoutes: (String routeName) {
          return _router.onGenerateInitialRoutes(routeName);
        },
        initialRoute: _router.selectInitialRoute(),
        debugShowCheckedModeBanner: false,
        localizationsDelegates: [
          GlobalCupertinoLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          localizationDelegate
        ],
        supportedLocales: localizationDelegate.supportedLocales,
        locale: localizationDelegate.currentLocale,
      ),
    );
  }
}
