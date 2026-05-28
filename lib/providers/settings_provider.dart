import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsProvider extends ChangeNotifier {
  static const _keyDarkMode = 'settings_dark_mode';
  static const _keyOrderUpdates = 'settings_order_updates';
  static const _keyPromotions = 'settings_promotions';
  static const _keyMessages = 'settings_messages';
  static const _keyWelcomeTips = 'settings_welcome_tips';
  static const _keyVerboseLogging = 'settings_verbose_logging';

  bool isDarkMode = false;
  bool orderUpdates = true;
  bool promotions = true;
  bool messages = true;
  bool showWelcomeTips = true;
  bool verboseLogging = false;

  ThemeMode get themeMode => isDarkMode ? ThemeMode.dark : ThemeMode.light;

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    isDarkMode = prefs.getBool(_keyDarkMode) ?? false;
    orderUpdates = prefs.getBool(_keyOrderUpdates) ?? true;
    promotions = prefs.getBool(_keyPromotions) ?? true;
    messages = prefs.getBool(_keyMessages) ?? true;
    showWelcomeTips = prefs.getBool(_keyWelcomeTips) ?? true;
    verboseLogging = prefs.getBool(_keyVerboseLogging) ?? false;
    notifyListeners();
  }

  Future<void> setDarkMode(bool value) async {
    isDarkMode = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyDarkMode, value);
    notifyListeners();
  }

  Future<void> setOrderUpdates(bool value) async {
    orderUpdates = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyOrderUpdates, value);
    notifyListeners();
  }

  Future<void> setPromotions(bool value) async {
    promotions = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyPromotions, value);
    notifyListeners();
  }

  Future<void> setMessages(bool value) async {
    messages = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyMessages, value);
    notifyListeners();
  }

  Future<void> setWelcomeTips(bool value) async {
    showWelcomeTips = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyWelcomeTips, value);
    notifyListeners();
  }

  Future<void> setVerboseLogging(bool value) async {
    verboseLogging = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyVerboseLogging, value);
    notifyListeners();
  }
}
