import 'package:flutter/foundation.dart';
import 'package:lazycook/core/services/api.dart';
import 'package:lazycook/core/viewmodels/base_model.dart';
import 'package:lazycook/ui/widgets/slidemenu/slide_item.dart';

class ListItem<T> extends BaseChangeNotifier {
  T _data;
  SlideController controller;

  ListItem({@required T data}) {
    this._data = data;
  }

  T get data => _data;
}

abstract class SlideListModel<T> extends BasePagerModel<T> {
  List<ListItem<T>> _list = [];

  SlideListModel(API api) : super(api);

  List<ListItem<T>> get list => _list;

  int _openedPos = -1;

  int get openedPos => _openedPos;

  bool onDataSetChanged = false;

  @override
  Future initial() {
    this._list?.clear();
    return super.initial();
  }

  //记录打开的item下标
  void open(index) {
//    logger.log("打开的item下标：$index");
    this._openedPos = index;
  }

  //记录关闭的item下标
  void close(index) {
    if (this._openedPos == index) {
      this._openedPos = -1;
    }
  }

  void closeLast() {
//    logger.log("closeLast index = $_openedPos");
    if (_openedPos != -1) {
      //logger.log("closeLast index = $_openedPos");
      var controller = _list[_openedPos]?.controller;
//      logger.log("closeLast contorller = ${controller.index}");
      _openedPos = -1;
      controller?.close();
    }
  }

  void closeImmediately() {
    if (_openedPos != -1) {
      _list[_openedPos].controller?.closeImmediately();
      _openedPos = -1;
    }
  }

  addAll(List<T> list) {
    (_list ?? []).addAll(list?.map((data) => ListItem(data: data)));
  }

  add(T item) {
    (_list ?? []).add(ListItem(data: item));
  }

  readyToChange() {
    onDataSetChanged = false;
  }

  remove(index) {
    onDataSetChanged = true;
    _list.removeAt(index);
  }
}
