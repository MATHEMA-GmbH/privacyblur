import 'dart:ui' as img_tools;

class ImageFilterResult {
  late img_tools.Image _mainImage;
  img_tools.Image? _changedPart;

  img_tools.Image? get changedPart {
    return _changedPart;
  }

  set changedPart(img_tools.Image? image) {
    _changedPart = image;
    if (_changedPart == null) {
      posX = -1;
      posY = -1;
    }
    _updateHash();
  }

  img_tools.Image get mainImage {
    return _mainImage;
  }

  set mainImage(img_tools.Image image) {
    _mainImage = image;
    _updateHash();
  }

  int posX = -1, posY = -1;
  int _hash = 0;

  void _updateHash() {
    _hash = mainImage.hashCode - (changedPart?.hashCode ?? 0);
  }

  ImageFilterResult.empty();

  @override
  bool operator ==(other) {
    return (other is ImageFilterResult) ? _hash == other._hash : false;
  }

  @override
  int get hashCode => _hash;
}
