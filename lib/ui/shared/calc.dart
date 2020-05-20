import 'package:flutter_screenutil/flutter_screenutil.dart';

num width(width) => ScreenUtil.getInstance().setWidth(width);

num height(height) => ScreenUtil.getInstance().setHeight(height);

num sp(size) => ScreenUtil.getInstance().setSp(size);
