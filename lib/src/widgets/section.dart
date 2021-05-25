import 'package:flutter/material.dart';

class Section extends StatelessWidget {
  final Widget child;
  final double? sectionHeight;

  Section({required this.child, required this.sectionHeight});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
        height: this.sectionHeight!,
        child: Center(
          child: this.child,
        ));
  }
}
