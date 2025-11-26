import 'package:flutter/material.dart';
import '../models/models.dart';
import '../services/services.dart';

class AppProvider with ChangeNotifier {
  User? _currentUser;
  final UserService _userService = UserService();

  User? get currentUser => _currentUser;

  bool get isLoggedIn => _currentUser != null;

  String get userRole => _currentUser?.role ?? '';

  Future<bool> login(String email, String password) async {
    final user = await _userService.authenticate(email, password);
    if (user != null) {
      _currentUser = user;
      notifyListeners();
      return true;
    }
    return false;
  }

  void logout() {
    _currentUser = null;
    notifyListeners();
  }

  void setUser(User user) {
    _currentUser = user;
    notifyListeners();
  }
}
