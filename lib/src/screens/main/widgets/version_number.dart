import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:yaml/yaml.dart';

class VersionNumber extends StatelessWidget {
  const VersionNumber({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: rootBundle.loadString('pubspec.yaml'),
        builder: (context, snapshot) {
          String version = "";
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.hasData) {
              var yaml = loadYaml(snapshot.data.toString());
              if (yaml != null) {
                version = yaml["version"].replaceAll(RegExp(r'(\+)\w+'), "");
              }
            }
          }
          return Text(version);
        });
  }
}
