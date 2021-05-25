import 'package:flutter/material.dart';
import 'package:privacyblur/src/utils/layout_config.dart';
import 'package:privacyblur/src/widgets/theme/theme_provider.dart';

class InternalLayout extends LayoutConfig {
  InternalLayout(BuildContext context) : super(context);

  double get view2PortraitSize {
    double additionalTabletSpacer = isTablet || isNeedSafeArea ? 30 : 10;
    return AppTheme.isIOS
        ? getScaledSize(180 + additionalTabletSpacer)
        : getScaledSize(200 + additionalTabletSpacer);
  }

  double get view2LandScapeSize {
    double additionalTabletSpacer = isTablet || isNeedSafeArea ? 30 : 10;
    return AppTheme.isIOS
        ? getScaledSize(180 + additionalTabletSpacer)
        : getScaledSize(175 + additionalTabletSpacer);
  }

  double get offsetBottom {
    double offsetBottom = landscapeMode ? 10.0 : view2PortraitSize + 10.0;
    return offsetBottom;
  }

  double get spacer {
    return getScaledSize(10);
  }

  double get iconSize {
    return getScaledSize(20);
  }
}
