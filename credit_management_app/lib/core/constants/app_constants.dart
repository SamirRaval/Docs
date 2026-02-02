/// Application-wide constants for the Credit Management System

class AppConstants {
  AppConstants._();

  // App Info
  static const String appName = 'Credit Management System';
  static const String appVersion = '1.0.0';

  // Database
  static const String databaseName = 'credit_management.db';
  static const int databaseVersion = 1;

  // Hive Box Names
  static const String customersBox = 'customers';
  static const String creditsBox = 'credits';
  static const String transactionsBox = 'transactions';
  static const String syncQueueBox = 'sync_queue';
  static const String settingsBox = 'settings';
  static const String userBox = 'user';

  // API Endpoints (for future use)
  static const String baseUrl = 'https://api.creditmanagement.com';
  static const String loginEndpoint = '/auth/login';
  static const String customersEndpoint = '/customers';
  static const String creditsEndpoint = '/credits';
  static const String transactionsEndpoint = '/transactions';
  static const String syncEndpoint = '/sync';

  // Sync Settings
  static const int syncIntervalMinutes = 5;
  static const int maxRetryAttempts = 3;

  // Pagination
  static const int defaultPageSize = 20;

  // Credit Limits
  static const double defaultCreditLimit = 10000.0;
  static const double maxCreditLimit = 1000000.0;

  // Date Formats
  static const String displayDateFormat = 'MMM dd, yyyy';
  static const String apiDateFormat = 'yyyy-MM-dd';
  static const String displayDateTimeFormat = 'MMM dd, yyyy hh:mm a';

  // Status Codes
  static const String statusPending = 'pending';
  static const String statusApproved = 'approved';
  static const String statusRejected = 'rejected';
  static const String statusActive = 'active';
  static const String statusClosed = 'closed';
  static const String statusOverdue = 'overdue';

  // Transaction Types
  static const String transactionTypeCredit = 'credit';
  static const String transactionTypeDebit = 'debit';
  static const String transactionTypePayment = 'payment';
  static const String transactionTypeRefund = 'refund';

  // Risk Levels
  static const String riskLow = 'low';
  static const String riskMedium = 'medium';
  static const String riskHigh = 'high';
}
