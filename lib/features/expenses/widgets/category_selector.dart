import 'package:flutter/material.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/widgets/app_card.dart';
import '../models/expense_category.dart';

/// Interactive selector for choosing an expense category with dark/light mode support.
class CategorySelector extends StatelessWidget {
  const CategorySelector({
    super.key,
    required this.selectedCategory,
    required this.onCategorySelected,
  });

  final String selectedCategory;
  final ValueChanged<String> onCategorySelected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final current = ExpenseCategory.fromName(selectedCategory);

    return InkWell(
      onTap: () => _showCategoryPicker(context),
      borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
      child: AppCard(
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.spacingMd,
          vertical: AppDimensions.spacingSm,
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(AppDimensions.spacingSm),
              decoration: BoxDecoration(
                color: current.color.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(
                current.icon,
                color: current.color,
                size: AppDimensions.iconSm,
              ),
            ),
            const SizedBox(width: AppDimensions.spacingMd),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Category',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    current.name,
                    style: theme.textTheme.titleMedium,
                  ),
                ],
              ),
            ),
            Icon(
              Icons.keyboard_arrow_down_rounded,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              size: AppDimensions.iconMd,
            ),
          ],
        ),
      ),
    );
  }

  void _showCategoryPicker(BuildContext context) {
    final theme = Theme.of(context);

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: theme.cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppDimensions.radiusXl),
        ),
      ),
      builder: (bottomSheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.spacingMd,
              vertical: AppDimensions.spacingLg,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.outline,
                      borderRadius:
                          BorderRadius.circular(AppDimensions.radiusFull),
                    ),
                  ),
                ),
                const SizedBox(height: AppDimensions.spacingMd),
                Text(
                  'Select Category',
                  style: theme.textTheme.headlineSmall,
                ),
                const SizedBox(height: AppDimensions.spacingMd),
                Flexible(
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: ExpenseCategory.categories.length,
                    separatorBuilder: (_, _) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final cat = ExpenseCategory.categories[index];
                      final isSelected = cat.name.toLowerCase() ==
                          selectedCategory.trim().toLowerCase();

                      return ListTile(
                        onTap: () {
                          onCategorySelected(cat.name);
                          Navigator.of(bottomSheetContext).pop();
                        },
                        leading: Container(
                          padding: const EdgeInsets.all(AppDimensions.spacingSm),
                          decoration: BoxDecoration(
                            color: cat.color.withValues(alpha: 0.15),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            cat.icon,
                            color: cat.color,
                            size: AppDimensions.iconSm,
                          ),
                        ),
                        title: Text(
                          cat.name,
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: isSelected
                                ? theme.colorScheme.primary
                                : theme.colorScheme.onSurface,
                            fontWeight: isSelected
                                ? FontWeight.w700
                                : FontWeight.w500,
                          ),
                        ),
                        trailing: isSelected
                            ? Icon(
                                Icons.check_circle_rounded,
                                color: theme.colorScheme.primary,
                                size: AppDimensions.iconSm,
                              )
                            : null,
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
