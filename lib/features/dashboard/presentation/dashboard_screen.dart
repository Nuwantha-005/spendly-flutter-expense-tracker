import 'package:firebase_auth/firebase_auth.dart' show User;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/loading_indicator.dart';
import '../../../core/widgets/primary_button.dart';
import '../../../core/widgets/section_title.dart';
import '../../auth/presentation/providers/auth_providers.dart';
import '../../expenses/domain/expense.dart';
import '../../expenses/domain/monthly_expense_summary.dart';
import '../../expenses/presentation/add_expense_screen.dart';
import '../../expenses/presentation/providers/expense_providers.dart';
import '../../expenses/presentation/widgets/expense_list_tile.dart';
import 'widgets/category_breakdown_tile.dart';
import 'widgets/category_pie_chart.dart';
import 'widgets/monthly_trend_bar_chart.dart';

/// Dashboard screen with real-time spending summaries, analytics, and recent expenses.
/// Fully polished for Light and Dark themes.
class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({
    super.key,
    this.onNavigateToExpenses,
  });

  /// Optional callback to switch to the full expenses tab.
  final VoidCallback? onNavigateToExpenses;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final user = ref.watch(currentUserProvider);
    final summaryAsync = ref.watch(currentMonthSummaryProvider);
    final expensesAsync = ref.watch(expensesStreamProvider);
    final recentExpensesAsync = ref.watch(recentExpensesProvider);
    final categoryAsync = ref.watch(categorySpendingListProvider);
    final trendAsync = ref.watch(monthlySpendingTrendProvider);
    final analyticsScope = ref.watch(analyticsScopeProvider);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.spacingMd,
            vertical: AppDimensions.spacingSm,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Greeting Header
              _buildHeader(context, user),
              const SizedBox(height: AppDimensions.spacingLg),

              // 2. Current Month Spending Overview Card
              summaryAsync.when(
                data: (summary) => _buildMonthSummaryCard(
                  context: context,
                  summary: summary,
                ),
                loading: () => _buildMonthSummaryLoading(),
                error: (_, _) => _buildErrorCard(ref),
              ),
              const SizedBox(height: AppDimensions.spacingXl),

              // 3. Monthly Trend Bar Chart Section
              const SectionTitle(title: 'Spending Trend'),
              const SizedBox(height: AppDimensions.spacingSm),
              AppCard(
                padding: const EdgeInsets.all(AppDimensions.spacingMd),
                child: trendAsync.when(
                  data: (items) {
                    final hasData = items.any((m) => m.totalAmount > 0);
                    if (!hasData) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: AppDimensions.spacingLg),
                        child: Center(
                          child: Text(
                            'No spending data yet',
                            style: theme.textTheme.bodyMedium,
                          ),
                        ),
                      );
                    }
                    return MonthlyTrendBarChart(items: items);
                  },
                  loading: () => const Padding(
                    padding:
                        EdgeInsets.symmetric(vertical: AppDimensions.spacingLg),
                    child: LoadingIndicator(message: 'Loading trend...'),
                  ),
                  error: (_, _) => const SizedBox.shrink(),
                ),
              ),
              const SizedBox(height: AppDimensions.spacingXl),

              // 4. Category Spending Analytics Section (Header with Title & Scope Toggle)
              Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: AppDimensions.spacingSm,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Spending by Category',
                      style: theme.textTheme.titleMedium,
                    ),
                    Row(
                      children: [
                        for (final scope in AnalyticsScope.values)
                          Padding(
                            padding: const EdgeInsets.only(
                                left: AppDimensions.spacingXs),
                            child: GestureDetector(
                              onTap: () => ref
                                  .read(analyticsScopeProvider.notifier)
                                  .state = scope,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: AppDimensions.spacingSm,
                                  vertical: AppDimensions.spacingXs,
                                ),
                                decoration: BoxDecoration(
                                  color: analyticsScope == scope
                                      ? theme.colorScheme.primary
                                      : theme.colorScheme.surfaceContainerHighest,
                                  borderRadius: BorderRadius.circular(
                                      AppDimensions.radiusFull),
                                ),
                                child: Text(
                                  scope.label,
                                  style: AppTextStyles.labelSmall.copyWith(
                                    color: analyticsScope == scope
                                        ? theme.colorScheme.onPrimary
                                        : theme.colorScheme.onSurface.withValues(alpha: 0.7),
                                    fontWeight: analyticsScope == scope
                                        ? FontWeight.w700
                                        : FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppDimensions.spacingSm),

              // Category Analytics Card
              AppCard(
                padding: const EdgeInsets.all(AppDimensions.spacingMd),
                child: categoryAsync.when(
                  data: (categories) {
                    if (categories.isEmpty) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: AppDimensions.spacingXl),
                        child: Column(
                          children: [
                            Container(
                              width: 64,
                              height: 64,
                              decoration: BoxDecoration(
                                color: theme.colorScheme.primaryContainer,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.pie_chart_outline_rounded,
                                size: AppDimensions.iconLg,
                                color: theme.colorScheme.primary,
                              ),
                            ),
                            const SizedBox(height: AppDimensions.spacingMd),
                            Text(
                              'No spending data yet',
                              style: theme.textTheme.titleMedium,
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: AppDimensions.spacingXs),
                            Text(
                              'Add expenses to see your spending insights.',
                              style: theme.textTheme.bodyMedium,
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      );
                    }

                    // Compute total for center label
                    final total = categories.fold<double>(
                        0.0, (sum, c) => sum + c.totalAmount);
                    final totalLabel =
                        '${categories.length} ${categories.length == 1 ? 'category' : 'categories'}';

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Donut Chart
                        CategoryPieChart(
                          items: categories,
                          centerText: totalLabel,
                        ),
                        const Divider(
                            height: AppDimensions.spacingLg,
                            thickness: 1),

                        // Total row
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Total',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            Text(
                              CurrencyFormatter.format(total),
                              style: theme.textTheme.titleMedium?.copyWith(
                                color: theme.colorScheme.primary,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppDimensions.spacingSm),

                        // Per-category breakdown rows
                        for (final cat in categories) ...[
                          const Divider(height: AppDimensions.spacingMd),
                          CategoryBreakdownTile(item: cat),
                        ],
                      ],
                    );
                  },
                  loading: () => const Padding(
                    padding:
                        EdgeInsets.symmetric(vertical: AppDimensions.spacingXl),
                    child: LoadingIndicator(message: 'Loading analytics...'),
                  ),
                  error: (_, _) => const SizedBox.shrink(),
                ),
              ),
              const SizedBox(height: AppDimensions.spacingXl),

              // 5. Recent Expenses Section
              SectionTitle(
                title: 'Recent Expenses',
                actionText: (expensesAsync.value?.isNotEmpty ?? false)
                    ? 'View All'
                    : null,
                onActionTap: onNavigateToExpenses,
              ),
              const SizedBox(height: AppDimensions.spacingSm),

              // Recent Expenses List / Empty State / Loading
              recentExpensesAsync.when(
                data: (recentExpenses) {
                  final allExpenses = expensesAsync.value ?? [];
                  if (allExpenses.isEmpty) {
                    return AppCard(
                      padding: const EdgeInsets.symmetric(
                        vertical: AppDimensions.spacingXl,
                        horizontal: AppDimensions.spacingMd,
                      ),
                      child: Column(
                        children: [
                          Container(
                            width: 64,
                            height: 64,
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primaryContainer,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.account_balance_wallet_outlined,
                              size: AppDimensions.iconLg,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                          const SizedBox(height: AppDimensions.spacingMd),
                          Text(
                            'No expenses yet',
                            style: theme.textTheme.titleMedium,
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: AppDimensions.spacingXs),
                          Text(
                            'Start tracking your spending by adding your first expense.',
                            style: theme.textTheme.bodyMedium,
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: AppDimensions.spacingLg),
                          PrimaryButton(
                            label: 'Add Expense',
                            isFullWidth: false,
                            height: AppDimensions.buttonSmallHeight,
                            onPressed: () => _openAddExpense(context),
                          ),
                        ],
                      ),
                    );
                  }

                  return Column(
                    children: [
                      for (int i = 0; i < recentExpenses.length; i++) ...[
                        if (i > 0)
                          const SizedBox(height: AppDimensions.spacingSm),
                        ExpenseListTile(
                          expense: recentExpenses[i],
                          onTap: () =>
                              _openEditExpense(context, recentExpenses[i]),
                          onDelete: () =>
                              _confirmDelete(context, ref, recentExpenses[i]),
                        ),
                      ],
                    ],
                  );
                },
                loading: () => const AppCard(
                  padding:
                      EdgeInsets.symmetric(vertical: AppDimensions.spacingXl),
                  child:
                      LoadingIndicator(message: 'Loading recent expenses...'),
                ),
                error: (_, _) => _buildErrorCard(ref),
              ),
              const SizedBox(height: AppDimensions.spacingXxl),
            ],
          ),
        ),
      ),
    );
  }

  /// Calculates time-based greeting.
  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  Widget _buildHeader(BuildContext context, User? user) {
    final theme = Theme.of(context);
    final displayName = user?.displayName?.trim();
    final hasName = displayName != null && displayName.isNotEmpty;
    final greeting = _getGreeting();

    final initial = hasName
        ? displayName[0].toUpperCase()
        : (user?.email?.isNotEmpty ?? false)
            ? user!.email![0].toUpperCase()
            : 'S';

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                hasName ? '$greeting, $displayName' : greeting,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: AppDimensions.spacingXs),
              Text(
                'Track your spending smartly',
                style: theme.textTheme.bodySmall,
              ),
            ],
          ),
        ),
        const SizedBox(width: AppDimensions.spacingSm),
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: theme.colorScheme.primaryContainer,
            shape: BoxShape.circle,
            border: Border.all(color: theme.colorScheme.outline),
          ),
          child: Center(
            child: Text(
              initial,
              style: AppTextStyles.titleMedium.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMonthSummaryCard({
    required BuildContext context,
    required MonthlyExpenseSummary summary,
  }) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: theme.brightness == Brightness.dark
              ? [const Color(0xFF0F766E), const Color(0xFF042F2E)]
              : [AppColors.primary, AppColors.primaryDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.25),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      padding: const EdgeInsets.all(AppDimensions.spacingLg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.calendar_month_rounded,
                      size: AppDimensions.iconSm, color: Colors.white),
                  const SizedBox(width: AppDimensions.spacingXs),
                  Text(
                    summary.monthDisplay,
                    style: AppTextStyles.labelLarge.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.spacingSm,
                  vertical: AppDimensions.spacingXs,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.18),
                  borderRadius:
                      BorderRadius.circular(AppDimensions.radiusFull),
                ),
                child: Text(
                  'Current Month',
                  style: AppTextStyles.labelSmall.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.spacingMd),
          Text(
            'Total Spending',
            style: AppTextStyles.bodyMedium.copyWith(
              color: Colors.white.withValues(alpha: 0.85),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: AppDimensions.spacingXs),
          Text(
            summary.formattedTotal,
            style: AppTextStyles.currencyLarge.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: AppDimensions.spacingSm),
          Row(
            children: [
              Icon(Icons.receipt_long_rounded,
                  size: AppDimensions.iconSm,
                  color: Colors.white.withValues(alpha: 0.85)),
              const SizedBox(width: AppDimensions.spacingXs),
              Text(
                summary.formattedCount,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: Colors.white.withValues(alpha: 0.9),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.spacingLg),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _openAddExpense(context),
              icon: const Icon(Icons.add_rounded,
                  color: AppColors.primary, size: AppDimensions.iconMd),
              label: Text(
                'Add Expense',
                style: AppTextStyles.labelLarge.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: AppColors.primary,
                elevation: 0,
                padding:
                    const EdgeInsets.symmetric(vertical: AppDimensions.spacingMd),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMonthSummaryLoading() {
    return const AppCard(
      padding: EdgeInsets.symmetric(vertical: AppDimensions.spacingXl),
      child: LoadingIndicator(message: 'Loading spending summary...'),
    );
  }

  Widget _buildErrorCard(WidgetRef ref) {
    return AppCard(
      backgroundColor: AppColors.errorContainer.withValues(alpha: 0.4),
      borderColor: AppColors.error.withValues(alpha: 0.25),
      padding: const EdgeInsets.all(AppDimensions.spacingLg),
      child: Column(
        children: [
          const Icon(Icons.cloud_off_rounded,
              color: AppColors.error, size: AppDimensions.iconLg),
          const SizedBox(height: AppDimensions.spacingSm),
          const Text('Unable to load your expenses.',
              style: AppTextStyles.titleMedium, textAlign: TextAlign.center),
          const SizedBox(height: AppDimensions.spacingXs),
          Text(
            'Please check your network connection and try again.',
            style: AppTextStyles.bodySmall
                .copyWith(color: AppColors.textSecondary),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppDimensions.spacingMd),
          PrimaryButton(
            label: 'Retry',
            isFullWidth: false,
            onPressed: () => ref.invalidate(expensesStreamProvider),
          ),
        ],
      ),
    );
  }

  void _openAddExpense(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => const AddExpenseScreen()),
    );
  }

  void _openEditExpense(BuildContext context, Expense expense) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
          builder: (_) => AddExpenseScreen(expense: expense)),
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref, Expense expense) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Delete Expense'),
          content: Text('Are you sure you want to delete "${expense.title}"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              style:
                  TextButton.styleFrom(foregroundColor: AppColors.error),
              onPressed: () async {
                Navigator.of(dialogContext).pop();
                final success = await ref
                    .read(expenseControllerProvider.notifier)
                    .deleteExpense(expense.id);
                if (success && context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Expense deleted successfully.'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }
}
