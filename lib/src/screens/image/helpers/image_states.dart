import 'package:privacyblur/src/screens/image/utils/positions_utils.dart';
import 'package:privacyblur/src/utils/image_filter/helpers/filter_result.dart';
import 'package:privacyblur/src/widgets/message_bar.dart';

import 'constants.dart';
import 'image_classes_helper.dart';

enum EditTool { EditSize, EditShape, EditGranularity, EditType }
enum FeedbackAction { ShowMessage, Navigate }

/// state to show message in UI
class ImageStateFeedback extends ImageStateBase {
  final String messageData;
  final MessageBarType messageType;
  final Set<FeedbackAction> feedback;
  final Map<String, dynamic>? positionalArgs;

  ImageStateFeedback(this.messageData,
      {this.messageType = MessageBarType.Information,
      this.feedback = const {FeedbackAction.ShowMessage},
      this.positionalArgs});
}

/// state to generate content on screen
class ImageStateScreen extends ImageStateBase {
  String filename = "";
  late ImageFilterResult image;
  List<FilterPosition> positions = List.empty(growable: true);
  int selectedFilterIndex = -1;

  // maybe remove from bloc in next version. ...Why?
  bool get hasSelection {
    return positions.length > 0;
  }

  bool get isImageSelected => getSelectedPosition() == null;

  bool isImageSaved = false;
  EditTool activeTool = EditTool.EditSize;
  int maxRadius = 300; //will be changed once on image set
  int maxPower = 50; //will be changed once on image set

  void resetSelection() {
    positions.clear();
    selectedFilterIndex = -1;
  }

  void positionsUpdateOrder() {
    selectedFilterIndex =
        PositionsUtils.changeAreasDrawOrder(positions, selectedFilterIndex);
  }

  void positionsMark2Redraw() {
    PositionsUtils.markCrossedAreas(positions, selectedFilterIndex);
  }

  FilterPosition? getSelectedPosition() {
    var canGetPosition = selectedFilterIndex >= 0 &&
        selectedFilterIndex < positions.length &&
        positions[selectedFilterIndex].posX > ImgConst.undefinedPosValue &&
        positions[selectedFilterIndex].posY > ImgConst.undefinedPosValue;
    if (!canGetPosition) return null;
    return positions[selectedFilterIndex];
  }

  ImageStateScreen clone() {
    var newImageStateScreen = ImageStateScreen()
      ..image = this.image
      ..filename = this.filename
      ..isImageSaved = this.isImageSaved
      ..activeTool = this.activeTool
      ..maxPower = this.maxPower
      ..selectedFilterIndex = this.selectedFilterIndex
      ..positions = this.positions
      ..maxRadius = this.maxRadius;
    return newImageStateScreen;
  }
}

/// base state class with override for == operator
class ImageStateBase {
  static int _globalSerial = 1;
  int _blocSerial = 0;

  ImageStateBase() {
    _globalSerial++;
    _blocSerial = _globalSerial;
  }

  @override
  bool operator ==(other) {
    if (other is ImageStateBase) {
      return this._blocSerial == other._blocSerial;
    }
    return false;
  }

  @override
  int get hashCode => super.hashCode;
}
