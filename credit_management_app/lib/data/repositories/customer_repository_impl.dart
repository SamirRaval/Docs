import '../../domain/entities/customer_entity.dart';
import '../../domain/repositories/customer_repository.dart';
import '../datasources/local/local_database_service.dart';
import '../models/customer_model.dart';

/// Implementation of CustomerRepository using local database
class CustomerRepositoryImpl implements CustomerRepository {
  final LocalDatabaseService _localDatabase;

  CustomerRepositoryImpl(this._localDatabase);

  @override
  Future<List<CustomerEntity>> getAllCustomers() async {
    final models = await _localDatabase.getAllCustomers();
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<CustomerEntity?> getCustomerById(String id) async {
    final model = await _localDatabase.getCustomerById(id);
    return model?.toEntity();
  }

  @override
  Future<List<CustomerEntity>> searchCustomers(String query) async {
    final models = await _localDatabase.searchCustomers(query);
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<List<CustomerEntity>> getCustomersByStatus(String status) async {
    final models = await _localDatabase.getCustomersByStatus(status);
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<List<CustomerEntity>> getCustomersByRiskLevel(String riskLevel) async {
    final models = await _localDatabase.getCustomersByRiskLevel(riskLevel);
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<CustomerEntity> createCustomer(CustomerEntity customer) async {
    final model = CustomerModel.fromEntity(customer);
    final savedModel = await _localDatabase.saveCustomer(model);
    
    // Add to sync queue
    await _localDatabase.addToSyncQueue(
      entityType: 'customer',
      entityId: customer.id,
      operation: 'create',
      data: model.toJson(),
    );
    
    return savedModel.toEntity();
  }

  @override
  Future<CustomerEntity> updateCustomer(CustomerEntity customer) async {
    final model = CustomerModel.fromEntity(customer);
    final savedModel = await _localDatabase.saveCustomer(model);
    
    // Add to sync queue
    await _localDatabase.addToSyncQueue(
      entityType: 'customer',
      entityId: customer.id,
      operation: 'update',
      data: model.toJson(),
    );
    
    return savedModel.toEntity();
  }

  @override
  Future<bool> deleteCustomer(String id) async {
    final result = await _localDatabase.deleteCustomer(id);
    
    if (result) {
      // Add to sync queue
      await _localDatabase.addToSyncQueue(
        entityType: 'customer',
        entityId: id,
        operation: 'delete',
        data: {'id': id},
      );
    }
    
    return result;
  }

  @override
  Future<int> getTotalCustomersCount() async {
    final customers = await _localDatabase.getAllCustomers();
    return customers.length;
  }

  @override
  Future<List<CustomerEntity>> getOverdueCustomers() async {
    final customers = await getAllCustomers();
    return customers.where((c) => c.status == 'overdue').toList();
  }

  @override
  Future<List<CustomerEntity>> getHighRiskCustomers() async {
    final models = await _localDatabase.getCustomersByRiskLevel('high');
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<List<CustomerEntity>> getRecentCustomers({int limit = 5}) async {
    final customers = await getAllCustomers();
    return customers.take(limit).toList();
  }

  @override
  Future<CustomerEntity> updateCustomerBalance(String id, double newBalance) async {
    final customer = await getCustomerById(id);
    if (customer == null) throw Exception('Customer not found');

    final updatedCustomer = customer.copyWith(
      currentBalance: newBalance,
      availableCredit: customer.creditLimit - newBalance,
      updatedAt: DateTime.now(),
      isSynced: false,
    );

    return updateCustomer(updatedCustomer);
  }

  @override
  Future<CustomerEntity> updateCustomerCreditLimit(String id, double newLimit) async {
    final customer = await getCustomerById(id);
    if (customer == null) throw Exception('Customer not found');

    final updatedCustomer = customer.copyWith(
      creditLimit: newLimit,
      availableCredit: newLimit - customer.currentBalance,
      updatedAt: DateTime.now(),
      isSynced: false,
    );

    return updateCustomer(updatedCustomer);
  }

  @override
  Future<List<CustomerEntity>> getUnsyncedCustomers() async {
    final models = await _localDatabase.getUnsyncedCustomers();
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<void> markCustomerAsSynced(String id) async {
    final customer = await getCustomerById(id);
    if (customer != null) {
      final updatedCustomer = customer.copyWith(isSynced: true);
      final model = CustomerModel.fromEntity(updatedCustomer);
      await _localDatabase.saveCustomer(model);
    }
  }
}
