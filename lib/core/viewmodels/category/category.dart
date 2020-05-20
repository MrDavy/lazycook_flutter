import 'dart:math';

import 'package:flutter/material.dart';
import 'package:lazycook/core/models/category.dart';
import 'package:lazycook/core/models/result_data.dart';
import 'package:lazycook/core/request/local_repository.dart';
import 'package:lazycook/core/services/api.dart';
import 'package:lazycook/core/viewmodels/base_model.dart';
import 'package:lazycook/core/request/exception/error.dart';

import '../../../config/lazy_uri.dart';

///
/// @desc
/// @author davy
/// @date 2019/12/15 8:26 下午
///
class CategoryModel extends BaseModel {
  LocalRepository _repository;

  CategoryModel(
      {@required API api,
      @required LocalRepository localRepository})
      : super(api) {
    _repository = localRepository;
  }

  ChildCategoryModel _childCategoryModel = ChildCategoryModel();

  ChildCategoryModel get childCategoryModel => _childCategoryModel;

  List<CategoryRecord> _categories;

  List<CategoryRecord> get categories => _categories;

  CategoryRecord selectedRecord;

  LazyError _error;

  LazyError get error => _error;

  changeSelectedItem(index) {
    selectedRecord?.change(false);
    if (_categories?.isNotEmpty == true) {
      _categories[index].change(true);
      selectedRecord = _categories[index];
    }
    getChildCategories(selectedRecord.category.p_id);
  }

  ///大类
  Future getCategories() async {
    setState(ViewState.LOADING);
    _childCategoryModel.setState(ViewState.LOADING);
    ResultData result =
        await _repository.load("categories") ?? await api.categories();
    if (result.error != null) {
      _error = result.error;
      setState(ViewState.FAILED);
    } else {
      var data = (result.data as List<dynamic>);
      if (data?.isNotEmpty == true) {
        _categories =
            data.map((category) => CategoryRecord(category: category)).toList();
        if (_categories?.isNotEmpty == true) {
          selectedRecord = _categories[0];
          selectedRecord.selected = true;
          var children = selectedRecord.category.children;
          if (children?.isNotEmpty == true) {
            await LocalRepository.instance
                .save("child_cate_${selectedRecord.category.p_id}", children);
            _childCategoryModel.value(children);
          } else {
            getChildCategories(selectedRecord.category.p_id);
          }
        }
        setState(ViewState.SUCCESS);
      } else {
        setState(ViewState.EMPTY_DATA);
      }
    }
  }

  ///小类
  Future getChildCategories(pid) async {
    _childCategoryModel.setState(ViewState.LOADING);
    ResultData result = await _repository.load("child_cate_$pid") ??
        await api.childCategories({"pid": "$pid"});
    if (result.error != null) {
      _childCategoryModel.setError(result.error);
    } else {
      var childList = result.data;
      _childCategoryModel.value(childList);
    }
  }

  @override
  List<String> requests() {
    return [LazyUri.CATEGORIES, LazyUri.CHILD_CATEGORIES];
  }
}

class ChildCategoryModel extends SampleModel {
  List<Category> _categories;

  List<Category> get categories => _categories;

  LazyError _error;

  LazyError get error => _error;

  void setError(LazyError error) {
    _error = error;
    setState(ViewState.FAILED);
  }

  void value(List<Category> categories) {
    this._categories = categories;
    if (categories?.isNotEmpty == true) {
      setState(ViewState.SUCCESS);
    } else {
      setState(ViewState.EMPTY_DATA);
    }
  }
}

class CategoryRecord extends BaseChangeNotifier {
  Category _category;
  bool selected = false;

  change(bool select) {
    selected = select;
    notifyListeners();
  }

  CategoryRecord({@required Category category}) {
    this._category = category;
  }

  Category get category => _category;
}
