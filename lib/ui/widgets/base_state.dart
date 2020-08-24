import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lazycook/core/viewmodels/person/login/user_model.dart';
import 'package:lazycook/ui/route/nav.dart';
import 'package:lazycook/ui/route/routers.dart';
import 'package:lazycook/ui/widgets/loading_dialog.dart';
import 'package:lazycook/utils/fluro/src/common.dart';
import 'package:lazycook/utils/logger.dart';
import 'package:provider/provider.dart';

abstract class BaseState<T extends StatefulWidget> extends State<T> {
  Logger logger;
  ScreenUtil dimens;

  @override
  void initState() {
    super.initState();
    logger = Logger(this.runtimeType.toString());
    dimens = ScreenUtil.getInstance();
  }

  @override
  void dispose() {
    super.dispose();
  }

  dLog(msg) {
    logger?.log(msg);
  }

  double sp(double fontSize) {
    return dimens.setSp(fontSize);
  }

  //计算view宽度，将dp或者pt转成px
  double width(double width) {
    return dimens.setWidth(width);
  }

  //计算view高度，将dp或者pt转成px
  double height(double height) {
    return dimens.setHeight(height);
  }

  bool checkUser(from) {
    if (Provider.of<UserModel>(context, listen: false).hasUser) {
      return true;
    } else {
      login(from);
      return false;
    }
  }

  Future login(from) {
    return Nav.pageTo(context, Routers.login,
        param: {'scence': from},
        transition: TransitionType.cupertinoFullScreenDialog);
  }

}
