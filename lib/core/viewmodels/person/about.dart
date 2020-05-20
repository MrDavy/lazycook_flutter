import 'package:lazycook/application.dart';
import 'package:lazycook/core/services/api.dart';
import 'package:lazycook/core/viewmodels/base_model.dart';
import 'package:lazycook/utils/utils.dart';
import 'package:package_info/package_info.dart';
import '../../../config/lazy_uri.dart';

class AboutModel extends BaseModel {
  AboutModel(API api) : super(api);

  Future checkVersion() async {
    if (Application.packageInfo == null) {
      Application.packageInfo = await Utils.getPackageInfo();
    }
    var versionInfo;
    if (Application.packageInfo != null) {
      versionInfo = await api.version();
    }
    return versionInfo;
  }

  @override
  List<String> requests() {
    return [LazyUri.VERSION];
  }
}
