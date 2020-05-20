import 'package:flutter/material.dart';
import 'package:lazycook/core/viewmodels/base_model.dart';

enum RecipeListViewType { HISTORY_VIEW, LIST_VIEW }

/*
 * 搜索页面类型model，
 * 搜索历史、菜品列表
 */
class RecipeListViewTypeModel extends SampleModel {
  RecipeListViewType _viewType = RecipeListViewType.HISTORY_VIEW;

  RecipeListViewTypeModel({@required RecipeListViewType viewType}) {
    _viewType = viewType;
  }

  RecipeListViewType get viewType => _viewType;

  changeViewType(RecipeListViewType type) {
//    logger.log("changeViewType current type = $_viewType，type = $type");
    if (_viewType != type) {
      _viewType = type;
      setStateOnly();
    }
  }
}
