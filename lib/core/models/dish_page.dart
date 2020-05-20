import 'package:lazycook/core/models/dish.dart';

class DishPage {
  bool hasNext;
  List<Dish> items;
  int pageNum;
  int pageSize;
  int totalNum;
  int totalPage;

  DishPage(
      {this.hasNext,
      this.items,
      this.pageNum,
      this.pageSize,
      this.totalNum,
      this.totalPage});

  factory DishPage.fromJson(Map<String, dynamic> json) {
    if (json == null) return null;
    return DishPage(
      hasNext: json['hasNext'],
      items: json['items'] != null
          ? (json['items'] as List).map((i) => Dish.fromJson(i)).toList()
          : null,
      pageNum: json['pageNum'],
      pageSize: json['pageSize'],
      totalNum: json['totalNum'],
      totalPage: json['totalPage'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['hasNext'] = this.hasNext;
    data['pageNum'] = this.pageNum;
    data['pageSize'] = this.pageSize;
    data['totalNum'] = this.totalNum;
    data['totalPage'] = this.totalPage;
    if (this.items != null) {
      data['items'] = this.items.map((v) => v.toJson()).toList();
    }
    return data;
  }
}
