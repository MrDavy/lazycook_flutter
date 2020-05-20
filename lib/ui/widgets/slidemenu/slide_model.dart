import 'package:dio/dio.dart';
import 'package:lazycook/core/viewmodels/base_model.dart';
import 'package:lazycook/ui/widgets/slidemenu/slide_item.dart';

enum OpenState { START, END, CLOSE, OPEN, MOVING }

class SlideNotifier extends BaseChangeNotifier {
  //向左滑动的最大距离
  double maxDistance = 0;

  //向右滑动的最大距离
  double minDistance = 0;

  //当前滑动的距离
  double _offset = 0;

  double get offset => _offset;

  double _endOffset = 0;

  double get endOffset => _endOffset;

  //滑动开始x位置
  double _startX = 0;

  double get startX => _startX;

  //当前滑动的x位置
  double _curX = 0;

  double get curX => _curX;

  //1，向左，2，向右
  int _direction = 1;

  int get direction => _direction;

  OpenState _lastState = OpenState.CLOSE;

  OpenState get lastState => _lastState;

  OpenState _openState = OpenState.CLOSE;

  OpenState get state => _openState;

  SlideNotifier();

  updateOffset(double offset) {
//    logger
//        .log("updateOffset 偏移：$offset，当前：$_offset，maxDistance = $maxDistance");
    _direction = offset >= 0 ? 2 : 1;
    this._offset += offset;
    this._offset = this._offset.clamp(maxDistance, minDistance);
    if (this._offset == minDistance) {
      _lastState = OpenState.CLOSE;
    } else if (this._offset == maxDistance) {
      _lastState = OpenState.OPEN;
    }
    var tmpState = this._offset == minDistance
        ? OpenState.CLOSE
        : this._offset == maxDistance ? OpenState.OPEN : OpenState.MOVING;
    if (!((tmpState == OpenState.OPEN && _openState == OpenState.OPEN) ||
        (tmpState == OpenState.CLOSE && _openState == OpenState.CLOSE))) {
      //logger.log(
      //    "updateOffset _offset = $_offset，maxDistance = $maxDistance，tmpState = $tmpState，_openState = $_openState");
      _openState = tmpState;
      notifyListeners();
    }
    _openState = tmpState;
  }

  onDragUpdate(offsetX) {
//    logger.log("onDragUpdate offsetX = $offsetX");
    _curX = offsetX;
  }

  //当抬起时，剩余的自动完成，需要记录当前已经滑动的距离
  onDragEnd() {
    _endOffset = this._offset;
//    logger.log("onDragEnd endOffset = $_endOffset");
  }

  onDragStart(offsetX) {
//    logger.log("onDragStart offsetX = $offsetX");
    this._startX = offsetX;
  }

  //手指滑动的距离
  double getMoveDx() {
    var dx = _curX - _startX;
    return dx >= 0 ? dx : dx * -1;
  }

  reset() {
    this._offset = 0;
    notifyListeners();
  }

  @override
  void dispose() {}
}
