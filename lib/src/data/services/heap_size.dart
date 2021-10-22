import 'package:flutter/services.dart';

class HeapSize {
  static const _platform = MethodChannel('de.mathema.privacyblur/memory');

  HeapSize._privateConstructor();

  static final HeapSize _instance = HeapSize._privateConstructor();

  factory HeapSize() {
    return _instance;
  }

  Future<dynamic> getSize() {
    return _platform.invokeMethod('getHeapSize');
  }
}
