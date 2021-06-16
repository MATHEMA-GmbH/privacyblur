import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'dart:ui' as img_tools;

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:privacyblur/resources/localization/keys.dart';
import 'package:privacyblur/src/data/services/face_detection.dart';
import 'package:privacyblur/src/screens/image/helpers/constants.dart';
import 'package:privacyblur/src/utils/image_filter/helpers/matrix_blur.dart';
import 'package:privacyblur/src/utils/image_filter/helpers/matrix_pixelate.dart';
import 'package:privacyblur/src/utils/image_filter/image_filters.dart';
import 'package:privacyblur/src/widgets/message_bar.dart';

import 'helpers/image_classes_helper.dart';
import 'helpers/image_events.dart';
import 'helpers/image_states.dart';
import 'image_repo.dart';
import 'utils/image_tools.dart';

// may be move to image_events, but it became visible in project, not only inside BLoC
class _yield_state_internally extends ImageEventBase {}

class ImageBloc extends Bloc<ImageEventBase, ImageStateBase?> {
  final ImageStateScreen _blocState = ImageStateScreen();
  final ImageRepository _repo;
  final ImgTools imgTools; //for mocking saving operations in future tests
  final FaceDetection faceDetection;

  Timer? _deferedFuture;
  Duration _defered = Duration(milliseconds: ImgConst.applyDelayDuration);

  ImageBloc(this._repo, this.imgTools, this.faceDetection) : super(null);

  @override
  Stream<ImageStateBase> mapEventToState(ImageEventBase event) async* {
    if (event is ImageEventSelected) {
      yield* imageSelected(event);
    } else if (event is ImageEventEditToolSelected) {
      yield* imageToolSelected(event);
    } else if (event is ImageEventFilterGranularity) {
      yield* powerFilterChanged(event);
    } else if (event is ImageEventShapeSize) {
      yield* radiusFilterChanged(event);
    } else if (event is ImageEventPositionChanged) {
      yield* positionFilterChanged(event);
    } else if (event is ImageEventNewFilter) {
      yield* addFilter(event);
    } else if (event is ImageEventExistingFilterSelected) {
      yield* selectFilterIndex(event);
    } else if (event is ImageEventCurrentFilterDelete) {
      yield* deleteFilterIndex(event);
    } else if (event is ImageEventSave2Disk) {
      yield* saveImage(event);
    } else if (event is ImageEventFilterPixelate) {
      yield* filterTypeChanged(event);
    } else if (event is ImageEventShapeRounded) {
      yield* filterShapeChanged(event);
    } else if (event is ImageEventDetectFaces) {
      yield* detectFaces();
    } else if (event is _yield_state_internally) {
      yield _blocState.clone();
    }
  }

  var imageFilter = ImageAppFilter();

  void _filterInArea() {
    _blocState.positions.forEach((position) {
      if (position.canceled || position.forceRedraw) {
        if (position.isPixelate) {
          imageFilter.setFilter(MatrixAppPixelate(
              (_blocState.maxPower * position.granularityRatio).toInt()));
        } else {
          imageFilter.setFilter(MatrixAppBlur(
              (_blocState.maxPower * position.granularityRatio).toInt()));
        }
        var radius = position.getVisibleRadius();
        imageFilter.apply2Area(
            position.posX, position.posY, radius, position.isRounded);
        position.canceled = false;
        position.forceRedraw = false;
      }
    });
  }

  void _applyCurrentFilter() {
    _deferedFuture?.cancel();
    _deferedFuture = Timer(_defered, () async {
      _filterInArea();
      _blocState.image = await imageFilter.getImage();
      add(new _yield_state_internally());
    });
  }

  void _cancelPosition(FilterPosition position) {
    if (position.canceled) return;
    position.canceled = true;
    imageFilter.cancelArea(position.posX, position.posY,
        position.getVisibleRadius(), position.isRounded);
  }

  void _cancelCurrentFilters(FilterPosition position) {
    if (position.canceled) return;
    _cancelPosition(position);
    _blocState.positionsMark2Redraw();
    _blocState.positions.forEach((pos) {
      if (pos.forceRedraw) {
        _cancelPosition(pos);
      }
    });
  }

  ImageStateFeedback _showFilterState() {
    String message = editToolMessage[_blocState.activeTool]!;
    return ImageStateFeedback(message, messageType: MessageBarType.Information);
  }

  Stream<ImageStateBase> filterShapeChanged(
      ImageEventShapeRounded event) async* {
    var position = _blocState.getSelectedPosition();
    if (position != null) {
      if (event.isRounded == position.isRounded) return;
      _cancelCurrentFilters(position);
      position.isRounded = event.isRounded;
      _applyCurrentFilter();
      yield _blocState.clone(); //needed
    }
  }

  Stream<ImageStateBase> filterTypeChanged(
      ImageEventFilterPixelate event) async* {
    var position = _blocState.getSelectedPosition();
    if (position != null) {
      if (event.isPixelate == position.isPixelate) return;
      _cancelCurrentFilters(position);
      position.isPixelate = event.isPixelate;
      _blocState.positionsUpdateOrder();
      _applyCurrentFilter(); //yield _blocState.clone(); not needed here
    }
  }

  Stream<ImageStateBase> saveImage(ImageEventSave2Disk event) async* {
    imageFilter.transactionCommit();
    _blocState.resetSelection();
    _blocState.image = await imageFilter.getImage();
    _blocState.isImageSaved = await imgTools.save2Gallery(
        imageFilter.imageWidth(),
        imageFilter.imageHeight(),
        imageFilter.getImageARGB32(),
        event.needOverride);
    if (_blocState.isImageSaved) {
      _blocState.savedOnce = true;
      yield ImageStateFeedback(Keys.Messages_Infos_Success_Saved,
          messageType: MessageBarType.Information);
    } else {
      yield ImageStateFeedback(Keys.Messages_Errors_File_System,
          messageType: MessageBarType.Failure);
    }
    yield _blocState.clone();
  }

