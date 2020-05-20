import 'dart:async';

import 'package:lazycook/core/viewmodels/base_model.dart';

class CodeModel extends SampleModel {
  Timer timer;

  int _time = -1;

  int get time => _time;

  set time(int time) {
    _time = time;
    notifyListeners();
  }

  Future sendMsg(params) async {
    countDown(120);
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
}
