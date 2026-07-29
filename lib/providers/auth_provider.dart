import 'package:flutter/material.dart';
import '../services/database_helper.dart';

class AuthProvider extends ChangeNotifier {
  bool _isLoggedIn = false;
  String _role = '';
  String _name = '';
  String _email = '';
  int _userId = 0;

  bool get isLoggedIn => _isLoggedIn;
  String get role => _role;
  bool get isAdmin => _role == 'admin';
  bool get isUser => _role == 'user';
  String get name => _name;
  String get email => _email;
  int get userId => _userId;

  // Login: cek admin dulu, lalu cek database user
  Future<String> login(String email, String password) async {
    if (email == 'Admintoko@gmail.com' && password == 'admin123') {
      _isLoggedIn = true;
      _role = 'admin';
      _name = 'Admin Toko';
      _email = email;
      notifyListeners();
      return 'admin';
    }

    final user = await DatabaseHelper.loginUser(email, password);
    if (user != null) {
      _isLoggedIn = true;
      _role = 'user';
      _name = user['name'] ?? '';
      _email = user['email'] ?? '';
      _userId = user['id'] ?? 0;
      notifyListeners();
      return 'user';
    }

    return '';
  }

  // Register: daftar user baru ke database
  Future<bool> register(String name, String email, String password) async {
    if (email == 'Admintoko@gmail.com') {
      return false;
    }
    final id = await DatabaseHelper.registerUser(name, email, password);
    if (id > 0) {
      _isLoggedIn = true;
      _role = 'user';
      _name = name;
      _email = email;
      _userId = id;
      notifyListeners();
      return true;
    }
    return false;
  }

  // Logout: hapus semua data session
  void logout() {
    _isLoggedIn = false;
    _role = '';
    _name = '';
    _email = '';
    _userId = 0;
    notifyListeners();
  }
}
