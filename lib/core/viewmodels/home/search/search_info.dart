import 'package:flutter/material.dart';
import 'package:lazycook/core/models/dish.dart';
import 'package:lazycook/core/models/dish_page.dart';
import 'package:lazycook/core/models/result_data.dart';
import 'package:lazycook/core/models/search_info.dart';
import 'package:lazycook/utils/const.dart';
import 'package:lazycook/utils/logger.dart';
import 'package:lazycook/utils/preference_utils.dart';
import 'package:lazycook/utils/string_utils.dart';
import 'package:meta/meta.dart';
import 'package:lazycook/core/services/api.dart';
import 'package:lazycook/core/viewmodels/base_model.dart';
import 'package:lazycook/core/request/exception/error.dart';
import 'dart:convert';
import '../../../../config/lazy_uri.dart';

///
/// @desc 搜索历史与推荐
/// @author Davy
/// @date 2019/8/20 14:51
///

class SearchInfoModel extends BaseModel {
  SearchInfoModel({@required API api}) : super(api);

  //历史记录删除状态
  bool _deleting = false;

  bool get deleting => _deleting;

  LazyError _searchError;

  LazyError get searchError => _searchError;

  List<SearchBaseInfo> _localHistory;

  History history;

  Recommend recommend;

  void addHistory(String value) {}

  changeOptType(bool deleting) {
    if (_deleting != deleting) {
      _deleting = deleting;
      notifyListeners();
    }
  }

  changeOptTypeOnly(bool deleting) {
    if (_deleting != deleting) {
      _deleting = deleting;
    }
  }

  Future getSearchInfo() async {
    logger.log("getSearchInfo hasUser = ${api.userModel.hasUser}");
    history = null;
    recommend = null;
    setState(ViewState.LOADING);
    if (api.userModel.hasUser) {
      bool hasSaved = await PreferenceUtils.containsKey(KEY_SEARCH_INFO);
      if (hasSaved) {
        var json = await PreferenceUtils.getString(KEY_SEARCH_INFO, null);
        if (StringUtils.isEmpty(json)) {
          setState(ViewState.FAILED);
        } else {
          SearchInfo _searchInfo = SearchInfo.fromJson(jsonDecode(json));
          if (_searchInfo?.history?.isNotEmpty == true) {
            history = History(api, _searchInfo.history);
          }
          if (_searchInfo?.recommend?.isNotEmpty == true) {
            recommend = Recommend(_searchInfo.recommend);
          }
          if (history == null && recommend == null) {
            setState(ViewState.EMPTY_DATA);
          } else {
            setState(ViewState.SUCCESS);
          }
        }
      } else {
        ResultData result = await api.searchInfo();
        if (result.error != null) {
          setState(ViewState.FAILED);
        } else {
          SearchInfo _searchInfo = result.data;
          if (_searchInfo?.history?.isNotEmpty == true) {
            history = History(api, _searchInfo.history);
          }
          if (_searchInfo?.recommend?.isNotEmpty == true) {
            recommend = Recommend(_searchInfo.recommend);
          }
          if (history == null && recommend == null) {
            setState(ViewState.EMPTY_DATA);
          } else {
//            PreferenceUtils.saveStringExpired(
//                KEY_SEARCH_INFO, jsonEncode(_searchInfo), 1 * 60);
            setState(ViewState.SUCCESS);
          }
        }
      }
    } else {
      history = History(api, []);
      setState(ViewState.EMPTY_DATA);
    }
  }

  @override
  void dispose() {
    api?.cancel("searchInfo");
  }

  @override
  List<String> requests() {
    return [LazyUri.RECIPE_SEARCH_HISTORY];
  }
}

//搜索推荐
class Recommend extends ChangeNotifier {
  List<SearchBaseInfo> _list;

  Recommend(this._list);

  List<SearchBaseInfo> get list => _list;

  set(List<SearchBaseInfo> recommend) {
    _list = recommend;
  }
}

//搜索历史
class History extends BaseModel {
  //是否现实全部
  bool _all = false;

  //搜索历史
  List<SearchBaseInfo> _list;

  History(API _api, this._list) : super(_api);

  bool get showAll => _all;

  List<SearchBaseInfo> get list => _list;

  set(List<SearchBaseInfo> history) {
    _list = history;
  }

  setShowAll(bool all) {
    if (all != _all) {
      _all = all;
      notifyListeners();
    }
  }

  Future delete(int index) async {
    var info = _list[index];
    var result = await api.deleteSearchHistory({"hid": info.id});
    if (result == null) {
      _list.removeAt(index);
      notifyListeners();
    }
    return result;
  }

  @override
  List<String> requests() {
    return [LazyUri.DELETE_SEARCH_HISTORY];
  }
}
