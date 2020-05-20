import 'dart:math';

import 'package:flutter/material.dart';
import 'package:lazycook/utils/logger.dart';

///
/// @desc
/// @author davy
/// @date 2019/12/25 9:53 下午
///
class Pie extends CustomPainter {
  Paint piePaint;
  var color;
  var logger = Logger("Pie");
  var height;
  var width;

  Pie(this.width, this.height) {
    piePaint = Paint();

    piePaint.isAntiAlias = true;
    piePaint.color = Color(0xfff2f2f2);
    piePaint.style = PaintingStyle.fill;
  }

  @override
  void paint(Canvas canvas, Size size) {
//    logger.log("size = $size");
    piePaint.color = Color(0xffffffff);
    var rect = Rect.fromLTWH(-width / 2, height / 2, width, height / 2+1);
    canvas.drawRect(rect, piePaint);
    piePaint.color = Color(0xfff2f2f2);
    rect = Rect.fromLTWH(-width / 2, 0, width, height+1);
//    logger.log("rect = $rect");
    canvas.drawOval(rect, piePaint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}
