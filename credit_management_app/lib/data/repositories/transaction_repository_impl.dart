import '../../domain/entities/transaction_entity.dart';
import '../../domain/repositories/transaction_repository.dart';
import '../datasources/local/local_database_service.dart';
import '../models/transaction_model.dart';

/// Implementation of TransactionRepository using local database
class TransactionRepositoryImpl implements TransactionRepository {
  final LocalDatabaseService _localDatabase;

  TransactionRepositoryImpl(this._localDatabase);

  @override
  Future<List<TransactionEntity>> getAllTransactions() async {
    final models = await _localDatabase.getAllTransactions();
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<TransactionEntity?> getTransactionById(String id) async {
    final model = await _localDatabase.getTransactionById(id);
    return model?.toEntity();
  }

  @override
  Future<List<TransactionEntity>> getTransactionsByCustomerId(String customerId) async {
    final models = await _localDatabase.getTransactionsByCustomerId(customerId);
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<List<TransactionEntity>> getTransactionsByCreditId(String creditId) async {
    final models = await _localDatabase.getTransactionsByCreditId(creditId);
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<List<TransactionEntity>> getTransactionsByType(String type) async {
    final models = await _localDatabase.getTransactionsByType(type);
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<List<TransactionEntity>> getTransactionsByStatus(String status) async {
    final transactions = await getAllTransactions();
    return transactions.where((t) => t.status == status).toList();
  }

  @override
  Future<List<TransactionEntity>> getTransactionsByDateRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    final models = await _localDatabase.getTransactionsByDateRange(startDate, endDate);
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<TransactionEntity> createTransaction(TransactionEntity transaction) async {
    final model = TransactionModel.fromEntity(transaction);
    final savedModel = await _localDatabase.saveTransaction(model);
    
    // Add to sync queue
    await _localDatabase.addToSyncQueue(
      entityType: 'transaction',
      entityId: transaction.id,
      operation: 'create',
      data: model.toJson(),
    );
    
    return savedModel.toEntity();
  }

  @override
  Future<TransactionEntity> updateTransaction(TransactionEntity transaction) async {
    final model = TransactionModel.fromEntity(transaction);
    final savedModel = await _localDatabase.saveTransaction(model);
    
    // Add to sync queue
    await _localDatabase.addToSyncQueue(
      entityType: 'transaction',
      entityId: transaction.id,
      operation: 'update',
      data: model.toJson(),
    );
    
    return savedModel.toEntity();
  }

  @override
  Future<bool> deleteTransaction(String id) async {
    final result = await _localDatabase.deleteTransaction(id);
    
    if (result) {
      // Add to sync queue
      await _localDatabase.addToSyncQueue(
        entityType: 'transaction',
        entityId: id,
        operation: 'delete',
        data: {'id': id},
      );
    }
    
    return result;
  }

  @override
  Future<int> getTotalTransactionsCount() async {
    final transactions = await _localDatabase.getAllTransactions();
    return transactions.length;
  }

  @override
  Future<double> getTotalCreditsAmount() async {
    final transactions = await getAllTransactions();
    return transactions
        .where((t) => t.isCredit && t.isCompleted)
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  @override
  Future<double> getTotalDebitsAmount() async {
    final transactions = await getAllTransactions();
    return transactions
        .where((t) => t.isDebit && t.isCompleted)
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  @override
  Future<List<TransactionEntity>> getRecentTransactions({int limit = 10}) async {
    final transactions = await getAllTransactions();
    return transactions.take(limit).toList();
  }

  @override
  Future<Map<String, double>> getTransactionsSummaryByType() async {
    final transactions = await getAllTransactions();
    final summary = <String, double>{};
    
    for (final transaction in transactions.where((t) => t.isCompleted)) {
      summary[transaction.type] = (summary[transaction.type] ?? 0) + transaction.amount;
    }
    
    return summary;
  }

  @override
  Future<Map<DateTime, double>> getDailyTransactionTotals(
    DateTime startDate,
    DateTime endDate,
  ) async {
    final transactions = await getTransactionsByDateRange(startDate, endDate);
    final dailyTotals = <DateTime, double>{};
    
    for (final transaction in transactions.where((t) => t.isCompleted)) {
      final date = DateTime(
        transaction.transactionDate.year,
        transaction.transactionDate.month,
        transaction.transactionDate.day,
      );
      
      final amount = transaction.isCredit ? transaction.amount : -transaction.amount;
      dailyTotals[date] = (dailyTotals[date] ?? 0) + amount;
    }
    
    return dailyTotals;
  }

  @override
  Future<Map<String, double>> getMonthlyTransactionTotals(int year) async {
    final transactions = await getAllTransactions();
    final monthlyTotals = <String, double>{};
    
    for (final transaction in transactions.where((t) => t.isCompleted)) {
      if (transaction.transactionDate.year == year) {
        final month = transaction.transactionDate.month.toString().padLeft(2, '0');
        final amount = transaction.isCredit ? transaction.amount : -transaction.amount;
        monthlyTotals[month] = (monthlyTotals[month] ?? 0) + amount;
      }
    }
    
    return monthlyTotals;
  }

  @override
  Future<List<TransactionEntity>> getUnsyncedTransactions() async {
    final models = await _localDatabase.getUnsyncedTransactions();
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<void> markTransactionAsSynced(String id) async {
    final transaction = await getTransactionById(id);
    if (transaction != null) {
      final updatedTransaction = transaction.copyWith(isSynced: true);
      final model = TransactionModel.fromEntity(updatedTransaction);
      await _localDatabase.saveTransaction(model);
    }
  }
}
