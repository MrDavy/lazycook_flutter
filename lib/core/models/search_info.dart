class SearchInfo {
  List<SearchBaseInfo> history;
  List<SearchBaseInfo> recommend;

  SearchInfo({this.history, this.recommend});

  factory SearchInfo.fromJson(Map<String, dynamic> json) {
    if (json == null) return null;
    return SearchInfo(
      history: json['history'] != null
          ? (json['history'] as List)
              .map((i) => SearchBaseInfo.fromJson(i))
              .toList()
          : null,
      recommend: json['recommend'] != null
          ? (json['recommend'] as List)
              .map((i) => SearchBaseInfo.fromJson(i))
              .toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.history != null) {
      data['history'] = this.history.map((v) => v.toJson()).toList();
    }
    if (this.recommend != null) {
      data['recommend'] = this.recommend.map((v) => v.toJson()).toList();
    }
    return data;
  }

  @override
  String toString() {
    return 'SearchInfo{history: ${history.toString()}, recommend: ${recommend.toString()}';
  }
}

class SearchBaseInfo {
  final String icon;
  final int id;
  final String optIcon;
  final int type;
  final String word;

  SearchBaseInfo({this.icon, this.id, this.optIcon, this.type, this.word});

  factory SearchBaseInfo.fromJson(Map<String, dynamic> json) {
    return SearchBaseInfo(
      icon: json['icon'],
      id: json['id'],
      optIcon: json['optIcon'],
      type: json['type'],
      word: json['word'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['icon'] = this.icon;
    data['id'] = this.id;
    data['optIcon'] = this.optIcon;
    data['type'] = this.type;
    data['word'] = this.word;
    return data;
  }

  @override
  String toString() {
    return 'SearchBaseInfo{icon: $icon, id: $id, optIcon: $optIcon, type: $type, word: $word}';
  }
}
