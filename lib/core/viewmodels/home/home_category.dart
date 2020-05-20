import 'package:lazycook/core/models/category.dart';
import 'package:lazycook/core/models/result_data.dart';
import 'package:meta/meta.dart';
import 'package:lazycook/core/services/api.dart';
import 'package:lazycook/core/viewmodels/base_model.dart';
import 'package:lazycook/utils/logger.dart';
import '../../../config/lazy_uri.dart';
///
/// @desc 首页分类
/// @author Davy
/// @date 2019/8/13 12:21
///

class HomeCategoryModel extends BaseModel {
  List<Category> _categories;

  HomeCategoryModel({@required API api}) : super(api);

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

  @override
  List<String> requests() {
    return [LazyUri.HOME_CATEGORIES];
  }
}
