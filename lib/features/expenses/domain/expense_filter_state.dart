import 'package:flutter/foundation.dart';
import '../../../../core/utils/date_formatter.dart';
import 'expense.dart';

/// Predefined date filtering presets.
enum DateFilterOption {
  all('All Dates'),
  today('Today'),
  thisWeek('This Week'),
  thisMonth('This Month'),
  custom('Custom Date');

  const DateFilterOption(this.label);
  final String label;
}

/// Immutable state encapsulating search query, category, and date filter settings.
@immutable
class ExpenseFilterState {
  const ExpenseFilterState({
    this.searchQuery = '',
    this.category = 'All',
    this.dateFilter = DateFilterOption.all,
    this.customDate,
  });

  /// Text search query matching title, category, or note.
  final String searchQuery;

  /// Selected category name or 'All'.
  final String category;

  /// Selected date range option.
  final DateFilterOption dateFilter;

  /// Specific date chosen when dateFilter == DateFilterOption.custom.
  final DateTime? customDate;

  bool get isSearchActive => searchQuery.trim().isNotEmpty;
  bool get isCategoryActive => category != 'All';
  bool get isDateActive => dateFilter != DateFilterOption.all;
  bool get hasActiveFilters =>
      isSearchActive || isCategoryActive || isDateActive;

  /// Friendly display label for the date filter.
  String get dateFilterLabel {
    if (dateFilter == DateFilterOption.custom && customDate != null) {
      return DateFormatter.formatShortDate(customDate!);
    }
    return dateFilter.label;
  }

  ExpenseFilterState copyWith({
    String? searchQuery,
    String? category,
    DateFilterOption? dateFilter,
    DateTime? customDate,
    bool clearCustomDate = false,
  }) {
    return ExpenseFilterState(
      searchQuery: searchQuery ?? this.searchQuery,
      category: category ?? this.category,
      dateFilter: dateFilter ?? this.dateFilter,
      customDate: clearCustomDate ? null : (customDate ?? this.customDate),
    );
  }

  ExpenseFilterState reset() => const ExpenseFilterState();

  /// Applies search, category, and date filtering in memory to a list of expenses.
  List<Expense> apply(List<Expense> expenses) {
    if (!hasActiveFilters) {
      return expenses;
    }

    final query = searchQuery.trim().toLowerCase();
    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);
    // Start of the current week (Monday)
    final weekStart = todayStart.subtract(Duration(days: now.weekday - 1));
    final weekEnd = weekStart.add(const Duration(days: 7));

    return expenses.where((expense) {
      // 1. Search Query Filter (Title, Category, or Note)
      if (query.isNotEmpty) {
        final titleMatch = expense.title.toLowerCase().contains(query);
        final categoryMatch = expense.category.toLowerCase().contains(query);
        final noteMatch = expense.note?.toLowerCase().contains(query) ?? false;

        if (!titleMatch && !categoryMatch && !noteMatch) {
          return false;
        }
      }

      // 2. Category Filter
      if (category != 'All') {
        if (expense.category.trim().toLowerCase() !=
            category.trim().toLowerCase()) {
          return false;
        }
      }

      // 3. Date Filter (using expense.date)
      final expDate =
          DateTime(expense.date.year, expense.date.month, expense.date.day);

      switch (dateFilter) {
        case DateFilterOption.all:
          break;

        case DateFilterOption.today:
          if (expDate != todayStart) {
            return false;
          }
          break;

        case DateFilterOption.thisWeek:
          if (expDate.isBefore(weekStart) || !expDate.isBefore(weekEnd)) {
            return false;
          }
          break;

        case DateFilterOption.thisMonth:
          if (expense.date.year != now.year || expense.date.month != now.month) {
            return false;
          }
          break;

        case DateFilterOption.custom:
          if (customDate != null) {
            final target = DateTime(
              customDate!.year,
              customDate!.month,
              customDate!.day,
            );
            if (expDate != target) {
              return false;
            }
          }
          break;
      }

      return true;
    }).toList();
  }
}
