import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lazycook/ui/shared/colors.dart';
import 'package:lazycook/ui/shared/styles.dart';

class Button extends StatelessWidget {
  final Color accentColor;
  final Color disabledColor;
  final Color textColor;
  final String text;
  final VoidCallback onPressed;
  final double fontSize;
  final FontWeight fontWeight;
  final ShapeBorder shape;
  final double height;
  final double width;
  final BorderRadiusGeometry borderRadius;
  final EdgeInsetsGeometry margin;
  final bool enable;

  const Button({
    Key key,
    this.text = "",
    this.accentColor = Colors.grey,
    this.disabledColor,
    this.textColor,
    this.onPressed,
    this.fontSize,
    this.fontWeight,
    this.shape,
    this.height,
    this.width,
    this.margin,
    this.borderRadius,
    this.enable = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height ?? ScreenUtil.getInstance().setHeight(40),
      width: width ?? double.infinity,
      margin: margin ?? EdgeInsets.zero,
      child: RaisedButton(
        shape: shape ??
            RoundedRectangleBorder(
                borderRadius:
                    borderRadius ?? BorderRadius.all(Radius.circular(4))),
        color: accentColor,
        highlightElevation: 2,
        disabledColor: disabledColor ?? buttonDisableColor,
        disabledElevation: 0,
        elevation: 2,
        onPressed: enable ? onPressed : null,
        child: Text(
          text,
          style: textStyle(
              color: textColor ?? Colors.white,
              fontSize: fontSize ?? ScreenUtil.getInstance().setSp(16),
              fontWeight: fontWeight ?? FontWeight.w400),
        ),
      ),
    );
  }
}
