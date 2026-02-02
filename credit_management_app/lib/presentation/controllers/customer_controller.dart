import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../domain/entities/customer_entity.dart';
import '../../domain/usecases/customer_usecases.dart';

/// Customer Controller for managing customer state and operations
class CustomerController extends GetxController {
  final CustomerUseCases _customerUseCases = Get.find<CustomerUseCases>();

  // Loading states
  final RxBool isLoading = false.obs;
  final RxBool isSubmitting = false.obs;

  // Customer list
  final RxList<CustomerEntity> customers = <CustomerEntity>[].obs;
  final RxList<CustomerEntity> filteredCustomers = <CustomerEntity>[].obs;

  // Selected customer (for detail view)
  final Rx<CustomerEntity?> selectedCustomer = Rx<CustomerEntity?>(null);

  // Search and filter
  final RxString searchQuery = ''.obs;
  final RxString statusFilter = 'all'.obs;
  final RxString riskFilter = 'all'.obs;

  // Form controllers
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final addressController = TextEditingController();
  final cityController = TextEditingController();
  final stateController = TextEditingController();
  final postalCodeController = TextEditingController();
  final companyNameController = TextEditingController();
  final taxIdController = TextEditingController();
  final creditLimitController = TextEditingController();
  final creditScoreController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    loadCustomers();
    
