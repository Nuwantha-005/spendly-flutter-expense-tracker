import 'package:flutter/material.dart';
import '../constants/app_dimensions.dart';
import 'app_colors.dart';
import 'app_text_styles.dart';

/// Centralized ThemeData for Spendly supporting Light and Dark modes.
class AppTheme {
  AppTheme._();

  /// Light theme definition
  static ThemeData get lightTheme {
    const colorScheme = ColorScheme.light(
      primary: AppColors.primary,
      onPrimary: AppColors.onPrimary,
      primaryContainer: AppColors.primaryContainer,
      onPrimaryContainer: AppColors.onPrimaryContainer,
      secondary: AppColors.secondary,
      onSecondary: AppColors.onSecondary,
      secondaryContainer: AppColors.secondaryContainer,
      surface: AppColors.surface,
      onSurface: AppColors.onSurface,
      error: AppColors.error,
      onError: AppColors.onError,
      errorContainer: AppColors.errorContainer,
      onErrorContainer: AppColors.onErrorContainer,
      outline: AppColors.border,
      outlineVariant: AppColors.borderSubtle,
    );

    return _buildTheme(
      colorScheme: colorScheme,
      scaffoldBg: AppColors.background,
      cardBg: AppColors.surface,
      borderColor: AppColors.border,
      dividerColor: AppColors.divider,
      appBarBg: AppColors.background,
      appBarFg: AppColors.textPrimary,
      textColor: AppColors.textPrimary,
      textSecondaryColor: AppColors.textSecondary,
      inputBg: AppColors.surface,
      navBarBg: AppColors.surface,
      isDark: false,
    );
  }

  /// Dark theme definition
  static ThemeData get darkTheme {
    const colorScheme = ColorScheme.dark(
      primary: AppColors.primaryLight,
      onPrimary: AppColors.onBackground,
      primaryContainer: AppColors.primaryContainerDark,
      onPrimaryContainer: AppColors.onPrimaryContainerDark,
      secondary: AppColors.secondaryLight,
      onSecondary: AppColors.onBackground,
      secondaryContainer: Color(0xFF0369A1),
      surface: AppColors.surfaceDark,
      onSurface: AppColors.onSurfaceDark,
      error: Color(0xFFF87171),
      onError: Color(0xFF450A0A),
      errorContainer: AppColors.errorContainerDark,
      onErrorContainer: AppColors.onErrorContainerDark,
      outline: AppColors.borderDark,
      outlineVariant: AppColors.borderSubtleDark,
    );

    return _buildTheme(
      colorScheme: colorScheme,
      scaffoldBg: AppColors.backgroundDark,
      cardBg: AppColors.surfaceDark,
      borderColor: AppColors.borderDark,
      dividerColor: AppColors.dividerDark,
      appBarBg: AppColors.backgroundDark,
      appBarFg: AppColors.textPrimaryDark,
      textColor: AppColors.textPrimaryDark,
      textSecondaryColor: AppColors.textSecondaryDark,
      inputBg: AppColors.surfaceVariantDark,
      navBarBg: AppColors.surfaceDark,
      isDark: true,
    );
  }

