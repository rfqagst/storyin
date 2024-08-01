import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:storyin/data/model/user.dart';

class AuthRepository {
  final String stateKey = 'state';
  final String userKey = 'user';

  Future<bool> isLoggedIn() async {
    final preferences = await SharedPreferences.getInstance();
    await Future.delayed(
      const Duration(seconds: 2),
    );
    return preferences.getBool(stateKey) ?? false;
  }

  Future<bool> login() async {
    final preferences = await SharedPreferences.getInstance();
    await Future.delayed(
      const Duration(seconds: 2),
    );
    return preferences.setBool(stateKey, true);
  }

  Future<bool> logout() async {
    final preferences = await SharedPreferences.getInstance();
    await Future.delayed(
      const Duration(seconds: 2),
    );
    return preferences.setBool(stateKey, false);
  }

  Future<bool> saveUser(User user) async {
    final preferences = await SharedPreferences.getInstance();
    await Future.delayed(
      const Duration(seconds: 2),
    );
    return preferences.setString(userKey, jsonEncode(user.toJson()));
  }

  Future<bool> deleteUser() async {
    final preferences = await SharedPreferences.getInstance();
    await Future.delayed(
      const Duration(seconds: 2),
    );
    return preferences.setString(userKey, "");
  }

  Future<User?> getUser() async {
    final preferences = await SharedPreferences.getInstance();
    await Future.delayed(const Duration(seconds: 2));
    final json = preferences.getString(userKey) ?? "";

    try {
      final Map<String, dynamic> userMap = jsonDecode(json);
      return User.fromJson(userMap);
    } catch (e) {
      return null;
    }
  }
}
