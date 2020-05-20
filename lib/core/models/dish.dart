import 'package:lazycook/core/models/dish_comment.dart';
import 'package:lazycook/core/models/user.dart';

class Dish {
  String album;
  int approve_status;
  String burden;
  int canBeComment;
  int canBeSale;
  String date;
  List<Opt> opt;
  List<DishComment> dishComments;
  int hasCollected;
  int hasPraised;
  int id;
  String ingredients;
  String intro;
  List<Materials> materials;
  String ori_album;
  int show_status;
  Statistic statistic;
  List<Step> steps;
  String tags;
  String title;
  int u_id;
  String video;
  User userInfo;

  Dish(
      {this.album,
      this.approve_status,
      this.burden,
      this.canBeComment,
      this.canBeSale,
      this.date,
      this.opt,
      this.dishComments,
      this.hasCollected,
      this.hasPraised,
      this.id,
      this.ingredients,
      this.intro,
      this.materials,
      this.ori_album,
      this.show_status,
      this.statistic,
      this.steps,
      this.tags,
      this.title,
      this.u_id,
      this.video,
      this.userInfo});

  factory Dish.fromJson(Map<String, dynamic> json) {
    return Dish(
      album: json['album'],
      approve_status: json['approve_status'],
      burden: json['burden'],
      canBeComment: json['canBeComment'],
      canBeSale: json['canBeSale'],
      date: json['date'],
      opt: json['opt'] != null
          ? (json['opt'] as List).map((i) => Opt.fromJson(i)).toList()
          : null,
      dishComments: json['dishComments'] != null
          ? (json['dishComments'] as List)
              .map((i) => DishComment.fromJson(i))
              .toList()
          : null,
      hasCollected: json['hasCollected'],
      hasPraised: json['hasPraised'],
      id: json['id'],
      ingredients: json['ingredients'],
      intro: json['intro'],
      materials: json['materials'] != null
          ? (json['materials'] as List)
              .map((i) => Materials.fromJson(i))
              .toList()
          : null,
      ori_album: json['ori_album'],
      show_status: json['show_status'],
      statistic: json['statistic'] != null
          ? Statistic.fromJson(json['statistic'])
          : null,
      steps: json['steps'] != null
          ? (json['steps'] as List).map((i) => Step.fromJson(i)).toList()
          : null,
      tags: json['tags'],
      title: json['title'],
      u_id: json['u_id'],
      video: json['video'],
      userInfo:
          json['userInfo'] != null ? User.fromJson(json['userInfo']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['album'] = this.album;
    data['approve_status'] = this.approve_status;
    data['burden'] = this.burden;
    data['canBeComment'] = this.canBeComment;
    data['canBeSale'] = this.canBeSale;
    data['date'] = this.date;
    data['hasCollected'] = this.hasCollected;
    data['hasPraised'] = this.hasPraised;
    data['id'] = this.id;
    data['ingredients'] = this.ingredients;
    data['intro'] = this.intro;
    data['ori_album'] = this.ori_album;
    data['show_status'] = this.show_status;
    data['tags'] = this.tags;
    data['title'] = this.title;
    data['u_id'] = this.u_id;
    data['video'] = this.video;
    if (this.opt != null) {
      data['opt'] = this.opt.map((v) => v.toJson()).toList();
    }
    if (this.dishComments != null) {
      data['dishComments'] = this.dishComments.map((v) => v.toJson()).toList();
    }
    if (this.materials != null) {
      data['materials'] = this.materials.map((v) => v.toJson()).toList();
    }
    if (this.statistic != null) {
      data['statistic'] = this.statistic.toJson();
    }
    if (this.steps != null) {
      data['steps'] = this.steps.map((v) => v.toJson()).toList();
    }
    if (this.userInfo != null) {
      data['userInfo'] = this.userInfo.toJson();
    }
    return data;
  }
}

class Opt {
  String txt;
  int type;
  int alpha;
  int red;
  int green;
  int blue;

  Opt({this.txt, this.type, this.alpha, this.red, this.green, this.blue});

  factory Opt.fromJson(Map<String, dynamic> json) {
    return Opt(
      txt: json['txt'],
      type: json['type'],
      alpha: json['alpha'],
      red: json['red'],
      green: json['green'],
      blue: json['blue'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['txt'] = this.txt;
    data['type'] = this.type;
    data['alpha'] = this.alpha;
    data['red'] = this.red;
    data['green'] = this.green;
    data['blue'] = this.blue;
    return data;
  }
}

class Materials {
  String name;
  int type;
  String value;

  Materials({this.name, this.type, this.value});

  factory Materials.fromJson(Map<String, dynamic> json) {
    return Materials(
      name: json['name'],
      type: json['type'],
      value: json['value'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['name'] = this.name;
    data['type'] = this.type;
    data['value'] = this.value;
    return data;
  }
}

class Statistic {
  int collected;
  int comments;
  int d_id;
  String date;
  int id;
  int praise;
  int search_times;
  int shared;
  int views;

  Statistic(
      {this.collected,
      this.comments,
      this.d_id,
      this.date,
      this.id,
      this.praise,
      this.search_times,
      this.shared,
      this.views});

  factory Statistic.fromJson(Map<String, dynamic> json) {
    return Statistic(
      collected: json['collected'],
      comments: json['comments'],
      d_id: json['d_id'],
      date: json['date'],
      id: json['id'],
      praise: json['praise'],
      search_times: json['search_times'],
      shared: json['shared'],
      views: json['views'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['collected'] = this.collected;
    data['comments'] = this.comments;
    data['d_id'] = this.d_id;
    data['date'] = this.date;
    data['id'] = this.id;
    data['praise'] = this.praise;
    data['search_times'] = this.search_times;
    data['shared'] = this.shared;
    data['views'] = this.views;
    return data;
  }
}

class Step {
  int d_id;
  int id;
  String img;
  String ori_img;
  String step;

  Step({this.d_id, this.id, this.img, this.ori_img, this.step});

  factory Step.fromJson(Map<String, dynamic> json) {
    return Step(
      d_id: json['d_id'],
      id: json['id'],
      img: json['img'],
      ori_img: json['ori_img'],
      step: json['step'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['d_id'] = this.d_id;
    data['id'] = this.id;
    data['img'] = this.img;
    data['ori_img'] = this.ori_img;
    data['step'] = this.step;
    return data;
  }
}
