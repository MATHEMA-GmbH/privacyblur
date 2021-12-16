import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:privacyblur/resources/localization/keys.dart';
import 'package:privacyblur/src/di.dart';
import 'package:privacyblur/src/router.dart';
import 'package:privacyblur/src/screens/image/utils/internal_layout.dart';
import 'package:privacyblur/src/screens/image/widgets/painter_image.dart';
import 'package:privacyblur/src/utils/image_filter/helpers/filter_result.dart';
import 'package:privacyblur/src/widgets/adaptive_widgets_builder.dart';
import 'package:privacyblur/src/screens/image/widgets/interactive_viewer_scrollbar.dart';

// ignore: must_be_immutable
class ImagePreviewScreen extends StatelessWidget {
  final double maxScale = 10;
  final DependencyInjection di;
  final AppRouter router;
  final ImageFilterResult image;
  final TransformationController transformationController;
  late InternalLayout internalLayout;

  ImagePreviewScreen(
      this.di, this.router, this.transformationController, this.image,
      {Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    internalLayout = InternalLayout(context);
    return ScaffoldWithAppBar.build(
      context: context,
      actions: [],
      title: translate(Keys.App_Name),
      body: SafeArea(
        child: _buildPreview(context),
      ),
    );
  }

  Widget _buildPreview(BuildContext context) {
    return LayoutBuilder(builder: (_, constraints) {
      var wScale = constraints.maxWidth / image.mainImage.width;
      var hScale = constraints.maxHeight / image.mainImage.height;
      var minScale = min(wScale, hScale); //to fit image
      var initialScale = max(wScale, hScale);
      var imageMinWidth = image.mainImage.width * minScale;
      var imageMinHeight = image.mainImage.height * minScale;
      var horizontalBorder =
          ((constraints.maxWidth - imageMinWidth).abs() / (minScale));
      var verticalBorder =
          ((constraints.maxHeight - imageMinHeight).abs() / (minScale));
      EdgeInsets boundaryMargin =
          EdgeInsets.fromLTRB(0, 0, horizontalBorder, verticalBorder);

      return Stack(children: [
        InteractiveViewer(
            maxScale: maxScale,
            scaleEnabled: true,
            panEnabled: true,
            constrained: false,
            boundaryMargin: boundaryMargin,
            minScale: minScale,
            transformationController: transformationController,
            child: SizedBox(
                width: image.mainImage.width.toDouble(),
                height: image.mainImage.height.toDouble(),
                child: CustomPaint(
                  size: Size(image.mainImage.height.toDouble(),
                      image.mainImage.width.toDouble()),
                  isComplex: true,
                  willChange: true,
                  painter: ImgPainter(image),
                ))),
        InteractiveViewerScrollBars(
            controller: transformationController,
            minScale: minScale,
            maxScale: maxScale,
            initialScale: initialScale,
            imageSize: Size(image.mainImage.width + horizontalBorder,
                image.mainImage.height + verticalBorder),
            viewPortSize: Size(constraints.maxWidth, constraints.maxHeight))
      ]);
    });
  }
}
