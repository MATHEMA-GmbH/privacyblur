import 'package:flutter/material.dart';
import 'package:privacyblur/src/di.dart';
import 'package:privacyblur/src/screens/image/image_view.dart';
import 'package:privacyblur/src/screens/image_preview/image_preview_view.dart';
import 'package:privacyblur/src/screens/main/main_view.dart';
import 'package:privacyblur/src/utils/image_filter/helpers/filter_result.dart';

class NoTransitionRoute extends MaterialPageRoute {
  NoTransitionRoute({builder}) : super(builder: builder);

  @override
  Duration get transitionDuration => const Duration(milliseconds: 0);
}

class ScreenNavigator {
  Future<Object?> pushReplacementNamed(BuildContext context, String route,
      {Map<String, dynamic>? arguments}) {
    return Navigator.pushReplacementNamed<Object?, void>(context, route,
        arguments: arguments);
  }

  Future<T?> pushNamed<T extends Object>(BuildContext context, String route,
      {Map<String, dynamic>? arguments}) {
    return Navigator.pushNamed<T?>(context, route, arguments: arguments);
  }

  // TODO: implement this method for opening image on image screen
  Future<T?> pushNamedAndRemoveUntil<T extends Object>(
      BuildContext context, String route, String predicateRoute,
      {Map<String, dynamic>? arguments}) {
    return Navigator.pushNamedAndRemoveUntil<T?>(
        context, route, ModalRoute.withName(predicateRoute),
        arguments: arguments);
  }

  void pop(BuildContext context, [Object? result]) {
    Navigator.pop(context, result);
  }
}

class AppRouter {
  String _initialRoute = _mainRoute;
  final DependencyInjection _di;

  static const String _mainRoute = '/main_route';
  static const String _imageRoute = '/image_route';
  static const String _imagePreviewRoute = '/image_preview_route';

  static const String imagePathArg = 'image_path';
  static const String controllerArg = 'transformationController';
  static const String imageArg = 'image';

  final ScreenNavigator _navigator;

  AppRouter.fromMainScreen(
    this._navigator,
    this._di,
  ) {
    _initialRoute = _mainRoute;
  }

  AppRouter.fromImageScreen(
    this._navigator,
    this._di,
  ) {
    _initialRoute = _imageRoute;
  }

  AppRouter.fromImagePreviewScreen(
    this._navigator,
    this._di,
  ) {
    _initialRoute = _imagePreviewRoute;
  }

  String selectInitialRoute() {
    return _initialRoute;
  }

  Route<dynamic> generateRoutes(RouteSettings settings) {
    final String? name = settings.name;
    final Map<String, dynamic>? args =
        settings.arguments as Map<String, dynamic>?;
    Route<dynamic> appRoute = _selectRoute(name, args);

    return appRoute;
  }

  List<Route<dynamic>> onGenerateInitialRoutes(String routeName) {
    return [_selectRoute(routeName, null)];
  }

  String _getPathFromArgs(dynamic args) {
    String path = '';
    if (args != null && (args is Map) && args.containsKey(imagePathArg)) {
      path = args[imagePathArg];
    }
    return path;
  }

  TransformationController _getControllerFromArgs(dynamic args) {
    TransformationController controller = TransformationController();
    if (args != null && (args is Map) && args.containsKey(controllerArg)) {
      controller = args[controllerArg];
    }
    return controller;
  }

  ImageFilterResult _getImageFromArgs(dynamic args) {
    dynamic result;
    if (args != null && (args is Map) && args.containsKey(imageArg)) {
      result = args[imageArg];
    }
    return result;
  }

  Route<dynamic> _selectRoute(String? name, dynamic args) {
    final Map appRoutes = {
      _mainRoute: MaterialPageRoute(builder: (context) {
        return MainScreen(_di, this);
      }),
      _imageRoute: MaterialPageRoute(builder: (context) {
        return ImageScreen(_di, this, _getPathFromArgs(args));
      }),
      _imagePreviewRoute: NoTransitionRoute(builder: (context) {
        return ImagePreviewScreen(
            _di, this, _getControllerFromArgs(args), _getImageFromArgs(args));
      }),
    };

    if (appRoutes[name] == null) return appRoutes[_imageRoute];
    return appRoutes[name];
  }

  void goBack(context, [Object? result]) {
    if (Navigator.canPop(context)) {
      _navigator.pop(context, result);
    } else {
      _navigator.pushReplacementNamed(context, _initialRoute);
    }
  }

  Future openImageRoute(context, String path) {
    return _navigator
        .pushNamed(context, _imageRoute, arguments: {imagePathArg: path});
  }

  void openImagePreview(
      context, TransformationController controller, ImageFilterResult image) {
    _navigator.pushNamed(context, _imagePreviewRoute,
        arguments: {controllerArg: controller, imageArg: image});
  }
}
