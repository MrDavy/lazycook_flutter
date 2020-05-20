import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'dart:math' as math;

import 'package:lazycook/ui/shared/colors.dart';
import 'package:lazycook/ui/shared/styles.dart';
import 'package:lazycook/utils/utils.dart';

//  @desc 状态栏，兼容android和ios
//  @author Davy
//  @date 2019/7/31 14:44

typedef ClickLeadingCallback = Function();

class MainWidget extends StatelessWidget {
  Widget child;
  Widget header;
  Widget statusBar;
  Widget leading;
  Widget divider;
  List<Widget> actions;
  Color statusBarColor;
  Color leadingColor;
  bool transparent;
  bool headerFloat;
  bool noStatusBar;
  bool hideStatusBar; //隐藏状态栏，位置仍然在
  bool noHeader;
  bool noLeading;
  BoxDecoration decoration;
  BoxDecoration headerDecoration;
  ClickLeadingCallback onLeadingTap;
  String title;
  Color titleColor;
  TextStyle titleStyle;
  num headerHeight;

  double _top;

  MainWidget(
      {this.child,
      this.header,
      this.statusBar,
      this.headerHeight,
      this.statusBarColor = Colors.transparent,
      this.leadingColor = Colors.white,
      this.titleColor = Colors.white,
      this.decoration,
      this.headerDecoration,
      this.leading,
      this.onLeadingTap,
      this.headerFloat = false,
      this.noStatusBar = false,
      this.hideStatusBar = false,
      this.noLeading = false,
      this.title = "标题",
      this.titleStyle,
      this.actions,
      this.divider,
      this.noHeader = false});

  @override
  Widget build(BuildContext context) {
    _top = Utils.statusBarHeight(context);
    Widget topbar = Container(
      width: double.infinity,
      height: _top,
      color: statusBarColor,
      child: statusBar ?? Container(),
    );

    List<Widget> _list = <Widget>[];
    if (!noStatusBar) {
      _list.add(topbar);
    }
    if (!noHeader && headerFloat) {
      Widget content = Expanded(
        child: Stack(
          children: <Widget>[
            Container(
              child: child,
            ),
            _buildHeader(context)
          ],
        ),
      );
      _list.add(content);
    } else {
      if (!noHeader) _list.add(_buildHeader(context));
      if (divider != null) {
        _list.add(divider);
      }
      _list.add(Expanded(
        child: Container(
          child: child,
        ),
      ));
    }

    return Container(
        decoration: decoration ?? BoxDecoration(color: white),
        child: Flex(
          direction: Axis.vertical,
          children: _list,
        ));
  }

  Widget _buildHeader(context) {
    List<Widget> views = [];
    if (!noLeading) {
      if (leading == null) {
        leading = _defaultLeading(context);
      }
      views.add(leading);
    }
    views.add(Expanded(
      child: Container(),
    ));
    if (actions != null && actions.isNotEmpty) {
      views.addAll(actions);
    }
    var margin = 0.0;
    if (!noStatusBar && hideStatusBar) {
      margin = _top;
    }
    return Container(
      height: headerHeight ?? ScreenUtil.getInstance().setHeight(48),
      margin: EdgeInsets.only(top: margin),
      decoration: headerDecoration,
      alignment: Alignment.center,
      child: Stack(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[...views],
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Expanded(
                child: Center(
                  child: header != null
                      ? header
                      : Text(
                          title,
                          style: titleStyle != null
                              ? titleStyle
                              : textStyle(
                                  color: titleColor ?? Colors.white,
                                  fontSize: ScreenUtil.getInstance().setSp(18),
                                  fontWeight: bold,
                                ),
                        ),
                ),
              )
            ],
          ),
        ],
      ),
    );
  }

  Widget _defaultLeading(context) => Container(
        height: ScreenUtil.getInstance().setHeight(48),
        width: ScreenUtil.getInstance().setWidth(48),
        child: InkWell(
          onTap: onLeadingTap != null
              ? onLeadingTap
              : () {
                  Navigator.pop(context);
                },
          child: Icon(
            Icons.arrow_back_ios,
            size: ScreenUtil.getInstance().setWidth(24),
            color: leadingColor,
          ),
        ),
      );
}
