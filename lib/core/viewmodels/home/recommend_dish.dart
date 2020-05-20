import 'package:lazycook/core/models/dish_page.dart';
import 'package:lazycook/core/models/recommend_dish.dart';
import 'package:lazycook/core/models/result_data.dart';
import 'package:lazycook/core/viewmodels/person/login/user_model.dart';
import 'package:meta/meta.dart';
import 'package:lazycook/core/services/api.dart';
import 'package:lazycook/core/viewmodels/base_model.dart';
import 'package:lazycook/utils/logger.dart';
import '../../../config/lazy_uri.dart';
///
/// @desc 首页推荐菜品列表
/// @author Davy
/// @date 2019/8/14 10:52
///

class RecommendDishModel extends BaseModel {
  Logger logger;

  RecommendDishModel({@required API api, UserModel userModel})
      : super(api);

  DishPage _dishPage;

  DishPage get dishPage => _dishPage;

  Future getRecommendDishes() async {
    setState(ViewState.LOADING);
    ResultData result =
        await api.recommendDishes({'page': "1", 'pageSize': "9"});
    if (result.error != null) {
      setState(ViewState.FAILED);
    } else {
      this._dishPage = result.data;
      setState(ViewState.SUCCESS);
    }
  }

  @override
  List<String> requests() {
    return [LazyUri.RECOMMEND_DISHES];
  }
}
