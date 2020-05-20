import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lazycook/config/config.dart';
import 'package:lazycook/core/viewmodels/person/avatar_eidt.dart';
import 'package:lazycook/core/viewmodels/person/login/user_model.dart';
import 'package:lazycook/ui/route/nav.dart';
import 'package:lazycook/ui/shared/colors.dart';
import 'package:lazycook/ui/shared/styles.dart';
import 'package:lazycook/ui/widgets/custom_state.dart';
import 'package:lazycook/ui/widgets/image.dart';
import 'package:lazycook/ui/widgets/main_widget.dart';
import 'package:lazycook/ui/widgets/provider_widget.dart';
import 'package:lazycook/utils/string_utils.dart';
import 'package:provider/provider.dart';

///
/// 编辑昵称
///
class AvatarEditPage extends StatefulWidget {
  AvatarEditPage({Key key}) : super(key: key);

  @override
  _AvatarEditPageState createState() => _AvatarEditPageState();
}

class _AvatarEditPageState extends CustomState<AvatarEditPage> {
  String localImg;
  AvatarEditModel _avatarEditModel;

  @override
  void initState() {
    super.initState();
    _avatarEditModel = AvatarEditModel(api());
  }

  @override
  Widget buildWidget(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.black,
        iconTheme: IconThemeData(color: Colors.white),
        brightness: Brightness.dark,
        title: Text(
          "个人头像",
          style: textStyle(
            color: Colors.white,
            fontSize: sp(18),
            fontWeight: bold,
          ),
        ),
        actions: <Widget>[
          GestureDetector(
            onTap: () async {
              var result = await selectPicture(
                  crop: true,
                  mWidth: ScreenUtil.screenWidthDp,
                  mHeight: ScreenUtil.screenWidthDp);
              logger.log("result = ${result?.path}");
              if (StringUtils.isNotEmpty(result?.path)) {
                localImg = result?.path;
                setState(() {});
              }
            },
            child: Padding(
              padding: EdgeInsets.only(right: width(16)),
              child: Image.asset(
                "assets/images/menu.png",
                width: width(24),
                height: height(16),
              ),
            ),
          )
        ],
      ),
      body: ChangeNotifierProvider.value(
        value: Provider.of<UserModel>(context),
        child: Stack(
          children: [
            Container(
              alignment: Alignment.center,
              child: Consumer<UserModel>(builder: (context, model, _) {
                logger.log("portrait = ${model.user.portrait}");
                return LdcImage(
                    img: StringUtils.isNotEmpty(localImg)
                        ? localImg
                        : StringUtils.isNotEmpty(model.user.portrait)
                            ? Config.envConfig().imgBasicUrl() +
                                model.user.portrait
                            : "",
                    width: ScreenUtil.screenWidthDp,
                    height: ScreenUtil.screenWidthDp);
              }),
            ),
            StringUtils.isNotEmpty(localImg)
                ? Align(
                    alignment: Alignment.bottomCenter,
                    child: InkWell(
                      onTap: () async {
                        var result = await simpleFuture(_avatarEditModel
                            ?.updateAvatar({"type": "4"}, localImg),loadingMsg: "正在提交...");
                        if (result == null) {
                          Nav.back();
                        }
                      },
                      child: Container(
                        margin: EdgeInsets.only(bottom: height(36)),
                        alignment: Alignment.center,
                        width: width(48),
                        height: width(48),
                        decoration: BoxDecoration(
                            color: backgroundGray,
                            shape: BoxShape.circle,
                            boxShadow:
                                getBoxShadows(Colors.black12, blurRadius: 2)),
                        child: Image.asset(
                          "assets/images/upload.png",
                          fit: BoxFit.fitWidth,
                        ),
                      ),
                    ),
                  )
                : Container()
          ],
        ),
      ),
    );
  }
}
