import 'package:lazycook/core/request/exception/error.dart';

class PageData<T> {
  bool hasNext;
  List<T> items;
  int pageNum;
  int pageSize;
  int totalNum;
  int totalPage;
  LazyError error;

  PageData(
      {this.hasNext,
      this.items,
      this.pageNum,
      this.pageSize,
      this.totalNum,
      this.totalPage,
      this.error});
}
