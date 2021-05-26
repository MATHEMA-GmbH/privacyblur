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
  int selectedFilterPosition = -1;

  // maybe remove from bloc in next version. ...Why?
  bool get hasSelection {
    return selectedFilterPosition >= 0 &&
        selectedFilterPosition < positions.length &&
        positions[selectedFilterPosition].posX > ImgConst.undefinedPosValue &&
        positions[selectedFilterPosition].posY > ImgConst.undefinedPosValue;
  }

  bool get isImageSelected => selectedFilterPosition < 0;

  bool isImageSaved = false;
  EditTool activeTool = EditTool.EditSize;
  int maxRadius = 300; //will be changed once on image set
  int maxPower = 50; //will be changed once on image set

  void resetSelection() {
    positions.clear();
    selectedFilterPosition=-1;
  }

  FilterPosition? getSelectedPosition(){
    if(!hasSelection) return null;
    return positions[selectedFilterPosition];
  }

  ImageStateScreen clone() {
    var newImageStateScreen = ImageStateScreen()
      ..image = this.image
      ..filename = this.filename
      ..isImageSaved = this.isImageSaved
      ..activeTool = this.activeTool
      ..maxPower = this.maxPower
      ..selectedFilterPosition = this.selectedFilterPosition
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
