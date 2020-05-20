import 'package:lazycook/core/models/banner.dart';
import 'package:lazycook/core/models/result_data.dart';
import 'package:lazycook/utils/logger.dart';
import 'package:meta/meta.dart';
import 'package:lazycook/core/services/api.dart';
import 'package:lazycook/core/viewmodels/base_model.dart';
import '../../../config/lazy_uri.dart';
///
/// @desc 首页广告页
/// @author Davy
/// @date 2019/8/9 14:47
///

class BannerModel extends BaseModel {
  Logger logger;

  BannerModel({@required API api}) : super(api);

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

  @override
  List<String> requests() {
    return [LazyUri.HOME_BANNERS];
  }
}
