import 'dart:math';
import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lazycook/config/config.dart';
import 'package:lazycook/core/models/dish.dart';
import 'package:lazycook/core/request/exception/error.dart';
import 'package:lazycook/core/viewmodels/base_model.dart';
import 'package:lazycook/core/viewmodels/recipe/recipe_detail.dart';
import 'package:lazycook/core/viewmodels/scroll_model.dart';
import 'package:lazycook/ui/route/nav.dart';
import 'package:lazycook/ui/route/routers.dart';
import 'package:lazycook/ui/shared/colors.dart';
import 'package:lazycook/ui/shared/styles.dart';
import 'package:lazycook/ui/widgets/custom_state.dart';
import 'package:lazycook/ui/widgets/dialog/custom_dialog.dart';
import 'package:lazycook/ui/widgets/gallery/gallery.dart';
import 'package:lazycook/ui/widgets/provider_widget.dart';
import 'package:lazycook/ui/widgets/icon_text.dart';
import 'package:lazycook/ui/widgets/load_container.dart';
import 'package:lazycook/ui/widgets/loading_dialog.dart';
import 'package:lazycook/ui/widgets/main_widget.dart';
import 'package:lazycook/ui/widgets/skeleton/icon_text_skeleton.dart';
import 'package:lazycook/utils/fluro/src/common.dart';
import 'package:provider/provider.dart';

///菜品详情页
class RecipeDetailWidget extends StatefulWidget {
  final int did;
  final String album;
  final String title;
  final String scence;

  RecipeDetailWidget(this.did, this.album, this.scence, this.title);

  @override
  RecipeDetailWidgetState createState() => new RecipeDetailWidgetState();
}

