import 'dart:io';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:privacyblur/resources/localization/keys.dart';
import 'package:privacyblur/src/data/services/local_storage.dart';
import 'package:privacyblur/src/di.dart';
import 'package:privacyblur/src/router.dart';
import 'package:privacyblur/src/utils/layout_config.dart';
import 'package:privacyblur/src/widgets/adaptive_widgets_builder.dart';
import 'package:privacyblur/src/widgets/message_bar.dart';
import 'package:privacyblur/src/widgets/section.dart';
import 'package:privacyblur/src/widgets/theme/theme_provider.dart';
import 'package:url_launcher/url_launcher.dart';

class MainScreen extends StatefulWidget with AppMessages {
  final DependencyInjection di;
  final AppRouter router;
  final localStorage = LocalStorage();

  MainScreen(this.di, this.router);

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> with WidgetsBindingObserver {
  final _picker = ImagePicker();
  late LayoutConfig _layoutConfig;
  late Color primaryColor;
  final String websiteURL = 'https://mathema-apps.de/';
  bool havePermission = true;
  bool userAlreadyClickButton = false;

  void initState() {
    super.initState();
    WidgetsBinding.instance?.addObserver(this);
    _showLastImageDialog(context);
  }

  @override
  void dispose() {
    WidgetsBinding.instance?.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _updatePermissionState();
    }
  }

  @override
  Widget build(BuildContext context) {
    primaryColor = AppTheme.primaryColor;
    _layoutConfig = LayoutConfig(context);
    return ScaffoldWithAppBar.build(
        context: context,
        title: translate(Keys.App_Name),
        body: buildPageBody(context),
        actions: []);
  }

  Widget buildPageBody(BuildContext context) {
    Color textColor = AppTheme.fontColor(context);

    return SafeArea(
      child: Container(
        constraints: BoxConstraints.expand(),
        child: LayoutBuilder(builder: (context, BoxConstraints constraints) {
          double screenInnerHeight = constraints.minHeight;
          return Column(
            children: [
              Section(
                  child:
                      Image.asset('lib/resources/images/launch_image.png', height: min(screenInnerHeight * 0.3, 360)),
                  sectionHeight: screenInnerHeight * 0.4),
              Section(
                  child: Text(
                    translate(Keys.Main_Screen_Content),
                    style: TextStyle(
                        fontSize:
                            Theme.of(context).textTheme.headline6!.fontSize,
                        fontWeight: FontWeight.bold,
                        color: textColor),
                    textAlign: TextAlign.center,
                  ),
                  sectionHeight: screenInnerHeight * 0.2),
              Section(
                  child: Column(
                    children: [
                      TextButtonBuilder.build(
                          text: translate(Keys.Main_Screen_Select_Image),
                          onPressed: () =>
                              openImageAction(context, ImageSource.gallery),
                          backgroundColor: AppTheme.buttonColor,
                          rounded: true,
                          padding: EdgeInsets.symmetric(
                              vertical: 10, horizontal: 20),
                          color: Colors.white),
                      if (!havePermission) _showPermissionWarning(),
                    ],
                  ),
                  sectionHeight: screenInnerHeight * 0.3),
              Section(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Made with ', style: TextStyle(color: textColor)),
                    Icon(CupertinoIcons.heart_fill, color: primaryColor),
                    Text(' by ', style: TextStyle(color: textColor)),
                    GestureDetector(
                      child: Text('MATHEMA',
                          style: TextStyle(color: primaryColor)),
                      onTap: () => launchLink(websiteURL),
                    ),
                  ],
                ),
                sectionHeight: screenInnerHeight * 0.1,
              ),
            ],
          );
        }),
      ),
    );
  }

  Widget _showPermissionWarning() {
    return Column(
      children: [
        SizedBox(
          height: 10,
        ),
        SizedBox(
          width: 300,
          child: Text(
            translate(Keys.Main_Screen_Photo_Permissions),
            textAlign: TextAlign.center,
            style: TextStyle(fontStyle: FontStyle.italic),
          ),
        ),
      ],
    );
  }

  Future<bool> _requestPermission(Permission permission) async {
    if (await permission.isGranted || await permission.isLimited) {
      return true;
    } else {
      return ((await permission.request()) == PermissionStatus.granted ||
          (await permission.request()) == PermissionStatus.limited);
    }
  }

  void _updatePermissionState() async {
    if (!userAlreadyClickButton) return;
    bool resultPermission = false;
    if (Platform.isIOS) {
      resultPermission = (await Permission.photos.isGranted ||
          await Permission.photos.isLimited);
    } else {
      resultPermission = (await Permission.storage.isGranted);
    }
    if (havePermission != resultPermission) {
      setState(() {
        havePermission = resultPermission;
      });
    }
  }

  void _showLastImageDialog(BuildContext context) async {
    var path = await widget.localStorage.getLastPath();
    if (path.length > 0) {
      var canDownscale = await AppConfirmationBuilder.build(context,
          message: translate(Keys.Messages_Errors_Image_Crash),
          acceptTitle: translate(Keys.Buttons_Ok),
          rejectTitle: translate(Keys.Buttons_Cancel));
      if (canDownscale) {
        widget.router.openImageRoute(context, path);
      } else {
        widget.localStorage.removeLastPath();
      }
    }
  }

  void openImageAction(BuildContext context, ImageSource type) async {
    PickedFile? pickedFile;
    bool status = Platform.isIOS
        ? await _requestPermission(Permission.photos)
        : await _requestPermission(Permission.storage);
    if (status) {
      try {
        pickedFile = await _picker.getImage(source: type);
      } catch (e) {
        widget.showMessage(
            context: context,
            message: translate(Keys.Messages_Errors_Image_Library),
            type: MessageBarType.Failure);
        return;
      }
      if (pickedFile != null && await File(pickedFile.path).exists()) {
        widget.router.openImageRoute(context, pickedFile.path);
      } else {
        widget.showMessage(
            context: context,
            message: translate(Keys.Messages_Errors_No_Image));
      }
    } else {
      var goSettings = await AppConfirmationBuilder.build(context,
          message: translate(Keys.Messages_Errors_Photo_Permissions),
          acceptTitle: translate(Keys.Buttons_Settings),
          rejectTitle: translate(Keys.Buttons_Cancel));
      userAlreadyClickButton = true;
      if (goSettings) {
        await openAppSettings();
      } else {
        _updatePermissionState();
      }
    }
  }

  void launchLink(String url) async {
    try {
      launch(Uri.encodeFull(url));
    } catch (e) {}
  }
}
