import 'package:flutter/material.dart';
import 'package:privacyblur/src/utils/image_filter/helpers/filter_result.dart';

class ImgPainter extends CustomPainter {
  final ImageFilterResult _image;
  late int _hash;

  ImgPainter(this._image) {
    _hash = _image.hashCode;
  }

  @override
  bool operator ==(other) {
    return (other is ImgPainter) ? _hash == other._hash : false;
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
  bool shouldRepaint(covariant ImgPainter oldDelegate) {
    if (_hash != oldDelegate._hash) {
      return true;
    }
    return false;
  }
}
