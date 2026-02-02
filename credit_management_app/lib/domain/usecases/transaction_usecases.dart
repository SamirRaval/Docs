import '../entities/transaction_entity.dart';
import '../repositories/transaction_repository.dart';

/// Use cases for transaction operations
class TransactionUseCases {
  final TransactionRepository _repository;

  TransactionUseCases(this._repository);

  /// Get all transactions
  Future<List<TransactionEntity>> getAllTransactions() {
    return _repository.getAllTransactions();
  }

  /// Get transaction by ID
  Future<TransactionEntity?> getTransactionById(String id) {
    return _repository.getTransactionById(id);
  }

  /// Get transactions by customer ID
  Future<List<TransactionEntity>> getTransactionsByCustomerId(String customerId) {
    return _repository.getTransactionsByCustomerId(customerId);
  }

  /// Get transactions by credit ID
  Future<List<TransactionEntity>> getTransactionsByCreditId(String creditId) {
    return _repository.getTransactionsByCreditId(creditId);
  }

  /// Get transactions by type
  Future<List<TransactionEntity>> getTransactionsByType(String type) {
    return _repository.getTransactionsByType(type);
  }

  /// Get transactions by date range
  Future<List<TransactionEntity>> getTransactionsByDateRange(
    DateTime startDate,
    DateTime endDate,
  ) {
    return _repository.getTransactionsByDateRange(startDate, endDate);
  }

  /// Create a new transaction
  Future<TransactionEntity> createTransaction({
    required String customerId,
    String? creditId,
    String? customerName,
    required double amount,
    required String type,
    String? description,
    String? referenceNumber,
    String paymentMethod = 'cash',
    DateTime? transactionDate,
  }) {
    final now = DateTime.now();
    
    final transaction = TransactionEntity(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      customerId: customerId,
      creditId: creditId,
      customerName: customerName,
      amount: amount,
      type: type,
      status: 'completed',
      description: description,
      referenceNumber: referenceNumber ?? _generateReferenceNumber(),
      paymentMethod: paymentMethod,
      transactionDate: transactionDate ?? now,
      createdAt: now,
      updatedAt: now,
      isSynced: false,
    );
    return _repository.createTransaction(transaction);
  }

  /// Update transaction status
  Future<TransactionEntity> updateTransactionStatus(
    String transactionId,
    String status,
  ) async {
    final transaction = await _repository.getTransactionById(transactionId);
    if (transaction == null) throw Exception('Transaction not found');

    final updatedTransaction = transaction.copyWith(
      status: status,
      updatedAt: DateTime.now(),
      isSynced: false,
    );
    return _repository.updateTransaction(updatedTransaction);
  }

  /// Cancel a transaction
  Future<TransactionEntity> cancelTransaction(String transactionId) {
    return updateTransactionStatus(transactionId, 'cancelled');
  }

  /// Delete a transaction
  Future<bool> deleteTransaction(String id) {
    return _repository.deleteTransaction(id);
  }

  /// Get dashboard statistics
  Future<Map<String, dynamic>> getDashboardStats() async {
    final totalCount = await _repository.getTotalTransactionsCount();
    final totalCredits = await _repository.getTotalCreditsAmount();
    final totalDebits = await _repository.getTotalDebitsAmount();
    final recentTransactions = await _repository.getRecentTransactions();
    final summaryByType = await _repository.getTransactionsSummaryByType();

    return {
      'totalTransactions': totalCount,
      'totalCredits': totalCredits,
      'totalDebits': totalDebits,
      'netAmount': totalCredits - totalDebits,
      'recentTransactions': recentTransactions,
      'summaryByType': summaryByType,
    };
  }

  /// Get recent transactions
  Future<List<TransactionEntity>> getRecentTransactions({int limit = 10}) {
    return _repository.getRecentTransactions(limit: limit);
  }

  /// Get transactions summary by type
  Future<Map<String, double>> getTransactionsSummaryByType() {
    return _repository.getTransactionsSummaryByType();
  }

  /// Get daily transaction totals
  Future<Map<DateTime, double>> getDailyTransactionTotals(
    DateTime startDate,
    DateTime endDate,
  ) {
    return _repository.getDailyTransactionTotals(startDate, endDate);
  }

  /// Get monthly transaction totals
  Future<Map<String, double>> getMonthlyTransactionTotals(int year) {
    return _repository.getMonthlyTransactionTotals(year);
  }

  /// Get unsynced transactions for sync
  Future<List<TransactionEntity>> getUnsyncedTransactions() {
    return _repository.getUnsyncedTransactions();
  }

  /// Mark transaction as synced
  Future<void> markTransactionAsSynced(String id) {
    return _repository.markTransactionAsSynced(id);
  }

  /// Generate a unique reference number
  String _generateReferenceNumber() {
    final now = DateTime.now();
    return 'TXN${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}${now.millisecondsSinceEpoch.toString().substring(8)}';
  }
}
