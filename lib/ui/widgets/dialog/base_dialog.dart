import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class BaseDialog extends Dialog {
  num width(w) {
    return ScreenUtil.getInstance().setWidth(w);
  }

  num height(h) {
    return ScreenUtil.getInstance().setHeight(h);
  }

  num sp(h) {
    return ScreenUtil.getInstance().setSp(h);
  }
}
