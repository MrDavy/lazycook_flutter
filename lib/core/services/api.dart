import 'dart:collection';
import 'dart:math';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:lazycook/core/models/banner.dart';
import 'package:lazycook/core/models/category.dart';
import 'package:lazycook/core/models/dish.dart';
import 'package:lazycook/core/models/dish_page.dart';
import 'package:lazycook/core/models/home_info.dart';
import 'package:lazycook/core/models/result_data.dart';
import 'package:lazycook/core/models/search_info.dart';
import 'package:lazycook/core/models/user.dart';
import 'package:lazycook/core/models/version_info.dart';
import 'package:lazycook/core/request/exception/error.dart';
import 'package:lazycook/core/request/local_repository.dart';
import 'package:lazycook/core/request/server.dart';
import 'package:lazycook/core/viewmodels/person/login/user_model.dart';
import 'package:lazycook/utils/cache.dart';
import 'package:lazycook/utils/logger.dart';

import '../../config/lazy_uri.dart';

///服务器接口
class API {
  Server server;
  Logger logger;
  HashMap<String, CancelToken> tokens = HashMap();

  ///用户信息，用于需要token校验的接口
  UserModel _userModel;

  UserModel get userModel => _userModel;

  API({@required UserModel userModel}) {
    this._userModel = userModel;
    server = Server.instance;
    logger = Logger(runtimeType.toString());
    tokens?.clear();
  }

  ///注册
  Future register(params, [CancelToken cancelToken]) async =>
      await _simpleWrap(LazyUri.REGISTER, params, cancelToken);

  ///登录1.验证码登录 2.密码登录
  Future login(params, [CancelToken cancelToken]) async {
    var result = await _wrap(LazyUri.LOGIN, params, cancelToken);
    if (result.data != null) {
      User user = User.fromJson(result.data);
      if (user != null) {
        _userModel?.saveUser(user);
      }
      return null;
    } else {
      return result.error;
    }
  }

  ///登出
  Future logout([CancelToken cancelToken]) async {
    var result = await _simpleWrap(LazyUri.LOGOUT, null, cancelToken);
    if (result == null) {
      await _userModel?.clearUser();
    }
    return result;
  }

  ///更新头像
  Future updateAvatar(params, [CancelToken cancelToken]) async {
    var result = await _simpleWrap(LazyUri.AVATAR_UPDATE, params, cancelToken);
    if (result == null) {
      _userModel?.user?.portrait = params["avatar"];
      await _userModel?.saveUser(_userModel?.user);
    }
    return result;
  }

  ///更新昵称
  Future updateNickName(params, [CancelToken cancelToken]) async {
    var result =
        await _simpleWrap(LazyUri.NICKNAME_UPDATE, params, cancelToken);
    if (result == null) {
      _userModel?.user?.nikename = params["nickname"];
      await _userModel?.saveUser(_userModel?.user);
    }
    return result;
  }

  ///校验验证码
  Future codeValidate(params, [CancelToken cancelToken]) async {
    return await _simpleWrap(LazyUri.CODE_VALIDATE, params, cancelToken);
  }

  ///找回密码
  Future resetPwd(params, [CancelToken cancelToken]) {
    return _simpleWrap(LazyUri.RESET_PWD, params, cancelToken);
  }

  ///验证码1：注册，2：登录，3：重置密码
  Future authCode(params, [CancelToken cancelToken]) async =>
      await _simpleWrap(LazyUri.AUTH_CODE, params, cancelToken);

  ///首页基本信息(包括推荐搜索关键字，未读消息数量，能不能新增)
  Future getHomeBasicInfo([CancelToken cancelToken]) async {
    var result = await _wrap(LazyUri.HOME_BASIC_INFO, null, cancelToken);
    return ResultData(
        data: result.data != null ? HomeBasicInfo.fromJson(result.data) : null,
        error: result.error);
  }

  ///广告图
  Future banners([CancelToken cancelToken]) async {
    var result = await _wrap(LazyUri.HOME_BANNERS, null, cancelToken);
    return ResultData<HomeBanner>(
        data: result.data != null ? HomeBanner.fromJson(result.data) : null,
        error: result.error);
  }

  ///首页分类
  Future homeCategory([CancelToken cancelToken]) async {
    var result = await _wrap(LazyUri.HOME_CATEGORIES, null, cancelToken);
    var list = result.data;
    if (list != null && list is List) {
      var data = list.map((item) => (Category.fromJson(item))).toList();
      return ResultData(data: data, error: result.error);
    } else {
      return ResultData(data: [], error: result.error);
    }
  }

  ///首页推荐菜品
  Future recommendDishes(params, [CancelToken cancelToken]) async {
    var result = await _wrap(LazyUri.RECOMMEND_DISHES, params, cancelToken);
    return ResultData(
        data: result.data != null ? DishPage.fromJson(result.data) : null,
        error: result.error);
  }

  ///搜索信息，如搜索历史、推荐搜索
  Future searchInfo([CancelToken cancelToken]) async {
    var result = await _wrap(LazyUri.RECIPE_SEARCH_HISTORY, null, cancelToken);
    return ResultData(
        data: result.data != null ? SearchInfo.fromJson(result.data) : null,
        error: result.error);
  }

  ///删除搜索历史
  Future deleteSearchHistory(params, [CancelToken cancelToken]) {
    return _simpleWrap(LazyUri.DELETE_SEARCH_HISTORY, params, cancelToken);
  }

