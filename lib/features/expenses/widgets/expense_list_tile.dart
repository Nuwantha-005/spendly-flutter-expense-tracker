import 'package:flutter/material.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../core/widgets/app_card.dart';
import '../models/expense.dart';
import '../models/expense_category.dart';

/// Clean card displaying an individual expense in lists with theme awareness.
class ExpenseListTile extends StatelessWidget {
  const ExpenseListTile({
    super.key,
    required this.expense,
    required this.onTap,
    required this.onDelete,
  });

  final Expense expense;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final category = ExpenseCategory.fromName(expense.category);

    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.spacingMd,
        vertical: AppDimensions.spacingMd,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Category Icon
          Container(
            padding: const EdgeInsets.all(AppDimensions.spacingSm),
            decoration: BoxDecoration(
              color: category.color.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(
              category.icon,
              color: category.color,
              size: AppDimensions.iconMd,
            ),
          ),
          const SizedBox(width: AppDimensions.spacingMd),

          // Title, Category, and Date
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  expense.title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: AppDimensions.spacingXs),
                Row(
                  children: [
                    Text(
                      category.name,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: category.color,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: AppDimensions.spacingSm),
                    Text('•', style: theme.textTheme.bodySmall),
                    const SizedBox(width: AppDimensions.spacingSm),
                    Text(
                      DateFormatter.formatRelative(expense.date),
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ),
                if (expense.note != null && expense.note!.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    expense.note!,
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontStyle: FontStyle.italic,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: AppDimensions.spacingSm),

          // Amount and Options Menu
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                CurrencyFormatter.formatExpense(expense.amount),
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: AppDimensions.spacingXs),
              PopupMenuButton<String>(
                padding: EdgeInsets.zero,
                iconSize: 18,
                icon: Icon(
                  Icons.more_horiz_rounded,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                ),
                onSelected: (value) {
                  if (value == 'edit') {
                    onTap();
                  } else if (value == 'delete') {
                    onDelete();
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        Icon(Icons.edit_outlined, size: 18),
                        SizedBox(width: 8),
                        Text('Edit'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete_outline_rounded,
                            size: 18, color: AppColors.error),
                        SizedBox(width: 8),
                        Text('Delete',
                            style: TextStyle(color: AppColors.error)),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