    // Set up search debounce
    debounce(
      searchQuery,
      (_) => _applyFilters(),
      time: const Duration(milliseconds: 300),
    );
  }

  @override
  void onClose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    addressController.dispose();
    cityController.dispose();
    stateController.dispose();
    postalCodeController.dispose();
    companyNameController.dispose();
    taxIdController.dispose();
    creditLimitController.dispose();
    creditScoreController.dispose();
    super.onClose();
  }

  /// Load all customers
  Future<void> loadCustomers() async {
    isLoading.value = true;
    try {
      customers.value = await _customerUseCases.getAllCustomers();
      _applyFilters();
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to load customers',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Apply search and filters
  void _applyFilters() {
    var result = customers.toList();

    // Apply search
    if (searchQuery.value.isNotEmpty) {
      final query = searchQuery.value.toLowerCase();
      result = result.where((c) {
        return c.name.toLowerCase().contains(query) ||
               c.email.toLowerCase().contains(query) ||
               c.phone.contains(query);
      }).toList();
    }

    // Apply status filter
    if (statusFilter.value != 'all') {
      result = result.where((c) => c.status == statusFilter.value).toList();
    }

    // Apply risk filter
    if (riskFilter.value != 'all') {
      result = result.where((c) => c.riskLevel == riskFilter.value).toList();
    }

    filteredCustomers.value = result;
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

  /// Set risk filter
  void setRiskFilter(String risk) {
    riskFilter.value = risk;
    _applyFilters();
  }

  /// Select customer for detail view
  void selectCustomer(CustomerEntity customer) {
    selectedCustomer.value = customer;
    Get.toNamed('/customers/detail');
  }

  /// Load customer by ID
  Future<void> loadCustomerById(String id) async {
    isLoading.value = true;
    try {
      selectedCustomer.value = await _customerUseCases.getCustomerById(id);
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to load customer',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Create a new customer
  Future<bool> createCustomer() async {
    if (!_validateForm()) return false;

    isSubmitting.value = true;
    try {
      await _customerUseCases.createCustomer(
        name: nameController.text.trim(),
        email: emailController.text.trim(),
        phone: phoneController.text.trim(),
        address: addressController.text.trim().isEmpty ? null : addressController.text.trim(),
        city: cityController.text.trim().isEmpty ? null : cityController.text.trim(),
        state: stateController.text.trim().isEmpty ? null : stateController.text.trim(),
        postalCode: postalCodeController.text.trim().isEmpty ? null : postalCodeController.text.trim(),
        companyName: companyNameController.text.trim().isEmpty ? null : companyNameController.text.trim(),
        taxId: taxIdController.text.trim().isEmpty ? null : taxIdController.text.trim(),
        creditLimit: double.tryParse(creditLimitController.text) ?? 10000.0,
        creditScore: int.tryParse(creditScoreController.text) ?? 700,
      );

      Get.snackbar(
        'Success',
        'Customer created successfully',
        snackPosition: SnackPosition.BOTTOM,
      );

      _clearForm();
      await loadCustomers();
      Get.back();
      return true;
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to create customer: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    } finally {
      isSubmitting.value = false;
    }
  }

  /// Update existing customer
  Future<bool> updateCustomer() async {
    if (selectedCustomer.value == null) return false;
    if (!_validateForm()) return false;

    isSubmitting.value = true;
    try {
      final updatedCustomer = selectedCustomer.value!.copyWith(
        name: nameController.text.trim(),
        email: emailController.text.trim(),
        phone: phoneController.text.trim(),
        address: addressController.text.trim().isEmpty ? null : addressController.text.trim(),
        city: cityController.text.trim().isEmpty ? null : cityController.text.trim(),
        state: stateController.text.trim().isEmpty ? null : stateController.text.trim(),
        postalCode: postalCodeController.text.trim().isEmpty ? null : postalCodeController.text.trim(),
        companyName: companyNameController.text.trim().isEmpty ? null : companyNameController.text.trim(),
        taxId: taxIdController.text.trim().isEmpty ? null : taxIdController.text.trim(),
        creditLimit: double.tryParse(creditLimitController.text) ?? selectedCustomer.value!.creditLimit,
        creditScore: int.tryParse(creditScoreController.text) ?? selectedCustomer.value!.creditScore,
      );

      await _customerUseCases.updateCustomer(updatedCustomer);

      Get.snackbar(
        'Success',
        'Customer updated successfully',
        snackPosition: SnackPosition.BOTTOM,
      );

      await loadCustomers();
      Get.back();
      return true;
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to update customer: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    } finally {
      isSubmitting.value = false;
    }
  }

  /// Delete customer
  Future<bool> deleteCustomer(String id) async {
    try {
      await _customerUseCases.deleteCustomer(id);
      
      Get.snackbar(
        'Success',
        'Customer deleted successfully',
        snackPosition: SnackPosition.BOTTOM,
      );

      await loadCustomers();
      return true;
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to delete customer: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }
  }

  /// Populate form for editing
  void populateFormForEdit(CustomerEntity customer) {
    nameController.text = customer.name;
    emailController.text = customer.email;
    phoneController.text = customer.phone;
    addressController.text = customer.address ?? '';
    cityController.text = customer.city ?? '';
    stateController.text = customer.state ?? '';
    postalCodeController.text = customer.postalCode ?? '';
    companyNameController.text = customer.companyName ?? '';
    taxIdController.text = customer.taxId ?? '';
    creditLimitController.text = customer.creditLimit.toString();
    creditScoreController.text = customer.creditScore.toString();
  }

  /// Validate form
  bool _validateForm() {
    if (nameController.text.trim().isEmpty) {
      Get.snackbar('Error', 'Name is required', snackPosition: SnackPosition.BOTTOM);
      return false;
    }
    if (emailController.text.trim().isEmpty) {
      Get.snackbar('Error', 'Email is required', snackPosition: SnackPosition.BOTTOM);
      return false;
    }
    if (phoneController.text.trim().isEmpty) {
      Get.snackbar('Error', 'Phone is required', snackPosition: SnackPosition.BOTTOM);
      return false;
    }
    return true;
  }

  /// Clear form
  void _clearForm() {
    nameController.clear();
    emailController.clear();
    phoneController.clear();
    addressController.clear();
    cityController.clear();
    stateController.clear();
    postalCodeController.clear();
    companyNameController.clear();
    taxIdController.clear();
    creditLimitController.clear();
    creditScoreController.clear();
  }

  /// Navigate to add customer
  void goToAddCustomer() {
    _clearForm();
    creditLimitController.text = '10000';
    creditScoreController.text = '700';
    Get.toNamed('/customers/add');
  }
}
