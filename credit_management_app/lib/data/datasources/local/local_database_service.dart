import 'package:hive_flutter/hive_flutter.dart';

import '../../models/customer_model.dart';
import '../../models/credit_model.dart';
import '../../models/transaction_model.dart';

/// Local database service using Hive for offline data storage
class LocalDatabaseService {
  // Box names
  static const String _customersBox = 'customers';
  static const String _creditsBox = 'credits';
  static const String _transactionsBox = 'transactions';
  static const String _syncQueueBox = 'sync_queue';
  static const String _settingsBox = 'settings';

  // ==================== CUSTOMERS ====================

  /// Get all customers
  Future<List<CustomerModel>> getAllCustomers() async {
    final box = Hive.box(_customersBox);
    final List<CustomerModel> customers = [];
    
    for (var key in box.keys) {
      final data = box.get(key);
      if (data != null) {
        customers.add(CustomerModel.fromJson(Map<String, dynamic>.from(data)));
      }
    }
    
    // Sort by createdAt descending
    customers.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return customers;
  }

  /// Get customer by ID
  Future<CustomerModel?> getCustomerById(String id) async {
    final box = Hive.box(_customersBox);
    final data = box.get(id);
    if (data == null) return null;
    return CustomerModel.fromJson(Map<String, dynamic>.from(data));
  }

  /// Save customer
  Future<CustomerModel> saveCustomer(CustomerModel customer) async {
    final box = Hive.box(_customersBox);
    await box.put(customer.id, customer.toJson());
    return customer;
  }

  /// Delete customer
  Future<bool> deleteCustomer(String id) async {
    final box = Hive.box(_customersBox);
    await box.delete(id);
    return true;
  }

  /// Search customers
  Future<List<CustomerModel>> searchCustomers(String query) async {
    final customers = await getAllCustomers();
    final lowercaseQuery = query.toLowerCase();
    
    return customers.where((customer) {
      return customer.name.toLowerCase().contains(lowercaseQuery) ||
             customer.email.toLowerCase().contains(lowercaseQuery) ||
             customer.phone.contains(query);
    }).toList();
  }

  /// Get customers by status
  Future<List<CustomerModel>> getCustomersByStatus(String status) async {
    final customers = await getAllCustomers();
    return customers.where((c) => c.status == status).toList();
  }

  /// Get customers by risk level
  Future<List<CustomerModel>> getCustomersByRiskLevel(String riskLevel) async {
    final customers = await getAllCustomers();
    return customers.where((c) => c.riskLevel == riskLevel).toList();
  }

  /// Get unsynced customers
  Future<List<CustomerModel>> getUnsyncedCustomers() async {
    final customers = await getAllCustomers();
    return customers.where((c) => !c.isSynced).toList();
  }

  // ==================== CREDITS ====================

  /// Get all credits
  Future<List<CreditModel>> getAllCredits() async {
    final box = Hive.box(_creditsBox);
    final List<CreditModel> credits = [];
    
    for (var key in box.keys) {
      final data = box.get(key);
      if (data != null) {
        credits.add(CreditModel.fromJson(Map<String, dynamic>.from(data)));
      }
    }
    
    credits.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return credits;
  }

  /// Get credit by ID
  Future<CreditModel?> getCreditById(String id) async {
    final box = Hive.box(_creditsBox);
    final data = box.get(id);
    if (data == null) return null;
    return CreditModel.fromJson(Map<String, dynamic>.from(data));
  }

  /// Save credit
  Future<CreditModel> saveCredit(CreditModel credit) async {
    final box = Hive.box(_creditsBox);
    await box.put(credit.id, credit.toJson());
    return credit;
  }

  /// Delete credit
  Future<bool> deleteCredit(String id) async {
    final box = Hive.box(_creditsBox);
    await box.delete(id);
    return true;
  }

  /// Get credits by customer ID
  Future<List<CreditModel>> getCreditsByCustomerId(String customerId) async {
    final credits = await getAllCredits();
    return credits.where((c) => c.customerId == customerId).toList();
  }

  /// Get credits by status
  Future<List<CreditModel>> getCreditsByStatus(String status) async {
    final credits = await getAllCredits();
    return credits.where((c) => c.status == status).toList();
  }

  /// Get unsynced credits
  Future<List<CreditModel>> getUnsyncedCredits() async {
    final credits = await getAllCredits();
    return credits.where((c) => !c.isSynced).toList();
  }

  // ==================== TRANSACTIONS ====================

