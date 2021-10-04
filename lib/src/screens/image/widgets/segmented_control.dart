import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:privacyblur/src/widgets/theme/theme_provider.dart';

class SegmentedControl extends StatefulWidget {
  final int groupValue;
  final Map<int, Widget> tabs;
  final Function onChanged;

  SegmentedControl(
      {required this.tabs, required this.groupValue, required this.onChanged});

  @override
  _SegmentedControlState createState() => _SegmentedControlState();
}

class _SegmentedControlState extends State<SegmentedControl> {
  late int groupValue;

  @override
  void didUpdateWidget(covariant SegmentedControl oldWidget) {
    groupValue = widget.groupValue;
    super.didUpdateWidget(oldWidget);
  }

  @override
  void initState() {
    this.groupValue = widget.groupValue;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (AppTheme.isCupertino) {
      return CupertinoSlidingSegmentedControl(
        groupValue: this.groupValue,
        children: this.widget.tabs,
        onValueChanged: onChanged,
      );
    } else {
      List<Widget> tabChildren = [];
      widget.tabs.forEach((index, tab) {
        tabChildren.add(Radio(
          value: index,
          groupValue: this.groupValue,
          onChanged: onChanged,
          activeColor: this.groupValue == index
              ? AppTheme.primaryColor
              : AppTheme.fontColor(context),
        ));
        tabChildren.add(GestureDetector(
          onTap: () => onChanged(index),
          child: tab,
        ));
      });
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: tabChildren,
      );
    }
  }

  void onChanged(int) {
    setState(() {
      groupValue = int;
    });
    this.widget.onChanged(int);
  }
}
