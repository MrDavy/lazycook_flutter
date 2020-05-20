import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lazycook/core/request/exception/error.dart';
import 'package:lazycook/core/viewmodels/person/settings.dart';
import 'package:lazycook/ui/route/nav.dart';
import 'package:lazycook/ui/shared/colors.dart';
import 'package:lazycook/ui/widgets/button.dart';
import 'package:lazycook/ui/widgets/custom_state.dart';
import 'package:lazycook/ui/widgets/main_widget.dart';
import 'package:lazycook/ui/widgets/provider_widget.dart';
import 'package:provider/provider.dart';

///
/// 设置
///
class SettingsPage extends StatefulWidget {
  SettingsPage({Key key}) : super(key: key);

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends CustomState<SettingsPage> {
  SettingsModel _settingsModel;

  @override
  void initState() {
    super.initState();
    _settingsModel = SettingsModel(api());
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
//        decoration: BoxDecoration(gradient: defaultGradient(context)),
        title: "设置",
        child: ProviderWidget<SettingsModel>(
          model: _settingsModel,
          onModelReady: (model) {},
          builder: (context, model, _) {
            return Container(
              child: Column(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Container(),
                  Button(
                    text: "退出登陆",
                    width: double.infinity,
                    margin: EdgeInsets.fromLTRB(
                        width(16), height(22), width(16), height(50)),
                    accentColor: warnColor,
                    onPressed: () async {
                      var result = await simpleFuture(model.logout(),
                          loadingMsg: "退出登录...");
                      if (result == null) {
                        Nav.back();
                      } else {
                        if (result is LazyError) {
                          showToast(result.message);
                        }
                      }
                    },
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

const List<Menu> menus = [
  const Menu(type: 1, title: "个人信息", iconPath: ""),
  const Menu(type: 2, title: "地址管理", iconPath: ""),
  const Menu(type: 3, title: "安全设置", iconPath: ""),
];

class Menu {
  final int type;
  final String title;
  final String iconPath;

  const Menu({this.type, this.title, this.iconPath});
}
