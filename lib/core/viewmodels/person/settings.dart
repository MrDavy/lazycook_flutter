import 'package:lazycook/core/services/api.dart';
import 'package:lazycook/core/viewmodels/base_model.dart';
import '../../../config/lazy_uri.dart';
class SettingsModel extends BaseModel {
  SettingsModel(API api) : super(api);

  Future logout(){
    return api.logout();
  }

  @override
  List<String> requests() {
    return [LazyUri.LOGOUT];
  }
}
