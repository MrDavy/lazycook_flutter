import 'package:flutter/material.dart';
import 'package:lazycook/utils/string_utils.dart';
import 'package:lazycook/utils/utils.dart';

///
/// @desc 菜单
/// @author davy
/// @date 2020/1/1 9:18 下午
///
class Menu {
  String title;
  String key;
  int sort;
  String icon;
  bool enable;
  bool needLogin;

  Menu(
      {this.title,
      this.key,
      this.sort,
      this.icon,
      this.enable,
      this.needLogin});

  factory Menu.fromJson(Map<String, dynamic> json) {
    if (json == null) return null;
    return Menu(
        title: json['title'],
        key: json['key'],
        sort: json['sort'],
        icon: json['icon'],
        enable: json['enable'],
        needLogin: json['needLogin']);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['title'] = this.title;
    data['key'] = this.key;
    data['sort'] = this.sort;
    data['icon'] = this.icon;
    data['enable'] = this.enable;
    data['needLogin'] = this.needLogin;
    return data;
  }

  @override
  String toString() {
    return 'Menu{title: $title, key: $key, sort: $sort, icon: $icon, enable: $enable, needLogin: $needLogin}';
  }
}
