import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:lazycook/config/config.dart';
import 'package:lazycook/core/models/dish.dart';
import 'package:lazycook/core/models/search_info.dart';
import 'package:lazycook/core/services/api.dart';
import 'package:lazycook/core/viewmodels/home/search/recipe_list.dart';
import 'package:lazycook/core/viewmodels/home/search/recipe_list_view_type.dart';
import 'package:lazycook/core/viewmodels/home/search/search_info.dart';
import 'package:lazycook/ui/route/nav.dart';
import 'package:lazycook/ui/route/routers.dart';
import 'package:lazycook/ui/shared/colors.dart';
import 'package:lazycook/ui/shared/styles.dart';
import 'package:lazycook/ui/widgets/custom_state.dart';
import 'package:lazycook/ui/widgets/icon_text.dart';
import 'package:lazycook/ui/widgets/list_container.dart';
import 'package:lazycook/ui/widgets/load_container.dart';
import 'package:lazycook/ui/widgets/main_widget.dart';
import 'package:lazycook/ui/widgets/provider_widget.dart';
import 'package:lazycook/ui/widgets/search_textview.dart';
import 'package:lazycook/ui/widgets/skeleton/icon_text_skeleton.dart';
import 'package:lazycook/utils/string_utils.dart';
import 'package:provider/provider.dart';

/*
 * 搜索页（优化版本）
 * 采用多个Provider分解布局控件，降低组件刷新颗粒度，减少组件刷新时的多余性能损耗
 */
class RecipeListWidget extends StatefulWidget {
  final String keyword;
  final String scence;
  final bool directSearch;

  const RecipeListWidget(
      {this.keyword = '', this.scence = "home", this.directSearch = false});

  @override
  RecipeListWidgetState createState() => new RecipeListWidgetState();
}

class RecipeListWidgetState extends CustomState<RecipeListWidget> {
  static const MAX_SHOWING = 12;

  TextEditingController _textEditingController;
  EasyRefreshController _controller;
  FocusNode _contentFocusNode = FocusNode();
  BuildContext providerContext;
  BuildContext _listViewContext;
  BuildContext _searchViewContext;

  SearchInfoModel _searchInfoModel;

