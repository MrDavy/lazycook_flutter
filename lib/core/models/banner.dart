///首页广告图
class HomeBanner {
  List<BannerData> banners;
  int date;

  HomeBanner({this.banners, this.date});

  factory HomeBanner.fromJson(Map<String, dynamic> json) {
    if (json == null) return null;
    return HomeBanner(
      banners: json['banners'] != null
          ? (json['banners'] as List)
              .map((i) => BannerData.fromJson(i))
              .toList()
          : null,
      date: json['date'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['date'] = this.date;
    if (this.banners != null) {
      data['banners'] = this.banners.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class BannerData {
  int d_id;
  String desc;
  int id;
  String imgUrl;
  String redirectUrl;
  String title;
  int type;

  BannerData(
      {this.d_id,
      this.desc,
      this.id,
      this.imgUrl,
      this.redirectUrl,
      this.title,
      this.type});

  factory BannerData.fromJson(Map<String, dynamic> json) {
    return BannerData(
      d_id: json['d_id'],
      desc: json['desc'],
      id: json['id'],
      imgUrl: json['imgUrl'],
      redirectUrl: json['redirectUrl'],
      title: json['title'],
      type: json['type'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['d_id'] = this.d_id;
    data['desc'] = this.desc;
    data['id'] = this.id;
    data['imgUrl'] = this.imgUrl;
    data['redirectUrl'] = this.redirectUrl;
    data['title'] = this.title;
    data['type'] = this.type;
    return data;
  }
}
