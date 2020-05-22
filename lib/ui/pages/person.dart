import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lazycook/config/config.dart';
import 'package:lazycook/core/models/menu.dart';
import 'package:lazycook/core/services/api.dart';
import 'package:lazycook/core/viewmodels/person/login/user_model.dart';
import 'package:lazycook/core/viewmodels/person/mine_menu.dart';
import 'package:lazycook/ui/route/nav.dart';
import 'package:lazycook/ui/route/routers.dart';
import 'package:lazycook/ui/shared/colors.dart';
import 'package:lazycook/ui/shared/styles.dart';
import 'package:lazycook/ui/widgets/avatar.dart';
import 'package:lazycook/ui/widgets/custom/pie.dart';
import 'package:lazycook/ui/widgets/custom_state.dart';
import 'package:lazycook/ui/widgets/icon_text.dart';
import 'package:lazycook/ui/widgets/main_widget.dart';
import 'package:lazycook/ui/widgets/provider_widget.dart';
import 'package:lazycook/utils/string_utils.dart';
import 'package:provider/provider.dart';

class PersonPage extends StatefulWidget {
  @override
  _PersonPageState createState() => _PersonPageState();
}

class _PersonPageState extends CustomState<PersonPage> {
  @override
  Widget buildWidget(BuildContext context) {
    return Scaffold(
      body: MainWidget(
        noLeading: true,
        leading: Padding(
          padding: EdgeInsets.only(left: width(16)),
          child: Image.asset(
            "assets/images/settings.png",
            width: width(24),
            height: width(24),
          ),
        ),
//        decoration: BoxDecoration(gradient: defaultGradient(context)),
        decoration: BoxDecoration(
            gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Theme.of(context).primaryColor, white, white, white])),
        title: "",
        onLeadingTap: () {},
        child: CustomScrollView(
          physics: ScrollPhysics(),
          slivers: <Widget>[
            SliverToBoxAdapter(
              child: Container(
                width: double.infinity,
                alignment: Alignment.center,
                margin: EdgeInsets.all(0),
                padding: EdgeInsets.all(0),
                child: Stack(
                  fit: StackFit.passthrough,
                  alignment: AlignmentDirectional.topCenter,
                  children: <Widget>[
                    Container(
                      margin: EdgeInsets.only(top: height(38)),
                      height: height(120),
                      child: CustomPaint(
                        painter: Pie(ScreenUtil.screenWidthDp, height(120)),
                      ),
                    ),
                    _buildAvatar()
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Container(
                color: white,
                width: double.infinity,
                child: ProviderWidget<MineMenuModel>(
                  model: MineMenuModel(api: Provider.of<API>(context)),
                  onModelReady: (model) => model.getMenus(),
                  builder: (context, model, child) {
                    return GridView.builder(
                        padding: EdgeInsets.only(
                            top: height(28), left: width(28), right: width(28)),
                        shrinkWrap: true,
                        physics: ScrollPhysics(),
                        itemCount: model?.menus?.length ?? 0,
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            crossAxisSpacing: width(20),
                            mainAxisSpacing: height(10)),
                        itemBuilder: (context, index) {
                          if (model?.menus?.isNotEmpty == true)
                            return InkWell(
                              child: _buildMenu(model.menus[index]),
                              onTap: () async {
                                await Nav.pageTo(
                                    context, model.menus[index].key,
                                    needLogin: model.menus[index].needLogin);
                              },
                            );
                          else
                            return _buildMenuSkeleton();
                        });
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatar() {
    var user = Provider.of<UserModel>(context).user;
    return Container(
      margin: EdgeInsets.only(left: width(16), right: width(16)),
      child: InkWell(
        onTap: () {
          if (checkUser('person')) {
            Nav.pageTo(context, Routers.person_info);
          }
        },
        child: Column(
          children: <Widget>[
            Hero(
                tag: "avatar",
                child: Avatar(
                  width: width(80),
                  height: width(80),
                  bgHeight: width(88),
                  bgWidth: width(88),
                  bgColor: white,
                  child: StringUtils.isEmpty(user?.portrait)
                      ? Image(
                          image: AssetImage("assets/images/icon-default.png"),
                          width: width(80),
                          height: width(80),
                          fit: BoxFit.cover,
                        )
                      : CachedNetworkImage(
                          placeholder: (context, url) => Image(
                            image: AssetImage("assets/images/icon-default.png"),
                            width: width(80),
                            height: width(80),
                            fit: BoxFit.cover,
                          ),
                          width: width(80),
                          height: width(80),
                          imageUrl:
                              Config.envConfig().imgBasicUrl() + user.portrait,
                          fit: BoxFit.fitWidth,
                        ),
                )),
            SizedBox(
              height: height(4),
            ),
            Text(
              StringUtils.isNotEmpty(user?.nikename) ? user?.nikename : "点击登录",
              style: textStyle(
                  color: color_222,
                  fontSize: sp(16),
                  fontWeight: FontWeight.w700),
            ),
            SizedBox(
              height: height(4),
            ),
            StringUtils.isNotEmpty(user?.tags)
                ? IconText(
                    iconWidth: width(14),
                    iconHeight: width(14),
                    text: user?.tags,
                    space: width(3),
                    assetImagePath: "assets/images/person_tag.png",
                    textStyle: textStyle(
                        color: secondColor,
                        fontSize: sp(12),
                        fontWeight: bold),
                  )
                : Container()
          ],
        ),
      ),
    );
  }

  Widget _buildMenu(Menu menu) {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Image.asset(
            "assets/images/${menu.icon}.png",
            width: width(36),
            height: height(36),
          ),
          Text(
            menu.title,
            style: textStyle(
                color: color_666,
                fontSize: sp(14),
                fontWeight: bold),
          )
        ],
      ),
    );
  }

  Widget _buildMenuSkeleton() {
    return Container(
      color: skeletonGray,
      width: width(36),
      height: height(56),
    );
  }
}
