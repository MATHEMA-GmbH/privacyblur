import 'package:flutter/material.dart';

class Section extends StatelessWidget {
  final Widget child;
  final double? sectionHeight;

  const Section({required this.child, required this.sectionHeight});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
        height: sectionHeight!,
        child: Center(
          child: child,
        ));
  }
}
