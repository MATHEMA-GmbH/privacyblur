import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:privacyblur/src/screens/image/helpers/image_states.dart';
import 'package:privacyblur/src/utils/image_filter/helpers/filter_result.dart';
import 'package:privacyblur/src/widgets/interactive_viewer_scrollbar.dart';

import 'custom_painter.dart';
import 'custom_shape.dart';

// ignore: must_be_immutable
class ImageViewer extends StatelessWidget {
  final ImageFilterResult image;
  final ImageStateScreen state;
  final double width; //available width for viewer
  final double height; //available height for viewer
  final void Function(double, double) moveFilterPosition;
  final void Function(double, double) addFilterPosition;
  final void Function(int) selectFilter;
  late TransformationController _transformationController;
  final double maxScale = 10;

  ImageViewer(
      this.image,
      this.state,
      this.width,
      this.height,
      this._transformationController,
      this.moveFilterPosition,
      this.addFilterPosition,
      this.selectFilter,
      {Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    var wScale = width / image.mainImage.width;
    var hScale = height / image.mainImage.height;
    double minScale = min(wScale, hScale); //to fit image
    ///initialScale
    ///calculated in parent view once for transformationController
    ///look _calculateInitialScaleAndOffset()
    double initialScale = max(wScale, hScale);
    var imageMinWidth = image.mainImage.width * minScale;
    var imageMinHeight = image.mainImage.height * minScale;

    ///calculate margins for no-scaled image
    double horizontalBorder = ((width - imageMinWidth).abs() / (minScale));
    double verticalBorder = ((height - imageMinHeight).abs() / (minScale));
    EdgeInsets boundaryMargin =
        EdgeInsets.fromLTRB(0, 0, horizontalBorder, verticalBorder);

    return Stack(children: [
      GestureDetector(
          onTapUp: onTapPosition,
          onLongPressMoveUpdate: onMoveFilter,
          onLongPressStart: onLongPressStart,
          child: InteractiveViewer(
              transformationController: _transformationController,
              maxScale: maxScale,
              scaleEnabled: true,
              panEnabled: true,
              constrained: false,
              boundaryMargin: boundaryMargin,
              minScale: minScale,
              child: SizedBox(
                  width: image.mainImage.width.toDouble(),
                  height: image.mainImage.height.toDouble(),
                  child: CustomPaint(
                    size: Size(image.mainImage.height.toDouble(),
                        image.mainImage.width.toDouble()),
                    isComplex: true,
                    willChange: true,
                    painter: ImgPainter(image),
                    foregroundPainter: ShapePainter(
                        state.positions, state.selectedFilterIndex),
                  )))),
      InteractiveViewerScrollBars(
          controller: _transformationController,
          minScale: minScale,
          maxScale: maxScale,
          initialScale: initialScale,
          imageSize: Size(image.mainImage.width + horizontalBorder,
              image.mainImage.height + verticalBorder),
          viewPortSize: Size(width, height))
    ]);
  }

  onTapPosition(TapUpDetails details) {
    Offset offset = _transformationController.toScene(
      details.localPosition,
    );
    var selected = _detectSelectedFilter(offset);
    if (selected >= 0) {
      selectFilter(selected);
    } else {
      addFilterPosition(offset.dx, offset.dy);
    }
  }

  onMoveFilter(LongPressMoveUpdateDetails details) {
    Offset offset = _transformationController.toScene(
      details.localPosition,
    );
    if (state.hasSelection) {
      moveFilterPosition(offset.dx, offset.dy);
    }
  }

  onLongPressStart(LongPressStartDetails details) {
    Offset offset = _transformationController.toScene(
      details.localPosition,
    );
    var selected = _detectSelectedFilter(offset);
    selectFilter(selected);
    if (selected >= 0) {
      moveFilterPosition(offset.dx, offset.dy);
    }
  }

  int _detectSelectedFilter(Offset offset) {
    int index = -1;
    double dist = 10000000;
    state.positions.asMap().forEach((key, value) {
      var tmpRadius = state.maxRadius * value.radiusRatio;
      var tmp =
          sqrt(pow(value.posX - offset.dx, 2) + pow(value.posY - offset.dy, 2));
      if ((value.isRounded && (tmp <= tmpRadius)) ||
          ((!value.isRounded) &&
              ((value.posX - offset.dx).abs() <= tmpRadius) &&
              ((value.posY - offset.dy).abs() <= tmpRadius))) {
        if (tmp < dist) {
          index = key;
          dist = tmp;
        }
      }
    });
    return index;
  }
}
