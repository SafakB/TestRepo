class ConversionModel {
  String id;
  List<String> participants;
  String? name;
  bool group;

  ConversionModel({
    required this.id,
    required this.participants,
    this.name,
    required this.group,
  });

  factory ConversionModel.fromJson(Map<String, dynamic> json) {
    return ConversionModel(
      id: json['\$id'],
      participants: List<String>.from(json['participants']),
      name: json['name'],
      group: json['group'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '\$id': id,
      'participants': participants,
      'name': name,
      'group': group,
    };
  }

  @override
  String toString() {
    return 'ConversionModel(id: $id, participants: $participants, name: $name, group: $group)';
  }
}
