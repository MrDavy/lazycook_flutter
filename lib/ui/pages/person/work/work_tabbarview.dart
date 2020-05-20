import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:lazycook/config/config.dart';
import 'package:lazycook/core/models/dish.dart';
import 'package:lazycook/core/viewmodels/person/works_model.dart';
import 'package:lazycook/ui/route/nav.dart';
import 'package:lazycook/ui/route/routers.dart';
import 'package:lazycook/ui/shared/colors.dart';
import 'package:lazycook/ui/shared/styles.dart';
import 'package:lazycook/ui/widgets/common_skeleton.dart';
import 'package:lazycook/ui/widgets/custom_state.dart';
import 'package:lazycook/ui/widgets/provider_widget.dart';
import 'package:lazycook/ui/widgets/slide_list_container.dart';
import 'package:lazycook/ui/widgets/slidemenu/slide_menu.dart';
import 'package:provider/provider.dart';

///
/// 作品列表页
class WorkTabBarView extends StatefulWidget {
  final int type;

  const WorkTabBarView({Key key, this.type}) : super(key: key);

  @override
  WorkTabBarViewState createState() => new WorkTabBarViewState();
}

class WorkTabBarViewState extends CustomState<WorkTabBarView> {
  WorksModel _worksModel;
  EasyRefreshController _controller;

  @override
  void initState() {
    super.initState();
    _worksModel = WorksModel(Provider.of(context, listen: false));
    _controller = EasyRefreshController();
  }

  @override
  bool keepAlive() {
    return true;
  }

  @override
  Widget buildWidget(BuildContext context) {
    return ProviderWidget<WorksModel>(
      model: _worksModel,
      onModelReady: (model) {
        refresh(init: true);
      },
      builder: (context, model, child) {
        return Container(
            child: SlideListContainer<Dish>(
          state: model.state,
          model: _worksModel,
          controller: _controller,
          onItemTap: (index) {
            Nav.pageTo(context, Routers.recipe_detail, param: {
              'did': _worksModel.list[index].data.id,
              'album': _worksModel.list[index].data.album,
              'title': _worksModel.list[index].data.title,
              "scence": "collection"
            });
          },
          padding:
              EdgeInsets.symmetric(horizontal: width(12), vertical: width(12)),
          separatorBuilder: (context, index) => Container(
            height: width(12),
          ),
          child: (index) {
            return Container(
              color: white,
              child: _buildListItem(model.list[index].data),
            );
          },
          menus: (index) {
            return _buildItemMenus(index);
          },
          retry: () {
            refresh(init: false);
          },
          loadView: (context) => buildListSkeleton(),
          errorText: model?.error?.message,
          onLoad: model.hasNext
              ? () async {
                  await refresh(init: false);
                  _controller.finishLoad(noMore: !model.hasNext);
                }
              : null,
          onRefresh: () async {
            return refresh(init: true);
          },
          onLoadMoreFailed: () {
            showToast(model.error.message);
          },
        ));
      },
    );
  }

