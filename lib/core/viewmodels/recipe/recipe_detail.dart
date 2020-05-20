import 'dart:math';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:lazycook/core/models/dish.dart';
import 'package:lazycook/core/models/result_data.dart';
import 'package:lazycook/core/request/exception/error.dart';
import 'package:lazycook/core/services/api.dart';
import 'package:lazycook/core/viewmodels/base_model.dart';
import 'package:meta/meta.dart';
import '../../../config/lazy_uri.dart';

/*
 *  菜品详情信息
 */
class RecipeDetailModel extends BaseModel {
  RecipeDetailModel({@required API api}) : super(api);

  Dish _dish;

  Dish get dish => _dish;

  Future getDishDetail(params) async {
    setState(ViewState.LOADING);
    ResultData result = await api.dishDetail(params);
    if (result.error != null) {
      error = result.error;
      setState(ViewState.FAILED);
    } else {
      this._dish = result.data;
      setState(ViewState.SUCCESS);
    }
  }

  Future collect(did, action) async {
    var result = await api.collect({"did": "$did", "action": "$action"});
    logger.log("收藏：result = $result");
    if (result == null) {
      _dish.hasCollected = action == "1" ? 1 : 0;
      _dish.statistic.collected += _dish.hasCollected == 1 ? 1 : -1;
      setState(ViewState.SUCCESS);
    }
    return result;
  }

  @override
  List<String> requests() {
    return [LazyUri.DISH_DETAIL, LazyUri.COLLECT];
  }
}
