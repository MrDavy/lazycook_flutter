import 'dart:async';

import 'package:dio/dio.dart';

class ProgressInterceptor extends Interceptor {
  ProgressCallback onSendProgress;
  ProgressCallback onReceiveProgress;

  ProgressInterceptor({this.onSendProgress, this.onReceiveProgress});

  @override
  Future<dynamic> onRequest(RequestOptions options) async {
    if (onSendProgress != null) {
      options.onSendProgress = this.onSendProgress;
    }
    if (onReceiveProgress != null) {
      options.onReceiveProgress = this.onReceiveProgress;
    }
    return options;
  }

  @override
  Future<dynamic> onError(DioError err) async {
    return err;
  }

  @override
  Future<dynamic> onResponse(Response response) async {
    return response;
  }
}
