import 'package:flutter/material.dart';
import 'package:privacyblur/src/utils/image_filter/helpers/filter_result.dart';
import 'package:privacyblur/src/widgets/theme/theme_provider.dart';

class ImgPainter extends CustomPainter {
  final ImageFilterResult _image;
  static int _old_hash = 0;
  late int _hash;

  ImgPainter(this._image) {
    _hash = _image.hashCode;
  }

  @override
  bool operator ==(other) {
    return (other is ImgPainter) ? this._hash == other._hash : false;
  }

  @override
  int get hashCode => _hash;

  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint();
    canvas.drawImage(_image.mainImage, Offset.zero, paint);
    if (_image.changedPart != null) {
      canvas.drawImage(_image.changedPart!,
          Offset(_image.posX.toDouble(), _image.posY.toDouble()), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    int newHash = hashCode;
    if (newHash != _old_hash) {
      _old_hash = newHash;
      return true;
    }
    return false;
  }
}
