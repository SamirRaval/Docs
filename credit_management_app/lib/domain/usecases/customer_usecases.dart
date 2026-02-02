import '../entities/customer_entity.dart';
import '../repositories/customer_repository.dart';

/// Use cases for customer operations
class CustomerUseCases {
  final CustomerRepository _repository;

  CustomerUseCases(this._repository);

  /// Get all customers
  Future<List<CustomerEntity>> getAllCustomers() {
    return _repository.getAllCustomers();
  }

  /// Get customer by ID
  Future<CustomerEntity?> getCustomerById(String id) {
    return _repository.getCustomerById(id);
  }

  /// Search customers
  Future<List<CustomerEntity>> searchCustomers(String query) {
    return _repository.searchCustomers(query);
  }

  /// Get customers by status
  Future<List<CustomerEntity>> getCustomersByStatus(String status) {
    return _repository.getCustomersByStatus(status);
  }

  /// Get customers by risk level
  Future<List<CustomerEntity>> getCustomersByRiskLevel(String riskLevel) {
    return _repository.getCustomersByRiskLevel(riskLevel);
  }

  /// Create a new customer
  Future<CustomerEntity> createCustomer({
    required String name,
    required String email,
    required String phone,
    String? address,
    String? city,
    String? state,
    String? country,
    String? postalCode,
    String? companyName,
    String? taxId,
    int creditScore = 700,
    double creditLimit = 10000.0,
  }) {
    final now = DateTime.now();
    final customer = CustomerEntity(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      email: email,
      phone: phone,
      address: address,
      city: city,
      state: state,
      country: country,
      postalCode: postalCode,
      companyName: companyName,
      taxId: taxId,
      creditScore: creditScore,
      creditLimit: creditLimit,
      currentBalance: 0.0,
      availableCredit: creditLimit,
      riskLevel: _calculateRiskLevel(creditScore),
      status: 'active',
      createdAt: now,
      updatedAt: now,
      isSynced: false,
    );
    return _repository.createCustomer(customer);
  }

  /// Update an existing customer
  Future<CustomerEntity> updateCustomer(CustomerEntity customer) {
    final updatedCustomer = customer.copyWith(
      updatedAt: DateTime.now(),
      isSynced: false,
    );
    return _repository.updateCustomer(updatedCustomer);
  }

  /// Delete a customer
  Future<bool> deleteCustomer(String id) {
    return _repository.deleteCustomer(id);
  }

  /// Get dashboard statistics
  Future<Map<String, dynamic>> getDashboardStats() async {
    final totalCount = await _repository.getTotalCustomersCount();
    final overdueCustomers = await _repository.getOverdueCustomers();
    final highRiskCustomers = await _repository.getHighRiskCustomers();
    final recentCustomers = await _repository.getRecentCustomers();

    return {
      'totalCustomers': totalCount,
      'overdueCount': overdueCustomers.length,
      'highRiskCount': highRiskCustomers.length,
      'recentCustomers': recentCustomers,
    };
  }

  /// Get overdue customers
  Future<List<CustomerEntity>> getOverdueCustomers() {
    return _repository.getOverdueCustomers();
  }

  /// Get high risk customers
  Future<List<CustomerEntity>> getHighRiskCustomers() {
    return _repository.getHighRiskCustomers();
  }

  /// Update customer balance
  Future<CustomerEntity> updateCustomerBalance(String id, double newBalance) {
    return _repository.updateCustomerBalance(id, newBalance);
  }

  /// Update customer credit limit
  Future<CustomerEntity> updateCustomerCreditLimit(String id, double newLimit) {
    return _repository.updateCustomerCreditLimit(id, newLimit);
  }

  /// Get unsynced customers for sync
  Future<List<CustomerEntity>> getUnsyncedCustomers() {
    return _repository.getUnsyncedCustomers();
  }

  /// Mark customer as synced
  Future<void> markCustomerAsSynced(String id) {
    return _repository.markCustomerAsSynced(id);
  }

  /// Calculate risk level based on credit score
  String _calculateRiskLevel(int creditScore) {
    if (creditScore >= 750) return 'low';
    if (creditScore >= 650) return 'medium';
    return 'high';
  }
}
