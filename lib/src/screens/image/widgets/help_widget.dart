import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:privacyblur/resources/localization/keys.dart';
import 'package:privacyblur/src/screens/image/utils/internal_layout.dart';
import 'package:privacyblur/src/widgets/theme/icons_provider.dart';
import 'package:privacyblur/src/widgets/theme/theme_provider.dart';

class HelpLine {
  final IconData icon;
  final String text;

  HelpLine(this.icon, this.text);
}

class HelpWidget extends StatelessWidget {
  static late InternalLayout _internalLayout;
  final double height;
  final double width;

  final List<HelpLine> helpLines = [
    HelpLine(AppIcons.click, Keys.Image_Screen_Help_Lines_Help0),
    HelpLine(AppIcons.drag, Keys.Image_Screen_Help_Lines_Help1),
    HelpLine(AppIcons.granularity, Keys.Image_Screen_Help_Lines_Help2),
    HelpLine(AppIcons.save, Keys.Image_Screen_Help_Lines_Help3)
  ];

  HelpWidget(this.height, this.width);

  @override
  Widget build(BuildContext context) {
    _internalLayout = InternalLayout(context);
    return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children:
            helpLines.map((help) => _helpTemplate(context, help)).toList());
  }

  Widget _helpTemplate(BuildContext context, HelpLine line) {
    double spacePerHelpline = height / helpLines.length;
    double widthFactor = min(max(width / height, 0.4), 1);
    double textSize = min(max(spacePerHelpline * 0.3 * widthFactor, 10), 16);
    return Padding(
      padding: EdgeInsets.only(
          left: _internalLayout.spacer * 2,
          right: _internalLayout.spacer * 2,
          bottom: min(spacePerHelpline * 0.25, 18)),
      child: Row(
        children: [
          Padding(
            padding:
                EdgeInsets.fromLTRB(0.0, 0, _internalLayout.spacer * 1.5, 0),
            child: Icon(
              line.icon,
              color: AppTheme.fontColor(context),
              size: textSize,
            ),
          ),
          Flexible(
              child: Text(
            translate(line.text),
            textScaleFactor: 1,
            style: TextStyle(
                color: AppTheme.fontColor(context),
                height: 1.1,
                fontSize: textSize),
          ))
        ],
      ),
    );
  }
}
