import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:privacyblur/resources/fonts/privacy_blur_icons.dart';
import 'package:privacyblur/src/widgets/theme/theme_provider.dart';

class AppIcons {
  static IconData get save {
    if (AppTheme.isCupertino) return CupertinoIcons.square_arrow_down;
    return Icons.save_alt_outlined;
  }

  static IconData get type {
    return PrivacyBlurIcons.type;
  }

  static IconData get click {
    if (AppTheme.isCupertino) return CupertinoIcons.hand_point_right;
    return Icons.arrow_forward_outlined;
  }

  static IconData get drag {
    if (AppTheme.isCupertino) return CupertinoIcons.move;
    return Icons.touch_app_outlined;
  }

  static IconData get done {
    if (AppTheme.isCupertino) return CupertinoIcons.check_mark;
    return Icons.done_outlined;
  }

  static IconData get resize {
    return PrivacyBlurIcons.resize;
  }

  static IconData get granularity {
    return PrivacyBlurIcons.granularity;
  }

  static IconData get shape {
    return PrivacyBlurIcons.shape;
  }

  static IconData get face {
    if (AppTheme.isCupertino) return CupertinoIcons.smiley;
    return Icons.tag_faces_outlined;
  }

  static IconData get delete {
    return Icons.delete_outlined;
  }
}
