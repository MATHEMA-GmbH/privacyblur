import 'package:flutter/material.dart';

class ScaledWrapper extends StatelessWidget {
  final Widget child;

  ScaledWrapper({required this.child});

  @override
  Widget build(BuildContext context) {
    final mediaQueryData = MediaQuery.of(context);
    final double constrainedTextScaleFactor =
        mediaQueryData.textScaleFactor.clamp(0.9, 1.1);

    return MediaQuery(
      data: MediaQuery.of(context).copyWith(
        textScaleFactor: constrainedTextScaleFactor,
      ),
      child: child,
    );
  }
}
