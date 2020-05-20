import 'package:lazycook/config/lazy_uri.dart';
import 'package:lazycook/core/models/result_data.dart';
import 'package:lazycook/core/request/exception/error.dart';
import 'package:lazycook/core/services/api.dart';
import 'package:lazycook/core/viewmodels/base_model.dart';

class AvatarEditModel extends BaseModel {
  AvatarEditModel(API api) : super(api);

  Future updateAvatar(params, path) async {
    return api.uploadImage(params, [path]).then((value) {
      logger.log("上传结果value = $value");
      if (value is ResultData) {
        if (value.error == null) {
          logger.log("value.data = ${value.data}");
          List<String> images = [];
          images.addAll(value.data);
          logger.log("images = $images");
          if (images.isEmpty) return Future.error(LazyError(message: "图片上传失败"));
          return _updateAvatar(images[0]);
        } else {
          return Future.error(
              LazyError(message: value.error.message, code: value.error.code));
        }
      }
      return Future.error(LazyError(message: "图片上传失败"));
    });
  }

  Future _updateAvatar(path) {
    return api.updateAvatar({"avatar": path});
  }

  @override
  List<String> requests() {
    return [LazyUri.AVATAR_UPDATE, LazyUri.IMG_UPLOAD];
  }
}
