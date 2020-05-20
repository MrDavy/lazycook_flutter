import 'package:flutter/material.dart';
import 'package:lazycook/application.dart';
import 'package:lazycook/core/viewmodels/person/login/user_model.dart';
import 'package:lazycook/ui/route/routers.dart';
import 'package:lazycook/utils/fluro/src/common.dart';
import 'package:lazycook/utils/fluro_convert_util.dart';
import 'package:lazycook/utils/logger.dart';
import 'dart:convert';

import 'package:lazycook/utils/utils.dart';
import 'package:provider/provider.dart';

class Nav {
  static Logger logger = Logger('Nav');

  static Future pageTo(context, String route,
      {bool needLogin = false,
      bool replace = false,
      bool clearStack = false,
      RoutePredicate predicate,
      TransitionType transition = TransitionType.cupertino,
      Map<String, dynamic> param}) {
    if (param != null && param.isNotEmpty) {
      route = route + "?json=${Utils.convertMapToJson(param)}";
    }
    return Application.router.navigateTo(Application.context, route,
        transition: transition,
        replace: replace,
        clearStack: clearStack,
        predicate: predicate,
        transitionDuration: Duration(milliseconds: 200));
  }

  static Future navigateTo(String route,
      {bool replace = false,
      bool clearStack = false,
      RoutePredicate predicate,
      TransitionType transition = TransitionType.cupertino,
      Map<String, dynamic> param}) {
    return pageTo(Application.context, route,
        replace: replace,
        clearStack: clearStack,
        predicate: predicate,
        transition: transition,
        param: param);
  }

  static void back<T>({T param}) {
    Navigator.pop<T>(Application.context, param);
  }

  static void backUntil(context, path) {
    Navigator.popUntil(context, ModalRoute.withName(path));
  }

  static void backTo(context, path, {Map<String, dynamic> param}) {
    Navigator.popAndPushNamed(context, path);
  }
}
