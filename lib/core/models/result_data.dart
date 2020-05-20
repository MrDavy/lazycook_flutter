import 'package:lazycook/core/request/exception/error.dart';

class ResultData<T> {
  T data;
  LazyError error;
  int code;

  ResultData({this.data, this.error, this.code});

  @override
  String toString() {
    return 'ResultData{data: $data, error: $error}';
  }
}
