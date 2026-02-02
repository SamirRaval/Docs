import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../domain/entities/credit_entity.dart';
import '../../domain/entities/customer_entity.dart';
import '../../domain/usecases/credit_usecases.dart';
import '../../domain/usecases/customer_usecases.dart';

/// Credit Controller for managing credit state and operations
class CreditController extends GetxController {
  final CreditUseCases _creditUseCases = Get.find<CreditUseCases>();
  final CustomerUseCases _customerUseCases = Get.find<CustomerUseCases>();

  // Loading states
  final RxBool isLoading = false.obs;
  final RxBool isSubmitting = false.obs;

  // Credit list
  final RxList<CreditEntity> credits = <CreditEntity>[].obs;
  final RxList<CreditEntity> filteredCredits = <CreditEntity>[].obs;

  // Customer list for dropdown
  final RxList<CustomerEntity> customers = <CustomerEntity>[].obs;

  // Selected credit (for detail view)
  final Rx<CreditEntity?> selectedCredit = Rx<CreditEntity?>(null);

  // Search and filter
  final RxString searchQuery = ''.obs;
  final RxString statusFilter = 'all'.obs;
  final RxString typeFilter = 'all'.obs;

  // Form controllers
  final Rx<CustomerEntity?> selectedCustomer = Rx<CustomerEntity?>(null);
  final principalAmountController = TextEditingController();
  final interestRateController = TextEditingController();
  final termMonthsController = TextEditingController();
  final purposeController = TextEditingController();
  final notesController = TextEditingController();
  final Rx<DateTime> startDate = DateTime.now().obs;
  final RxString creditType = 'personal'.obs;

  @override
  void onInit() {
    super.onInit();
    loadCredits();
    loadCustomers();
    
    debounce(
      searchQuery,
      (_) => _applyFilters(),
      time: const Duration(milliseconds: 300),
    );
  }

  @override
  void onClose() {
    principalAmountController.dispose();
    interestRateController.dispose();
    termMonthsController.dispose();
    purposeController.dispose();
    notesController.dispose();
    super.onClose();
  }

  /// Load all credits
  Future<void> loadCredits() async {
    isLoading.value = true;
    try {
      credits.value = await _creditUseCases.getAllCredits();
      _applyFilters();
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to load credits',
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
    var result = credits.toList();

    // Apply search
    if (searchQuery.value.isNotEmpty) {
      final query = searchQuery.value.toLowerCase();
      result = result.where((c) {
        return (c.customerName?.toLowerCase().contains(query) ?? false) ||
               c.id.contains(query);
      }).toList();
    }

    // Apply status filter
    if (statusFilter.value != 'all') {
      result = result.where((c) => c.status == statusFilter.value).toList();
    }

    // Apply type filter
    if (typeFilter.value != 'all') {
      result = result.where((c) => c.creditType == typeFilter.value).toList();
    }

    filteredCredits.value = result;
  }

  /// Set search query
  void setSearchQuery(String query) {
    searchQuery.value = query;
  }

  /// Set status filter
  void setStatusFilter(String status) {
    statusFilter.value = status;
    _applyFilters();
  }

  /// Set type filter
  void setTypeFilter(String type) {
    typeFilter.value = type;
    _applyFilters();
  }

  /// Create a new credit
  Future<bool> createCredit() async {
    if (!_validateForm()) return false;

    isSubmitting.value = true;
    try {
      await _creditUseCases.createCredit(
        customerId: selectedCustomer.value!.id,
        customerName: selectedCustomer.value!.name,
        principalAmount: double.parse(principalAmountController.text),
        interestRate: double.tryParse(interestRateController.text) ?? 0.0,
        termMonths: int.parse(termMonthsController.text),
        startDate: startDate.value,
        creditType: creditType.value,
        purpose: purposeController.text.trim().isEmpty ? null : purposeController.text.trim(),
        notes: notesController.text.trim().isEmpty ? null : notesController.text.trim(),
      );

      Get.snackbar(
        'Success',
        'Credit created successfully',
        snackPosition: SnackPosition.BOTTOM,
      );

      _clearForm();
      await loadCredits();
      Get.back();
      return true;
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to create credit: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    } finally {
      isSubmitting.value = false;
    }
  }

  /// Approve a credit
  Future<bool> approveCredit(String creditId) async {
    try {
      await _creditUseCases.approveCredit(creditId);
      
      Get.snackbar(
        'Success',
        'Credit approved successfully',
        snackPosition: SnackPosition.BOTTOM,
      );

      await loadCredits();
      return true;
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to approve credit: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }
  }

  /// Reject a credit
  Future<bool> rejectCredit(String creditId, {String? reason}) async {
    try {
      await _creditUseCases.rejectCredit(creditId, reason: reason);
      
      Get.snackbar(
        'Success',
        'Credit rejected',
        snackPosition: SnackPosition.BOTTOM,
      );

      await loadCredits();
      return true;
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to reject credit: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }
  }

  /// Record payment
  Future<bool> recordPayment(String creditId, double amount) async {
    try {
      await _creditUseCases.recordPayment(creditId, amount);
      
      Get.snackbar(
        'Success',
        'Payment recorded successfully',
        snackPosition: SnackPosition.BOTTOM,
      );

      await loadCredits();
      return true;
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to record payment: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }
  }

  /// Delete credit
  Future<bool> deleteCredit(String id) async {
    try {
      await _creditUseCases.deleteCredit(id);
      
      Get.snackbar(
        'Success',
        'Credit deleted successfully',
        snackPosition: SnackPosition.BOTTOM,
      );

      await loadCredits();
      return true;
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to delete credit: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }
  }

  /// Get credits by customer
  Future<List<CreditEntity>> getCreditsByCustomer(String customerId) async {
    return _creditUseCases.getCreditsByCustomerId(customerId);
  }

  /// Validate form
  bool _validateForm() {
    if (selectedCustomer.value == null) {
      Get.snackbar('Error', 'Please select a customer', snackPosition: SnackPosition.BOTTOM);
      return false;
    }
    if (principalAmountController.text.isEmpty) {
      Get.snackbar('Error', 'Principal amount is required', snackPosition: SnackPosition.BOTTOM);
      return false;
    }
    if (termMonthsController.text.isEmpty) {
      Get.snackbar('Error', 'Term (months) is required', snackPosition: SnackPosition.BOTTOM);
      return false;
    }
    return true;
  }

  /// Clear form
  void _clearForm() {
    selectedCustomer.value = null;
    principalAmountController.clear();
    interestRateController.clear();
    termMonthsController.clear();
    purposeController.clear();
    notesController.clear();
    startDate.value = DateTime.now();
    creditType.value = 'personal';
  }

  /// Navigate to add credit
  void goToAddCredit() {
    _clearForm();
    interestRateController.text = '0';
    termMonthsController.text = '12';
    Get.toNamed('/credits/add');
  }
}
