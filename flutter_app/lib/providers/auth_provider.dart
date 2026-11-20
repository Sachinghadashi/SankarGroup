import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/api_service.dart';
import '../core/utils/shared_prefs_helper.dart';

class AuthProvider extends ChangeNotifier {
  UserModel? _currentUser;
  String? _token;
  bool _isLoading = false;
  String? _errorMessage;

  UserModel? get currentUser => _currentUser;
  String? get token => _token;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _token != null && _currentUser != null;

  // Initialize session from SharedPreferences on app launch
  Future<bool> checkAuthStatus() async {
    _isLoading = true;
    notifyListeners();

    try {
      final savedToken = await SharedPrefsHelper.getToken();
      final savedUser = await SharedPrefsHelper.getUser();

      if (savedToken != null && savedUser != null) {
        _token = savedToken;
        _currentUser = savedUser;
        _isLoading = false;
        notifyListeners();
        return true;
      }
    } catch (e) {
      debugPrint('Error restoring session: $e');
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  // User Login
  Future<bool> login({
    required String email,
    required String password,
    bool rememberMe = true,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await ApiService.login(email, password);

    _isLoading = false;
    if (result['success'] == true) {
      _token = result['token'];
      _currentUser = result['user'];

      // Persist in SharedPreferences
      await SharedPrefsHelper.saveToken(_token!);
      await SharedPrefsHelper.saveUser(_currentUser!);
      await SharedPrefsHelper.setRememberMe(rememberMe, email);

      notifyListeners();
      return true;
    } else {
      _errorMessage = result['message'] ?? 'Authentication failed';
      notifyListeners();
      return false;
    }
  }

  // User Sign Up
  Future<bool> register({
    required String name,
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await ApiService.register(name, email, password);

    _isLoading = false;
    if (result['success'] == true) {
      _token = result['token'];
      _currentUser = result['user'];

      // Persist in SharedPreferences
      await SharedPrefsHelper.saveToken(_token!);
      await SharedPrefsHelper.saveUser(_currentUser!);
      await SharedPrefsHelper.setRememberMe(true, email);

      notifyListeners();
      return true;
    } else {
      _errorMessage = result['message'] ?? 'Registration failed';
      notifyListeners();
      return false;
    }
  }

  // User Logout
  Future<void> logout() async {
    _token = null;
    _currentUser = null;
    await SharedPrefsHelper.clearSession();
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
