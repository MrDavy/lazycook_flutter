import 'package:flutter/material.dart';
import 'package:lazycook/core/viewmodels/scroll_model.dart';
import 'package:provider/provider.dart';

class ScrollListenWidget extends StatefulWidget {
  final Widget Function(BuildContext context, ScrollModel model, Widget child)
      builder;
  final ScrollModel model;

  const ScrollListenWidget({Key key, this.builder, this.model})
      : super(key: key);

  @override
  _ScrollListenWidgetState createState() => _ScrollListenWidgetState();
}

class _ScrollListenWidgetState extends State<ScrollListenWidget> {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<ScrollModel>(
      create: (context) {
        return widget.model;
      },
      child: Consumer<ScrollModel>(builder: widget.builder),
    );
  }
}
