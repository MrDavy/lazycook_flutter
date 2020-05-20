import 'package:lazycook/core/services/api.dart';
import 'package:lazycook/core/viewmodels/base_model.dart';
import '../../../../config/lazy_uri.dart';
class PwdResetModel extends BaseModel {
  PwdResetModel(API api) : super(api);

  @override
  List<String> requests() {
    return [LazyUri.CODE_VALIDATE];
  }

  Future authCode(phone) {
    return api.authCode({'phone': phone, 'type': '4'});
  }
}
