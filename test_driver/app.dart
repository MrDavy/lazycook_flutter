import 'package:flutter/cupertino.dart';
import 'package:flutter_driver/driver_extension.dart';

import 'package:lazycook/main.dart' as app;
import 'package:lazycook/ui/pages/home.dart';

void main() {
  // This line enables the extension
  enableFlutterDriverExtension();
  // Call the `main()` function of your app or call `runApp` with any widget you
  // are interested in testing.
  //这个地方可以测试整个应用，也可以测试应用的一部分
  app.main(); //测试整个应用
//  runApp(Home());//测试一部分
}
