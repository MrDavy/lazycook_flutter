import 'package:lazycook/application.dart';
import 'package:lazycook/core/models/banner.dart';
import 'package:lazycook/core/models/category.dart';
import 'package:lazycook/core/models/dish_page.dart';
import 'package:lazycook/core/models/home_info.dart';
import 'package:lazycook/core/models/protocol/wrap.dart';
import 'package:lazycook/core/models/result_data.dart';
import 'package:lazycook/core/services/api.dart';
import 'package:lazycook/core/viewmodels/base_model.dart';
import '../../../config/lazy_uri.dart';

class HomeModel extends BaseModel {
  HomeModel(API api) : super(api);

  Future refresh({bool init = false}) {
    return Future.wait([
      getHomeBasicInfo(),
      getHomeBanners(),
      getCategories(),
      getRecommendDishes(init)
    ]);
  }

  bool reachTop = true;

  updateOffset(offset) {
    var tmp = offset <= 0;
    if (tmp != reachTop) {
      reachTop = tmp;
      notifyListeners();
    }
  }

  ///header
  HomeBasicInfo _homeInfo;

  HomeBasicInfo get homeInfo => _homeInfo;

  Future getHomeBasicInfo() async {
    setState(ViewState.LOADING);
    ResultData result = await api.getHomeBasicInfo();
    if (result.error != null) {
      Application.homeBasicInfo = null;
      setState(ViewState.FAILED);
    } else {
      this._homeInfo = result.data;
      Application.homeBasicInfo = this._homeInfo;
      setState(ViewState.SUCCESS);
    }
  }

  ///banner
  HomeBanner _homeBanner;

  HomeBanner get banner => _homeBanner;

  Future getHomeBanners() async {
    setState(ViewState.LOADING);
    ResultData result = await api.banners();
    if (result.error != null) {
      setState(ViewState.FAILED);
    } else {
      this._homeBanner = result.data;
      setState(ViewState.SUCCESS);
    }
  }

  ///category
  List<Category> _categories;

  List<Category> get categories => _categories;

  Future getCategories() async {
    setState(ViewState.LOADING);
    ResultData result = await api.homeCategory();
    if (result.error != null) {
      setState(ViewState.FAILED);
    } else {
      this._categories = result.data;
      setState(ViewState.SUCCESS);
    }
  }

  ///recommend
  StateShell<DishPage> _wrappedDishPage = StateShell();

  StateShell<DishPage> get wrappedDishPage => _wrappedDishPage;

  Future getRecommendDishes(bool init) async {
    if (init) {
      _wrappedDishPage = StateShell();
      notifyListeners();
    }
    ResultData result =
        await api.recommendDishes({'page': "1", 'pageSize': "9"});
    if (result.error != null) {
      _wrappedDishPage = StateShell(state: ViewState.FAILED);
    } else {
      _wrappedDishPage =
          StateShell(state: ViewState.SUCCESS, data: result.data);
    }
    notifyListeners();
  }

  @override
  List<String> requests() {
    return [
      LazyUri.HOME_BANNERS,
      LazyUri.HOME_CATEGORIES,
      LazyUri.HOME_BASIC_INFO,
      LazyUri.RECOMMEND_DISHES
    ];
  }
}
