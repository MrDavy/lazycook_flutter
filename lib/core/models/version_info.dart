class VersionInfo {
  String description;
  int force_update;
  int hasNewVersion;
  String url;

  VersionInfo(
      {this.description, this.force_update, this.hasNewVersion, this.url});

  factory VersionInfo.fromJson(Map<String, dynamic> json) {
    return VersionInfo(
      description: json['description'],
      force_update: json['force_update'],
      hasNewVersion: json['hasNewVersion'],
      url: json['url'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['description'] = this.description;
    data['force_update'] = this.force_update;
    data['hasNewVersion'] = this.hasNewVersion;
    data['url'] = this.url;
    return data;
  }
}