  List<SlideMenu> _buildItemMenus(int index) {
    List<Opt> opts = _worksModel.list[index].data.opt;
    if (opts == null || opts.isEmpty) return null;
    Color bgColor = accentColor;
    Widget widget;
    if (opts.length == 1) {
      widget = InkWell(
        onTap: () async {
          onOptTap(opts[0].type, index);
        },
        child: Center(
          child: Text(
            opts[0].txt,
            style: textStyle(
                fontSize: sp(14), fontWeight: FontWeight.w400, color: white),
          ),
        ),
      );
      bgColor = Color.fromARGB(
          opts[0].alpha, opts[0].red, opts[0].green, opts[0].blue);
    } else if (opts.length == 2) {
      List<Widget> children = opts
          .map((opt) => _buildOptButton(opt.txt,
                  Color.fromARGB(opt.alpha, opt.red, opt.green, opt.blue),
                  onTap: () {
                onOptTap(opt.type, index);
              }))
          .toList();
      children.insert(
          1,
          SizedBox(
            height: height(10),
          ));
      widget = Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: children,
      );
    }
    return [
      SlideMenu(
        height: height(90),
        width: width(90),
        decoration: BoxDecoration(color: bgColor),
        child: widget,
      )
    ];
  }

  Widget _buildOptButton(text, color, {VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.only(
            left: width(12),
            top: height(6),
            right: width(12),
            bottom: height(6)),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(24),
          boxShadow:
              getBoxShadows(Colors.black12, blurRadius: 0.5, spreadRadius: 0.5),
        ),
        child: Text(
          text,
          style: textStyle(
              fontSize: sp(13), fontWeight: FontWeight.w400, color: white),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _buildListItem(Dish item) {
    var ingredients = StringBuffer();
    item.materials?.forEach((Materials m) {
      if (m.type == 1) {
        ingredients.write(m.name);
        ingredients.write(",");
      }
    });
    var ingreStr = ingredients.toString();
    if (ingreStr.length > 1) {
      ingreStr = ingreStr.substring(0, ingreStr.length - 1);
    }
    return Container(
      height: height(90),
      child: Row(
        children: <Widget>[
          ClipRRect(
            borderRadius: BorderRadius.all(Radius.circular(width(6))),
            child: CachedNetworkImage(
              fit: BoxFit.fill,
              placeholder: (context, url) => Container(
                height: double.infinity,
                width: width(120),
                decoration: BoxDecoration(
                    color: skeletonGray,
                    borderRadius: BorderRadius.all(Radius.circular(width(6)))),
              ),
              height: height(90),
              width: width(120),
              imageUrl: Config.envConfig().imgBasicUrl() + item.album,
            ),
          ),
          Flexible(
              child: Container(
            margin: EdgeInsets.only(left: width(10), bottom: height(10)),
            height: double.infinity,
            child: Column(
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Flexible(
                        child: Text(
                      item.title,
                      style: textStyle(
                          color: textColor,
                          fontSize: sp(16),
                          fontWeight: bold),
                      softWrap: false,
                      overflow: TextOverflow.fade,
                      maxLines: 1,
                    )),
                    SizedBox(
                      height: height(4),
                    ),
                    Flexible(
                        child: Text(
                      ingreStr.toString(),
                      style: textStyle(
                          color: Colors.grey.shade500,
                          fontSize: sp(12),
                          fontWeight: FontWeight.w400),
                      softWrap: false,
                      overflow: TextOverflow.fade,
                      maxLines: 1,
                    )),
                  ],
                ),
                Flexible(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        "发布时间：${item.date}",
                        style: textStyle(
                            color: color_666,
                            fontSize: sp(12),
                            fontWeight: FontWeight.w400),
                      )
                    ],
                  ),
                )
              ],
            ),
          ))
        ],
      ),
    );
  }

  Future refresh({bool init = false}) async {
    try {
      await _worksModel
          ?.refresh(init: init, params: {"type": "${widget.type}"});
    } catch (error) {
      logger.log("异常：" + error.message);
      showToast(error.message);
    }
  }

  ///type：1删除，2下架，3修改
  void onOptTap(int type, int index) {
    _worksModel?.closeLast();
    switch (type) {
      case 1:
      case 2:
        showOptDialog(index, type);
        break;
      case 3:
        showToast("修改");
        break;
    }
  }

  showOptDialog(index, type) {
    showCustomDialog(
      context: context,
      dialogType: DialogType.GENERAL,
      alignment: Alignment.center,
      msg: type == 1 ? "删除后您的该作品将永久消失，是否继续？" : "作品下架后，修改后可以重新上架",
      cancelText: type == 1 ? "否" : "取消",
      confirmText: type == 1 ? "是" : "确定",
      onCancel: () {
        Nav.back();
      },
      onConfirm: () {
        Nav.back();
        showLoading("");
        _worksModel.workOpt(index, type).then((v) {
          hideLoading();
        }).catchError((e) {
          hideLoading();
        });
      },
    );
//    showDialog(
//        context: context,
//        builder: (_) {
//          return CustomDialog(
//            alignment: Alignment.center,
//            msg: type == 1 ? "删除后您的该作品将永久消失，是否继续？" : "作品下架后，修改后可以重新上架",
//            cancelText: type == 1 ? "否" : "取消",
//            confirmText: type == 1 ? "是" : "确定",
//            onCancel: () {
//              Nav.backForMap(context);
//            },
//            onConfirm: () {
//              Nav.backForMap(context);
//              showLoading("");
//              _worksModel.workOpt(index, type).then((v) {
//                hideLoading();
//              }).catchError((e) {
//                hideLoading();
//              });
//            },
//          );
//        });
  }
}
