class DishComment {
  List<ChildComment> childComments;
  String content;
  int d_id;
  int date;
  int hasPraised;
  int id;
  String imgs;
  int praise;
  int u_id;
  String username;

  DishComment(
      {this.childComments,
      this.content,
      this.d_id,
      this.date,
      this.hasPraised,
      this.id,
      this.imgs,
      this.praise,
      this.u_id,
      this.username});

  factory DishComment.fromJson(Map<String, dynamic> json) {
    return DishComment(
      childComments: json['childComments'] != null
          ? (json['childComments'] as List)
              .map((i) => ChildComment.fromJson(i))
              .toList()
          : null,
      content: json['content'],
      d_id: json['d_id'],
      date: json['date'],
      hasPraised: json['hasPraised'],
      id: json['id'],
      imgs: json['imgs'],
      praise: json['praise'],
      u_id: json['u_id'],
      username: json['username'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['content'] = this.content;
    data['d_id'] = this.d_id;
    data['date'] = this.date;
    data['hasPraised'] = this.hasPraised;
    data['id'] = this.id;
    data['imgs'] = this.imgs;
    data['praise'] = this.praise;
    data['u_id'] = this.u_id;
    data['username'] = this.username;
    if (this.childComments != null) {
      data['childComments'] =
          this.childComments.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class ChildComment {
  int comment_id;
  String content;
  int date;
  int from_uid;
  String from_username;
  int hasPraised;
  int id;
  String imgs;
  int praise;
  int to_uid;
  String to_username;

  ChildComment(
      {this.comment_id,
      this.content,
      this.date,
      this.from_uid,
      this.from_username,
      this.hasPraised,
      this.id,
      this.imgs,
      this.praise,
      this.to_uid,
      this.to_username});

  factory ChildComment.fromJson(Map<String, dynamic> json) {
    return ChildComment(
      comment_id: json['comment_id'],
      content: json['content'],
      date: json['date'],
      from_uid: json['from_uid'],
      from_username: json['from_username'],
      hasPraised: json['hasPraised'],
      id: json['id'],
      imgs: json['imgs'],
      praise: json['praise'],
      to_uid: json['to_uid'],
      to_username: json['to_username'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['comment_id'] = this.comment_id;
    data['content'] = this.content;
    data['date'] = this.date;
    data['from_uid'] = this.from_uid;
    data['from_username'] = this.from_username;
    data['hasPraised'] = this.hasPraised;
    data['id'] = this.id;
    data['imgs'] = this.imgs;
    data['praise'] = this.praise;
    data['to_uid'] = this.to_uid;
    data['to_username'] = this.to_username;
    return data;
  }
}
