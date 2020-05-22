import 'dart:math';

import 'package:flutter/material.dart';
import 'package:lazycook/application.dart';
import 'package:lazycook/core/models/home_info.dart';
import 'package:lazycook/core/viewmodels/home/home.dart';
import 'package:lazycook/core/viewmodels/person/works_model.dart';
import 'package:lazycook/ui/pages/person/work/work_tabbarview.dart';
import 'package:lazycook/ui/route/nav.dart';
import 'package:lazycook/ui/route/routers.dart';
import 'package:lazycook/ui/shared/colors.dart';
import 'package:lazycook/ui/shared/styles.dart';
import 'package:lazycook/ui/widgets/base_state.dart';
import 'package:lazycook/ui/widgets/custom_state.dart';
import 'package:lazycook/ui/widgets/main_widget.dart';
import 'package:lazycook/ui/widgets/provider_widget.dart';
import 'package:lazycook/ui/widgets/slidemenu/slide_menu.dart';
import 'package:lazycook/ui/widgets/slidemenu/slide_item.dart';
import 'package:lazycook/ui/widgets/slidemenu/slide_model.dart';
import 'package:provider/provider.dart';

///
/// 我的作品
///
class WorksPage extends StatefulWidget {
  WorksPage({Key key}) : super(key: key);

  @override
  _WorksPageState createState() => _WorksPageState();
}

class _WorksPageState extends CustomState<WorksPage>
    with SingleTickerProviderStateMixin {
  WorksModel _worksModel;
  TabController _tabController;

  @override
  void initState() {
    super.initState();
    _worksModel = WorksModel(Provider.of(context, listen: false));
    _tabController = TabController(length: tabs.length, vsync: this)
      ..addListener(() {});
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget buildWidget(BuildContext context) {
    return Scaffold(
      body: ChangeNotifierProvider(
        create: (context) => _worksModel,
        child: MainWidget(
          title: "我的作品",
          decoration: BoxDecoration(gradient: defaultGradient(context)),
//          decoration: BoxDecoration(color: white),
//          statusBarColor: themeAccentColor,
//          headerDecoration: BoxDecoration(color: themeAccentColor),
          child: Container(
            color: white,
            child: ProviderWidget(
              model: _worksModel,
              onModelReady: (model) {},
              builder: (context, model, child) {
                return buildContentView();
              },
            ),
          ),
          actions: <Widget>[
            Application.homeBasicInfo != null &&
                    Application.homeBasicInfo.canAdd
                ? SizedBox(
                    width: width(48),
                    height: height(36),
                    child: InkWell(
                      onTap: () {
                        Nav.pageTo(context, Routers.works_new);
                      },
                      child: Container(
                        child: Center(
                          child: Image.asset(
                            "assets/images/add-recipe.png",
                            width: width(26),
                            height: width(26),
                          ),
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

  Widget buildContentView() {
    return Container(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          _buildTabBar(),
          Container(
            height: height(8),
            color: gray,
          ),
          _buildTabView()
        ],
      ),
    );
  }

  Widget _buildTabView() {
    return Expanded(
        child: TabBarView(
            controller: _tabController,
            children: tabs
                .map((tab) => WorkTabBarView(
                      type: tab.index,
                    ))
                .toList()));
  }

  Widget _buildTabBar() {
    return TabBar(
        controller: _tabController,
        labelPadding: EdgeInsets.symmetric(vertical: height(4)),
        labelColor: themeAccentColor,
        labelStyle: textStyle(
          fontSize: sp(16),
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelColor: color_999,
        unselectedLabelStyle: textStyle(
          fontSize: sp(16),
          fontWeight: bold,
        ),
        indicatorColor: themeAccentColor,
        indicatorPadding: EdgeInsets.symmetric(horizontal: width(10)),
        indicatorSize: TabBarIndicatorSize.label,
        isScrollable: false,
        tabs: tabs
            .map((Choice tap) => Tab(
                  text: tap.title,
                ))
            .toList());
  }
}

const List<Choice> tabs = const <Choice>[
  const Choice("已发布", 0),
  const Choice("审核中", 1),
  const Choice("待处理", 2),
];

class Choice {
  final String title;
  final int index;

  const Choice(this.title, this.index);
}
