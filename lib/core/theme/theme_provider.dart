import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

const String _kThemePreferenceKey = 'spendy_theme_mode';

/// State notifier managing ThemeMode with SharedPreferences persistence using ValueNotifier.
class ThemeModeNotifier extends ValueNotifier<ThemeMode> {
  ThemeModeNotifier() : super(ThemeMode.system) {
    _loadPreference();
  }

  /// Compatibility getter for the current state.
  ThemeMode get state => value;

  Future<void> _loadPreference() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedMode = prefs.getString(_kThemePreferenceKey);
      if (savedMode != null) {
        switch (savedMode) {
          case 'light':
            value = ThemeMode.light;
            break;
          case 'dark':
            value = ThemeMode.dark;
            break;
          case 'system':
          default:
            value = ThemeMode.system;
            break;
        }
      }
    } catch (_) {
      // Default safely to system mode if storage fails
      value = ThemeMode.system;
    }
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    value = mode;
    try {
      final prefs = await SharedPreferences.getInstance();
      String modeStr;
      switch (mode) {
        case ThemeMode.light:
          modeStr = 'light';
          break;
        case ThemeMode.dark:
          modeStr = 'dark';
          break;
        case ThemeMode.system:
          modeStr = 'system';
          break;
      }
      await prefs.setString(_kThemePreferenceKey, modeStr);
    } catch (_) {
      // Silent catch
    }
  }

  void toggleTheme() {
    if (value == ThemeMode.dark) {
      setThemeMode(ThemeMode.light);
    } else {
      setThemeMode(ThemeMode.dark);
    }
  }
}

/// Global instance of ThemeModeNotifier accessible throughout the application.
final themeNotifier = ThemeModeNotifier();
