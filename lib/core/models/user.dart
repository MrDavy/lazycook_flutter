class User {
  String area;
  int be_concerned;
  int client;
  String concern_cook;
  String customCategories;
  String email;
  String gender;
  int id;
  String last_login_ip;
  String last_login_time;
  String nikename;
  String password;
  String phone;
  String portrait;
  String preference;
  String register_time;
  int register_type;
  String token;
  String username;
  int works;
  String tags;

  User(
      {this.area,
      this.be_concerned,
      this.client,
      this.concern_cook,
      this.customCategories,
      this.email,
      this.gender,
      this.id,
      this.last_login_ip,
      this.last_login_time,
      this.nikename,
      this.password,
      this.phone,
      this.portrait,
      this.preference,
      this.register_time,
      this.register_type,
      this.token,
      this.username,
      this.works,
      this.tags});

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      area: json['area'],
      be_concerned: json['be_concerned'],
      client: json['client'],
      concern_cook: json['concern_cook'],
      customCategories: json['customCategories'],
      email: json['email'],
      gender: json['gender'],
      id: json['id'],
      last_login_ip: json['last_login_ip'],
      last_login_time: json['last_login_time'],
      nikename: json['nikename'],
      password: json['password'],
      phone: json['phone'],
      portrait: json['portrait'],
      preference: json['preference'],
      register_time: json['register_time'],
      register_type: json['register_type'],
      token: json['token'],
      username: json['username'],
      works: json['works'],
      tags: json['tags'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['area'] = this.area;
    data['be_concerned'] = this.be_concerned;
    data['client'] = this.client;
    data['concern_cook'] = this.concern_cook;
    data['customCategories'] = this.customCategories;
    data['email'] = this.email;
    data['gender'] = this.gender;
    data['id'] = this.id;
    data['last_login_ip'] = this.last_login_ip;
    data['last_login_time'] = this.last_login_time;
    data['nikename'] = this.nikename;
    data['password'] = this.password;
    data['phone'] = this.phone;
    data['portrait'] = this.portrait;
    data['preference'] = this.preference;
    data['register_time'] = this.register_time;
    data['register_type'] = this.register_type;
    data['token'] = this.token;
    data['username'] = this.username;
    data['works'] = this.works;
    data['tags'] = this.tags;
    return data;
  }
}
