import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:lazycook/config/config.dart';
import 'package:lazycook/core/models/dish.dart';
import 'package:lazycook/core/services/api.dart';
import 'package:lazycook/core/viewmodels/person/collection.dart';
import 'package:lazycook/ui/route/nav.dart';
import 'package:lazycook/ui/route/routers.dart';
import 'package:lazycook/ui/shared/colors.dart';
import 'package:lazycook/ui/shared/styles.dart';
import 'package:lazycook/ui/widgets/common_skeleton.dart';
import 'package:lazycook/ui/widgets/custom_state.dart';
import 'package:lazycook/ui/widgets/list_container.dart';
import 'package:lazycook/ui/widgets/main_widget.dart';
import 'package:lazycook/ui/widgets/provider_widget.dart';
import 'package:lazycook/ui/widgets/slidemenu/slide_item.dart';
import 'package:lazycook/ui/widgets/slidemenu/slide_menu.dart';
import 'package:lazycook/ui/widgets/slidemenu/slide_model.dart';
import 'package:provider/provider.dart';

///
/// 收藏
///
class CollectionPage extends StatefulWidget {
  CollectionPage({Key key}) : super(key: key);

  @override
  _CollectionPageState createState() => _CollectionPageState();
}

class _CollectionPageState extends CustomState<CollectionPage>
    with SingleTickerProviderStateMixin {
  CollectionModel _collectionModel;
  EasyRefreshController _controller;
  ScrollController _scrollController;
  double maxDistance = -120;
  double minMoveDistance = 30;
  double minMoveSpeed = 200;

  @override
  void initState() {
    super.initState();
    _collectionModel =
        CollectionModel(Provider.of<API>(context, listen: false));
    _controller = EasyRefreshController();
    _scrollController = ScrollController()
      ..addListener(() {
        _collectionModel?.closeLast();
      });
  }

  @override
  Widget buildWidget(BuildContext context) {
    return Scaffold(
        body: ChangeNotifierProvider<CollectionModel>(
      create: (context) => _collectionModel,
      child: MainWidget(
        title: "我的收藏",
//        decoration: BoxDecoration(color: white),
        decoration: BoxDecoration(gradient: defaultGradient(context)),
//        statusBarColor: accentColor,
//        headerDecoration: BoxDecoration(color: accentColor),
        child: Container(
          color: white,
          child: ProviderWidget<CollectionModel>(
            model: _collectionModel,
            onModelReady: (model) {
              refresh(init: true);
            },
            builder: (context, model, child) {
              var list = model.list;
              return Container(
                child: ListContainer(
                  state: model.state,
                  controller: _controller,
                  scrollController: _scrollController,
                  itemCount: list?.length ?? 0,
                  padding: EdgeInsets.symmetric(
                      horizontal: width(12), vertical: width(12)),
                  separatorBuilder: (context, index) => Container(
                    height: width(12),
                  ),
                  itemBuilder: (context, index) {
                    return Container(
                      child: ChangeNotifierProvider<CollectedDish>.value(
                        value: list[index],
                        child: Consumer<CollectedDish>(
                          builder: (context, model, _) {
                            ///注意：当列表带分页的时候，每次notifyListeners()的时候，
                            ///已经加载的item是会重复利用的，因此这里不能给已经加载的item配置新的controller
                            ///如果删除了或增加了item项，需要重新配置controller
//                          logger.log(
//                              "build index = $index，lastState = ${model?.controller?.getLastState()}，"
//                              "openState = ${model?.controller?.getOpenState()}，"
//                              "_openedPos = ${_collectionModel.openedPos}");
                            if (model.controller == null ||
                                _collectionModel.uncollected) {
                              var controller = SlideController()
                                ..addListener((state) {
                                  if (state == OpenState.OPEN) {
                                    _collectionModel?.open(index);
//                                  logger.log("打开了 $index");
                                  } else if (state == OpenState.START) {
//                                  logger.log("开始了 $index");
                                    if (_collectionModel?.openedPos != index) {
                                      _collectionModel?.closeLast();
                                    }
                                  } else if (state == OpenState.CLOSE) {
                                    //logger.log("关闭了 $index");
                                    _collectionModel?.close(index);
                                  }
                                });
                              model.controller = controller;
                            }
                            return SlideItem(
                              controller: model.controller,
                              onTap: () {
                                //logger.log("onTap pos = ${_collectionModel?.openedPos}");
                                if (_collectionModel?.openedPos != -1) {
                                  _collectionModel?.closeLast();
                                } else {
                                  Nav.pageTo(context, Routers.recipe_detail,
                                      param: {
                                        'did': list[index].dish.id,
                                        'album': list[index].dish.album,
                                        'title': list[index].dish.title,
                                        "scence": "collection"
                                      });
                                }
                              },
                              height: height(90),
                              menus: [
                                SlideMenu(
                                  height: height(90),
                                  width: width(90),
                                  decoration: BoxDecoration(color: Colors.red),
                                  child: InkWell(
                                    onTap: () async {
                                      _collectionModel?.closeLast();
                                      var result = await simpleFuture(
                                          _collectionModel
                                              ?.delCollection(index));
                                      if (result == null) {
                                        showToast("取消成功");
                                      }
                                    },
                                    child: Center(
                                      child: Icon(
                                        Icons.delete_forever,
                                        color: Colors.white,
                                        size: width(36),
                                      ),
                                    ),
                                  ),
                                )
                              ],
                              child: Container(
                                color: white,
                                child: _buildListItem(model.dish),
                              ),
                            );
                          },
                        ),
                      ),
                    );
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
                ),
              );
            },
          ),
        ),
      ),
    ));
  }

  Future refresh({bool init = false}) async {
    try {
      await _collectionModel?.refresh(init: init);
    } catch (error) {
      logger.log("异常：" + error.message);
      showToast(error.message);
    }
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
                        "收藏时间：${item.date}",
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
}
