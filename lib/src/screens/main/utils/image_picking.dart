import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:privacyblur/src/widgets/theme/theme_provider.dart';

class ImagePicking extends ImagePicker {
  bool permissionsGranted = true;
  bool settingsHasBeenVisited = false;

  Future<bool> requestLibraryPermissionStatus() async {
    return AppTheme.isDesktop
        ? true
        : (Platform.isIOS
        ? await _requestPermission(Permission.photos)
        : await _requestPermission(Permission.storage));
  }

  Future<bool> _requestPermission(Permission permission) async {
    if (await permission.isGranted || await permission.isLimited) {
      return true;
    } else {
      return ((await permission.request()) == PermissionStatus.granted ||
          (await permission.request()) == PermissionStatus.limited);
    }
  }

  Future<File?> pickFile(ImageSource type) async {
    File? resultFile;
    if (AppTheme.isDesktop) {
      FilePickerResult? pickResult = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['jpg', 'png', 'jpeg', 'webp', 'gif'],
      );
      if (pickResult != null) resultFile = File(pickResult.files.single.path!);
    } else {
      PickedFile? pickResult;
      pickResult = await getImage(source: type);
      if (pickResult != null) resultFile = File(pickResult.path);
    }
    return resultFile;
  }

  void updatePermissionState() async {
    if (!settingsHasBeenVisited) return;
    bool resultPermission = false;
    if (Platform.isIOS) {
      resultPermission = (await Permission.photos.isGranted ||
          await Permission.photos.isLimited);
    } else {
      resultPermission = (await Permission.storage.isGranted);
    }
    if (permissionsGranted != resultPermission) {
      permissionsGranted = resultPermission;
    }
  }
}