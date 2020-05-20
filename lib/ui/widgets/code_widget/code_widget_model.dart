import 'package:flutter/material.dart';
import 'package:lazycook/core/viewmodels/base_model.dart';
import 'package:lazycook/utils/string_utils.dart';

enum NumType { NUM, LINE, NONE }

class Num {
  NumType type;
  String num;

  Num(this.type, this.num);

  @override
  String toString() {
    return 'Num{type: $type, num: $num}';
  }
}

class CodeWidgetModel extends BaseChangeNotifier {
  final int count;
  List<Num> _nums = [];

  List<Num> get nums => _nums;

  CodeWidgetModel(this.count) {
    for (int index = 0; index < count; index++) {
      _nums.add(Num(index == 0 ? NumType.LINE : NumType.NONE, ""));
    }
  }

  String _text;

  updateText(text) {
    this._text = text;
    _initNums();
    if (StringUtils.isNotEmpty(_text)) {
      var length = _text.length;
      for (int i = 0; i < length; i++) {
        var code = _text[i];
        _nums[i].num = "$code";
        _nums[i].type = NumType.NUM;
      }
      if (length < count && length > 0) {
        _nums[length].type = NumType.LINE;
      }
    }

    notifyListeners();
  }

  void _initNums() {
    for (int index = 0; index < count; index++) {
      _nums[index].type = index == 0 ? NumType.LINE : NumType.NONE;
      _nums[index].num = "";
    }
  }
}
