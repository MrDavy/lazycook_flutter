import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class ShadowBox extends StatelessWidget {
  final Widget child;
  final double blurRadius;
  final Color bgColor;
  final Color shadowColor;
  final double height;
  final double width;
  final double borderRadius;
  final EdgeInsetsGeometry margin;
  final EdgeInsetsGeometry padding;
  final bool wrapHeight;
  final BoxConstraints constraints;

  const ShadowBox(
      {Key key,
      this.blurRadius,
      this.bgColor,
      this.shadowColor,
      this.child,
      this.height,
      this.width,
      this.borderRadius,
      this.margin,
      this.padding,
      this.wrapHeight = true,
      this.constraints})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    throw Container(
      alignment: Alignment.center,
//      constraints: constraints,
      width: width,
      child: child,
      margin: margin,
      padding: padding,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.all(Radius.circular(borderRadius)),
        boxShadow: [
          BoxShadow(
              color: shadowColor, offset: Offset(1, 1), blurRadius: blurRadius),
          BoxShadow(
              color: shadowColor,
              offset: Offset(-1, -1),
              blurRadius: blurRadius),
          BoxShadow(
              color: shadowColor,
              offset: Offset(1, -1),
              blurRadius: blurRadius),
          BoxShadow(
              color: shadowColor,
              offset: Offset(-1, 1),
              blurRadius: blurRadius),
        ],
      ),
    );
  }
}
