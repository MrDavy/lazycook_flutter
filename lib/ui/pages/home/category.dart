import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:lazycook/config/config.dart';
import 'package:lazycook/core/request/local_repository.dart';
import 'package:lazycook/core/services/api.dart';
import 'package:lazycook/core/viewmodels/category/category.dart';
import 'package:lazycook/ui/route/nav.dart';
import 'package:lazycook/ui/route/routers.dart';
import 'package:lazycook/ui/shared/colors.dart';
import 'package:lazycook/ui/shared/styles.dart';
import 'package:lazycook/ui/widgets/custom_state.dart';
import 'package:lazycook/ui/widgets/provider_widget.dart';
import 'package:lazycook/ui/widgets/load_container.dart';
import 'package:lazycook/ui/widgets/main_widget.dart';
import 'package:lazycook/ui/widgets/search_textview.dart';
import 'package:lazycook/utils/string_utils.dart';
import 'package:provider/provider.dart';

class CategoryWidget extends StatefulWidget {
  final String scence;

  CategoryWidget({Key key, this.scence}) : super(key: key);

  @override
  CategoryWidgetState createState() => new CategoryWidgetState();
}

class CategoryWidgetState extends CustomState<CategoryWidget> {
  BuildContext _buildContext;

//
//  @override
//  void dispose() {
//    logger.log("dispose");
//    super.dispose();
//  }

  @override
  Widget buildWidget(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomPadding: false,
      body: MainWidget(
        title: "分类",
        header: _buildSearchHeader(),
        decoration: BoxDecoration(gradient: defaultGradient(context)),
        child: Container(
          padding: EdgeInsets.only(top: height(10)),
          width: double.infinity,
          color: skeletonGray,
          child: _buildLayout(),
        ),
      ),
    );
  }

  ///搜索框
  Widget _buildSearchHeader() {
    return SearchView(
      enable: false,
      margin: EdgeInsets.only(left: width(48), right: width(12)),
      hintColor: color_999,
      hintText: '客官，想吃点啥？',
      onClick: () {
        if (widget.scence == "recipe_list") {
          Nav.back(param: {'scence': 'search'});
        } else {
          Nav.pageTo(context, Routers.home_search,
              param: {"keyword": "", 'scence': 'category'});
        }
      },
    );
  }

  Widget _buildLayout() {
    return ProviderWidget<CategoryModel>(
      model: CategoryModel(
          api: Provider.of<API>(context),
          localRepository: Provider.of<LocalRepository>(context)),
      onModelReady: (model) => model.getCategories(),
      builder: (context, model, child) {
        _buildContext = context;
        return LoadContainer(
            state: model.state,
            content: (context) => Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Expanded(
                      child: _buildCategoryList(),
                    ),
                    Expanded(
                      flex: 3,
                      child: Container(
                        color: Colors.white,
                        padding: EdgeInsets.only(
                            left: width(12), right: width(12), top: height(12)),
                        child: _buildChildCategoryList(),
                      ),
                    )
                  ],
                ),
            retry: () async {
              await model.getCategories();
            });
      },
    );
  }

  Widget _buildCategoryList() {
    var categories = Provider.of<CategoryModel>(_buildContext).categories;
    return Container(
      child: ListView.builder(
        shrinkWrap: true,
        itemBuilder: (context, index) {
          return categories?.isNotEmpty == true
              ? _buildCategoryItem(index)
              : _buildCategoryItemSkeleton();
        },
        itemCount: categories?.length ?? 10,
        physics: ScrollPhysics(),
        padding: EdgeInsets.all(0),
      ),
    );
  }

  Widget _buildCategoryItem(index) {
    var categoryModel = Provider.of<CategoryModel>(_buildContext);
    return ChangeNotifierProvider<CategoryRecord>.value(
      value: categoryModel?.categories[index],
      child: Consumer<CategoryRecord>(builder: (context, model, child) {
        var selected = model.selected ?? false;
        return InkWell(
          onTap: () => categoryModel.changeSelectedItem(index),
          child: Container(
            decoration: BoxDecoration(
              color: selected ? Colors.white : backgroundGray,
              border: selected
                  ? Border(left: BorderSide(color: red, width: width(4)))
                  : Border(
                      top: BorderSide(color: Colors.white, width: height(1)),
                      bottom: BorderSide(color: Colors.white, width: height(1)),
                    ),
            ),
            height: height(50),
            child: Container(
              alignment: Alignment.center,
              child: Text(
                model.category.name,
                style: textStyle(
                    color: selected ? red : color_666,
                    fontSize: sp(14),
                    fontWeight: bold),
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildCategoryItemSkeleton() {
    return Container(
      height: height(50),
      decoration: BoxDecoration(
        color: skeletonGray,
        border: Border(
          top: BorderSide(color: Colors.white, width: height(1)),
          bottom: BorderSide(color: Colors.white, width: height(1)),
        ),
      ),
    );
  }

  Widget _buildChildCategoryList() {
    var categoryModel = Provider.of<CategoryModel>(_buildContext);
    return ChangeNotifierProvider<ChildCategoryModel>.value(
        value: categoryModel.childCategoryModel,
        child: Consumer<ChildCategoryModel>(
          builder: (context, model, _) {
            var childCategories = model.categories;
            return LoadContainer(
              state: model.state,
              content: (context) => GridView.builder(
                  padding: EdgeInsets.all(0.0),
                  itemCount: childCategories?.length ?? 10,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: width(10),
                      mainAxisSpacing: height(10),
                      childAspectRatio: 1),
                  itemBuilder: (context, index) {
                    var placeholder = Container(
                      height: width(50),
                      width: width(50),
                      decoration: BoxDecoration(
                          color: skeletonGray,
                          borderRadius:
                              BorderRadius.all(Radius.circular(width(6)))),
                    );
                    return InkWell(
                      onTap: () {
                        if (widget.scence == "recipe_list") {
                          Nav.back(param: {
                            'scence': 'category',
                            "keyword": childCategories[index].name
                          });
                        } else {
                          Nav.pageTo(context, Routers.home_search, param: {
                            "scence": 'category',
                            "keyword": childCategories[index].name,
                            'isList': true
                          });
                        }
                      },
                      child: Column(
                        children: <Widget>[
                          ClipRRect(
                            borderRadius:
                                BorderRadius.all(Radius.circular(width(6))),
                            child: CachedNetworkImage(
                                width: width(50),
                                fit: BoxFit.fill,
                                errorWidget: (context, url, error) =>
                                    placeholder,
                                placeholder: (context, url) => placeholder,
                                height: width(50),
                                imageUrl: Config.envConfig().imgBasicUrl() +
                                    childCategories[index].img),
                          ),
                          SizedBox(
                            height: height(2),
                          ),
                          Expanded(
                            child: Text(
                              childCategories[index].name,
                              style: textStyle(
                                  color: color_222,
                                  fontWeight: bold,
                                  fontSize: sp(12)),
                            ),
                          )
                        ],
                      ),
                    );
                  }),
              retry: () async {
                await categoryModel.getChildCategories(
                    categoryModel.selectedRecord.category.p_id);
              },
            );
          },
        ));
  }
}
