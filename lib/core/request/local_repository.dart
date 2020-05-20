import 'package:flutter/material.dart';
import 'package:lazycook/core/models/result_data.dart';
import 'package:lazycook/utils/cache.dart';
import 'package:lazycook/utils/logger.dart';

///
/// @desc 缓存数据仓库
/// @author davy
/// @date 2019/12/22 3:16 下午
///
class LocalRepository {
  Logger _logger = Logger("LocalRepository");

  factory LocalRepository() => _getInstance();

  static LocalRepository _instance;

  static LocalRepository get instance => _getInstance();

  static LocalRepository _getInstance() {
    if (_instance == null) {
      _instance = LocalRepository._internal();
    }
    return _instance;
  }

  LocalRepository._internal();

  Future<ResultData> load(String key) async {
    try {
      var data = await Cache.instance.get(key);
      if (data != null) {
        return ResultData(data: data, error: null);
      }
    } catch (e) {
      _logger.log("save $key to local repository failed!，e = $e");
    }
    return null;
  }

  Future save(String key, dynamic data) async {
    try {
      await Cache.instance.put(key, data);
      return true;
    } catch (e) {
      _logger.log("save $key to local repository failed!，e = $e");
    }
    return false;
  }

  Future delete(String key) async {
    try {
      return await Cache.instance.delete(key);
    } catch (e) {}
    return false;
  }

  void dispose() {}
}
