import 'package:flutter/material.dart';
import '../../core/constants/app_dimensions.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/widgets/loading_indicator.dart';
import '../../core/widgets/primary_button.dart';
import '../../core/widgets/spendly_app_bar.dart';
import '../auth/auth_service.dart';
import 'expense_service.dart';
import 'firestore_exception_handler.dart';
import 'models/expense.dart';
import 'models/expense_category.dart';
import 'models/expense_filter_state.dart';
import 'add_expense_screen.dart';
import 'widgets/expense_list_tile.dart';

/// Screen listing all authenticated user's expenses with real-time updates,
/// multi-criteria search (title, category, note), and combined category/date filters.
/// Fully theme-adaptive for dark and light modes.
class ExpensesScreen extends StatefulWidget {
  const ExpensesScreen({super.key});

  @override
  State<ExpensesScreen> createState() => _ExpensesScreenState();
}

class _ExpensesScreenState extends State<ExpensesScreen> {
  final _searchController = TextEditingController();
  final _expenseService = ExpenseService();
  final _authService = AuthService();

  ExpenseFilterState _filterState = const ExpenseFilterState();
  Key _streamKey = UniqueKey();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _retry() {
    setState(() {
      _streamKey = UniqueKey();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final userId = _authService.currentUser?.uid ?? '';

    return Scaffold(
      appBar: SpendlyAppBar(
        title: 'Expenses',
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: Icon(Icons.add_rounded, color: theme.colorScheme.primary),
            onPressed: () => _openAddExpense(context),
            tooltip: 'Add Expense',
          ),
        ],
      ),
      body: SafeArea(
        child: StreamBuilder<List<Expense>>(
          key: _streamKey,
          stream: userId.isNotEmpty
              ? _expenseService.watchExpenses(userId)
              : Stream.value(<Expense>[]),
          builder: (context, snapshot) {
            final allExpenses = snapshot.data ?? [];
            final filtered = _filterState.apply(allExpenses);

            return Column(
              children: [
                // 1. Search Bar & Filter Controls Header
                Container(
                  color: theme.scaffoldBackgroundColor,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppDimensions.spacingMd,
                    vertical: AppDimensions.spacingSm,
                  ),
                  child: Column(
                    children: [
                      _buildSearchBar(context),
                      const SizedBox(height: AppDimensions.spacingSm),
                      _buildFilterButtons(context),
                      if (_filterState.hasActiveFilters) ...[
                        const SizedBox(height: AppDimensions.spacingSm),
                        _buildActiveFilterChips(
                          context,
                          filtered.length,
                        ),
                      ],
                    ],
                  ),
                ),
                const Divider(height: 1),

                // 2. Main Expenses Content Area
                Expanded(
                  child: Builder(
                    builder: (context) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                          child:
                              LoadingIndicator(message: 'Loading expenses...'),
                        );
                      }

                      if (snapshot.hasError) {
                        return Center(
                          child: Padding(
                            padding:
                                const EdgeInsets.all(AppDimensions.spacingXl),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.cloud_off_rounded,
                                  color: AppColors.error,
                                  size: AppDimensions.iconXl,
                                ),
                                const SizedBox(height: AppDimensions.spacingMd),
                                Text(
                                  'Unable to load your expenses.',
                                  style: theme.textTheme.headlineSmall,
                                ),
                                const SizedBox(height: AppDimensions.spacingSm),
                                Text(
                                  'Please check your network connection and try again.',
                                  textAlign: TextAlign.center,
                                  style: theme.textTheme.bodyMedium,
                                ),
                                const SizedBox(height: AppDimensions.spacingLg),
                                PrimaryButton(
                                  label: 'Retry',
                                  isFullWidth: false,
                                  onPressed: _retry,
                                ),
                              ],
                            ),
                          ),
                        );
                      }

                      // If user has zero expenses overall in their account
                      if (allExpenses.isEmpty) {
                        return EmptyState(
                          icon: Icons.account_balance_wallet_outlined,
                          title: 'No expenses yet',
                          message:
                              'Start tracking your spending by adding your first expense.',
                          actionText: 'Add Expense',
                          onAction: () => _openAddExpense(context),
                        );
                      }

                      // If filters produced zero matching results
                      if (filtered.isEmpty) {
                        return EmptyState(
                          icon: Icons.search_off_rounded,
                          title: 'No matching expenses',
                          message: 'Try changing your search or filters.',
                          actionText: 'Clear Filters',
                          onAction: () {
                            _searchController.clear();
                            setState(() {
                              _filterState = const ExpenseFilterState();
                            });
                          },
                        );
                      }

                      return ListView.separated(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppDimensions.spacingMd,
                          vertical: AppDimensions.spacingSm,
                        ),
                        itemCount: filtered.length,
                        separatorBuilder: (_, _) =>
                            const SizedBox(height: AppDimensions.spacingSm),
                        itemBuilder: (context, index) {
                          final expense = filtered[index];
                          return ExpenseListTile(
                            expense: expense,
                            onTap: () => _openEditExpense(context, expense),
                            onDelete: () => _confirmDelete(context, expense),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  /// Builds the text search field with theme adaptation.
  Widget _buildSearchBar(BuildContext context) {
    final theme = Theme.of(context);

    return TextField(
      controller: _searchController,
      onChanged: (value) {
        setState(() {
          _filterState = _filterState.copyWith(searchQuery: value);
        });
      },
      style: theme.textTheme.bodyMedium?.copyWith(
        color: theme.colorScheme.onSurface,
      ),
      decoration: InputDecoration(
        hintText: 'Search expenses...',
        prefixIcon: Icon(
          Icons.search_rounded,
          color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
          size: AppDimensions.iconSm,
        ),
        suffixIcon: _filterState.isSearchActive
            ? IconButton(
                icon: Icon(
                  Icons.close_rounded,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  size: AppDimensions.iconSm,
                ),
                onPressed: () {
                  _searchController.clear();
                  setState(() {
                    _filterState = _filterState.copyWith(searchQuery: '');
                  });
                },
                tooltip: 'Clear search',
              )
            : null,
        filled: true,
        fillColor: theme.cardColor,
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.spacingMd,
          vertical: AppDimensions.spacingSm,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
          borderSide: BorderSide(color: theme.colorScheme.outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
          borderSide: BorderSide(color: theme.colorScheme.primary, width: 1.5),
        ),
      ),
    );
  }

  /// Builds the Category and Date filter selector buttons.
  Widget _buildFilterButtons(BuildContext context) {
    final theme = Theme.of(context);
    final isCatActive = _filterState.isCategoryActive;
    final isDateActive = _filterState.isDateActive;

    return Row(
      children: [
        // Category Filter Selector
        Expanded(
          child: OutlinedButton(
            onPressed: () => _showCategoryFilterSheet(context),
            style: OutlinedButton.styleFrom(
              backgroundColor: isCatActive
                  ? theme.colorScheme.primaryContainer
                  : theme.cardColor,
              side: BorderSide(
                color: isCatActive
                    ? theme.colorScheme.primary
                    : theme.colorScheme.outline,
                width: isCatActive ? 1.5 : 1.0,
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.spacingSm,
                vertical: AppDimensions.spacingSm,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Icon(
                        Icons.category_outlined,
                        size: AppDimensions.iconSm,
                        color: isCatActive
                            ? theme.colorScheme.primary
                            : theme.colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                      const SizedBox(width: AppDimensions.spacingXs),
                      Expanded(
                        child: Text(
                          isCatActive ? _filterState.category : 'Category',
                          style: theme.textTheme.labelMedium?.copyWith(
                            color: isCatActive
                                ? theme.colorScheme.primary
                                : theme.colorScheme.onSurface,
                            fontWeight: isCatActive
                                ? FontWeight.w700
                                : FontWeight.w500,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_drop_down_rounded,
                  color: isCatActive
                      ? theme.colorScheme.primary
                      : theme.colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: AppDimensions.spacingSm),

        // Date Filter Selector
        Expanded(
          child: OutlinedButton(
            onPressed: () => _showDateFilterSheet(context),
            style: OutlinedButton.styleFrom(
              backgroundColor: isDateActive
                  ? theme.colorScheme.primaryContainer
                  : theme.cardColor,
              side: BorderSide(
                color: isDateActive
                    ? theme.colorScheme.primary
                    : theme.colorScheme.outline,
                width: isDateActive ? 1.5 : 1.0,
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.spacingSm,
                vertical: AppDimensions.spacingSm,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Icon(
                        Icons.calendar_today_outlined,
                        size: AppDimensions.iconSm,
                        color: isDateActive
                            ? theme.colorScheme.primary
                            : theme.colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                      const SizedBox(width: AppDimensions.spacingXs),
                      Expanded(
                        child: Text(
                          isDateActive ? _filterState.dateFilterLabel : 'Date',
                          style: theme.textTheme.labelMedium?.copyWith(
                            color: isDateActive
                                ? theme.colorScheme.primary
                                : theme.colorScheme.onSurface,
                            fontWeight: isDateActive
                                ? FontWeight.w700
                                : FontWeight.w500,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_drop_down_rounded,
                  color: isDateActive
                      ? theme.colorScheme.primary
                      : theme.colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// Builds row showing active filter chips and clear all button.
  Widget _buildActiveFilterChips(
    BuildContext context,
    int matchCount,
  ) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '$matchCount ${matchCount == 1 ? 'expense' : 'expenses'} found',
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            InkWell(
              onTap: () {
                _searchController.clear();
                setState(() {
                  _filterState = const ExpenseFilterState();
                });
              },
              borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.spacingXs,
                  vertical: 2,
                ),
                child: Text(
                  'Clear Filters',
                  style: AppTextStyles.labelSmall.copyWith(
                    color: AppColors.error,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppDimensions.spacingXs),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              if (_filterState.isCategoryActive) ...[
                InputChip(
                  label: Text(_filterState.category),
                  onDeleted: () {
                    setState(() {
                      _filterState = _filterState.copyWith(category: 'All');
                    });
                  },
                  deleteIconColor: theme.colorScheme.primary,
                  backgroundColor: theme.colorScheme.primaryContainer,
                  labelStyle: AppTextStyles.labelSmall.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                  side: BorderSide(color: theme.colorScheme.primary, width: 0.5),
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(AppDimensions.radiusFull),
                  ),
                ),
                const SizedBox(width: AppDimensions.spacingXs),
              ],
              if (_filterState.isDateActive) ...[
                InputChip(
                  label: Text(_filterState.dateFilterLabel),
                  onDeleted: () {
                    setState(() {
                      _filterState = _filterState.copyWith(
                        dateFilter: DateFilterOption.all,
                        clearCustomDate: true,
                      );
                    });
                  },
                  deleteIconColor: theme.colorScheme.primary,
                  backgroundColor: theme.colorScheme.primaryContainer,
                  labelStyle: AppTextStyles.labelSmall.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                  side: BorderSide(color: theme.colorScheme.primary, width: 0.5),
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(AppDimensions.radiusFull),
                  ),
                ),
                const SizedBox(width: AppDimensions.spacingXs),
              ],
              if (_filterState.isSearchActive) ...[
                InputChip(
                  label: Text('"${_filterState.searchQuery}"'),
                  onDeleted: () {
                    _searchController.clear();
                    setState(() {
                      _filterState = _filterState.copyWith(searchQuery: '');
                    });
                  },
                  deleteIconColor: theme.colorScheme.primary,
                  backgroundColor: theme.colorScheme.primaryContainer,
                  labelStyle: AppTextStyles.labelSmall.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                  side: BorderSide(color: theme.colorScheme.primary, width: 0.5),
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(AppDimensions.radiusFull),
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  /// Displays category selection modal bottom sheet.
  void _showCategoryFilterSheet(BuildContext context) {
    final currentCategory = _filterState.category;
    final theme = Theme.of(context);

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: theme.cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppDimensions.radiusLg),
        ),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.spacingMd,
                  vertical: AppDimensions.spacingSm,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Filter by Category',
                      style: theme.textTheme.titleMedium,
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded),
                      onPressed: () => Navigator.of(sheetContext).pop(),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              Flexible(
                child: ListView(
                  shrinkWrap: true,
                  children: [
                    ListTile(
                      leading: Container(
                        padding: const EdgeInsets.all(AppDimensions.spacingSm),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primaryContainer,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.apps_rounded,
                          size: AppDimensions.iconSm,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                      title: const Text('All Categories'),
                      trailing: currentCategory == 'All'
                          ? Icon(Icons.check_circle_rounded,
                              color: theme.colorScheme.primary)
                          : null,
                      selected: currentCategory == 'All',
                      onTap: () {
                        setState(() {
                          _filterState = _filterState.copyWith(category: 'All');
                        });
                        Navigator.of(sheetContext).pop();
                      },
                    ),
                    for (final cat in ExpenseCategory.categories)
                      ListTile(
                        leading: Container(
                          padding:
                              const EdgeInsets.all(AppDimensions.spacingSm),
                          decoration: BoxDecoration(
                            color: cat.color.withValues(alpha: 0.15),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            cat.icon,
                            size: AppDimensions.iconSm,
                            color: cat.color,
                          ),
                        ),
                        title: Text(cat.name),
                        trailing: currentCategory.toLowerCase() ==
                                cat.name.toLowerCase()
                            ? Icon(Icons.check_circle_rounded,
                                color: theme.colorScheme.primary)
                            : null,
                        selected: currentCategory.toLowerCase() ==
                            cat.name.toLowerCase(),
                        onTap: () {
                          setState(() {
                            _filterState =
                                _filterState.copyWith(category: cat.name);
                          });
                          Navigator.of(sheetContext).pop();
                        },
                      ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// Displays date range selection modal bottom sheet.
  void _showDateFilterSheet(BuildContext context) {
    final theme = Theme.of(context);

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: theme.cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppDimensions.radiusLg),
        ),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.spacingMd,
                  vertical: AppDimensions.spacingSm,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Filter by Date',
                      style: theme.textTheme.titleMedium,
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded),
                      onPressed: () => Navigator.of(sheetContext).pop(),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              for (final option in DateFilterOption.values)
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(AppDimensions.spacingSm),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primaryContainer,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      option == DateFilterOption.custom
                          ? Icons.calendar_month_rounded
                          : Icons.calendar_today_rounded,
                      size: AppDimensions.iconSm,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  title: Text(
                    option == DateFilterOption.custom &&
                            _filterState.dateFilter == DateFilterOption.custom &&
                            _filterState.customDate != null
                        ? 'Custom: ${_filterState.dateFilterLabel}'
                        : option.label,
                  ),
                  trailing: _filterState.dateFilter == option
                      ? Icon(Icons.check_circle_rounded,
                          color: theme.colorScheme.primary)
                      : null,
                  selected: _filterState.dateFilter == option,
                  onTap: () async {
                    Navigator.of(sheetContext).pop();
                    if (option == DateFilterOption.custom) {
                      await _selectCustomDate(context);
                    } else {
                      setState(() {
                        _filterState = _filterState.copyWith(
                          dateFilter: option,
                          clearCustomDate: true,
                        );
                      });
                    }
                  },
                ),
            ],
          ),
        );
      },
    );
  }

  /// Opens date picker for custom date filter selection.
  Future<void> _selectCustomDate(BuildContext context) async {
    final current = _filterState.customDate ?? DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: current,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      helpText: 'Select Expense Date',
    );
    if (picked != null) {
      setState(() {
        _filterState = _filterState.copyWith(
          dateFilter: DateFilterOption.custom,
          customDate: picked,
        );
      });
    }
  }

  void _openAddExpense(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => const AddExpenseScreen(),
      ),
    );
  }

  void _openEditExpense(BuildContext context, Expense expense) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => AddExpenseScreen(expense: expense),
      ),
    );
  }

  void _confirmDelete(BuildContext context, Expense expense) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Delete Expense'),
          content: Text(
            'Are you sure you want to delete "${expense.title}"?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              style: TextButton.styleFrom(
                foregroundColor: AppColors.error,
              ),
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
