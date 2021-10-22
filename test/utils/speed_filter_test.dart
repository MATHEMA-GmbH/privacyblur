import 'dart:async';
import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img_external;
import 'package:privacyblur/src/utils/image_filter/helpers/matrix_blur.dart';
import 'package:privacyblur/src/utils/image_filter/helpers/matrix_pixelate.dart';
import 'package:privacyblur/src/utils/image_filter/image_filters.dart';

void main() {
  test('Image save Test', () async {
    ImageAppFilter filter = ImageAppFilter();

    var _width = 10000;
    var _height = 10000;
    Uint32List listData = Uint32List(_width * _height); //7x7
    Completer<Image> _completer = Completer();
    decodeImageFromPixels(
        listData.buffer.asUint8List(), _width, _height, PixelFormat.rgba8888,
        (result) {
      _completer.complete(result);
    });
    var image = await _completer.future;
    await filter.setImage(image);
    filter.transactionStart();
    filter.setFilter(MatrixAppPixelate(3));
    filter.apply2Area(300, 300, 200, false); //to all image
    var time1 = DateTime.now().millisecondsSinceEpoch;
    for (int i = 0; i < 200; i++) {
      filter.apply2Area(300, 300, 20, false); //to all image
      image = (await filter.getImage()).mainImage;
    }
    var t1 = await Future.value(true);
    var diff = DateTime.now().millisecondsSinceEpoch - time1;
    var templateTime = diff;
    print('------------------------------------------------');
    print('----------Image with transaction x 200----------');
    print(((diff ~/ 10) / 100).toString() + " sec");
    filter.transactionCommit();
    time1 = DateTime.now().millisecondsSinceEpoch;
    image = (await filter.getImage()).mainImage;
    var t2 = await Future.value(true);
    diff = DateTime.now().millisecondsSinceEpoch - time1;
    print('----------------------------------------------');
    print('-------------Image NO transaction-------------');
    print(((diff ~/ 10) / 100).toString() + " sec");
    print('----------------------------------------------');
    print('**********************************************');
    expect(templateTime < diff, true);
  });

  // Before any changes in filter run this test and take a time.
  // Then try to reduce this time.
  //
  // result on my laptop was:
  // size: 3000x3000
  // blur filter size: 500
  // apply2SquareArea(2000, 2000, 10000)
  // Total Time: ~12.1 sec
  test('blur speed test 3000x3000', () async {
    ImageAppFilter filter = ImageAppFilter();

    var _width = 3000;
    var _height = 3000;
    Uint32List listData = Uint32List(_width * _height); //7x7
    for (int i = 0; i < listData.length; i++) {
      listData[i] = 0xff707070;
    }
    Completer<Image> _completer = Completer();
    decodeImageFromPixels(
        listData.buffer.asUint8List(), _width, _height, PixelFormat.rgba8888,
        (result) {
      _completer.complete(result);
    });
    var image = await _completer.future;
    await filter.setImage(image);
    ImageAppFilter.setMaxProcessedWidth(_width + 1);
    var time1 = DateTime.now().millisecondsSinceEpoch;
    double multiplyCounter = 0.001; //float point variable
    for (int i = 0; i < 63000000; i++) {
      multiplyCounter *= i.toDouble();
      multiplyCounter -= (multiplyCounter - 1.0);
    }
    var diff = DateTime.now().millisecondsSinceEpoch - time1;
    var templateTime = diff;
    print('----------------' +
        multiplyCounter.toString() +
        '-------------------');
    print('------------Control Time--------------');
    print(((diff ~/ 100) / 10).toString() + " sec");
    print('-------------------------------------');

    filter.setFilter(MatrixAppBlur(500));
    filter.transactionStart();
    time1 = DateTime.now().millisecondsSinceEpoch;
    filter.apply2Area(2000, 2000, 10000, false); //to all image
    diff = DateTime.now().millisecondsSinceEpoch - time1;
    print('-------------------------------------');
    print('------------Filter Time--------------');
    print(((diff ~/ 100) / 10).toString() + " sec");
    print('-------------------------------------');
    print('*************************************');
    expect((templateTime * 15.0) > diff, true);
  });

  test('blur speed compare 1000x1000', () async {
    ImageAppFilter filter = ImageAppFilter();

    var _width = 1000;
    var _height = 1000;
    Uint32List listData = Uint32List(_width * _height); //7x7
    Completer<Image> _completer = Completer();
    decodeImageFromPixels(
        listData.buffer.asUint8List(), _width, _height, PixelFormat.rgba8888,
        (result) {
      _completer.complete(result);
    });
    var image = await _completer.future;
    await filter.setImage(image);
    ImageAppFilter.setMaxProcessedWidth(_width + 1);
    var time1 = DateTime.now().millisecondsSinceEpoch;
    var diff = DateTime.now().millisecondsSinceEpoch - time1;
    var templateTime = diff;
    filter.setFilter(MatrixAppBlur(500));
    filter.transactionStart();
    time1 = DateTime.now().millisecondsSinceEpoch;
    filter.apply2Area(2000, 2000, 10000, false); //to all image
    filter.transactionCommit();
    diff = DateTime.now().millisecondsSinceEpoch - time1;
    print('-------------------------------------');
    print('------------Filter Time--------------');
    print(((diff ~/ 100) / 10).toString() + " sec");
    print('-------------------------------------');
    print('-------------------------------------');
    var appFilterTime = diff;
    img_external.Image extImageLib = img_external.Image.rgb(_width, _height);
    time1 = DateTime.now().millisecondsSinceEpoch;

    ///this library use a trick as fact they calculate only 2/3 of radius.
    ///bluring is not so powerfull as with linear bluring.
    ///to get same result radius must be in 3-4 times bigger
    ///but even with same block size it works in 7 times slower.
    img_external.gaussianBlur(extImageLib, 250);
    diff = DateTime.now().millisecondsSinceEpoch - time1;
    print('-------------------------------------');
    print('---------External Lib Time-----------');
    print(((diff ~/ 100) / 10).toString() + " sec");
    print('-------------------------------------');
    print('*************************************');
    expect(appFilterTime * 6.0 < diff, true);
  });

  test('pixelate speed compare 15.000x15.000', () async {
    ImageAppFilter filter = ImageAppFilter();

    var _width = 15000;
    var _height = 15000;
    Uint32List listData = Uint32List(_width * _height); //7x7
    Completer<Image> _completer = Completer();
    decodeImageFromPixels(
        listData.buffer.asUint8List(), _width, _height, PixelFormat.rgba8888,
        (result) {
      _completer.complete(result);
    });
    var image = await _completer.future;
    await filter.setImage(image);
    ImageAppFilter.setMaxProcessedWidth(_width + 1);
    var time1 = DateTime.now().millisecondsSinceEpoch;
    var diff = DateTime.now().millisecondsSinceEpoch - time1;
    var templateTime = diff;
    filter.setFilter(MatrixAppPixelate(500));
    filter.transactionStart();
    time1 = DateTime.now().millisecondsSinceEpoch;
    filter.apply2Area(10000, 10000, 10000, false); //to all image
    filter.transactionCommit();
    diff = DateTime.now().millisecondsSinceEpoch - time1;
    print('-------------------------------------');
    print('------------Filter Time--------------');
    print(((diff ~/ 100) / 10).toString() + " sec");
    print('-------------------------------------');
    print('-------------------------------------');
    var appFilterTime = diff;
    img_external.Image extImageLib = img_external.Image.rgb(_width, _height);
    time1 = DateTime.now().millisecondsSinceEpoch;
    img_external.pixelate(extImageLib, 500);
    diff = DateTime.now().millisecondsSinceEpoch - time1;
    print('-------------------------------------');
    print('---------External Lib Time-----------');
    print(((diff ~/ 100) / 10).toString() + " sec");
    print('-------------------------------------');
    print('-------------------------------------');
    expect(appFilterTime * 3.0 < diff, true);
  });
}
