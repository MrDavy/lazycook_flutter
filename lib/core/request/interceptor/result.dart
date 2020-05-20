import 'dart:async';

import 'package:dio/dio.dart';
import 'package:lazycook/core/request/exception/error.dart';
import 'package:lazycook/utils/logger.dart';

class ResultInterceptor extends Interceptor {
  var logger = Logger("ResultInterceptor");

  String _params(FormData formData) {
    if (formData == null) return "null";
    var list = formData?.fields;
    StringBuffer params = StringBuffer();
    for (MapEntry<String, String> param in list) {
      params.write("${param.key}:${param.value}，");
    }
    return params.toString();
  }

  @override
  Future onRequest(RequestOptions options) async {
    logger.log(
        "发送请求：${options.uri}，参数：${_params(options.data)}头：${options.headers.toString()}");
    return super.onRequest(options);
  }

  @override
  Future onError(DioError err) async {
    return LazyError(code: LazyError.SYSTEM_ERROR, message: err.message);
  }

  @override
  Future<dynamic> onResponse(Response response) async {
//    Result resultData = Result.fromJson(jsonDecode(response.data));
//    return resultData;
//    if (resultData != null) {
//      if (resultData.code == 0) {
//        return resultData.data;
//      } else if (resultData.code == 1002) {
//        throw Error('需要登录');
//      } else {
//        throw Error(resultData.msg);
//      }
//    }
    var date = DateTime.now();
    logger.log(
        "接收请求：${response.request.path}，${date.minute}:${date.second}:${date.millisecond}");
    return super.onResponse(response);
  }
}
