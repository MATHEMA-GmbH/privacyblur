import 'package:flutter_translate_annotations/flutter_translate_annotations.dart';
import 'package:privacyblur/src/constants.dart';

part 'keys.g.dart';

// Generate static translation keys: flutter pub run build_runner build --delete-conflicting-outputs

@TranslateKeysOptions(
    path: LOCALIZATION_RESOURCES_PATH, caseStyle: CaseStyle.titleCase, separator: "_")
class _$Keys // ignore: unused_element
{}
