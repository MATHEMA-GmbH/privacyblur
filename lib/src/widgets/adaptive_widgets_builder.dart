import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:privacyblur/src/widgets/scaled_wrapper.dart';

import 'theme/theme_provider.dart';

final bool _isIOS = AppTheme.isIOS;

class IconButtonBuilder {
  static Widget build(
      {Color? color,
      required IconData icon,
      String? text,
      required Function() onPressed,
      int rotateIconQuarter = 0,
      double iconSize = 30}) {
    if (_isIOS) {
      return CupertinoButton(
          child: text != null
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    RotatedBox(
                      quarterTurns: rotateIconQuarter,
                      child: Icon(
                        icon,
                        color: color,
                        size: iconSize,
                      ),
                    ),
                    SizedBox(width: 10),
                    Text(text, style: TextStyle(color: color)),
                  ],
                )
              : _buildRotatableIcon(rotateIconQuarter, icon, color, iconSize),
          onPressed: onPressed);
    } else {
      return TextButton(
        child: text != null
            ? Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  RotatedBox(
                    quarterTurns: rotateIconQuarter,
                    child: Icon(
                      icon,
                      color: color,
                      size: iconSize,
                    ),
                  ),
                  SizedBox(width: 10),
                  Text(text, style: TextStyle(color: color)),
                ],
              )
            : _buildRotatableIcon(rotateIconQuarter, icon, color, iconSize),
        onPressed: onPressed,
      );
    }
  }

  static Widget _buildRotatableIcon(rotateIconQuarter, icon, color, iconSize) {
    return RotatedBox(
      quarterTurns: rotateIconQuarter,
      child: Icon(
        icon,
        color: color,
        size: iconSize,
      ),
    );
  }
}

class TextButtonBuilder {
  static Widget build({
    Color? color,
    required String text,
    required Function() onPressed,
    int rotateIconQuarter = 0,
    Color? backgroundColor,
    bool rounded = false,
    EdgeInsets? padding,
  }) {
    double? borderRadius = rounded ? 6 : 0;
    EdgeInsets? _padding = padding != null ? padding : EdgeInsets.all(0);
    if (_isIOS) {
      return CupertinoButton(
        padding: _padding,
        color: backgroundColor,
        onPressed: onPressed,
        child: RotatedBox(
          quarterTurns: rotateIconQuarter,
          child: Text(text, style: TextStyle(color: color)),
        ),
        borderRadius: BorderRadius.all(Radius.circular(borderRadius)),
      );
    } else {
      return MaterialButton(
        color: backgroundColor,
        child: RotatedBox(
            quarterTurns: rotateIconQuarter,
            child: Text(text, style: TextStyle(color: color))),
        onPressed: onPressed,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(borderRadius))),
        padding: _padding,
      );
    }
  }
}

class ScaffoldWithAppBar {
  static Widget build(
      {required BuildContext context,
      Widget? leading,
      required String title,
      List<Widget>? actions,
      Future<bool> Function()? onBackPressed,
      required Widget body}) {
    if (_isIOS) {
      return WillPopScope(
        onWillPop: () async {
          if (onBackPressed == null) return true;
          return await onBackPressed();
        },
        child: ScaledWrapper(
          child: CupertinoPageScaffold(
            navigationBar: _AppBarBuilder.build(
                context: context,
                leading: leading,
                title: title,
                actions: actions) as ObstructingPreferredSizeWidget,
            child: body,
          ),
        ),
      );
    } else {
      return WillPopScope(
          onWillPop: () async {
            if (onBackPressed == null) return true;
            return await onBackPressed();
          },
          child: ScaledWrapper(
            child: Scaffold(
              appBar: _AppBarBuilder.build(
                  context: context,
                  leading: leading,
                  title: title,
                  actions: actions),
              body: body,
            ),
          ));
    }
  }
}

class AppBuilder {
  static Widget build({
    required String title,
    required Route<dynamic> Function(RouteSettings) onGenerateRoute,
    required List<Route<dynamic>> Function(String) onGenerateInitialRoutes,
    required String initialRoute,
    bool? debugShowCheckedModeBanner,
    required List<Locale> supportedLocales,
    required Locale locale,
    required Iterable<LocalizationsDelegate<dynamic>> localizationsDelegates,
  }) {
    if (_isIOS) {
      return MaterialApp(
        title: title,
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        themeMode: ThemeMode.system,
        debugShowCheckedModeBanner: false,
        home: Material(
          child: CupertinoApp(
              title: title,
              theme: AppTheme.iosTheme,
              onGenerateRoute: onGenerateRoute,
              onGenerateInitialRoutes: onGenerateInitialRoutes,
              initialRoute: initialRoute,
              debugShowCheckedModeBanner: debugShowCheckedModeBanner!,
              supportedLocales: supportedLocales,
              locale: locale,
              localizationsDelegates: localizationsDelegates),
        ),
      );
    } else {
      return MaterialApp(
          title: title,
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          themeMode: ThemeMode.system,
          onGenerateRoute: onGenerateRoute,
          onGenerateInitialRoutes: onGenerateInitialRoutes,
          initialRoute: initialRoute,
          debugShowCheckedModeBanner: debugShowCheckedModeBanner!,
          supportedLocales: supportedLocales,
          locale: locale,
          localizationsDelegates: localizationsDelegates);
    }
  }
}

class _AppBarBuilder {
  static PreferredSizeWidget build(
      {required BuildContext context,
      Widget? leading,
      required String title,
      List<Widget>? actions}) {
    if (_isIOS) {
      return CupertinoNavigationBar(
          //backgroundColor: Theme.of(context).bottomAppBarColor,
          leading: leading,
          middle: Text(title),
          automaticallyImplyLeading: true,
          automaticallyImplyMiddle: true,
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: actions!,
          ));
    } else {
      return AppBar(
        leading: leading,
        title: Text(title,
            style: TextStyle(color: AppTheme.appBarToolColor(context))),
        actions: actions,
        automaticallyImplyLeading: true,
        leadingWidth: 80,
        brightness: Brightness.dark,
        centerTitle: true,
      );
    }
  }
}

class AppConfirmationBuilder {
  static Future<bool> build<bool>(
    BuildContext context, {
    required String message,
    required String acceptTitle,
    required String rejectTitle,
  }) async {
    if (_isIOS) {
      return (await showCupertinoDialog<bool>(
              context: context,
              barrierDismissible: true,
              builder: (BuildContext context) {
                return CupertinoAlertDialog(
                  content: Text(message),
                  actions: [
                    _buildAdaptiveAlertButton(
                        rejectTitle, () => Navigator.of(context).pop(false)),
                    _buildAdaptiveAlertButton(
                        acceptTitle, () => Navigator.of(context).pop(true)),
                  ],
                );
              })) ??
          Future.value(false) as FutureOr<bool>;
    } else {
      return (await showDialog<bool>(
              context: context,
              barrierDismissible: true,
              builder: (BuildContext context) {
                return AlertDialog(
                  content: Text(message),
                  actions: [
                    _buildAdaptiveAlertButton(
                        rejectTitle, () => Navigator.of(context).pop(false)),
                    _buildAdaptiveAlertButton(
                        acceptTitle, () => Navigator.of(context).pop(true)),
                  ],
                );
              })) ??
          Future.value(false) as FutureOr<bool>;
    }
  }

  static Widget _buildAdaptiveAlertButton(
      String text, void Function()? onPressed) {
    if (_isIOS) {
      return CupertinoDialogAction(
        onPressed: onPressed,
        child: Text(text),
      );
    } else {
      return MaterialButton(onPressed: onPressed, child: Text(text));
    }
  }
}
