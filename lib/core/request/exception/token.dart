import 'package:dio/dio.dart';

class TokenException extends DioError {
  final String message;

  TokenException(this.message);

  @override
  String toString() {
    return message;
  }
}
