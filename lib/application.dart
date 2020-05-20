import 'package:flutter/material.dart';
import 'package:lazycook/core/models/home_info.dart';
import 'package:lazycook/utils/fluro/src/router.dart';
import 'package:package_info/package_info.dart';

class Application {
  static Router router;
  static PackageInfo packageInfo;
  static BuildContext context;
  static String encryptKey;
  static HomeBasicInfo homeBasicInfo;
//  static GlobalKey<NavigatorState> navigatorState = new GlobalKey();
}
