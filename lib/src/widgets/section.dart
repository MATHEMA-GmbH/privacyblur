import 'package:flutter/material.dart';

class Section extends StatelessWidget {
  final Widget child;
  final double? sectionHeight;

  const Section({Key? key, required this.child, required this.sectionHeight})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
        height: sectionHeight!,
        child: Center(
          child: child,
        ));
  }
}
