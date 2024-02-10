class UserModel {
  String id;
  String? name;
  String? email;
  bool emailVerification;
  String? phone;
  bool phoneVerification;
  bool status;
  String? sessionId;

  UserModel({
    required this.id,
    this.name,
    this.email,
    required this.emailVerification,
    this.phone,
    required this.phoneVerification,
    required this.status,
    this.sessionId,
  });

  UserModel.fromJson(Map<String, dynamic> json)
      : id = json['\$id'],
        name = json['name'],
        email = json['email'],
        emailVerification = json['emailVerification'],
        phone = json['phone'],
        phoneVerification = json['phoneVerification'],
        status = json['status'],
        sessionId = json['sessionId'];

  UserModel.fromMap(Map<String, dynamic> map)
      : id = map['\$id'],
        name = map['name'],
        email = map['email'],
        emailVerification = map['emailVerification'],
        phone = map['phone'],
        phoneVerification = map['phoneVerification'],
        status = map['status'],
        sessionId = map['sessionId'];

  Map<String, dynamic> toJson() {
    return {
      'userId': id,
      'name': name,
      'email': email,
      'emailVerification': emailVerification,
      'phone': phone,
      'phoneVerification': phoneVerification,
      'status': status,
      'sessionId': sessionId,
    };
  }

  @override
  String toString() {
    return 'UserModel(id: $id, name: $name, email: $email, emailVerification: $emailVerification, phone: $phone, phoneVerification: $phoneVerification, status: $status, sessionId: $sessionId)';
  }
}
