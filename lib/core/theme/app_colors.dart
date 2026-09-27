import 'package:flutter/material.dart';

/// Centralized color palette for Spendly supporting Light and Dark modes.
/// Designed for a clean, modern financial application.
class AppColors {
  AppColors._();

  // Primary Brand Colors (Financial Green/Teal)
  static const Color primary = Color(0xFF0F766E);
  static const Color primaryLight = Color(0xFF14B8A6);
  static const Color primaryDark = Color(0xFF115E59);
  static const Color primaryContainer = Color(0xFFE6F4F1);
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color onPrimaryContainer = Color(0xFF0D524C);

  // Dark Mode Primary Overrides
  static const Color primaryContainerDark = Color(0xFF134E4A);
  static const Color onPrimaryContainerDark = Color(0xFF99F6E4);

  // Secondary / Accent Colors
  static const Color secondary = Color(0xFF0284C7);
  static const Color secondaryLight = Color(0xFF38BDF8);
  static const Color secondaryContainer = Color(0xFFE0F2FE);
  static const Color onSecondary = Color(0xFFFFFFFF);

  // Background and Surfaces (Light Mode)
  static const Color background = Color(0xFFF8FAFC);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFF1F5F9);
  static const Color onBackground = Color(0xFF0F172A);
  static const Color onSurface = Color(0xFF0F172A);

  // Background and Surfaces (Dark Mode)
  static const Color backgroundDark = Color(0xFF0B1120);
  static const Color surfaceDark = Color(0xFF131D33);
  static const Color surfaceVariantDark = Color(0xFF1E293B);
  static const Color onBackgroundDark = Color(0xFFF8FAFC);
  static const Color onSurfaceDark = Color(0xFFF8FAFC);

  // Borders and Dividers (Light Mode)
  static const Color border = Color(0xFFE2E8F0);
  static const Color borderSubtle = Color(0xFFF1F5F9);
  static const Color divider = Color(0xFFE2E8F0);

  // Borders and Dividers (Dark Mode)
  static const Color borderDark = Color(0xFF26334D);
  static const Color borderSubtleDark = Color(0xFF1E293B);
  static const Color dividerDark = Color(0xFF26334D);

  // Typography Colors (Light Mode)
  static const Color textPrimary = Color(0xFF0F172A);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color textTertiary = Color(0xFF94A3B8);
  static const Color textDisabled = Color(0xFFCBD5E1);

  // Typography Colors (Dark Mode)
  static const Color textPrimaryDark = Color(0xFFF8FAFC);
  static const Color textSecondaryDark = Color(0xFF94A3B8);
  static const Color textTertiaryDark = Color(0xFF64748B);
  static const Color textDisabledDark = Color(0xFF475569);

  // Semantic Status Colors
  static const Color success = Color(0xFF16A34A);
  static const Color successContainer = Color(0xFFDCFCE7);
  static const Color onSuccess = Color(0xFFFFFFFF);
  static const Color onSuccessContainer = Color(0xFF14532D);

  static const Color successContainerDark = Color(0xFF14532D);
  static const Color onSuccessContainerDark = Color(0xFF86EFAC);

  static const Color warning = Color(0xFFD97706);
  static const Color warningContainer = Color(0xFFFEF3C7);
  static const Color onWarning = Color(0xFFFFFFFF);
  static const Color onWarningContainer = Color(0xFF78350F);

  static const Color warningContainerDark = Color(0xFF78350F);
  static const Color onWarningContainerDark = Color(0xFFFDE68A);

  static const Color error = Color(0xFFDC2626);
  static const Color errorContainer = Color(0xFFFEE2E2);
  static const Color onError = Color(0xFFFFFFFF);
  static const Color onErrorContainer = Color(0xFF7F1D1D);

  static const Color errorContainerDark = Color(0xFF7F1D1D);
  static const Color onErrorContainerDark = Color(0xFFFECACA);

  static const Color info = Color(0xFF2563EB);
  static const Color infoContainer = Color(0xFFDBEAFE);

  // Shadow / Overlay
  static const Color shadow = Color(0x0A0F172A);
  static const Color shadowDark = Color(0x33000000);
}
