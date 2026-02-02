import 'package:intl/intl.dart';

/// Utility class for date and time operations
class DateTimeUtils {
  DateTimeUtils._();

  static final DateFormat _displayDateFormat = DateFormat('MMM dd, yyyy');
  static final DateFormat _displayDateTimeFormat = DateFormat('MMM dd, yyyy hh:mm a');
  static final DateFormat _apiDateFormat = DateFormat('yyyy-MM-dd');
  static final DateFormat _apiDateTimeFormat = DateFormat('yyyy-MM-dd HH:mm:ss');

  /// Format date for display
  static String formatDisplayDate(DateTime date) {
    return _displayDateFormat.format(date);
  }

  /// Format date and time for display
  static String formatDisplayDateTime(DateTime date) {
    return _displayDateTimeFormat.format(date);
  }

  /// Format date for API
  static String formatApiDate(DateTime date) {
    return _apiDateFormat.format(date);
  }

  /// Format date and time for API
  static String formatApiDateTime(DateTime date) {
    return _apiDateTimeFormat.format(date);
  }

  /// Parse date from API format
  static DateTime? parseApiDate(String? dateString) {
    if (dateString == null || dateString.isEmpty) return null;
    try {
      return _apiDateFormat.parse(dateString);
    } catch (e) {
      return null;
    }
  }

  /// Parse date and time from API format
  static DateTime? parseApiDateTime(String? dateString) {
    if (dateString == null || dateString.isEmpty) return null;
    try {
      return _apiDateTimeFormat.parse(dateString);
    } catch (e) {
      return null;
    }
  }

  /// Get relative time string (e.g., "2 hours ago")
  static String getRelativeTime(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 365) {
      final years = (difference.inDays / 365).floor();
      return '$years ${years == 1 ? 'year' : 'years'} ago';
    } else if (difference.inDays > 30) {
      final months = (difference.inDays / 30).floor();
      return '$months ${months == 1 ? 'month' : 'months'} ago';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} ${difference.inDays == 1 ? 'day' : 'days'} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} ${difference.inHours == 1 ? 'hour' : 'hours'} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} ${difference.inMinutes == 1 ? 'minute' : 'minutes'} ago';
    } else {
      return 'Just now';
    }
  }

  /// Check if date is today
  static bool isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year && date.month == now.month && date.day == now.day;
  }

  /// Check if date is overdue
  static bool isOverdue(DateTime dueDate) {
    return DateTime.now().isAfter(dueDate);
  }

  /// Get days until due date
  static int daysUntilDue(DateTime dueDate) {
    return dueDate.difference(DateTime.now()).inDays;
  }

  /// Get start of day
  static DateTime startOfDay(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  /// Get end of day
  static DateTime endOfDay(DateTime date) {
    return DateTime(date.year, date.month, date.day, 23, 59, 59);
  }

  /// Get start of month
  static DateTime startOfMonth(DateTime date) {
    return DateTime(date.year, date.month, 1);
  }

  /// Get end of month
  static DateTime endOfMonth(DateTime date) {
    return DateTime(date.year, date.month + 1, 0, 23, 59, 59);
  }
}
