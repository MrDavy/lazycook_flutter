import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lazycook/application.dart';
import 'package:lazycook/config/config.dart';
import 'package:lazycook/config/storage_manager.dart';
import 'package:lazycook/ui/route/routers.dart';
import 'package:lazycook/utils/fluro/src/router.dart';
import 'package:lazycook/utils/utils.dart';

import 'lazycook.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await StorageManager.init();
  Application.packageInfo = await Utils.getPackageInfo();
  Router router = Router();
  Routers.configureRouters(router);
  Application.router = router;

  //捕获异常
  FlutterError.onError = (FlutterErrorDetails details) {
    if (Config.isDebug()) {
      try {} catch (e) {} finally {
        FlutterError.dumpErrorToConsole(details);
      }
    } else {
      Zone.current.handleUncaughtError(details.exception, details.stack);
    }
  };

  // 强制竖屏
  SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitDown, DeviceOrientation.portraitUp]).then((_) {
    runZonedGuarded(() {
      runApp(LazyCookApp());
    }, (error, stackTrace) async {
      await reportTrace(error, stackTrace);
    });
  });

  if (Platform.isAndroid) {
    SystemUiOverlayStyle systemUiOverlayStyle = SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarBrightness: Brightness.dark,
        systemNavigationBarColor: Colors.black);
    SystemChrome.setSystemUIOverlayStyle(systemUiOverlayStyle);
  } else {
    SystemUiOverlayStyle systemUiOverlayStyle = SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarBrightness: Brightness.dark,
        systemNavigationBarColor: Colors.black);
    SystemChrome.setSystemUIOverlayStyle(systemUiOverlayStyle);
  }
}

Future<Null> reportTrace(Object error, StackTrace stackTrace) {
  print("上报异常 error = $error，trace = $stackTrace.");
  return null;
}
