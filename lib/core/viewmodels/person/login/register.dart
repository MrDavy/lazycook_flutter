import 'dart:async';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:lazycook/core/models/result_data.dart';
import 'package:lazycook/core/request/exception/error.dart';
import 'package:lazycook/core/services/api.dart';
import 'package:lazycook/core/viewmodels/base_model.dart';
import 'package:lazycook/utils/string_utils.dart';
import '../../../../config/lazy_uri.dart';

class RegisterModel extends BaseModel {
  RegisterModel({@required API api}) : super(api);

  ///密码是否显示明文
  bool _pwdVisible = false;

  bool get pwdVisible => _pwdVisible;

  ///正在登录中
  ///头像图片
  File _avatar;

  File get avatar => _avatar;

  set avatar(File file) {
    _avatar = file;
    notifyListeners();
  }

  changePwdVisible(bool visible) {
    if (_pwdVisible == visible) return;
    _pwdVisible = visible;
    notifyListeners();
  }

  Future register(params) async {
    if (StringUtils.isEmpty(_avatar.path)) {
      return realRegister(params);
    } else {
      return api.uploadImage({"type": "4"}, [_avatar.path]).then((value) {
        logger.log("上传结果value = $value");
        if (value is ResultData) {
          if (value.error == null) {
            logger.log("value.data = ${value.data}");
            List<String> images = [];
            images.addAll(value.data);
            logger.log("images = $images");
            if (images.isEmpty)
              return Future.error(LazyError(message: "图片上传失败"));
            params.avatar = images[0];
            return realRegister(params);
          } else {
            return Future.error(LazyError(
                message: value.error.message, code: value.error.code));
          }
        }
        return Future.error(LazyError(message: "图片上传失败"));
      });
    }
  }

  Future realRegister(params) {
    logger.log("注册：params = $params");
    return api.register(params);
  }

  @override
  List<String> requests() {
    return [LazyUri.REGISTER];
  }
}
