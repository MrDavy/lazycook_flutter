import 'env.dart';

///调用mock数据环境
class MockConfig extends EnvConfig {
  @override
  String baseUrl() {
    return "https://mockapi.eolinker.com/KlS2EHYf12f235f42467adae15c022f769aad0b042069d3"+subDomain();
  }
}
