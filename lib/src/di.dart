import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:privacyblur/src/data/services/heap_size.dart';
import 'package:privacyblur/src/data/services/local_storage.dart';
import 'package:privacyblur/src/screens/image/image_bloc.dart';
import 'package:privacyblur/src/screens/image/image_repo.dart';
import 'package:privacyblur/src/screens/image/utils/image_tools.dart';

import 'data/services/face_detection.dart';

class DependencyInjection {
  late String appName;
  static final DependencyInjection _instance = DependencyInjection._internal();

  DependencyInjection._internal();

  factory DependencyInjection() {
    return _instance;
  }

  List<RepositoryProvider> getRepositoryProviders() => [
        RepositoryProvider<ImageRepository>(
            create: (context) => ImageRepository(LocalStorage(), HeapSize()))
      ];

  BlocProvider<ImageBloc> getImageBloc() => BlocProvider<ImageBloc>(
      create: (context) => ImageBloc(
          RepositoryProvider.of<ImageRepository>(context),
          ImgTools(),
          FaceDetection()));
}