  static ThemeData _buildTheme({
    required ColorScheme colorScheme,
    required Color scaffoldBg,
    required Color cardBg,
    required Color borderColor,
    required Color dividerColor,
    required Color appBarBg,
    required Color appBarFg,
    required Color textColor,
    required Color textSecondaryColor,
    required Color inputBg,
    required Color navBarBg,
    required bool isDark,
  }) {
    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: scaffoldBg,
      cardColor: cardBg,
      dividerColor: dividerColor,

      // Typography
      fontFamily: null,
      textTheme: TextTheme(
        headlineLarge: AppTextStyles.headlineLarge.copyWith(color: textColor),
        headlineMedium: AppTextStyles.headlineMedium.copyWith(color: textColor),
        headlineSmall: AppTextStyles.headlineSmall.copyWith(color: textColor),
        titleLarge: AppTextStyles.titleLarge.copyWith(color: textColor),
        titleMedium: AppTextStyles.titleMedium.copyWith(color: textColor),
        titleSmall: AppTextStyles.titleSmall.copyWith(color: textSecondaryColor),
        bodyLarge: AppTextStyles.bodyLarge.copyWith(color: textColor),
        bodyMedium: AppTextStyles.bodyMedium.copyWith(color: textSecondaryColor),
        bodySmall: AppTextStyles.bodySmall.copyWith(
          color: isDark ? AppColors.textTertiaryDark : AppColors.textTertiary,
        ),
        labelLarge: AppTextStyles.labelLarge.copyWith(
          color: isDark ? Colors.white : AppColors.onPrimary,
        ),
        labelMedium: AppTextStyles.labelMedium.copyWith(color: textSecondaryColor),
        labelSmall: AppTextStyles.labelSmall.copyWith(
          color: isDark ? AppColors.textTertiaryDark : AppColors.textTertiary,
        ),
      ),

      // AppBar Theme
      appBarTheme: AppBarTheme(
        backgroundColor: appBarBg,
        foregroundColor: appBarFg,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: AppTextStyles.titleLarge.copyWith(color: appBarFg),
        iconTheme: IconThemeData(color: appBarFg),
      ),

      // Card Theme
      cardTheme: CardThemeData(
        color: cardBg,
        elevation: AppDimensions.cardElevation,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
          side: BorderSide(
            color: borderColor,
            width: AppDimensions.cardBorderWidth,
          ),
        ),
      ),

      // Elevated Button Theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: isDark ? AppColors.primaryLight : AppColors.primary,
          foregroundColor: isDark ? AppColors.onBackground : AppColors.onPrimary,
          elevation: 0,
          minimumSize: const Size(double.infinity, AppDimensions.buttonHeight),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
          ),
          textStyle: AppTextStyles.labelLarge,
        ),
      ),

      // Outlined Button Theme
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: isDark ? AppColors.primaryLight : AppColors.primary,
          elevation: 0,
          minimumSize: const Size(double.infinity, AppDimensions.buttonHeight),
          side: BorderSide(
            color: isDark ? AppColors.primaryLight : AppColors.primary,
            width: 1.5,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
          ),
          textStyle: AppTextStyles.labelLarge.copyWith(
            color: isDark ? AppColors.primaryLight : AppColors.primary,
          ),
        ),
      ),

      // Text Button Theme
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: isDark ? AppColors.primaryLight : AppColors.primary,
          textStyle: AppTextStyles.labelLarge.copyWith(
            color: isDark ? AppColors.primaryLight : AppColors.primary,
          ),
        ),
      ),

      // Input Decoration Theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: inputBg,
        hintStyle: AppTextStyles.bodyMedium.copyWith(
          color: isDark ? AppColors.textDisabledDark : AppColors.textTertiary,
        ),
        labelStyle: AppTextStyles.bodyMedium.copyWith(color: textSecondaryColor),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.spacingMd,
          vertical: AppDimensions.spacingMd,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
          borderSide: BorderSide(color: borderColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
          borderSide: BorderSide(color: borderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
          borderSide: BorderSide(
            color: isDark ? AppColors.primaryLight : AppColors.primary,
            width: 1.5,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
          borderSide: const BorderSide(
            color: AppColors.error,
            width: 1.2,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
          borderSide: const BorderSide(
            color: AppColors.error,
            width: 1.5,
          ),
        ),
      ),

      // Bottom Navigation Bar Theme
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: navBarBg,
        selectedItemColor: isDark ? AppColors.primaryLight : AppColors.primary,
        unselectedItemColor: textSecondaryColor,
        selectedLabelStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
        elevation: 8,
        type: BottomNavigationBarType.fixed,
      ),

      // Dialog Theme
      dialogTheme: DialogThemeData(
        backgroundColor: cardBg,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
        ),
        titleTextStyle: AppTextStyles.titleLarge.copyWith(color: textColor),
        contentTextStyle: AppTextStyles.bodyMedium.copyWith(color: textSecondaryColor),
      ),

      // SnackBar Theme
      snackBarTheme: SnackBarThemeData(
        backgroundColor: isDark ? AppColors.surfaceVariantDark : AppColors.textPrimary,
        contentTextStyle: TextStyle(
          color: isDark ? AppColors.textPrimaryDark : Colors.white,
          fontSize: 14,
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        ),
      ),

      // Divider Theme
      dividerTheme: DividerThemeData(
        color: dividerColor,
        thickness: 1.0,
        space: 1.0,
      ),
    );
  }
}
