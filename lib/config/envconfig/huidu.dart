import 'package:lazycook/config/envconfig/env.dart';

///
/// @Description 
/// @Date 2020/5/16 0:36
/// @Created by Davy
///
class HuiDuConfig extends EnvConfig {
  @override
  String baseUrl() {
    return "http://ldc.sovlot.com:90" + subDomain();
  }
}