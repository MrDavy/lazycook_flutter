import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:lazycook/application.dart';

class AuthInterceptor extends Interceptor {
  @override
  Future<dynamic> onRequest(RequestOptions options) async {
    Map<String, dynamic> headers =
        options.headers == null ? Map() : options.headers;
    headers["platform"] = Platform.operatingSystem == "android" ? "1" : "2";
    headers['version'] = Application.packageInfo?.version ?? "0.0.0";
    options.headers = headers;
    return options;
  }
}
