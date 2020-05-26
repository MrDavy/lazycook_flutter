import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lazycook/ui/shared/calc.dart';

const headerStyle = TextStyle(fontSize: 35, fontWeight: FontWeight.w900);
const subHeaderStyle = TextStyle(fontSize: 16.0, fontWeight: bold);

const bold = FontWeight.w500;

///文本样式，方便修改字体
TextStyle textStyle({color, fontSize, fontWeight, height, decoration}) {
  return GoogleFonts.sourceSansPro(
      textStyle: TextStyle(
          decoration: decoration,
          color: color,
          fontSize: fontSize,
          height: height,
          fontWeight: fontWeight));
}

TextStyle inputLabelStyle() {
  return GoogleFonts.sourceSansPro(
    textStyle: TextStyle(fontWeight: FontWeight.w400, fontSize: sp(14)),
  );
}

List<BoxShadow> getBoxShadows(Color color,
    {double blurRadius = 0.0, double spreadRadius = 0.0}) {
  return [
    BoxShadow(
        color: color,
        offset: Offset(1, 1),
        spreadRadius: spreadRadius,
        blurRadius: blurRadius),
    BoxShadow(
        color: color,
        offset: Offset(-1, -1),
        spreadRadius: spreadRadius,
        blurRadius: blurRadius),
    BoxShadow(
        color: color,
        offset: Offset(1, -1),
        spreadRadius: spreadRadius,
        blurRadius: blurRadius),
    BoxShadow(
        color: color,
        offset: Offset(-1, 1),
        spreadRadius: spreadRadius,
        blurRadius: blurRadius),
  ];
}

List<BoxShadow> getBoxLTRBShadows(Color color,
    {double blurRadius = 0.0,
    double leftSpreadRadius = 0.0,
    double topSpreadRadius = 0.0,
    double rightSpreadRadius = 0.0,
    double bottomSpreadRadius = 0.0}) {
  return [
    BoxShadow(
        color: color,
        offset: Offset(1, 1),
        spreadRadius: leftSpreadRadius,
        blurRadius: blurRadius),
    BoxShadow(
        color: color,
        offset: Offset(-1, -1),
        spreadRadius: topSpreadRadius,
        blurRadius: blurRadius),
    BoxShadow(
        color: color,
        offset: Offset(1, -1),
        spreadRadius: rightSpreadRadius,
        blurRadius: blurRadius),
    BoxShadow(
        color: color,
        offset: Offset(-1, 1),
        spreadRadius: bottomSpreadRadius,
        blurRadius: blurRadius),
  ];
}

Map createDecoration(borderColor, focusedColor, errorColor) {
  return {
    'focusedErrorBorder': OutlineInputBorder(
      borderSide: BorderSide(color: errorColor),
      borderRadius: BorderRadius.circular(width(4)),
    ),
    "focusedBorder": OutlineInputBorder(
      borderSide: BorderSide(color: focusedColor),
      borderRadius: BorderRadius.circular(width(4)),
    ),
    "border": OutlineInputBorder(
      borderSide: BorderSide(color: borderColor, width: width(1)),
      borderRadius: BorderRadius.circular(width(4)),
    ),
    "contentPadding":
        EdgeInsets.symmetric(vertical: height(4), horizontal: width(4)),
  };
}
