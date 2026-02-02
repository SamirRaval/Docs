import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../domain/entities/transaction_entity.dart';
import '../../domain/entities/customer_entity.dart';
import '../../domain/usecases/transaction_usecases.dart';
import '../../domain/usecases/customer_usecases.dart';

/// Transaction Controller for managing transaction state and operations
class TransactionController extends GetxController {
  final TransactionUseCases _transactionUseCases = Get.find<TransactionUseCases>();
  final CustomerUseCases _customerUseCases = Get.find<CustomerUseCases>();

  // Loading states
  final RxBool isLoading = false.obs;
  final RxBool isSubmitting = false.obs;

  // Transaction list
  final RxList<TransactionEntity> transactions = <TransactionEntity>[].obs;
  final RxList<TransactionEntity> filteredTransactions = <TransactionEntity>[].obs;

  // Customer list for dropdown
  final RxList<CustomerEntity> customers = <CustomerEntity>[].obs;

  // Selected transaction (for detail view)
  final Rx<TransactionEntity?> selectedTransaction = Rx<TransactionEntity?>(null);

  // Search and filter
  final RxString searchQuery = ''.obs;
  final RxString typeFilter = 'all'.obs;
  final RxString statusFilter = 'all'.obs;

  // Form controllers
  final Rx<CustomerEntity?> selectedCustomer = Rx<CustomerEntity?>(null);
  final amountController = TextEditingController();
  final descriptionController = TextEditingController();
  final referenceController = TextEditingController();
  final RxString transactionType = 'payment'.obs;
  final RxString paymentMethod = 'cash'.obs;
  final Rx<DateTime> transactionDate = DateTime.now().obs;

  @override
  void onInit() {
    super.onInit();
    loadTransactions();
    loadCustomers();
    
    debounce(
      searchQuery,
      (_) => _applyFilters(),
      time: const Duration(milliseconds: 300),
    );
  }

  @override
  void onClose() {
    amountController.dispose();
    descriptionController.dispose();
    referenceController.dispose();
    super.onClose();
  }

  /// Load all transactions
  Future<void> loadTransactions() async {
    isLoading.value = true;
    try {
      transactions.value = await _transactionUseCases.getAllTransactions();
      _applyFilters();
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to load transactions',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Load customers for dropdown
  Future<void> loadCustomers() async {
    try {
      customers.value = await _customerUseCases.getAllCustomers();
    } catch (e) {
      // Silent fail for customers
    }
  }

  /// Apply search and filters
  void _applyFilters() {
    var result = transactions.toList();

    // Apply search
    if (searchQuery.value.isNotEmpty) {
      final query = searchQuery.value.toLowerCase();
      result = result.where((t) {
        return (t.customerName?.toLowerCase().contains(query) ?? false) ||
               (t.referenceNumber?.contains(query) ?? false) ||
               t.id.contains(query);
      }).toList();
    }

    // Apply type filter
    if (typeFilter.value != 'all') {
      result = result.where((t) => t.type == typeFilter.value).toList();
    }

    // Apply status filter
    if (statusFilter.value != 'all') {
      result = result.where((t) => t.status == statusFilter.value).toList();
    }

    filteredTransactions.value = result;
  }

  /// Set search query
  void setSearchQuery(String query) {
    searchQuery.value = query;
  }

  /// Set type filter
  void setTypeFilter(String type) {
    typeFilter.value = type;
    _applyFilters();
  }

  /// Set status filter
  void setStatusFilter(String status) {
    statusFilter.value = status;
    _applyFilters();
  }

  /// Create a new transaction
  Future<bool> createTransaction() async {
    if (!_validateForm()) return false;

    isSubmitting.value = true;
    try {
      await _transactionUseCases.createTransaction(
        customerId: selectedCustomer.value!.id,
        customerName: selectedCustomer.value!.name,
        amount: double.parse(amountController.text),
        type: transactionType.value,
        description: descriptionController.text.trim().isEmpty ? null : descriptionController.text.trim(),
        referenceNumber: referenceController.text.trim().isEmpty ? null : referenceController.text.trim(),
        paymentMethod: paymentMethod.value,
        transactionDate: transactionDate.value,
      );

      Get.snackbar(
        'Success',
        'Transaction created successfully',
        snackPosition: SnackPosition.BOTTOM,
      );

      _clearForm();
      await loadTransactions();
      Get.back();
      return true;
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to create transaction: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    } finally {
      isSubmitting.value = false;
    }
  }

  /// Cancel a transaction
  Future<bool> cancelTransaction(String transactionId) async {
    try {
      await _transactionUseCases.cancelTransaction(transactionId);
      
      Get.snackbar(
        'Success',
        'Transaction cancelled',
        snackPosition: SnackPosition.BOTTOM,
      );

      await loadTransactions();
      return true;
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to cancel transaction: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }
  }

  /// Delete transaction
  Future<bool> deleteTransaction(String id) async {
    try {
      await _transactionUseCases.deleteTransaction(id);
      
      Get.snackbar(
        'Success',
        'Transaction deleted successfully',
        snackPosition: SnackPosition.BOTTOM,
      );

      await loadTransactions();
      return true;
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to delete transaction: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }
  }

  /// Get transactions by customer
  Future<List<TransactionEntity>> getTransactionsByCustomer(String customerId) async {
    return _transactionUseCases.getTransactionsByCustomerId(customerId);
  }

  /// Get transaction summary
  Future<Map<String, dynamic>> getTransactionSummary() async {
    return _transactionUseCases.getDashboardStats();
  }

  /// Validate form
  bool _validateForm() {
    if (selectedCustomer.value == null) {
      Get.snackbar('Error', 'Please select a customer', snackPosition: SnackPosition.BOTTOM);
      return false;
    }
    if (amountController.text.isEmpty) {
      Get.snackbar('Error', 'Amount is required', snackPosition: SnackPosition.BOTTOM);
      return false;
    }
    final amount = double.tryParse(amountController.text);
    if (amount == null || amount <= 0) {
      Get.snackbar('Error', 'Please enter a valid amount', snackPosition: SnackPosition.BOTTOM);
      return false;
    }
    return true;
  }

  /// Clear form
  void _clearForm() {
    selectedCustomer.value = null;
    amountController.clear();
    descriptionController.clear();
    referenceController.clear();
    transactionType.value = 'payment';
    paymentMethod.value = 'cash';
    transactionDate.value = DateTime.now();
  }

  /// Navigate to add transaction
  void goToAddTransaction() {
    _clearForm();
    Get.toNamed('/transactions/add');
  }
}
