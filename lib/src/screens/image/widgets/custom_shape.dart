import 'package:flutter/material.dart';
import 'package:privacyblur/src/screens/image/helpers/constants.dart';
import 'package:privacyblur/src/screens/image/helpers/image_classes_helper.dart';
import 'package:privacyblur/src/widgets/theme/theme_provider.dart';

class ShapePainter extends CustomPainter {
  static int _old_hash = 0;
  int _hash = 0;
  final int maxRadius;
  final int selectedPosition;
  final List<FilterPosition> positions;
  final bool isImageSelected;

  ShapePainter(this.positions, this.maxRadius, this.selectedPosition, this.isImageSelected) {
    // with prime numbers to reduce collisions... may be. Not very important
    // from https://primes.utm.edu/lists/small/10000.txt
    positions.forEach((p) {
      _hash += (p.isRounded ? 7879 : 9341) +
          selectedPosition * 8467 +
          (p.radiusRatio * maxRadius * 14557).toInt() +
          p.posX +
          p.posY * 12347;
    });
    _hash += isImageSelected ? 7919 : 8887;
  }

  @override
  bool operator ==(other) {
    return (other is ShapePainter) ? this._hash == other._hash : false;
  }

  @override
  int get hashCode => _hash;

  void _drawImageSelection(Canvas canvas, Size size) {
    var paint1 = Paint()
    ..color = AppTheme.primaryColor
    ..strokeWidth = 4
    ..style = PaintingStyle.stroke;
    if(isImageSelected) canvas.drawRect(Offset(0, 0) & Size(size.width -2, size.height -2), paint1);
  }

  void _drawCircle(Canvas canvas, int x, int y, double r, Color color) {
    var paint = Paint();
    paint.color = color;
    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = 2;
    canvas.drawCircle(Offset(x.toDouble(), y.toDouble()), r.toDouble(), paint);
  }

  void _drawRect(Canvas canvas, int x, int y, double r, Color color) {
    var paint = Paint();
    paint.color = color;
    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = 2;
    canvas.drawRect(
        Rect.fromCircle(
            center: Offset(x.toDouble(), y.toDouble()), radius: r.toDouble()),
        paint);
  }

  @override
  void paint(Canvas canvas, Size size) {
    positions.asMap().forEach((index, position) {
      if (position.posX <= ImgConst.undefinedPosValue ||
          position.posY <= ImgConst.undefinedPosValue) {
        return;
      }
      var radius = position.radiusRatio * maxRadius;
      var colorBorder = index == selectedPosition ? AppTheme.primaryColor : Colors.black;
      var colorBorderInner =
          index == selectedPosition ? AppTheme.primaryColor : Colors.grey;
      if (position.isRounded) {
        _drawCircle(canvas, position.posX, position.posY, radius, colorBorder);
        _drawCircle(
            canvas, position.posX, position.posY, radius - 2, colorBorderInner);
      } else {
        _drawRect(canvas, position.posX, position.posY, radius, colorBorder);
        _drawRect(
            canvas, position.posX, position.posY, radius - 2, colorBorderInner);
      }
    });
    if(isImageSelected) _drawImageSelection(canvas, size);
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
