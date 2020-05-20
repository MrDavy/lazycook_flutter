import 'package:lazycook/core/models/dish.dart';
import 'package:lazycook/core/models/dish_page.dart';
import 'package:lazycook/core/models/page.dart';
import 'package:lazycook/core/models/result_data.dart';
import 'package:lazycook/core/services/api.dart';
import 'package:lazycook/core/viewmodels/base_model.dart';
import 'package:lazycook/ui/widgets/slidemenu/slide_list_model.dart';
import '../../../config/lazy_uri.dart';
class WorksModel extends SlideListModel<Dish> {
  WorksModel(API api) : super(api);

  Future workOpt(index, optType) {
    readyToChange();
    return Future.delayed(Duration(milliseconds: 200), () {
      remove(index);
      onDataChanged();
    });
  }

  @override
  Future<PageData<Dish>> loadData(params) async {
    ResultData result = await api.workList(params);
    DishPage data = result?.data;
    return PageData<Dish>(
        hasNext: data?.hasNext,
        items: data?.items,
        pageNum: data?.pageNum,
        pageSize: data?.pageSize,
        totalNum: data?.totalNum,
        totalPage: data?.totalPage ?? 0,
        error: result?.error);
  }

  @override
  Future onComplete(List<Dish> list) {
    this.addAll(list);
    return null;
  }

  @override
  List<String> requests() {
    return [LazyUri.DELETE_WORK];
  }

  @override
  onDataChanged() {
    if (this.list?.isNotEmpty == true) {
      setState(PageViewState.SUCCESS);
    } else {
      setState(PageViewState.EMPTY_DATA);
    }
  }
}
