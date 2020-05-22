import 'package:flare_flutter/flare_actor.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lazycook/core/viewmodels/base_model.dart';
import 'package:lazycook/ui/shared/styles.dart';
import 'package:lazycook/utils/logger.dart';

import 'typedef.dart';

///容器
class LoadContainer extends StatelessWidget {
  final ViewState state; //组建状态
  final BoxDecoration decoration; //布局样式
  final double width;
  final double height;
  final double iconWidth; //错误描述图片宽度
  final double iconHeight; //错误描述图片高度
  final Alignment align;
  final Function retry; //重试回调
  final ViewCreateFunc content;
  final ViewCreateFunc loadView;
  final ViewCreateFunc errorView;
  final ViewCreateFunc emptyView;
  final ViewCreateFunc idleView;
  final String emptyText; //空描述
  final String errorText; //错误描述
  final String retryText; //重试按钮文字
  final String errorImageRes; //错误图片描述
  final bool showLoadingIndicator; //是否现实加载动画
  final bool wrapHeight; //高度自适应

  final Logger logger = new Logger("LoadContainer");

  LoadContainer(
      {@required this.state,
      this.decoration,
      this.height = double.infinity,
      this.width = double.infinity,
      this.align = Alignment.center,
      this.retry,
      this.content,
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
      this.showLoadingIndicator = true,
      this.wrapHeight = false});

  @override
  Widget build(BuildContext context) {
    Widget view = getView(context);
    return wrapHeight || height <= 0
        ? Container(
            width: width,
            alignment: align,
            decoration: decoration,
            child: view,
          )
        : Container(
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
      case ViewState.IDLE:
        return idleView != null
            ? idleView(context)
            : Container(
                decoration: decoration,
                width: width,
              );
      case ViewState.LOADING:
        return Container(
          width: width,
          alignment: Alignment.center,
          child: Stack(
            alignment: AlignmentDirectional.center,
            children: <Widget>[
              loadView != null ? loadView(context) : Container(),
              showLoadingIndicator
                  ? Center(
                      child: SizedBox(
//                        width: ScreenUtil.getInstance().setWidth(36),
//                        height: ScreenUtil.getInstance().setWidth(36),
//                        child: CircularProgressIndicator(),
                        child: FlareActor(
                          "assets/flare/loading.flr",
                          alignment: Alignment.center,
                          fit: BoxFit.cover,
                          animation: "loading",
                        ),
                      ),
                    )
                  : Container(),
            ],
          ),
        );
      case ViewState.SUCCESS:
        return content != null
            ? content(context)
            : Container(
                decoration: decoration,
                width: width,
                alignment: Alignment.center,
                child: Text(
                  'no content view',
                  style: textStyle(
                      fontSize: ScreenUtil.getInstance().setSp(12),
                      color: Theme.of(context).accentColor),
                ),
              );
      case ViewState.FAILED:
        return errorView != null
            ? errorView(context)
            : Container(
                decoration: decoration,
                width: width,
                alignment: Alignment.center,
                child: InkWell(
                  onTap: retry,
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
                            color: Theme.of(context).errorColor),
                      ),
                      SizedBox(
                        height: ScreenUtil.getInstance().setHeight(6),
                      ),
                      Text(
                        retryText != null && retryText.isNotEmpty
                            ? retryText
                            : '点击重试',
                        style: textStyle(
                            fontSize: ScreenUtil.getInstance().setSp(12),
                            color: Theme.of(context).accentColor),
                      )
                    ],
                  ),
                ),
              );
      case ViewState.EMPTY_DATA:
        return emptyView != null
            ? emptyView(context)
            : Container(
                decoration: decoration,
                width: width,
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
