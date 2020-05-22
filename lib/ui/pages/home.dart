import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:lazycook/config/config.dart';
import 'package:lazycook/core/models/banner.dart';
import 'package:lazycook/core/models/category.dart';
import 'package:lazycook/core/models/dish.dart';
import 'package:lazycook/core/models/dish_page.dart';
import 'package:lazycook/core/models/home_info.dart';
import 'package:lazycook/core/models/protocol/wrap.dart';
import 'package:lazycook/core/viewmodels/home/home.dart';
import 'package:lazycook/core/viewmodels/person/about.dart';
import 'package:lazycook/ui/route/nav.dart';
import 'package:lazycook/ui/route/routers.dart';
import 'package:lazycook/ui/shared/colors.dart';
import 'package:lazycook/ui/shared/styles.dart';
import 'package:lazycook/ui/widgets/custom_state.dart';
import 'package:lazycook/ui/widgets/easy_refresh_header.dart';
import 'package:lazycook/ui/widgets/icon_text.dart';
import 'package:lazycook/ui/widgets/load_container.dart';
import 'package:lazycook/ui/widgets/main_widget.dart';
import 'package:lazycook/ui/widgets/search_textview.dart';
import 'package:lazycook/utils/string_utils.dart';
import 'package:provider/provider.dart';

///首页
class HomePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => HomePageState();
}

class HomePageState extends CustomState<HomePage> {
  ScrollController _controller;
  SwiperController _swiperController;

  HomeModel _model;

  static const int GRID_H_COUNT = 3;

  num _imageWidth;
  num _imageHeight;

  @override
  bool keepAlive() {
    return true;
  }

  refresh(init) {
    if (_model == null) {
      _model = HomeModel(api());
    }
    _model.refresh(init: init);
  }

  @override
  void initState() {
    super.initState();
    _controller = ScrollController()
      ..addListener(() {
        _model?.updateOffset(_controller.offset);
      });
    _swiperController = SwiperController();
    refresh(true);
    _imageWidth = (ScreenUtil.screenWidthDp -
            (GRID_H_COUNT - 1) * width(10) -
            width(8) * 4) /
        GRID_H_COUNT;
    _imageHeight = _imageWidth * .75;
    Provider.of<AboutModel>(context, listen: false)
        .checkVersion()
        .then((result) {
      if (result.error != null) {
        logger.log("error：${result.error.message}");
      } else {
        showVersionUpdateDialog(result.data, showTips: false);
      }
    }).catchError((error) {
      logger.log("error：$error");
    });
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
    _swiperController.dispose();
    _model.dispose();
  }