  ///搜索菜品
  Future searchDishs(params, [CancelToken cancelToken]) async {
    var result = await _wrap(LazyUri.SEARCH_DISHES, params, cancelToken);
    return ResultData(
        data: result.data != null ? DishPage.fromJson(result.data) : null,
        error: result.error);
  }

  ///菜品详情
  Future dishDetail(params, [CancelToken cancelToken]) async {
    var result =
        await _wrap(LazyUri.DISH_DETAIL, params, cancelToken ?? CancelToken());
    return ResultData(
        data: result.data != null ? Dish.fromJson(result.data) : null,
        error: result.error);
  }

  ///菜品收藏、取消：1：收藏，0：取消收藏
  Future collect(params, [CancelToken cancelToken]) async {
    return _simpleWrap(LazyUri.COLLECT, params, cancelToken ?? CancelToken());
  }

  ///菜品分类，大类
  Future categories([CancelToken cancelToken]) async {
    var result =
        await _wrap(LazyUri.CATEGORIES, null, cancelToken ?? CancelToken());
    var list = result.data;
    if (list != null && list is List) {
      var data = list.map((item) => (Category.fromJson(item))).toList();
      await LocalRepository.instance.save("categories", data);
      return ResultData(data: data, error: result.error);
    } else {
      return ResultData(data: [], error: result.error);
    }
  }

  ///菜品分类，小类
  Future childCategories(params, [CancelToken cancelToken]) async {
    var result = await _wrap(
        LazyUri.CHILD_CATEGORIES, params, cancelToken ?? CancelToken());
    var list = result.data;
    if (list != null && list is List) {
      var data = list.map((item) => (Category.fromJson(item))).toList();
      await LocalRepository.instance.save("child_cate_${params["pid"]}", data);
      return ResultData(data: data, error: result.error);
    } else {
      return ResultData(data: [], error: result.error);
    }
  }

  ///收藏列表
  Future collectionList(params, [CancelToken cancelToken]) async {
    var result = await _wrap(
        LazyUri.COLLECTION_LIST, params, cancelToken ?? CancelToken());
    return ResultData(
        data: result.data != null ? DishPage.fromJson(result.data) : null,
        error: result.error);
  }

  ///作品列表
  Future workList(params, [CancelToken cancelToken]) async {
    var result =
        await _wrap(LazyUri.WORK_LIST, params, cancelToken ?? CancelToken());
    return ResultData(
        data: result.data != null ? DishPage.fromJson(result.data) : null,
        error: result.error);
  }

  ///删除作品
  Future delWork(params, [CancelToken cancelToken]) async {
    var result =
        await _wrap(LazyUri.DELETE_WORK, params, cancelToken ?? CancelToken());
    return ResultData(error: result.error);
  }

  ///新建作品
  Future addWork(params, [CancelToken cancelToken]) async {
    var result =
        await _wrap(LazyUri.NEW_WORK, params, cancelToken ?? CancelToken());
    return ResultData(error: result.error);
  }

  ///意见反馈
  Future feedback(params, [CancelToken cancelToken]) async {
    return _simpleWrap(LazyUri.FEEDBACK, params, cancelToken ?? CancelToken());
  }

  ///检查版本更新
  Future version([CancelToken cancelToken]) async {
    var result =
        await _wrap(LazyUri.VERSION, null, cancelToken ?? CancelToken());
    return ResultData(
        data: result.data != null ? VersionInfo.fromJson(result.data) : null,
        error: result.error);
  }

  ///图片上传
  ///        1 -> albumPath
  ///        2 -> stepPath
  ///        3 -> commentPath
  ///        4 -> portraitPath
  Future uploadImage(params, List<String> files,
      [CancelToken cancelToken]) async {
    var result = await _wrap(LazyUri.IMG_UPLOAD, params, cancelToken, files);
    return ResultData(
        data: result.data != null ? List<String>.from(result.data) : null,
        error: result.error);
  }

  Future _simpleWrap(url, params, cancelToken) async {
    LazyError _error;
    try {
      tokens[url] = cancelToken ?? CancelToken();
      var headers = Map<String, dynamic>();
      if (_userModel?.hasUser == true) {
        headers["token"] = _userModel.user?.token ?? "";
      }
      var result = await server.post(url, params, cancelToken, headers);
      tokens?.remove(url);
      _error = result['error'];
    } catch (e) {
      _error = LazyError(message: "系统错误");
    }
    return _error;
  }

  Future<ResultData<dynamic>> _wrap(url, params, cancelToken,
      [List<String> files]) async {
    try {
      tokens[url] = cancelToken ?? CancelToken();
      var headers = Map<String, dynamic>();
      if (_userModel?.hasUser == true) {
        headers["token"] = _userModel.user?.token ?? "";
      }
      var result = await server.post(url, params, cancelToken, headers, files);
      tokens?.remove(url);
      return ResultData(data: result['data'], error: result['error']);
    } catch (e) {
      logger.log("系统错误：e=$e");
      return ResultData(error: LazyError(message: "系统错误"));
    }
  }

  void cancel(String key) {
    try {
      var token = tokens[key];
      if (token?.isCancelled == false) {
        token?.cancel("中断请求");
        logger.log("$key请求中断成功！");
      }
      tokens?.remove(key);
    } catch (e) {
      logger.log("$key请求中断失败！");
    }
  }

  void dispose() {
    try {
      tokens?.forEach((key, token) {
        if (token?.isCancelled == false) {
          token?.cancel();
        }
      });
    } catch (e) {
      logger.log("e = $e");
    }
    tokens?.clear();
  }
//  Future awaitWrap(Future future) => future
//      .then((data) => ({'data': data}))
//      .catchError((err) => ({'error': err}));
}
