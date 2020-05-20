import 'package:flutter/material.dart';
import 'package:lazycook/ui/widgets/main_widget.dart';

class Basket extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Material(
      child: MainWidget(
        statusBarColor: Theme.of(context).primaryColor,
        child: Text('Basket'),
      ),
    );
  }
}
