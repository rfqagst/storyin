import 'dart:convert';

class User {
  String? userId;
  String? name;
  String? token;

  User({required this.userId, required this.name, required this.token});

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'name': name,
      'token': token,
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      userId: map['userId'],
      name: map['name'],
      token: map['token'],
    );
  }

  String toJson() => json.encode(toMap());

  factory User.fromJson(String source) => User.fromMap(json.decode(source));
}