  @override
  void initState() {
    super.initState();
    _searchInfoModel = SearchInfoModel(api: api());
    _textEditingController = TextEditingController();
    if (StringUtils.isNotEmpty(widget.keyword)) {
      _textEditingController.text = widget.keyword;
    }
    _controller = EasyRefreshController();
    _contentFocusNode.addListener(() {
      if (_contentFocusNode.hasFocus) {
//        SearchInfoModel model =
//            Provider.of<SearchInfoModel>(_searchViewContext);
//        model.changeOptType(false);
        Provider.of<RecipeListViewTypeModel>(providerContext, listen: false)
            .changeViewType(RecipeListViewType.HISTORY_VIEW);
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future search({first = false}) async {
    String keyword = StringUtils.isNotEmpty(_textEditingController.text)
        ? _textEditingController.text
        : widget.keyword;
    if (StringUtils.isEmpty(_textEditingController.text) &&
        StringUtils.isNotEmpty(widget.keyword)) {
      _textEditingController.text = widget.keyword;
    }
    _contentFocusNode?.unfocus();
    var model = Provider.of<RecipeListModel>(_listViewContext, listen: false);
    return await model
        .refresh(params: {"keywords": keyword}, init: first).catchError((err) {
      _controller.finishLoad(success: false);
      showToast(err);
    });
  }

  @override
  Widget buildWidget(BuildContext context) {
    var viewType = RecipeListViewType.HISTORY_VIEW;
    if (widget.directSearch) {
      viewType = RecipeListViewType.LIST_VIEW;
    }
    return ChangeNotifierProvider<RecipeListViewTypeModel>(
      create: (context) => RecipeListViewTypeModel(viewType: viewType),
      child: Scaffold(
          resizeToAvoidBottomPadding: false,
          body: MainWidget(
            decoration: BoxDecoration(gradient: defaultGradient(context)),
            actions: <Widget>[
              SizedBox(
                width: width(48),
                child: Consumer<RecipeListViewTypeModel>(
                  builder: (context, model, _) {
                    return (model.viewType == RecipeListViewType.HISTORY_VIEW)
                        ? InkWell(
                            onTap: () {
                              Provider.of<SearchInfoModel>(_searchViewContext,
                                      listen: false)
                                  .changeOptTypeOnly(false);
                              showListView();
                            },
                            child: Container(
                              alignment: Alignment.centerLeft,
                              width: width(48),
                              child: Text(
                                "搜索",
                                style: textStyle(
                                    color: Colors.white, fontSize: sp(16)),
                              ),
                            ),
                          )
                        : InkWell(
                            onTap: () {
                              _contentFocusNode?.unfocus();
                              logger.log("scence = ${widget.scence}");
                              if (widget.scence == "category") {
                                Nav.back();
                              } else {
                                Nav.pageTo(context, Routers.category,
                                        param: {"scence": "recipe_list"})
                                    .then((value) {
                                  if (value != null) {
                                    var scence = value['scence'];
                                    if (scence == "search") {
                                      _contentFocusNode.requestFocus();
                                      model.changeViewType(
                                          RecipeListViewType.HISTORY_VIEW);
                                    } else if (scence == "category") {
                                      _textEditingController.text =
                                          value['keyword'];
                                      _contentFocusNode.unfocus();
                                      model.changeViewType(
                                          RecipeListViewType.LIST_VIEW);
                                      search(first: true);
                                    } else {}
                                  }
                                });
                              }
                            },
                            child: Container(
                              width: width(48),
                              alignment: Alignment.centerLeft,
                              child: Image.asset(
                                'assets/images/category.png',
                                width: width(24),
                                height: width(24),
                              ),
                            ),
                          );
                  },
                ),
              ),
            ],
            header: _buildSearchHeader((value) {
              showListView();
            }),
//        noHeader: true,
            child: Container(
                color: Colors.white,
                height: double.infinity,
                width: double.infinity,
                child: Consumer<RecipeListViewTypeModel>(
                    builder: (context, model, _) {
                  providerContext = context;
                  Widget content;
                  if (model.viewType == RecipeListViewType.HISTORY_VIEW) {
                    content = _buildSearchInfo();
                  } else {
                    content = _buildListView();
                  }
                  return content;
                })),
            onLeadingTap: () async {
              _contentFocusNode?.unfocus();
              Nav.back();
              return false;
            },
          )),
    );
  }

  void showListView() {
    if (StringUtils.isEmpty(_textEditingController.text) &&
        StringUtils.isNotEmpty(widget.keyword)) {
      _textEditingController.text = widget.keyword;
    }
    _contentFocusNode?.unfocus();
    Provider.of<RecipeListViewTypeModel>(providerContext, listen: false)
        .changeViewType(RecipeListViewType.LIST_VIEW);
  }

  ///列表
  Widget _buildListView() {
    return ProviderWidget<RecipeListModel>(
      model: RecipeListModel(Provider.of<API>(context)),
      onModelReady: (model) {
//        logger.log("load recipe list");
        String keyword = StringUtils.isNotEmpty(_textEditingController.text)
            ? _textEditingController.text
            : widget.keyword;
        model.refresh(params: {"keywords": keyword}).catchError(((err) {
          showToast(err);
          _controller.finishLoad(success: false);
        }));
      },
      builder: (context, model, _) {
        _listViewContext = context;

        ///加载成功，显示列表
        List<DishCharacter> list = model?.list;
        var count = list?.length ?? 0;

        return ListContainer(
          state: model.state,
          controller: _controller,
          itemCount: count,
          padding:
              EdgeInsets.symmetric(horizontal: width(12), vertical: height(12)),
          separatorBuilder: (context, index) => Container(
            height: height(12),
          ),
          itemBuilder: (context, index) {
            return GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                Nav.pageTo(context, Routers.recipe_detail, param: {
                  'did': list[index].dish.id,
                  'album': list[index].dish.album,
                  'title': list[index].dish.title
                });
              },
              child: ChangeNotifierProvider<DishCharacter>.value(
                value: list[index],
                child: Consumer<DishCharacter>(builder: (context, model, _) {
                  return Container(
                    child: _buildListItem(model.dish),
                  );
                }),
              ),
            );
          },
          loadView: (context) => _buildListSkeleton(),
          errorText: model?.error?.message,
          onLoad: model.hasNext
              ? () async {
                  _contentFocusNode.unfocus();
                  await this.search();
                  _controller.finishLoad(noMore: !model.hasNext);
                }
              : null,
          onRefresh: null,
          onLoadMoreFailed: () {
            _controller?.finishLoad(success: false);
          },
          retry: () {
            search();
          },
        );
      },
    );
  }

  ///搜索历史+推荐搜索
  Widget _buildSearchInfo() {
    logger.log("_buildSearchInfo");
    return ProviderWidget<SearchInfoModel>(
      model: _searchInfoModel,
      onModelReady: (model) {
        model.getSearchInfo();
      },
      builder: (context, model, _) {
        _searchViewContext = context;
        return LoadContainer(
          state: model.state,
          align: Alignment.topCenter,
          content: (context) {
            List<Widget> list = new List();
            list.add(_buildSearchHistory(model.history, "搜索历史"));
            if (!model.deleting && model.recommend != null) {
              list.add(SizedBox(height: height(10)));
              list.add(_buildSearchRecommend(model.recommend, "推荐搜索"));
            }
            return Container(
              padding: EdgeInsets.only(
                  left: width(16), right: width(16), top: height(10)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: list,
              ),
            );
          },
          emptyView: (context) => Container(),
//          loadView: (context) => Center(
//            child: SizedBox(
//              width: width(36),
//              height: width(36),
//              child: CircularProgressIndicator(),
//            ),
//          ),
          retry: () {
            model.getSearchInfo();
          },
        );
      },
    );
  }

  ///搜索历史搜索项
  Widget _buildSearchHistoryItem(SearchBaseInfo searchBaseInfo) {
    return InkWell(
      onTap: () {
        _textEditingController.text = searchBaseInfo.word;
        showListView();
//        search(first: true);
//        _textEditingController.selection=TextSelection.fromPosition(TextPosition(offset: searchBaseInfo.word.length,affinity: TextAffinity.downstream));
      },
      child: Chip(
        label: Text(searchBaseInfo.word),
        labelStyle: textStyle(
          color: Color(0xff2d2d2d),
          fontSize: sp(12),
          fontWeight: bold,
        ),
        labelPadding: EdgeInsets.only(
            left: width(6), top: 0.0, bottom: 0.0, right: width(6)),
        deleteIcon: null,
        avatar: null,
        backgroundColor: skeletonGray,
      ),
    );
  }

  ///搜索框
  Widget _buildSearchHeader(onSubmit) {
    return SearchView(
      margin: EdgeInsets.only(left: width(48), right: width(60)),
      focusNode: _contentFocusNode,
      controller: _textEditingController,
      autofocus: !widget.directSearch,
      hintText: '客官，想吃点啥？',
//          StringUtils.isNotEmpty(widget.keyword) ? widget.keyword : '客官，想吃点啥？',
      onFieldSubmitted: onSubmit,
    );
  }

  ///搜索历史
  Widget _buildSearchHistory(History history, title) {
    bool deleting = Provider.of<SearchInfoModel>(_searchViewContext).deleting;
    return ChangeNotifierProvider<History>.value(
      value: history,
      child: Container(
          child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          _buildHistoryCategoryTitle(title, Consumer<SearchInfoModel>(
            builder: (context, model, _) {
              return InkWell(
                child: model.deleting
                    ? Icon(Icons.done, color: Colors.amber)
                    : Icon(Icons.delete, color: Colors.grey.shade500),
                onTap: () {
                  _contentFocusNode.unfocus();
                  model.changeOptType(!model.deleting);
                },
              );
            },
          )),
          Consumer<History>(builder: (context, model, _) {
            var list = model.list;
            //显示部分历史记录
            if (!deleting) {
              if (!model.showAll && list.length > MAX_SHOWING) {
                list = list.sublist(0, MAX_SHOWING);
              }
            }
            List<Widget> children = new List();
            for (var index = 0; index < list.length; index++) {
              var info = list[index];
              children.add(InkWell(
                onTap: () {
                  ///点击历史记录
                  if (deleting) {
//                    deletedHistory(info.id);
                  } else {
                    _textEditingController.text = info.word;
                    showListView();
                  }
                },
                child: Chip(
                    label: Text(info.word),
                    labelStyle: textStyle(
                        color: Color(0xff2d2d2d),
                        fontSize: sp(12),
                        fontWeight: bold),
                    labelPadding: EdgeInsets.only(
                        left: width(6), top: 0.0, bottom: 0.0, right: width(6)),
                    avatar: null,
                    backgroundColor: skeletonGray,
                    onDeleted: deleting
                        ? () async {
                            var result =
                                await simpleFuture(model.delete(index));
                            if (result == null) {
                              showToast("删除成功");
                            }
                          }
                        : null),
              ));
            }
            if (!deleting && model.list.length > MAX_SHOWING) {
              children.add(InkWell(
                child: Chip(
                  label: Image(
                      image: AssetImage(model.showAll
                          ? "assets/images/arrow-show-up.png"
                          : "assets/images/arrow-show-down.png"),
                      width: width(16),
                      height: width(16)),
                  labelStyle: textStyle(
                      color: Color(0xff2d2d2d),
                      fontSize: sp(12),
                      fontWeight: bold),
                  labelPadding: EdgeInsets.only(
                      left: width(6), top: 0.0, bottom: 0.0, right: width(6)),
                  avatar: null,
                  backgroundColor: Colors.white,
                ),
                onTap: () {
                  model.setShowAll(!model.showAll);
                },
              ));
            }
            return Wrap(spacing: width(10), children: children);
          })
        ],
      )),
    );
  }