  Stream<ImageStateScreen> selectFilterIndex(
      ImageEventExistingFilterSelected event) async* {
    _blocState.selectedFilterIndex = event.index;
    yield _blocState.clone(); //needed
  }

  Stream<ImageStateScreen> deleteFilterIndex(
      ImageEventCurrentFilterDelete event) async* {
    if (_blocState.positions.length <= 1) {
      imageFilter.transactionCancel();
      _blocState.resetSelection();
      _blocState.image = await imageFilter.getImage();
      if (_blocState.positions.isEmpty) _blocState.isImageSaved = true;
      yield _blocState.clone(); //needed
      return;
    }
    var position = _blocState.getSelectedPosition();
    if (position != null) {
      _cancelCurrentFilters(position);
      _blocState.removePositionObject(position);
      _applyCurrentFilter(); //yield _blocState.clone(); - not needed here
    }
  }

  Stream<ImageStateScreen> addFilter(ImageEventNewFilter event) async* {
    imageFilter.transactionStart();
    _blocState.addPosition(event.x, event.y);
    _blocState.selectedFilterIndex = _blocState.positions.length - 1;
    _blocState.isImageSaved = false;
    _applyCurrentFilter();
    yield _blocState.clone(); //needed
  }

  Stream<ImageStateScreen> positionFilterChanged(
      ImageEventPositionChanged event) async* {
    var position = _blocState.getSelectedPosition();
    if (position != null) {
      _cancelCurrentFilters(position);
      position.posX = event.x.toInt();
      position.posY = event.y.toInt();
      _applyCurrentFilter();
      yield _blocState.clone(); //needed
    }
  }

  Stream<ImageStateScreen> radiusFilterChanged(
      ImageEventShapeSize event) async* {
    var position = _blocState.getSelectedPosition();
    if (position != null) {
      _cancelCurrentFilters(position);
      position.radiusRatio = event.radius;
      _applyCurrentFilter();
      yield _blocState.clone(); //needed
    }
  }

  Stream<ImageStateScreen> powerFilterChanged(
      ImageEventFilterGranularity event) async* {
    var position = _blocState.getSelectedPosition();
    if (position != null) {
      _cancelCurrentFilters(position);
      position.granularityRatio = event.power;
      _blocState.positionsUpdateOrder();
      _applyCurrentFilter();
      yield _blocState.clone(); //not really needed here, but now its necessary
    }
  }

  Stream<ImageStateBase> imageToolSelected(
      ImageEventEditToolSelected event) async* {
    _blocState.activeTool = event.activeTool;
    yield _showFilterState();
    yield _blocState.clone();
  }

  Stream<ImageStateBase> imageSelected(ImageEventSelected event) async* {
    var lastPath = await _repo.getLastPath();
    var maxImageSize = ImgConst.defaultImageSize;
    if ((lastPath) == event.filename) {
      var heapMemory = await _repo.getHeapSize();
      if (heapMemory > 0) {
        maxImageSize =
            sqrt((heapMemory * ImgConst.partFreeMemory) / 4.0).toInt();
      }
    } else {
      maxImageSize = -1;
      await _repo.setLastPath(event.filename);
    }
    _blocState.filename = event.filename;
    _blocState.isImageSaved = true;
    img_tools.Image? tmpImage;
    try {
      tmpImage = await imgTools.scaleFile(_blocState.filename, maxImageSize);
      if (imgTools.scaled) {
        String origRes = '${imgTools.srcWidth} x ${imgTools.srcHeight}';
        String newRes = '${tmpImage.width} x ${tmpImage.height}';
        yield ImageStateFeedback(Keys.Messages_Errors_Image_Scale_Down,
            positionalArgs: {"origRes": origRes, "newRes": newRes});
      }
    } catch (e) {
      yield* _yieldCriticalException(Keys.Messages_Errors_Img_Not_Readable);
      return;
    }
    _blocState.maxRadius = (max(tmpImage.width, tmpImage.height) ~/ 4);
    _blocState.maxPower = (max(tmpImage.width, tmpImage.height) ~/ 35);
    _blocState.resetSelection();
    ImageAppFilter.setMaxProcessedWidth(_blocState.maxRadius * 3);

    /// VERY IMPORTANT TO USE AWAIT HERE!!!
    _blocState.image = await imageFilter.setImage(tmpImage);
    yield _blocState.clone();
    await _repo.removeLastPath();
  }

  Stream<ImageStateScreen> detectFaces() async* {
    imageFilter.transactionStart();
    var detectionResult = await faceDetection.detectFaces(
        Platform.isIOS
            ? imageFilter.getImageARGB8()
            : imageFilter.getImageNV21(),
        imageFilter.imageWidth(),
        imageFilter.imageHeight());
    if (_blocState.addFaces(detectionResult)) _blocState.isImageSaved = false;
    _blocState.selectedFilterIndex = _blocState.positions.length - 1;
    _applyCurrentFilter();
    yield _blocState.clone();
  }

  Stream<ImageStateFeedback> _yieldCriticalException(String title) async* {
    await _repo.removeLastPath();
    yield ImageStateFeedback(
      title,
      messageType: MessageBarType.Failure,
      feedback: {FeedbackAction.Navigate, FeedbackAction.ShowMessage},
    );
  }
}
