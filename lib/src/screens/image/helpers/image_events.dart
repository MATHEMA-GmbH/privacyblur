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

/// image click (tap) position updated
class ImageEventSetPosition extends ImageEventBase {
  final double x;
  final double y;

  ImageEventSetPosition(this.x, this.y);
}

/// filter apply clicked
class ImageEventApply extends ImageEventBase {}

/// filter apply clicked
class ImageEventCancel extends ImageEventBase {}

/// save image on disk clicked
class ImageEventSave2Disk extends ImageEventBase {}
