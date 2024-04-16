import 'package:flutter/material.dart';
import 'package:flutter_client/Themes/dark_theme.dart';
import 'package:flutter_client/Themes/light_theme.dart';

CustomTheme customTheme = CustomTheme();

class CustomTheme with ChangeNotifier {
  static bool _isDark = ThemeMode.system == ThemeMode.dark;
  ThemeMode get themeMode => _isDark ? ThemeMode.dark : ThemeMode.light;

  void toggleTheme() {
    _isDark = !_isDark;
    notifyListeners();
  }

  ThemeData customLightTheme = lightTheme;

  ThemeData customDarkTheme = darkTheme;
}