  @override
  Widget buildWidget(BuildContext context) {
    return Container(
      child: Material(
        child: ChangeNotifierProvider<HomeModel>(
          create: (context) => _model,
          child: MainWidget(
            child: EasyRefresh.builder(
              header: easyHeader(),
              builder: (context, physics, header, footer) {
                return CustomScrollView(
                  controller: _controller,
                  physics: physics,
                  slivers: <Widget>[
                    header,
                    SliverList(
                      delegate: SliverChildListDelegate([
                        ScrollNotificationInterceptor(
                          child: _buildBanner(),
                        )
                      ]),
                    ),
                    SliverToBoxAdapter(
                      child: SizedBox(
                        height: height(10),
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: ScrollNotificationInterceptor(
                        child: _buildCategory(),
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: ScrollNotificationInterceptor(
                        child: _buildRecommendDishView(),
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: SizedBox(
                        height: height(40),
                      ),
                    ),
                  ],
                );
              },
              onRefresh: () async {
                refresh(false);
              },
            ),
            decoration: BoxDecoration(gradient: defaultGradient(context)),
            header: _buildSearch(),
            statusBar: _buildStatusBar(),
            noLeading: true,
            headerFloat: false,
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBar() {
    return Selector<HomeModel, bool>(
        builder: (context, reachTop, _) {
          return Container(
            color:
                reachTop ? Colors.transparent : themeAccentColor,
          );
        },
        selector: (context, model) => model.reachTop);
  }

  ///首页推荐菜品
  Widget _buildRecommendDishView() {
    return Selector<HomeModel, StateShell<DishPage>>(
      builder: (context, wrappedDishPage, child) {
        Widget view = LoadContainer(
          state: wrappedDishPage.state,
          wrapHeight: true,
          showLoadingIndicator: false,
          content: (context) => _buildRecommendItem(wrappedDishPage.data.items),
          loadView: (context) => _buildRecommendSkeleton(),
          emptyText: "暂无推荐菜品~",
          retry: () {
            _model?.getRecommendDishes(false);
          },
        );

        return Container(
          width: double.infinity,
          margin:
              EdgeInsets.only(left: width(8), right: width(8), top: height(8)),
          padding: EdgeInsets.all(width(8)),
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.all(Radius.circular(width(6)))),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Text(
                    "推荐菜品",
                    style: textStyle(
                      color: textColor,
                      fontSize: sp(14),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: height(10),
              ),
              Flexible(
                flex: 1,
                child: view,
              )
            ],
          ),
        );
      },
      selector: (context, model) => model.wrappedDishPage,
    );
  }

  Widget _buildCategory() {
    return Selector<HomeModel, List<Category>>(
      builder: (context, categories, child) {
        ///未加载、加载中、加载失败显示骨架屏
        Widget child;
        if (categories == null) {
          child = _buildCategorySkeleton();
        } else {
          var count = categories.length;
          if (count == 0) count = 10;
          child = GridView.builder(
            padding: EdgeInsets.all(0.0),
            physics: NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: count ~/ 2,
              mainAxisSpacing: 8,
            ),
            itemBuilder: (context, index) {
              if (categories.isNotEmpty) {
                return _buildCategoryItem(categories[index]);
              } else {
                return _buildCategorySkeletonItem();
              }
            },
            itemCount: count,
          );
        }
        return Container(
          margin: EdgeInsets.symmetric(horizontal: width(8)),
          padding:
              EdgeInsets.symmetric(horizontal: width(8), vertical: height(8)),
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.all(Radius.circular(width(6)))),
          child: child,
        );
      },
      selector: (context, model) => model.categories,
    );
  }

  Widget _buildSearch() {
    return Stack(
      children: <Widget>[
        Selector<HomeModel, bool>(
            builder: (context, reachTop, _) {
              return Container(
                height: height(48),
                color: reachTop
                    ? Colors.transparent
                    : themeAccentColor,
              );
            },
            selector: (context, model) => model.reachTop),
        Container(
          height: height(48),
          child: Selector<HomeModel, HomeBasicInfo>(
            builder: (context, homeInfo, child) {
              int count = homeInfo != null ? homeInfo.unread : 0;
              if (count > 99) count = 99;
              return Padding(
                padding: EdgeInsets.only(left: width(12), right: width(12)),
                child: Row(
                  children: <Widget>[
                    Image.asset(
                      "assets/images/lazycook.png",
                      height: height(22),
                    ),
                    SizedBox(
                      width: width(10),
                    ),
                    Expanded(
                        child: GestureDetector(
                            onTap: () {
                              Nav.pageTo(context, Routers.home_search,
                                  param: {"keyword": homeInfo?.keyword});
                            },
                            child: SearchView(
                              enable: false,
                              hintText: homeInfo != null &&
                                      StringUtils.isNotEmpty(homeInfo.keyword)
                                  ? homeInfo.keyword
                                  : '客官，想吃点啥？',
                            ))),
                    if (homeInfo != null && homeInfo.canAdd)
                      Padding(
                        padding: EdgeInsets.only(left: width(10)),
                        child: GestureDetector(
                          onTap: () {
                            Nav.pageTo(context, Routers.works_new);
                          },
                          child: Image.asset(
                            "assets/images/add-recipe.png",
                            width: width(26),
                            height: width(26),
                          ),
                        ),
                      ),
                  ],
                ),
              );
            },
            selector: (context, model) => model.homeInfo,
          ),
        )
      ],
    );
  }

  Widget _buildBanner() {
    return Selector<HomeModel, HomeBanner>(
        builder: (context, banner, _) {
          var count = banner?.banners != null ? banner.banners.length : 0;
          List<BannerData> banners =
              banner != null && banner.banners != null ? banner.banners : [];
          var borderRadius = BorderRadius.all(Radius.circular(width(8)));
          return Container(
            height: height(140),
            width: double.infinity,
            child: count > 0
                ? Swiper(
                    controller: _swiperController,
                    layout: SwiperLayout.DEFAULT,
                    itemHeight: height(140),
                    autoplay: true,
                    autoplayDisableOnInteraction: false,
//                  index: _currentIndex,
                    scrollDirection: Axis.horizontal,
                    itemCount: count,
                    pagination: SwiperPagination(
                        builder: DotSwiperPaginationBuilder(
                      color: Colors.white,
                      activeColor: themeAccentColor,
                      size: width(6),
                      activeSize: width(6),
                    )),
                    itemBuilder: (context, index) => Padding(
                      padding: EdgeInsets.only(left: width(8), right: width(8)),
                      child: ClipRRect(
                        borderRadius: borderRadius,
                        child: CachedNetworkImage(
                            placeholder: (context, url) => Container(
                                  color: skeletonGray,
                                  width: double.infinity,
                                  alignment: Alignment.center,
                                  height: double.infinity,
//                                child: SizedBox(
//                                  width: width(36),
//                                  height: width(36),
//                                  child: CircularProgressIndicator(),
//                                ),
                                ),
                            imageUrl: banners != null && banners.isNotEmpty
                                ? Config.envConfig().imgBasicUrl() +
                                    banners[index].imgUrl
                                : "",
                            fit: BoxFit.fill),
                      ),
                    ),
                    onTap: (index) {
                      BannerData banner = banners[index];
                      if (banner.type == 0) {
                        ///菜品
                        Nav.pageTo(context, Routers.recipe_detail, param: {
                          'did': banner.d_id,
                          'album': banner.imgUrl,
                          'title': banner.title
                        });
                      } else {
                        ///广告

                      }
                    },
                  )
                : Container(
                    margin: EdgeInsets.only(left: width(12), right: width(12)),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                        color: skeletonGray, borderRadius: borderRadius),
                  ),
          );
        },
        selector: (context, model) => model.banner);
  }

  ///推荐菜品列表
  Widget _buildRecommendItem(List<Dish> items) {
    return GridView.builder(
        padding: EdgeInsets.all(0.0),
        physics: NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        itemCount: items.length,
        itemBuilder: (context, index) {
          var item = items[index];
          return Container(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                GestureDetector(
                  onTap: () {
                    Nav.pageTo(context, Routers.recipe_detail, param: {
                      'did': item.id,
                      'album': item.album,
                      'title': item.title
                    });
                  },
                  child: Stack(
                    children: <Widget>[
                      Container(
                        height: _imageHeight,
                        decoration: BoxDecoration(
                            color: skeletonGray,
                            borderRadius:
                                BorderRadius.all(Radius.circular(width(6)))),
                      ),
                      ClipRRect(
                        borderRadius:
                            BorderRadius.all(Radius.circular(width(6))),
                        child: CachedNetworkImage(
                            width: double.infinity,
                            fit: BoxFit.fill,
                            placeholder: (context, url) => Container(
                                  height: _imageHeight,
                                  decoration: BoxDecoration(
                                      color: skeletonGray,
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(
                                              ScreenUtil.getInstance()
                                                  .setWidth(6)))),
                                ),
                            height: _imageHeight,
                            imageUrl:
                                Config.envConfig().imgBasicUrl() + item.album),
                      ),
                    ],
                  ),
                ),
                Flexible(
                    child: Container(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      SizedBox(
                        height: height(4),
                      ),
                      Flexible(
                          child: Text(
                        item.title,
                        softWrap: false,
                        overflow: TextOverflow.ellipsis,
                        style: textStyle(
                            color: textColor,
                            fontSize: sp(12),
                            fontWeight: bold),
                        maxLines: 1,
                      )),
                      SizedBox(
                        height: height(4),
                      ),
                      Flexible(
                          child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          Flexible(
                            child: IconText(
                              iconHeight: height(12),
                              iconWidth: width(12),
                              assetImagePath:
                                  'assets/images/icon-uncollected.png',
                              text: "${item.statistic.collected}",
                              space: width(2),
                              textStyle: textStyle(
                                  color: color_999,
                                  fontSize: sp(10),
                                  height: height(0.95),
                                  fontWeight: FontWeight.w400),
                            ),
                          ),
                          SizedBox(
                            width: width(6),
                          ),
                          Flexible(
                            child: IconText(
                              iconHeight: height(12),
                              iconWidth: width(12),
                              assetImagePath: 'assets/images/icon-views-2.png',
                              text: "${item.statistic.views}",
                              space: width(2),
                              textStyle: textStyle(
                                  color: color_999,
                                  fontSize: sp(10),
                                  height: height(0.95),
                                  fontWeight: FontWeight.w400),
                            ),
                          )
                        ],
                      ))
                    ],
                  ),
                ))
              ],
            ),
          );
        },
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: GRID_H_COUNT,
            crossAxisSpacing: width(10),
            mainAxisSpacing: height(10),
            childAspectRatio: 0.8));
  }

  Widget _buildCategoryItem(Category category) {
    return Column(
      children: <Widget>[
        GestureDetector(
          onTap: () {
//            logger.log(category.toString());
            if (category.c_id == -1) {
              Nav.pageTo(context, Routers.category, param: {'scence': 'home'});
            } else {
              Nav.pageTo(context, Routers.home_search, param: {
                "keyword": category.name,
                'scence': 'home',
                'isList': true
              });
            }
          },
          child: Stack(
            children: <Widget>[
              Container(
                width: width(48),
                height: width(48),
                decoration: BoxDecoration(
                    color: skeletonGray,
                    borderRadius: BorderRadius.all(Radius.circular(width(24)))),
              ),
              ClipRRect(
                borderRadius: BorderRadius.all(Radius.circular(width(24))),
                child: CachedNetworkImage(
                    placeholder: (context, url) => Container(
                          width: width(48),
                          height: width(48),
                          decoration: BoxDecoration(
                              color: skeletonGray,
                              borderRadius:
                                  BorderRadius.all(Radius.circular(width(24)))),
                        ),
                    width: width(48),
                    height: width(48),
                    imageUrl: Config.envConfig().imgBasicUrl() + category.img),
              ),
            ],
          ),
        ),
        SizedBox(
          height: height(2),
        ),
        Text(
          category.name,
          maxLines: 1,
          style:
              textStyle(color: textColor, fontSize: sp(12), fontWeight: bold),
        )
      ],
    );
  }

  ///推荐菜品骨架
  Widget _buildRecommendSkeleton() {
    return GridView.builder(
        padding: EdgeInsets.all(0.0),
        primary: false,
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        itemCount: 6,
        itemBuilder: (context, index) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                height: _imageHeight,
                decoration: BoxDecoration(
                  color: skeletonGray,
                  borderRadius: BorderRadius.all(Radius.circular(width(6))),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(left: width(3), right: width(3)),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Container(
                      margin: EdgeInsets.only(top: width(6)),
                      width: width(72),
                      height: height(8),
                      color: skeletonGray,
                    ),
                    SizedBox(
                      height: height(4),
                    ),
                    Row(
                      children: <Widget>[
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Image(
                              image: AssetImage(
                                  "assets/images/icon-collect-skeleton.png"),
                              width: width(12),
                              height: height(12),
                            ),
                            Container(
                              margin: EdgeInsets.only(left: width(2)),
                              width: width(26),
                              height: height(6),
                              color: skeletonGray,
                            )
                          ],
                        ),
                        SizedBox(
                          width: width(4),
                        ),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Image(
                              image: AssetImage(
                                  "assets/images/icon-views-skeleton.png"),
                              width: width(12),
                              height: height(12),
                            ),
                            Container(
                              margin: EdgeInsets.only(left: width(2)),
                              width: width(20),
                              height: height(6),
                              color: skeletonGray,
                            )
                          ],
                        )
                      ],
                    )
                  ],
                ),
              )
            ],
          );
        },
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: GRID_H_COUNT,
          crossAxisSpacing: width(10),
          mainAxisSpacing: height(10),
          childAspectRatio: 0.8,
        ));
  }

  Widget _buildCategorySkeletonItem() {
    return Column(
      children: <Widget>[
        Container(
          width: width(48),
          height: width(48),
          decoration: BoxDecoration(
              color: skeletonGray,
              borderRadius: BorderRadius.all(Radius.circular(width(24)))),
        ),
        SizedBox(
          height: height(2),
        ),
        Container(
          width: width(48),
          height: height(10),
          color: skeletonGray,
        ),
      ],
    );
  }

  Widget _buildCategorySkeleton() {
    return GridView.builder(
      padding: EdgeInsets.all(0.0),
      physics: NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 5,
        mainAxisSpacing: 0,
      ),
      itemBuilder: (context, index) {
        return _buildCategorySkeletonItem();
      },
      itemCount: 10,
    );
  }

  @override
  bool get wantKeepAlive => true;
}
