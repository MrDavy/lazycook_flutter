import 'package:flutter/material.dart';

class ScrollModel extends ChangeNotifier {
  final num distance;

  ScrollModel(this.distance) {
    _height = distance;
  }

  ///占比
  double _proportion=0;

  double get proportion => _proportion;

  ///偏移的距离
  var _offset = 0.0;

  double get offset => _offset;

  ///剩余距离
  double _height = 0;

  double get height => _height;

  change(offset) {
    _offset = offset;
    _height = distance - _offset;
    _height = _height.clamp(0, distance);
    _proportion = _offset / (distance / 2);
    _proportion = _proportion.clamp(0.0, 1.0);
    notifyListeners();
  }
}
