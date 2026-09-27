import 'package:flutter/material.dart';
import '../constants/app_dimensions.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

/// Reusable primary CTA button for Spendly.
class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.icon,
    this.isFullWidth = true,
    this.backgroundColor,
    this.textColor,
    this.height = AppDimensions.buttonHeight,
    this.borderRadius = AppDimensions.radiusMd,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final IconData? icon;
  final bool isFullWidth;
  final Color? backgroundColor;
  final Color? textColor;
  final double height;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    final effectiveBgColor = backgroundColor ?? AppColors.primary;
    final effectiveTextColor = textColor ?? AppColors.onPrimary;

    Widget child;
    if (isLoading) {
      child = SizedBox(
        height: 22,
        width: 22,
        child: CircularProgressIndicator(
          strokeWidth: 2.5,
          valueColor: AlwaysStoppedAnimation<Color>(effectiveTextColor),
        ),
      );
    } else if (icon != null) {
      child = Row(
        mainAxisSize: isFullWidth ? MainAxisSize.max : MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: AppDimensions.iconSm,
            color: effectiveTextColor,
          ),
          const SizedBox(width: AppDimensions.spacingSm),
          Text(
            label,
            style: AppTextStyles.labelLarge.copyWith(color: effectiveTextColor),
          ),
        ],
      );
    } else {
      child = Text(
        label,
        style: AppTextStyles.labelLarge.copyWith(color: effectiveTextColor),
      );
    }

    return SizedBox(
      width: isFullWidth ? double.infinity : null,
      height: height,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: effectiveBgColor,
          foregroundColor: effectiveTextColor,
          disabledBackgroundColor: effectiveBgColor.withValues(alpha: 0.5),
          disabledForegroundColor: effectiveTextColor.withValues(alpha: 0.7),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.spacingLg,
          ),
        ),
        child: child,
      ),
    );
  }
}
