import '../../../core/utils/currency_formatter.dart';

/// Immutable model representing aggregate spending for a single calendar month in trend views.
class MonthlyTrendItem {
  const MonthlyTrendItem({
    required this.year,
    required this.month,
    required this.monthLabel,
    required this.totalAmount,
    required this.isCurrentMonth,
  });

  /// The year of the month (e.g. 2026).
  final int year;

  /// The month (1-12).
  final int month;

  /// Short localized month label (e.g. "Apr", "May", "Sep").
  final String monthLabel;

  /// Sum of all expenses in this month.
  final double totalAmount;

  /// Whether this item corresponds to the current calendar month.
  final bool isCurrentMonth;

  /// Formatted currency string (e.g. "Rs. 45,250.00").
  String get formattedTotal => CurrencyFormatter.format(totalAmount);
}
