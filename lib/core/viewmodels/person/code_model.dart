import 'dart:async';

import 'package:lazycook/config/lazy_uri.dart';
import 'package:lazycook/core/services/api.dart';
import 'package:lazycook/core/viewmodels/base_model.dart';

class CodeModel extends BaseModel {
  Timer timer;

  int _time = -1;

  CodeModel(API api) : super(api);

  int get time => _time;

  set time(int time) {
    _time = time;
    notifyListeners();
  }

  Future sendMsg(params) async {
    return api.authCode(params);
  }

  Future countDown(int total) async {
    _time = total;
    timer = Timer.periodic(Duration(seconds: 1), (timer) {
      notifyListeners();
      _time--;
      if (_time < 0) {
        cancel();
      }
    });
  }

  void cancel() {
    timer?.cancel();
    _time = -1;
  }

  @override
  void dispose() {
    cancel();
  }

  @override
  List<String> requests() {
    return [LazyUri.AUTH_CODE];
  }
}
