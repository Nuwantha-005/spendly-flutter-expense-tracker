import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../domain/category_spending.dart';
import '../../domain/expense.dart';
import '../../domain/expense_category.dart';
import '../../domain/expense_filter_state.dart';
import '../../domain/monthly_expense_summary.dart';
import '../../domain/monthly_trend_item.dart';
import '../../data/expense_service.dart';
import '../../data/firestore_exception_handler.dart';

/// Exposes the centralized ExpenseService instance.
final expenseServiceProvider = Provider<ExpenseService>((ref) {
  return ExpenseService();
});

/// Streams real-time expenses strictly for the currently authenticated user.
final expensesStreamProvider =
    StreamProvider.autoDispose<List<Expense>>((ref) {
  final user = ref.watch(currentUserProvider);
  if (user == null) {
    return Stream.value(<Expense>[]);
  }

  final expenseService = ref.watch(expenseServiceProvider);
  return expenseService.watchExpenses(user.uid);
});

/// Computes the MonthlyExpenseSummary for the active user's current month.
/// Automatically recalculates in real-time when an expense is added, edited, or deleted.
final currentMonthSummaryProvider =
    Provider.autoDispose<AsyncValue<MonthlyExpenseSummary>>((ref) {
  final expensesAsync = ref.watch(expensesStreamProvider);

  return expensesAsync.whenData((expenses) {
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
  });
});

/// Selects up to 5 most recent expenses from the real-time stream.
final recentExpensesProvider =
    Provider.autoDispose<AsyncValue<List<Expense>>>((ref) {
  final expensesAsync = ref.watch(expensesStreamProvider);

  return expensesAsync.whenData((expenses) {
    return expenses.take(AppConstants.maxRecentExpenses).toList();
  });
});

/// Computes the total numeric expenses for the current month.
final currentMonthTotalProvider = Provider.autoDispose<double>((ref) {
  final summaryAsync = ref.watch(currentMonthSummaryProvider);
  return summaryAsync.value?.totalAmount ?? 0.0;
});

/// Formats the current month total as currency string.
final currentMonthTotalFormattedProvider = Provider.autoDispose<String>((ref) {
  final summaryAsync = ref.watch(currentMonthSummaryProvider);
  return summaryAsync.value?.formattedTotal ??
      CurrencyFormatter.format(0.0);
});

/// Scope for category breakdown analytics.
enum AnalyticsScope {
  thisMonth('This Month'),
  allTime('All Time');

  const AnalyticsScope(this.label);
  final String label;
}

/// Provider for toggling the active analytics scope (defaults to thisMonth).
final analyticsScopeProvider =
    StateProvider.autoDispose<AnalyticsScope>((ref) => AnalyticsScope.thisMonth);

/// Calculates category spending distribution based on the active scope.
/// Sorted by totalAmount descending. Only includes categories with spending > 0.
final categorySpendingListProvider =
    Provider.autoDispose<AsyncValue<List<CategorySpending>>>((ref) {
  final expensesAsync = ref.watch(expensesStreamProvider);
  final scope = ref.watch(analyticsScopeProvider);

  return expensesAsync.whenData((expenses) {
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
  });
});

/// Computes monthly spending totals for the past 6 months to display in the trend bar chart.
final monthlySpendingTrendProvider =
    Provider.autoDispose<AsyncValue<List<MonthlyTrendItem>>>((ref) {
  final expensesAsync = ref.watch(expensesStreamProvider);

  return expensesAsync.whenData((expenses) {
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
  });
});

/// StateNotifier controlling active filter settings for the Expense History screen.
class ExpenseFilterNotifier extends StateNotifier<ExpenseFilterState> {
  ExpenseFilterNotifier() : super(const ExpenseFilterState());

