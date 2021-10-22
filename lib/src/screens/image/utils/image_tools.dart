import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'dart:ui' as img_tools;

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_exif_rotation/flutter_exif_rotation.dart';
import 'package:image/image.dart' as img_external;
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:image_size_getter/file_input.dart';
import 'package:image_size_getter/image_size_getter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:privacyblur/src/screens/image/helpers/constants.dart';
import 'package:privacyblur/src/widgets/theme/theme_provider.dart';

class ImgTools {
  int srcWidth = 0;
  int srcHeight = 0;
  bool scaled = false;
  final String saveFileName =
      'blur' + DateTime.now().millisecondsSinceEpoch.toString(); //no extention!
  int _saveCount = 0;

  Future<img_tools.Image> scaleFile(String filePath, int maxSize) async {
    File file;
    if (AppTheme.isDesktop) {
      file = File(filePath);
    } else {
      file = await _fixRotationBug(filePath);
    }

    scaled = false;
    if (maxSize <= 0) return _readFile(file);
    maxSize = (maxSize ~/ 16) * 16;
    Size size;
    size = ImageSizeGetter.getSize(FileInput(file));
    srcWidth = size.width;
    srcHeight = size.height;
    if (srcWidth < 0 || srcHeight < 0) {
      throw const FormatException('Wrong image format');
    }

    var scaleRatio = max(srcWidth, srcHeight) / maxSize;
    if (scaleRatio > 1.0) {
      scaled = true;
      var codec = await img_tools.instantiateImageCodec(file.readAsBytesSync(),
          allowUpscaling: false,
          targetWidth: srcWidth ~/ scaleRatio,
          targetHeight: srcHeight ~/ scaleRatio);
      var frame = await codec.getNextFrame();
      return Future.value(frame.image);
    } else {
      return _readFile(file);
    }
  }

  Future<bool> save2Gallery(
      int width, int height, Uint32List raw, bool needOverride) async {
    bool saved = false;
    String fileName;

    try {
      String? selectedDirectory; // desktop only
      if (AppTheme.isDesktop) {
        selectedDirectory = await FilePicker.platform.getDirectoryPath();
      }
      String? temporaryDirectoryPath = (await getTemporaryDirectory()).path;
      fileName = _createFileName(needOverride);
      Uint8List imageBytes = Uint8List.fromList(img_external
          .encodeJpg(img_external.Image.fromBytes(width, height, raw)));
      saved = await _writeFile(
          bytes: imageBytes,
          tempDir: temporaryDirectoryPath,
          newPath: selectedDirectory,
          fileName: fileName);
      _saveCount++;
    } catch (err) {
      if (kDebugMode) {
        print(err.toString());
      }
    }

    return saved;
  }

  String _createFileName(bool needOverride) {
    String fileName = saveFileName;
    if (!needOverride) {
      fileName = 'blur' +
          _saveCount.toString() +
          DateTime.now().millisecondsSinceEpoch.toString();
    }
    return fileName;
  }

  Future<bool> _writeFile(
      {required Uint8List bytes,
      required String tempDir,
      required String? newPath,
      required String fileName}) async {
    bool saved = false;

    if (AppTheme.isDesktop) {
      File image = await _imageToFile(bytes: bytes, directoryPath: tempDir);
      await image.copy('$newPath/$fileName.jpg');
      saved = true;
    } else {
      Directory directory = Directory(tempDir);
      try {
        directory.create(recursive: true);
        await ImageGallerySaver.saveImage(bytes,
            quality: ImgConst.imgQuality, name: fileName);
        saved = true;
      } catch (e) {
        if (kDebugMode) {
          print(e.toString());
        }
      }
    }

    return saved;
  }

  Future<File> _imageToFile(
      {required Uint8List bytes,
      required String directoryPath,
      String ext = "jpg"}) async {
    File file = File('$directoryPath/blur.$ext');
    await file.writeAsBytes(
        bytes.buffer.asUint8List(bytes.offsetInBytes, bytes.lengthInBytes));
    return file;
  }

  Future<img_tools.Image> _readFile(File file) async {
    var completer = Completer<img_tools.Image>();
    img_tools.decodeImageFromList(file.readAsBytesSync(), (result) {
      completer.complete(result);
    });
    var tempImage = await completer.future;
    srcWidth = tempImage.width;
    srcHeight = tempImage.height;
    scaled = false;
    return Future.value(tempImage);
  }

  Future<File> _fixRotationBug(String filename) async {
    File? file;
    bool error = false;
    try {
      file = await FlutterExifRotation.rotateImage(path: filename)
          .timeout(const Duration(seconds: 2));
    } catch (err) {
      error = true;
    }
    if (error) {
      file = await FlutterExifRotation.rotateImage(path: filename)
          .timeout(const Duration(seconds: 10));
    }
    if (file == null) {
      throw const FormatException('Image rotation fix plugin problems');
    } else {
      return Future.value(file);
    }
  }
}
