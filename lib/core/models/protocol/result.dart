///统一处理接口结果
class Result {
  int code;
  String msg;

  dynamic data;

  dynamic extra;

  Result(this.code, this.msg, this.data, this.extra);

  factory Result.fromJson(Map<String, dynamic> json) => Result(
      json['code'] as int, json['msg'] as String, json['data'], json['extra']);

  Map<String, dynamic> toJson() => <String, dynamic>{
        'code': this.code,
        'msg': this.msg,
        'data': this.data,
        'extra': this.extra
      };

  @override
  String toString() {
    return 'Result{code: $code, msg: $msg, data: $data, extra: $extra}';
  }
}
