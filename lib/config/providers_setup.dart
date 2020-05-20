import 'package:lazycook/core/models/home_info.dart';
import 'package:lazycook/core/models/user.dart';
import 'package:lazycook/core/request/local_repository.dart';
import 'package:lazycook/core/viewmodels/config/local.dart';
import 'package:lazycook/core/viewmodels/home/home_Info.dart';
import 'package:lazycook/core/viewmodels/person/about.dart';
import 'package:lazycook/core/viewmodels/person/auth_service.dart';
import 'package:lazycook/core/viewmodels/person/login/user_model.dart';
import 'package:lazycook/utils/logger.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

import '../core/services/api.dart';

List<SingleChildWidget> providers = [
  ...independentServices,
  ...dependentServices,
  ...uiConsumableProviders
];

///独立的Provider
List<SingleChildWidget> independentServices = [
  ///创建全局Repository
  Provider(
    create: (context) {
      return LocalRepository();
    },
    dispose: (_, repository) => repository.dispose(),
  ),

  ///国际化
  ChangeNotifierProvider(create: (context) => LocalModel()),

  ///用户信息
  ChangeNotifierProvider<UserModel>(create: (context) {
    return UserModel();
  }),
];

///依赖的Provider
List<SingleChildWidget> dependentServices = [
  //认证服务放全局
  ProxyProvider<UserModel, API>(
    update: (_, userModel, previous) {
      return previous ?? API(userModel: userModel);
    },
    dispose: (_, repository) => repository.dispose(),
  ),
  ChangeNotifierProvider<AboutModel>(
      create: (context) => AboutModel(Provider.of(context, listen: false))),
];

List<SingleChildWidget> uiConsumableProviders = [
  //用户信息放全局
//  StreamProvider<User>(
//    create: (context) {
//      Logger("StreamProvider").log("msg");
//      return Provider.of<AuthenticationService>(context, listen: false).user;
//    },
//  )
];
