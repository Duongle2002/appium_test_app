import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';

class AuthProvider with ChangeNotifier {
  String? _token;
  bool get isAuthenticated => _token != null;

  AuthProvider() {
    _loadToken();
  }

  Future<void> _loadToken() async {
    _token = await ApiService.getToken();
    if (_token != null) {
      final isValid = await ApiService.verifyToken();
      if (!isValid) _token = null; // Xóa token nếu không hợp lệ
    }
    notifyListeners();
  }

  Future<void> register(String name, String email, String password) async {
    await ApiService.register(name, email, password);
  }

  Future<void> login(String email, String password) async {
    _token = await ApiService.login(email, password);
    notifyListeners();
  }

  void logout() {
    _token = null;
    ApiService.clearToken(); // Xóa token khi đăng xuất
    notifyListeners();
  }

}

extension ApiServiceExtension on ApiService {
  static Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
  }
}