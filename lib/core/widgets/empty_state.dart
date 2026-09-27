import 'package:flutter/material.dart';
import '../constants/app_dimensions.dart';
import 'primary_button.dart';

/// Reusable empty state component indicating missing or unpopulated data.
/// Automatically adapts to light and dark themes.
class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.title,
    required this.message,
    this.icon = Icons.receipt_long_outlined,
    this.actionText,
    this.onAction,
  });

  final String title;
  final String message;
  final IconData icon;
  final String? actionText;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.spacingXl,
          vertical: AppDimensions.spacingXl,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: AppDimensions.iconLg,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: AppDimensions.spacingLg),
            Text(
              title,
              textAlign: TextAlign.center,
              style: theme.textTheme.headlineSmall,
            ),
            const SizedBox(height: AppDimensions.spacingSm),
            Text(
              message,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium,
            ),
            if (actionText != null && onAction != null) ...[
              const SizedBox(height: AppDimensions.spacingLg),
              PrimaryButton(
                label: actionText!,
                onPressed: onAction,
                isFullWidth: false,
                height: AppDimensions.buttonSmallHeight,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
