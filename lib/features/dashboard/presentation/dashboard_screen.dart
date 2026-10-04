import 'package:firebase_auth/firebase_auth.dart' show User;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/loading_indicator.dart';
import '../../../core/widgets/primary_button.dart';
import '../../../core/widgets/section_title.dart';
import '../../auth/data/auth_service.dart';
import '../../expenses/data/expense_service.dart';
import '../../expenses/data/firestore_exception_handler.dart';
import '../../expenses/domain/category_spending.dart';
import '../../expenses/domain/expense.dart';
import '../../expenses/domain/expense_category.dart';
import '../../expenses/domain/monthly_expense_summary.dart';
import '../../expenses/domain/monthly_trend_item.dart';
import '../../expenses/presentation/add_expense_screen.dart';
import '../../expenses/presentation/widgets/expense_list_tile.dart';
import 'widgets/category_breakdown_tile.dart';
import 'widgets/category_pie_chart.dart';
import 'widgets/monthly_trend_bar_chart.dart';

/// Scope for category breakdown analytics on the dashboard.
enum AnalyticsScope {
  thisMonth('This Month'),
  allTime('All Time');

  const AnalyticsScope(this.label);
  final String label;
}

/// Dashboard screen with real-time spending summaries, analytics, and recent expenses.
/// Fully polished for Light and Dark themes.
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({
    super.key,
    this.onNavigateToExpenses,
  });

  /// Optional callback to switch to the full expenses tab.
  final VoidCallback? onNavigateToExpenses;

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final _expenseService = ExpenseService();
  final _authService = AuthService();

  AnalyticsScope _analyticsScope = AnalyticsScope.thisMonth;
  Key _streamKey = UniqueKey();

  void _retry() {
    setState(() {
      _streamKey = UniqueKey();
    });
  }

  /// Computes monthly expense summary for the current month.
  MonthlyExpenseSummary _calculateCurrentMonthSummary(List<Expense> expenses) {
    final now = DateTime.now();
    double total = 0.0;
    int count = 0;

    for (final expense in expenses) {
      if (expense.date.year == now.year && expense.date.month == now.month) {
        total += expense.amount;
        count++;
      }
    }

    return MonthlyExpenseSummary(
      year: now.year,
      month: now.month,
      monthDisplay: DateFormatter.formatMonthYear(now),
      totalAmount: total,
      expenseCount: count,
    );
  }

  /// Calculates category spending distribution based on the active scope.
  List<CategorySpending> _calculateCategorySpending(
    List<Expense> expenses,
    AnalyticsScope scope,
  ) {
    final now = DateTime.now();
    final List<Expense> targetExpenses;

    if (scope == AnalyticsScope.thisMonth) {
      targetExpenses = expenses
          .where((e) => e.date.year == now.year && e.date.month == now.month)
          .toList();
    } else {
      targetExpenses = expenses;
    }

    if (targetExpenses.isEmpty) {
      return <CategorySpending>[];
    }

    final double totalSpent = targetExpenses.fold(
      0.0,
      (sum, e) => sum + e.amount,
    );

    final Map<String, double> categoryTotals = {};
    final Map<String, int> categoryCounts = {};

    for (final expense in targetExpenses) {
      final cat = expense.category.trim();
      categoryTotals[cat] = (categoryTotals[cat] ?? 0.0) + expense.amount;
      categoryCounts[cat] = (categoryCounts[cat] ?? 0) + 1;
    }

    final List<CategorySpending> results = [];
    categoryTotals.forEach((catName, amount) {
      if (amount > 0) {
        final catObj = ExpenseCategory.fromName(catName);
        final pct = totalSpent > 0 ? (amount / totalSpent) * 100 : 0.0;
        results.add(
          CategorySpending(
            categoryName: catObj.name,
            totalAmount: amount,
            percentage: pct,
            transactionCount: categoryCounts[catName] ?? 1,
            icon: catObj.icon,
            color: catObj.color,
          ),
        );
      }
    });

    results.sort((a, b) => b.totalAmount.compareTo(a.totalAmount));
    return results;
  }

  /// Computes monthly spending totals for the past 6 months for the trend chart.
  List<MonthlyTrendItem> _calculateMonthlyTrend(List<Expense> expenses) {
    final now = DateTime.now();
    final List<MonthlyTrendItem> trend = [];

    // Calculate last 6 months in chronological order
    for (int i = 5; i >= 0; i--) {
      final targetDate = DateTime(now.year, now.month - i, 1);
      final year = targetDate.year;
      final month = targetDate.month;
      final monthLabel = DateFormat('MMM').format(targetDate);
      final isCurrent = (year == now.year && month == now.month);

      double monthlySum = 0.0;
      for (final expense in expenses) {
        if (expense.date.year == year && expense.date.month == month) {
          monthlySum += expense.amount;
        }
      }

      trend.add(
        MonthlyTrendItem(
          year: year,
          month: month,
          monthLabel: monthLabel,
          totalAmount: monthlySum,
          isCurrentMonth: isCurrent,
        ),
      );
    }

    return trend;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final user = _authService.currentUser;
    final userId = user?.uid ?? '';

    return Scaffold(
      body: SafeArea(
        child: StreamBuilder<List<Expense>>(
          key: _streamKey,
          stream: userId.isNotEmpty
              ? _expenseService.watchExpenses(userId)
              : Stream.value(<Expense>[]),
          builder: (context, snapshot) {
            final isLoading =
                snapshot.connectionState == ConnectionState.waiting;
            final hasError = snapshot.hasError;
            final expenses = snapshot.data ?? [];

            final summary = _calculateCurrentMonthSummary(expenses);
            final trendItems = _calculateMonthlyTrend(expenses);
            final categoryItems =
                _calculateCategorySpending(expenses, _analyticsScope);
            final recentExpenses =
                expenses.take(AppConstants.maxRecentExpenses).toList();

            return SingleChildScrollView(
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
                  if (isLoading)
                    _buildMonthSummaryLoading()
                  else if (hasError)
                    _buildErrorCard()
                  else
                    _buildMonthSummaryCard(
                      context: context,
                      summary: summary,
                    ),
                  const SizedBox(height: AppDimensions.spacingXl),

                  // 3. Monthly Trend Bar Chart Section
                  const SectionTitle(title: 'Spending Trend'),
                  const SizedBox(height: AppDimensions.spacingSm),
                  AppCard(
                    padding: const EdgeInsets.all(AppDimensions.spacingMd),
                    child: isLoading
                        ? const Padding(
                            padding: EdgeInsets.symmetric(
                                vertical: AppDimensions.spacingLg),
                            child: LoadingIndicator(message: 'Loading trend...'),
                          )
                        : hasError
                            ? const SizedBox.shrink()
                            : !trendItems.any((m) => m.totalAmount > 0)
                                ? Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: AppDimensions.spacingLg),
                                    child: Center(
                                      child: Text(
                                        'No spending data yet',
                                        style: theme.textTheme.bodyMedium,
                                      ),
                                    ),
                                  )
                                : MonthlyTrendBarChart(items: trendItems),
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
                                  onTap: () {
                                    setState(() {
                                      _analyticsScope = scope;
                                    });
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: AppDimensions.spacingSm,
                                      vertical: AppDimensions.spacingXs,
                                    ),
                                    decoration: BoxDecoration(
                                      color: _analyticsScope == scope
                                          ? theme.colorScheme.primary
                                          : theme.colorScheme
                                              .surfaceContainerHighest,
                                      borderRadius: BorderRadius.circular(
                                          AppDimensions.radiusFull),
                                    ),
                                    child: Text(
                                      scope.label,
                                      style: AppTextStyles.labelSmall.copyWith(
                                        color: _analyticsScope == scope
                                            ? theme.colorScheme.onPrimary
                                            : theme.colorScheme.onSurface
                                                .withValues(alpha: 0.7),
                                        fontWeight: _analyticsScope == scope
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
                    child: isLoading
                        ? const Padding(
                            padding: EdgeInsets.symmetric(
                                vertical: AppDimensions.spacingXl),
                            child:
                                LoadingIndicator(message: 'Loading analytics...'),
                          )
                        : hasError
                            ? const SizedBox.shrink()
                            : categoryItems.isEmpty
                                ? Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: AppDimensions.spacingXl),
                                    child: Column(
                                      children: [
                                        Container(
                                          width: 64,
                                          height: 64,
                                          decoration: BoxDecoration(
                                            color: theme
                                                .colorScheme.primaryContainer,
                                            shape: BoxShape.circle,
                                          ),
                                          child: Icon(
                                            Icons.pie_chart_outline_rounded,
                                            size: AppDimensions.iconLg,
                                            color: theme.colorScheme.primary,
                                          ),
                                        ),
                                        const SizedBox(
                                            height: AppDimensions.spacingMd),
                                        Text(
                                          'No spending data yet',
                                          style: theme.textTheme.titleMedium,
                                          textAlign: TextAlign.center,
                                        ),
                                        const SizedBox(
                                            height: AppDimensions.spacingXs),
                                        Text(
                                          'Add expenses to see your spending insights.',
                                          style: theme.textTheme.bodyMedium,
                                          textAlign: TextAlign.center,
                                        ),
                                      ],
                                    ),
                                  )
                                : Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: [
                                      // Donut Chart
                                      CategoryPieChart(
                                        items: categoryItems,
                                        centerText:
                                            '${categoryItems.length} ${categoryItems.length == 1 ? 'category' : 'categories'}',
                                      ),
                                      const Divider(
                                          height: AppDimensions.spacingLg,
                                          thickness: 1),

                                      // Total row
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            'Total',
                                            style: theme.textTheme.titleMedium
                                                ?.copyWith(
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                          Text(
                                            CurrencyFormatter.format(
                                                categoryItems.fold<double>(
                                                    0.0,
                                                    (sum, c) =>
                                                        sum + c.totalAmount)),
                                            style: theme.textTheme.titleMedium
                                                ?.copyWith(
                                              color:
                                                  theme.colorScheme.primary,
                                              fontWeight: FontWeight.w800,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(
                                          height: AppDimensions.spacingSm),

                                      // Per-category breakdown rows
                                      for (final cat in categoryItems) ...[
                                        const Divider(
                                            height: AppDimensions.spacingMd),
                                        CategoryBreakdownTile(item: cat),
                                      ],
                                    ],
                                  ),
                  ),
                  const SizedBox(height: AppDimensions.spacingXl),

                  // 5. Recent Expenses Section
                  SectionTitle(
                    title: 'Recent Expenses',
                    actionText:
                        expenses.isNotEmpty ? 'View All' : null,
                    onActionTap: widget.onNavigateToExpenses,
                  ),
                  const SizedBox(height: AppDimensions.spacingSm),

                  // Recent Expenses List / Empty State / Loading
                  if (isLoading)
                    const AppCard(
                      padding: EdgeInsets.symmetric(
                          vertical: AppDimensions.spacingXl),
                      child: LoadingIndicator(
                          message: 'Loading recent expenses...'),
                    )
                  else if (hasError)
                    _buildErrorCard()
                  else if (expenses.isEmpty)
                    AppCard(
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
                    )
                  else
                    Column(
                      children: [
                        for (int i = 0; i < recentExpenses.length; i++) ...[
                          if (i > 0)
                            const SizedBox(height: AppDimensions.spacingSm),
                          ExpenseListTile(
                            expense: recentExpenses[i],
                            onTap: () => _openEditExpense(
                                context, recentExpenses[i]),
                            onDelete: () => _confirmDelete(
                                context, recentExpenses[i]),
                          ),
                        ],
                      ],
                    ),
                  const SizedBox(height: AppDimensions.spacingXxl),
                ],
              ),
            );
          },
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

  Widget _buildErrorCard() {
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
            onPressed: _retry,
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

  void _confirmDelete(BuildContext context, Expense expense) {
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
                final userId = _authService.currentUser?.uid;
                if (userId != null) {
                  try {
                    await _expenseService.deleteExpense(
                      userId: userId,
                      expenseId: expense.id,
                    );
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Expense deleted successfully.'),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    }
                  } catch (e) {
                    if (context.mounted) {
                      final message =
                          FirestoreExceptionHandler.getErrorMessage(e);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(message),
                          backgroundColor: AppColors.error,
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    }
                  }
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
