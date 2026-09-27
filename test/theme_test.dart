import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spendy/core/theme/app_colors.dart';
import 'package:spendy/core/theme/app_theme.dart';
import 'package:spendy/core/theme/theme_provider.dart';

void main() {
  group('Theme System Tests', () {
    test('Light theme properties verification', () {
      final light = AppTheme.lightTheme;
      expect(light.brightness, Brightness.light);
      expect(light.scaffoldBackgroundColor, AppColors.background);
      expect(light.colorScheme.primary, AppColors.primary);
      expect(light.cardColor, AppColors.surface);
    });

    test('Dark theme properties verification', () {
      final dark = AppTheme.darkTheme;
      expect(dark.brightness, Brightness.dark);
      expect(dark.scaffoldBackgroundColor, AppColors.backgroundDark);
      expect(dark.colorScheme.primary, AppColors.primaryLight);
      expect(dark.cardColor, AppColors.surfaceDark);
    });

    test('ThemeModeNotifier toggle switches mode cleanly', () {
      final notifier = ThemeModeNotifier();
      // Initially system
      expect(notifier.state, ThemeMode.system);

      notifier.setThemeMode(ThemeMode.dark);
      expect(notifier.state, ThemeMode.dark);

      notifier.toggleTheme();
      expect(notifier.state, ThemeMode.light);

      notifier.toggleTheme();
      expect(notifier.state, ThemeMode.dark);
    });
  });
}
