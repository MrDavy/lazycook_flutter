import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:lazycook/config/storage_manager.dart';
import 'package:lazycook/core/models/user.dart';
import 'package:lazycook/utils/logger.dart';

class UserModel extends ChangeNotifier {
  static const kUser = "user";

  Logger _logger = Logger("UserModel");

  User _user;

  User get user => _user;

  bool get hasUser => _user != null;

  UserModel() {
    var userMap = StorageManager.localStorage.getItem(kUser);
//    _logger.log("local userMap = $userMap");
    _user = userMap == null ? null : User.fromJson(userMap);
//    _logger.log("local user = $_user");
  }

  saveUser(User user) {
    this._user = user;
    notifyListeners();
    StorageManager.localStorage.setItem(kUser, user);
  }

  Future clearUser() {
    this._user = null;
    notifyListeners();
    return StorageManager.localStorage.deleteItem(kUser);
  }
}
