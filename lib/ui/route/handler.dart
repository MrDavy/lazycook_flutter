import 'package:flutter/material.dart';
import 'package:lazycook/ui/pages/home.dart';
import 'package:lazycook/ui/pages/home/category.dart';
import 'package:lazycook/ui/pages/home/recipe_detail.dart';
import 'package:lazycook/ui/pages/home/recipe_list.dart';
import 'package:lazycook/ui/pages/person/about.dart';
import 'package:lazycook/ui/pages/person/collection.dart';
import 'package:lazycook/ui/pages/person/feedback.dart';
import 'package:lazycook/ui/pages/person/info/avatar_edit.dart';
import 'package:lazycook/ui/pages/person/info/nickname_edit.dart';
import 'package:lazycook/ui/pages/person/login/reset/code_input.dart';
import 'package:lazycook/ui/pages/person/login/reset/phone_validate.dart';
import 'package:lazycook/ui/pages/person/login/login.dart';
import 'package:lazycook/ui/pages/person/login/register.dart';
import 'package:lazycook/ui/pages/person/login/reset/pwd_input.dart';
import 'package:lazycook/ui/pages/person/info/person_info.dart';
import 'package:lazycook/ui/pages/person/settings/settings.dart';
import 'package:lazycook/ui/pages/person/work/work_new.dart';
import 'package:lazycook/ui/pages/person/work/works.dart';
import 'package:lazycook/ui/pages/web_view.dart';
import 'package:lazycook/ui/widgets/crop/image_crop_page.dart';
import 'package:lazycook/ui/widgets/gallery/gallery.dart';
import 'package:lazycook/utils/fluro/src/common.dart';
import 'package:lazycook/utils/logger.dart';
import 'package:lazycook/utils/utils.dart';

import 'notfound.dart';

///自定义路由事件处理参数，将json转为map
class LdcHandler extends Handler {
  final Logger logger = Logger("LdcHandler");

  final LdcHandlerFunc ldcHandlerFunc;
  final bool intercept;

  LdcHandler({this.ldcHandlerFunc, this.intercept})
      : super(intercept: intercept);

  @override
  HandlerFunc get handlerFunc =>
      (context, params, {Map<String, dynamic> extra}) {
        Map<String, dynamic> map;
        if (params != null && params.length > 0 && params.containsKey('json')) {
          map = Utils.convertJsonToMap(params['json'].first);
        }
        return ldcHandlerFunc(context, map, extra);
      };
}

///
typedef Widget LdcHandlerFunc(BuildContext context,
    Map<String, dynamic> parameters, Map<String, dynamic> extra);

///错误页
Handler notFoundHandler =
    LdcHandler(ldcHandlerFunc: (_, map, extra) => NotFoundWidget());

///主页
Handler homeHandler =
    LdcHandler(ldcHandlerFunc: (context, map, extra) => HomePage());

///分类
Handler categoryHandler = LdcHandler(
    ldcHandlerFunc: (context, map, extra) => CategoryWidget(
          scence: map == null ? '' : (map['scence'] ?? ''),
        ));

///菜品详情
Handler recipeDetailHandler = LdcHandler(
    ldcHandlerFunc: (context, map, extra) => RecipeDetailWidget(
          map == null ? 0 : (map['did'] ?? ""),
          map == null ? "" : (map["album"] ?? ""),
          map == null ? "" : (map['scence'] ?? ""),
          map == null ? "" : (map['title'] ?? ""),
        ));

///搜索
Handler homeSearchHandler = LdcHandler(
    ldcHandlerFunc: (context, map, extra) => RecipeListWidget(
          keyword: map == null ? '' : (map['keyword'] ?? ''),
          scence: map == null ? '' : (map['scence'] ?? ''),
          directSearch: map == null ? false : map['isList'] ?? false,
        ));

///收藏
Handler collectionHandler = LdcHandler(
    intercept: true, ldcHandlerFunc: (context, map, extra) => CollectionPage());

///作品
Handler worksHandler = LdcHandler(
    intercept: true, ldcHandlerFunc: (context, map, extra) => WorksPage());

///新建作品
Handler worksNewHandler = LdcHandler(
    intercept: true,
    ldcHandlerFunc: (context, map, extra) {
      return NewWork(
        workId: map != null ? map['work_id'] : null,
      );
    });

///客服
Handler consumerServiceHandler =
    LdcHandler(ldcHandlerFunc: (context, map, extra) => FeedbackPage());

///关于我们
Handler aboutUsHandler =
    LdcHandler(ldcHandlerFunc: (context, map, extra) => AboutPage());

///设置
Handler settingsHandler =
    LdcHandler(ldcHandlerFunc: (context, map, extra) => SettingsPage());

///用户相关
///
///登陆
Handler loginHandler = LdcHandler(
    ldcHandlerFunc: (context, map, extra) => LoginPage(
        scence: map != null
            ? map['scence']
            : extra == null ? '' : (extra['path'] ?? '')));

///注册
Handler registerHandler =
    LdcHandler(ldcHandlerFunc: (context, map, extra) => RegisterPage());

///忘记密码
Handler forgetHandler =
    LdcHandler(ldcHandlerFunc: (context, map, extra) => PhoneValidatePage());

///忘记密码-验证码输入
Handler forgetCodeHandler = LdcHandler(
    ldcHandlerFunc: (context, map, extra) => CodeInput(
          phone: map == null ? null : map['phone'],
        ));

///忘记密码-密码输入
Handler forgetPwdInputCodeHandler = LdcHandler(
    ldcHandlerFunc: (context, map, extra) => PwdInputWidget(
          token: map == null ? null : map['token'],
          phone: map == null ? null : map['phone'],
          code: map == null ? null : map['code'],
        ));

///用户信息
Handler personInfoHandler =
    LdcHandler(ldcHandlerFunc: (context, map, extra) => PersonInfoPage());

///头像修改
Handler avatarEditHandler =
    LdcHandler(ldcHandlerFunc: (context, map, extra) => AvatarEditPage());

///昵称修改
Handler nicknameEditHandler =
    LdcHandler(ldcHandlerFunc: (context, map, extra) => NickNameEditPage());

///功能性
///
///裁剪
Handler cropHandler = LdcHandler(
    ldcHandlerFunc: (context, map, extra) => ImageCrop(
          image: map == null ? null : map['image'],
          width: map == null ? null : map['width'],
          height: map == null ? null : map['height'],
        ));

///web
Handler webHandler = LdcHandler(
    ldcHandlerFunc: (context, map, extra) => Browser(
          url: map == null ? null : map['url'],
          title: map == null ? null : map['title'],
        ));

///web
Handler galleryHandler = LdcHandler(ldcHandlerFunc: (context, map, extra) {
  return Gallery(
    list: map == null
        ? []
        : map['list']
            .map<GalleryData>((data) => GalleryData.fromJson(data))
            .toList(),
    initialIndex: map == null ? 0 : map['initialIndex'],
  );
});
