import 'package:flutter/material.dart';
import 'package:lazycook/core/models/dish.dart';
import 'package:lazycook/core/models/dish_page.dart';
import 'package:lazycook/core/models/page.dart';
import 'package:lazycook/core/models/result_data.dart';
import 'package:lazycook/core/services/api.dart';
import 'package:lazycook/core/viewmodels/base_model.dart';
import 'package:lazycook/core/request/exception/error.dart';
import '../../../../config/lazy_uri.dart';
class DishCharacter extends ChangeNotifier {
  Dish _dish;

  DishCharacter({@required Dish dish}) {
    _dish = dish;
  }

  Dish get dish => _dish;
}

class RecipeListModel extends BasePagerModel<Dish> {
  RecipeListModel(API api) : super(api);

  List<DishCharacter> _list;

  List<DishCharacter> get list => _list;

  @override
  List<String> requests() {
    return [LazyUri.SEARCH_DISHES];
  }

  @override
  Future initial() {
    this._list?.clear();
    return super.initial();
  }

  @override
  Future<PageData<Dish>> loadData(params) async {
    ResultData result = await api.searchDishs(params);
    DishPage data = result?.data;
    return PageData<Dish>(
        hasNext: data?.hasNext,
        items: data?.items,
        pageNum: data?.pageNum,
        pageSize: data?.pageSize,
        totalNum: data?.totalNum,
        totalPage: data?.totalPage,
        error: result?.error);
  }

  @override
  Future onComplete(List<Dish> list) {
    if (this._list == null) {
      this._list = [];
    }
    this._list.addAll(list.map((dish) => DishCharacter(dish: dish)));
    return null;
  }
}
