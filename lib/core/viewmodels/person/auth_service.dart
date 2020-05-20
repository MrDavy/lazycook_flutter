import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:lazycook/core/models/user.dart';
import 'package:lazycook/core/services/api.dart';
import 'package:lazycook/utils/logger.dart';
import 'package:lazycook/utils/preference_utils.dart';
import 'package:meta/meta.dart';

///用户登录，认证服务
class AuthenticationService {
  API _api;
  Logger _logger = Logger("AuthenticationService");

  AuthenticationService({@required API api}) : _api = api;
  StreamController<User> _userController = StreamController<User>();

  Stream<User> get user => _userController.stream;

  Future getToken() async {
    var token = await PreferenceUtils.getString("token");
    _logger.log("getToken token = $token");
    User user = User(token: token);
    _userController.add(user);
    return user;
  }

  Future login(params) async {
    _logger.log("login params = $params");
    User user = await _api.login(params, CancelToken());
    PreferenceUtils.saveString("token", user.token).catchError((error) {});
    _userController.add(user);
    return user;
  }

  dispose() {
    _userController.close();
  }
}
