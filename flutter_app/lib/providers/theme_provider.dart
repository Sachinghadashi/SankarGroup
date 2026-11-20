import 'package:flutter/material.dart';
import '../core/utils/shared_prefs_helper.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.light;

  ThemeMode get themeMode => _themeMode;
  bool get isDarkMode => _themeMode == ThemeMode.dark;

  Future<void> initTheme() async {
    final isDark = await SharedPrefsHelper.isDarkMode();
    _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }

  Future<void> toggleTheme() async {
    if (_themeMode == ThemeMode.light) {
      _themeMode = ThemeMode.dark;
      await SharedPrefsHelper.setDarkMode(true);
    } else {
      _themeMode = ThemeMode.light;
      await SharedPrefsHelper.setDarkMode(false);
    }
    notifyListeners();
  }
}
