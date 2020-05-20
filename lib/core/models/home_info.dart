///首页搜索栏信息
class HomeBasicInfo {
  bool canAdd;
  String keyword;
  int unread;

  HomeBasicInfo({this.canAdd, this.keyword, this.unread});

  factory HomeBasicInfo.fromJson(Map<String, dynamic> json) {
    return HomeBasicInfo(
      canAdd: json['canAdd'],
      keyword: json['keyword'],
      unread: json['unread'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['canAdd'] = this.canAdd;
    data['keyword'] = this.keyword;
    data['unread'] = this.unread;
    return data;
  }

  @override
  String toString() {
    return 'HomeBasicInfo{canAdd: $canAdd, keyword: $keyword, unread: $unread}';
  }
}
