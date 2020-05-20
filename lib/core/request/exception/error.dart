import 'package:dio/dio.dart';

///自定义错误
class LazyError implements Exception {
  static const int SYSTEM_ERROR = 1001;

  final String message;
  final int code;
  final dynamic extra;

  LazyError({this.message, this.code, this.extra});

  @override
  String toString() {
    return 'Error{message: $message, code: $code, extra: $extra}';
  }
}
