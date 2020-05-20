import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:lazycook/core/models/dish.dart';
import 'package:lazycook/core/models/dish_page.dart';
import 'package:lazycook/core/models/page.dart';
import 'package:lazycook/core/models/result_data.dart';
import 'package:lazycook/core/request/exception/error.dart';
import 'package:lazycook/core/services/api.dart';
import 'package:lazycook/core/viewmodels/base_model.dart';
import 'package:lazycook/ui/widgets/slidemenu/slide_item.dart';
import '../../../config/lazy_uri.dart';

class CollectedDish extends BaseChangeNotifier {
  Dish _dish;
  SlideController controller;

  CollectedDish({@required Dish dish}) {
    this._dish = dish;
  }

  Dish get dish => _dish;
}

class CollectionModel extends BasePagerModel<Dish> {
  CollectionModel(API api) : super(api);

  List<CollectedDish> _list;

  List<CollectedDish> get list => _list;

  int _openedPos = -1;

  int get openedPos => _openedPos;

  bool uncollected = false;

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

  @override
  Future initial() {
    this._list?.clear();
    return super.initial();
  }

  Future delCollection(index) async {
    uncollected = false;
    var result =
        await api.collect({"did": "${_list[index].dish.id}", "action": "2"});
    if (result != null && result is LazyError) {
      ///取消失败
      logger.log("取消失败");
    } else {
      ///取消成功
      logger.log("取消成功");
      uncollected = true;
      remove(index);
      if (_list?.length == 0) {
        setState(PageViewState.EMPTY_DATA);
      } else {
        setState(PageViewState.SUCCESS);
      }
    }
    return result;
  }

  remove(index) {
    _list.removeAt(index);
  }

  @override
  Future<PageData<Dish>> loadData(params) async {
    ResultData result = await api.collectionList(params);
    DishPage data = result?.data;
    return PageData<Dish>(
        hasNext: data?.hasNext,
        items: data?.items,
        pageNum: data?.pageNum,
        pageSize: data?.pageSize,
        totalNum: data?.totalNum,
        totalPage: data?.totalPage ?? 0,
        error: result?.error);
  }

  @override
  Future onComplete(List<Dish> list) {
    if (this._list == null) this._list = [];
    this._list?.addAll(list?.map((dish) => CollectedDish(dish: dish)) ?? []);
    return null;
  }

  @override
  List<String> requests() {
    return [LazyUri.COLLECTION_LIST];
  }
}
