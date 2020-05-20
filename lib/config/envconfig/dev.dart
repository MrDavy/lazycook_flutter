import 'env.dart';

///开发环境
class DevConfig extends EnvConfig {
  @override
  String baseUrl() {
    return "http://172.29.36.48" + subDomain();
  }
}
