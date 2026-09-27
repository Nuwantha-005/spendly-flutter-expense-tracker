import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/primary_button.dart';
import '../../../core/widgets/spendly_app_bar.dart';
import '../domain/expense.dart';
import 'providers/expense_providers.dart';
import 'widgets/category_selector.dart';

/// Screen for creating or editing an expense record with full dark/light theme support.
class AddExpenseScreen extends ConsumerStatefulWidget {
  const AddExpenseScreen({
    super.key,
    this.expense,
  });

  /// Existing expense to edit, or null when creating a new expense.
  final Expense? expense;

  @override
  ConsumerState<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends ConsumerState<AddExpenseScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _titleController;
  late final TextEditingController _amountController;
  late final TextEditingController _noteController;

  late String _selectedCategory;
  late DateTime _selectedDate;

  bool get _isEditing => widget.expense != null;

  @override
  void initState() {
    super.initState();
    final expense = widget.expense;
    _titleController = TextEditingController(text: expense?.title ?? '');
    _amountController = TextEditingController(
      text: expense != null ? expense.amount.toStringAsFixed(2) : '',
    );
    _noteController = TextEditingController(text: expense?.note ?? '');
    _selectedCategory = expense?.category ?? 'Food';
    _selectedDate = expense?.date ?? DateTime.now();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  String? _validateTitle(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Title is required';
    }
    return null;
  }

  String? _validateAmount(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Amount is required';
    }
    final parsed = double.tryParse(value.trim());
    if (parsed == null || parsed <= 0) {
      return 'Please enter a valid positive amount';
    }
    return null;
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _handleSubmit() async {
    ref.read(expenseControllerProvider.notifier).clearError();

    if (!_formKey.currentState!.validate()) {
      return;
    }

    FocusScope.of(context).unfocus();

    final parsedAmount = double.parse(_amountController.text.trim());
    final title = _titleController.text.trim();
    final note = _noteController.text.trim();

    bool success;
    if (_isEditing) {
      final updated = widget.expense!.copyWith(
        title: title,
        amount: parsedAmount,
        category: _selectedCategory,
        date: _selectedDate,
        note: note.isNotEmpty ? note : null,
      );
      success = await ref
          .read(expenseControllerProvider.notifier)
          .updateExpense(updated);
    } else {
      final newExpense = Expense(
        id: '',
        title: title,
        amount: parsedAmount,
        category: _selectedCategory,
        date: _selectedDate,
        note: note.isNotEmpty ? note : null,
        createdAt: DateTime.now(),
      );
      success = await ref
          .read(expenseControllerProvider.notifier)
          .addExpense(newExpense);
    }

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _isEditing
                ? 'Expense updated successfully.'
                : 'Expense added successfully.',
          ),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
        ),
      );
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final expenseState = ref.watch(expenseControllerProvider);
    final isLoading = expenseState.isLoading;

    ref.listen<AsyncValue<void>>(expenseControllerProvider, (_, next) {
      if (next.hasError && !next.isLoading) {
        final errorMsg = next.error.toString();
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(
                  Icons.error_outline_rounded,
                  color: AppColors.onError,
                  size: AppDimensions.iconSm,
                ),
                const SizedBox(width: AppDimensions.spacingSm),
                Expanded(
                  child: Text(
                    errorMsg,
                    style: const TextStyle(color: AppColors.onError),
                  ),
                ),
              ],
            ),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    });

    return Scaffold(
      appBar: SpendlyAppBar(
        title: _isEditing ? 'Edit Expense' : 'Add Expense',
        automaticallyImplyLeading: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.spacingMd,
            vertical: AppDimensions.spacingMd,
          ),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Error Banner (if any)
                if (expenseState.hasError && !isLoading) ...[
                  AppCard(
                    backgroundColor: theme.brightness == Brightness.dark
                        ? AppColors.errorContainerDark
                        : AppColors.errorContainer,
                    borderColor: AppColors.error.withValues(alpha: 0.4),
                    padding: const EdgeInsets.all(AppDimensions.spacingMd),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.error_outline_rounded,
                          color: AppColors.error,
                          size: AppDimensions.iconMd,
                        ),
                        const SizedBox(width: AppDimensions.spacingSm),
                        Expanded(
                          child: Text(
                            expenseState.error.toString(),
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.brightness == Brightness.dark
                                  ? AppColors.onErrorContainerDark
                                  : AppColors.onErrorContainer,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppDimensions.spacingLg),
                ],

                // Amount Field
                Text(
                  'Amount',
                  style: theme.textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: AppDimensions.spacingXs),
                TextFormField(
                  controller: _amountController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  textInputAction: TextInputAction.next,
                  enabled: !isLoading,
                  validator: _validateAmount,
                  style: theme.textTheme.headlineMedium?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w700,
                  ),
                  decoration: InputDecoration(
                    hintText: '0.00',
                    prefixText: 'Rs. ',
                    prefixStyle: theme.textTheme.headlineMedium?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(height: AppDimensions.spacingLg),

                // Title Field
                Text(
                  'Title',
                  style: theme.textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: AppDimensions.spacingXs),
                TextFormField(
                  controller: _titleController,
                  textCapitalization: TextCapitalization.sentences,
                  textInputAction: TextInputAction.next,
                  enabled: !isLoading,
                  validator: _validateTitle,
                  decoration: const InputDecoration(
                    hintText: 'e.g. Grocery shopping',
                    prefixIcon: Icon(
                      Icons.edit_note_rounded,
                      size: AppDimensions.iconSm,
                    ),
                  ),
                ),
                const SizedBox(height: AppDimensions.spacingLg),

                // Category Selector
                Text(
                  'Category',
                  style: theme.textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: AppDimensions.spacingXs),
                CategorySelector(
                  selectedCategory: _selectedCategory,
                  onCategorySelected: (category) {
                    setState(() {
                      _selectedCategory = category;
                    });
                  },
                ),
                const SizedBox(height: AppDimensions.spacingLg),

                // Date Picker Tile
                Text(
                  'Date',
                  style: theme.textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: AppDimensions.spacingXs),
                InkWell(
                  onTap: isLoading ? null : _selectDate,
                  borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                  child: AppCard(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppDimensions.spacingMd,
                      vertical: AppDimensions.spacingMd,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.calendar_today_rounded,
                              size: AppDimensions.iconSm,
                              color: theme.colorScheme.primary,
                            ),
                            const SizedBox(width: AppDimensions.spacingMd),
                            Text(
                              DateFormatter.formatDate(_selectedDate),
                              style: theme.textTheme.titleMedium,
                            ),
                          ],
                        ),
                        Icon(
                          Icons.arrow_drop_down_rounded,
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: AppDimensions.spacingLg),

                // Optional Note Field
                Text(
                  'Note (Optional)',
                  style: theme.textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: AppDimensions.spacingXs),
                TextFormField(
                  controller: _noteController,
                  maxLines: 3,
                  textCapitalization: TextCapitalization.sentences,
                  enabled: !isLoading,
                  decoration: const InputDecoration(
                    hintText: 'Add additional details or notes...',
                  ),
                ),
                const SizedBox(height: AppDimensions.spacingXl),

                // Save / Update Button
                PrimaryButton(
                  label: _isEditing ? 'Update Expense' : 'Save Expense',
                  isLoading: isLoading,
                  onPressed: isLoading ? null : _handleSubmit,
                ),
                const SizedBox(height: AppDimensions.spacingLg),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
