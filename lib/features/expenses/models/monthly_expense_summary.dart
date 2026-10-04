import '../../../core/utils/currency_formatter.dart';

/// Immutable domain model representing aggregate monthly spending summary.
class MonthlyExpenseSummary {
  const MonthlyExpenseSummary({
    required this.year,
    required this.month,
    required this.monthDisplay,
    required this.totalAmount,
    required this.expenseCount,
  });

  /// The year of this summary (e.g. 2026).
  final int year;

  /// The month of this summary (1-12).
  final int month;

  /// Localized month & year display string (e.g. "September 2026").
  final String monthDisplay;

  /// Sum of all expenses belonging strictly to this month and year.
  final double totalAmount;

  /// Number of expense entries recorded for this month.
  final int expenseCount;

  /// Formatted currency string for total amount (e.g. "Rs. 45,250.00").
  String get formattedTotal => CurrencyFormatter.format(totalAmount);

  /// User-friendly label for expense count (e.g. "12 expenses", "1 expense", "0 expenses").
  String get formattedCount =>
      expenseCount == 1 ? '1 expense' : '$expenseCount expenses';

  /// Whether there are any expenses in this month.
  bool get hasExpenses => expenseCount > 0;
}
