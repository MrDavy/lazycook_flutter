///首页分类
class Category {
  int c_id;
  String img;
  String name;
  int p_id;
  List<Category> children;

  Category({this.c_id, this.img, this.name, this.p_id, this.children});

  factory Category.fromJson(Map<String, dynamic> json) {
    if (json == null) return null;
    return Category(
        c_id: json['c_id'],
        img: json['img'],
        name: json['name'],
        p_id: json['p_id'],
        children: json['children'] != null
            ? (json['children'] as List)
                .map((c) => Category.fromJson(c))
                .toList()
            : null);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['c_id'] = this.c_id;
    data['img'] = this.img;
    data['name'] = this.name;
    data['p_id'] = this.p_id;
    if (this.children != null) {
      data['children'] = this.children.map((c) => c.toJson()).toList();
    }
    return data;
  }

  @override
  String toString() {
    return 'Category{c_id: $c_id, img: $img, name: $name, p_id: $p_id}, children: $children';
  }
}
