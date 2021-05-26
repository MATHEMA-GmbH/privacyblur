import 'dart:async';
import 'dart:math';
import 'dart:ui' as img_tools;

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:privacyblur/resources/localization/keys.dart';
import 'package:privacyblur/src/screens/image/helpers/constants.dart';
import 'package:privacyblur/src/utils/image_filter/helpers/matrix_blur.dart';
import 'package:privacyblur/src/utils/image_filter/helpers/matrix_pixelate.dart';
import 'package:privacyblur/src/utils/image_filter/image_filters.dart';
import 'package:privacyblur/src/widgets/message_bar.dart';

import 'helpers/image_classes_helper.dart';
import 'helpers/image_events.dart';
import 'helpers/image_states.dart';
import 'image_repo.dart';
import 'utils/filter_utils.dart';
import 'utils/image_tools.dart';

// may be move to image_events, but it became visible in project, not only inside BLoC
class _yield_state_internally extends ImageEventBase {}

class ImageBloc extends Bloc<ImageEventBase, ImageStateBase?> {
  final ImageStateScreen _blocState = ImageStateScreen();
  final ImageRepository _repo;
  Timer? _deferedFuture;
  Duration _defered = Duration(milliseconds: ImgConst.applyDelayDuration);

  ImageBloc(this._repo) : super(null);

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
    } else if (event is ImageEventExistingFilterDelete) {
      yield* deleteFilterIndex(event);
    } else if (event is ImageEventApply) {
      yield* applyFilterChanged(event);
    } else if (event is ImageEventCancel) {
      yield* cancelTransaction();
    } else if (event is ImageEventSave2Disk) {
      yield* saveImage(event);
    } else if (event is ImageEventFilterPixelate) {
      yield* filterTypeChanged(event);
    } else if (event is ImageEventShapeRounded) {
      yield* filterShapeChanged(event);
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
      _blocState.selectedFilterPosition = FilterUtils.changeAreasDrawOrder(
          _blocState.positions, _blocState.selectedFilterPosition);
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
    FilterUtils.markCrossedAreas(
        _blocState.positions, _blocState.selectedFilterPosition);
    for (int i = 0; i < _blocState.positions.length; i++) {
      if (_blocState.positions[i].forceRedraw) {
        _cancelPosition(_blocState.positions[i]);
      }
    }
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
      yield _blocState.clone();
    }
  }

  Stream<ImageStateBase> filterTypeChanged(
      ImageEventFilterPixelate event) async* {
    var position = _blocState.getSelectedPosition();
    if (position != null) {
      if (event.isPixelate == position.isPixelate) return;
      _cancelCurrentFilters(position);
      position.isPixelate = event.isPixelate;
      _applyCurrentFilter();
      yield _blocState.clone();
    }
  }

  Stream<ImageStateBase> saveImage(ImageEventSave2Disk event) async* {
    _blocState.isImageSaved = await ImgTools().save2Gallery(
        imageFilter.imgChannels.imageWidth,
        imageFilter.imgChannels.imageHeight,
        imageFilter.imgChannels.tempImgArr);
    if (_blocState.isImageSaved) {
      yield ImageStateFeedback(Keys.Messages_Infos_Success_Saved,
          messageType: MessageBarType.Information);
    } else {
      yield ImageStateFeedback(Keys.Messages_Errors_File_System,
          messageType: MessageBarType.Failure);
    }
    yield _blocState.clone();
  }

  Stream<ImageStateScreen> applyFilterChanged(ImageEventApply event) async* {
    imageFilter.transactionCommit();
    _blocState.resetSelection();
    _blocState.image = await imageFilter.getImage();
    _blocState.isImageSaved = false;
    yield _blocState.clone();
  }

  Stream<ImageStateScreen> cancelTransaction() async* {
    imageFilter.transactionCancel();
    _blocState.resetSelection();
    _blocState.image = await imageFilter.getImage();
    yield _blocState.clone();
  }

  Stream<ImageStateScreen> selectFilterIndex(
      ImageEventExistingFilterSelected event) async* {
    _blocState.selectedFilterPosition = event.index;
    yield _blocState.clone();
  }

  Stream<ImageStateScreen> deleteFilterIndex(
      ImageEventExistingFilterDelete event) async* {
    if (_blocState.positions.length <= 1) {
      yield* cancelTransaction();
      return;
    }
    var position = _blocState.getSelectedPosition();
    if (position != null) {
      _cancelCurrentFilters(position);
      _blocState.selectedFilterPosition = event.index - 1;
      _blocState.positions.removeAt(event.index);
      _applyCurrentFilter();
      yield _blocState.clone();
    }
  }

  Stream<ImageStateScreen> addFilter(ImageEventNewFilter event) async* {
    imageFilter.transactionStart();
    _blocState.positions.add(FilterPosition(_blocState.maxRadius)
      ..posX = event.x.toInt()
      ..posY = event.y.toInt());
    _blocState.selectedFilterPosition = _blocState.positions.length - 1;
    _applyCurrentFilter();
    yield _blocState.clone();
  }

  Stream<ImageStateScreen> positionFilterChanged(
      ImageEventPositionChanged event) async* {
    var position = _blocState.getSelectedPosition();
    if (position != null) {
      _cancelCurrentFilters(position);
      position.posX = event.x.toInt();
      position.posY = event.y.toInt();
      _applyCurrentFilter();
      yield _blocState.clone();
    }
  }

  Stream<ImageStateScreen> radiusFilterChanged(
      ImageEventShapeSize event) async* {
    var position = _blocState.getSelectedPosition();
    if (position != null) {
      _cancelCurrentFilters(position);
      position.radiusRatio = event.radius;
      _applyCurrentFilter();
      yield _blocState.clone();
    }
  }

  Stream<ImageStateScreen> powerFilterChanged(
      ImageEventFilterGranularity event) async* {
    var position = _blocState.getSelectedPosition();
    if (position != null) {
      _cancelCurrentFilters(position);
      position.granularityRatio = event.power;
      _applyCurrentFilter();
    }
    yield _blocState.clone();
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
    var imgTools = ImgTools();
    try {
      tmpImage = await imgTools.scaleFile(_blocState.filename, maxImageSize);
      if (imgTools.scaled) {
        String origRes =
            imgTools.srcWidth.toString() + 'x' + imgTools.srcHeight.toString();
        String newRes =
            tmpImage.width.toString() + 'x' + tmpImage.height.toString();
        yield ImageStateFeedback(Keys.Messages_Errors_Image_Scale_Down,
            positionalArgs: {"origRes": origRes, "newRes": newRes});
      }
    } catch (e) {
      yield* _yieldCriticalException(Keys.Messages_Errors_Img_Not_Readable);
      return;
    }
    _blocState.maxRadius = (max(tmpImage.width, tmpImage.height) ~/ 6);
    _blocState.maxPower = (max(tmpImage.width, tmpImage.height) ~/ 30);
    _blocState.resetSelection();
    ImageAppFilter.setMaxProcessedWidth(_blocState.maxRadius * 3);

    /// VERY IMPORTANT TO USE AWAIT HERE!!!
    _blocState.image = await imageFilter.setImage(tmpImage);
    yield _blocState.clone();
    await _repo.removeLastPath();
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
