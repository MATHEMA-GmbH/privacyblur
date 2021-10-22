import 'dart:math';

import 'package:flutter/material.dart';

class InteractiveViewerScrollBars extends StatefulWidget {
  final TransformationController controller;
  final double minScale;
  final double maxScale;
  final double initialScale;
  final Size imageSize;
  final Size viewPortSize;

  const InteractiveViewerScrollBars(
      {Key? key,
      required this.controller,
      required this.minScale,
      required this.maxScale,
      required this.initialScale,
      required this.imageSize,
      required this.viewPortSize})
      : super(key: key);

  @override
  _InteractiveViewerScrollBarsState createState() =>
      _InteractiveViewerScrollBarsState();
}

class _InteractiveViewerScrollBarsState
    extends State<InteractiveViewerScrollBars> {
  late Size _scrollBarSize;
  late Offset _scrollBarOffset;
  late final void Function() _listener =
      () => _calculateTransformationUpdates();

  @override
  void initState() {
    widget.controller.addListener(_listener);
    _calculateTransformationUpdates();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      _buildScrollBar(true, _scrollBarSize.width, _scrollBarOffset.dx),
      _buildScrollBar(false, _scrollBarSize.height, _scrollBarOffset.dy)
    ]);
  }

  Widget _buildScrollBar(bool isHorizontal,
      [double size = 0, double offset = 0]) {
    bool shouldBuild =
        (isHorizontal && size <= 0.95 * widget.viewPortSize.width) ||
            (!isHorizontal && size <= 0.95 * widget.viewPortSize.height);
    return shouldBuild
        ? Positioned(
            top: isHorizontal ? null : offset,
            right: isHorizontal ? null : 0,
            bottom: isHorizontal ? 0 : null,
            left: isHorizontal ? offset : null,
            child: Container(
              height: isHorizontal ? 5 : size,
              width: isHorizontal ? size : 5,
              decoration: const BoxDecoration(
                  color: Colors.blueGrey,
                  borderRadius: BorderRadius.all(Radius.circular(10))),
            ),
          )
        : const SizedBox();
  }

  Size _calculateScrollBarSize(double transformationScale, Size viewPortSize) {
    /// If fully zoomed out then must equal full screen size
    double horizontalScrollbarSize = min(
        max(viewPortSize.width * transformationScale, 25),
        widget.viewPortSize.width - 10);
    double verticalScrollbarSize = min(
        max(viewPortSize.height * transformationScale, 25),
        widget.viewPortSize.height - 10);
    return Size(horizontalScrollbarSize, verticalScrollbarSize);
  }

  Offset _calulateScrollBarOffSet(double currentScale, Size scrollBarSize) {
    double offsetX = widget.controller.value.row0[3];
    double offsetY = widget.controller.value.row1[3];
    double scrollBarOffsetX = ((offsetX / currentScale) /
                (widget.imageSize.width -
                    widget.viewPortSize.width / currentScale))
            .abs() *
        (widget.viewPortSize.width - scrollBarSize.width);
    double scrollBarOffsetY = ((offsetY / currentScale) /
                (widget.imageSize.height -
                    widget.viewPortSize.height / currentScale))
            .abs() *
        (widget.viewPortSize.height - scrollBarSize.height);
    return Offset(scrollBarOffsetX, scrollBarOffsetY);
  }

  void _calculateTransformationUpdates() {
    double currentScale = widget.controller.value.row0[0];
    double transformationScale = 1 -
        (((currentScale - widget.minScale) * 0.9) /
            (widget.maxScale * widget.initialScale - widget.minScale));
    Size scrollBarSize =
        _calculateScrollBarSize(transformationScale, widget.viewPortSize);
    Offset scrollBarOffset =
        _calulateScrollBarOffSet(currentScale, scrollBarSize);
    setState(() {
      _scrollBarSize = scrollBarSize;
      _scrollBarOffset = scrollBarOffset;
    });
  }

  @override
  void dispose() {
    widget.controller.removeListener(_listener);
    super.dispose();
  }
}