  ///删除历史记录
  void deletedHistory(int id) {
    logger.log("删除 $id");
  }

  ///推荐搜索
  Widget _buildSearchRecommend(Recommend recommend, title, [Widget icon]) {
    return ChangeNotifierProvider<Recommend>.value(
      value: recommend,
      child: Container(
          child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          _buildHistoryCategoryTitle(title, icon),
          Consumer<Recommend>(
              builder: (context, model, _) => Wrap(
                    spacing: width(10),
                    children: recommend.list
                        .map((info) => _buildSearchHistoryItem(info))
                        .toList(),
                  ))
        ],
      )),
    );
  }

  ///搜索历史标题
  Widget _buildHistoryCategoryTitle(String title, [Widget icon]) {
    var list = <Widget>[];
    list.add(Text(
      title,
      style: textStyle(
        color: Colors.black,
        fontSize: sp(14),
        fontWeight: bold,
      ),
    ));
    if (icon != null) {
      list.add(icon);
    }
    return Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: list);
  }

  Widget _buildListSkeleton() {
    return Stack(
      children: <Widget>[
        ListView.separated(
            separatorBuilder: (context, index) => Container(
                  height: height(12),
                ),
            padding: EdgeInsets.symmetric(
                horizontal: width(12), vertical: height(12)),
            itemCount: 10,
            shrinkWrap: true,
            itemBuilder: (context, index) {
              return Container(
                child: _buildListSkeletonItem(),
              );
            }),
//        Center(
//          child: CircleProgress(),
//        )
      ],
    );
  }

  Widget _buildListSkeletonItem() {
    return Container(
      height: height(90),
      child: Row(
        children: <Widget>[
          Container(
            height: double.infinity,
            width: height(120),
            decoration: BoxDecoration(
                color: skeletonGray,
                borderRadius: BorderRadius.all(Radius.circular(width(6)))),
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
                Flexible(
                  child: Column(
                    ///标题、配料
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Flexible(
                          child: Container(
                        color: skeletonGray,
                        height: height(10),
                        width: width(50),
                      )),
                      SizedBox(
                        height: height(4),
                      ),
                      Flexible(
                          child: Container(
                        color: skeletonGray,
                        height: height(12),
                        width: double.infinity,
                      )),
                    ],
                  ),
                ),
                Flexible(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      Flexible(
                          child: TextSkeleton(
                        image: AssetImage(
                            "assets/images/icon-collect-skeleton.png"),
                        iconDirection: IconDirection.LEFT,
                        textHeight: height(12),
                        iconHeight: width(14),
                        iconWidth: width(14),
                        textWidth: width(28),
                        withIcon: true,
                      )),
                      SizedBox(
                        width: width(6),
                      ),
                      Flexible(
                          child: TextSkeleton(
                        image:
                            AssetImage("assets/images/icon-views-skeleton.png"),
                        iconDirection: IconDirection.LEFT,
                        textHeight: height(12),
                        iconHeight: width(14),
                        iconWidth: width(14),
                        textWidth: width(28),
                        withIcon: true,
                      ))
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

  Widget _buildListItem(Dish item) {
    var ingredients = StringBuffer();
    var burdens = StringBuffer();
    item.materials.forEach((Materials m) {
      if (m.type == 1) {
        ingredients.write(m.name);
        ingredients.write(",");
      } else {
        burdens.write(m.name);
        burdens.write(",");
      }
    });
    var ingreStr = ingredients.toString();
    if (ingreStr.length > 1) {
      ingreStr = ingreStr.substring(0, ingreStr.length - 1);
    }
    var burdenStr = burdens.toString();
    if (burdenStr.length > 1) {
      burdenStr = burdenStr.substring(0, burdenStr.length - 1);
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
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          Flexible(
                            child: IconText(
                              iconHeight: width(14),
                              iconWidth: width(14),
                              assetImagePath:
                                  'assets/images/icon-uncollected.png',
                              text: "${item.statistic.collected}",
                              space: width(4),
                              textStyle: textStyle(
                                  color: color_999,
                                  fontSize: sp(12),
                                  height: height(0.95)),
                            ),
                          ),
                          SizedBox(
                            width: 6.0,
                          ),
                          Flexible(
                              child: IconText(
                            iconHeight: width(14),
                            iconWidth: width(14),
                            assetImagePath: 'assets/images/icon-views-2.png',
                            text: "${item.statistic.views}",
                            space: width(2),
                            textStyle: textStyle(
                                color: color_999,
                                fontSize: sp(12),
                                height: height(0.95)),
                          ))
                        ],
                      ),
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
