class ConfigModel {
  String id;
  String? title;
  String key;
  String? value;

  ConfigModel({
    required this.id,
    this.title,
    required this.key,
    this.value,
  });

  factory ConfigModel.fromJson(Map<String, dynamic> json) {
    return ConfigModel(
      id: json['\$id'],
      title: json['title'],
      key: json['key'],
      value: json['value'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '\$id': id,
      'title': title,
      'key': key,
      'value': value,
    };
  }

  @override
  String toString() {
    return 'ConfigModel(id: $id, title: $title, key: $key, value: $value)';
  }
}
