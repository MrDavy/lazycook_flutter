import 'dart:collection';

import 'package:flutter/material.dart';

///
/// @desc 内存缓存
/// @author davy
/// @date 2019/12/22 12:04 上午
///
class Cache {
  Map<String, dynamic> _cache = HashMap();

  factory Cache() => _getInstance();
  static Cache _instance;

  static Cache _getInstance() {
    if (_instance == null) {
      _instance = Cache._internal();
    }
    return _instance;
  }

  Cache._internal() {}

  static Cache get instance => _getInstance();

  Future put(String key, dynamic value) async {
    try {
      _cache[key] = value;
      return true;
    } catch (e) {}
    return false;
  }

  Future<dynamic> get(String key) async {
    try {
      return await _cache[key];
    } catch (e) {}
    return null;
  }

  Future delete(String key) async {
    try {
      await _cache.remove(key);
      return true;
    } catch (e) {}
    return false;
  }
}
