import 'package:privacyblur/src/screens/image/helpers/image_states.dart';

class ImageEventBase {}

/// triggered after image was selected
class ImageEventSelected extends ImageEventBase {
  final String filename;

  ImageEventSelected(this.filename);
}

/// filter set edit tool
class ImageEventEditToolSelected extends ImageEventBase {
  final EditTool activeTool;

  ImageEventEditToolSelected(this.activeTool);
}

/// filter set rounded
class ImageEventShapeRounded extends ImageEventBase {
  final bool isRounded;

  ImageEventShapeRounded(this.isRounded);
}

/// filter set pixelate
class ImageEventFilterPixelate extends ImageEventBase {
  final bool isPixelate;

  ImageEventFilterPixelate(this.isPixelate);
}

/// filter shape size changed
class ImageEventShapeSize extends ImageEventBase {
  final double radius;

  ImageEventShapeSize(this.radius);
}

/// filter power changed
class ImageEventFilterGranularity extends ImageEventBase {
  final double power;

  ImageEventFilterGranularity(this.power);
}

/// filter index selected
class ImageEventExistingFilterSelected extends ImageEventBase {
  final int index;

  ImageEventExistingFilterSelected(this.index);
}

class ImageEventCurrentFilterDelete extends ImageEventBase {}

class ImageEventDetectFaces extends ImageEventBase {}

/// image click (tap) new filter adding
class ImageEventNewFilter extends ImageEventBase {
  final double x;
  final double y;

  ImageEventNewFilter(this.x, this.y);
}

/// image move filter
class ImageEventPositionChanged extends ImageEventBase {
  final double x;
  final double y;

  ImageEventPositionChanged(this.x, this.y);
}

/// save image on disk clicked
class ImageEventSave2Disk extends ImageEventBase {
  final bool needOverride;

  ImageEventSave2Disk(this.needOverride);
}
