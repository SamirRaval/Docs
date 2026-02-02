import '../entities/transaction_entity.dart';

/// Abstract repository interface for transaction operations
abstract class TransactionRepository {
  /// Get all transactions
  Future<List<TransactionEntity>> getAllTransactions();

  /// Get transaction by ID
  Future<TransactionEntity?> getTransactionById(String id);

  /// Get transactions by customer ID
  Future<List<TransactionEntity>> getTransactionsByCustomerId(String customerId);

  /// Get transactions by credit ID
  Future<List<TransactionEntity>> getTransactionsByCreditId(String creditId);

  /// Get transactions by type
  Future<List<TransactionEntity>> getTransactionsByType(String type);

  /// Get transactions by status
  Future<List<TransactionEntity>> getTransactionsByStatus(String status);

  /// Get transactions by date range
  Future<List<TransactionEntity>> getTransactionsByDateRange(
    DateTime startDate,
    DateTime endDate,
  );

  /// Create a new transaction
  Future<TransactionEntity> createTransaction(TransactionEntity transaction);

  /// Update an existing transaction
  Future<TransactionEntity> updateTransaction(TransactionEntity transaction);

  /// Delete a transaction
  Future<bool> deleteTransaction(String id);

  /// Get total transactions count
  Future<int> getTotalTransactionsCount();

  /// Get total credits amount (money in)
  Future<double> getTotalCreditsAmount();

  /// Get total debits amount (money out)
  Future<double> getTotalDebitsAmount();

  /// Get recent transactions
  Future<List<TransactionEntity>> getRecentTransactions({int limit = 10});

  /// Get transactions summary by type
  Future<Map<String, double>> getTransactionsSummaryByType();

  /// Get daily transaction totals for a period
  Future<Map<DateTime, double>> getDailyTransactionTotals(
    DateTime startDate,
    DateTime endDate,
  );

  /// Get monthly transaction totals
  Future<Map<String, double>> getMonthlyTransactionTotals(int year);

  /// Get unsynced transactions
  Future<List<TransactionEntity>> getUnsyncedTransactions();

  /// Mark transaction as synced
  Future<void> markTransactionAsSynced(String id);
}
