import 'package:flutter/material.dart';
import '../../../core/utils/currency_formatter.dart';

/// Immutable model representing spending aggregation for a single category.
class CategorySpending {
  const CategorySpending({
    required this.categoryName,
    required this.totalAmount,
    required this.percentage,
    required this.transactionCount,
    required this.icon,
    required this.color,
  });

  /// The name of the category (e.g. "Food").
  final String categoryName;

  /// Total amount spent in this category.
  final double totalAmount;

  /// Percentage of total spending (e.g. 25.5 for 25.5%).
  final double percentage;

  /// Total number of expense transactions in this category.
  final int transactionCount;

  /// Associated Material icon.
  final IconData icon;

  /// Associated category color.
  final Color color;

  /// Formatted currency string (e.g. "Rs. 12,500.00").
  String get formattedTotal => CurrencyFormatter.format(totalAmount);

  /// Formatted percentage string (e.g. "25.5%").
  String get formattedPercentage => '${percentage.toStringAsFixed(1)}%';
}
