import 'package:flutter/material.dart';

class ThemeProvider with ChangeNotifier {
  // Varsayılan olarak sistem ayarını veya light modu seçelim
  ThemeMode _themeMode = ThemeMode.light;

  ThemeMode get themeMode => _themeMode;

  bool get isDarkMode => _themeMode == ThemeMode.dark;

  void toggleTheme(bool isOn) {
    _themeMode = isOn ? ThemeMode.dark : ThemeMode.light;
    notifyListeners(); // Tüm sayfaları haberdar eder
  }
}
