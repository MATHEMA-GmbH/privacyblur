import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_styled_toast/flutter_styled_toast.dart';
import 'package:privacyblur/src/widgets/theme/theme_provider.dart';

enum MessageBarType { Information, Failure }

mixin AppMessages {
  final messageBarStyles = {MessageBarType.Failure: const Color(0xFFC5003E)};

  void showMessage(
      {required BuildContext context,
      required String message,
      MessageBarType? type,
      double offsetBottom = 10.0}) {
    Color defaultBackgroundColor = AppTheme.fontColorAccent(context);
    Color defaultFontColor = AppTheme.scaffoldColor(context);
    var words = message.split(' ');
    Duration duration = Duration(seconds: min(max(words.length ~/ 3, 2), 10));
    showToast(
      message,
      context: context,
      animDuration: const Duration(milliseconds: 0),
      duration: duration,
      backgroundColor: type == MessageBarType.Failure
          ? messageBarStyles[type]
          : defaultBackgroundColor,
      position: StyledToastPosition(
          align: Alignment.bottomCenter, offset: offsetBottom),
      textStyle: TextStyle(
          color:
              type == MessageBarType.Failure ? Colors.white : defaultFontColor),
    );
  }
}
