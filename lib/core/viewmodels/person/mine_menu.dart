import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:lazycook/core/models/menu.dart';
import 'package:lazycook/core/models/protocol/result.dart';
import 'package:lazycook/core/services/api.dart';
import 'package:lazycook/core/viewmodels/base_model.dart';

///
/// @desc
/// @author davy
/// @date 2020/1/1 9:04 下午
///
class MineMenuModel extends BaseModel {
  MineMenuModel({@required API api}) : super(api);

  var json =
      "{\"code\":0,\"data\":[{\"title\":\"我的收藏\",\"key\":\"/person/collection\",\"sort\":1,\"needLogin\":true,\"enable\":true,\"icon\":\"collection\"},{\"title\":\"我的作品\",\"key\":\"/person/works\",\"sort\":2,\"needLogin\":true,\"enable\":true,\"icon\":\"works\"},{\"title\":\"意见反馈\",\"key\":\"/person/service\",\"sort\":6,\"needLogin\":false,\"enable\":true,\"icon\":\"service\"},{\"title\":\"关于我们\",\"key\":\"/person/about\",\"sort\":7,\"needLogin\":false,\"enable\":true,\"icon\":\"us\"},{\"title\":\"设置\",\"key\":\"/person/settings\",\"sort\":8,\"needLogin\":false,\"enable\":true,\"icon\":\"setting\"}],\"msg\":\"success\"}";

//      "{\"code\":0,\"data\":[{\"title\":\"收藏\",\"key\":\"mine.collection\",\"sort\":1,\"enable\":true,\"icon\":\"collection\"},{\"title\":\"作品\",\"key\":\"mine.works\",\"sort\":2,\"enable\":true,\"icon\":\"works\"},{\"title\":\"订单\",\"key\":\"mine.order\",\"sort\":3,\"enable\":true,\"icon\":\"order\"},{\"title\":\"关注\",\"key\":\"mine.concern\",\"sort\":4,\"enable\":true,\"icon\":\"concern\"},{\"title\":\"直播\",\"key\":\"mine.video\",\"sort\":5,\"enable\":true,\"icon\":\"video\"},{\"title\":\"客服\",\"key\":\"mine.service\",\"sort\":6,\"enable\":true,\"icon\":\"service\"},{\"title\":\"我们\",\"key\":\"mine.about\",\"sort\":7,\"enable\":true,\"icon\":\"us\"}],\"msg\":\"success\"}";

  List<Menu> _menus;

  List<Menu> get menus => _menus;

  Future getMenus() async {
    setState(ViewState.LOADING);
    this._menus = await _generateMenus();
    setState(ViewState.SUCCESS);
  }

  Future<List<Menu>> _generateMenus() async {
    Result result = Result.fromJson(jsonDecode(json));
    var data = result.data;
    if (data != null && data is List) {
      var list = data.map((item) => Menu.fromJson(item)).toList();
      list.sort((m1, m2) => m1.sort.compareTo(m2.sort));
      return list;
    }
    return null;
  }

  @override
  List<String> requests() {
    return [];
  }
}
