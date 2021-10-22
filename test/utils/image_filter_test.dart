import 'dart:async';
import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:privacyblur/src/utils/image_filter/helpers/matrix_blur.dart';
import 'package:privacyblur/src/utils/image_filter/image_filters.dart';

void main() {
  /// --- UserInfo ---
  test('blur', () async {
    ImageAppFilter filter = ImageAppFilter();

    var _width = 5;
    var _height = 5;
    Uint32List listData = Uint32List(_width * _height); //7x7
    for (int i = 0; i < listData.length; i++) {
      listData[i] = 0xff707070;
    }
    //set some random color
    for (int x = 0; x < _width; x++) {
      for (int y = 0; y < _height; y++) {
        listData[y * _width + x] = ((x == 1 ? x : x * 2) * (y + 1)) * 5;
      }
    }
    Completer<Image> _completer = Completer();
    decodeImageFromPixels(
        listData.buffer.asUint8List(), _width, _height, PixelFormat.rgba8888,
        (result) {
      _completer.complete(result);
    });
    var image = await _completer.future;
    await filter.setImage(image);
    filter.setFilter(MatrixAppBlur(3));
    filter.transactionStart();
    filter.apply2Area(3, 3, 3,false);
    filter.transactionCommit();
    image = (await filter.getImage()).mainImage;
    var imgData = (await image.toByteData())!.buffer.asUint32List();
    expect(imgData[0] & 0xff, 31);
    expect(imgData[1] & 0xff, 25);
    expect(imgData[2] & 0xff, 45);
    expect(imgData[3] & 0xff, 68);
    expect(imgData[4] & 0xff, 55);

    expect(imgData[5] & 0xff, 31);
    expect(imgData[6] & 0xff, 25);
    expect(imgData[7] & 0xff, 45);
    expect(imgData[8] & 0xff, 68);
    expect(imgData[9] & 0xff, 55);

    expect(imgData[10] & 0xff, 31);
    expect(imgData[11] & 0xff, 33);
    expect(imgData[12] & 0xff, 63);
    expect(imgData[13] & 0xff, 98);
    expect(imgData[14] & 0xff, 78);

    expect(imgData[15] & 0xff, 46);
    expect(imgData[16] & 0xff, 41);
    expect(imgData[17] & 0xff, 81);
    expect(imgData[18] & 0xff, 128);
    expect(imgData[19] & 0xff, 78);

    expect(imgData[20] & 0xff, 46);
    expect(imgData[21] & 0xff, 41);
    expect(imgData[22] & 0xff, 81);
    expect(imgData[23] & 0xff, 128);
    expect(imgData[24] & 0xff, 78);
  });
}