class RecipeDetailWidgetState extends CustomState<RecipeDetailWidget>
    with TickerProviderStateMixin {
  BuildContext _detailContext;
  BuildContext _headerContext;
  ScrollController _scrollController;

  GlobalKey _fKey = GlobalKey();
  GlobalKey _f2Key = GlobalKey();

  AnimationController _animationController;
  AnimationController _animation2Controller;

  var albumHeight = 0.0;
  var stepImageHeight;

  var showTitle = false;

  LoadingDialog dialog;

  @override
  void initState() {
    super.initState();
    albumHeight = ScreenUtil.screenWidthDp * .7;
    //单边间隙总宽度12+16+10
    stepImageHeight = (ScreenUtil.screenWidthDp - width(38) * 2) * .7;
    _scrollController = ScrollController();
    _scrollController.addListener(() {
      var offset = _scrollController.offset;
//      if (offset >= 0 && offset <= ALBUM_HEIGHT)
      if (offset <= albumHeight)
        Provider.of<ScrollModel>(_headerContext, listen: false).change(offset);
    });
    _animationController = AnimationController(
        value: 1, vsync: this, duration: Duration(milliseconds: 200));
    _animation2Controller = AnimationController(
        value: 0, vsync: this, duration: Duration(milliseconds: 200));
  }

  @override
  Widget buildWidget(BuildContext buildContext) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<ScrollModel>(create: (context) {
          return ScrollModel(albumHeight);
        }),
      ],
      child: ProviderWidget<RecipeDetailModel>(
        model: RecipeDetailModel(api: Provider.of(buildContext)),
        onModelReady: (model) async {
          model.getDishDetail({"did": "${widget.did}"});
        },
        builder: (context, model, child) {
          this._detailContext = context;
          return Scaffold(
            body: MainWidget(
              decoration: BoxDecoration(gradient: defaultGradient(context)),
              header: Consumer<ScrollModel>(
                builder: (context, childModel, child) {
                  _headerContext = context;
                  return Opacity(
                    opacity: childModel.proportion,
                    child: Text(
                      model.dish?.title ?? "",
                      style: textStyle(
                        color: Colors.white,
                        fontSize: sp(18),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  );
                },
              ),
              child: _buildLayout(),
              actions: _buildActions(_fKey),
            ),
          );
        },
      ),
    );
  }

  Widget _buildFavoriteIcon(Dish dish, key, controller) {
    return Consumer<RecipeDetailModel>(builder: (context, collectModel, _) {
      return InkWell(
        child: Container(
          padding: EdgeInsets.only(
              left: width(8),
              right: width(8),
              top: height(8),
              bottom: height(8)),
          height: width(40),
          width: width(48),
          child: ScaleTransition(
            scale: controller,
            child: Icon(
              (collectModel?.dish?.hasCollected == 1)
                  ? Icons.favorite
                  : Icons.favorite_border,
              key: key,
              color: !(collectModel?.dish?.hasCollected == 1)
                  ? white
                  : white,
              size: width(24),
            ),
          ),
        ),
        onTap: () async {
          var type = await checkLogin();
          if (type == 1) {
            var result = await simpleFuture(
                collectModel.collect(
                    dish?.id, (dish?.hasCollected == 1) ? "2" : "1"),
                loadingMsg: dish?.hasCollected == 1 ? "取消收藏" : "收藏中");
            if (result != null && result is LazyError) {
              showToast(result.message);
            }
          }
          if (type == 2) {
            Provider.of<RecipeDetailModel>(this._detailContext, listen: false)
                .getDishDetail({"did": "${widget.did}"});
          } else {}
        },
      );
    });
  }

  List<Widget> _buildActions(key) {
    List<Widget> _list = [];
    var dish =
        Provider.of<RecipeDetailModel>(this._detailContext, listen: false)
            ?.dish;
    if (dish != null) {
      if (widget.scence != "collection") {
        _list.add(_buildFavoriteIcon(dish, key, _animationController));
      }
//      _list.add(InkWell(
//        child: Container(
//          padding: EdgeInsets.only(
//              left: width(8),
//              top: height(8),
//              bottom: height(8),
//              right: width(16)),
//          height: width(40),
//          width: width(48),
//          child: Icon(
//            Icons.share,
//            color: Colors.white,
//            size: width(24),
//          ),
//        ),
//        onTap: () {},
//      ));
    }
    return _list;
  }

  Widget _buildLayout() {
    var model =
        Provider.of<RecipeDetailModel>(this._detailContext, listen: false);
    return LoadContainer(
      state: model.state,
      decoration: BoxDecoration(color: Colors.white),
      loadView: (context) => _buildSkeleton(),
      content: (context) => _buildContent(),
      errorText: model?.error?.message ?? "",
    );
  }

  Widget _buildContent() {
//    logger.log("_buildContent");
    return CustomScrollView(
      controller: _scrollController,
      physics: ScrollPhysics(),
      shrinkWrap: true,
      slivers: <Widget>[
        SliverToBoxAdapter(
          child: Stack(
            children: <Widget>[
              _buildAlbum(),
              Column(
                children: <Widget>[
                  Consumer<ScrollModel>(builder: (context, childModel, child) {
                    return SizedBox(
                      height: childModel.height,
                    );
                  }),
                  Container(
                    color: Colors.white,
                    child: Column(
                      children: <Widget>[
                        _buildStatisticView(),
                        Container(
                            width: double.infinity,
                            height: 1,
                            color: skeletonGray),
                        _buildIntro(),
                        SizedBox(height: height(10)),
                        _buildBurdenView(),
                        SizedBox(height: height(10)),
                        _buildStepView(),
                        SizedBox(height: height(40)),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAlbum() {
//    var model =
//        Provider.of<RecipeDetailModel>(this._detailContext, listen: false);
    var placeholder = Container(
      width: double.infinity,
      height: albumHeight,
      color: skeletonGray,
    );
//    if (model.dish == null) {
//      return placeholder;
//    }
    return CachedNetworkImage(
      width: double.infinity,
      fit: BoxFit.fitWidth,
      placeholder: (context, url) => placeholder,
      height: albumHeight,
      imageUrl: Config.envConfig().imgBasicUrl() + widget.album,
//      imageUrl: Config.envConfig().imgBasicUrl() + model?.dish?.album ?? "",
    );
  }

  Widget _buildSectionTitle(text) {
    return IconText(
      iconHeight: width(16),
      iconWidth: width(16),
      assetImagePath: 'assets/images/title-icon.png',
      text: text,
      space: width(2),
      textStyle: textStyle(
          color: textColor,
          fontSize: sp(16),
          height: height(0.95),
          fontWeight: FontWeight.w600),
    );
  }

  Widget _buildIntro() {
    var model =
        Provider.of<RecipeDetailModel>(this._detailContext, listen: false);
    return Container(
      width: double.infinity,
      padding:
          EdgeInsets.only(left: width(12), right: width(12), top: height(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          _buildSectionTitle("介绍"),
          SizedBox(
            height: height(10),
          ),
          Padding(
            child: Text(
              model.dish.intro,
              style: textStyle(fontSize: sp(14)),
            ),
            padding: EdgeInsets.only(left: width(26), right: width(26)),
          )
        ],
      ),
    );
  }

  Widget _buildStepView() {
    var model =
        Provider.of<RecipeDetailModel>(this._detailContext, listen: false);
    var steps = model.dish.steps;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(
        left: width(12),
        right: width(12),
        top: height(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          _buildSectionTitle("步骤"),
          SizedBox(
            height: height(10),
          ),
          ListView.builder(
              padding: EdgeInsets.only(
                  left: width(16), top: 0, right: width(16), bottom: 0),
              physics: NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: steps.length,
              itemBuilder: (context, index) {
                return Container(
                  padding: EdgeInsets.only(top: height(6), bottom: height(6)),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.only(left: 0),
                        child: Text(
                          steps[index].step,
                          style: textStyle(
                              color: color_333, fontSize: sp(14)),
                        ),
                      ),
                      SizedBox(
                        height: height(10),
                      ),
                      Padding(
                        padding: EdgeInsets.only(
                            left: width(10),
                            right: width(10),
                            bottom: height(10)),
                        child: InkWell(
                          onTap: () {
                            Nav.pageTo(context, Routers.gallery,
                                param: {
                                  "list": steps
                                      .map<GalleryData>((step) => GalleryData(
                                          description: step.step,
                                          url: step.img))
                                      .toList(),
                                  "initialIndex": index
                                },
                                transition:
                                    TransitionType.cupertinoFullScreenDialog);
                          },
                          child: CachedNetworkImage(
                            width: double.infinity,
                            fit: BoxFit.fitWidth,
                            placeholder: (context, url) => Container(
                              width: double.infinity,
                              height: stepImageHeight,
                              color: skeletonGray,
                            ),
                            height: stepImageHeight,
                            imageUrl: Config.envConfig().imgBasicUrl() +
                                steps[index].img,
//      imageUrl: Config.envConfig().imgBasicUrl() + model?.dish?.album ?? "",
                          ),
                        ),
                      )
                    ],
                  ),
                );
              })
        ],
      ),
    );
  }

  Widget _buildBurdenView() {
    var model =
        Provider.of<RecipeDetailModel>(this._detailContext, listen: false);
    var materials = model.dish.materials;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(
        left: width(12),
        right: width(12),
        top: height(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          _buildSectionTitle("用料"),
          SizedBox(
            height: height(10),
          ),
          ListView.builder(
              padding: EdgeInsets.only(
                  left: width(16), top: 0, right: width(16), bottom: 0),
              physics: NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: materials.length,
              itemBuilder: (context, index) {
                return Container(
                  padding: EdgeInsets.only(top: height(6), bottom: height(6)),
                  decoration: BoxDecoration(
                      border: Border(
                          bottom: BorderSide(
                    color: skeletonGray,
                    width: width(1),
                  ))),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.only(left: width(10)),
                        child: Text(
                          materials[index].name,
                          style: textStyle(
                              color: color_333, fontSize: sp(14)),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(right: width(10)),
                        child: Text(
                          materials[index].value,
                          style: textStyle(
                              color: color_999,
                              fontSize: sp(14),
                              fontWeight: FontWeight.w300),
                        ),
                      )
                    ],
                  ),
                );
              })
        ],
      ),
    );
  }

  Widget _buildStatisticView() {
    var model =
        Provider.of<RecipeDetailModel>(this._detailContext, listen: false);
    Statistic statistic = model.dish.statistic;
    return Container(
      padding: EdgeInsets.only(
          left: width(12),
          right: width(12),
          top: height(12),
          bottom: height(12)),
      child: Stack(
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Text(model.dish.title,
                      style: textStyle(
                          fontSize: sp(18), fontWeight: FontWeight.w600)),
                  SizedBox(
                    height: height(10),
                  ),
                  Row(
                    children: <Widget>[
                      IconText(
                        iconHeight: width(16),
                        iconWidth: width(16),
                        assetImagePath: 'assets/images/icon-collect-gray.png',
                        text: "${statistic.collected}",
                        space: width(2),
                        textStyle: textStyle(
                            color: color_999,
                            fontSize: sp(14),
                            height: height(0.95),
                            fontWeight: FontWeight.w400),
                      ),
                      SizedBox(
                        width: width(10),
                      ),
                      IconText(
                        iconHeight: width(16),
                        iconWidth: width(16),
                        assetImagePath: 'assets/images/icon-views-666666.png',
                        text: "${statistic.views}",
                        space: width(2),
                        textStyle: textStyle(
                            color: color_999,
                            fontSize: sp(14),
                            height: height(0.95),
                            fontWeight: FontWeight.w400),
                      ),
//                      SizedBox(
//                        width: width(10),
//                      ),
//                      IconText(
//                        iconHeight: width(16),
//                        iconWidth: width(16),
//                        assetImagePath: 'assets/images/icon-share.png',
//                        text: "${statistic.shared}",
//                        space: width(2),
//                        textStyle: textStyle(
//                            color: color_999,
//                            fontSize: sp(14),
//                            height: height(0.95),
//                            fontWeight: FontWeight.w400),
//                      )
                    ],
                  )
                ],
              ),
//                _buildFavoriteIcon(
//                    model.dish.hasCollected, 0xFF999999, 0xFFEB402D)
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.max,
            children: [
              _buildFavoriteIcon(model.dish, _f2Key, _animation2Controller)
            ],
          )
        ],
      ),
    );
  }

  Widget _buildSkeleton() {
    return CustomScrollView(
      physics: ScrollPhysics(),
      slivers: <Widget>[
        SliverToBoxAdapter(
          child: Container(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Container(
                  width: double.infinity,
                  height: albumHeight,
                  color: skeletonGray,
                ),
                SizedBox(
                  height: height(12),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Container(
                      width: width(80),
                      height: height(14),
                      color: skeletonGray,
                    ),
                    SizedBox(
                      height: height(10),
                    ),
                    Container(
                      width: width(100),
                      height: height(12),
                      color: skeletonGray,
                    ),
                  ],
                ),
                Container(
                    margin: EdgeInsets.only(top: height(12)),
                    width: double.infinity,
                    height: 1,
                    color: skeletonGray),
                Container(
                  margin: EdgeInsets.only(
                      left: width(30),
                      top: height(16),
                      right: width(12),
                      bottom: height(12)),
                  color: skeletonGray,
                  height: height(10),
                ),
                Container(
                  margin: EdgeInsets.only(
                      left: width(12),
                      top: height(2),
                      right: width(12),
                      bottom: height(12)),
                  color: skeletonGray,
                  height: height(10),
                ),
                Container(
                  margin: EdgeInsets.only(
                      left: width(12),
                      top: height(2),
                      right: width(12),
                      bottom: height(12)),
                  color: skeletonGray,
                  height: height(10),
                ),
                ListView.builder(
                    physics: ScrollPhysics(),
                    padding: EdgeInsets.all(0),
                    itemCount: 2,
                    shrinkWrap: true,
                    itemBuilder: (context, index) => _buildListSkeleton())
              ],
            ),
          ),
        )
      ],
    );
  }

  Widget _buildListSkeleton() {
    return Column(
      children: <Widget>[
        Row(
          children: <Widget>[
            Container(
              margin: EdgeInsets.only(left: width(12)),
              height: height(80),
              width: width(120),
              decoration: BoxDecoration(
                  color: skeletonGray,
                  borderRadius: BorderRadius.all(Radius.circular(width(6)))),
            ),
            Expanded(
              child: Container(
                height: height(80),
                padding: EdgeInsets.only(top: height(6)),
                margin: EdgeInsets.only(left: width(10), right: width(12)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  mainAxisSize: MainAxisSize.max,
                  children: <Widget>[
                    Container(
                      color: skeletonGray,
                      height: height(10),
                      width: width(100),
                    ),
                    Container(
                      margin: EdgeInsets.only(top: height(16)),
                      color: skeletonGray,
                      height: height(10),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: height(8))
      ],
    );
  }

  @override
  void dispose() {
    super.dispose();
  }

  Widget _buildError() {
    return Center(
      child: Text("加载出错~"),
    );
  }
}
