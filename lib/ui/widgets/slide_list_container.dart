import 'package:flare_flutter/flare_actor.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lazycook/core/viewmodels/base_model.dart';
import 'package:lazycook/ui/shared/styles.dart';
import 'package:lazycook/ui/widgets/easy_refresh_header.dart';
import 'package:lazycook/ui/widgets/slidemenu/slide_menu.dart';
import 'package:lazycook/ui/widgets/slidemenu/slide_list.dart';
import 'package:lazycook/ui/widgets/slidemenu/slide_list_model.dart';
import 'package:lazycook/ui/widgets/typedef.dart';
import 'package:lazycook/utils/logger.dart';

///容器
class SlideListContainer<T> extends StatelessWidget {
  final PageViewState state;
  final BoxDecoration decoration;
  final double width;
  final double height;
  final double iconWidth;
  final double iconHeight;
  final Alignment align;

  final ViewCreateFunc loadView;
  final ViewCreateFunc errorView;
  final ViewCreateFunc emptyView;
  final ViewCreateFunc idleView;
  final ViewCreateFunc refreshHeader;
  final ViewCreateFunc refreshFooter;

  final String emptyText;
  final String errorText;
  final String retryText;
  final String errorImageRes;

  final Function onLoadMoreFailed;
  final Function retry;
  final Function onLoad;
  final Function onRefresh;
  final EasyRefreshController controller;
  final bool showLoadingIndicator; //是否现实加载动画

  final IndexedWidgetBuilder separatorBuilder;
  final EdgeInsetsGeometry padding;
  final SlideListModel model;
  final WidgetsCreator menus;
  final WidgetCreator child;
  final OnItemTap onItemTap;

  final Logger logger = new Logger("ListContainer");

  SlideListContainer(
      {@required this.state,
      this.decoration,
      this.height = double.infinity,
      this.width = double.infinity,
      this.align = Alignment.center,
      this.retry,
      this.loadView,
      this.emptyView,
      this.errorView,
      this.idleView,
      this.emptyText = "数据君迷路了~ o(╯□╰)o",
      this.errorText = "呀~，出错了 o(╯□╰)o",
      this.retryText,
      this.iconWidth = 0,
      this.iconHeight = 0,
      this.errorImageRes = "assets/images/icon-default-search.png",
      this.onLoad,
      this.onRefresh,
      this.refreshHeader,
      this.refreshFooter,
      this.controller,
      this.separatorBuilder,
      this.padding = const EdgeInsets.all(0),
      this.onLoadMoreFailed,
      this.showLoadingIndicator = true,
      this.model,
      this.menus,
      this.child,
      this.onItemTap});

  @override
  Widget build(BuildContext context) {
    Widget view = getView(context);
    return Container(
      width: width,
      height: height,
      alignment: align,
      decoration: decoration,
      child: view,
    );
  }

  ///根据状态显示对应布局
  Widget getView(context) {
    switch (state) {
      case PageViewState.IDLE:
        return idleView != null
            ? idleView(context)
            : Container(
                decoration: decoration,
                width: width,
                height: height,
              );
      case PageViewState.FIRST_PAGE_LOADING:
        return Container(
          alignment: Alignment.center,
          child: Stack(
            children: <Widget>[
              loadView != null ? loadView(context) : Container(),
              showLoadingIndicator
                  ? Center(
                      child: SizedBox(
                        child: FlareActor(
                          "assets/flare/loading.flr",
                          alignment: Alignment.center,
                          animation: "loading",
                        ),
                      ),
                    )
                  : Container(),
            ],
          ),
        );
//      case PageViewState.LOADING:
//      case PageViewState.NO_MORE_DATA:
//      case PageViewState.FAILED: //加载更多失败
      case PageViewState.SUCCESS:
        return SlideListView<T>(
          controller: controller,
          separatorBuilder: separatorBuilder,
          refreshHeader: refreshHeader,
          refreshFooter: refreshFooter,
          emptyView: emptyView,
          model: model,
          padding: padding,
          menus: menus,
          onTap: onItemTap,
          child: child,
          onRefresh: state == PageViewState.LOADING ? null : onRefresh,
          onLoad: onLoad,
        );
      case PageViewState.FIRST_PAGE_LOAD_FAILED:
        return errorView != null
            ? errorView(context)
            : Container(
                decoration: decoration,
                width: width,
                height: height,
                alignment: Alignment.center,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Image(
                      alignment: Alignment.center,
                      width: iconWidth > 0
                          ? iconWidth
                          : ScreenUtil.getInstance().setWidth(128),
                      height: iconHeight > 0
                          ? iconHeight
                          : ScreenUtil.getInstance().setWidth(128),
                      image: AssetImage(errorImageRes),
                    ),
                    SizedBox(
                      height: ScreenUtil.getInstance().setHeight(4),
                    ),
                    Text(
                      errorText,
                      style: textStyle(
                          fontSize: ScreenUtil.getInstance().setSp(12),
                          color: Theme.of(context).accentColor),
                    ),
                    SizedBox(
                      height: ScreenUtil.getInstance().setHeight(6),
                    ),
                    FlatButton(
                      onPressed: retry,
                      child: Text(
                        retryText != null && retryText.isNotEmpty
                            ? retryText
                            : '点击重试',
                        style: textStyle(
                            fontSize: ScreenUtil.getInstance().setSp(12),
                            color: Theme.of(context).accentColor),
                      ),
                    )
                  ],
                ),
              );
      case PageViewState.EMPTY_DATA:
        return emptyView != null
            ? emptyView(context)
            : Container(
                decoration: decoration,
                width: width,
                height: height,
                alignment: Alignment.center,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Image(
                      alignment: Alignment.center,
                      width: iconWidth > 0
                          ? iconWidth
                          : ScreenUtil.getInstance().setWidth(128),
                      height: iconHeight > 0
                          ? iconHeight
                          : ScreenUtil.getInstance().setWidth(128),
                      image: AssetImage(errorImageRes),
                    ),
                    SizedBox(
                      height: ScreenUtil.getInstance().setHeight(4),
                    ),
                    Text(
                      emptyText,
                      style: textStyle(
                          fontSize: ScreenUtil.getInstance().setSp(12),
                          color: Theme.of(context).accentColor),
                    ),
                  ],
                ));
      default:
        return Center(
          child: Text('状态走丢了~ o(╯□╰)o'),
        );
    }
  }
}
