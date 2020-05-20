import 'package:lazycook/core/services/api.dart';
import 'package:lazycook/core/viewmodels/base_model.dart';
import '../../../../config/lazy_uri.dart';
class PwdInputModel extends BaseModel {
  PwdInputModel(API api) : super(api);

  ///密码是否显示明文
  bool _pwdVisible = false;

  bool get pwdVisible => _pwdVisible;

  changePwdVisible(bool visible) {
    if (_pwdVisible == visible) return;
    _pwdVisible = visible;
    notifyListeners();
  }

  Future submit(params) {
    return api.resetPwd(params);
  }

  @override
  List<String> requests() {
    return [LazyUri.RESET_PWD];
  }
}
