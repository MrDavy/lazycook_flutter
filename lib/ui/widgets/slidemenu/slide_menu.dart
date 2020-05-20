import 'package:flutter/material.dart';

///
/// 侧滑按钮
///
class SlideMenu extends StatelessWidget {
  //补充stack覆盖不全
  static const double SPACE = 0.6;

  final BoxDecoration decoration;
  final double height;
  final double width;
  final Widget child;

  const SlideMenu({
    Key key,
    @required this.child,
    this.decoration,
    this.height,
    this.width,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: decoration,
      width: width,
      height: height - SPACE,
      child: child,
    );
  }
}
