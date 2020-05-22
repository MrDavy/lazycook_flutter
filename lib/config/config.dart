import 'package:lazycook/config/envconfig/huidu.dart';

import 'envconfig/dev.dart';
import 'envconfig/env.dart';
import 'envconfig/mock.dart';
import 'envconfig/prod.dart';
import 'envconfig/test.dart';

class Config {
  ///当前环境,由于测试环境没有部署在外网，此处使用prod
  static const Env env = Env.huidu;

  static bool isDebug() {
    return env != Env.prod;
  }

  ///  环境配置
  static EnvConfig envConfig() {
    switch (env) {
      case Env.mock:
        return MockConfig();
      case Env.dev:
        return DevConfig();
      case Env.test:
        return TestConfig();
      case Env.prod:
        return ProdConfig();
      case Env.huidu:
        return HuiDuConfig();
    }
    return DevConfig();
  }
}

enum Env { mock, dev, test, prod, huidu }
