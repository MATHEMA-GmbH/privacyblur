import 'package:flutter/material.dart';

class ScaledWrapper extends StatelessWidget {
  final Widget child;

  const ScaledWrapper({Key? key, required this.child}) : super(key: key);

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
