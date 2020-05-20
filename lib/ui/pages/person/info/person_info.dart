import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lazycook/config/config.dart';
import 'package:lazycook/core/request/exception/error.dart';
import 'package:lazycook/core/viewmodels/person/login/user_model.dart';
import 'package:lazycook/core/viewmodels/person/person.dart';
import 'package:lazycook/core/viewmodels/person/settings.dart';
import 'package:lazycook/ui/route/nav.dart';
import 'package:lazycook/ui/route/routers.dart';
import 'package:lazycook/ui/shared/colors.dart';
import 'package:lazycook/ui/shared/styles.dart';
import 'package:lazycook/ui/widgets/button.dart';
import 'package:lazycook/ui/widgets/custom_state.dart';
import 'package:lazycook/ui/widgets/main_widget.dart';
import 'package:lazycook/ui/widgets/provider_widget.dart';
import 'package:lazycook/utils/fluro/fluro.dart';
import 'package:lazycook/utils/string_utils.dart';
import 'package:provider/provider.dart';

///
/// 个人信息
///
class PersonInfoPage extends StatefulWidget {
  PersonInfoPage({Key key}) : super(key: key);

  @override
  _PersonInfoPageState createState() => _PersonInfoPageState();
}

class _PersonInfoPageState extends CustomState<PersonInfoPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  bool darkStatusBar() {
    return true;
  }

  @override
  Widget buildWidget(BuildContext context) {
    return Scaffold(
      body: MainWidget(
        statusBarColor: white,
        headerDecoration: BoxDecoration(color: white),
        titleColor: Colors.black,
        leadingColor: Colors.black,
        title: "个人信息",
        child: MultiProvider(
          providers: [
            ChangeNotifierProvider.value(value: Provider.of<UserModel>(context))
          ],
          child: Container(
            color: backgroundGray,
            child: Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
//                  Row(
//                    mainAxisAlignment: MainAxisAlignment.spaceAround,
//                    children: <Widget>[
//                      Image.asset(
//                        "assets/images/link.png",
//                        height: height(20),
//                        fit: BoxFit.fitWidth,
//                      ),
//                      Image.asset(
//                        "assets/images/link.png",
//                        height: height(20),
//                        fit: BoxFit.fitWidth,
//                      )
//                    ],
//                  ),
                InkWell(
                  onTap: () {
                    Nav.pageTo(context, Routers.person_avatar_edit);
                  },
                  child: Container(
                    decoration: BoxDecoration(
                        color: white,
                        boxShadow:
                            getBoxLTRBShadows(Colors.grey[200], blurRadius: 2),
                        borderRadius: BorderRadius.circular(width(3))),
                    margin: EdgeInsets.fromLTRB(
                        width(10), height(20), width(10), height(10)),
                    padding: EdgeInsets.only(
                        left: width(16),
                        top: height(8),
                        bottom: height(8),
                        right: width(6)),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Text(
                          "头像",
                          style: textStyle(
                            color: textColor,
                            fontSize: sp(14),
                            fontWeight: bold,
                          ),
                        ),
                        Row(
                          children: <Widget>[
                            Consumer<UserModel>(
                              builder: (context, model, _) {
                                var user = model.user;
                                var placeholder = Image.asset(
                                  "assets/images/icon-default.png",
                                  width: width(56),
                                  height: width(56),
                                );
                                return ClipOval(
                                  child: StringUtils.isEmpty(user.portrait)
                                      ? placeholder
                                      : CachedNetworkImage(
                                          placeholder: (context, url) =>
                                              placeholder,
                                          imageUrl:
                                              Config.envConfig().imgBasicUrl() +
                                                  user.portrait,
                                          width: width(56),
                                          height: width(56),
                                          fit: BoxFit.contain,
                                        ),
                                );
                              },
                            ),
                            SizedBox(
                              width: width(10),
                            ),
                            Icon(
                              Icons.keyboard_arrow_right,
                              color: lineColor,
                            )
                          ],
                        )
                      ],
                    ),
                  ),
                ),
//                  Row(
//                    mainAxisAlignment: MainAxisAlignment.spaceAround,
//                    children: <Widget>[
//                      Image.asset(
//                        "assets/images/link_short.png",
//                        height: height(10),
//                        fit: BoxFit.fitWidth,
//                      ),
//                      Image.asset(
//                        "assets/images/link_short.png",
//                        height: height(10),
//                        fit: BoxFit.cover,
//                      )
//                    ],
//                  ),
                InkWell(
                  onTap: () {
                    Nav.pageTo(context, Routers.person_nickname_edit,
                        transition: TransitionType.cupertinoFullScreenDialog);
                  },
                  child: Container(
                    decoration: BoxDecoration(
                        color: white,
                        boxShadow:
                            getBoxLTRBShadows(Colors.grey[200], blurRadius: 2),
                        borderRadius: BorderRadius.circular(width(3))),
                    margin: EdgeInsets.fromLTRB(
                        width(10), height(0), width(10), height(10)),
                    padding: EdgeInsets.only(
                        left: width(16),
                        top: height(16),
                        bottom: height(16),
                        right: width(6)),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Text(
                          "昵称",
                          style: textStyle(
                            color: textColor,
                            fontSize: sp(14),
                            fontWeight: bold,
                          ),
                        ),
                        Row(
                          children: <Widget>[
                            Consumer<UserModel>(
                              builder: (context, model, _) {
                                var user = model.user;
                                return Text(
                                  user.nikename,
                                  style: textStyle(color: color_666),
                                );
                              },
                            ),
                            SizedBox(
                              width: width(10),
                            ),
                            Icon(
                              Icons.keyboard_arrow_right,
                              color: lineColor,
                            )
                          ],
                        )
                      ],
                    ),
                  ),
                ),
//                  Row(
//                    mainAxisAlignment: MainAxisAlignment.spaceAround,
//                    children: <Widget>[
//                      Image.asset(
//                        "assets/images/link_short.png",
//                        height: height(10),
//                        fit: BoxFit.fitWidth,
//                      ),
//                      Image.asset(
//                        "assets/images/link_short.png",
//                        height: height(10),
//                        fit: BoxFit.cover,
//                      )
//                    ],
//                  ),
                Container(
                  decoration: BoxDecoration(
                      color: white,
                      boxShadow:
                          getBoxLTRBShadows(Colors.grey[200], blurRadius: 2),
                      borderRadius: BorderRadius.circular(width(3))),
                  margin: EdgeInsets.fromLTRB(
                      width(10), height(0), width(10), height(0)),
                  padding: EdgeInsets.only(
                      left: width(16),
                      top: height(16),
                      bottom: height(16),
                      right: width(6)),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text(
                        "手机号",
                        style: textStyle(
                          color: textColor,
                          fontSize: sp(14),
                          fontWeight: bold,
                        ),
                      ),
                      Row(
                        children: <Widget>[
                          Consumer<UserModel>(
                            builder: (context, model, _) {
                              var user = model.user;
                              return Text(
                                user.phone,
                                style: textStyle(color: color_666),
                              );
                            },
                          ),
                          SizedBox(
                            width: width(10),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
