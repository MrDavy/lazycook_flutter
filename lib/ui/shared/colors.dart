import 'package:flutter/material.dart';

const green = Color(0xFF6DD400);
const blue = Color(0xFF0091FF);
const white = Colors.white;

const secondColor = Color(0xff99CC33);
const accentColor = Color(0xffff9900);
const primaryColor = Color(0xffff9900);
const primaryColorDark = Color(0xffff9900);
const gray = Color(0xfff0f0f0);
const lineColor = Color(0xffEDEDED);

const skeletonGray = Color(0xffF9FAFB);
const alphaSkeletonGray = Color(0x9ff0f0f0);
const backgroundGray = Color(0xfff6f6f6);
const red = Color(0xffDD3229);
const textColor = Color(0xff1e1e1e);
const hintColor = Color(0xffAEAEAE);
const buttonDisableColor = Color(0xffcccccc);
const borderColor = Color(0xffE0E0E0);
const disableColor = Color(0xa0ff9900);
const color_999 = Color(0xff999999);
const color_222 = Color(0xff222222);
const color_333 = Color(0xff333333);
const color_666 = Color(0xff666666);
const color_f2 = Color(0xfff2f2f2);

const successColor = Color(0xff07c160);
const noticeColor = Color(0xff10aeff);
const generalWarnColor = Color(0xffa5a5a5);
const warnColor = Color(0xfffa5151);
const waitColor = Color(0xff10aeff);

LinearGradient defaultGradient(context) {
  return LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        Theme.of(context).primaryColor,
        backgroundGray,
        backgroundGray,
        backgroundGray
      ]);
}
