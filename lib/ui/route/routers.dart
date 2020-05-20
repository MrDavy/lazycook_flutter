import 'package:lazycook/ui/route/handler.dart';
import 'package:lazycook/utils/fluro/src/router.dart';

class Routers {
  static const root = '/';
  static const crop = '/crop';
  static const web = '/web';
  static const gallery = "/gallery";

  static const home = '/home';
  static const home_search = '/home/search';
  static const news = '/home/news';
  static const add_recipe = '/home/add_recipe';
  static const recipe_detail = '/recipe_detail';
  static const category = '/home/category';

  static const collection = '/person/collection';
  static const works = '/person/works';
  static const works_new = '/person/works/new';
  static const service = '/person/service';
  static const about = '/person/about';
  static const settings = '/person/settings';
  static const login = '/person/login';
  static const register = '/person/register';
  static const forget = '/person/forget';
  static const forget_code = "/person/forget/code";
  static const forget_pwd_input = "/person/forget/pwd";
  static const person_info = "/person/info";
  static const person_avatar_edit = "/person/info/avatar";
  static const person_nickname_edit = "/person/info/nickname";

  static configureRouters(Router router) {
    router.notFoundHandler = notFoundHandler;

    ///定义重定向的路由处理器，对应重定向的路由页面
    router.redirectHandler = loginHandler;

    ///首页
    router.define(home, handler: homeHandler);
    router.define(home_search, handler: homeSearchHandler);
    router.define(recipe_detail, handler: recipeDetailHandler);

    ///分类
    router.define(category, handler: categoryHandler);

    ///个人中心
    router.define(collection, handler: collectionHandler);
    router.define(works, handler: worksHandler);
    router.define(works_new, handler: worksNewHandler);
    router.define(service, handler: consumerServiceHandler);
    router.define(about, handler: aboutUsHandler);
    router.define(settings, handler: settingsHandler);
    router.define(login, handler: loginHandler);
    router.define(register, handler: registerHandler);
    router.define(forget, handler: forgetHandler);
    router.define(forget_code, handler: forgetCodeHandler);
    router.define(forget_pwd_input, handler: forgetPwdInputCodeHandler);

    router.define(person_info, handler: personInfoHandler);
    router.define(person_avatar_edit, handler: avatarEditHandler);
    router.define(person_nickname_edit, handler: nicknameEditHandler);

    ///功能性
    router.define(crop, handler: cropHandler);
    router.define(web, handler: webHandler);
    router.define(gallery, handler: galleryHandler);
  }
}
