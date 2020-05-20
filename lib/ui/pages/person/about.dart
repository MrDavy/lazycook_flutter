import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lazycook/application.dart';
import 'package:lazycook/core/models/result_data.dart';
import 'package:lazycook/core/models/version_info.dart';
import 'package:lazycook/core/request/exception/error.dart';
import 'package:lazycook/core/viewmodels/person/about.dart';
import 'package:lazycook/ui/route/nav.dart';
import 'package:lazycook/ui/route/routers.dart';
import 'package:lazycook/ui/shared/colors.dart';
import 'package:lazycook/ui/shared/styles.dart';
import 'package:lazycook/ui/widgets/custom_state.dart';
import 'package:lazycook/ui/widgets/main_widget.dart';
import 'package:lazycook/utils/fluro/src/common.dart';
import 'package:lazycook/utils/utils.dart';
import 'package:package_info/package_info.dart';
import 'package:provider/provider.dart';

///
/// 关于我们
///
class AboutPage extends StatefulWidget {
  @override
  _AboutPageState createState() => _AboutPageState();
}

class _AboutPageState extends CustomState<AboutPage> {
  AboutModel _aboutModel;

  @override
  void initState() {
    super.initState();
    _aboutModel = Provider.of<AboutModel>(context, listen: false);
  }

  @override
  Widget buildWidget(BuildContext context) {
    return Scaffold(
      body: MainWidget(
        statusBarColor: white,
        titleColor: Colors.black,
        leadingColor: Colors.black,
        headerDecoration: BoxDecoration(color: white),
        title: "",
        child: ChangeNotifierProvider<AboutModel>.value(
          value: _aboutModel,
          child: Container(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Expanded(
                  child: ListView(
                    padding: EdgeInsets.only(top: height(50)),
                    shrinkWrap: true,
                    physics: ScrollPhysics(),
                    children: <Widget>[
                      Image.asset(
                        "assets/images/icon-app.png",
                        width: 152,
                        height: 152,
                      ),
                      Container(
                        alignment: Alignment.center,
                        child: Text(
                          "Version ${Application.packageInfo?.version ?? ""}",
                          style: textStyle(
                              color: textColor,
                              fontSize: sp(14),
                              fontWeight: bold),
                        ),
                      ),
                      Consumer<AboutModel>(builder: (context, model, _) {
                        return InkWell(
                          onTap: () async {
                            showLoading("检查版本...");
                            ResultData result = await model.checkVersion();
                            hideLoading();
                            if (result.error != null) {
                              showToast(result.error.message);
                            } else {
                              showVersionUpdateDialog(result.data);
                            }
                          },
                          child: Container(
                            margin: EdgeInsets.symmetric(
                                horizontal: width(28), vertical: height(40)),
                            height: height(48),
                            decoration: BoxDecoration(
                                border: Border(
                                    top: BorderSide(
                                        color: Color(0xafcccccc), width: 0.5),
                                    bottom: BorderSide(
                                        color: Color(0xafcccccc), width: 0.5))),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Text(
                                  "版本更新",
                                  style: textStyle(
                                      color: textColor,
                                      fontSize: sp(16),
                                      fontWeight: FontWeight.w400),
                                ),
                                Icon(
                                  Icons.chevron_right,
                                  size: width(28),
                                  color: color_999,
                                )
                              ],
                            ),
                          ),
                        );
                      })
                    ],
                  ),
                  flex: 1,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  bool darkStatusBar() {
    return true;
  }
}
