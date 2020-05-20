import 'package:lazycook/config/lazy_uri.dart';
import 'package:lazycook/core/services/api.dart';
import 'package:lazycook/core/viewmodels/base_model.dart';

///
/// @Description
/// @Date 2020/5/8 21:57
/// @Created by Davy
///
class PersonModel extends BaseModel {
  PersonModel(API api) : super(api);

  Future updateNickName(params) {
    return api.updateNickName(params);
  }

  @override
  List<String> requests() {
    return [LazyUri.NICKNAME_UPDATE];
  }
}
