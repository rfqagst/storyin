import 'package:flutter/material.dart';
import 'package:storyin/data/api/api_service.dart';
import 'package:storyin/data/db/auth_repository.dart';
import 'package:storyin/data/model/user.dart';
import 'package:storyin/utils/auth_state.dart';

class AuthProvider extends ChangeNotifier {
  final ApiService apiService;
  final AuthRepository authRepository;

  AuthProvider({required this.apiService, required this.authRepository}) {
    _state = AuthState.initial;
    _message = '';
  }

  bool isLoggedIn = false;

  late AuthState _state;
  AuthState get state => _state;
  late String _message;
  String get message => _message;

  Future<void> register(String name, String email, String password) async {
    _state = AuthState.loading;
    notifyListeners();
    try {
      final response = await apiService.register(name, email, password);

      if (response['error'] == false) {
        _state = AuthState.success;
        _message = response['message'];
      } else {
        _state = AuthState.error;
        _message = response['message'];
      }
    } catch (e) {
      _state = AuthState.error;
      _message = e.toString();
    }
    notifyListeners();
  }

  Future<void> login(String email, String password) async {
    _state = AuthState.loading;
    notifyListeners();
    try {
      final response = await apiService.login(email, password);

      if (response['error'] == false) {
        _state = AuthState.success;
        _message = response['message'];

        final loginResult = response['loginResult'];
        final userId = loginResult['userId'];
        final userName = loginResult['name'];
        final token = loginResult['token'];

        if (userId != null && userName != null && token != null) {
          final user = User(userId: userId, name: userName, token: token);
          await authRepository.saveUser(user);
          await authRepository.login();
        } else {
          throw Exception('Nilai loginResult tidak valid');
        }
      } else {
        _state = AuthState.error;
        _message = response['message'];
      }
    } catch (e) {
      _state = AuthState.error;
      _message = e.toString();
    }
  }

  Future<bool> logout() async {
    _state = AuthState.loading;
    notifyListeners();
    final logout = await authRepository.logout();
    if (logout) {
      await authRepository.deleteUser();
    }
    isLoggedIn = await authRepository.isLoggedIn();
    _state = AuthState.initial;
    notifyListeners();
    return !isLoggedIn;
  }
}
