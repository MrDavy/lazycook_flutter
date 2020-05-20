import 'package:lazycook/core/services/api.dart';
import 'package:lazycook/core/viewmodels/base_model.dart';

import '../../../../config/lazy_uri.dart';

class CodeInputModel extends BaseModel {
  CodeInputModel(API api) : super(api);

  bool _reSubmit = false;

  bool get reSubmit => _reSubmit;

  setReSubmit(reSubmit) {
    logger.log("setReSubmit reSubmit = $reSubmit");
    _reSubmit = reSubmit;
    notifyListeners();
  }

  Future validateCode(phone, code) {
    return api.codeValidate({'phone': phone, 'code': code, 'type': '4'});
  }

  Future authCode(phone) {
    return api.authCode({'phone': phone, 'type': '4'});
  }

  @override
  List<String> requests() {
    return [LazyUri.CODE_VALIDATE];
  }
}
