import 'package:intl/intl.dart';

/// Utility class for currency and number formatting
class CurrencyUtils {
  CurrencyUtils._();

  static final NumberFormat _currencyFormat = NumberFormat.currency(
    symbol: '\$',
    decimalDigits: 2,
  );

  static final NumberFormat _compactCurrencyFormat = NumberFormat.compactCurrency(
    symbol: '\$',
    decimalDigits: 1,
  );

  static final NumberFormat _percentFormat = NumberFormat.percentPattern();

  static final NumberFormat _numberFormat = NumberFormat.decimalPattern();

  /// Format amount as currency
  static String formatCurrency(double amount) {
    return _currencyFormat.format(amount);
  }

  /// Format amount as compact currency (e.g., \$1.5K)
  static String formatCompactCurrency(double amount) {
    return _compactCurrencyFormat.format(amount);
  }

  /// Format as percentage
  static String formatPercent(double value) {
    return _percentFormat.format(value);
  }

  /// Format number with commas
  static String formatNumber(num number) {
    return _numberFormat.format(number);
  }

  /// Parse currency string to double
  static double? parseCurrency(String? value) {
    if (value == null || value.isEmpty) return null;
    try {
      // Remove currency symbols and commas
      final cleanValue = value.replaceAll(RegExp(r'[^\d.-]'), '');
      return double.parse(cleanValue);
    } catch (e) {
      return null;
    }
  }

  /// Calculate percentage change
  static double calculatePercentageChange(double oldValue, double newValue) {
    if (oldValue == 0) return newValue > 0 ? 100.0 : 0.0;
    return ((newValue - oldValue) / oldValue) * 100;
  }

  /// Format credit score
  static String formatCreditScore(int score) {
    if (score >= 750) return '$score (Excellent)';
    if (score >= 700) return '$score (Good)';
    if (score >= 650) return '$score (Fair)';
    if (score >= 600) return '$score (Poor)';
    return '$score (Very Poor)';
  }

  /// Get credit score color based on value
  static String getCreditScoreRating(int score) {
    if (score >= 750) return 'Excellent';
    if (score >= 700) return 'Good';
    if (score >= 650) return 'Fair';
    if (score >= 600) return 'Poor';
    return 'Very Poor';
  }
}
