import 'package:flutter/material.dart';
import 'package:lazycook/ui/widgets/main_widget.dart';

class Circle extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Material(
      child: MainWidget(
        child: Text('Circle'),
        headerFloat: false,
      ),
    );
  }
}
