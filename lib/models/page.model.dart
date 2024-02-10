class PageModel {
  String id;
  String? title;
  String? description;
  String? content;
  bool enabled;

  PageModel({
    required this.id,
    this.title,
    this.description,
    this.content,
    required this.enabled,
  });

  factory PageModel.fromJson(Map<String, dynamic> json) {
    return PageModel(
      id: json['\$id'],
      title: json['title'],
      description: json['description'],
      content: json['content'],
      enabled: json['enabled'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '\$id': id,
      'title': title,
      'description': description,
      'content': content,
      'enabled': enabled,
    };
  }

  @override
  String toString() {
    return 'PageModel(id: $id, title: $title, description: $description, content: $content, enabled: $enabled)';
  }
}
