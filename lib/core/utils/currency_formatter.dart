import 'package:intl/intl.dart';
import '../constants/app_constants.dart';

/// Utility class for formatting currency amounts across Spendly.
class CurrencyFormatter {
  CurrencyFormatter._();

  /// Formats a numeric amount into a currency string (e.g. $1,234.50).
  static String format(
    double amount, {
    String symbol = AppConstants.defaultCurrencySymbol,
    int decimalDigits = 2,
    String locale = AppConstants.defaultLocale,
  }) {
    final format = NumberFormat.currency(
      locale: locale,
      symbol: symbol,
      decimalDigits: decimalDigits,
    );
    return format.format(amount);
  }

  /// Formats an expense outflow amount with negative prefix (e.g. -Rs. 1,500.00).
  static String formatExpense(
    double amount, {
    String symbol = AppConstants.defaultCurrencySymbol,
    int decimalDigits = 2,
    String locale = AppConstants.defaultLocale,
  }) {
    return '-${format(amount, symbol: symbol, decimalDigits: decimalDigits, locale: locale)}';
  }

  /// Formats large numbers compactly (e.g. $1.2K, $10.5M).
  static String formatCompact(
    double amount, {
    String symbol = AppConstants.defaultCurrencySymbol,
    String locale = AppConstants.defaultLocale,
  }) {
    final format = NumberFormat.compactCurrency(
      locale: locale,
      symbol: symbol,
    );
    return format.format(amount);
  }
}
