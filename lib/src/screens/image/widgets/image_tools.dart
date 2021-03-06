import 'package:flutter/material.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:privacyblur/resources/localization/keys.dart';
import 'package:privacyblur/src/screens/image/helpers/image_states.dart';
import 'package:privacyblur/src/screens/image/utils/internal_layout.dart';
import 'package:privacyblur/src/screens/image/widgets/segmented_control.dart';
import 'package:privacyblur/src/utils/flavors.dart';
import 'package:privacyblur/src/widgets/adaptive_widgets_builder.dart';
import 'package:privacyblur/src/widgets/theme/icons_provider.dart';
import 'package:privacyblur/src/widgets/theme/theme_provider.dart';

// ignore: must_be_immutable
class ImageToolsWidget extends StatelessWidget {
  late InternalLayout _internalLayout;
  final Function(double radius) onRadiusChanged;
  final Function(double filterPower) onPowerChanged;
  final Function(EditTool tool) onEditToolSelected;
  final Function() onPreview;
  final bool isLandscape;
  final double curRadius;
  final double curPower;
  final bool isRounded;
  final bool isPixelate;
  final EditTool activeTool;
  final Function() onBlurSelected;
  final Function() onPixelateSelected;
  final Function() onCircleSelected;
  final Function() onSquareSelected;
  final Function() onFilterDelete;
  final Function() onDetectFace;

  ImageToolsWidget(
      {Key? key,
      required this.onRadiusChanged,
      required this.onPowerChanged,
      required this.onPreview,
      required this.isLandscape,
      required this.curRadius,
      required this.curPower,
      required this.onBlurSelected,
      required this.onPixelateSelected,
      required this.onCircleSelected,
      required this.onSquareSelected,
      required this.isPixelate,
      required this.isRounded,
      required this.onEditToolSelected,
      required this.activeTool,
      required this.onFilterDelete,
      required this.onDetectFace})
      : super(key: key);

  late Map<int, Widget> shapes;
  late Map<int, Widget> types;

  @override
  Widget build(BuildContext context) {
    _internalLayout = InternalLayout(context);
    return createImageTools(context);
  }

  Widget createImageTools(context) {
    shapes = <int, Widget>{
      0: _controlTab(Keys.Buttons_Circle),
      1: _controlTab(Keys.Buttons_Square),
    };
    types = <int, Widget>{
      0: _controlTab(Keys.Buttons_Pixelate),
      1: _controlTab(Keys.Buttons_Blur),
    };

    return Container(
      alignment: Alignment.topCenter,
      padding: const EdgeInsets.fromLTRB(0, 10, 0, 0),
      child: Row(children: [
        if (isLandscape)
          Expanded(
            flex: 1,
            child: TextButtonBuilder.build(
                color: AppTheme.fontColor(context),
                text: translate(Keys.Buttons_Preview),
                onPressed: onPreview,
                rotateIconQuarter: isLandscape ? 1 : 0),
          ),
        Expanded(
          flex: 8,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _listParameters(context),
              Container(
                alignment: Alignment.center,
                padding: EdgeInsets.symmetric(
                    horizontal: _internalLayout.spacer * 2),
                child: _buildControl(context),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (!isLandscape)
                    Expanded(
                        child: TextButtonBuilder.build(
                            color: AppTheme.fontColor(context),
                            text: translate(Keys.Buttons_Preview),
                            onPressed: onPreview,
                            rotateIconQuarter: isLandscape ? 1 : 0))
                ],
              ),
              (_internalLayout.isNeedSafeArea || isLandscape)
                  ? SizedBox(height: _internalLayout.spacer)
                  : const SizedBox(height: 0),
            ],
          ),
        )
      ]),
    );
  }

  Widget _buildControl(BuildContext context) {
    switch (activeTool) {
      case EditTool.EditSize:
        return Slider.adaptive(
            activeColor: AppTheme.fontColor(context),
            value: curRadius > 1.0 ? 1.0 : curRadius,
            min: 0.0,
            max: 1.0,
            onChanged: (double radius) => onRadiusChanged(radius));
      case EditTool.EditGranularity:
        return Slider.adaptive(
            activeColor: AppTheme.fontColor(context),
            value: curPower,
            min: 0.0,
            max: 1.0,
            onChanged: (double filterPower) => onPowerChanged(filterPower));
      case EditTool.EditShape:
        return SegmentedControl(
            tabs: shapes,
            groupValue: isRounded ? 0 : 1,
            onChanged: (i) => i == 0 ? onCircleSelected() : onSquareSelected());
      case EditTool.EditType:
      default:
        return SegmentedControl(
            tabs: types,
            groupValue: isPixelate ? 0 : 1,
            onChanged: (i) => i == 0 ? onPixelateSelected() : onBlurSelected());
    }
  }

  Widget _listParameters(context) {
    return SizedBox(
      height: _internalLayout.iconSize * 2,
      child: Scrollbar(
        isAlwaysShown: false,
        child: ListView(
          shrinkWrap: true,
          scrollDirection: Axis.horizontal,
          children: <Widget>[
            IconButtonBuilder.build(
              rotateIconQuarter: isLandscape ? 1 : 0,
              icon: AppIcons.resize,
              color: activeTool == EditTool.EditSize
                  ? AppTheme.primaryColor
                  : AppTheme.fontColor(context),
              onPressed: () => onEditToolSelected(EditTool.EditSize),
              iconSize: _internalLayout.iconSize,
            ),
            IconButtonBuilder.build(
              icon: AppIcons.granularity,
              color: activeTool == EditTool.EditGranularity
                  ? AppTheme.primaryColor
                  : AppTheme.fontColor(context),
              onPressed: () => onEditToolSelected(EditTool.EditGranularity),
              iconSize: _internalLayout.iconSize,
            ),
            IconButtonBuilder.build(
              rotateIconQuarter: isLandscape ? 1 : 0,
              icon: AppIcons.type,
              color: activeTool == EditTool.EditType
                  ? AppTheme.primaryColor
                  : AppTheme.fontColor(context),
              onPressed: () => onEditToolSelected(EditTool.EditType),
              iconSize: _internalLayout.iconSize,
            ),
            IconButtonBuilder.build(
              rotateIconQuarter: isLandscape ? 1 : 0,
              icon: AppIcons.shape,
              color: activeTool == EditTool.EditShape
                  ? AppTheme.primaryColor
                  : AppTheme.fontColor(context),
              onPressed: () => onEditToolSelected(EditTool.EditShape),
              iconSize: _internalLayout.iconSize,
            ),
            if (!BuildFlavor.isFoss && !AppTheme.isDesktop)
              IconButtonBuilder.build(
                rotateIconQuarter: isLandscape ? 1 : 0,
                icon: AppIcons.face,
                color: AppTheme.fontColor(context),
                onPressed: onDetectFace,
                iconSize: _internalLayout.iconSize,
              ),
            IconButtonBuilder.build(
              rotateIconQuarter: isLandscape ? 1 : 0,
              icon: AppIcons.delete,
              color: AppTheme.fontColor(context),
              onPressed: onFilterDelete,
              iconSize: _internalLayout.iconSize,
            ),
          ],
        ),
      ),
    );
  }

  Widget _controlTab(String label) {
    return RotatedBox(
      quarterTurns: isLandscape ? 1 : 0,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: _internalLayout.spacer),
        child: Text(
          translate(label),
          softWrap: false,
          style: TextStyle(fontSize: _internalLayout.getScaledSize(14)),
        ),
      ),
    );
  }
}
