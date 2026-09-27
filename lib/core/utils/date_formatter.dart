import 'package:intl/intl.dart';

/// Utility class for formatting dates and times across Spendly.
class DateFormatter {
  DateFormatter._();

  /// Formats date to standard readable format: "Sep 27, 2026".
  static String formatDate(DateTime date) {
    return DateFormat('MMM d, y').format(date);
  }

  /// Formats date to month and year: "September 2026".
  static String formatMonthYear(DateTime date) {
    return DateFormat('MMMM y').format(date);
  }

  /// Formats date to short format: "27 Sep".
  static String formatShortDate(DateTime date) {
    return DateFormat('d MMM').format(date);
  }

  /// Formats time to 12-hour clock: "04:30 PM".
  static String formatTime(DateTime date) {
    return DateFormat('hh:mm a').format(date);
  }

  /// Formats date to a user-friendly relative label ("Today", "Yesterday", or "MMM d").
  static String formatRelative(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final targetDate = DateTime(date.year, date.month, date.day);

    final difference = today.difference(targetDate).inDays;
    if (difference == 0) {
      return 'Today';
    } else if (difference == 1) {
      return 'Yesterday';
    } else {
      return formatDate(date);
    }
  }
}
