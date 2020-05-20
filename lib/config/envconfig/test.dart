import 'env.dart';

///测试环境
class TestConfig extends EnvConfig {
  @override
  String baseUrl() {
    return "https://localhost" + subDomain();
  }
}
