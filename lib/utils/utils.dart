import 'dart:convert';
import 'dart:ui';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:lazycook/utils/string_utils.dart';
import 'package:package_info/package_info.dart';
import 'package:url_launcher/url_launcher.dart';

class Utils {
  static openWebOut(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  static num statusBarHeight(context) {
    EdgeInsets padding = MediaQuery.of(context).padding;
    return math.max(padding.top, EdgeInsets.zero.top);
  }

  static Future getPackageInfo() {
    return PackageInfo.fromPlatform();
  }

  static double getWidth() {
    return window.physicalSize.width;
  }

  static String convertMapToJson(Map<String, dynamic> params) {
    if (params == null) return null;
    String jsonString = json.encode(params);
    return jsonEncode(Utf8Encoder().convert(jsonString)); //转换为Utf8编码格式，防止含有中文出差
  }

  static Map<String, dynamic> convertJsonToMap(String jsonStr) {
    if (StringUtils.isEmpty(jsonStr)) return null;
    var list = List<int>();

    ///字符串解码
    jsonDecode(jsonStr).forEach(list.add);
    final String value = Utf8Decoder().convert(list);
    return json.decode(value);
  }

  static bool validatePhone(phone) {
    return RegExp(
            "^((13[0-9])|(14[5,7])|(15[0-3,5-9])|(17[0,3,5-8])|(18[0-9])|166|198|199|(147))\\d{8}\$")
        .hasMatch(phone);
  }
}
