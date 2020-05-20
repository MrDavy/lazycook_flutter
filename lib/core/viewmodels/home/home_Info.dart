import 'package:lazycook/core/models/home_info.dart';
import 'package:lazycook/core/models/result_data.dart';
import 'package:lazycook/core/services/api.dart';
import 'package:lazycook/core/viewmodels/base_model.dart';
import 'package:meta/meta.dart';
import '../../../config/lazy_uri.dart';
///
/// @desc 首页基本信息
/// @author Davy
/// @date 2019/8/9 14:47
///

class HomeInfoModel extends BaseModel {
  HomeInfoModel({@required API api}) : super(api);

  HomeBasicInfo _homeInfo;

  HomeBasicInfo get homeInfo => _homeInfo;

  Future getHomeBasicInfo() async {
    setState(ViewState.LOADING);
    ResultData result = await api.getHomeBasicInfo();
    if (result.error != null) {
      setState(ViewState.FAILED);
    } else {
      this._homeInfo = result.data;
      setState(ViewState.SUCCESS);
    }
  }

  @override
  List<String> requests() {
    return [LazyUri.HOME_BASIC_INFO];
  }
}
