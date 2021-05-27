import 'dart:math';

import 'package:flutter/Material.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:privacyblur/resources/localization/keys.dart';
import 'package:privacyblur/src/di.dart';
import 'package:privacyblur/src/router.dart';
import 'package:privacyblur/src/screens/image/utils/internal_layout.dart';
import 'package:privacyblur/src/screens/image/widgets/custom_painter.dart';
import 'package:privacyblur/src/utils/image_filter/helpers/filter_result.dart';
import 'package:privacyblur/src/widgets/adaptive_widgets_builder.dart';

// ignore: must_be_immutable
class ImagePreviewScreen extends StatelessWidget {
  final DependencyInjection di;
  final AppRouter router;
  final Matrix4 matrix;
  final ImageFilterResult image;
  late InternalLayout internalLayout;
  TransformationController? transformationController;

  ImagePreviewScreen(this.di, this.router, this.matrix, this.image);

  @override
  Widget build(BuildContext context) {
    internalLayout = InternalLayout(context);
    transformationController = TransformationController(matrix);
    return ScaffoldWithAppBar.build(
      context: context,
      title: translate(Keys.App_Name),
      body: SafeArea(
        child: _buildPreview(context),
        top: internalLayout.landscapeMode,
        bottom: internalLayout.landscapeMode,
        left: !internalLayout.landscapeMode,
        right: !internalLayout.landscapeMode,
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
      return InteractiveViewer(
          maxScale: 10,
          scaleEnabled: true,
          panEnabled: true,
          constrained: false,
          boundaryMargin: boundaryMargin,
          minScale: minScale / initialScale,
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
              )));
    });
  }
}
