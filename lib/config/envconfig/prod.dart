import 'env.dart';

///生产环境
class ProdConfig extends EnvConfig {
  @override
  String baseUrl() {
    return "http://ldc.sovlot.com:90" + subDomain();
  }
}
