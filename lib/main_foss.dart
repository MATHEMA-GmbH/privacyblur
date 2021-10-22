import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'src/app_container.dart';
import 'src/utils/flavors.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  BuildFlavor.flavor = Flavor.foss;
  runApp(await AppContainer().app);
}
