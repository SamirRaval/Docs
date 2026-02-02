import '../entities/customer_entity.dart';

/// Abstract repository interface for customer operations
abstract class CustomerRepository {
  /// Get all customers
  Future<List<CustomerEntity>> getAllCustomers();

  /// Get customer by ID
  Future<CustomerEntity?> getCustomerById(String id);

  /// Search customers by name, email, or phone
  Future<List<CustomerEntity>> searchCustomers(String query);

  /// Get customers by status
  Future<List<CustomerEntity>> getCustomersByStatus(String status);

  /// Get customers by risk level
  Future<List<CustomerEntity>> getCustomersByRiskLevel(String riskLevel);

  /// Create a new customer
  Future<CustomerEntity> createCustomer(CustomerEntity customer);

  /// Update an existing customer
  Future<CustomerEntity> updateCustomer(CustomerEntity customer);

  /// Delete a customer
  Future<bool> deleteCustomer(String id);

  /// Get total customers count
  Future<int> getTotalCustomersCount();

  /// Get customers with overdue payments
  Future<List<CustomerEntity>> getOverdueCustomers();

  /// Get high risk customers
  Future<List<CustomerEntity>> getHighRiskCustomers();

  /// Get recently added customers
  Future<List<CustomerEntity>> getRecentCustomers({int limit = 5});

  /// Update customer credit balance
  Future<CustomerEntity> updateCustomerBalance(String id, double newBalance);

  /// Update customer credit limit
  Future<CustomerEntity> updateCustomerCreditLimit(String id, double newLimit);

  /// Get unsynced customers
  Future<List<CustomerEntity>> getUnsyncedCustomers();

  /// Mark customer as synced
  Future<void> markCustomerAsSynced(String id);
}