  /// Get all transactions
  Future<List<TransactionModel>> getAllTransactions() async {
    final box = Hive.box(_transactionsBox);
    final List<TransactionModel> transactions = [];
    
    for (var key in box.keys) {
      final data = box.get(key);
      if (data != null) {
        transactions.add(TransactionModel.fromJson(Map<String, dynamic>.from(data)));
      }
    }
    
    transactions.sort((a, b) => b.transactionDate.compareTo(a.transactionDate));
    return transactions;
  }

  /// Get transaction by ID
  Future<TransactionModel?> getTransactionById(String id) async {
    final box = Hive.box(_transactionsBox);
    final data = box.get(id);
    if (data == null) return null;
    return TransactionModel.fromJson(Map<String, dynamic>.from(data));
  }

  /// Save transaction
  Future<TransactionModel> saveTransaction(TransactionModel transaction) async {
    final box = Hive.box(_transactionsBox);
    await box.put(transaction.id, transaction.toJson());
    return transaction;
  }

  /// Delete transaction
  Future<bool> deleteTransaction(String id) async {
    final box = Hive.box(_transactionsBox);
    await box.delete(id);
    return true;
  }

  /// Get transactions by customer ID
  Future<List<TransactionModel>> getTransactionsByCustomerId(String customerId) async {
    final transactions = await getAllTransactions();
    return transactions.where((t) => t.customerId == customerId).toList();
  }

  /// Get transactions by credit ID
  Future<List<TransactionModel>> getTransactionsByCreditId(String creditId) async {
    final transactions = await getAllTransactions();
    return transactions.where((t) => t.creditId == creditId).toList();
  }

  /// Get transactions by type
  Future<List<TransactionModel>> getTransactionsByType(String type) async {
    final transactions = await getAllTransactions();
    return transactions.where((t) => t.type == type).toList();
  }

  /// Get transactions by date range
  Future<List<TransactionModel>> getTransactionsByDateRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    final transactions = await getAllTransactions();
    return transactions.where((t) {
      final date = DateTime.parse(t.transactionDate);
      return date.isAfter(startDate) && date.isBefore(endDate);
    }).toList();
  }

  /// Get unsynced transactions
  Future<List<TransactionModel>> getUnsyncedTransactions() async {
    final transactions = await getAllTransactions();
    return transactions.where((t) => !t.isSynced).toList();
  }

  // ==================== SYNC QUEUE ====================

  /// Add item to sync queue
  Future<void> addToSyncQueue({
    required String entityType,
    required String entityId,
    required String operation,
    required Map<String, dynamic> data,
  }) async {
    final box = Hive.box(_syncQueueBox);
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    
    await box.put(id, {
      'id': id,
      'entityType': entityType,
      'entityId': entityId,
      'operation': operation,
      'data': data,
      'retryCount': 0,
      'status': 'pending',
      'createdAt': DateTime.now().toIso8601String(),
    });
  }

  /// Get pending sync items
  Future<List<Map<String, dynamic>>> getPendingSyncItems() async {
    final box = Hive.box(_syncQueueBox);
    final List<Map<String, dynamic>> items = [];
    
    for (var key in box.keys) {
      final data = box.get(key);
      if (data != null && data['status'] == 'pending') {
        items.add(Map<String, dynamic>.from(data));
      }
    }
    
    // Sort by createdAt ascending (FIFO)
    items.sort((a, b) => a['createdAt'].compareTo(b['createdAt']));
    return items;
  }

  /// Mark sync item as completed
  Future<void> markSyncItemCompleted(String id) async {
    final box = Hive.box(_syncQueueBox);
    await box.delete(id);
  }

  /// Update sync item retry count
  Future<void> updateSyncItemRetry(String id, String? errorMessage) async {
    final box = Hive.box(_syncQueueBox);
    final data = box.get(id);
    
    if (data != null) {
      final updatedData = Map<String, dynamic>.from(data);
      updatedData['retryCount'] = (updatedData['retryCount'] ?? 0) + 1;
      updatedData['errorMessage'] = errorMessage;
      
      if (updatedData['retryCount'] >= 3) {
        updatedData['status'] = 'failed';
      }
      
      await box.put(id, updatedData);
    }
  }

  // ==================== SETTINGS ====================

  /// Get setting value
  Future<dynamic> getSetting(String key) async {
    final box = Hive.box(_settingsBox);
    return box.get(key);
  }

  /// Save setting value
  Future<void> saveSetting(String key, dynamic value) async {
    final box = Hive.box(_settingsBox);
    await box.put(key, value);
  }

  /// Clear all data (for logout/reset)
  Future<void> clearAllData() async {
    await Hive.box(_customersBox).clear();
    await Hive.box(_creditsBox).clear();
    await Hive.box(_transactionsBox).clear();
    await Hive.box(_syncQueueBox).clear();
    await Hive.box(_settingsBox).clear();
  }
}
