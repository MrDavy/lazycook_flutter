import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:lazycook/core/models/page.dart';
import 'package:lazycook/core/models/result_data.dart';
import 'package:lazycook/core/request/exception/error.dart';
import 'package:lazycook/core/services/api.dart';
import 'package:lazycook/utils/logger.dart';

enum ViewState {
  IDLE, //空闲状态
  LOADING, //加载中
  SUCCESS, //加载成功
  FAILED, //非第一页数据失败，场景：分页列表，则弹窗提示；详情或其他页，提供重试
  EMPTY_DATA, //成功了，但没有数据
}

class BaseChangeNotifier extends ChangeNotifier {
  Logger logger;

  BaseChangeNotifier() {
    logger = Logger(this.runtimeType.toString());
  }
}

abstract class _BaseApiModel extends BaseChangeNotifier {
  API _api;

  _BaseApiModel(API api) {
    _api = api;
  }

  API get api => _api;

  @override
  void dispose() {
    requests()?.forEach((request) {
      _api?.cancel(request);
    });
  }

  List<String> requests();
}

class SampleModel extends BaseChangeNotifier {
  ViewState _state = ViewState.IDLE;

  ViewState get state => _state;

  LazyError error;

  String _loadingMsg = "";

  String get loadingMsg => _loadingMsg;

  setState(ViewState state) {
    _state = state ?? ViewState.LOADING;
    error = null;
    notifyListeners();
  }

  setStateOnly() {
    notifyListeners();
  }

  setStateWithMsg(ViewState state, String loadingMsg) {
    _state = state ?? ViewState.LOADING;
    _loadingMsg = loadingMsg ?? "";
    notifyListeners();
  }

  bool checkResult(ResultData resultData) {
    return resultData != null &&
        resultData.error == null &&
        resultData.data != null;
  }
}

abstract class BaseModel extends _BaseApiModel {
  ViewState _state = ViewState.IDLE;

  BaseModel(API api) : super(api);

  ViewState get state => _state;

  LazyError error;

  String _loadingMsg = "";

  String get loadingMsg => _loadingMsg;

  setState(ViewState state) {
    _state = state ?? ViewState.LOADING;
    error = null;
    notifyListeners();
  }

  setStateOnly() {
    notifyListeners();
  }

  setStateWithMsg(ViewState state, String loadingMsg) {
    _state = state ?? ViewState.LOADING;
    _loadingMsg = loadingMsg ?? "";
    notifyListeners();
  }

  bool _checkResult(ResultData resultData) {
    return resultData != null &&
        resultData.error == null &&
        resultData.data != null;
  }
}

enum PageViewState {
  IDLE, //空闲状态
  LOADING, //加载中
  SUCCESS, //加载成功
  FAILED, //非第一页数据失败，场景：分页列表，则弹窗提示；详情或其他页，提供重试
  EMPTY_DATA, //成功了，但没有数据
  NO_MORE_DATA, //非第一页数据加载成功了，但没有数据
  FIRST_PAGE_LOADING, //第一次加载中
  FIRST_PAGE_LOAD_FAILED, //第一页加载失败，提供重试
}

abstract class BasePagerModel<T> extends _BaseApiModel {
  PageViewState _state = PageViewState.IDLE;

  BasePagerModel(API api) : super(api);

  PageViewState get state => _state;

  String _loadingMsg = "";

  String get loadingMsg => _loadingMsg;

  LazyError _error;

  LazyError get error => _error;

  int _currentPage = 0;

  int get page => _currentPage;

  int pageSize = 10;

  bool _hasNext = false;

  bool get hasNext => _hasNext;

  setState(PageViewState state) {
    _state = state ?? PageViewState.LOADING;
    notifyListeners();
  }

  setStateWithMsg(ViewState state, String loadingMsg) {
    _state = state ?? PageViewState.LOADING;
    _loadingMsg = loadingMsg ?? "";
    notifyListeners();
  }

  Future refresh({bool init = false, Map<String, dynamic> params}) async {
    if (params == null) params = HashMap();
    if (_currentPage < 0) _currentPage = 0;
    if (init || _currentPage == 0) {
      setState(PageViewState.FIRST_PAGE_LOADING);
      await initial();
    }
    var _pageData;
    try {
      _pageData = await loadData({...params, "page": "${++_currentPage}"});
    } catch (error) {
      logger.log("系统错误：${error}");
      _pageData = PageData(error: LazyError(message: "系统错误"));
    }
    if (_pageData?.error != null) {
      logger.log("${_pageData?.error?.message}");
      this._error = _pageData?.error;
      if (this._currentPage > 1) {
        _currentPage--;
//        Fluttertoast.showToast(msg: "${_error?.message}");
        return Future.error(this._error);
      } else {
        _currentPage--;
        setState(PageViewState.FIRST_PAGE_LOAD_FAILED);
      }
    } else {
      if (_pageData?.items?.length == 0) {
        if (_currentPage == 1) {
          //第一页没有数据
          setState(PageViewState.EMPTY_DATA);
        } else if (_currentPage > 1) {
          setState(PageViewState.NO_MORE_DATA);
        }
        _currentPage--;
      } else {
        _hasNext = _pageData?.hasNext;
        await onComplete(_pageData?.items);
        setState(PageViewState.SUCCESS);
      }
    }
  }

  onDataChanged() {}

  Future initial() async {
    this._loadingMsg = "";
    this._currentPage = 0;
  }

  Future onComplete(List<T> list);

  Future<PageData<T>> loadData(params);
}
