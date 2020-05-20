import 'dart:async';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lazycook/core/models/result_data.dart';
import 'package:lazycook/core/request/exception/error.dart';
import 'package:lazycook/core/services/api.dart';
import 'package:lazycook/core/viewmodels/base_model.dart';
import 'package:lazycook/utils/string_utils.dart';
import '../../../../config/lazy_uri.dart';

class LoginModel extends BaseModel {
  LoginModel({@required API api}) : super(api);

  ///密码是否显示明文
  bool _pwdVisible = false;

  bool get pwdVisible => _pwdVisible;

  String charCode = "";

  ///正在登录中
  bool _logging = false;

  bool get logging => _logging;

  bool _loginWithPwd = true;

  bool get loginWithPwd => _loginWithPwd;

  set loginWithPwd(bool withPwd) {
    if (_loginWithPwd == withPwd) return;
    _loginWithPwd = withPwd;
    notifyListeners();
  }

  Future login(params) async {
    return await api.login(params);
  }

  changeLoginStatus(bool logging) {
    if (_logging == logging) return;
    _logging = logging;
    notifyListeners();
  }

  changePwdVisible(bool visible) {
    if (_pwdVisible == visible) return;
    _pwdVisible = visible;
    notifyListeners();
  }

  @override
  List<String> requests() {
    return [LazyUri.LOGIN, LazyUri.AUTH_CODE];
  }
}
