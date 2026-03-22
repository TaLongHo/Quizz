import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeService {
  static const String _key = "isDarkMode";

  // Biến notifier để lắng nghe thay đổi toàn app
  static final ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(ThemeMode.light);

  // Khởi tạo (gọi ở main.dart)
  static Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    bool isDark = prefs.getBool(_key) ?? false;
    themeNotifier.value = isDark ? ThemeMode.dark : ThemeMode.light;
  }

  // Hàm chuyển đổi
  static Future<void> toggleTheme() async {
    final prefs = await SharedPreferences.getInstance();
    if (themeNotifier.value == ThemeMode.light) {
      themeNotifier.value = ThemeMode.dark;
      await prefs.setBool(_key, true);
    } else {
      themeNotifier.value = ThemeMode.light;
      await prefs.setBool(_key, false);
    }
  }

  static bool get isDark => themeNotifier.value == ThemeMode.dark;
}