  /// Updates text search query (case-insensitive title, category, note).
  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }

  /// Sets active category filter or 'All'.
  void setCategory(String category) {
    state = state.copyWith(category: category);
  }

  /// Sets active date filter option with optional custom date.
  void setDateFilter(DateFilterOption option, [DateTime? customDate]) {
    state = state.copyWith(
      dateFilter: option,
      customDate: customDate,
      clearCustomDate: customDate == null && option != DateFilterOption.custom,
    );
  }

  /// Clears only the search query.
  void clearSearch() {
    state = state.copyWith(searchQuery: '');
  }

  /// Resets category to 'All'.
  void clearCategory() {
    state = state.copyWith(category: 'All');
  }

  /// Resets date filter to 'All Dates'.
  void clearDateFilter() {
    state = state.copyWith(
      dateFilter: DateFilterOption.all,
      clearCustomDate: true,
    );
  }

  /// Resets all filters back to default.
  void clearAllFilters() {
    state = const ExpenseFilterState();
  }
}

/// Provider exposing the current filter state.
final expenseFilterProvider =
    StateNotifierProvider.autoDispose<ExpenseFilterNotifier, ExpenseFilterState>(
        (ref) {
  return ExpenseFilterNotifier();
});

/// Exposes the real-time filtered expenses, calculated in-memory from expensesStreamProvider.
/// Does NOT trigger any unnecessary Firestore queries when filters or search change.
final filteredExpensesProvider =
    Provider.autoDispose<AsyncValue<List<Expense>>>((ref) {
  final expensesAsync = ref.watch(expensesStreamProvider);
  final filterState = ref.watch(expenseFilterProvider);

  return expensesAsync.whenData((expenses) {
    return filterState.apply(expenses);
  });
});

/// StateNotifier controlling async expense operations (add, update, delete).
class ExpenseController extends StateNotifier<AsyncValue<void>> {
  ExpenseController(this._ref) : super(const AsyncData(null));

  final Ref _ref;

  ExpenseService get _service => _ref.read(expenseServiceProvider);

  String? get _currentUserId => _ref.read(currentUserProvider)?.uid;

  /// Adds a new expense under the active user's Firestore path.
  Future<bool> addExpense(Expense expense) async {
    final userId = _currentUserId;
    if (userId == null) {
      state = AsyncError('User is not authenticated.', StackTrace.current);
      return false;
    }

    state = const AsyncLoading();
    try {
      await _service.addExpense(userId: userId, expense: expense);
      state = const AsyncData(null);
      return true;
    } catch (e, st) {
      final message = FirestoreExceptionHandler.getErrorMessage(e);
      state = AsyncError(message, st);
      return false;
    }
  }

  /// Updates an existing expense in Firestore.
  Future<bool> updateExpense(Expense expense) async {
    final userId = _currentUserId;
    if (userId == null) {
      state = AsyncError('User is not authenticated.', StackTrace.current);
      return false;
    }

    state = const AsyncLoading();
    try {
      await _service.updateExpense(userId: userId, expense: expense);
      state = const AsyncData(null);
      return true;
    } catch (e, st) {
      final message = FirestoreExceptionHandler.getErrorMessage(e);
      state = AsyncError(message, st);
      return false;
    }
  }

  /// Deletes an expense from Firestore.
  Future<bool> deleteExpense(String expenseId) async {
    final userId = _currentUserId;
    if (userId == null) {
      state = AsyncError('User is not authenticated.', StackTrace.current);
      return false;
    }

    state = const AsyncLoading();
    try {
      await _service.deleteExpense(userId: userId, expenseId: expenseId);
      state = const AsyncData(null);
      return true;
    } catch (e, st) {
      final message = FirestoreExceptionHandler.getErrorMessage(e);
      state = AsyncError(message, st);
      return false;
    }
  }

  /// Clears any pending error state.
  void clearError() {
    state = const AsyncData(null);
  }
}

/// Provider exposing the ExpenseController.
final expenseControllerProvider =
    StateNotifierProvider<ExpenseController, AsyncValue<void>>((ref) {
  return ExpenseController(ref);
});
